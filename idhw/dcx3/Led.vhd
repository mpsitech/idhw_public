-- file Led.vhd
-- Led controller implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 16 Aug 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Led is
	port (
		led15pwm: out std_logic;

		clkCmdbus: in std_logic;

		led60pwm: out std_logic;

		dCmdbus: in std_logic_vector(7 downto 0);

		reset: in std_logic;

		rdyCmdbusFromCmdinv: out std_logic;

		mclk: in std_logic;

		rdCmdbusFromCmdinv: in std_logic;

		tkclk: in std_logic
	);
end Led;

architecture Led of Led is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- 15deg LED
	type state15_t is (
		state15Init,
		state15Idle,
		state15Inv,
		state15RunA, state15RunB
	);
	signal state15, state15_next: state15_t := state15Init;

	signal ton15: natural range 0 to 100 := 0;

	signal led15pwm_sig, led15pwm_sig_next: std_logic;

	---- 60deg LED
	type state60_t is (
		state60Init,
		state60Idle,
		state60Inv,
		state60RunA, state60RunB
	);
	signal state60, state60_next: state60_t := state60Init;

	signal ton60: natural range 0 to 100 := 0;

	signal led60pwm_sig, led60pwm_sig_next: std_logic;

	---- command execution
	type stateCmd_t is (
		stateCmdInit,
		stateCmdIdle,
		stateCmdRecvA, stateCmdRecvB,
		stateCmdInvSetTon15,
		stateCmdInvSetTon60
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	constant tixDbeVActionInv: std_logic_vector(7 downto 0) := x"00";

	constant tixVDcx3ControllerCmdinv: std_logic_vector(7 downto 0) := x"01";

	constant maxlenCmdbuf: natural range 0 to 11 := 11;

	type cmdbuf_t is array (0 to maxlenCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	constant ixCmdbufRoute: natural range 0 to maxlenCmdbuf-1 := 0;
	constant ixCmdbufAction: natural range 0 to maxlenCmdbuf-1 := 4;
	constant ixCmdbufCref: natural range 0 to maxlenCmdbuf-1 := 5;
	constant ixCmdbufInvCommand: natural range 0 to maxlenCmdbuf-1 := 9;

	-- inv: setTon15, setTon60

	constant tixVCommandSetTon15: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvSetTon15: natural range 0 to maxlenCmdbuf := 11;
	constant ixCmdbufInvSetTon15Ton15: natural range 0 to maxlenCmdbuf-1 := 10;

	constant tixVCommandSetTon60: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvSetTon60: natural range 0 to maxlenCmdbuf := 11;
	constant ixCmdbufInvSetTon60Ton60: natural range 0 to maxlenCmdbuf-1 := 10;

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

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
	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- BEGIN
		variable lenCmdbuf: natural range 0 to maxlenCmdbuf;
		-- IP impl.cmd.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			rdyCmdbusFromCmdinv_sig_next <= '1';
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
					if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetTon15 and lenCmdbuf=lenCmdbufInvSetTon15) then
						stateCmd_next <= stateCmdInvSetTon15;
					elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetTon60 and lenCmdbuf=lenCmdbufInvSetTon60) then
						stateCmd_next <= stateCmdInvSetTon60;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				elsif clkCmdbus='1' then
					cmdbuf(lenCmdbuf) <= dCmdbus;
					lenCmdbuf := lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvA;
				end if;

			elsif stateCmd=stateCmdInvSetTon15 then
				-- IP impl.cmd.rising.invSetTon15 --- INSERT

			elsif stateCmd=stateCmdInvSetTon60 then
				-- IP impl.cmd.rising.invSetTon60 --- INSERT
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
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: 15deg LED (15)
	------------------------------------------------------------------------

	-- IP impl.15.wiring --- BEGIN
	led15pwm <= led15pwm_sig;
	
	ackCmdTo15InvSetTon15 <= '1' when state15=state15Inv else '0';
	-- IP impl.15.wiring --- END

	-- IP impl.15.rising --- BEGIN
	process (reset, mclk, state15)
		-- IP impl.15.rising.vars --- RBEGIN
		variable i: natural range 0 to 100;
		-- IP impl.15.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.15.rising.asyncrst --- BEGIN
			state15_next <= state15Init;
			led15pwm_sig_next <= '0';
			-- IP impl.15.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (state15=state15Init or (state15/=state15Idle and state15/=state15Inv and reqCmdTo15InvSetTon15='1')) then
				-- IP impl.15.rising.syncrst --- BEGIN
				led15pwm_sig_next <= '0';
				-- IP impl.15.rising.syncrst --- END

				state15_next <= state15Idle;

			elsif state15=state15Idle then
				if reqCmdTo15InvSetTon15='1' then
					ton15 <= to_integer(unsigned(cmdbuf(ixCmdbufInvSetTon15Ton15))); -- IP impl.15.rising.idle.copy --- ILINE

					state15_next <= state15Inv;
				else
					-- IP impl.15.rising.idle --- IBEGIN
					i := 0;

					if ton15=0 then
						led15pwm_sig_next <= '0';
					else
						led15pwm_sig_next <= '1';
					end if;
					-- IP impl.15.rising.idle --- IEND

					if tkclk='0' then
						state15_next <= state15RunB;
					else
						state15_next <= state15RunA;
					end if;
				end if;

			elsif state15=state15Inv then
				if reqCmdTo15InvSetTon15='0' then
					state15_next <= state15Idle;
				end if;

			elsif state15=state15RunA then
				if tkclk='0' then
					if i=100 then
						state15_next <= state15Idle;
					else
						-- IP impl.15.rising.runA --- IBEGIN
						if i=ton15 then
							led15pwm_sig_next <= '0';
						end if;
						-- IP impl.15.rising.runA --- IEND
						state15_next <= state15RunB;
					end if;
				end if;

			elsif state15=state15RunB then
				if tkclk='1' then
					i := i + 1; -- IP impl.15.rising.runB --- ILINE
					state15_next <= state15RunA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.15.rising --- END

	-- IP impl.15.falling --- BEGIN
	process (mclk)
	begin
		if falling_edge(mclk) then
			state15 <= state15_next;
			led15pwm_sig <= led15pwm_sig_next;
		end if;
	end process;
	-- IP impl.15.falling --- END

	------------------------------------------------------------------------
	-- implementation: 60deg LED (60)
	------------------------------------------------------------------------

	-- IP impl.60.wiring --- BEGIN
	led60pwm <= led60pwm_sig;
	
	ackCmdTo60InvSetTon60 <= '1' when state60=state60Inv else '0';
	-- IP impl.60.wiring --- END

	-- IP impl.60.rising --- BEGIN
	process (reset, mclk, state60)
		-- IP impl.60.rising.vars --- RBEGIN
		variable i: natural range 0 to 100;
		-- IP impl.60.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.60.rising.asyncrst --- BEGIN
			state60_next <= state60Init;
			led60pwm_sig_next <= '0';
			-- IP impl.60.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (state60=state60Init or (state60/=state60Idle and state60/=state60Inv and reqCmdTo60InvSetTon60='1')) then
				-- IP impl.60.rising.syncrst --- BEGIN
				led60pwm_sig_next <= '0';
				-- IP impl.60.rising.syncrst --- END

				state60_next <= state60Idle;

			elsif state60=state60Idle then
				if reqCmdTo60InvSetTon60='1' then
					ton60 <= to_integer(unsigned(cmdbuf(ixCmdbufInvSetTon60Ton60))); -- IP impl.60.rising.idle.copy --- ILINE

					state60_next <= state60Inv;
				else
					-- IP impl.60.rising.idle --- IBEGIN
					i := 0;

					if ton60=0 then
						led60pwm_sig_next <= '0';
					else
						led60pwm_sig_next <= '1';
					end if;
					-- IP impl.60.rising.idle --- IEND

					if tkclk='0' then
						state60_next <= state60RunB;
					else
						state60_next <= state60RunA;
					end if;
				end if;

			elsif state60=state60Inv then
				if reqCmdTo60InvSetTon60='0' then
					state60_next <= state60Idle;
				end if;

			elsif state60=state60RunA then
				if tkclk='0' then
					if i=100 then
						state60_next <= state60Idle;
					else
						-- IP impl.60.rising.runA --- IBEGIN
						if i=ton60 then
							led60pwm_sig_next <= '0';
						end if;
						-- IP impl.60.rising.runA --- IEND
						state60_next <= state60RunB;
					end if;
				end if;

			elsif state60=state60RunB then
				if tkclk='1' then
					i := i + 1; -- IP impl.60.rising.runB --- ILINE
					state60_next <= state60RunA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.60.rising --- END

	-- IP impl.60.falling --- BEGIN
	process (mclk)
	begin
		if falling_edge(mclk) then
			state60 <= state60_next;
			led60pwm_sig <= led60pwm_sig_next;
		end if;
	end process;
	-- IP impl.60.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Led;

