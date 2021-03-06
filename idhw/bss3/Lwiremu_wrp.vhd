-- file Lwiremu_wrp.vhd
-- Lwiremu_wrp wrapper implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Lwiremu_wrp is
	port (
		extclk: in std_logic;

		led: out std_logic_vector(15 downto 0);
		sw: in std_logic_vector(15 downto 0);

		JA: out std_logic_vector(7 downto 0);

		btnC: in std_logic;
		btnL: in std_logic;
		btnR: in std_logic;
		RsRx: in std_logic;
		RsTx: out std_logic;

		JC: out std_logic_vector(7 downto 0);

		JB: out std_logic_vector(7 downto 0);

		an: out std_logic_vector(3 downto 0);

		dp: out std_logic;

		seg: out std_logic_vector(6 downto 0);

		JXADC: out std_logic_vector(7 downto 0)
	);
end Lwiremu_wrp;

architecture Lwiremu_wrp of Lwiremu_wrp is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Sramemu_wrp is
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
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- other
	signal lw_clk: std_logic;
	signal lw_snc: std_logic;
	signal lw_d1: std_logic;
	signal lw_d2: std_logic;
	signal lw_extsnc: std_logic;
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	mySramemu_wrp : Sramemu_wrp
		port map (
			lw_clk_wrp => lw_clk,
			lw_snc_wrp => lw_snc,
			lw_d1_wrp => lw_d1,
			lw_d2_wrp => lw_d2,
			lw_extsnc_wrp => lw_extsnc,

			extclk => extclk,

			led => led,
			sw => sw,

			JA => JA,

			btnC => btnC,
			btnL => btnL,
			btnR => btnR,
			RsRx => RsRx,
			RsTx => RsTx,

			clk => lw_clk,
			snc => lw_snc,
			d1 => lw_d1,
			d2 => lw_d2,
			extsnc => lw_extsnc,

			JC => JC,

			JB => JB,

			an => an,

			dp => dp,

			seg => seg,

			JXADC => JXADC
		);

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Lwiremu_wrp;

