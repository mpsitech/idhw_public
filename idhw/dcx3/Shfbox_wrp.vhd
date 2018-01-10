-- file Shfbox_wrp.vhd
-- Shfbox_wrp wrapper implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 28 Nov 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Shfbox_wrp is
	generic (
		fExtclk: natural range 1 to 1000000 := 200000;
		fMclk: natural range 1 to 1000000 := 50000
	);
	port (
		nxss: out std_logic;
		xsck: out std_logic;
		xsdo: out std_logic;
		xsdi: in std_logic;

		l_nass: out std_logic;
		l_asck: out std_logic;
		l_asdo: out std_logic;
		l_asdi: in std_logic;

		-- shuffle
		l_ntss: inout std_logic;
		l_tsck: inout std_logic;
		l_tsdo: inout std_logic;
		l_tsdi: inout std_logic;

		-- shuffle
		l_npss: out std_logic;
		l_psck: out std_logic;
		l_psdo: out std_logic;
		l_psdi: in std_logic;

		-- shuffle
		l_nqss: out std_logic;
		l_qsck: out std_logic;
		l_qsdo: out std_logic;
		l_qsdi: in std_logic;

		-- shuffle
		l_lio0: out std_logic;
		l_rio0: out std_logic;

		-- shuffle
		r_d15pwm: out std_logic;
		r_d60pwm: out std_logic;

		exg_sysen_nn: in std_logic;
		exg_nn_sysen: in std_logic;
		exg_s1clk: in std_logic;
		exg_s1nirq_s1cs0: in std_logic;
		exg_s1mosi: in std_logic;
		exg_s1cs0_s1cs1: in std_logic;
		exg_s1miso: inout std_logic;

		extclkp: in std_logic;
		extclkn: in std_logic;

		lw_clkp: in std_logic;
		lw_clkn: in std_logic;

		lw_sncp: in std_logic;
		lw_sncn: in std_logic;

		lw_d1p: in std_logic;
		lw_d1n: in std_logic;

		lw_d2p: in std_logic;
		lw_d2n: in std_logic;

		lw_extsnc: out std_logic;
		lw_rx: in std_logic;
		lw_tx: out std_logic;

		sr_nce: out std_logic;
		sr_noe: out std_logic;
		sr_nwe: out std_logic;

		sr_a: out std_logic_vector(20 downto 0);
		sr_d: inout std_logic_vector(7 downto 0);

		ledg: out std_logic;
		ledr: out std_logic;
	);
end Shfbox_wrp;

