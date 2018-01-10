-- file Hostshfbox.vhd
-- Hostshfbox other module implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 28 Nov 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Hostshfbox is
	port (
		l_ntss: inout std_logic;
		l_tsck: inout std_logic;
		l_tsdo: inout std_logic;
		l_tsdi: inout std_logic;

		exg_sysen_nn: in std_logic;
		exg_nn_sysen: in std_logic;
		exg_s1clk: in std_logic;
		exg_s1nirq_s1cs0: in std_logic;
		exg_s1mosi: in std_logic;
		exg_s1cs0_s1cs1: in std_logic;
		exg_s1miso: inout std_logic;

		spih_nss: out std_logic;
		spih_sclk: out std_logic;
		spih_mosi: out std_logic;
		spih_miso: in std_logic;

		spi1_nss: in std_logic;
		spi1_sclk: in std_logic;
		spi1_mosi: in std_logic;
		spi1_miso: out std_logic
	);
end Hostshfbox;

architecture Hostshfbox of Hostshfbox is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- other
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

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- IBEGIN
	l_ntss <= 'Z' when tixVCfg=tixVCfgTheta
		else spi1_nss;

	l_tsck <= 'Z' when tixVCfg=tixVCfgTheta
		else spi1_sclk;

	l_tsdo <= 'Z' when tixVCfg=tixVCfgTheta
		else spi1_mosi;

	l_tsdi <= spih_miso when tixVCfg=tixVCfgTheta
		else 'Z';

	exg_s1miso <= spih_miso when ((tixVCfg=tixVCfgOvero and exg_sysen_nn='1') or (tixVCfg=tixVCfgDuoveroCs0 and exg_nn_sysen='1') or (tixVCfg=tixVCfgDuoveroCs1 and exg_nn_sysen='1'))
		else 'Z';

	spih_nss <= exg_s1cs0_s1cs1 when (tixVCfg=tixVCfgOvero and exg_sysen_nn='1')
		else exg_s1nirq_s1cs0 when (tixVCfg=tixVCfgDuoveroCs0 and exg_nn_sysen='1')
		else exg_s1cs0_s1cs1 when (tixVCfg=tixVCfgDuoveroCs1 and exg_nn_sysen='1')
		else l_ntss when tixVCfg=tixVCfgTheta
		else '1';

	spih_sclk <= exg_s1clk when (tixVCfg=tixVCfgOvero or tixVCfg=tixVCfgDuoveroCs0 or tixVCfg=tixVCfgDuoveroCs1)
		else l_tsck when tixVCfg=tixVCfgTheta
		else '0';

	spih_mosi <= exg_s1mosi when (tixVCfg=tixVCfgOvero or tixVCfg=tixVCfgDuoveroCs0 or tixVCfg=tixVCfgDuoveroCs1)
		else l_tsdo when tixVCfg=tixVCfgTheta
		else '0';

	spi1_miso <= '0' when tixVCfg=tixVCfgTheta
		else l_tsdi;
	-- IP impl.oth.cust --- IEND

end Hostshfbox;


