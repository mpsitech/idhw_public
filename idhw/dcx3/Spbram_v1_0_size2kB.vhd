-- file Spbram_v1_0_size2kB.vhd
-- Spbram_v1_0_size2kB spbram_v1_0 implementation
-- author Alexander Wirthmueller
-- date created: 8 Mar 2017
-- date modified: 8 Mar 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

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

	-- IP sigs --- BEGIN
	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	signal en0: std_logic;

	signal drd0: std_logic_vector(8 downto 0);

	-- IP sigs --- END

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBram0 : RAMB16_S9
		port map (
			DO => drd0(7 downto 0),
			DOP => drd0(8 downto 8),
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr(7 downto 0),
			DIP => dwr(8 downto 8),
			EN => en0,
			SSR => '0',
			WE => we
		);

	-- IP impl --- BEGIN
	------------------------------------------------------------------------
	-- implementation
	------------------------------------------------------------------------

	en0 <= en;

	drd <= drd0;
	-- IP impl --- END

end Spbram_v1_0_size2kB;
