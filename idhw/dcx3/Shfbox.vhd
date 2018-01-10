-- file Shfbox.vhd
-- Shfbox controller implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 16 Aug 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Shfbox is
	port (
		reset: in std_logic;

		mclk: in std_logic;

		clkCmdbus: in std_logic;

		dCmdbus: in std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		tixVDcx3ShfboxGpiocfg_wrp: out std_logic_vector(7 downto 0);
		tixVDcx3ShfboxLedcfg_wrp: out std_logic_vector(7 downto 0);
		tixVDcx3ShfboxSpicfg_wrp: out std_logic_vector(7 downto 0)
	);
end Shfbox;

architecture Shfbox of Shfbox is

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
		stateCmdInvSetSpicfg,
		stateCmdInvSetGpiocfg,
		stateCmdInvSetLedcfg
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	constant tixDbeVActionInv: std_logic_vector(7 downto 0) := x"00";

	constant tixVDcx3ControllerCmdinv: std_logic_vector(7 downto 0) := x"01";

-- not needed
	constant tixVGpiocfgVislVisr: std_logic_vector(7 downto 0) := x"00";
	constant tixVGpiocfgVisrVisl: std_logic_vector(7 downto 0) := x"01";

-- not needed
	constant tixVLedcfgLed15Led60: std_logic_vector(7 downto 0) := x"00";
	constant tixVLedcfgLed60Led15: std_logic_vector(7 downto 0) := x"01";

-- not needed
	constant tixVSpicfgThetaPhiQcd: std_logic_vector(7 downto 0) := x"00";
	constant tixVSpicfgThetaQcdPhi: std_logic_vector(7 downto 0) := x"01";
	constant tixVSpicfgPhiThetaQcd: std_logic_vector(7 downto 0) := x"02";
	constant tixVSpicfgPhiQcdTheta: std_logic_vector(7 downto 0) := x"03";
	constant tixVSpicfgQcdThetaPhi: std_logic_vector(7 downto 0) := x"04";
	constant tixVSpicfgQcdPhiTheta: std_logic_vector(7 downto 0) := x"05";

	constant maxlenCmdbuf: natural range 0 to 11 := 11;

	type cmdbuf_t is array (0 to maxlenCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	constant ixCmdbufRoute: natural range 0 to maxlenCmdbuf-1 := 0;
	constant ixCmdbufAction: natural range 0 to maxlenCmdbuf-1 := 4;
	constant ixCmdbufCref: natural range 0 to maxlenCmdbuf-1 := 5;
	constant ixCmdbufInvCommand: natural range 0 to maxlenCmdbuf-1 := 9;

	-- inv: setSpicfg, setGpiocfg, setLedcfg

	constant tixVCommandSetSpicfg: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvSetSpicfg: natural range 0 to maxlenCmdbuf := 11;
	constant ixCmdbufInvSetSpicfgTixVSpicfg: natural range 0 to maxlenCmdbuf-1 := 10;

	constant tixVCommandSetGpiocfg: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvSetGpiocfg: natural range 0 to maxlenCmdbuf := 11;
	constant ixCmdbufInvSetGpiocfgTixVGpiocfg: natural range 0 to maxlenCmdbuf-1 := 10;

	constant tixVCommandSetLedcfg: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvSetLedcfg: natural range 0 to maxlenCmdbuf := 11;
	constant ixCmdbufInvSetLedcfgTixVLedcfg: natural range 0 to maxlenCmdbuf-1 := 10;

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;

	signal tixVGpiocfg: std_logic_vector(7 downto 0) := tixVGpiocfgVislVisr;
	signal tixVLedcfg: std_logic_vector(7 downto 0) := tixVLedcfgLed15Led60;
	signal tixVSpicfg: std_logic_vector(7 downto 0) := tixVSpicfgThetaPhiQcd;

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

-- THIS IS NEW
	tixVDcx3ShfboxGpiocfg_wrp <= tixVGpiocfg;
	tixVDcx3ShfboxLedcfg_wrp <= tixVLedcfg;
	tixVDcx3ShfboxSpicfg_wrp <= tixVSpicfg;
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
					if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetSpicfg and lenCmdbuf=lenCmdbufInvSetSpicfg) then
						stateCmd_next <= stateCmdInvSetSpicfg;
					elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetGpiocfg and lenCmdbuf=lenCmdbufInvSetGpiocfg) then
						stateCmd_next <= stateCmdInvSetGpiocfg;
					elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetLedcfg and lenCmdbuf=lenCmdbufInvSetLedcfg) then
						stateCmd_next <= stateCmdInvSetLedcfg;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				elsif clkCmdbus='1' then
					cmdbuf(lenCmdbuf) <= dCmdbus;
					lenCmdbuf := lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvA;
				end if;

			elsif stateCmd=stateCmdInvSetSpicfg then
				-- IP impl.cmd.rising.invSetSpicfg --- IBEGIN
				tixVSpicfg <= cmdbuf(ixCmdbufInvSetSpicfgTixVSpicfg);
				-- IP impl.cmd.rising.invSetSpicfg --- IEND

				stateCmd_next <= stateCmdInit;

			elsif stateCmd=stateCmdInvSetGpiocfg then
				-- IP impl.cmd.rising.invSetGpiocfg --- IBEGIN
				tixVGpiocfg <= cmdbuf(ixCmdbufInvSetSpicfgTixVGpiocfg);
				-- IP impl.cmd.rising.invSetGpiocfg --- IEND

				stateCmd_next <= stateCmdInit;

			elsif stateCmd=stateCmdInvSetLedcfg then
				-- IP impl.cmd.rising.invSetLedcfg --- IBEGIN
				tixVLedcfg <= cmdbuf(ixCmdbufInvSetLedcfgTixVLedcfg);
				-- IP impl.cmd.rising.invSetLedcfg --- IEND

				stateCmd_next <= stateCmdInit;
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
	-- implementation: other 
	------------------------------------------------------------------------

	-- IP impl.oth.cust --- INSERT

end Shfbox;