architecture Shfbox_wrp of Shfbox_wrp is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Top is
		generic (
			fExtclk: natural range 1 to 1000000 := 200000;
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			nxss: out std_logic;
			xsck: out std_logic;
			xsdo: out std_logic;
			xsdi: in std_logic;

			l_nass: out std_logic;
			l_asck: out std_logic;
			l_asdo: out std_logic;
			l_asdi: in std_logic;

			-- NEW: wrapper signals not pins
			l_ntss: inout std_logic;
			l_tsck: inout std_logic;
			l_tsdo: inout std_logic;
			l_tsdi: inout std_logic;

			-- NEW: wrapper signals not pins
			l_npss: out std_logic;
			l_psck: out std_logic;
			l_psdo: out std_logic;
			l_psdi: in std_logic;

			-- NEW: wrapper signals not pins
			l_nqss: out std_logic;
			l_qsck: out std_logic;
			l_qsdo: out std_logic;
			l_qsdi: in std_logic;

			-- NEW: wrapper signals not pins
			l_lio0: out std_logic;
			l_rio0: out std_logic;

			-- NEW: wrapper signals not pins
			r_d15pwm: out std_logic;
			r_d60pwm: out std_logic;

			exg_sysen_nn: in std_logic;
			exg_nn_sysen: in std_logic;
			exg_s1clk: in std_logic;
			exg_s1nirq_s1cs0: in std_logic;
			exg_s1mosi: in std_logic;
			exg_s1cs0_s1cs1: in std_logic;
			exg_s1miso: inout std_logic;

			extclkp: in std_logic;
			extclkn: in std_logic;

			lw_clkp: in std_logic;
			lw_clkn: in std_logic;

			lw_sncp: in std_logic;
			lw_sncn: in std_logic;

			lw_d1p: in std_logic;
			lw_d1n: in std_logic;

			lw_d2p: in std_logic;
			lw_d2n: in std_logic;

			lw_extsnc: out std_logic;
			lw_rx: in std_logic;
			lw_tx: out std_logic;

			sr_nce: out std_logic;
			sr_noe: out std_logic;
			sr_nwe: out std_logic;

			sr_a: out std_logic_vector(20 downto 0);
			sr_d: inout std_logic_vector(7 downto 0);

			ledg: out std_logic;
			ledr: out std_logic;

			-- NEW: Shfbox to Shfbox_wrp
			tixVDcx3ShfboxGpiocfg_wrp: out std_logic_vector(7 downto 0);
			tixVDcx3ShfboxLedcfg_wrp: out std_logic_vector(7 downto 0);
			tixVDcx3ShfboxSpicfg_wrp: out std_logic_vector(7 downto 0)
		);
	end Top;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	-- new: almost all pin names are overwritten => _psb extension required

	---- myTop (?)
	signal tixVDcx3ShfboxGpiocfg: std_logic_vector(7 downto 0);
	signal tixVDcx3ShfboxLedcfg: std_logic_vector(7 downto 0);
	signal tixVDcx3ShfboxSpicfg: std_logic_vector(7 downto 0);

	---- other
	signal l_ntss_psb: std_logic;
	signal l_tsck_psb: std_logic;
	signal l_tsdo_psb: std_logic;
	signal l_tsdi_psb: std_logic;

	signal l_npss_psb: std_logic;
	signal l_psck_psb: std_logic;
	signal l_psdo_psb: std_logic;
	signal l_psdi_psb: std_logic;

	signal l_nqss_psb: std_logic;
	signal l_qsck_psb: std_logic;
	signal l_qsdo_psb: std_logic;
	signal l_qsdi_psb: std_logic;

	signal l_lio0_psb: std_logic;
	signal l_rio0_psb: std_logic;

	signal r_d15pwm_psb: std_logic;
	signal r_d60pwm_psb: std_logic;

	-- IP sigs.oth.cust --- IBEGIN
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
	-- IP sigs.oth.cust --- IEND

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	component myTop : Top
		generic map (
			fExtclk => fExtclk,
			fMclk => fMclk
		)
		port map (
			nxss => nxss,
			xsck => xsck,
			xsdo => xsdo,
			xsdi => xsdi,

			l_nass => l_nass,
			l_asck => l_asck,
			l_asdo => l_asdo,
			l_asdi => l_asdi,

			-- NEW: wrapper signals not pins
			l_ntss => l_ntss_psb,
			l_tsck => l_tsck_psb,
			l_tsdo => l_tsdo_psb,
			l_tsdi => l_tsdi_psb,

			-- NEW: wrapper signals not pins
			l_npss => l_npss_psb,
			l_psck => l_psck_psb,
			l_psdo => l_psdo_psb,
			l_psdi => l_psdi_psb,

			-- NEW: wrapper signals not pins
			l_nqss => l_nqss_psb,
			l_qsck => l_qsck_psb,
			l_qsdo => l_qsdo_psb,
			l_qsdi => l_qsdi_psb,

			-- NEW: wrapper signals not pins
			l_lio0 => l_lio0_psb,
			l_rio0 => l_rio0_psb,

			-- NEW: wrapper signals not pins
			r_d15pwm => r_d15pwm_psb,
			r_d60pwm => r_d60pwm_psb,

			exg_sysen_nn => exg_sysen_nn,
			exg_nn_sysen => exg_nn_sysen,
			exg_s1clk => exg_s1clk,
			exg_s1nirq_s1cs0 => exg_s1nirq_s1cs0,
			exg_s1mosi => exg_s1mosi,
			exg_s1cs0_s1cs1 => exg_s1cs0_s1cs1,
			exg_s1miso => exg_s1miso,

			extclkp => extclkp,
			extclkn => extclkn,

			lw_clkp => lw_clkp,
			lw_clkn => lw_clkn,

			lw_sncp => lw_sncp,
			lw_sncn => lw_sncn,

			lw_d1p => lw_d1p,
			lw_d1n => lw_d1n,

			lw_d2p => lw_d2p,
			lw_d2n => lw_d2n,

			lw_extsnc => lw_extsnc,
			lw_rx => lw_rx,
			lw_tx => lw_tx,

			sr_nce => sr_nce,
			sr_noe => sr_noe,
			sr_nwe => sr_nwe,

			sr_a => sr_a,
			sr_d => sr_d,

			ledg => ledg,
			ledr => ledr,

			tixVDcx3ShfboxGpiocfg_wrp => tixVDcx3ShfboxGpiocfg,
			tixVDcx3ShfboxLedcfg_wrp => tixVDcx3ShfboxLedcfg,
			tixVDcx3ShfboxSpicfg_wrp => tixVDcx3ShfboxSpicfg
		);

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	-- IP impl.oth.cust --- IBEGIN
	l_lio0 <= l_lio0_psb when tixVDcx3ShfboxGpiocfg=tixVGpiocfgVislVisr
		else l_rio0_psb when tixVDcx3ShfboxGpiocfg=tixVGpiocfgVisrVisl
		else '0';

	l_rio0 <= l_rio0_psb when tixVDcx3ShfboxGpiocfg=tixVGpiocfgVislVisr
		else l_lio0_psb when tixVDcx3ShfboxGpiocfg=tixVGpiocfgVisrVisl
		else '0';

	r_d15pwm <= r_d15pwm_psb when tixVDcx3ShfboxLedcfg=tixVLedcfgLed15Led60
		else r_d60pwm_psb when tixVDcx3ShfboxLedcfg=tixVLedcfgLed60Led15
		else '0';

	r_d60pwm <= r_d60pwm_psb when tixVDcx3ShfboxLedcfg=tixVLedcfgLed15Led60
		else r_d15pwm_psb when tixVDcx3ShfboxLedcfg=tixVLedcfgLed60Led15
		else '0';

	l_ntss <= l_ntss_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi)
		else l_npss_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta)
		else l_nqss_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else '1';

	l_tsck <= l_tsck_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi)
		else l_psck_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta)
		else l_qsck_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else '0';

	l_tsdo <= l_tsdo_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi)
		else l_psdo_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta)
		else l_qsdo_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else '0';

	l_npss <= l_ntss_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd)
		else l_npss_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else l_nqss_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta)
		else '1';

	l_psck <= l_tsck_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd)
		else l_psck_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else l_qsck_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta)
		else '0';

	l_psdo <= l_tsdo_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd)
		else l_psdo_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else l_qsdo_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta)
		else '0';

	l_nqss <= l_ntss_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else l_npss_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi)
		else l_nqss_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd)
		else '1';

	l_qsck <= l_tsck_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else l_psck_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi)
		else l_qsck_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd)
		else '0';

	l_qsdo <= l_tsdo_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else l_psdo_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi)
		else l_qsdo_psb when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd)
		else '0';

	l_tsdi_psb <= l_tsdi when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi)
		else l_psdi when (tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd)
		else l_qsdi when (tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else '0';

	l_psdi_psb <= l_tsdi when (tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta)
		else l_psdi when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else l_qsdi when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi)
		else '0';

	l_qsdi_psb <= l_tsdi when (tixVDcx3ShfboxSpicfg=tixVSpicfgQcdThetaPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgQcdPhiTheta)
		else l_psdi when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaQcdPhi or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiQcdTheta)
		else l_qsdi when (tixVDcx3ShfboxSpicfg=tixVSpicfgThetaPhiQcd or tixVDcx3ShfboxSpicfg=tixVSpicfgPhiThetaQcd)
		else '0';
	-- IP impl.oth.cust --- IEND

end Shfbox_wrp;
