-- file Top.vhd
-- Top top_v1_0 top implementation
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
use work.Oled128x32_v1_0_lib.all;

entity Top is
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

		sw: in std_logic_vector(7 downto 0);

		JA: out std_logic_vector(7 downto 0);

		btnC: in std_logic;
		btnL: in std_logic;
		btnR: in std_logic;

		enRx: in std_logic;
		rx: in std_logic_vector(31 downto 0);
		strbRx: in std_logic;

		enTx: in std_logic;
		tx: out std_logic_vector(31 downto 0);
		strbTx: in std_logic;

		clk: in std_logic;
		snc: in std_logic;
		d1: in std_logic;
		d2: in std_logic;
		extsnc: out std_logic;

		oledVdd: out std_logic;
		oledVbat: out std_logic;
		oledRes: out std_logic;
		oledDc: out std_logic;
		oledSclk: out std_logic;
		oledSdin: out std_logic;

		JC: out std_logic_vector(7 downto 0);

		nce: out std_logic;
		noe: out std_logic;
		nwe: out std_logic;

		a: out std_logic_vector(18 downto 0);
		d: inout std_logic_vector(7 downto 0);

		JB: out std_logic_vector(7 downto 0);

		JD: out std_logic_vector(7 downto 0)
	);
end Top;

