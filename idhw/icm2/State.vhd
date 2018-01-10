-- IP file --- KEEP

-- file State.vhd
-- State controller implementation
-- author Alexander Wirthmueller
-- date created: 19 Sep 2017
-- date modified: 19 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

entity State is
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: inout std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		reqCmdbusToCmdret: out std_logic;
		wrCmdbusToCmdret: in std_logic;

		acqrng: in std_logic;
		commok: in std_logic;
		tempok: in std_logic;

		ledg: out std_logic;
		ledr: out std_logic
	);
end State;

architecture State of State is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

--	---- command execution (cmd)
--	type stateCmd_t is (
--		stateCmdInit,
--		stateCmdEmpty,
--		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE, stateCmdRecvF,
--		stateCmdFullA, stateCmdFullB,
--		stateCmdSendA, stateCmdSendB, stateCmdSendC,
--		stateCmdPrepRetGet
--	);
--	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;
--
--	-- inv: get
--	-- ret/newret: get
--
--	constant sizeCmdbuf: natural := 10;
--
--	constant tixVIcm2StateNc: std_logic_vector(7 downto 0) := x"00";
--	constant tixVIcm2StateCool: std_logic_vector(7 downto 0) := x"01";
--	constant tixVIcm2StateReady: std_logic_vector(7 downto 0) := x"02";
--	constant tixVIcm2StateActive: std_logic_vector(7 downto 0) := x"03";
--
--	constant tixVCommandGet: std_logic_vector(7 downto 0) := x"00";
--	constant lenCmdbufInvGet: natural := 10;
--	constant lenCmdbufRetGet: natural := 10;
--	constant ixCmdbufRetGetTixVIcm2State: natural := 9;
--
--	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
--	signal cmdbuf: cmdbuf_t;
--
--	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);
--
--	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
--	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;
--
--	-- IP sigs.cmd.cust --- INSERT
--
--	---- LED control (led)
--	type stateLed_t is (
--		stateLedOn,
--		stateLedOff
--	);
--	signal stateLed, stateLed_next: stateLed_t := stateLedOn;
--
--	signal ledg_sig: std_logic;
--	signal ledr_sig: std_logic;
--
--	-- IP sigs.led.cust --- INSERT
--
--	---- other
--	-- IP sigs.oth.cust --- INSERT

begin

	-- stripped down to meet FPGA area constraint
	rdyCmdbusFromCmdinv <= '0';

	reqCmdbusToCmdret <= '0';

	ledg <= '0';
	ledr <= '0';

