-- file Sramemu_wrp.vhd
-- Sramemu_wrp wrapper implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Sramemu_wrp is
	port (
		lw_clk_wrp: out std_logic;
		lw_snc_wrp: out std_logic;
		lw_d1_wrp: out std_logic;
		lw_d2_wrp: out std_logic;
		lw_extsnc_wrp: in std_logic;

		extclk: in std_logic;

		led: out std_logic_vector(15 downto 0);
		sw: in std_logic_vector(15 downto 0);

		JA: out std_logic_vector(7 downto 0);

		btnC: in std_logic;
		btnL: in std_logic;
		btnR: in std_logic;
		RsRx: in std_logic;
		RsTx: out std_logic;

		clk: in std_logic;
		snc: in std_logic;
		d1: in std_logic;
		d2: in std_logic;
		extsnc: out std_logic;

		JC: out std_logic_vector(7 downto 0);

		JB: out std_logic_vector(7 downto 0);

		an: out std_logic_vector(3 downto 0);

		dp: out std_logic;

		seg: out std_logic_vector(6 downto 0);

		JXADC: out std_logic_vector(7 downto 0)
	);
end Sramemu_wrp;

architecture Sramemu_wrp of Sramemu_wrp is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Spbram_v1_0_size160kB is
		port (
			clk: in std_logic;

			en: in std_logic;
			we: in std_logic;

			a: in std_logic_vector(17 downto 0);
			drd: out std_logic_vector(7 downto 0);
			dwr: in std_logic_vector(7 downto 0)
		);
	end component;

	component Top is
		generic (
			fExtclk: natural range 1 to 1000000 := 100000;
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			lw_clk_wrp: out std_logic;
			lw_snc_wrp: out std_logic;
			lw_d1_wrp: out std_logic;
			lw_d2_wrp: out std_logic;
			lw_extsnc_wrp: in std_logic;

			extclk: in std_logic;

			led: out std_logic_vector(15 downto 0);
			sw: in std_logic_vector(15 downto 0);

			JA: out std_logic_vector(7 downto 0);

			btnC: in std_logic;
			btnL: in std_logic;
			btnR: in std_logic;
			RsRx: in std_logic;
			RsTx: out std_logic;

			clk: in std_logic;
			snc: in std_logic;
			d1: in std_logic;
			d2: in std_logic;
			extsnc: out std_logic;

			JC: out std_logic_vector(7 downto 0);

			nce: out std_logic;
			noe: out std_logic;
			nwe: out std_logic;

			a: out std_logic_vector(17 downto 0);
			d: inout std_logic_vector(7 downto 0);

			JB: out std_logic_vector(7 downto 0);

			an: out std_logic_vector(3 downto 0);

			dp: out std_logic;

			seg: out std_logic_vector(6 downto 0);

			JXADC: out std_logic_vector(7 downto 0)
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- myBuf
	signal enBuf: std_logic;
	signal weBuf: std_logic;
	signal drdBuf: std_logic_vector(7 downto 0);

	---- other
	signal emuclk: std_logic;

	signal sr_nce: std_logic;
	signal sr_noe: std_logic;
	signal sr_nwe: std_logic;

	signal sr_a: std_logic_vector(17 downto 0);
	signal sr_d: std_logic_vector(7 downto 0);
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBuf : Spbram_v1_0_size160kB
		port map (
			clk => emuclk,

			en => enBuf,
			we => weBuf,

			a => sr_a,
			drd => drdBuf,
			dwr => sr_d
		);

	myTop : Top
		generic map (
			fExtclk => 100000,
			fMclk => 50000
		)
		port map (
			lw_clk_wrp => lw_clk_wrp,
			lw_snc_wrp => lw_snc_wrp,
			lw_d1_wrp => lw_d1_wrp,
			lw_d2_wrp => lw_d2_wrp,
			lw_extsnc_wrp => lw_extsnc_wrp,

			extclk => extclk,

			led => led,
			sw => sw,

			JA => JA,

			btnC => btnC,
			btnL => btnL,
			btnR => btnR,
			RsRx => RsRx,
			RsTx => RsTx,

			clk => clk,
			snc => snc,
			d1 => d1,
			d2 => d2,
			extsnc => extsnc,

			JC => JC,

			nce => sr_nce,
			noe => sr_noe,
			nwe => sr_nwe,

			a => sr_a,
			d => sr_d,

			JB => JB,

			an => an,

			dp => dp,

			seg => seg,

			JXADC => JXADC
		);

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- IBEGIN
	emuclk <= not extclk;

	enBuf <= not sr_nce;
	weBuf <= not sr_nwe;

	sr_d <= drdBuf when (sr_nce='0' and sr_noe='0') else "ZZZZZZZZ";
	-- IP impl.oth.cust --- IEND

end Sramemu_wrp;


