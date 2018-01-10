-- file Spbram_v1_0_size2kB.vhd
-- Spbram_v1_0_size2kB spbram_v1_0 implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Spbram_v1_0_size2kB is
	port (
		clk: in std_logic;

		en: in std_logic;
		we: in std_logic;

		a: in std_logic_vector(10 downto 0);
		drd: out std_logic_vector(8 downto 0);
		dwr: in std_logic_vector(8 downto 0)
	);
end Spbram_v1_0_size2kB;

architecture Spbram_v1_0_size2kB of Spbram_v1_0_size2kB is

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBram : RAMB16_S9
		port map (
			DO => drd(7 downto 0),
			DOP => drd(8 downto 8),
			ADDR => a,
			CLK => clk,
			DI => dwr(7 downto 0),
			DIP => dwr(8 downto 8),
			EN => en,
			SSR => '0',
			WE => we
		);

end Spbram_v1_0_size2kB;