--	------------------------------------------------------------------------
--	-- sub-module instantiation
--	------------------------------------------------------------------------
--
--	------------------------------------------------------------------------
--	-- implementation: command execution (cmd)
--	------------------------------------------------------------------------
--
--	-- IP impl.cmd.wiring --- BEGIN
--	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";
--
--	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
--	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
--	-- IP impl.cmd.wiring --- END
--
--	-- IP impl.cmd.rising --- BEGIN
--	process (reset, mclk, stateCmd)
--		-- IP impl.cmd.rising.vars --- BEGIN
--		variable lenCmdbuf: natural range 0 to sizeCmdbuf;
--		variable bytecnt: natural range 0 to sizeCmdbuf;
--
--		variable i, j: natural range 0 to sizeCmdbuf;
--		variable x: std_logic_vector(7 downto 0);
--		-- IP impl.cmd.rising.vars --- END
--
--	begin
--		if reset='1' then
--			-- IP impl.cmd.rising.asyncrst --- BEGIN
--			stateCmd_next <= stateCmdInit;
--			rdyCmdbusFromCmdinv_sig_next <= '1';
--			reqCmdbusToCmdret_sig_next <= '0';
--			-- IP impl.cmd.rising.asyncrst --- END
--
--		elsif rising_edge(mclk) then
--			if stateCmd=stateCmdInit then
--				-- IP impl.cmd.rising.syncrst --- BEGIN
--				rdyCmdbusFromCmdinv_sig_next <= '1';
--				reqCmdbusToCmdret_sig_next <= '0';
--
--				lenCmdbuf := 0;
--				i := 0;
--				j := 0;
--				x := x"00";
--				bytecnt := 0;
--				-- IP impl.cmd.rising.syncrst --- END
--
--				stateCmd_next <= stateCmdEmpty;
--
--			elsif stateCmd=stateCmdEmpty then
--				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
--					rdyCmdbusFromCmdinv_sig_next <= '0';
--
--					stateCmd_next <= stateCmdRecvA;
--				end if;
--
--			elsif stateCmd=stateCmdRecvA then
--				if clkCmdbus='0' then
--					stateCmd_next <= stateCmdRecvB;
--				end if;
--
--			elsif stateCmd=stateCmdRecvB then
--				if clkCmdbus='1' then
--					if rdCmdbusFromCmdinv='0' then
--						i := ixCmdbufRoute;
--						j := ixCmdbufRoute+1;
--
--						stateCmd_next <= stateCmdRecvD;
--
--					else
--						cmdbuf(lenCmdbuf) <= dCmdbus;
--
--						stateCmd_next <= stateCmdRecvC;
--					end if;
--				end if;
--
--			elsif stateCmd=stateCmdRecvC then
--				if clkCmdbus='0' then
--					lenCmdbuf := lenCmdbuf + 1;
--
--					stateCmd_next <= stateCmdRecvB;
--				end if;
--
--			elsif stateCmd=stateCmdRecvD then
--				if j=4 then
--					cmdbuf(ixCmdbufRoute+3) <= x"00";
--
--					stateCmd_next <= stateCmdRecvF;
--
--				else
--					if (i=0 and cmdbuf(j)=x"00") then
--						x := tixVIdhwIcm2ControllerCmdret;
--					else
--						x := cmdbuf(j);
--					end if;
--
--					stateCmd_next <= stateCmdRecvE;
--				end if;
--
--			elsif stateCmd=stateCmdRecvE then
--				cmdbuf(i) <= x;
--
--				i := i + 1;
--				j := j + 1;
--
--				stateCmd_next <= stateCmdRecvD;
--
--			elsif stateCmd=stateCmdRecvF then
--				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGet and lenCmdbuf=lenCmdbufInvGet) then
--					stateCmd_next <= stateCmdPrepRetGet;
--
--				else
--					stateCmd_next <= stateCmdInit;
--				end if;
--
--			elsif stateCmd=stateCmdFullA then
--				if cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerCmdret then
--					reqCmdbusToCmdret_sig_next <= '1';
--
--					stateCmd_next <= stateCmdFullB;
--
--				else
--					stateCmd_next <= stateCmdInit;
--				end if;
--
--			elsif stateCmd=stateCmdFullB then
--				if (wrCmdbusToCmdret='1' and clkCmdbus='1') then
--					bytecnt := 0;
--
--					dCmdbus_sig_next <= cmdbuf(0);
--
--					stateCmd_next <= stateCmdSendA;
--				end if;
--
--			elsif stateCmd=stateCmdSendA then
--				if clkCmdbus='0' then
--					bytecnt := bytecnt + 1;
--
--					stateCmd_next <= stateCmdSendB;
--				end if;
--
--			elsif stateCmd=stateCmdSendB then
--				if clkCmdbus='1' then
--					if bytecnt=lenCmdbuf then
--						stateCmd_next <= stateCmdSendC;
--
--					else
--						dCmdbus_sig_next <= cmdbuf(bytecnt);
--
--						if bytecnt=(lenCmdbuf-1) then
--							reqCmdbusToCmdret_sig_next <= '0';
--						end if;
--
--						stateCmd_next <= stateCmdSendA;
--					end if;
--				end if;
--
--			elsif stateCmd=stateCmdSendC then
--				if wrCmdbusToCmdret='0' then
--					stateCmd_next <= stateCmdInit;
--				end if;
--
--			elsif stateCmd=stateCmdPrepRetGet then
--				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;
--
--				-- IP impl.cmd.rising.prepRetGet --- IBEGIN
--				if commok='0' then
--					cmdbuf(ixCmdbufRetGetTixVIcm2State) <= tixVIcm2StateNc;
--				elsif tempok='0' then
--					cmdbuf(ixCmdbufRetGetTixVIcm2State) <= tixVIcm2StateCool;
--				elsif acqrng='0' then
--					cmdbuf(ixCmdbufRetGetTixVIcm2State) <= tixVIcm2StateReady;
--				else
--					cmdbuf(ixCmdbufRetGetTixVIcm2State) <= tixVIcm2StateActive;
--				end if;
--				-- IP impl.cmd.rising.prepRetGet --- IEND
--
--				lenCmdbuf := lenCmdbufRetGet;
--
--				stateCmd_next <= stateCmdFullA;
--			end if;
--		end if;
--	end process;
--	-- IP impl.cmd.rising --- END
--
--	-- IP impl.cmd.falling --- BEGIN
--	process (mclk)
--	begin
--		if falling_edge(mclk) then
--			stateCmd <= stateCmd_next;
--		end if;
--	end process;
--
--	process (clkCmdbus)
--	begin
--		if falling_edge(clkCmdbus) then
--			dCmdbus_sig <= dCmdbus_sig_next;
--			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
--			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
--		end if;
--	end process;
--	-- IP impl.cmd.falling --- END
--
--	------------------------------------------------------------------------
--	-- implementation: LED control (led)
--	------------------------------------------------------------------------
--
--	-- IP impl.led.wiring --- BEGIN
--	ledg_sig <= '0' when (commok='1' and (acqrng='0' and stateLed=stateLedOn)) else '1';
--	ledg <= ledg_sig;
--	ledr_sig <= '0' when (commok='0' or tempok='0') else '1';
--	ledr <= ledr_sig;
--	-- IP impl.led.wiring --- END
--
--	-- IP impl.led.rising --- BEGIN
--	process (reset, tkclk, stateLed)
--		-- IP impl.led.rising.vars --- RBEGIN
--		variable i: natural range 0 to 4000;
--		-- IP impl.led.rising.vars --- REND
--
--	begin
--		if reset='1' then
--			-- IP impl.led.rising.asyncrst --- RBEGIN
--			stateLed_next <= stateLedOn;
--
--			i := 0;
--			-- IP impl.led.rising.asyncrst --- REND
--
--		elsif rising_edge(tkclk) then
--			if stateLed=stateLedOn then
--				i := i + 1; -- IP impl.led.rising.on.ext --- ILINE
--
--				if i=1000 then
--					i := 0; -- IP impl.led.rising.on.off --- ILINE
--
--					stateLed_next <= stateLedOff;
--				end if;
--
--			elsif stateLed=stateLedOff then
--				i := i + 1; -- IP impl.led.rising.off.ext --- ILINE
--
--				if i=4000 then
--					i := 0; -- IP impl.led.rising.off.on --- ILINE
--
--					stateLed_next <= stateLedOn;
--				end if;
--			end if;
--		end if;
--	end process;
--	-- IP impl.led.rising --- END
--
--	-- IP impl.led.falling --- BEGIN
--	process (tkclk)
--		-- IP impl.led.falling.vars --- BEGIN
--		-- IP impl.led.falling.vars --- END
--	begin
--		if falling_edge(tkclk) then
--			stateLed <= stateLed_next;
--		end if;
--	end process;
--	-- IP impl.led.falling --- END
--
--	------------------------------------------------------------------------
--	-- implementation: other 
--	------------------------------------------------------------------------
--
--	
--	-- IP impl.oth.cust --- INSERT

end State;