architecture Top of Top is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Alua is
		port (
			reset: in std_logic;
			mclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			btn: in std_logic;

			r0_out: out std_logic_vector(63 downto 0);
			r1_out: out std_logic_vector(63 downto 0)
		);
	end component;

	component Alub is
		port (
			reset: in std_logic;
			mclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			btn: in std_logic;

			r0_out: out std_logic_vector(63 downto 0);
			r1_out: out std_logic_vector(63 downto 0)
		);
	end component;

	component Cmdbus is
		generic (
			fMclk: natural range 1 to 1000000 := 50000;
			fClk: natural range 1 to 100000 := 12500
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			clk: out std_logic;

			rdy: in std_logic_vector(23 downto 0);

			req: in std_logic_vector(23 downto 0);
			ack: out std_logic_vector(23 downto 0)
		);
	end component;

	component Cmdinv is
		port (
			reset: in std_logic;
			mclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			reqCmdbusToAlua: out std_logic;
			wrCmdbusToAlua: in std_logic;

			reqCmdbusToAlub: out std_logic;
			wrCmdbusToAlub: in std_logic;

			reqCmdbusToDcxif: out std_logic;
			wrCmdbusToDcxif: in std_logic;

			reqCmdbusToLwiracq: out std_logic;
			wrCmdbusToLwiracq: in std_logic;

			reqCmdbusToLwiremu: out std_logic;
			wrCmdbusToLwiremu: in std_logic;

			reqCmdbusToPhiif: out std_logic;
			wrCmdbusToPhiif: in std_logic;

			reqCmdbusToPmmu: out std_logic;
			wrCmdbusToPmmu: in std_logic;

			reqCmdbusToQcdif: out std_logic;
			wrCmdbusToQcdif: in std_logic;

			reqCmdbusToThetaif: out std_logic;
			wrCmdbusToThetaif: in std_logic;

			reqCmdbusToTkclksrc: out std_logic;
			wrCmdbusToTkclksrc: in std_logic;

			reqCmdbusToTrigger: out std_logic;
			wrCmdbusToTrigger: in std_logic;

			reqBufFromHostif: in std_logic;
			ackBufFromHostif: out std_logic;
			dneBufFromHostif: in std_logic;

			avllenBufFromHostif: out std_logic_vector(5 downto 0);

			dBufFromHostif: in std_logic_vector(7 downto 0);
			strbDBufFromHostif: in std_logic
		);
	end component;

	component Cmdret is
		port (
			reset: in std_logic;
			mclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: in std_logic_vector(7 downto 0);

			rdyCmdbusFromAlua: out std_logic;
			rdCmdbusFromAlua: in std_logic;

			rdyCmdbusFromAlub: out std_logic;
			rdCmdbusFromAlub: in std_logic;

			rdyCmdbusFromDcxif: out std_logic;
			rdCmdbusFromDcxif: in std_logic;

			rdyCmdbusFromLwiracq: out std_logic;
			rdCmdbusFromLwiracq: in std_logic;

			rdyCmdbusFromPhiif: out std_logic;
			rdCmdbusFromPhiif: in std_logic;

			rdyCmdbusFromPmmu: out std_logic;
			rdCmdbusFromPmmu: in std_logic;

			rdyCmdbusFromQcdif: out std_logic;
			rdCmdbusFromQcdif: in std_logic;

			rdyCmdbusFromThetaif: out std_logic;
			rdCmdbusFromThetaif: in std_logic;

			rdyCmdbusFromTkclksrc: out std_logic;
			rdCmdbusFromTkclksrc: in std_logic;

			reqBufToHostif: in std_logic;
			ackBufToHostif: out std_logic;
			dneBufToHostif: in std_logic;

			avllenBufToHostif: out std_logic_vector(7 downto 0);

			dBufToHostif: out std_logic_vector(7 downto 0);
			strbDBufToHostif: in std_logic
		);
	end component;

	component Dcxif is
		generic (
			fMclk: natural range 1 to 1000000 := 50000;

			dtPing: natural range 0 to 10000 := 1000;
			Nretry: natural range 1 to 5 := 3
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			fastclk: in std_logic;
			tkclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			reqWrbufFromHostif: in std_logic;
			ackWrbufFromHostif: out std_logic;
			dneWrbufFromHostif: in std_logic;

			avllenWrbufFromHostif: out std_logic_vector(10 downto 0);

			dWrbufFromHostif: in std_logic_vector(7 downto 0);
			strbDWrbufFromHostif: in std_logic;

			reqRdbufToHostif: in std_logic;
			ackRdbufToHostif: out std_logic;
			dneRdbufToHostif: in std_logic;

			avllenRdbufToHostif: out std_logic_vector(10 downto 0);

			dRdbufToHostif: out std_logic_vector(7 downto 0);
			strbDRdbufToHostif: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Debounce_v1_0 is
		generic (
			tdead: natural range 1 to 10000 := 100
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			noisy: in std_logic;
			clean: out std_logic
		);
	end component;

	component Hostif is
		port (
			reset: in std_logic;
			mclk: in std_logic;
			fastclk: in std_logic;
			tkclk: in std_logic;
			commok: out std_logic;
			reqReset: out std_logic;

			reqBufToCmdinv: out std_logic;
			ackBufToCmdinv: in std_logic;
			dneBufToCmdinv: out std_logic;

			avllenBufToCmdinv: in std_logic_vector(5 downto 0);

			dBufToCmdinv: out std_logic_vector(7 downto 0);
			strbDBufToCmdinv: out std_logic;

			reqBufFromCmdret: out std_logic;
			ackBufFromCmdret: in std_logic;
			dneBufFromCmdret: out std_logic;

			avllenBufFromCmdret: in std_logic_vector(7 downto 0);

			dBufFromCmdret: in std_logic_vector(7 downto 0);
			strbDBufFromCmdret: out std_logic;

			reqWrbufToDcxif: out std_logic;
			ackWrbufToDcxif: in std_logic;
			dneWrbufToDcxif: out std_logic;

			avllenWrbufToDcxif: in std_logic_vector(10 downto 0);

			dWrbufToDcxif: out std_logic_vector(7 downto 0);
			strbDWrbufToDcxif: out std_logic;

			reqRdbufFromDcxif: out std_logic;
			ackRdbufFromDcxif: in std_logic;
			dneRdbufFromDcxif: out std_logic;

			avllenRdbufFromDcxif: in std_logic_vector(10 downto 0);

			dRdbufFromDcxif: in std_logic_vector(7 downto 0);
			strbDRdbufFromDcxif: out std_logic;

			reqWrbufToQcdif: out std_logic;
			ackWrbufToQcdif: in std_logic;
			dneWrbufToQcdif: out std_logic;

			avllenWrbufToQcdif: in std_logic_vector(10 downto 0);

			dWrbufToQcdif: out std_logic_vector(7 downto 0);
			strbDWrbufToQcdif: out std_logic;

			reqRdbufFromQcdif: out std_logic;
			ackRdbufFromQcdif: in std_logic;
			dneRdbufFromQcdif: out std_logic;

			avllenRdbufFromQcdif: in std_logic_vector(10 downto 0);

			dRdbufFromQcdif: in std_logic_vector(7 downto 0);
			strbDRdbufFromQcdif: out std_logic;

			reqOutbuf0FromPmmu: out std_logic;
			ackOutbuf0FromPmmu: in std_logic;
			dneOutbuf0FromPmmu: out std_logic;

			avllenOutbuf0FromPmmu: in std_logic_vector(18 downto 0);

			dOutbuf0FromPmmu: in std_logic_vector(7 downto 0);
			strbDOutbuf0FromPmmu: out std_logic;

			enRx: in std_logic;
			rx: in std_logic_vector(31 downto 0);
			strbRx: in std_logic;

			enTx: in std_logic;
			tx: out std_logic_vector(31 downto 0);
			strbTx: in std_logic
		);
	end component;

	component Lwiracq is
		port (
			reset: in std_logic;
			mclk: in std_logic;
			fastclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			reqCmdbusToPmmu: out std_logic;
			wrCmdbusToPmmu: in std_logic;

			reqCmdbusToTkclksrc: out std_logic;
			wrCmdbusToTkclksrc: in std_logic;

			rdyCmdbusFromPmmu: out std_logic;
			rdCmdbusFromPmmu: in std_logic;

			rdyCmdbusFromTkclksrc: out std_logic;
			rdCmdbusFromTkclksrc: in std_logic;

			clkInbuf0ToPmmu: out std_logic;

			reqInbuf0ToPmmu: out std_logic;
			ackInbuf0ToPmmu: in std_logic;
			dneInbuf0ToPmmu: out std_logic;

			avllenInbuf0ToPmmu: in std_logic_vector(18 downto 0);

			dInbuf0ToPmmu: out std_logic_vector(7 downto 0);
			strbDInbuf0ToPmmu: out std_logic;

			trigLwir: in std_logic;

			clk: in std_logic;
			snc: in std_logic;
			d1: in std_logic;
			d2: in std_logic;
			extsnc: out std_logic
		);
	end component;

	component Lwiremu is
		generic (
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			fastclk: in std_logic;
			tkclk: in std_logic;

			lw_clk_wrp: out std_logic;
			lw_snc_wrp: out std_logic;
			lw_d1_wrp: out std_logic;
			lw_d2_wrp: out std_logic;
			lw_extsnc_wrp: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: in std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			rowsqr_out: out std_logic_vector(19 downto 0);
			colsqr_out: out std_logic_vector(19 downto 0);
			rsqr_out: out std_logic_vector(19 downto 0)
		);
	end component;

	component Oled128x32_v1_0 is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;

			textNotBitmap: std_logic := '0';
			numNotChar: std_logic := '0';
			binNotHex: std_logic := '0';

			Tfrm: natural range 10 to 1000 := 100
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;
			run: in std_logic;

			bitmap: in bitmap32x128_t;
			char: in char4x20_t;
			hex: in hex4x16_t;
			bin: in bin4x16_t;

			vdd: out std_logic;
			vbat: out std_logic;

			nres: out std_logic;
			dNotC: out std_logic;

			sclk: out std_logic;
			mosi: out std_logic
		);
	end component;

	component Phiif is
		generic (
			fMclk: natural range 1 to 1000000 := 50000;

			dtPing: natural range 0 to 10000 := 1000;
			Nretry: natural range 1 to 5 := 3
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			fastclk: in std_logic;
			tkclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Pmmu_v1_0_120x4kB_8sl is
		port (
			reset: in std_logic;
			mclk: in std_logic;
			fastclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			rdyCmdbusFromLwiracq: out std_logic;
			rdCmdbusFromLwiracq: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			reqCmdbusToLwiracq: out std_logic;
			wrCmdbusToLwiracq: in std_logic;

			clkInbuf0FromLwiracq: in std_logic;
			clkOutbuf0ToHostif: in std_logic;

			reqInbuf0FromLwiracq: in std_logic;
			ackInbuf0FromLwiracq: out std_logic;
			dneInbuf0FromLwiracq: in std_logic;

			avllenInbuf0FromLwiracq: out std_logic_vector(18 downto 0);

			dInbuf0FromLwiracq: in std_logic_vector(7 downto 0);
			strbDInbuf0FromLwiracq: in std_logic;

			reqOutbuf0ToHostif: in std_logic;
			ackOutbuf0ToHostif: out std_logic;
			dneOutbuf0ToHostif: in std_logic;

			avllenOutbuf0ToHostif: out std_logic_vector(18 downto 0);

			dOutbuf0ToHostif: out std_logic_vector(7 downto 0);
			strbDOutbuf0ToHostif: in std_logic;

			nce: out std_logic;
			noe: out std_logic;
			nwe: out std_logic;

			a: out std_logic_vector(18 downto 0);
			d: inout std_logic_vector(7 downto 0)
		);
	end component;

	component Qcdif is
		generic (
			fMclk: natural range 1 to 1000000 := 50000;

			dtPing: natural range 0 to 10000 := 1000;
			Nretry: natural range 1 to 5 := 3
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			fastclk: in std_logic;
			tkclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			reqWrbufFromHostif: in std_logic;
			ackWrbufFromHostif: out std_logic;
			dneWrbufFromHostif: in std_logic;

			avllenWrbufFromHostif: out std_logic_vector(10 downto 0);

			dWrbufFromHostif: in std_logic_vector(7 downto 0);
			strbDWrbufFromHostif: in std_logic;

			reqRdbufToHostif: in std_logic;
			ackRdbufToHostif: out std_logic;
			dneRdbufToHostif: in std_logic;

			avllenRdbufToHostif: out std_logic_vector(10 downto 0);

			dRdbufToHostif: out std_logic_vector(7 downto 0);
			strbDRdbufToHostif: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Thetaif is
		generic (
			fMclk: natural range 1 to 1000000 := 50000;

			dtPing: natural range 0 to 10000 := 1000;
			Nretry: natural range 1 to 5 := 3
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			fastclk: in std_logic;
			tkclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Tkclksrc is
		generic (
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: out std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			rdyCmdbusFromLwiracq: out std_logic;
			rdCmdbusFromLwiracq: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			reqCmdbusToLwiracq: out std_logic;
			wrCmdbusToLwiracq: in std_logic
		);
	end component;

	component Trigger is
		generic (
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: in std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			btn: in std_logic;
			trigLwir: out std_logic;
			rng: out std_logic;
			mtrig: out std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- master clock (mclk)

	signal mclk, mclk_sig: std_logic;

	---- reset (rst)
	type stateRst_t is (
		stateRstReset,
		stateRstRun
	);
	signal stateRst, stateRst_next: stateRst_t := stateRstReset;

	signal reset: std_logic;

	---- myAlua
	signal aluaR0: std_logic_vector(63 downto 0);
	signal aluaR1: std_logic_vector(63 downto 0);

	---- myAlub
	signal alubR0: std_logic_vector(63 downto 0);
	signal alubR1: std_logic_vector(63 downto 0);

	---- myBufgExtclk
	signal extclk_psb: std_logic;

	---- myCmdbus
	signal clkCmdbus, clkCmdbus_sig: std_logic;
	signal ackCmdbus: std_logic_vector(23 downto 0);

	---- myCmdinv
	signal avllenBufHostifToCmdinv: std_logic_vector(5 downto 0);

	---- myCmdret
	signal avllenBufCmdretToHostif: std_logic_vector(7 downto 0);

	signal dBufCmdretToHostif: std_logic_vector(7 downto 0);

	---- myDcxif
	signal avllenWrbufHostifToDcxif: std_logic_vector(10 downto 0);
	signal avllenRdbufDcxifToHostif: std_logic_vector(10 downto 0);

	signal dRdbufDcxifToHostif: std_logic_vector(7 downto 0);

	---- myDebounceBtnc
	signal btnC_sig: std_logic;

	---- myDebounceBtnl
	signal btnL_sig: std_logic;

	---- myDebounceBtnr
	signal btnR_sig: std_logic;

	---- myHostif
	signal commok: std_logic;

	signal avlbx: std_logic_vector(7 downto 0);
	signal reqbx: std_logic_vector(7 downto 0);
	signal arbbx: std_logic_vector(7 downto 0);

	signal avllen: std_logic_vector(31 downto 0);
	signal reqlen: std_logic_vector(31 downto 0);
	signal arblen: std_logic_vector(31 downto 0);

	signal crc: std_logic_vector(15 downto 0);
	signal crcRxbuf: std_logic_vector(15 downto 0);

	signal hoststateOp: std_logic_vector(15 downto 0);
	signal xfertkn: std_logic_vector(15 downto 0);

	signal dBufHostifToCmdinv: std_logic_vector(7 downto 0);
	signal strbDBufHostifToCmdinv: std_logic;

	signal strbDBufCmdretToHostif: std_logic;

	signal dWrbufHostifToDcxif: std_logic_vector(7 downto 0);
	signal strbDWrbufHostifToDcxif: std_logic;

	signal strbDRdbufDcxifToHostif: std_logic;

	signal dWrbufHostifToQcdif: std_logic_vector(7 downto 0);
	signal strbDWrbufHostifToQcdif: std_logic;

	signal strbDRdbufQcdifToHostif: std_logic;

	signal strbDOutbuf0PmmuToHostif: std_logic;

	---- myLwiracq
	signal clkInbuf0LwiracqToPmmu: std_logic;
	signal lwiracqtkn: std_logic_vector(2 downto 0);

	signal lwircmdbuf: std_logic_vector(119 downto 0);
	signal lwircmdbuf_part: std_logic_vector(7 downto 0);

	signal dInbuf0LwiracqToPmmu: std_logic_vector(7 downto 0);
	signal strbDInbuf0LwiracqToPmmu: std_logic;

	---- myLwiremu
	signal rowsqr: std_logic_vector(19 downto 0);
	signal colsqr: std_logic_vector(19 downto 0);
	signal rsqr: std_logic_vector(19 downto 0);

	---- myPmmu
	signal pgbusy: std_logic_vector(0 to 39);
	signal avllenInbuf0LwiracqToPmmu: std_logic_vector(18 downto 0);
	signal avllenOutbuf0PmmuToHostif: std_logic_vector(18 downto 0);

	signal dOutbuf0PmmuToHostif: std_logic_vector(7 downto 0);

	---- myQcdif
	signal avllenWrbufHostifToQcdif: std_logic_vector(10 downto 0);
	signal avllenRdbufQcdifToHostif: std_logic_vector(10 downto 0);

	signal dRdbufQcdifToHostif: std_logic_vector(7 downto 0);

	---- myTkclksrc
	signal tkclk: std_logic;
	signal tkst: std_logic_vector(31 downto 0);

	signal tkcmdbuf: std_logic_vector(111 downto 0);

	signal tklenCmdbuf: std_logic_vector(7 downto 0);

	---- myTrigger
	signal trigLwir: std_logic;

	---- handshake
	-- myHostif to myCmdinv
	signal reqBufHostifToCmdinv: std_logic;
	signal ackBufHostifToCmdinv: std_logic;
	signal dneBufHostifToCmdinv: std_logic;

	-- myHostif to myCmdret
	signal reqBufCmdretToHostif: std_logic;
	signal ackBufCmdretToHostif: std_logic;
	signal dneBufCmdretToHostif: std_logic;

	-- myHostif to myDcxif
	signal reqWrbufHostifToDcxif: std_logic;
	signal ackWrbufHostifToDcxif: std_logic;
	signal dneWrbufHostifToDcxif: std_logic;

	-- myHostif to myDcxif
	signal reqRdbufDcxifToHostif: std_logic;
	signal ackRdbufDcxifToHostif: std_logic;
	signal dneRdbufDcxifToHostif: std_logic;

	-- myHostif to myQcdif
	signal reqWrbufHostifToQcdif: std_logic;
	signal ackWrbufHostifToQcdif: std_logic;
	signal dneWrbufHostifToQcdif: std_logic;

	-- myHostif to myQcdif
	signal reqRdbufQcdifToHostif: std_logic;
	signal ackRdbufQcdifToHostif: std_logic;
	signal dneRdbufQcdifToHostif: std_logic;

	-- myLwiracq to myPmmu
	signal reqInbuf0LwiracqToPmmu: std_logic;
	signal ackInbuf0LwiracqToPmmu: std_logic;
	signal dneInbuf0LwiracqToPmmu: std_logic;

	-- myHostif to myPmmu
	signal reqOutbuf0PmmuToHostif: std_logic;
	signal ackOutbuf0PmmuToHostif: std_logic;
	signal dneOutbuf0PmmuToHostif: std_logic;

	---- other
	signal reqReset: std_logic := '0';

	signal dCmdbus: std_logic_vector(7 downto 0) := x"00";
	signal rdyCmdbus: std_logic_vector(23 downto 0) := x"000000";
	signal reqCmdbus: std_logic_vector(23 downto 0) := x"000000";

	signal hex: hex4x16_t;

	signal aluaR0_part: std_logic_vector(15 downto 0);
	signal aluaR1_part: std_logic_vector(15 downto 0);
	signal alubR0_part: std_logic_vector(15 downto 0);
	signal alubR1_part: std_logic_vector(15 downto 0);

	signal tkcmdbuf_part: std_logic_vector(7 downto 0);

	signal JA_sig: std_logic_vector(7 downto 0) := x"00";
	signal JC_sig: std_logic_vector(7 downto 0) := x"00";
	signal JB_sig: std_logic_vector(7 downto 0) := x"00";
	signal JD_sig: std_logic_vector(7 downto 0) := x"00";
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myAlua : Alua
		port map (
			reset => reset,
			mclk => mclk_sig,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwZedbReqCmdbusAluaToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwZedbAckCmdbusAluaToCmdret),

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToAlua),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToAlua),

			btn => btnL_sig,

			r0_out => aluaR0,
			r1_out => aluaR1
		);

	myAlub : Alub
		port map (
			reset => reset,
			mclk => mclk_sig,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwZedbReqCmdbusAlubToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwZedbAckCmdbusAlubToCmdret),

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToAlub),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToAlub),

			btn => btnL_sig,

			r0_out => alubR0,
			r1_out => alubR1
		);

	myBufgClkCmdbus : BUFG
		port map (
			I => clkCmdbus,
			O => clkCmdbus_sig
		);

	myBufgExtclk : BUFG
		port map (
			I => extclk,
			O => extclk_psb
		);

	myBufgMclk : BUFG
		port map (
			I => mclk,
			O => mclk_sig
		);

	myCmdbus : Cmdbus
		generic map (
			fMclk => fMclk,
			fClk => 12500
		)
		port map (
			reset => reset,
			mclk => mclk_sig,
			clk => clkCmdbus,

			rdy => rdyCmdbus,

			req => reqCmdbus,
			ack => ackCmdbus
		);

	myCmdinv : Cmdinv
		port map (
			reset => reset,
			mclk => mclk_sig,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			reqCmdbusToAlua => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToAlua),
			wrCmdbusToAlua => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToAlua),

			reqCmdbusToAlub => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToAlub),
			wrCmdbusToAlub => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToAlub),

			reqCmdbusToDcxif => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToDcxif),
			wrCmdbusToDcxif => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToDcxif),

			reqCmdbusToLwiracq => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToLwiracq),
			wrCmdbusToLwiracq => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToLwiracq),

			reqCmdbusToLwiremu => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToLwiremu),
			wrCmdbusToLwiremu => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToLwiremu),

			reqCmdbusToPhiif => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToPhiif),
			wrCmdbusToPhiif => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToPhiif),

			reqCmdbusToPmmu => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToPmmu),
			wrCmdbusToPmmu => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToPmmu),

			reqCmdbusToQcdif => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToQcdif),
			wrCmdbusToQcdif => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToQcdif),

			reqCmdbusToThetaif => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToThetaif),
			wrCmdbusToThetaif => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToThetaif),

			reqCmdbusToTkclksrc => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToTkclksrc),
			wrCmdbusToTkclksrc => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToTkclksrc),

			reqCmdbusToTrigger => reqCmdbus(ixVSigIdhwZedbReqCmdbusCmdinvToTrigger),
			wrCmdbusToTrigger => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToTrigger),

			reqBufFromHostif => reqBufHostifToCmdinv,
			ackBufFromHostif => ackBufHostifToCmdinv,
			dneBufFromHostif => dneBufHostifToCmdinv,

			avllenBufFromHostif => avllenBufHostifToCmdinv,

			dBufFromHostif => dBufHostifToCmdinv,
			strbDBufFromHostif => strbDBufHostifToCmdinv
		);

	myCmdret : Cmdret
		port map (
			reset => reset,
			mclk => mclk_sig,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromAlua => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusAluaToCmdret),
			rdCmdbusFromAlua => ackCmdbus(ixVSigIdhwZedbAckCmdbusAluaToCmdret),

			rdyCmdbusFromAlub => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusAlubToCmdret),
			rdCmdbusFromAlub => ackCmdbus(ixVSigIdhwZedbAckCmdbusAlubToCmdret),

			rdyCmdbusFromDcxif => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusDcxifToCmdret),
			rdCmdbusFromDcxif => ackCmdbus(ixVSigIdhwZedbAckCmdbusDcxifToCmdret),

			rdyCmdbusFromLwiracq => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusLwiracqToCmdret),
			rdCmdbusFromLwiracq => ackCmdbus(ixVSigIdhwZedbAckCmdbusLwiracqToCmdret),

			rdyCmdbusFromPhiif => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusPhiifToCmdret),
			rdCmdbusFromPhiif => ackCmdbus(ixVSigIdhwZedbAckCmdbusPhiifToCmdret),

			rdyCmdbusFromPmmu => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusPmmuToCmdret),
			rdCmdbusFromPmmu => ackCmdbus(ixVSigIdhwZedbAckCmdbusPmmuToCmdret),

			rdyCmdbusFromQcdif => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusQcdifToCmdret),
			rdCmdbusFromQcdif => ackCmdbus(ixVSigIdhwZedbAckCmdbusQcdifToCmdret),

			rdyCmdbusFromThetaif => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusThetaifToCmdret),
			rdCmdbusFromThetaif => ackCmdbus(ixVSigIdhwZedbAckCmdbusThetaifToCmdret),

			rdyCmdbusFromTkclksrc => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusTkclksrcToCmdret),
			rdCmdbusFromTkclksrc => ackCmdbus(ixVSigIdhwZedbAckCmdbusTkclksrcToCmdret),

			reqBufToHostif => reqBufCmdretToHostif,
			ackBufToHostif => ackBufCmdretToHostif,
			dneBufToHostif => dneBufCmdretToHostif,

			avllenBufToHostif => avllenBufCmdretToHostif,

			dBufToHostif => dBufCmdretToHostif,
			strbDBufToHostif => strbDBufCmdretToHostif
		);

	myDcxif : Dcxif
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToDcxif),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToDcxif),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwZedbReqCmdbusDcxifToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwZedbAckCmdbusDcxifToCmdret),

			reqWrbufFromHostif => reqWrbufHostifToDcxif,
			ackWrbufFromHostif => ackWrbufHostifToDcxif,
			dneWrbufFromHostif => dneWrbufHostifToDcxif,

			avllenWrbufFromHostif => avllenWrbufHostifToDcxif,

			dWrbufFromHostif => dWrbufHostifToDcxif,
			strbDWrbufFromHostif => strbDWrbufHostifToDcxif,

			reqRdbufToHostif => reqRdbufDcxifToHostif,
			ackRdbufToHostif => ackRdbufDcxifToHostif,
			dneRdbufToHostif => dneRdbufDcxifToHostif,

			avllenRdbufToHostif => avllenRdbufDcxifToHostif,

			dRdbufToHostif => dRdbufDcxifToHostif,
			strbDRdbufToHostif => strbDRdbufDcxifToHostif,

			nss => JA_sig(2),
			sclk => JA_sig(3),
			mosi => JA_sig(0),
			miso => JA_sig(1)
		);

	myDebounceBtnc : Debounce_v1_0
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			noisy => btnC,
			clean => btnC_sig
		);

	myDebounceBtnl : Debounce_v1_0
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			noisy => btnL,
			clean => btnL_sig
		);

	myDebounceBtnr : Debounce_v1_0
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			noisy => btnR,
			clean => btnR_sig
		);

	myHostif : Hostif
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,
			tkclk => tkclk,
			commok => commok,
			reqReset => reqReset,

			reqBufToCmdinv => reqBufHostifToCmdinv,
			ackBufToCmdinv => ackBufHostifToCmdinv,
			dneBufToCmdinv => dneBufHostifToCmdinv,

			avllenBufToCmdinv => avllenBufHostifToCmdinv,

			dBufToCmdinv => dBufHostifToCmdinv,
			strbDBufToCmdinv => strbDBufHostifToCmdinv,

			reqBufFromCmdret => reqBufCmdretToHostif,
			ackBufFromCmdret => ackBufCmdretToHostif,
			dneBufFromCmdret => dneBufCmdretToHostif,

			avllenBufFromCmdret => avllenBufCmdretToHostif,

			dBufFromCmdret => dBufCmdretToHostif,
			strbDBufFromCmdret => strbDBufCmdretToHostif,

			reqWrbufToDcxif => reqWrbufHostifToDcxif,
			ackWrbufToDcxif => ackWrbufHostifToDcxif,
			dneWrbufToDcxif => dneWrbufHostifToDcxif,

			avllenWrbufToDcxif => avllenWrbufHostifToDcxif,

			dWrbufToDcxif => dWrbufHostifToDcxif,
			strbDWrbufToDcxif => strbDWrbufHostifToDcxif,

			reqRdbufFromDcxif => reqRdbufDcxifToHostif,
			ackRdbufFromDcxif => ackRdbufDcxifToHostif,
			dneRdbufFromDcxif => dneRdbufDcxifToHostif,

			avllenRdbufFromDcxif => avllenRdbufDcxifToHostif,

			dRdbufFromDcxif => dRdbufDcxifToHostif,
			strbDRdbufFromDcxif => strbDRdbufDcxifToHostif,

			reqWrbufToQcdif => reqWrbufHostifToQcdif,
			ackWrbufToQcdif => ackWrbufHostifToQcdif,
			dneWrbufToQcdif => dneWrbufHostifToQcdif,

			avllenWrbufToQcdif => avllenWrbufHostifToQcdif,

			dWrbufToQcdif => dWrbufHostifToQcdif,
			strbDWrbufToQcdif => strbDWrbufHostifToQcdif,

			reqRdbufFromQcdif => reqRdbufQcdifToHostif,
			ackRdbufFromQcdif => ackRdbufQcdifToHostif,
			dneRdbufFromQcdif => dneRdbufQcdifToHostif,

			avllenRdbufFromQcdif => avllenRdbufQcdifToHostif,

			dRdbufFromQcdif => dRdbufQcdifToHostif,
			strbDRdbufFromQcdif => strbDRdbufQcdifToHostif,

			reqOutbuf0FromPmmu => reqOutbuf0PmmuToHostif,
			ackOutbuf0FromPmmu => ackOutbuf0PmmuToHostif,
			dneOutbuf0FromPmmu => dneOutbuf0PmmuToHostif,

			avllenOutbuf0FromPmmu => avllenOutbuf0PmmuToHostif,

			dOutbuf0FromPmmu => dOutbuf0PmmuToHostif,
			strbDOutbuf0FromPmmu => strbDOutbuf0PmmuToHostif,

			enRx => enRx,
			rx => rx,
			strbRx => strbRx,

			enTx => enTx,
			tx => tx,
			strbTx => strbTx
		);

	myLwiracq : Lwiracq
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToLwiracq),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToLwiracq),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwZedbReqCmdbusLwiracqToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwZedbAckCmdbusLwiracqToCmdret),

			reqCmdbusToPmmu => reqCmdbus(ixVSigIdhwZedbReqCmdbusLwiracqToPmmu),
			wrCmdbusToPmmu => ackCmdbus(ixVSigIdhwZedbAckCmdbusLwiracqToPmmu),

			reqCmdbusToTkclksrc => reqCmdbus(ixVSigIdhwZedbReqCmdbusLwiracqToTkclksrc),
			wrCmdbusToTkclksrc => ackCmdbus(ixVSigIdhwZedbAckCmdbusLwiracqToTkclksrc),

			rdyCmdbusFromPmmu => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusPmmuToLwiracq),
			rdCmdbusFromPmmu => ackCmdbus(ixVSigIdhwZedbAckCmdbusPmmuToLwiracq),

			rdyCmdbusFromTkclksrc => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusTkclksrcToLwiracq),
			rdCmdbusFromTkclksrc => ackCmdbus(ixVSigIdhwZedbAckCmdbusTkclksrcToLwiracq),

			clkInbuf0ToPmmu => clkInbuf0LwiracqToPmmu,

			reqInbuf0ToPmmu => reqInbuf0LwiracqToPmmu,
			ackInbuf0ToPmmu => ackInbuf0LwiracqToPmmu,
			dneInbuf0ToPmmu => dneInbuf0LwiracqToPmmu,

			avllenInbuf0ToPmmu => avllenInbuf0LwiracqToPmmu,

			dInbuf0ToPmmu => dInbuf0LwiracqToPmmu,
			strbDInbuf0ToPmmu => strbDInbuf0LwiracqToPmmu,

			trigLwir => trigLwir,

			clk => clk,
			snc => snc,
			d1 => d1,
			d2 => d2,
			extsnc => extsnc
		);

	myLwiremu : Lwiremu
		generic map (
			fMclk => fMclk -- in kHz
		)
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,
			tkclk => tkclk,

			lw_clk_wrp => lw_clk_wrp,
			lw_snc_wrp => lw_snc_wrp,
			lw_d1_wrp => lw_d1_wrp,
			lw_d2_wrp => lw_d2_wrp,
			lw_extsnc_wrp => lw_extsnc_wrp,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToLwiremu),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToLwiremu),

			rowsqr_out => rowsqr,
			colsqr_out => colsqr,
			rsqr_out => rsqr
		);

	myOled128x32 : Oled128x32_v1_0
		generic map (
			fMclk => fMclk
		)
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,
			run => '1',

			bitmap => (x"AAAA9249FFFF9249AAAA9249FFFF9249", x"AAAA492400002492AAAA492400002492", x"AAAA2492FFFF4924AAAA2492FFFF4924", x"AAAA924900009249AAAA924900009249", x"AAAA4924FFFF2492AAAA4924FFFF2492", x"AAAA249200004924AAAA249200004924", x"AAAA9249FFFF9249AAAA9249FFFF9249", x"AAAA492400002492AAAA492400002492", x"AAAA2492FFFF4924AAAA2492FFFF4924", x"AAAA924900009249AAAA924900009249", x"AAAA4924FFFF2492AAAA4924FFFF2492", x"AAAA249200004924AAAA249200004924", x"AAAA9249FFFF9249AAAA9249FFFF9249", x"AAAA492400002492AAAA492400002492", x"AAAA2492FFFF4924AAAA2492FFFF4924", x"AAAA924900009249AAAA924900009249", x"FFFF9249AAAA9249FFFF9249AAAA9249", x"00002492AAAA492400002492AAAA4924", x"FFFF4924AAAA2492FFFF4924AAAA2492", x"00009249AAAA924900009249AAAA9249", x"FFFF2492AAAA4924FFFF2492AAAA4924", x"00004924AAAA249200004924AAAA2492", x"FFFF9249AAAA9249FFFF9249AAAA9249", x"00002492AAAA492400002492AAAA4924", x"FFFF4924AAAA2492FFFF4924AAAA2492", x"00009249AAAA924900009249AAAA9249", x"FFFF2492AAAA4924FFFF2492AAAA4924", x"00004924AAAA249200004924AAAA2492", x"FFFF9249AAAA9249FFFF9249AAAA9249", x"00002492AAAA492400002492AAAA4924", x"FFFF4924AAAA2492FFFF4924AAAA2492", x"00009249AAAA924900009249AAAA9249"),
			char => (('W',' ','H',' ','I',' ','Z',' ','N',' ','I',' ','U',' ','M','/','/','D','B','E'),('(','C',')',' ','2','0','1','7',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),('M','p','s','i',' ','T','e','c','h','n','o','l','o','g','i','e','s',' ',' ',' '),('M','u','n','i','c','h',',',' ','G','e','r','m','a','n','y',' ',' ',' ',' ',' ')),
			hex => hex,
			bin => (x"0000", x"0000", x"0000", x"0000"),

			vdd => oledVdd,
			vbat => oledVbat,

			nres => oledRes,
			dNotC => oledDc,

			sclk => oledSclk,
			mosi => oledSdin
		);

	myPhiif : Phiif
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToPhiif),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToPhiif),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwZedbReqCmdbusPhiifToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwZedbAckCmdbusPhiifToCmdret),

			nss => JC_sig(2),
			sclk => JC_sig(3),
			mosi => JC_sig(0),
			miso => JC_sig(1)
		);

	myPmmu : Pmmu_v1_0_120x4kB_8sl
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToPmmu),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToPmmu),

			rdyCmdbusFromLwiracq => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusLwiracqToPmmu),
			rdCmdbusFromLwiracq => ackCmdbus(ixVSigIdhwZedbAckCmdbusLwiracqToPmmu),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwZedbReqCmdbusPmmuToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwZedbAckCmdbusPmmuToCmdret),

			reqCmdbusToLwiracq => reqCmdbus(ixVSigIdhwZedbReqCmdbusPmmuToLwiracq),
			wrCmdbusToLwiracq => ackCmdbus(ixVSigIdhwZedbAckCmdbusPmmuToLwiracq),

			clkInbuf0FromLwiracq => clkInbuf0LwiracqToPmmu,
			clkOutbuf0ToHostif => mclk_sig,

			reqInbuf0FromLwiracq => reqInbuf0LwiracqToPmmu,
			ackInbuf0FromLwiracq => ackInbuf0LwiracqToPmmu,
			dneInbuf0FromLwiracq => dneInbuf0LwiracqToPmmu,

			avllenInbuf0FromLwiracq => avllenInbuf0LwiracqToPmmu,

			dInbuf0FromLwiracq => dInbuf0LwiracqToPmmu,
			strbDInbuf0FromLwiracq => strbDInbuf0LwiracqToPmmu,

			reqOutbuf0ToHostif => reqOutbuf0PmmuToHostif,
			ackOutbuf0ToHostif => ackOutbuf0PmmuToHostif,
			dneOutbuf0ToHostif => dneOutbuf0PmmuToHostif,

			avllenOutbuf0ToHostif => avllenOutbuf0PmmuToHostif,

			dOutbuf0ToHostif => dOutbuf0PmmuToHostif,
			strbDOutbuf0ToHostif => strbDOutbuf0PmmuToHostif,

			nce => nce,
			noe => noe,
			nwe => nwe,

			a => a,
			d => d
		);

	myQcdif : Qcdif
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToQcdif),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToQcdif),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwZedbReqCmdbusQcdifToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwZedbAckCmdbusQcdifToCmdret),

			reqWrbufFromHostif => reqWrbufHostifToQcdif,
			ackWrbufFromHostif => ackWrbufHostifToQcdif,
			dneWrbufFromHostif => dneWrbufHostifToQcdif,

			avllenWrbufFromHostif => avllenWrbufHostifToQcdif,

			dWrbufFromHostif => dWrbufHostifToQcdif,
			strbDWrbufFromHostif => strbDWrbufHostifToQcdif,

			reqRdbufToHostif => reqRdbufQcdifToHostif,
			ackRdbufToHostif => ackRdbufQcdifToHostif,
			dneRdbufToHostif => dneRdbufQcdifToHostif,

			avllenRdbufToHostif => avllenRdbufQcdifToHostif,

			dRdbufToHostif => dRdbufQcdifToHostif,
			strbDRdbufToHostif => strbDRdbufQcdifToHostif,

			nss => JB_sig(2),
			sclk => JB_sig(3),
			mosi => JB_sig(0),
			miso => JB_sig(1)
		);

	myThetaif : Thetaif
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToThetaif),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToThetaif),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwZedbReqCmdbusThetaifToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwZedbAckCmdbusThetaifToCmdret),

			nss => JD_sig(2),
			sclk => JD_sig(3),
			mosi => JD_sig(0),
			miso => JD_sig(1)
		);

	myTkclksrc : Tkclksrc
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToTkclksrc),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToTkclksrc),

			rdyCmdbusFromLwiracq => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusLwiracqToTkclksrc),
			rdCmdbusFromLwiracq => ackCmdbus(ixVSigIdhwZedbAckCmdbusLwiracqToTkclksrc),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwZedbReqCmdbusTkclksrcToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwZedbAckCmdbusTkclksrcToCmdret),

			reqCmdbusToLwiracq => reqCmdbus(ixVSigIdhwZedbReqCmdbusTkclksrcToLwiracq),
			wrCmdbusToLwiracq => ackCmdbus(ixVSigIdhwZedbAckCmdbusTkclksrcToLwiracq)
		);

	myTrigger : Trigger
		generic map (
			fMclk => fMclk -- in kHz
		)
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwZedbRdyCmdbusCmdinvToTrigger),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwZedbAckCmdbusCmdinvToTrigger),

			btn => btnC_sig,
			trigLwir => trigLwir,
			rng => open,
			mtrig => open
		);

	------------------------------------------------------------------------
	-- implementation: master clock (mclk)
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
	-- implementation: reset (rst)
	------------------------------------------------------------------------

	-- IP impl.rst.wiring --- BEGIN
	reset <= '0' when stateRst=stateRstReset else '1';
	-- IP impl.rst.wiring --- END

	process (reqReset, mclk_sig)
		variable i: natural range 0 to 16 := 0;
	begin
		if reqReset='1' then
			i := 0;
			stateRst <= stateRstReset;
		elsif rising_edge(mclk_sig) then
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

	JA <= JA_sig;
	JC <= JC_sig;
	JB <= JB_sig;
	JD <= JD_sig;
	
	-- IP impl.oth.cust --- IBEGIN
	--JA_sig(4) <= enTx;--clkCmdbus;
	--JA_sig(5) <= strbTx;--reqCmdbus(10); -- reqCmdbusCmdinvToTkclksrc
	--JA_sig(6) <= enTx;--ackCmdbus(10); -- wrCmdbusCmdinvToTkclksrc
	--JA_sig(7) <= ackCmdbus(16); -- wrCmdbufTkclksrcToCmdret

	--JB_sig(4) <= enRx;
	--JB_sig(5) <= strbRx;

	hex <= (aluaR0, aluaR1, alubR0, alubR1) when sw(3 downto 0)="0000"

		else (x"00000000" & "000" & reqCmdbus(23) & "000" & reqCmdbus(22) & "000" & reqCmdbus(21) & "000" & reqCmdbus(20) & "000" & reqCmdbus(19) & "000" & reqCmdbus(18) & "000" & reqCmdbus(17) & "000" & reqCmdbus(16),
			"000" & reqCmdbus(15) & "000" & reqCmdbus(14) & "000" & reqCmdbus(13) & "000" & reqCmdbus(12) & "000" & reqCmdbus(11) & "000" & reqCmdbus(10) & "000" & reqCmdbus(9) & "000" & reqCmdbus(8)
			& "000" & reqCmdbus(7) & "000" & reqCmdbus(6) & "000" & reqCmdbus(5) & "000" & reqCmdbus(4) & "000" & reqCmdbus(3) & "000" & reqCmdbus(2) & "000" & reqCmdbus(1) & "000" & reqCmdbus(0),
			x"00000000" & "000" & rdyCmdbus(23) & "000" & rdyCmdbus(22) & "000" & rdyCmdbus(21) & "000" & rdyCmdbus(20) & "000" & rdyCmdbus(19) & "000" & rdyCmdbus(18) & "000" & rdyCmdbus(17) & "000" & rdyCmdbus(16),
			"000" & rdyCmdbus(15) & "000" & rdyCmdbus(14) & "000" & rdyCmdbus(13) & "000" & rdyCmdbus(12) & "000" & rdyCmdbus(11) & "000" & rdyCmdbus(10) & "000" & rdyCmdbus(9) & "000" & rdyCmdbus(8)
			& "000" & rdyCmdbus(7) & "000" & rdyCmdbus(6) & "000" & rdyCmdbus(5) & "000" & rdyCmdbus(4) & "000" & rdyCmdbus(3) & "000" & rdyCmdbus(2) & "000" & rdyCmdbus(1) & "000" & rdyCmdbus(0)
		) when sw(3 downto 0)="0001"

		else (x"00000000" & "000" & avlbx(7) & "000" & avlbx(6) & "000" & avlbx(5) & "000" & avlbx(4) & "000" & avlbx(3) & "000" & avlbx(2) & "000" & avlbx(1) & "000" & avlbx(0),
			x"00000000" & "000" & reqbx(7) & "000" & reqbx(6) & "000" & reqbx(5) & "000" & reqbx(4) & "000" & reqbx(3) & "000" & reqbx(2) & "000" & reqbx(1) & "000" & reqbx(0),
			x"000000000000" & crc, x"000000000000" & crcRxbuf) when sw(3 downto 0)="0010"

		else (x"00000000" & tkst, x"00000000000000" & tklenCmdbuf, x"0000" & tkcmdbuf(111 downto 64), tkcmdbuf(63 downto 0)) when sw(3 downto 0)="0011"
		
		else (x"0000" & hoststateOp & x"0000" & xfertkn, x"00000000" & reqlen, x"00000000" & avllen, x"00000000" & arblen) when sw(3 downto 0)="0100"

		else (x"0000000000000000", x"0000000000000000", x"0000000000000000", x"0000000000000000");
	-- IP impl.oth.cust --- IEND

end Top;


