-- file Hostshfbox_wrp.vhd
-- Hostshfbox_wrp wrapper implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 28 Nov 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Hostshfbox_wrp is
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

		l_ntss: inout std_logic;
		l_tsck: inout std_logic;
		l_tsdo: inout std_logic;
		l_tsdi: inout std_logic;

		l_npss: out std_logic;
		l_psck: out std_logic;
		l_psdo: out std_logic;
		l_psdi: in std_logic;

		l_nqss: out std_logic;
		l_qsck: out std_logic;
		l_qsdo: out std_logic;
		l_qsdi: in std_logic;

		l_lio0: out std_logic;
		l_rio0: out std_logic;

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
end Hostshfbox_wrp;

architecture Hostshfbox_wrp of Hostshfbox_wrp is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

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

			l_npss: out std_logic;
			l_psck: out std_logic;
			l_psdo: out std_logic;
			l_psdi: in std_logic;

			l_nqss: out std_logic;
			l_qsck: out std_logic;
			l_qsdo: out std_logic;
			l_qsdi: in std_logic;

			l_lio0: out std_logic;
			l_rio0: out std_logic;

			r_d15pwm: out std_logic;
			r_d60pwm: out std_logic;

			-- shuffle
			exg_sysen_nn: in std_logic; -- technically, not required (!)
			exg_nn_sysen: in std_logic; -- technically, not required (!)
			exg_s1clk: in std_logic;
			exg_s1nirq_s1cs0: in std_logic; -- technically, not required (!)
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

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- other
--- not including exg_sysen_nn, exg_nn_sysen, exg_s1nirq_s1cs0 - those need to be declared ports with cpi
	signal l_ntss_psb: std_logic;
	signal l_tsck_psb: std_logic;
	signal l_tsdo_psb: std_logic;
	signal l_tsdi_psb: std_logic;

	signal exg_s1clk_psb: std_logic;
	signal exg_s1mosi_psb: std_logic;
	signal exg_s1cs0_s1cs1_psb: std_logic;
	signal exg_s1miso_psb: std_logic;
---

	-- IP sigs.oth.cust --- IBEGIN
	constant tixVCfgOvero: std_logic_vector(7 downto 0) := x"00";
	constant tixVCfgDuoveroCs0: std_logic_vector(7 downto 0) := x"01";
	constant tixVCfgDuoveroCs1: std_logic_vector(7 downto 0) := x"02";
	constant tixVCfgTheta: std_logic_vector(7 downto 0) := x"03";
	
	signal tixVCfg: std_logic_vector(7 downto 0) := tixVCfgOvero;
	-- IP sigs.oth.cust --- IEND

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	component myShfbox_wrp : Shfbox_wrp
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

			l_npss => l_npss,
			l_psck => l_psck,
			l_psdo => l_psdo,
			l_psdi => l_psdi,

			l_nqss => l_nqss,
			l_qsck => l_qsck,
			l_qsdo => l_qsdo,
			l_qsdi => l_qsdi,

			l_lio0 => l_lio0,
			l_rio0 => l_rio0,

			r_d15pwm => r_d15pwm,
			r_d60pwm => r_d60pwmb,

			-- NEW: wrapper signals not pins
			exg_sysen_nn => exg_sysen_nn,
			exg_nn_sysen => exg_nn_sysen,
			exg_s1clk => exg_s1clk_psb,
			exg_s1nirq_s1cs0 => exg_s1nirq_s1cs0,
			exg_s1mosi => exg_s1mosi_psb,
			exg_s1cs0_s1cs1 => exg_s1cs0_s1cs1_psb,
			exg_s1miso => exg_s1miso_psb,

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
			ledr => ledr
		);

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	-- IP impl.oth.cust --- IBEGIN
	l_ntss <= 'Z' when tixVCfg=tixVCfgTheta -- input
		else l_ntss_psb; -- output

	l_tsck <= 'Z' when tixVCfg=tixVCfgTheta -- input
		else l_tsck_psb; -- output

	l_tsdo <= 'Z' when tixVCfg=tixVCfgTheta -- input
		else l_tsdo_psb; -- output

	l_tsdi <= exg_s1miso_psb when tixVCfg=tixVCfgTheta -- output
		else 'Z'; -- input

	exg_s1miso <= exg_s1miso_psb when ((tixVCfg=tixVCfgOvero and exg_sysen_nn='1') or (tixVCfg=tixVCfgDuoveroCs0 and exg_nn_sysen='1') or (tixVCfg=tixVCfgDuoveroCs1 and exg_nn_sysen='1'))
		else 'Z';

	exg_s1cs0_s1cs1_psb <= exg_s1cs0_s1cs1 when (tixVCfg=tixVCfgOvero and exg_sysen_nn='1')
		else exg_s1nirq_s1cs0 when (tixVCfg=tixVCfgDuoveroCs0 and exg_nn_sysen='1')
		else exg_s1cs0_s1cs1 when (tixVCfg=tixVCfgDuoveroCs1 and exg_nn_sysen='1')
		else l_ntss when tixVCfg=tixVCfgTheta
		else '1';

	exg_s1clk_psb <= exg_s1clk when (tixVCfg=tixVCfgOvero or tixVCfg=tixVCfgDuoveroCs0 or tixVCfg=tixVCfgDuoveroCs1)
		else l_tsck when tixVCfg=tixVCfgTheta
		else '0';

	exg_s1mosi_psb <= exg_s1mosi when (tixVCfg=tixVCfgOvero or tixVCfg=tixVCfgDuoveroCs0 or tixVCfg=tixVCfgDuoveroCs1)
		else l_tsdo when tixVCfg=tixVCfgTheta
		else '0';

	l_tsdi_psb <= '0' when tixVCfg=tixVCfgTheta
		else l_tsdi;
	-- IP impl.oth.cust --- IEND

end Hostshfbox_wrp;
