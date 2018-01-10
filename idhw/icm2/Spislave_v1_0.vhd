-- file Spislave_v1_0.vhd
-- Spislave_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 17 May 2016
-- date modified: 28 Jan 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Spislave_v1_0 is
	generic (
		cpol: std_logic := '0';
		cpha: std_logic := '0';

		nssByteNotXfer: std_logic := '0';
		misoPrecphaNotCpha: std_logic := '0'
	);
	port (
		reset: in std_logic;

		mclk: in std_logic;

		req: in std_logic;
		ack: out std_logic;
		dne: out std_logic;

		len: in std_logic_vector(10 downto 0);

		send: in std_logic_vector(7 downto 0);
		strbSend: out std_logic;

		recv: out std_logic_vector(7 downto 0);
		strbRecv: out std_logic;

		nss: in std_logic;
		sclk: in std_logic;
		mosi: in std_logic;
		miso: inout std_logic
	);
end Spislave_v1_0;

architecture Spislave_v1_0 of Spislave_v1_0 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	-- transfer operation (xfer)
	type stateXfer_t is (
		stateXferInit,
		stateXferIdle,
		stateXferWaitNssA, stateXferWaitNssB,
		stateXferLoad,
		stateXferDataA, stateXferDataB,
		stateXferStore,
		stateXferDone
	);
	signal stateXfer, stateXfer_next: stateXfer_t := stateXferInit;

	signal ack_sig, ack_sig_next: std_logic;

	signal miso_sig, miso_sig_next: std_logic;

	signal recv_sig, recv_sig_next: std_logic_vector(7 downto 0);

	-- other
	signal sclk_sig: std_logic;

begin

	------------------------------------------------------------------------
	-- implementation: transfer operation (xfer)
	------------------------------------------------------------------------

	ack <= ack_sig;

	dne <= '1' when stateXfer=stateXferDone else '0';

	miso <= 'Z' when nss='1' else miso_sig;

	strbSend <= '0' when (stateXfer=stateXferWaitNssA or stateXfer=stateXferWaitNssB or stateXfer=stateXferDataA or stateXfer=stateXferDataB or stateXfer=stateXferStore) else '1';

	recv <= recv_sig;
	
	strbRecv <= '0' when (stateXfer=stateXferLoad or stateXfer=stateXferDataA or stateXfer=stateXferDataB or stateXfer=stateXferStore) else '1';

	process (reset, mclk)
		variable send_var: std_logic_vector(7 downto 0);

		variable recvraw: std_logic_vector(7 downto 0);
		
		variable bitcnt: natural range 0 to 7;
		variable bytecnt: natural range 0 to 2047;

	begin
		if reset='1' then
			stateXfer_next <= stateXferInit;
			ack_sig_next <= '0';
			miso_sig_next <= '0';
			recv_sig_next <= x"00";

		elsif rising_edge(mclk) then
			if stateXfer=stateXferInit then
				ack_sig_next <= '0';
				miso_sig_next <= '0';
				recv_sig_next <= x"00";
				
				bytecnt := 0;

				stateXfer_next <= stateXferIdle;

			elsif stateXfer=stateXferIdle then
				if req='1' then
					if to_integer(unsigned(len))=0 then
						ack_sig_next <= '1';
						stateXfer_next <= stateXferDone;
					else
						stateXfer_next <= stateXferWaitNssA;
					end if;
				end if;

			elsif stateXfer=stateXferWaitNssA then
				if req='0' then
					stateXfer_next <= stateXferInit;

				elsif nss='1' then
					stateXfer_next <= stateXferWaitNssB;
				end if;

			elsif stateXfer=stateXferWaitNssB then
				if req='0' then
					stateXfer_next <= stateXferInit;

				elsif (nss='0' and sclk_sig='0') then
					ack_sig_next <= '1';
					stateXfer_next <= stateXferLoad;
				end if;

			elsif stateXfer=stateXferLoad then
				send_var := send;
					
				recvraw := x"00";

				bitcnt := 0;
				bytecnt := bytecnt + 1; -- byte count put out for send

				if ((misoPrecphaNotCpha='0' and cpha='0') or (misoPrecphaNotCpha='1' and cpha='1')) then
					miso_sig_next <= send_var(7-bitcnt);
				end if;

				stateXfer_next <= stateXferDataA;

			elsif stateXfer=stateXferDataA then -- sclk '0'
				if req='0' then
					stateXfer_next <= stateXferInit;

				elsif sclk_sig='1' then
					if cpha='0' then
						recvraw(7-bitcnt) := mosi;

					elsif (misoPrecphaNotCpha='0' and cpha='1') then
						miso_sig_next <= send_var(7-bitcnt);
					elsif (misoPrecphaNotCpha='1' and cpha='0') then
						if bitcnt<7 then
							miso_sig_next <= send_var(7-bitcnt-1);
						end if;
					end if;
					
					stateXfer_next <= stateXferDataB;
				end if;

			elsif stateXfer=stateXferDataB then -- sclk '1'
				if req='0' then
					stateXfer_next <= stateXferInit;

				elsif sclk_sig='0' then
					if cpha='1' then
						recvraw(7-bitcnt) := mosi;
					end if;

					if bitcnt=7 then
						recv_sig_next <= recvraw;

						stateXfer_next <= stateXferStore;

					else
						bitcnt := bitcnt + 1;
						
						if ((misoPrecphaNotCpha='0' and cpha='0') or (misoPrecphaNotCpha='1' and cpha='1')) then
							miso_sig_next <= send_var(7-bitcnt);
						end if;

						stateXfer_next <= stateXferDataA;
					end if;
				end if;

			elsif stateXfer=stateXferStore then
				if bytecnt=to_integer(unsigned(len)) then
					stateXfer_next <= stateXferDone;
				else
					if nssByteNotXfer='0' then
						stateXfer_next <= stateXferWaitNssB;
					else
						stateXfer_next <= stateXferWaitNssA;
					end if;
				end if;

			elsif stateXfer=stateXferDone then
				if req='0' then
					stateXfer_next <= stateXferInit;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateXfer <= stateXfer_next;
			ack_sig <= ack_sig_next;
			miso_sig <= miso_sig_next;
			recv_sig <= recv_sig_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: other
	------------------------------------------------------------------------

	sclk_sig <= sclk when cpol='0' else not sclk;

end Spislave_v1_0;

