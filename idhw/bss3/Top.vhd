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
use work.Bss3.all;

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
		generic (
			fMclk: natural range 1 to 1000000 := 50000;
			fSclk: natural range 100 to 50000000 := 5000000
		);
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

			reqOutbuf0FromPmmu: out std_logic;
			ackOutbuf0FromPmmu: in std_logic;
			dneOutbuf0FromPmmu: out std_logic;

			avllenOutbuf0FromPmmu: in std_logic_vector(17 downto 0);

			dOutbuf0FromPmmu: in std_logic_vector(7 downto 0);
			strbDOutbuf0FromPmmu: out std_logic;

			rxd: in std_logic;
			txd: out std_logic
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

			avllenInbuf0ToPmmu: in std_logic_vector(17 downto 0);

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

	component Pmmu_v1_0_40x4kB_4sl is
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

			avllenInbuf0FromLwiracq: out std_logic_vector(17 downto 0);

			dInbuf0FromLwiracq: in std_logic_vector(7 downto 0);
			strbDInbuf0FromLwiracq: in std_logic;

			reqOutbuf0ToHostif: in std_logic;
			ackOutbuf0ToHostif: out std_logic;
			dneOutbuf0ToHostif: in std_logic;

			avllenOutbuf0ToHostif: out std_logic_vector(17 downto 0);

			dOutbuf0ToHostif: out std_logic_vector(7 downto 0);
			strbDOutbuf0ToHostif: in std_logic;

			nce: out std_logic;
			noe: out std_logic;
			nwe: out std_logic;

			a: out std_logic_vector(17 downto 0);
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

	component Quad7seg_v1_0 is
		port (
			reset: in std_logic;
			tkclk: in std_logic;
			d: in std_logic_vector(15 downto 0);

			ssa: out std_logic_vector(3 downto 0);
			sscdp: out std_logic;
			ssc: out std_logic_vector(6 downto 0)
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

	signal dWrbufHostifToQcdif: std_logic_vector(7 downto 0);
	signal strbDWrbufHostifToQcdif: std_logic;

	signal strbDRdbufQcdifToHostif: std_logic;

	signal dWrbufHostifToDcxif: std_logic_vector(7 downto 0);
	signal strbDWrbufHostifToDcxif: std_logic;

	signal strbDRdbufDcxifToHostif: std_logic;

	signal strbDOutbuf0PmmuToHostif: std_logic;

	---- myLwiracq
	signal clkInbuf0LwiracqToPmmu: std_logic;
	signal lwiracqtkn: std_logic_vector(2 downto 0);

	signal lwircmdbuf: std_logic_vector(119 downto 0);

	signal dInbuf0LwiracqToPmmu: std_logic_vector(7 downto 0);
	signal strbDInbuf0LwiracqToPmmu: std_logic;

	---- myLwiremu
	signal rowsqr: std_logic_vector(19 downto 0);
	signal colsqr: std_logic_vector(19 downto 0);
	signal rsqr: std_logic_vector(19 downto 0);

	---- myPmmu
	signal pgbusy: std_logic_vector(0 to 39);
	signal avllenInbuf0LwiracqToPmmu: std_logic_vector(17 downto 0);
	signal avllenOutbuf0PmmuToHostif: std_logic_vector(17 downto 0);

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

	-- myHostif to myQcdif
	signal reqWrbufHostifToQcdif: std_logic;
	signal ackWrbufHostifToQcdif: std_logic;
	signal dneWrbufHostifToQcdif: std_logic;

	-- myHostif to myQcdif
	signal reqRdbufQcdifToHostif: std_logic;
	signal ackRdbufQcdifToHostif: std_logic;
	signal dneRdbufQcdifToHostif: std_logic;

	-- myHostif to myDcxif
	signal reqWrbufHostifToDcxif: std_logic;
	signal ackWrbufHostifToDcxif: std_logic;
	signal dneWrbufHostifToDcxif: std_logic;

	-- myHostif to myDcxif
	signal reqRdbufDcxifToHostif: std_logic;
	signal ackRdbufDcxifToHostif: std_logic;
	signal dneRdbufDcxifToHostif: std_logic;

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

	signal dQuad7seg: std_logic_vector(15 downto 0) := x"0000";
	signal hex: std_logic_vector(15 downto 0);

	signal aluaR0_part: std_logic_vector(15 downto 0);
	signal aluaR1_part: std_logic_vector(15 downto 0);
	signal alubR0_part: std_logic_vector(15 downto 0);
	signal alubR1_part: std_logic_vector(15 downto 0);

	signal tkcmdbuf_part: std_logic_vector(7 downto 0);

	signal lwircmdbuf_part: std_logic_vector(7 downto 0);

	signal JA_sig: std_logic_vector(7 downto 0) := x"00";
	signal JC_sig: std_logic_vector(7 downto 0) := x"00";
	signal JB_sig: std_logic_vector(7 downto 0) := x"00";
	signal JXADC_sig: std_logic_vector(7 downto 0) := x"00";
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

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwBss3ReqCmdbusAluaToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwBss3AckCmdbusAluaToCmdret),

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToAlua),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToAlua),

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

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwBss3ReqCmdbusAlubToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwBss3AckCmdbusAlubToCmdret),

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToAlub),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToAlub),

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

			reqCmdbusToAlua => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToAlua),
			wrCmdbusToAlua => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToAlua),

			reqCmdbusToAlub => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToAlub),
			wrCmdbusToAlub => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToAlub),

			reqCmdbusToDcxif => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToDcxif),
			wrCmdbusToDcxif => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToDcxif),

			reqCmdbusToLwiracq => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToLwiracq),
			wrCmdbusToLwiracq => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToLwiracq),

			reqCmdbusToLwiremu => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToLwiremu),
			wrCmdbusToLwiremu => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToLwiremu),

			reqCmdbusToPhiif => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToPhiif),
			wrCmdbusToPhiif => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToPhiif),

			reqCmdbusToPmmu => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToPmmu),
			wrCmdbusToPmmu => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToPmmu),

			reqCmdbusToQcdif => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToQcdif),
			wrCmdbusToQcdif => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToQcdif),

			reqCmdbusToThetaif => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToThetaif),
			wrCmdbusToThetaif => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToThetaif),

			reqCmdbusToTkclksrc => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToTkclksrc),
			wrCmdbusToTkclksrc => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToTkclksrc),

			reqCmdbusToTrigger => reqCmdbus(ixVSigIdhwBss3ReqCmdbusCmdinvToTrigger),
			wrCmdbusToTrigger => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToTrigger),

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

			rdyCmdbusFromAlua => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusAluaToCmdret),
			rdCmdbusFromAlua => ackCmdbus(ixVSigIdhwBss3AckCmdbusAluaToCmdret),

			rdyCmdbusFromAlub => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusAlubToCmdret),
			rdCmdbusFromAlub => ackCmdbus(ixVSigIdhwBss3AckCmdbusAlubToCmdret),

			rdyCmdbusFromDcxif => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusDcxifToCmdret),
			rdCmdbusFromDcxif => ackCmdbus(ixVSigIdhwBss3AckCmdbusDcxifToCmdret),

			rdyCmdbusFromLwiracq => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusLwiracqToCmdret),
			rdCmdbusFromLwiracq => ackCmdbus(ixVSigIdhwBss3AckCmdbusLwiracqToCmdret),

			rdyCmdbusFromPhiif => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusPhiifToCmdret),
			rdCmdbusFromPhiif => ackCmdbus(ixVSigIdhwBss3AckCmdbusPhiifToCmdret),

			rdyCmdbusFromPmmu => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusPmmuToCmdret),
			rdCmdbusFromPmmu => ackCmdbus(ixVSigIdhwBss3AckCmdbusPmmuToCmdret),

			rdyCmdbusFromQcdif => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusQcdifToCmdret),
			rdCmdbusFromQcdif => ackCmdbus(ixVSigIdhwBss3AckCmdbusQcdifToCmdret),

			rdyCmdbusFromThetaif => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusThetaifToCmdret),
			rdCmdbusFromThetaif => ackCmdbus(ixVSigIdhwBss3AckCmdbusThetaifToCmdret),

			rdyCmdbusFromTkclksrc => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusTkclksrcToCmdret),
			rdCmdbusFromTkclksrc => ackCmdbus(ixVSigIdhwBss3AckCmdbusTkclksrcToCmdret),

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

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToDcxif),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToDcxif),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwBss3ReqCmdbusDcxifToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwBss3AckCmdbusDcxifToCmdret),

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
		generic map (
			fSclk => 5000000
		)
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

			reqOutbuf0FromPmmu => reqOutbuf0PmmuToHostif,
			ackOutbuf0FromPmmu => ackOutbuf0PmmuToHostif,
			dneOutbuf0FromPmmu => dneOutbuf0PmmuToHostif,

			avllenOutbuf0FromPmmu => avllenOutbuf0PmmuToHostif,

			dOutbuf0FromPmmu => dOutbuf0PmmuToHostif,
			strbDOutbuf0FromPmmu => strbDOutbuf0PmmuToHostif,

			rxd => RsRx,
			txd => RsTx
		);

	myLwiracq : Lwiracq
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToLwiracq),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToLwiracq),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwBss3ReqCmdbusLwiracqToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwBss3AckCmdbusLwiracqToCmdret),

			reqCmdbusToPmmu => reqCmdbus(ixVSigIdhwBss3ReqCmdbusLwiracqToPmmu),
			wrCmdbusToPmmu => ackCmdbus(ixVSigIdhwBss3AckCmdbusLwiracqToPmmu),

			reqCmdbusToTkclksrc => reqCmdbus(ixVSigIdhwBss3ReqCmdbusLwiracqToTkclksrc),
			wrCmdbusToTkclksrc => ackCmdbus(ixVSigIdhwBss3AckCmdbusLwiracqToTkclksrc),

			rdyCmdbusFromPmmu => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusPmmuToLwiracq),
			rdCmdbusFromPmmu => ackCmdbus(ixVSigIdhwBss3AckCmdbusPmmuToLwiracq),

			rdyCmdbusFromTkclksrc => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusTkclksrcToLwiracq),
			rdCmdbusFromTkclksrc => ackCmdbus(ixVSigIdhwBss3AckCmdbusTkclksrcToLwiracq),

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

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToLwiremu),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToLwiremu),

			rowsqr_out => rowsqr,
			colsqr_out => colsqr,
			rsqr_out => rsqr
		);

	myPhiif : Phiif
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToPhiif),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToPhiif),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwBss3ReqCmdbusPhiifToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwBss3AckCmdbusPhiifToCmdret),

			nss => JC_sig(2),
			sclk => JC_sig(3),
			mosi => JC_sig(0),
			miso => JC_sig(1)
		);

	myPmmu : Pmmu_v1_0_40x4kB_4sl
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToPmmu),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToPmmu),

			rdyCmdbusFromLwiracq => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusLwiracqToPmmu),
			rdCmdbusFromLwiracq => ackCmdbus(ixVSigIdhwBss3AckCmdbusLwiracqToPmmu),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwBss3ReqCmdbusPmmuToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwBss3AckCmdbusPmmuToCmdret),

			reqCmdbusToLwiracq => reqCmdbus(ixVSigIdhwBss3ReqCmdbusPmmuToLwiracq),
			wrCmdbusToLwiracq => ackCmdbus(ixVSigIdhwBss3AckCmdbusPmmuToLwiracq),

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

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToQcdif),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToQcdif),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwBss3ReqCmdbusQcdifToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwBss3AckCmdbusQcdifToCmdret),

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

	myQuad7seg : Quad7seg_v1_0
		port map (
			reset => reset,
			tkclk => tkclk,
			d => dQuad7seg,

			ssa => an,
			sscdp => dp,
			ssc => seg
		);

	myThetaif : Thetaif
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk_psb,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToThetaif),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToThetaif),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwBss3ReqCmdbusThetaifToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwBss3AckCmdbusThetaifToCmdret),

			nss => JXADC_sig(2),
			sclk => JXADC_sig(3),
			mosi => JXADC_sig(0),
			miso => JXADC_sig(1)
		);

	myTkclksrc : Tkclksrc
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToTkclksrc),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToTkclksrc),

			rdyCmdbusFromLwiracq => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusLwiracqToTkclksrc),
			rdCmdbusFromLwiracq => ackCmdbus(ixVSigIdhwBss3AckCmdbusLwiracqToTkclksrc),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwBss3ReqCmdbusTkclksrcToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwBss3AckCmdbusTkclksrcToCmdret),

			reqCmdbusToLwiracq => reqCmdbus(ixVSigIdhwBss3ReqCmdbusTkclksrcToLwiracq),
			wrCmdbusToLwiracq => ackCmdbus(ixVSigIdhwBss3AckCmdbusTkclksrcToLwiracq)
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

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwBss3RdyCmdbusCmdinvToTrigger),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwBss3AckCmdbusCmdinvToTrigger),

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
	JXADC <= JXADC_sig;
	
	-- IP impl.oth.cust --- IBEGIN
	aluaR0_part <= aluaR0(15 downto 0) when sw(9 downto 8)="00"
		else aluaR0(31 downto 16) when sw(9 downto 8)="01"
		else aluaR0(47 downto 32) when sw(9 downto 8)="10"
		else aluaR0(63 downto 48) when sw(9 downto 8)="11";

	aluaR1_part <= aluaR1(15 downto 0) when sw(9 downto 8)="00"
		else aluaR1(31 downto 16) when sw(9 downto 8)="01"
		else aluaR1(47 downto 32) when sw(9 downto 8)="10"
		else aluaR1(63 downto 48) when sw(9 downto 8)="11";

	alubR0_part <= alubR0(15 downto 0) when sw(9 downto 8)="00"
		else alubR0(31 downto 16) when sw(9 downto 8)="01"
		else alubR0(47 downto 32) when sw(9 downto 8)="10"
		else alubR0(63 downto 48) when sw(9 downto 8)="11";

	alubR1_part <= alubR1(15 downto 0) when sw(9 downto 8)="00"
		else alubR1(31 downto 16) when sw(9 downto 8)="01"
		else alubR1(47 downto 32) when sw(9 downto 8)="10"
		else alubR1(63 downto 48) when sw(9 downto 8)="11";

	tkcmdbuf_part <= tkcmdbuf(7 downto 0) when sw(11 downto 8)="0000"
		else tkcmdbuf(15 downto 8) when sw(11 downto 8)="0001"
		else tkcmdbuf(23 downto 16) when sw(11 downto 8)="0010"
		else tkcmdbuf(31 downto 24) when sw(11 downto 8)="0011"
		else tkcmdbuf(39 downto 32) when sw(11 downto 8)="0100"
		else tkcmdbuf(47 downto 40) when sw(11 downto 8)="0101"
		else tkcmdbuf(55 downto 48) when sw(11 downto 8)="0110"
		else tkcmdbuf(63 downto 56) when sw(11 downto 8)="0111"
		else tkcmdbuf(71 downto 64) when sw(11 downto 8)="1000"
		else tkcmdbuf(79 downto 72) when sw(11 downto 8)="1001"
		else tkcmdbuf(87 downto 80) when sw(11 downto 8)="1010"
		else tkcmdbuf(95 downto 88) when sw(11 downto 8)="1011"
		else tkcmdbuf(103 downto 96) when sw(11 downto 8)="1100"
		else tkcmdbuf(111 downto 104) when sw(11 downto 8)="1101"
		else x"00";

	lwircmdbuf_part <= lwircmdbuf(7 downto 0) when sw(11 downto 8)="0000"
		else lwircmdbuf(15 downto 8) when sw(11 downto 8)="0001"
		else lwircmdbuf(23 downto 16) when sw(11 downto 8)="0010"
		else lwircmdbuf(31 downto 24) when sw(11 downto 8)="0011"
		else lwircmdbuf(39 downto 32) when sw(11 downto 8)="0100"
		else lwircmdbuf(47 downto 40) when sw(11 downto 8)="0101"
		else lwircmdbuf(55 downto 48) when sw(11 downto 8)="0110"
		else lwircmdbuf(63 downto 56) when sw(11 downto 8)="0111"
		else lwircmdbuf(71 downto 64) when sw(11 downto 8)="1000"
		else lwircmdbuf(79 downto 72) when sw(11 downto 8)="1001"
		else lwircmdbuf(87 downto 80) when sw(11 downto 8)="1010"
		else lwircmdbuf(95 downto 88) when sw(11 downto 8)="1011"
		else lwircmdbuf(103 downto 96) when sw(11 downto 8)="1100"
		else lwircmdbuf(111 downto 104) when sw(11 downto 8)="1101"
		else lwircmdbuf(119 downto 112) when sw(11 downto 8)="1110"
		else x"00";

	--JA_sig(4) <= clkCmdbus;
	--JA_sig(5) <= reqCmdbus(tixVSigBss3ReqCmdbusCmdinvToTkclksrc);
	--JA_sig(6) <= ackCmdbus(tixVSigBss3AckCmdbusCmdinvToTkclksrc);
	--JA_sig(7) <= ackCmdbus(tixVSigBss3AckCmdbusTkclksrcToCmdret);
		
	--JA_sig(4) <= urxsmp_out;
	--JA_sig(5) <= RsRx;
	--JA_sig(6) <= reqUtx_sig;
	--JA_sig(7) <= RsTx_sig;

	--JA_sig(4) <= lwir_extsnc;
	--JA_sig(7 downto 5) <= lwiracqtkn; -- valid/frmstart/idle

	JA_sig(4) <= lw_extsnc_wrp;
	JA_sig(5) <= ackInbuf0LwiracqToPmmu;
	JA_sig(6) <= dneInbuf0LwiracqToPmmu;
	JA_sig(7) <= strbDInbuf0LwiracqToPmmu;

	--JA_sig(4) <= reqCmdbus(tixVSigBss3ReqCmdbusLwiracqToPmmu);
	--JA_sig(5) <= reqCmdbus(tixVSigBss3ReqCmdbusPmmuToLwiracq);
	--JA_sig(6) <= ackCmdbus(tixVSigBss3AckCmdbusLwiracqToPmmu);
	--JA_sig(7) <= ackCmdbus(tixVSigBss3AckCmdbusPmmuToLwiracq);

	led <= (x"00" & reqCmdbus(23 downto 16)) when sw(3 downto 0)="0001"
		else reqCmdbus(15 downto 0) when sw(3 downto 0)="0000"

		else (x"00" & rdyCmdbus(23 downto 16)) when sw(3 downto 0)="0101"
		else rdyCmdbus(15 downto 0) when sw(3 downto 0)="0100"

		else (avlbx & reqbx) when sw(3 downto 0)="1000"
		else (x"00" & arbbx) when sw(3 downto 0)="1001"

		else ("000000" & pgbusy(0 to 9)) when sw(3 downto 0)="1100"
		else ("000000" & pgbusy(10 to 19)) when sw(3 downto 0)="1101"
		else ("000000" & pgbusy(20 to 29)) when sw(3 downto 0)="1110"
		else ("000000" & pgbusy(30 to 39)) when sw(3 downto 0)="1111"

		else x"0000";

	hex <= -- aluaR0_part when sw(15 downto 12)="0000"
		--else aluaR1_part when sw(15 downto 12)="0001"
		--else alubR0_part when sw(15 downto 12)="0010"
		--else alubR1_part when sw(15 downto 12)="0011"

		--else hoststateOp when sw(15 downto 12)="0100"
		--else xfertkn when sw(15 downto 12)="0101"

		rowsqr(15 downto 0) when sw(15 downto 12)="0000"
		else (x"000" & rowsqr(19 downto 16)) when sw(15 downto 12)="0001"
		else colsqr(15 downto 0) when sw(15 downto 12)="0010"
		else (x"000" & colsqr(19 downto 16)) when sw(15 downto 12)="0011"
		else rsqr(15 downto 0) when sw(15 downto 12)="0100"
		else (x"000" & rsqr(19 downto 16)) when sw(15 downto 12)="0101"

		--else crc when sw(15 downto 12)="1000"
		--else crcRxbuf when sw(15 downto 12)="1001"

		--else tkst(15 downto 0) when sw(15 downto 12)="1000"
		--else tkst(31 downto 16) when sw(15 downto 12)="1001"

		else reqlen(15 downto 0) when sw(15 downto 12)="1000"
		else reqlen(31 downto 16) when sw(15 downto 12)="1001"

		else avllen(15 downto 0) when sw(15 downto 12)="1010"
		else avllen(31 downto 16) when sw(15 downto 12)="1011"

		else arblen(15 downto 0) when sw(15 downto 12)="1100"
		else arblen(31 downto 16) when sw(15 downto 12)="1101"

		--else (x"00" & tklenCmdbuf) when sw(15 downto 12)="1110"
		--else (x"00" & tkcmdbuf_part) when sw(15 downto 12)="1111"

		else (x"00" & lwircmdbuf_part) when sw(15 downto 12)="1111"

		else x"0000";
	-- IP impl.oth.cust --- IEND

end Top;


