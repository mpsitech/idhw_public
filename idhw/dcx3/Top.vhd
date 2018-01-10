-- file Dcx3.vhd
-- Dcx3 top_v1_0 top implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 28 Nov 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

-- IP libs.cust --- INSERT

entity Top is
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

architecture Top of Top is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

-- OUT >
	component Hostshfbox is
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
	end component;
-- >

	component Hostif is
		port (
			miso: inout std_logic;
			mosi: in std_logic;
			sclk: in std_logic;
			nss: in std_logic;

			reset: in std_logic;
			mclk: in std_logic;
			commok: out std_logic;
			reqReset: out std_logic;

			reqBufToCmdinv: out std_logic;

			reqBufFromCmdret: out std_logic;

			ackBufToCmdinv: in std_logic;

			ackBufFromCmdret: in std_logic;

			incBufToCmdinv: out std_logic;

			incBufFromCmdret: out std_logic;

			cnfBufToCmdinv: out std_logic;

			cnfBufFromCmdret: out std_logic;

			lenBufToCmdinv: in std_logic_vector(5 downto 0);
			lenBufFromCmdret: in std_logic_vector(7 downto 0);

			dBufToCmdinv: out std_logic_vector(7 downto 0);

			dBufFromCmdret: in std_logic_vector(7 downto 0);

			strbDBufToCmdinv: out std_logic;

			strbDBufFromCmdret: in std_logic;

			reqBufFromPmmu: out std_logic;

			reqWrbufToQcdif: out std_logic;

			reqRdbufFromQcdif: out std_logic;

			ackBufFromPmmu: in std_logic;

			ackWrbufToQcdif: in std_logic;

			ackRdbufFromQcdif: in std_logic;

			incBufFromPmmu: out std_logic;

			incWrbufToQcdif: out std_logic;

			incRdbufFromQcdif: out std_logic;

			cnfBufFromPmmu: out std_logic;

			cnfWrbufToQcdif: out std_logic;

			cnfRdbufFromQcdif: out std_logic;

			lenBufFromPmmu: in std_logic_vector(19 downto 0);
			lenWrbufToQcdif: in std_logic_vector(10 downto 0);
			lenRdbufFromQcdif: in std_logic_vector(10 downto 0);

			dBufFromPmmu: in std_logic_vector(7 downto 0);

			dWrbufToQcdif: out std_logic_vector(7 downto 0);

			dRdbufFromQcdif: in std_logic_vector(7 downto 0);

			strbDBufFromPmmu: in std_logic;

			strbDRdbufFromQcdif: in std_logic;

			strbDWrbufToQcdif: out std_logic;
			
			-- DEBUG
			nssToDbgout1: out std_logic;
			sclkToDbgout2: out std_logic
		);
	end component;

	component Cmdbus is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;
			fClk: natural range 1 to 100000 := 10000
		);
		port (
			reset: in std_logic;
			clk: out std_logic;
			mclk: in std_logic;

			rdy: in std_logic_vector(16 downto 0);

			req: in std_logic_vector(16 downto 0);
			ack: out std_logic_vector(16 downto 0)
		);
	end component;

	component Cmdinv is
		port (
			reset: in std_logic;

			clkCmdbus: in std_logic;

			mclk: in std_logic;

			dCmdbus: inout std_logic_vector(7 downto 0);

			reqCmdbusToAdxl: out std_logic;
			wrCmdbusToAdxl: in std_logic;

			reqCmdbusToAlign: out std_logic;
			wrCmdbusToAlign: in std_logic;

			reqCmdbusToLed: out std_logic;
			wrCmdbusToLed: in std_logic;

			reqCmdbusToLwirif: out std_logic;
			wrCmdbusToLwirif: in std_logic;

			reqCmdbusToPhiif: out std_logic;
			wrCmdbusToPhiif: in std_logic;

			reqCmdbusToPmmu: out std_logic;
			wrCmdbusToPmmu: in std_logic;

			reqCmdbusToQcdif: out std_logic;
			wrCmdbusToQcdif: in std_logic;

			reqCmdbusToShfbox: out std_logic;
			wrCmdbusToShfbox: in std_logic;

			reqCmdbusToState: out std_logic;
			wrCmdbusToState: in std_logic;

			reqCmdbusToThetaif: out std_logic;
			wrCmdbusToThetaif: in std_logic;

			reqCmdbusToTkclksrc: out std_logic;
			wrCmdbusToTkclksrc: in std_logic;

			reqCmdbusToTrigger: out std_logic;
			wrCmdbusToTrigger: in std_logic;

			reqBufFromHostif: in std_logic;
			ackBufFromHostif: out std_logic;

			incBufFromHostif: in std_logic;
			cnfBufFromHostif: in std_logic;

			lenBufFromHostif: out std_logic_vector(5 downto 0);

			dBufFromHostif: in std_logic_vector(7 downto 0);
			strbDBufFromHostif: in std_logic
		);
	end component;

	component Cmdret is
		port (
			reset: in std_logic;

			clkCmdbus: in std_logic;

			mclk: in std_logic;

			dCmdbus: in std_logic_vector(7 downto 0);

			rdyCmdbusFromAdxl: out std_logic;
			rdCmdbusFromAdxl: in std_logic;

			rdyCmdbusFromPmmu: out std_logic;
			rdCmdbusFromPmmu: in std_logic;

			rdyCmdbusFromQcdif: out std_logic;
			rdCmdbusFromQcdif: in std_logic;

			rdyCmdbusFromState: out std_logic;
			rdCmdbusFromState: in std_logic;

			rdyCmdbusFromTkclksrc: out std_logic;
			rdCmdbusFromTkclksrc: in std_logic;

			reqBufToHostif: in std_logic;
			ackBufToHostif: out std_logic;

			incBufToHostif: in std_logic;
			cnfBufToHostif: in std_logic;

			lenBufToHostif: out std_logic_vector(7 downto 0);

			dBufToHostif: out std_logic_vector(7 downto 0);
			strbDBufToHostif: out std_logic
		);
	end component;

	component Adxl is
		generic (
			fMclk: natural range 1 to 1000000
		);
		port (
			reset: in std_logic;

			clkCmdbus: in std_logic;

			mclk: in std_logic;

			dCmdbus: inout std_logic_vector(7 downto 0);

			tkclk: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Align is
		generic (
			fMclk: natural range 1 to 1000000
		);
		port (
			reset: in std_logic;

			clkCmdbus: in std_logic;

			mclk: in std_logic;

			dCmdbus: in std_logic_vector(7 downto 0);

			tkclk: in std_logic;

			rdyCmdbusFromCmdinv: out std_logic;

			trigrng: in std_logic;

			rdCmdbusFromCmdinv: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Led is
		port (
			led15pwm: out std_logic;

			clkCmdbus: in std_logic;

			led60pwm: out std_logic;

			dCmdbus: in std_logic_vector(7 downto 0);

			reset: in std_logic;

			rdyCmdbusFromCmdinv: out std_logic;

			mclk: in std_logic;

			rdCmdbusFromCmdinv: in std_logic;

			tkclk: in std_logic
		);
	end component;

	component Lwiracq is
		port (
			clk: in std_logic;
			snc: in std_logic;

			d1: in std_logic;
			d2: in std_logic;

			extsnc: out std_logic;
			reset: in std_logic;
			mclk: in std_logic;
			trig: in std_logic;

			reqBufToPmmu: in std_logic;
			ackBufToPmmu: out std_logic;

			incBufToPmmu: in std_logic;
			cnfBufToPmmu: in std_logic;

			lenBufToPmmu: out std_logic_vector(12 downto 0);

			dBufToPmmu: out std_logic_vector(7 downto 0);
			strbDBufToPmmu: out std_logic;
			
			-- DEBUG
			sncToDbgout3: out std_logic
		);
	end component;

	component Lwirif is
		generic (
			fMclk: natural range 1 to 1000000
		);
		port (
			reset: in std_logic;

			clkCmdbus: in std_logic;

			mclk: in std_logic;

			dCmdbus: in std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			rxd: in std_logic;
			txd: out std_logic
		);
	end component;

	component Phiif is
		port (
			reset: in std_logic;

			clkCmdbus: in std_logic;

			mclk: in std_logic;

			dCmdbus: in std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Pmmu is
		port (
			nce: out std_logic;

			clkCmdbus: in std_logic;

			noe: out std_logic;

			dCmdbus: inout std_logic_vector(7 downto 0);

			nwe: out std_logic;

			rdyCmdbusFromCmdinv: out std_logic;

			a: out std_logic_vector(20 downto 0);

			rdCmdbusFromCmdinv: in std_logic;

			d: inout std_logic_vector(7 downto 0);

			reqCmdbusToCmdret: out std_logic;

			reset: in std_logic;

			wrCmdbusToCmdret: in std_logic;

			mclk: in std_logic;

			reqBufToHostif: in std_logic;
			ackBufToHostif: out std_logic;

			incBufToHostif: in std_logic;
			cnfBufToHostif: in std_logic;

			lenBufToHostif: out std_logic_vector(19 downto 0);

			dBufToHostif: out std_logic_vector(7 downto 0);
			strbDBufToHostif: out std_logic;

			reqBufFromLwiracq: out std_logic;
			ackBufFromLwiracq: in std_logic;

			incBufFromLwiracq: out std_logic;
			cnfBufFromLwiracq: out std_logic;

			lenBufFromLwiracq: in std_logic_vector(12 downto 0);

			dBufFromLwiracq: in std_logic_vector(7 downto 0);
			strbDBufFromLwiracq: in std_logic
		);
	end component;

	component Qcdif is
		port (
			reset: in std_logic;

			clkCmdbus: in std_logic;

			mclk: in std_logic;

			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			reqWrbufFromHostif: in std_logic;

			reqRdbufToHostif: in std_logic;

			ackWrbufFromHostif: out std_logic;

			ackRdbufToHostif: out std_logic;

			incWrbufFromHostif: in std_logic;

			incRdbufToHostif: in std_logic;

			cnfWrbufFromHostif: in std_logic;

			cnfRdbufToHostif: in std_logic;

			lenWrbufFromHostif: out std_logic_vector(10 downto 0);
			lenRdbufToHostif: out std_logic_vector(10 downto 0);

			dWrbufFromHostif: in std_logic_vector(7 downto 0);

			dRdbufToHostif: out std_logic_vector(7 downto 0);

			strbDWrbufFromHostif: in std_logic;

			strbDRdbufToHostif: out std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

-- > HEAVILY MODIFIED!
	component Shfbox is
		port (
			reset: in std_logic;

			mclk: in std_logic;

			clkCmdbus: in std_logic;

			dCmdbus: in std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			tixVDcx3ShfboxGpiocfg_wrp: out std_logic_vector(7 downto 0);
			tixVDcx3ShfboxLedcfg_wrp: out std_logic_vector(7 downto 0);
			tixVDcx3ShfboxSpicfg_wrp: out std_logic_vector(7 downto 0)
		);
	end component;

	component State is
		port (
			ledg: out std_logic;

			clkCmdbus: in std_logic;

			ledr: out std_logic;

			dCmdbus: inout std_logic_vector(7 downto 0);

			reset: in std_logic;

			rdyCmdbusFromCmdinv: out std_logic;

			mclk: in std_logic;

			rdCmdbusFromCmdinv: in std_logic;

			tkclk: in std_logic;

			reqCmdbusToCmdret: out std_logic;

			commok: in std_logic;

			wrCmdbusToCmdret: in std_logic
		);
	end component;

	component Thetaif is
		port (
			reset: in std_logic;

			clkCmdbus: in std_logic;

			mclk: in std_logic;

			dCmdbus: in std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Tkclksrc is
		generic (
			fMclk: natural range 1 to 1000000
		);
		port (
			reset: in std_logic;

			clkCmdbus: in std_logic;

			mclk: in std_logic;

			dCmdbus: inout std_logic_vector(7 downto 0);

			tkclk: out std_logic;

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic
		);
	end component;

	component Trigger is
		port (
			reset: in std_logic;

			clkCmdbus: in std_logic;

			mclk: in std_logic;

			dCmdbus: in std_logic_vector(7 downto 0);

			tkclk: in std_logic;

			rdyCmdbusFromCmdinv: out std_logic;

			trigrng: out std_logic;

			rdCmdbusFromCmdinv: in std_logic;

			trigLwir: out std_logic;
			trigVisl: out std_logic;
			trigVisr: out std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- master clock

	signal mclk: std_logic := '0';

	---- reset
	type stateRst_t is (
		stateRstReset,
		stateRstRun
	);
	signal stateRst, stateRst_next: stateRst_t := stateRstReset;

	signal reset: std_logic := '0';

	---- other
	signal spi1_nss: std_logic;

	signal clkCmdbus: std_logic;

	signal spi1_sclk: std_logic;
	signal reqReset: std_logic;

	signal dCmdbus: std_logic_vector(7 downto 0);

	signal spi1_mosi: std_logic;
	signal extclk: std_logic;

	signal rdyCmdbus: std_logic_vector(16 downto 0);

	signal spi1_miso: std_logic;

	signal reqCmdbus: std_logic_vector(16 downto 0);

	signal spih_nss: std_logic;

	signal ackCmdbus: std_logic_vector(16 downto 0);

	signal spih_sclk: std_logic;
	signal spih_mosi: std_logic;
	signal spih_miso: std_logic;
	signal spit_nss: std_logic;
	signal spit_sclk: std_logic;
	signal spit_mosi: std_logic;
	signal spit_miso: std_logic;
	signal spip_nss: std_logic;
	signal spip_sclk: std_logic;
	signal spip_mosi: std_logic;
	signal spip_miso: std_logic;
	signal spiq_nss: std_logic;
	signal spiq_sclk: std_logic;
	signal spiq_mosi: std_logic;
	signal spiq_miso: std_logic;
	signal gpiol_0: std_logic;
	signal gpior_0: std_logic;
	signal led15pwm: std_logic;
	signal led60pwm: std_logic;
	signal commok: std_logic;
	signal trigrng: std_logic;
	signal trigLwir: std_logic;
	signal tkclk: std_logic;

	signal reqBufCmdretToHostif: std_logic;

	signal reqBufHostifToCmdinv: std_logic;

	signal ackBufCmdretToHostif: std_logic;

	signal ackBufHostifToCmdinv: std_logic;

	signal incBufCmdretToHostif: std_logic;

	signal incBufHostifToCmdinv: std_logic;

	signal cnfBufCmdretToHostif: std_logic;

	signal cnfBufHostifToCmdinv: std_logic;

	signal lenBufCmdretToHostif: std_logic_vector(7 downto 0);
	signal lenBufHostifToCmdinv: std_logic_vector(5 downto 0);

	signal dBufCmdretToHostif: std_logic_vector(7 downto 0);

	signal dBufHostifToCmdinv: std_logic_vector(7 downto 0);

	signal strbDBufCmdretToHostif: std_logic;

	signal strbDBufHostifToCmdinv: std_logic;

	signal reqBufPmmuToHostif: std_logic;

	signal reqWrbufHostifToQcdif: std_logic;

	signal reqRdbufQcdifToHostif: std_logic;

	signal ackBufPmmuToHostif: std_logic;

	signal ackWrbufHostifToQcdif: std_logic;

	signal ackRdbufQcdifToHostif: std_logic;

	signal incBufPmmuToHostif: std_logic;

	signal incWrbufHostifToQcdif: std_logic;

	signal incRdbufQcdifToHostif: std_logic;

	signal cnfBufPmmuToHostif: std_logic;

	signal cnfWrbufHostifToQcdif: std_logic;

	signal cnfRdbufQcdifToHostif: std_logic;

	signal lenBufPmmuToHostif: std_logic_vector(19 downto 0);
	signal lenWrbufHostifToQcdif: std_logic_vector(10 downto 0);
	signal lenRdbufQcdifToHostif: std_logic_vector(10 downto 0);

	signal dBufPmmuToHostif: std_logic_vector(7 downto 0);

	signal dWrbufHostifToQcdif: std_logic_vector(7 downto 0);

	signal dRdbufQcdifToHostif: std_logic_vector(7 downto 0);

	signal strbDBufPmmuToHostif: std_logic;

	signal strbDWrbufHostifToQcdif: std_logic;

	signal strbDRdbufQcdifToHostif: std_logic;

	signal reqBufLwiracqToPmmu: std_logic;
	signal ackBufLwiracqToPmmu: std_logic;

	signal incBufLwiracqToPmmu: std_logic;
	signal cnfBufLwiracqToPmmu: std_logic;

	signal lenBufLwiracqToPmmu: std_logic_vector(12 downto 0);

	signal dBufLwiracqToPmmu: std_logic_vector(7 downto 0);
	signal strbDBufLwiracqToPmmu: std_logic;

	signal lw_clk: std_logic;
	signal lw_snc: std_logic;
	signal lw_d1: std_logic;
	signal lw_d2: std_logic;

	-- IP sigs.oth.cust --- IBEGIN
	-- DEBUG
	signal dbgout1: std_logic;
	signal dbgout2: std_logic;
	signal dbgout3: std_logic;
	signal dbgin1: std_logic;
	-- IP sigs.oth.cust --- IEND

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myIbufdsLw_clk : IBUFDS
		port map (
			I => lw_clkp,
			IB => lw_clkn,
			O => lw_clk
		);

	myIbufdsLw_snc : IBUFDS
		port map (
			I => lw_sncp,
			IB => lw_sncn,
			O => lw_snc
		);

	myIbufdsLw_d1 : IBUFDS
		port map (
			I => lw_d1p,
			IB => lw_d1n,
			O => lw_d1
		);

	myIbufdsLw_d2 : IBUFDS
		port map (
			I => lw_d2p,
			IB => lw_d2n,
			O => lw_d2
		);

	myIbufgdsExtclk : IBUFGDS
		port map (
			I => extclkp,
			IB => extclkn,
			O => extclk
		);

-- OUT >
	myHostshfbox : Hostshfbox
		port map (
			l_ntss => l_ntss,
			l_tsck => l_tsck,
			l_tsdo => l_tsdo,
			l_tsdi => l_tsdi,

			exg_sysen_nn => exg_sysen_nn,
			exg_nn_sysen => exg_nn_sysen,
			exg_s1clk => exg_s1clk,
			exg_s1nirq_s1cs0 => exg_s1nirq_s1cs0,
			exg_s1mosi => exg_s1mosi,
			exg_s1cs0_s1cs1 => exg_s1cs0_s1cs1,
			exg_s1miso => exg_s1miso,

			spih_nss => spih_nss,
			spih_sclk => spih_sclk,
			spih_mosi => spih_mosi,
			spih_miso => spih_miso,

			spi1_nss => spi1_nss,
			spi1_sclk => spi1_sclk,
			spi1_mosi => spi1_mosi,
			spi1_miso => spi1_miso
		);
-- <

	myHostif : Hostif
		port map (
			miso => spih_miso,
			mosi => spih_mosi,
			sclk => spih_sclk,
			nss => spih_nss,

			reset => reset,
			mclk => mclk,
			commok => commok,
			reqReset => reqReset,

			reqBufToCmdinv => reqBufHostifToCmdinv,

			reqBufFromCmdret => reqBufCmdretToHostif,

			ackBufToCmdinv => ackBufHostifToCmdinv,

			ackBufFromCmdret => ackBufCmdretToHostif,

			incBufToCmdinv => incBufHostifToCmdinv,

			incBufFromCmdret => incBufCmdretToHostif,

			cnfBufToCmdinv => cnfBufHostifToCmdinv,

			cnfBufFromCmdret => cnfBufCmdretToHostif,

			lenBufToCmdinv => lenBufHostifToCmdinv,
			lenBufFromCmdret => lenBufCmdretToHostif,

			dBufToCmdinv => dBufHostifToCmdinv,

			dBufFromCmdret => dBufCmdretToHostif,

			strbDBufToCmdinv => strbDBufHostifToCmdinv,

			strbDBufFromCmdret => strbDBufCmdretToHostif,

			reqBufFromPmmu => reqBufPmmuToHostif,

			reqWrbufToQcdif => reqWrbufHostifToQcdif,

			reqRdbufFromQcdif => reqRdbufQcdifToHostif,

			ackBufFromPmmu => ackBufPmmuToHostif,

			ackWrbufToQcdif => ackWrbufHostifToQcdif,

			ackRdbufFromQcdif => ackRdbufQcdifToHostif,

			incBufFromPmmu => incBufPmmuToHostif,

			incWrbufToQcdif => incWrbufHostifToQcdif,

			incRdbufFromQcdif => incRdbufQcdifToHostif,

			cnfBufFromPmmu => cnfBufPmmuToHostif,

			cnfWrbufToQcdif => cnfWrbufHostifToQcdif,

			cnfRdbufFromQcdif => cnfRdbufQcdifToHostif,

			lenBufFromPmmu => lenBufPmmuToHostif,
			lenWrbufToQcdif => lenWrbufHostifToQcdif,
			lenRdbufFromQcdif => lenRdbufQcdifToHostif,

			dBufFromPmmu => dBufPmmuToHostif,

			dWrbufToQcdif => dWrbufHostifToQcdif,

			dRdbufFromQcdif => dRdbufQcdifToHostif,

			strbDBufFromPmmu => strbDBufPmmuToHostif,

			strbDRdbufFromQcdif => strbDRdbufQcdifToHostif,

			strbDWrbufToQcdif => strbDWrbufHostifToQcdif,

			-- DEBUG
			nssToDbgout1 => dbgout1,
			sclkToDbgout2 => dbgout2
		);

	myCmdbus : Cmdbus
		generic map (
			fMclk => fMclk,
			fClk => 12500
		)
		port map (
			reset => reset,
			clk => clkCmdbus,
			mclk => mclk,

			rdy => rdyCmdbus,

			req => reqCmdbus,
			ack => ackCmdbus
		);

	myCmdinv : Cmdinv
		port map (
			reset => reset,

			clkCmdbus => clkCmdbus,

			mclk => mclk,

			dCmdbus => dCmdbus,

			reqCmdbusToAdxl => reqCmdbus(1),
			wrCmdbusToAdxl => ackCmdbus(1),

			reqCmdbusToAlign => reqCmdbus(2),
			wrCmdbusToAlign => ackCmdbus(2),

			reqCmdbusToLed => reqCmdbus(3),
			wrCmdbusToLed => ackCmdbus(3),

			reqCmdbusToLwirif => reqCmdbus(4),
			wrCmdbusToLwirif => ackCmdbus(4),

			reqCmdbusToPhiif => reqCmdbus(5),
			wrCmdbusToPhiif => ackCmdbus(5),

			reqCmdbusToPmmu => reqCmdbus(6),
			wrCmdbusToPmmu => ackCmdbus(6),

			reqCmdbusToQcdif => reqCmdbus(7),
			wrCmdbusToQcdif => ackCmdbus(7),

			reqCmdbusToShfbox => reqCmdbus(8),
			wrCmdbusToShfbox => ackCmdbus(8),

			reqCmdbusToState => reqCmdbus(9),
			wrCmdbusToState => ackCmdbus(9),

			reqCmdbusToThetaif => reqCmdbus(10),
			wrCmdbusToThetaif => ackCmdbus(10),

			reqCmdbusToTkclksrc => reqCmdbus(11),
			wrCmdbusToTkclksrc => ackCmdbus(11),

			reqCmdbusToTrigger => reqCmdbus(12),
			wrCmdbusToTrigger => ackCmdbus(12),

			reqBufFromHostif => reqBufHostifToCmdinv,
			ackBufFromHostif => ackBufHostifToCmdinv,

			incBufFromHostif => incBufHostifToCmdinv,
			cnfBufFromHostif => cnfBufHostifToCmdinv,

			lenBufFromHostif => lenBufHostifToCmdinv,

			dBufFromHostif => dBufHostifToCmdinv,
			strbDBufFromHostif => strbDBufHostifToCmdinv
		);

	myCmdret : Cmdret
		port map (
			reset => reset,

			clkCmdbus => clkCmdbus,

			mclk => mclk,

			dCmdbus => dCmdbus,

			rdyCmdbusFromAdxl => rdyCmdbus(0),
			rdCmdbusFromAdxl => ackCmdbus(0),

			rdyCmdbusFromPmmu => rdyCmdbus(13),
			rdCmdbusFromPmmu => ackCmdbus(13),

			rdyCmdbusFromQcdif => rdyCmdbus(14),
			rdCmdbusFromQcdif => ackCmdbus(14),

			rdyCmdbusFromState => rdyCmdbus(15),
			rdCmdbusFromState => ackCmdbus(15),

			rdyCmdbusFromTkclksrc => rdyCmdbus(16),
			rdCmdbusFromTkclksrc => ackCmdbus(16),

			reqBufToHostif => reqBufCmdretToHostif,
			ackBufToHostif => ackBufCmdretToHostif,

			incBufToHostif => incBufCmdretToHostif,
			cnfBufToHostif => cnfBufCmdretToHostif,

			lenBufToHostif => lenBufCmdretToHostif,

			dBufToHostif => dBufCmdretToHostif,
			strbDBufToHostif => strbDBufCmdretToHostif
		);

	myAdxl : Adxl
		generic map (
			fMclk => fMclk
		)
		port map (
			reset => reset,

			clkCmdbus => clkCmdbus,

			mclk => mclk,

			dCmdbus => dCmdbus,

			tkclk => tkclk,

			reqCmdbusToCmdret => reqCmdbus(0),
			wrCmdbusToCmdret => ackCmdbus(0),

			rdyCmdbusFromCmdinv => rdyCmdbus(1),
			rdCmdbusFromCmdinv => ackCmdbus(1),

			nss => nxss,
			sclk => xsck,
			mosi => xsdo,
			miso => xsdi
		);

	myAlign : Align
		generic map (
			fMclk => fMclk
		)
		port map (
			reset => reset,

			clkCmdbus => clkCmdbus,

			mclk => mclk,

			dCmdbus => dCmdbus,

			tkclk => tkclk,

			rdyCmdbusFromCmdinv => rdyCmdbus(2),

			trigrng => trigrng,

			rdCmdbusFromCmdinv => ackCmdbus(2),

			nss => l_nass,
			sclk => l_asck,
			mosi => l_asdo,
			miso => l_asdi
		);

	myLed : Led
		port map (
			led15pwm => led15pwm,

			clkCmdbus => clkCmdbus,

			led60pwm => led60pwm,

			dCmdbus => dCmdbus,

			reset => reset,

			rdyCmdbusFromCmdinv => rdyCmdbus(3),

			mclk => mclk,

			rdCmdbusFromCmdinv => ackCmdbus(3),

			tkclk => tkclk
		);

	myLwiracq : Lwiracq
		port map (
			clk => lw_clk,
			snc => lw_snc,

			d1 => lw_d1,
			d2 => lw_d2,

			extsnc => lw_extsnc,
			reset => reset,
			mclk => mclk,
			trig => trigLwir,

			reqBufToPmmu => reqBufLwiracqToPmmu,
			ackBufToPmmu => ackBufLwiracqToPmmu,

			incBufToPmmu => incBufLwiracqToPmmu,
			cnfBufToPmmu => cnfBufLwiracqToPmmu,

			lenBufToPmmu => lenBufLwiracqToPmmu,

			dBufToPmmu => dBufLwiracqToPmmu,
			strbDBufToPmmu => strbDBufLwiracqToPmmu,
			
			-- DEBUG
			sncToDbgout3 => dbgout3
		);

	myLwirif : Lwirif
		generic map (
			fMclk => fMclk
		)
		port map (
			reset => reset,

			clkCmdbus => clkCmdbus,

			mclk => mclk,

			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(4),
			rdCmdbusFromCmdinv => ackCmdbus(4),

			rxd => lw_rx,
			txd => lw_tx
		);

	myPhiif : Phiif
		port map (
			reset => reset,

			clkCmdbus => clkCmdbus,

			mclk => mclk,

			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(5),
			rdCmdbusFromCmdinv => ackCmdbus(5),

			nss => spip_nss,
			sclk => spip_sclk,
			mosi => spip_mosi,
			miso => spip_miso
		);

	myPmmu : Pmmu
		port map (
			nce => sr_nce,

			clkCmdbus => clkCmdbus,

			noe => sr_noe,

			dCmdbus => dCmdbus,

			nwe => sr_nwe,

			rdyCmdbusFromCmdinv => rdyCmdbus(6),

			a => sr_a,

			rdCmdbusFromCmdinv => ackCmdbus(6),

			d => sr_d,

			reqCmdbusToCmdret => reqCmdbus(13),

			reset => reset,

			wrCmdbusToCmdret => ackCmdbus(13),

			mclk => mclk,

			reqBufToHostif => reqBufPmmuToHostif,
			ackBufToHostif => ackBufPmmuToHostif,

			incBufToHostif => incBufPmmuToHostif,
			cnfBufToHostif => cnfBufPmmuToHostif,

			lenBufToHostif => lenBufPmmuToHostif,

			dBufToHostif => dBufPmmuToHostif,
			strbDBufToHostif => strbDBufPmmuToHostif,

			reqBufFromLwiracq => reqBufLwiracqToPmmu,
			ackBufFromLwiracq => ackBufLwiracqToPmmu,

			incBufFromLwiracq => incBufLwiracqToPmmu,
			cnfBufFromLwiracq => cnfBufLwiracqToPmmu,

			lenBufFromLwiracq => lenBufLwiracqToPmmu,

			dBufFromLwiracq => dBufLwiracqToPmmu,
			strbDBufFromLwiracq => strbDBufLwiracqToPmmu
		);

	myQcdif : Qcdif
		port map (
			reset => reset,

			clkCmdbus => clkCmdbus,

			mclk => mclk,

			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(7),
			rdCmdbusFromCmdinv => ackCmdbus(7),

			reqCmdbusToCmdret => reqCmdbus(14),
			wrCmdbusToCmdret => ackCmdbus(14),

			reqWrbufFromHostif => reqWrbufHostifToQcdif,

			reqRdbufToHostif => reqRdbufQcdifToHostif,

			ackWrbufFromHostif => ackWrbufHostifToQcdif,

			ackRdbufToHostif => ackRdbufQcdifToHostif,

			incWrbufFromHostif => incWrbufHostifToQcdif,

			incRdbufToHostif => incRdbufQcdifToHostif,

			cnfWrbufFromHostif => cnfWrbufHostifToQcdif,

			cnfRdbufToHostif => cnfRdbufQcdifToHostif,

			lenWrbufFromHostif => lenWrbufHostifToQcdif,
			lenRdbufToHostif => lenRdbufQcdifToHostif,

			dWrbufFromHostif => dWrbufHostifToQcdif,

			dRdbufToHostif => dRdbufQcdifToHostif,

			strbDWrbufFromHostif => strbDWrbufHostifToQcdif,

			strbDRdbufToHostif => strbDRdbufQcdifToHostif,

			nss => spiq_nss,
			sclk => spiq_sclk,
			mosi => spiq_mosi,
			miso => spiq_miso
		);

-- HEAVILY MODIFIED
	myShfbox : Shfbox
		port map (
			reset => reset,

			mclk => mclk,

			clkCmdbus => clkCmdbus,

			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(8),
			rdCmdbusFromCmdinv => ackCmdbus(8),

			tixVDcx3ShfboxGpiocfg_wrp => tixVDcx3ShfboxGpiocfg_wrp,
			tixVDcx3ShfboxLedcfg_wrp => tixVDcx3ShfboxLedcfg_wrp,
			tixVDcx3ShfboxSpicfg_wrp => tixVDcx3ShfboxSpicfg_wrp,
		);

	myState : State
		port map (
			ledg => ledg,

			clkCmdbus => clkCmdbus,

			ledr => ledr,

			dCmdbus => dCmdbus,

			reset => reset,

			rdyCmdbusFromCmdinv => rdyCmdbus(9),

			mclk => mclk,

			rdCmdbusFromCmdinv => ackCmdbus(9),

			tkclk => tkclk,

			reqCmdbusToCmdret => reqCmdbus(15),

			commok => commok,

			wrCmdbusToCmdret => ackCmdbus(15)
		);

	myThetaif : Thetaif
		port map (
			reset => reset,

			clkCmdbus => clkCmdbus,

			mclk => mclk,

			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(10),
			rdCmdbusFromCmdinv => ackCmdbus(10),

			nss => spit_nss,
			sclk => spit_sclk,
			mosi => spit_mosi,
			miso => spit_miso
		);

	myTkclksrc : Tkclksrc
		generic map (
			fMclk => fMclk -- in kHz
		)
		port map (
			reset => reset,

			clkCmdbus => clkCmdbus,

			mclk => mclk,

			dCmdbus => dCmdbus,

			tkclk => tkclk,

			rdyCmdbusFromCmdinv => rdyCmdbus(11),
			rdCmdbusFromCmdinv => ackCmdbus(11),

			reqCmdbusToCmdret => reqCmdbus(16),
			wrCmdbusToCmdret => ackCmdbus(16)
		);

	myTrigger : Trigger
		port map (
			reset => reset,

			clkCmdbus => clkCmdbus,

			mclk => mclk,

			dCmdbus => dCmdbus,

			tkclk => tkclk,

			rdyCmdbusFromCmdinv => rdyCmdbus(12),

			trigrng => trigrng,

			rdCmdbusFromCmdinv => ackCmdbus(12),

			trigLwir => trigLwir,
			trigVisl => gpiol_0,
			trigVisr => gpior_0
		);

	------------------------------------------------------------------------
	-- implementation: master clock
	------------------------------------------------------------------------

	process (extclk)
		variable i: natural range 0 to (fExtclk/fMclk)/2;
	begin
		if falling_edge(extclk) then
			i := i + 1;
			if i=(fExtclk/fMclk)/2 then
				mclk <= not mclk;
				i := 0;
			end if;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: reset
	------------------------------------------------------------------------

	-- IP impl.rst.wiring --- BEGIN
	reset <= '1' when stateRst=stateRstReset else '0';
	-- IP impl.rst.wiring --- END

	process (reqReset, mclk)
		variable i: natural range 0 to 16 := 0;
	begin
		if reqReset='1' then
			i := 0;
			stateRst <= stateRstReset;
		elsif rising_edge(mclk) then
			if stateRst=stateRstReset then
				i := i + 1;
				if i=16 then
					i := 0;
					stateRst <= stateRstRun;
				end if;
			end if;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Top;

