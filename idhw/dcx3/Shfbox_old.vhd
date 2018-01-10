-- file Shfbox.vhd
-- Shfbox controller implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 28 Nov 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Shfbox is
	port (
		spi2_nss: out std_logic;

		clkCmdbus: in std_logic;

		spi2_sclk: out std_logic;

		dCmdbus: in std_logic_vector(7 downto 0);

		spi2_mosi: out std_logic;

		rdyCmdbusFromCmdinv: out std_logic;

		spi2_miso: in std_logic;

		rdCmdbusFromCmdinv: in std_logic;

		spi3_nss: out std_logic;
		spi3_sclk: out std_logic;
		spi3_mosi: out std_logic;
		spi3_miso: in std_logic;

		gpio1_0: out std_logic;
		gpio2_0: out std_logic;
		led1pwm: out std_logic;
		led2pwm: out std_logic;
		reset: in std_logic;
		mclk: in std_logic;

		spi1_nss: out std_logic;
		spi1_sclk: out std_logic;
		spi1_mosi: out std_logic;
		spi1_miso: in std_logic;

		spit_nss: in std_logic;
		spit_sclk: in std_logic;
		spit_mosi: in std_logic;
		spit_miso: out std_logic;

		spip_nss: in std_logic;
		spip_sclk: in std_logic;
		spip_mosi: in std_logic;
		spip_miso: out std_logic;

		spiq_nss: in std_logic;
		spiq_sclk: in std_logic;
		spiq_mosi: in std_logic;
		spiq_miso: out std_logic;

		gpiol_0: in std_logic;
		gpior_0: in std_logic;
		led15pwm: in std_logic;
		led60pwm: in std_logic
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

	constant tixVGpiocfgVislVisr: std_logic_vector(7 downto 0) := x"00";
	constant tixVGpiocfgVisrVisl: std_logic_vector(7 downto 0) := x"01";

	constant tixVLedcfgLed15Led60: std_logic_vector(7 downto 0) := x"00";
	constant tixVLedcfgLed60Led15: std_logic_vector(7 downto 0) := x"01";

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

	
	-- IP impl.oth.cust --- IBEGIN
	gpio1_0 <= gpiol_0 when tixVGpiocfg=tixVGpiocfgVislVisr
		else gpior_0 when tixVGpiocfg=tixVGpiocfgVisrVisl
		else '0';

	gpio2_0 <= gpior_0 when tixVGpiocfg=tixVGpiocfgVislVisr
		else gpiol_0 when tixVGpiocfg=tixVGpiocfgVisrVisl
		else '0';

	led1pwm <= led15pwm when tixVLedcfg=tixVLedcfgLed15Led60
		else led60pwm when tixVLedcfg=tixVLedcfgLed60Led15
		else '0';

	led2pwm <= led60pwm when tixVLedcfg=tixVLedcfgLed15Led60
		else led15pwm when tixVLedcfg=tixVLedcfgLed60Led15
		else '0';

	spi1_nss <= spit_nss when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgThetaQcdPhi)
		else spip_nss when (tixVSpicfg=tixVSpicfgPhiThetaQcd or tixVSpicfg=tixVSpicfgPhiQcdTheta)
		else spiq_nss when (tixVSpicfg=tixVSpicfgQcdThetaPhi or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else '1';

	spi1_sclk <= spit_sclk when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgThetaQcdPhi)
		else spip_sclk when (tixVSpicfg=tixVSpicfgPhiThetaQcd or tixVSpicfg=tixVSpicfgPhiQcdTheta)
		else spiq_sclk when (tixVSpicfg=tixVSpicfgQcdThetaPhi or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else '0';

	spi1_mosi <= spit_mosi when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgThetaQcdPhi)
		else spip_mosi when (tixVSpicfg=tixVSpicfgPhiThetaQcd or tixVSpicfg=tixVSpicfgPhiQcdTheta)
		else spiq_mosi when (tixVSpicfg=tixVSpicfgQcdThetaPhi or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else '0';

	spi2_nss <= spit_nss when (tixVSpicfg=tixVSpicfgQcdThetaPhi or tixVSpicfg=tixVSpicfgPhiThetaQcd)
		else spip_nss when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else spiq_nss when (tixVSpicfg=tixVSpicfgThetaQcdPhi or tixVSpicfg=tixVSpicfgPhiQcdTheta)
		else '1';

	spi2_sclk <= spit_sclk when (tixVSpicfg=tixVSpicfgQcdThetaPhi or tixVSpicfg=tixVSpicfgPhiThetaQcd)
		else spip_sclk when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else spiq_sclk when (tixVSpicfg=tixVSpicfgThetaQcdPhi or tixVSpicfg=tixVSpicfgPhiQcdTheta)
		else '0';

	spi2_mosi <= spit_mosi when (tixVSpicfg=tixVSpicfgQcdThetaPhi or tixVSpicfg=tixVSpicfgPhiThetaQcd)
		else spip_mosi when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else spiq_mosi when (tixVSpicfg=tixVSpicfgThetaQcdPhi or tixVSpicfg=tixVSpicfgPhiQcdTheta)
		else '0';

	spi3_nss <= spit_nss when (tixVSpicfg=tixVSpicfgPhiQcdTheta or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else spip_nss when (tixVSpicfg=tixVSpicfgThetaQcdPhi or tixVSpicfg=tixVSpicfgQcdThetaPhi)
		else spiq_nss when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgPhiThetaQcd)
		else '1';

	spi3_sclk <= spit_sclk when (tixVSpicfg=tixVSpicfgPhiQcdTheta or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else spip_sclk when (tixVSpicfg=tixVSpicfgThetaQcdPhi or tixVSpicfg=tixVSpicfgQcdThetaPhi)
		else spiq_sclk when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgPhiThetaQcd)
		else '0';

	spi3_mosi <= spit_mosi when (tixVSpicfg=tixVSpicfgPhiQcdTheta or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else spip_mosi when (tixVSpicfg=tixVSpicfgThetaQcdPhi or tixVSpicfg=tixVSpicfgQcdThetaPhi)
		else spiq_mosi when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgPhiThetaQcd)
		else '0';

	spit_miso <= spi1_miso when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgThetaQcdPhi)
		else spi2_miso when (tixVSpicfg=tixVSpicfgQcdThetaPhi or tixVSpicfg=tixVSpicfgPhiThetaQcd)
		else spi3_miso when (tixVSpicfg=tixVSpicfgPhiQcdTheta or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else '0';

	spip_miso <= spi1_miso when (tixVSpicfg=tixVSpicfgPhiThetaQcd or tixVSpicfg=tixVSpicfgPhiQcdTheta)
		else spi2_miso when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else spi3_miso when (tixVSpicfg=tixVSpicfgThetaQcdPhi or tixVSpicfg=tixVSpicfgQcdThetaPhi)
		else '0';

	spiq_miso <= spi1_miso when (tixVSpicfg=tixVSpicfgQcdThetaPhi or tixVSpicfg=tixVSpicfgQcdPhiTheta)
		else spi2_miso when (tixVSpicfg=tixVSpicfgThetaQcdPhi or tixVSpicfg=tixVSpicfgPhiQcdTheta)
		else spi3_miso when (tixVSpicfg=tixVSpicfgThetaPhiQcd or tixVSpicfg=tixVSpicfgPhiThetaQcd)
		else '0';
	-- IP impl.oth.cust --- IEND

end Shfbox;


