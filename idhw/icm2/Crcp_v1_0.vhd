-- file Crcp_v1_0.vhd
-- Crcp_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 13 Dec 2016
-- date modified: 3 Apr 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Crcp_v1_0 is
	generic (
		poly: std_logic_vector(15 downto 0) := x"8005";
		bitinv: std_logic := '0'
	);
	port (
		reset: in std_logic;
		
		mclk: in std_logic;

		fastclk: in std_logic; -- here, for capt and fin

		req: in std_logic;
		ack: out std_logic;
		dne: out std_logic;
		
		captNotFin: in std_logic;

		d: in std_logic_vector(7 downto 0);
		strbD: in std_logic;

		crc: out std_logic_vector(15 downto 0)
	);
end Crcp_v1_0;

architecture Crcp_v1_0 of Crcp_v1_0 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpIdle,
		stateOpCaptA, stateOpCaptB, stateOpCaptC,
		stateOpFinA, stateOpFinB,
		stateOpDone
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpIdle;

	signal d_sig: std_logic_vector(7 downto 0);

	---- other
	signal crcraw: std_logic_vector(15 downto 0) := x"0000";

	signal ackCapt: std_logic := '0';
	signal ackFin: std_logic := '0';
	
begin

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	ack <= '1' when (stateOp=stateOpCaptA or stateOp=stateOpCaptB or stateOp=stateOpCaptC or stateOp=stateOpFinA or stateOp=stateOpFinB or stateOp=stateOpDone) else '0';
	dne <= '1' when stateOp=stateOpDone else '0';
	
	process (reset, mclk)
	begin
		if reset='1' then
			stateOp_next <= stateOpInit;
			crc <= x"0000";

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or req='0') then
				crc <= x"0000";

				if req='0' then
					stateOp_next <= stateOpInit;
				else
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpIdle then
				if (req='1' and captNotFin='1') then
					stateOp_next <= stateOpCaptA;
				end if;

			elsif stateOp=stateOpCaptA then
				if strbD='1' then
					d_sig <= d;
					stateOp_next <= stateOpCaptB;
				end if;

			elsif stateOp=stateOpCaptB then
				if ackCapt='1' then
					stateOp_next <= stateOpCaptC;
				end if;

			elsif stateOp=stateOpCaptC then
				if captNotFin='0' then
					stateOp_next <= stateOpFinA;
				elsif strbD='0' then
					stateOp_next <= stateOpCaptA;
				end if;

			elsif stateOp=stateOpFinA then
				stateOp_next <= stateOpFinB;

			elsif stateOp=stateOpFinB then
				if ackFin='1' then
					crc <= crcraw;
					stateOp_next <= stateOpDone;
				end if;

			elsif stateOp=stateOpDone then
				-- if req='0' then
				-- 	stateOp_next <= stateOpInit;
				-- end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: other
	------------------------------------------------------------------------

	process (reset, fastclk)
		variable bitcnt: natural range 0 to 16;
		variable crcmsb: std_logic;
		variable b: std_logic;

	begin
		if reset='1' then
			crcraw <= x"0000";
			ackCapt <= '0';
			ackFin <= '0';

		elsif rising_edge(fastclk) then
			if stateOp=stateOpIdle then
				crcraw <= x"0000";

			elsif stateOp=stateOpCaptA then
				ackCapt <= '0';
				bitcnt := 0;
			
			elsif stateOp=stateOpCaptB then
				if bitcnt=8 then
					ackCapt <= '1';
				else
					crcmsb := crcraw(15);
					if bitinv='0' then
						b := d_sig(8-bitcnt-1);
					else
						b := d_sig(bitcnt);
					end if;
					if crcmsb='1' then
						crcraw <= (crcraw(14 downto 0) & b) xor poly;
					else
						crcraw <= crcraw(14 downto 0) & b;
					end if;
					bitcnt := bitcnt + 1;
				end if;

			elsif stateOp=stateOpFinA then
				ackFin <= '0';
				bitcnt := 0;

			elsif stateOp=stateOpFinB then
				if bitcnt=16 then
					ackFin <= '1';
				else
	 				crcmsb := crcraw(15);
					if crcmsb='1' then
						crcraw <= (crcraw(14 downto 0) & '0') xor poly;
					else
						crcraw <= crcraw(14 downto 0) & '0';
					end if;
					bitcnt := bitcnt + 1;
				end if;
			end if;
		end if;
	end process;

end Crcp_v1_0;

