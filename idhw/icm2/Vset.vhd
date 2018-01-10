-- file Vset.vhd
-- Vset controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

entity Vset is
	generic (
		fMclk: natural range 1 to 1000000
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: in std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		rdyCmdbusFromTemp: out std_logic;
		rdCmdbusFromTemp: in std_logic;

		nss: out std_logic;
		sclk: out std_logic;
		mosi: out std_logic;
		miso: in std_logic
	);
end Vset;

architecture Vset of Vset is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Spimaster_v1_0 is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;

			cpol: std_logic := '0';
			cpha: std_logic := '0';

			nssByteNotXfer: std_logic := '0';

			fSclk: natural range 1 to 50000000 := 10000000;
			Nstop: natural range 1 to 8 := 1
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

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- command execution (cmd)
	type stateCmd_t is (
		stateCmdInit,
		stateCmdEmpty,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD,
		stateCmdInvSetVdd,
		stateCmdInvSetVref,
		stateCmdInvSetVtec,
		stateCmdSetA, stateCmdSetB, stateCmdSetC, stateCmdSetD, stateCmdSetE
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: setVdd, setVref, setVtec

	constant sizeCmdbuf: natural := 12;

	constant tixVCommandSetVdd: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvSetVdd: natural := 12;
	constant ixCmdbufInvSetVddVdd: natural := 10;

	constant tixVCommandSetVref: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvSetVref: natural := 12;
	constant ixCmdbufInvSetVrefVref: natural := 10;

	constant tixVCommandSetVtec: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvSetVtec: natural := 12;
	constant ixCmdbufInvSetVtecVtec: natural := 10;

	signal Vdd: std_logic_vector(9 downto 0);
	signal Vref: std_logic_vector(9 downto 0);
	signal Vtec: std_logic_vector(9 downto 0);

	signal spilen: std_logic_vector(10 downto 0);
	signal spisend, spisend_next: std_logic_vector(7 downto 0);

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal rdyCmdbusFromTemp_sig, rdyCmdbusFromTemp_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- mySpi
	signal strbSpisend: std_logic;

	---- handshake
	-- cmd to mySpi
	signal reqSpi, reqSpi_next: std_logic;
	signal dneSpi: std_logic;

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	mySpi : Spimaster_v1_0
		generic map (
			fMclk => fMclk,

			cpol => '0',
			cpha => '1',

			fSclk => 12500000
		)
		port map (
			reset => reset,
			mclk => mclk,

			req => reqSpi,
			ack => open,
			dne => dneSpi,

			len => spilen,

			send => spisend,
			strbSend => strbSpisend,

			recv => open,
			strbRecv => open,

			nss => nss,
			sclk => sclk,
			mosi => mosi,
			miso => miso
		);

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	rdyCmdbusFromTemp <= rdyCmdbusFromTemp_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- RBEGIN
		variable lenCmdbuf: natural range 0 to sizeCmdbuf := 0;

		variable bytecnt: natural range 0 to 6;
		-- IP impl.cmd.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			reqSpi_next <= '0';
			spisend_next <= x"00";
			rdyCmdbusFromCmdinv_sig_next <= '1';
			rdyCmdbusFromTemp_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				reqSpi_next <= '0';
				spisend_next <= x"00";
				rdyCmdbusFromCmdinv_sig_next <= '1';
				rdyCmdbusFromTemp_sig_next <= '1';

				lenCmdbuf := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if ((rdCmdbusFromCmdinv='1' or rdCmdbusFromTemp='1') and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
					rdyCmdbusFromTemp_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;
				end if;

			elsif stateCmd=stateCmdRecvA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvB then
				if clkCmdbus='1' then
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromTemp='0') then
						stateCmd_next <= stateCmdRecvD;

					else
						cmdbuf(lenCmdbuf) <= dCmdbus;

						stateCmd_next <= stateCmdRecvC;
					end if;
				end if;

			elsif stateCmd=stateCmdRecvC then
				if clkCmdbus='0' then
					lenCmdbuf := lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvD then
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetVdd and lenCmdbuf=lenCmdbufInvSetVdd) then
					stateCmd_next <= stateCmdInvSetVdd;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetVref and lenCmdbuf=lenCmdbufInvSetVref) then
					stateCmd_next <= stateCmdInvSetVref;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetVtec and lenCmdbuf=lenCmdbufInvSetVtec) then
					stateCmd_next <= stateCmdInvSetVtec;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdInvSetVdd then
				-- IP impl.cmd.rising.invSetVdd --- IBEGIN
				Vdd(9 downto 8) <= cmdbuf(ixCmdbufInvSetVddVdd)(1 downto 0);
				Vdd(7 downto 0) <= cmdbuf(ixCmdbufInvSetVddVdd+1)(7 downto 0);
				-- IP impl.cmd.rising.invSetVdd --- IEND

				stateCmd_next <= stateCmdSetA;

			elsif stateCmd=stateCmdInvSetVref then
				-- IP impl.cmd.rising.invSetVref --- IBEGIN
				Vref(9 downto 8) <= cmdbuf(ixCmdbufInvSetVrefVref)(1 downto 0);
				Vref(7 downto 0) <= cmdbuf(ixCmdbufInvSetVrefVref+1)(7 downto 0);
				-- IP impl.cmd.rising.invSetVref --- IEND

				stateCmd_next <= stateCmdSetA;

			elsif stateCmd=stateCmdInvSetVtec then
				-- IP impl.cmd.rising.invSetVtec --- IBEGIN
				Vtec(9 downto 8) <= cmdbuf(ixCmdbufInvSetVtecVtec)(1 downto 0);
				Vtec(7 downto 0) <= cmdbuf(ixCmdbufInvSetVtecVtec+1)(7 downto 0);
				-- IP impl.cmd.rising.invSetVtec --- IEND

				stateCmd_next <= stateCmdSetA;

			elsif stateCmd=stateCmdSetA then
				-- IP impl.cmd.rising.setA.initspi --- IBEGIN
				spilen <= std_logic_vector(to_unsigned(6, 11));

				bytecnt := 0;
				-- IP impl.cmd.rising.setA.initspi --- IEND

				stateCmd_next <= stateCmdSetD;

			elsif stateCmd=stateCmdSetB then
				if dneSpi='1' then
					reqSpi_next <= '0'; -- IP impl.cmd.rising.setB.done --- ILINE

					stateCmd_next <= stateCmdInit;

				else
					stateCmd_next <= stateCmdSetC;
				end if;

			elsif stateCmd=stateCmdSetC then
				bytecnt := bytecnt + 1; -- IP impl.cmd.rising.setC --- ILINE

				stateCmd_next <= stateCmdSetD;

			elsif stateCmd=stateCmdSetD then
				-- IP impl.cmd.rising.setD --- IBEGIN
				reqSpi_next <= '1';

				if bytecnt=0 then
					spisend_next <= "000000" & Vtec(9 downto 8);
				elsif bytecnt=1 then
					spisend_next <= Vtec(7 downto 0);
				elsif bytecnt=2 then
					spisend_next <= "000000" & Vref(9 downto 8);
				elsif bytecnt=3 then
					spisend_next <= Vref(7 downto 0);
				elsif bytecnt=4 then
					spisend_next <= "000000" & Vdd(9 downto 8);
				elsif bytecnt=5 then
					spisend_next <= Vdd(7 downto 0);
				end if;
				-- IP impl.cmd.rising.setD --- IEND

				stateCmd_next <= stateCmdSetE;

			elsif stateCmd=stateCmdSetE then
				if strbSpisend='1' then
					stateCmd_next <= stateCmdSetB;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.cmd.rising --- END

	-- IP impl.cmd.falling --- BEGIN
	process (mclk)
	begin
		if falling_edge(mclk) then
			stateCmd <= stateCmd_next;
			reqSpi <= reqSpi_next;
			spisend <= spisend_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			rdyCmdbusFromTemp_sig <= rdyCmdbusFromTemp_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Vset;


