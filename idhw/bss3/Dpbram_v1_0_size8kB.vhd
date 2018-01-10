-- file Dpbram_v1_0_size8kB.vhd
-- Dpbram_v1_0_size8kB dpbram_v1_0 implementation
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

entity Dpbram_v1_0_size8kB is
	port (
		clkA: in std_logic;

		enA: in std_logic;
		weA: in std_logic;

		aA: in std_logic_vector(12 downto 0);
		drdA: out std_logic_vector(7 downto 0);
		dwrA: in std_logic_vector(7 downto 0);

		clkB: in std_logic;

		enB: in std_logic;
		weB: in std_logic;

		aB: in std_logic_vector(12 downto 0);
		drdB: out std_logic_vector(7 downto 0);
		dwrB: in std_logic_vector(7 downto 0)
	);
end Dpbram_v1_0_size8kB;

architecture Dpbram_v1_0_size8kB of Dpbram_v1_0_size8kB is

	-- IP sigs --- BEGIN
	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	signal enA1: std_logic := '0';
	signal enA2: std_logic := '0';
	signal enA0: std_logic := '0';
	signal enA3: std_logic := '0';

	signal drdA1: std_logic_vector(7 downto 0) := x"00";
	signal drdA2: std_logic_vector(7 downto 0) := x"00";
	signal drdA0: std_logic_vector(7 downto 0) := x"00";
	signal drdA3: std_logic_vector(7 downto 0) := x"00";

	signal enB1: std_logic := '0';
	signal enB2: std_logic := '0';
	signal enB0: std_logic := '0';
	signal enB3: std_logic := '0';

	signal drdB1: std_logic_vector(7 downto 0) := x"00";
	signal drdB2: std_logic_vector(7 downto 0) := x"00";
	signal drdB0: std_logic_vector(7 downto 0) := x"00";
	signal drdB3: std_logic_vector(7 downto 0) := x"00";
	-- IP sigs --- END

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBram0 : RAMB16_S9_S9
		port map (
			DOA => drdA0,
			DOB => drdB0,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA0,
			ENB => enB0,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram1 : RAMB16_S9_S9
		port map (
			DOA => drdA1,
			DOB => drdB1,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA1,
			ENB => enB1,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram2 : RAMB16_S9_S9
		port map (
			DOA => drdA2,
			DOB => drdB2,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA2,
			ENB => enB2,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram3 : RAMB16_S9_S9
		port map (
			DOA => drdA3,
			DOB => drdB3,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA3,
			ENB => enB3,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	-- IP impl --- BEGIN
	------------------------------------------------------------------------
	-- implementation 
	------------------------------------------------------------------------

	enA0 <= '1' when (aA(12 downto 11)="00" and enA='1') else '0';
	enA1 <= '1' when (aA(12 downto 11)="01" and enA='1') else '0';
	enA2 <= '1' when (aA(12 downto 11)="10" and enA='1') else '0';
	enA3 <= '1' when (aA(12 downto 11)="11" and enA='1') else '0';

	drdA <= drdA0 when aA(12 downto 11)="00"
		else drdA1 when aA(12 downto 11)="01"
		else drdA2 when aA(12 downto 11)="10"
		else drdA3 when aA(12 downto 11)="11"
		else x"00";

	enB0 <= '1' when (aB(12 downto 11)="00" and enB='1') else '0';
	enB1 <= '1' when (aB(12 downto 11)="01" and enB='1') else '0';
	enB2 <= '1' when (aB(12 downto 11)="10" and enB='1') else '0';
	enB3 <= '1' when (aB(12 downto 11)="11" and enB='1') else '0';

	drdB <= drdB0 when aB(12 downto 11)="00"
		else drdB1 when aB(12 downto 11)="01"
		else drdB2 when aB(12 downto 11)="10"
		else drdB3 when aB(12 downto 11)="11"
		else x"00";
	-- IP impl --- END

end Dpbram_v1_0_size8kB;

