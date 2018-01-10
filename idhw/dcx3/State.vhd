-- file State.vhd
-- State controller implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 16 Aug 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity State is
	port (
		ledg: out std_logic;

		clkCmdbus: in std_logic;

		ledr: out std_logic;

		dCmdbus: inout std_logic_vector(7 downto 0);

		reset: in std_logic;

		rdyCmdbusFromCmdinv: out std_logic;

		mclk: in std_logic;

		rdCmdbusFromCmdinv: in std_logic;

		tkclk: in std_logic;

		reqCmdbusToCmdret: out std_logic;

		commok: in std_logic;

		wrCmdbusToCmdret: in std_logic
	);
end State;

architecture State of State is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- command execution
	type stateCmd_t is (
		stateCmdInit,
		stateCmdIdle,
		stateCmdRecvA, stateCmdRecvB,
		stateCmdInvGet,
		stateCmdPrepRetGet,
		stateCmdWaitSend, stateCmdSendA, stateCmdSendB, stateCmdSendC
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	constant tixDbeVActionInv: std_logic_vector(7 downto 0) := x"00";
	constant tixDbeVActionRet: std_logic_vector(7 downto 0) := x"80";

	constant tixVDcx3ControllerCmdinv: std_logic_vector(7 downto 0) := x"01";
	constant tixVDcx3ControllerCmdret: std_logic_vector(7 downto 0) := x"02";

	constant tixVDcx3StateNc: std_logic_vector(7 downto 0) := x"00";
	constant tixVDcx3StateReady: std_logic_vector(7 downto 0) := x"01";

	constant maxlenCmdbuf: natural range 0 to 10 := 10;

	type cmdbuf_t is array (0 to maxlenCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	constant ixCmdbufRoute: natural range 0 to maxlenCmdbuf-1 := 0;
	constant ixCmdbufAction: natural range 0 to maxlenCmdbuf-1 := 4;
	constant ixCmdbufCref: natural range 0 to maxlenCmdbuf-1 := 5;
	constant ixCmdbufInvCommand: natural range 0 to maxlenCmdbuf-1 := 9;

	-- inv: get
	-- ret: get

	constant tixVCommandGet: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvGet: natural range 0 to maxlenCmdbuf := 10;
	constant lenCmdbufRetGet: natural range 0 to maxlenCmdbuf := 10;
	constant ixCmdbufRetGetTixVDcx3State: natural range 0 to maxlenCmdbuf-1 := 9;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- LED control
	type stateLed_t is (
		stateLedOn,
		stateLedOff
	);
	signal stateLed, stateLed_next: stateLed_t := stateLedOn;

	signal ledg_sig: std_logic := '0';
	signal ledr_sig: std_logic := '0';

	-- IP sigs.led.cust --- INSERT

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- implementation: command execution
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- BEGIN
		variable lenCmdbuf: natural range 0 to maxlenCmdbuf;
		variable bytecnt: natural range 0 to maxlenCmdbuf;
		-- IP impl.cmd.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			dCmdbus_sig_next <= "ZZZZZZZZ";
			rdyCmdbusFromCmdinv_sig_next <= '1';
			reqCmdbusToCmdret_sig_next <= '0';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				stateCmd_next <= stateCmdIdle;

			elsif stateCmd=stateCmdIdle then
				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
					lenCmdbuf := 0;

					rdyCmdbusFromCmdinv_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;

				end if;

			elsif stateCmd=stateCmdRecvA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvB then
				if rdCmdbusFromCmdinv='0' then
					if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGet and lenCmdbuf=lenCmdbufInvGet) then
						stateCmd_next <= stateCmdInvGet;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				elsif clkCmdbus='1' then
					cmdbuf(lenCmdbuf) <= dCmdbus;
					lenCmdbuf := lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvA;
				end if;

			elsif stateCmd=stateCmdPrepRetGet then
				-- IP impl.cmd.rising.prepRetGet --- IBEGIN
				if commok='0' then
					cmdbuf(ixCmdbufRetGetTixVDcx3State) <= tixVDcx3StateNc;
				elsif acqrng='0' then
					cmdbuf(ixCmdbufRetGetTixVDcx3State) <= tixVDcx3StateReady;
				else
					cmdbuf(ixCmdbufRetGetTixVDcx3State) <= tixVDcx3StateActive;
				end if;
				-- IP impl.cmd.rising.prepRetGet --- IEND

			elsif stateCmd=stateCmdWaitSend then
				if (wrCmdbusToCmdret='1' and clkCmdbus='1') then
					dCmdbus_sig_next <= cmdbuf(0);
					bytecnt := 1; -- byte count made available to dCmdbus

					stateCmd_next <= stateCmdSendA;
				end if;

			elsif stateCmd=stateCmdSendA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdSendB;
				end if;

			elsif stateCmd=stateCmdSendB then
				if clkCmdbus='1' then
					dCmdbus_sig_next <= cmdbuf(bytecnt);

					bytecnt := bytecnt + 1;

					if bytecnt=lenCmdbuf then
						reqCmdbusToCmdret_sig_next <= '0';

						stateCmd_next <= stateCmdSendC;

					else
						stateCmd_next <= stateCmdSendA;
					end if;
				end if;

			elsif stateCmd=stateCmdSendC then
				if wrCmdbusToCmdret='0' then
					stateCmd_next <= stateCmdInit;
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
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			dCmdbus_sig <= dCmdbus_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: LED control
	------------------------------------------------------------------------

	-- IP impl.led.wiring --- BEGIN
	ledg_sig <= '1' when (commok='1' and (trigrng='0' or (trigrng='1' and stateLed=stateLedOn))) else '0';
	ledg <= ledg_sig;

	ledr_sig <= '1' when commok='0' else '0';
	ledr <= ledr_sig;
	-- IP impl.led.wiring --- END

	-- IP impl.led.rising --- BEGIN
	process (reset, tkclk, stateLed)
		-- IP impl.led.rising.vars --- RBEGIN
		variable i: natural range 0 to 4000;
		-- IP impl.led.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.led.rising.asyncrst --- RBEGIN
			stateLed_next <= stateLedOn;

			i := 0;
			-- IP impl.led.rising.asyncrst --- REND

		elsif rising_edge(tkclk) then
			if stateLed=stateLedOn then
				i := i + 1; -- IP impl.led.rising.on.ext --- ILINE
				if i=1000 then
					i := 0; -- IP impl.led.rising.on.off --- ILINE
					stateLed_next <= stateLedOff;
				end if;

			elsif stateLed=stateLedOff then
				i := i + 1; -- IP impl.led.rising.off.ext --- ILINE
				if i=4000 then
					i := 0; -- IP impl.led.rising.off.on --- ILINE
					stateLed_next <= stateLedOn;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.led.rising --- END

	-- IP impl.led.falling --- BEGIN
	process (tkclk)
		-- IP impl.led.falling.vars --- INSERT
	begin
		if falling_edge(tkclk) then
			stateLed <= stateLed_next;
		end if;
	end process;
	-- IP impl.led.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end State;

