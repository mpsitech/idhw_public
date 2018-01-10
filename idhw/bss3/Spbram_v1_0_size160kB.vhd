-- file Spbram_v1_0_size160kB.vhd
-- Spbram_v1_0_size160kB spbram_v1_0 implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Spbram_v1_0_size160kB is
	port (
		clk: in std_logic;

		en: in std_logic;
		we: in std_logic;

		a: in std_logic_vector(17 downto 0);
		drd: out std_logic_vector(7 downto 0);
		dwr: in std_logic_vector(7 downto 0)
	);
end Spbram_v1_0_size160kB;

architecture Spbram_v1_0_size160kB of Spbram_v1_0_size160kB is

	-- IP sigs --- BEGIN
	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	signal en0: std_logic := '0';
	signal en1: std_logic := '0';
	signal en2: std_logic := '0';
	signal en3: std_logic := '0';
	signal en4: std_logic := '0';
	signal en5: std_logic := '0';
	signal en6: std_logic := '0';
	signal en7: std_logic := '0';
	signal en8: std_logic := '0';
	signal en9: std_logic := '0';
	signal en10: std_logic := '0';
	signal en11: std_logic := '0';
	signal en12: std_logic := '0';
	signal en13: std_logic := '0';
	signal en14: std_logic := '0';
	signal en15: std_logic := '0';
	signal en16: std_logic := '0';
	signal en17: std_logic := '0';
	signal en18: std_logic := '0';
	signal en19: std_logic := '0';
	signal en20: std_logic := '0';
	signal en21: std_logic := '0';
	signal en22: std_logic := '0';
	signal en23: std_logic := '0';
	signal en24: std_logic := '0';
	signal en25: std_logic := '0';
	signal en26: std_logic := '0';
	signal en27: std_logic := '0';
	signal en28: std_logic := '0';
	signal en29: std_logic := '0';
	signal en30: std_logic := '0';
	signal en31: std_logic := '0';
	signal en32: std_logic := '0';
	signal en33: std_logic := '0';
	signal en34: std_logic := '0';
	signal en35: std_logic := '0';
	signal en36: std_logic := '0';
	signal en37: std_logic := '0';
	signal en38: std_logic := '0';
	signal en39: std_logic := '0';
	signal en40: std_logic := '0';
	signal en41: std_logic := '0';
	signal en42: std_logic := '0';
	signal en43: std_logic := '0';
	signal en44: std_logic := '0';
	signal en45: std_logic := '0';
	signal en46: std_logic := '0';
	signal en47: std_logic := '0';
	signal en48: std_logic := '0';
	signal en49: std_logic := '0';
	signal en50: std_logic := '0';
	signal en51: std_logic := '0';
	signal en52: std_logic := '0';
	signal en53: std_logic := '0';
	signal en54: std_logic := '0';
	signal en55: std_logic := '0';
	signal en56: std_logic := '0';
	signal en57: std_logic := '0';
	signal en58: std_logic := '0';
	signal en59: std_logic := '0';
	signal en60: std_logic := '0';
	signal en61: std_logic := '0';
	signal en62: std_logic := '0';
	signal en63: std_logic := '0';
	signal en64: std_logic := '0';
	signal en65: std_logic := '0';
	signal en66: std_logic := '0';
	signal en67: std_logic := '0';
	signal en68: std_logic := '0';
	signal en69: std_logic := '0';
	signal en70: std_logic := '0';
	signal en71: std_logic := '0';
	signal en72: std_logic := '0';
	signal en73: std_logic := '0';
	signal en74: std_logic := '0';
	signal en75: std_logic := '0';
	signal en76: std_logic := '0';
	signal en77: std_logic := '0';
	signal en78: std_logic := '0';
	signal en79: std_logic := '0';

	signal drd0: std_logic_vector(7 downto 0) := x"00";
	signal drd1: std_logic_vector(7 downto 0) := x"00";
	signal drd2: std_logic_vector(7 downto 0) := x"00";
	signal drd3: std_logic_vector(7 downto 0) := x"00";
	signal drd4: std_logic_vector(7 downto 0) := x"00";
	signal drd5: std_logic_vector(7 downto 0) := x"00";
	signal drd6: std_logic_vector(7 downto 0) := x"00";
	signal drd7: std_logic_vector(7 downto 0) := x"00";
	signal drd8: std_logic_vector(7 downto 0) := x"00";
	signal drd9: std_logic_vector(7 downto 0) := x"00";
	signal drd10: std_logic_vector(7 downto 0) := x"00";
	signal drd11: std_logic_vector(7 downto 0) := x"00";
	signal drd12: std_logic_vector(7 downto 0) := x"00";
	signal drd13: std_logic_vector(7 downto 0) := x"00";
	signal drd14: std_logic_vector(7 downto 0) := x"00";
	signal drd15: std_logic_vector(7 downto 0) := x"00";
	signal drd16: std_logic_vector(7 downto 0) := x"00";
	signal drd17: std_logic_vector(7 downto 0) := x"00";
	signal drd18: std_logic_vector(7 downto 0) := x"00";
	signal drd19: std_logic_vector(7 downto 0) := x"00";
	signal drd20: std_logic_vector(7 downto 0) := x"00";
	signal drd21: std_logic_vector(7 downto 0) := x"00";
	signal drd22: std_logic_vector(7 downto 0) := x"00";
	signal drd23: std_logic_vector(7 downto 0) := x"00";
	signal drd24: std_logic_vector(7 downto 0) := x"00";
	signal drd25: std_logic_vector(7 downto 0) := x"00";
	signal drd26: std_logic_vector(7 downto 0) := x"00";
	signal drd27: std_logic_vector(7 downto 0) := x"00";
	signal drd28: std_logic_vector(7 downto 0) := x"00";
	signal drd29: std_logic_vector(7 downto 0) := x"00";
	signal drd30: std_logic_vector(7 downto 0) := x"00";
	signal drd31: std_logic_vector(7 downto 0) := x"00";
	signal drd32: std_logic_vector(7 downto 0) := x"00";
	signal drd33: std_logic_vector(7 downto 0) := x"00";
	signal drd34: std_logic_vector(7 downto 0) := x"00";
	signal drd35: std_logic_vector(7 downto 0) := x"00";
	signal drd36: std_logic_vector(7 downto 0) := x"00";
	signal drd37: std_logic_vector(7 downto 0) := x"00";
	signal drd38: std_logic_vector(7 downto 0) := x"00";
	signal drd39: std_logic_vector(7 downto 0) := x"00";
	signal drd40: std_logic_vector(7 downto 0) := x"00";
	signal drd41: std_logic_vector(7 downto 0) := x"00";
	signal drd42: std_logic_vector(7 downto 0) := x"00";
	signal drd43: std_logic_vector(7 downto 0) := x"00";
	signal drd44: std_logic_vector(7 downto 0) := x"00";
	signal drd45: std_logic_vector(7 downto 0) := x"00";
	signal drd46: std_logic_vector(7 downto 0) := x"00";
	signal drd47: std_logic_vector(7 downto 0) := x"00";
	signal drd48: std_logic_vector(7 downto 0) := x"00";
	signal drd49: std_logic_vector(7 downto 0) := x"00";
	signal drd50: std_logic_vector(7 downto 0) := x"00";
	signal drd51: std_logic_vector(7 downto 0) := x"00";
	signal drd52: std_logic_vector(7 downto 0) := x"00";
	signal drd53: std_logic_vector(7 downto 0) := x"00";
	signal drd54: std_logic_vector(7 downto 0) := x"00";
	signal drd55: std_logic_vector(7 downto 0) := x"00";
	signal drd56: std_logic_vector(7 downto 0) := x"00";
	signal drd57: std_logic_vector(7 downto 0) := x"00";
	signal drd58: std_logic_vector(7 downto 0) := x"00";
	signal drd59: std_logic_vector(7 downto 0) := x"00";
	signal drd60: std_logic_vector(7 downto 0) := x"00";
	signal drd61: std_logic_vector(7 downto 0) := x"00";
	signal drd62: std_logic_vector(7 downto 0) := x"00";
	signal drd63: std_logic_vector(7 downto 0) := x"00";
	signal drd64: std_logic_vector(7 downto 0) := x"00";
	signal drd65: std_logic_vector(7 downto 0) := x"00";
	signal drd66: std_logic_vector(7 downto 0) := x"00";
	signal drd67: std_logic_vector(7 downto 0) := x"00";
	signal drd68: std_logic_vector(7 downto 0) := x"00";
	signal drd69: std_logic_vector(7 downto 0) := x"00";
	signal drd70: std_logic_vector(7 downto 0) := x"00";
	signal drd71: std_logic_vector(7 downto 0) := x"00";
	signal drd72: std_logic_vector(7 downto 0) := x"00";
	signal drd73: std_logic_vector(7 downto 0) := x"00";
	signal drd74: std_logic_vector(7 downto 0) := x"00";
	signal drd75: std_logic_vector(7 downto 0) := x"00";
	signal drd76: std_logic_vector(7 downto 0) := x"00";
	signal drd77: std_logic_vector(7 downto 0) := x"00";
	signal drd78: std_logic_vector(7 downto 0) := x"00";
	signal drd79: std_logic_vector(7 downto 0) := x"00";
	-- IP sigs --- END

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBram0 : RAMB16_S9
		port map (
			DO => drd0,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en0,
			SSR => '0',
			WE => we
		);

	myBram1 : RAMB16_S9
		port map (
			DO => drd1,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en1,
			SSR => '0',
			WE => we
		);

	myBram10 : RAMB16_S9
		port map (
			DO => drd10,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en10,
			SSR => '0',
			WE => we
		);

	myBram11 : RAMB16_S9
		port map (
			DO => drd11,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en11,
			SSR => '0',
			WE => we
		);

	myBram12 : RAMB16_S9
		port map (
			DO => drd12,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en12,
			SSR => '0',
			WE => we
		);

	myBram13 : RAMB16_S9
		port map (
			DO => drd13,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en13,
			SSR => '0',
			WE => we
		);

	myBram14 : RAMB16_S9
		port map (
			DO => drd14,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en14,
			SSR => '0',
			WE => we
		);

	myBram15 : RAMB16_S9
		port map (
			DO => drd15,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en15,
			SSR => '0',
			WE => we
		);

	myBram16 : RAMB16_S9
		port map (
			DO => drd16,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en16,
			SSR => '0',
			WE => we
		);

	myBram17 : RAMB16_S9
		port map (
			DO => drd17,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en17,
			SSR => '0',
			WE => we
		);

	myBram18 : RAMB16_S9
		port map (
			DO => drd18,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en18,
			SSR => '0',
			WE => we
		);

	myBram19 : RAMB16_S9
		port map (
			DO => drd19,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en19,
			SSR => '0',
			WE => we
		);

	myBram2 : RAMB16_S9
		port map (
			DO => drd2,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en2,
			SSR => '0',
			WE => we
		);

	myBram20 : RAMB16_S9
		port map (
			DO => drd20,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en20,
			SSR => '0',
			WE => we
		);

	myBram21 : RAMB16_S9
		port map (
			DO => drd21,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en21,
			SSR => '0',
			WE => we
		);

	myBram22 : RAMB16_S9
		port map (
			DO => drd22,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en22,
			SSR => '0',
			WE => we
		);

	myBram23 : RAMB16_S9
		port map (
			DO => drd23,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en23,
			SSR => '0',
			WE => we
		);

	myBram24 : RAMB16_S9
		port map (
			DO => drd24,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en24,
			SSR => '0',
			WE => we
		);

	myBram25 : RAMB16_S9
		port map (
			DO => drd25,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en25,
			SSR => '0',
			WE => we
		);

	myBram26 : RAMB16_S9
		port map (
			DO => drd26,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en26,
			SSR => '0',
			WE => we
		);

	myBram27 : RAMB16_S9
		port map (
			DO => drd27,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en27,
			SSR => '0',
			WE => we
		);

	myBram28 : RAMB16_S9
		port map (
			DO => drd28,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en28,
			SSR => '0',
			WE => we
		);

	myBram29 : RAMB16_S9
		port map (
			DO => drd29,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en29,
			SSR => '0',
			WE => we
		);

	myBram3 : RAMB16_S9
		port map (
			DO => drd3,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en3,
			SSR => '0',
			WE => we
		);

	myBram30 : RAMB16_S9
		port map (
			DO => drd30,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en30,
			SSR => '0',
			WE => we
		);

	myBram31 : RAMB16_S9
		port map (
			DO => drd31,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en31,
			SSR => '0',
			WE => we
		);

	myBram32 : RAMB16_S9
		port map (
			DO => drd32,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en32,
			SSR => '0',
			WE => we
		);

	myBram33 : RAMB16_S9
		port map (
			DO => drd33,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en33,
			SSR => '0',
			WE => we
		);

	myBram34 : RAMB16_S9
		port map (
			DO => drd34,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en34,
			SSR => '0',
			WE => we
		);

	myBram35 : RAMB16_S9
		port map (
			DO => drd35,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en35,
			SSR => '0',
			WE => we
		);

	myBram36 : RAMB16_S9
		port map (
			DO => drd36,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en36,
			SSR => '0',
			WE => we
		);

	myBram37 : RAMB16_S9
		port map (
			DO => drd37,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en37,
			SSR => '0',
			WE => we
		);

	myBram38 : RAMB16_S9
		port map (
			DO => drd38,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en38,
			SSR => '0',
			WE => we
		);

	myBram39 : RAMB16_S9
		port map (
			DO => drd39,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en39,
			SSR => '0',
			WE => we
		);

	myBram4 : RAMB16_S9
		port map (
			DO => drd4,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en4,
			SSR => '0',
			WE => we
		);

	myBram40 : RAMB16_S9
		port map (
			DO => drd40,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en40,
			SSR => '0',
			WE => we
		);

	myBram41 : RAMB16_S9
		port map (
			DO => drd41,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en41,
			SSR => '0',
			WE => we
		);

	myBram42 : RAMB16_S9
		port map (
			DO => drd42,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en42,
			SSR => '0',
			WE => we
		);

	myBram43 : RAMB16_S9
		port map (
			DO => drd43,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en43,
			SSR => '0',
			WE => we
		);

	myBram44 : RAMB16_S9
		port map (
			DO => drd44,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en44,
			SSR => '0',
			WE => we
		);

	myBram45 : RAMB16_S9
		port map (
			DO => drd45,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en45,
			SSR => '0',
			WE => we
		);

	myBram46 : RAMB16_S9
		port map (
			DO => drd46,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en46,
			SSR => '0',
			WE => we
		);

	myBram47 : RAMB16_S9
		port map (
			DO => drd47,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en47,
			SSR => '0',
			WE => we
		);

	myBram48 : RAMB16_S9
		port map (
			DO => drd48,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en48,
			SSR => '0',
			WE => we
		);

	myBram49 : RAMB16_S9
		port map (
			DO => drd49,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en49,
			SSR => '0',
			WE => we
		);

	myBram5 : RAMB16_S9
		port map (
			DO => drd5,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en5,
			SSR => '0',
			WE => we
		);

	myBram50 : RAMB16_S9
		port map (
			DO => drd50,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en50,
			SSR => '0',
			WE => we
		);

	myBram51 : RAMB16_S9
		port map (
			DO => drd51,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en51,
			SSR => '0',
			WE => we
		);

	myBram52 : RAMB16_S9
		port map (
			DO => drd52,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en52,
			SSR => '0',
			WE => we
		);

	myBram53 : RAMB16_S9
		port map (
			DO => drd53,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en53,
			SSR => '0',
			WE => we
		);

	myBram54 : RAMB16_S9
		port map (
			DO => drd54,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en54,
			SSR => '0',
			WE => we
		);

	myBram55 : RAMB16_S9
		port map (
			DO => drd55,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en55,
			SSR => '0',
			WE => we
		);

	myBram56 : RAMB16_S9
		port map (
			DO => drd56,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en56,
			SSR => '0',
			WE => we
		);

	myBram57 : RAMB16_S9
		port map (
			DO => drd57,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en57,
			SSR => '0',
			WE => we
		);

	myBram58 : RAMB16_S9
		port map (
			DO => drd58,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en58,
			SSR => '0',
			WE => we
		);

	myBram59 : RAMB16_S9
		port map (
			DO => drd59,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en59,
			SSR => '0',
			WE => we
		);

	myBram6 : RAMB16_S9
		port map (
			DO => drd6,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en6,
			SSR => '0',
			WE => we
		);

	myBram60 : RAMB16_S9
		port map (
			DO => drd60,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en60,
			SSR => '0',
			WE => we
		);

	myBram61 : RAMB16_S9
		port map (
			DO => drd61,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en61,
			SSR => '0',
			WE => we
		);

	myBram62 : RAMB16_S9
		port map (
			DO => drd62,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en62,
			SSR => '0',
			WE => we
		);

	myBram63 : RAMB16_S9
		port map (
			DO => drd63,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en63,
			SSR => '0',
			WE => we
		);

	myBram64 : RAMB16_S9
		port map (
			DO => drd64,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en64,
			SSR => '0',
			WE => we
		);

	myBram65 : RAMB16_S9
		port map (
			DO => drd65,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en65,
			SSR => '0',
			WE => we
		);

	myBram66 : RAMB16_S9
		port map (
			DO => drd66,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en66,
			SSR => '0',
			WE => we
		);

	myBram67 : RAMB16_S9
		port map (
			DO => drd67,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en67,
			SSR => '0',
			WE => we
		);

	myBram68 : RAMB16_S9
		port map (
			DO => drd68,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en68,
			SSR => '0',
			WE => we
		);

	myBram69 : RAMB16_S9
		port map (
			DO => drd69,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en69,
			SSR => '0',
			WE => we
		);

	myBram7 : RAMB16_S9
		port map (
			DO => drd7,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en7,
			SSR => '0',
			WE => we
		);

	myBram70 : RAMB16_S9
		port map (
			DO => drd70,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en70,
			SSR => '0',
			WE => we
		);

	myBram71 : RAMB16_S9
		port map (
			DO => drd71,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en71,
			SSR => '0',
			WE => we
		);

	myBram72 : RAMB16_S9
		port map (
			DO => drd72,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en72,
			SSR => '0',
			WE => we
		);

	myBram73 : RAMB16_S9
		port map (
			DO => drd73,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en73,
			SSR => '0',
			WE => we
		);

	myBram74 : RAMB16_S9
		port map (
			DO => drd74,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en74,
			SSR => '0',
			WE => we
		);

	myBram75 : RAMB16_S9
		port map (
			DO => drd75,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en75,
			SSR => '0',
			WE => we
		);

	myBram76 : RAMB16_S9
		port map (
			DO => drd76,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en76,
			SSR => '0',
			WE => we
		);

	myBram77 : RAMB16_S9
		port map (
			DO => drd77,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en77,
			SSR => '0',
			WE => we
		);

	myBram78 : RAMB16_S9
		port map (
			DO => drd78,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en78,
			SSR => '0',
			WE => we
		);

	myBram79 : RAMB16_S9
		port map (
			DO => drd79,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en79,
			SSR => '0',
			WE => we
		);

	myBram8 : RAMB16_S9
		port map (
			DO => drd8,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en8,
			SSR => '0',
			WE => we
		);

	myBram9 : RAMB16_S9
		port map (
			DO => drd9,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en9,
			SSR => '0',
			WE => we
		);

	-- IP impl --- BEGIN
	------------------------------------------------------------------------
	-- implementation
	------------------------------------------------------------------------

	en0 <= '1' when (a(17 downto 11)="0000000" and en='1') else '0';
	en1 <= '1' when (a(17 downto 11)="0000001" and en='1') else '0';
	en2 <= '1' when (a(17 downto 11)="0000010" and en='1') else '0';
	en3 <= '1' when (a(17 downto 11)="0000011" and en='1') else '0';
	en4 <= '1' when (a(17 downto 11)="0000100" and en='1') else '0';
	en5 <= '1' when (a(17 downto 11)="0000101" and en='1') else '0';
	en6 <= '1' when (a(17 downto 11)="0000110" and en='1') else '0';
	en7 <= '1' when (a(17 downto 11)="0000111" and en='1') else '0';
	en8 <= '1' when (a(17 downto 11)="0001000" and en='1') else '0';
	en9 <= '1' when (a(17 downto 11)="0001001" and en='1') else '0';
	en10 <= '1' when (a(17 downto 11)="0001010" and en='1') else '0';
	en11 <= '1' when (a(17 downto 11)="0001011" and en='1') else '0';
	en12 <= '1' when (a(17 downto 11)="0001100" and en='1') else '0';
	en13 <= '1' when (a(17 downto 11)="0001101" and en='1') else '0';
	en14 <= '1' when (a(17 downto 11)="0001110" and en='1') else '0';
	en15 <= '1' when (a(17 downto 11)="0001111" and en='1') else '0';
	en16 <= '1' when (a(17 downto 11)="0010000" and en='1') else '0';
	en17 <= '1' when (a(17 downto 11)="0010001" and en='1') else '0';
	en18 <= '1' when (a(17 downto 11)="0010010" and en='1') else '0';
	en19 <= '1' when (a(17 downto 11)="0010011" and en='1') else '0';
	en20 <= '1' when (a(17 downto 11)="0010100" and en='1') else '0';
	en21 <= '1' when (a(17 downto 11)="0010101" and en='1') else '0';
	en22 <= '1' when (a(17 downto 11)="0010110" and en='1') else '0';
	en23 <= '1' when (a(17 downto 11)="0010111" and en='1') else '0';
	en24 <= '1' when (a(17 downto 11)="0011000" and en='1') else '0';
	en25 <= '1' when (a(17 downto 11)="0011001" and en='1') else '0';
	en26 <= '1' when (a(17 downto 11)="0011010" and en='1') else '0';
	en27 <= '1' when (a(17 downto 11)="0011011" and en='1') else '0';
	en28 <= '1' when (a(17 downto 11)="0011100" and en='1') else '0';
	en29 <= '1' when (a(17 downto 11)="0011101" and en='1') else '0';
	en30 <= '1' when (a(17 downto 11)="0011110" and en='1') else '0';
	en31 <= '1' when (a(17 downto 11)="0011111" and en='1') else '0';
	en32 <= '1' when (a(17 downto 11)="0100000" and en='1') else '0';
	en33 <= '1' when (a(17 downto 11)="0100001" and en='1') else '0';
	en34 <= '1' when (a(17 downto 11)="0100010" and en='1') else '0';
	en35 <= '1' when (a(17 downto 11)="0100011" and en='1') else '0';
	en36 <= '1' when (a(17 downto 11)="0100100" and en='1') else '0';
	en37 <= '1' when (a(17 downto 11)="0100101" and en='1') else '0';
	en38 <= '1' when (a(17 downto 11)="0100110" and en='1') else '0';
	en39 <= '1' when (a(17 downto 11)="0100111" and en='1') else '0';
	en40 <= '1' when (a(17 downto 11)="0101000" and en='1') else '0';
	en41 <= '1' when (a(17 downto 11)="0101001" and en='1') else '0';
	en42 <= '1' when (a(17 downto 11)="0101010" and en='1') else '0';
	en43 <= '1' when (a(17 downto 11)="0101011" and en='1') else '0';
	en44 <= '1' when (a(17 downto 11)="0101100" and en='1') else '0';
	en45 <= '1' when (a(17 downto 11)="0101101" and en='1') else '0';
	en46 <= '1' when (a(17 downto 11)="0101110" and en='1') else '0';
	en47 <= '1' when (a(17 downto 11)="0101111" and en='1') else '0';
	en48 <= '1' when (a(17 downto 11)="0110000" and en='1') else '0';
	en49 <= '1' when (a(17 downto 11)="0110001" and en='1') else '0';
	en50 <= '1' when (a(17 downto 11)="0110010" and en='1') else '0';
	en51 <= '1' when (a(17 downto 11)="0110011" and en='1') else '0';
	en52 <= '1' when (a(17 downto 11)="0110100" and en='1') else '0';
	en53 <= '1' when (a(17 downto 11)="0110101" and en='1') else '0';
	en54 <= '1' when (a(17 downto 11)="0110110" and en='1') else '0';
	en55 <= '1' when (a(17 downto 11)="0110111" and en='1') else '0';
	en56 <= '1' when (a(17 downto 11)="0111000" and en='1') else '0';
	en57 <= '1' when (a(17 downto 11)="0111001" and en='1') else '0';
	en58 <= '1' when (a(17 downto 11)="0111010" and en='1') else '0';
	en59 <= '1' when (a(17 downto 11)="0111011" and en='1') else '0';
	en60 <= '1' when (a(17 downto 11)="0111100" and en='1') else '0';
	en61 <= '1' when (a(17 downto 11)="0111101" and en='1') else '0';
	en62 <= '1' when (a(17 downto 11)="0111110" and en='1') else '0';
	en63 <= '1' when (a(17 downto 11)="0111111" and en='1') else '0';
	en64 <= '1' when (a(17 downto 11)="1000000" and en='1') else '0';
	en65 <= '1' when (a(17 downto 11)="1000001" and en='1') else '0';
	en66 <= '1' when (a(17 downto 11)="1000010" and en='1') else '0';
	en67 <= '1' when (a(17 downto 11)="1000011" and en='1') else '0';
	en68 <= '1' when (a(17 downto 11)="1000100" and en='1') else '0';
	en69 <= '1' when (a(17 downto 11)="1000101" and en='1') else '0';
	en70 <= '1' when (a(17 downto 11)="1000110" and en='1') else '0';
	en71 <= '1' when (a(17 downto 11)="1000111" and en='1') else '0';
	en72 <= '1' when (a(17 downto 11)="1001000" and en='1') else '0';
	en73 <= '1' when (a(17 downto 11)="1001001" and en='1') else '0';
	en74 <= '1' when (a(17 downto 11)="1001010" and en='1') else '0';
	en75 <= '1' when (a(17 downto 11)="1001011" and en='1') else '0';
	en76 <= '1' when (a(17 downto 11)="1001100" and en='1') else '0';
	en77 <= '1' when (a(17 downto 11)="1001101" and en='1') else '0';
	en78 <= '1' when (a(17 downto 11)="1001110" and en='1') else '0';
	en79 <= '1' when (a(17 downto 11)="1001111" and en='1') else '0';

	drd <= drd0 when a(17 downto 11)="0000000"
		else drd1 when a(17 downto 11)="0000001"
		else drd2 when a(17 downto 11)="0000010"
		else drd3 when a(17 downto 11)="0000011"
		else drd4 when a(17 downto 11)="0000100"
		else drd5 when a(17 downto 11)="0000101"
		else drd6 when a(17 downto 11)="0000110"
		else drd7 when a(17 downto 11)="0000111"
		else drd8 when a(17 downto 11)="0001000"
		else drd9 when a(17 downto 11)="0001001"
		else drd10 when a(17 downto 11)="0001010"
		else drd11 when a(17 downto 11)="0001011"
		else drd12 when a(17 downto 11)="0001100"
		else drd13 when a(17 downto 11)="0001101"
		else drd14 when a(17 downto 11)="0001110"
		else drd15 when a(17 downto 11)="0001111"
		else drd16 when a(17 downto 11)="0010000"
		else drd17 when a(17 downto 11)="0010001"
		else drd18 when a(17 downto 11)="0010010"
		else drd19 when a(17 downto 11)="0010011"
		else drd20 when a(17 downto 11)="0010100"
		else drd21 when a(17 downto 11)="0010101"
		else drd22 when a(17 downto 11)="0010110"
		else drd23 when a(17 downto 11)="0010111"
		else drd24 when a(17 downto 11)="0011000"
		else drd25 when a(17 downto 11)="0011001"
		else drd26 when a(17 downto 11)="0011010"
		else drd27 when a(17 downto 11)="0011011"
		else drd28 when a(17 downto 11)="0011100"
		else drd29 when a(17 downto 11)="0011101"
		else drd30 when a(17 downto 11)="0011110"
		else drd31 when a(17 downto 11)="0011111"
		else drd32 when a(17 downto 11)="0100000"
		else drd33 when a(17 downto 11)="0100001"
		else drd34 when a(17 downto 11)="0100010"
		else drd35 when a(17 downto 11)="0100011"
		else drd36 when a(17 downto 11)="0100100"
		else drd37 when a(17 downto 11)="0100101"
		else drd38 when a(17 downto 11)="0100110"
		else drd39 when a(17 downto 11)="0100111"
		else drd40 when a(17 downto 11)="0101000"
		else drd41 when a(17 downto 11)="0101001"
		else drd42 when a(17 downto 11)="0101010"
		else drd43 when a(17 downto 11)="0101011"
		else drd44 when a(17 downto 11)="0101100"
		else drd45 when a(17 downto 11)="0101101"
		else drd46 when a(17 downto 11)="0101110"
		else drd47 when a(17 downto 11)="0101111"
		else drd48 when a(17 downto 11)="0110000"
		else drd49 when a(17 downto 11)="0110001"
		else drd50 when a(17 downto 11)="0110010"
		else drd51 when a(17 downto 11)="0110011"
		else drd52 when a(17 downto 11)="0110100"
		else drd53 when a(17 downto 11)="0110101"
		else drd54 when a(17 downto 11)="0110110"
		else drd55 when a(17 downto 11)="0110111"
		else drd56 when a(17 downto 11)="0111000"
		else drd57 when a(17 downto 11)="0111001"
		else drd58 when a(17 downto 11)="0111010"
		else drd59 when a(17 downto 11)="0111011"
		else drd60 when a(17 downto 11)="0111100"
		else drd61 when a(17 downto 11)="0111101"
		else drd62 when a(17 downto 11)="0111110"
		else drd63 when a(17 downto 11)="0111111"
		else drd64 when a(17 downto 11)="1000000"
		else drd65 when a(17 downto 11)="1000001"
		else drd66 when a(17 downto 11)="1000010"
		else drd67 when a(17 downto 11)="1000011"
		else drd68 when a(17 downto 11)="1000100"
		else drd69 when a(17 downto 11)="1000101"
		else drd70 when a(17 downto 11)="1000110"
		else drd71 when a(17 downto 11)="1000111"
		else drd72 when a(17 downto 11)="1001000"
		else drd73 when a(17 downto 11)="1001001"
		else drd74 when a(17 downto 11)="1001010"
		else drd75 when a(17 downto 11)="1001011"
		else drd76 when a(17 downto 11)="1001100"
		else drd77 when a(17 downto 11)="1001101"
		else drd78 when a(17 downto 11)="1001110"
		else drd79 when a(17 downto 11)="1001111"
		else x"00";
	-- IP impl --- END

end Spbram_v1_0_size160kB;

