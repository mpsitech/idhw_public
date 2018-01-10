-- file Pmmu_v1_0_120x4kB_8sl.vhd
-- Pmmu_v1_0_120x4kB_8sl pmmu_v1_0 controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Pmmu_v1_0_120x4kB_8sl is
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
end Pmmu_v1_0_120x4kB_8sl;

architecture Pmmu_v1_0_120x4kB_8sl of Pmmu_v1_0_120x4kB_8sl is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Dpbram_v1_0_size8kB is
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
	end component;

	component Spbram_v1_0_size2kB is
		port (
			clk: in std_logic;

			en: in std_logic;
			we: in std_logic;

			a: in std_logic_vector(10 downto 0);
			drd: out std_logic_vector(8 downto 0);
			dwr: in std_logic_vector(8 downto 0)
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	constant sizePg: natural := 4096; -- equals sizeOutbuf0/2 and sizeInbuf0/2
	constant sizeTocbuf: natural := 2048;
	constant slot: natural := 8;

	constant pgsizeMem: natural := 120;

	---- command execution (cmd)
	type stateCmd_t is (
		stateCmdInit,
		stateCmdEmpty,
		stateCmdWaitLockA, stateCmdWaitLockB, stateCmdWaitLockC,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE, stateCmdRecvF,
		stateCmdRecvG,
		stateCmdFullA, stateCmdFullB,
		stateCmdSendA, stateCmdSendB, stateCmdSendC, stateCmdSendD,
		stateCmdPrepRetAlloc,
		stateCmdPrepRetReadOutbuf0,
		stateCmdPrepRetWriteInbuf0,
		stateCmdPrepCreferrWriteInbuf0, stateCmdPrepCreferrReadOutbuf0, stateCmdPrepCreferr,
		stateCmdPrepErrInvalidWriteInbuf0,
		stateCmdPrepErrInvalidReadOutbuf0,
		stateCmdPrepErrInvalid
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: alloc, free, readOutbuf0, writeInbuf0
	-- rev: readOutbuf0, writeInbuf0
	-- ret/newret: alloc, readOutbuf0, writeInbuf0
	-- err: invalid

	constant sizeCmdbuf: natural := 13;

	constant tixVSlotVoid: std_logic_vector(7 downto 0) := x"00";
	constant tixVSlotS0: std_logic_vector(7 downto 0) := x"01";
	constant tixVSlotS1: std_logic_vector(7 downto 0) := x"02";
	constant tixVSlotS2: std_logic_vector(7 downto 0) := x"03";
	constant tixVSlotS3: std_logic_vector(7 downto 0) := x"04";
	constant tixVSlotS4: std_logic_vector(7 downto 0) := x"05";
	constant tixVSlotS5: std_logic_vector(7 downto 0) := x"06";
	constant tixVSlotS6: std_logic_vector(7 downto 0) := x"07";
	constant tixVSlotS7: std_logic_vector(7 downto 0) := x"08";

	constant tixVCommandAlloc: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvAlloc: natural := 12;
	constant ixCmdbufInvAllocDynNotStat: natural := 10;
	constant ixCmdbufInvAllocReqPglen: natural := 11;
	constant lenCmdbufRetAlloc: natural := 10;
	constant ixCmdbufRetAllocTixVSlot: natural := 9;

	constant tixVCommandFree: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvFree: natural := 11;
	constant ixCmdbufInvFreeTixVSlot: natural := 10;

	constant tixVCommandReadOutbuf0: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvReadOutbuf0: natural := 12;
	constant ixCmdbufInvReadOutbuf0TixVSlot: natural := 10;
	constant ixCmdbufInvReadOutbuf0FreeNotKeep: natural := 11;
	constant lenCmdbufRetReadOutbuf0: natural := 10;

	constant tixVCommandWriteInbuf0: std_logic_vector(7 downto 0) := x"03";
	constant lenCmdbufInvWriteInbuf0: natural := 11;
	constant ixCmdbufInvWriteInbuf0TixVSlot: natural := 10;
	constant lenCmdbufRetWriteInbuf0: natural := 10;

	constant tixVErrorInvalid: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufErrInvalid: natural := 10;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal rdyCmdbusFromLwiracq_sig, rdyCmdbusFromLwiracq_sig_next: std_logic;
	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;
	signal reqCmdbusToLwiracq_sig, reqCmdbusToLwiracq_sig_next: std_logic;

	---- inbuf0 and writeInbuf0 command management (inbuf0)
	type stateInbuf0_t is (
		stateInbuf0Init,
		stateInbuf0Idle,
		stateInbuf0StartA, stateInbuf0StartB, stateInbuf0StartC,
		stateInbuf0Ready,
		stateInbuf0WriteA, stateInbuf0WriteB, stateInbuf0WriteC,
		stateInbuf0Step,
		stateInbuf0RevA, stateInbuf0RevB,
		stateInbuf0Ret,
		stateInbuf0Err
	);
	signal stateInbuf0, stateInbuf0_next: stateInbuf0_t;

	signal routeWriteInbuf0: std_logic_vector(7 downto 0);
	signal crefWriteInbuf0: std_logic_vector(31 downto 0);

	signal tixVSlotInbuf0, tixVSlotInbuf0_next: std_logic_vector(7 downto 0);

	signal maxlenInbuf0_rd: natural range 0 to slot;

	signal inbuf0Brun, inbuf0Brun_next: std_logic;

	signal highNotLowInbuf0A, highNotLowInbuf0A_next: std_logic;
	
	signal lenInbuf0Low, lenInbuf0Low_next: natural range 0 to sizePg;
	signal lenInbuf0High, lenInbuf0High_next: natural range 0 to sizePg;

	---- inbuf0 B outward/lwiracq-facing operation (inbuf0B)
	type stateInbuf0B_t is (
		stateInbuf0BInit,
		stateInbuf0BStart,
		stateInbuf0BWaitWriteA, stateInbuf0BWaitWriteB,
		stateInbuf0BWaitEmpty,
		stateInbuf0BReady,
		stateInbuf0BXferA, stateInbuf0BXferB,
		stateInbuf0BDone
	);
	signal stateInbuf0B, stateInbuf0B_next: stateInbuf0B_t;

	signal enInbuf0B: std_logic;

	signal aInbuf0B, aInbuf0B_next: natural range 0 to sizePg-1;
	signal aInbuf0B_vec: std_logic_vector(12 downto 0);

	signal highNotLowInbuf0B, highNotLowInbuf0B_next: std_logic;

	signal avllenInbuf0FromLwiracq_sig, avllenInbuf0FromLwiracq_sig_next: natural range 0 to 491520;
	signal avllenInbuf0FromLwiracq_zero, avllenInbuf0FromLwiracq_zero_next: std_logic;

	---- memory read/write operation (mem)
	type stateMem_t is (
		stateMemInit,
		stateMemIdle,
		stateMemWriteInbuf0A, stateMemWriteInbuf0B, stateMemWriteInbuf0C,
		stateMemReadOutbuf0A, stateMemReadOutbuf0B, stateMemReadOutbuf0C, stateMemReadOutbuf0D
	);
	signal stateMem, stateMem_next: stateMem_t := stateMemInit;

	signal enInbuf0: std_logic;

	signal aInbuf0, aInbuf0_next: natural range 0 to sizePg-1;
	signal aInbuf0_vec: std_logic_vector(12 downto 0);

	signal enOutbuf0: std_logic;

	signal aOutbuf0, aOutbuf0_next: natural range 0 to sizePg-1;
	signal aOutbuf0_vec: std_logic_vector(12 downto 0);

	signal dOutbuf0: std_logic_vector(7 downto 0);

	signal pga: natural range 0 to pgsizeMem-1;
	signal a_sig: natural range 0 to sizePg-1;

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpIdle,
		stateOpAllocA, stateOpAllocB, stateOpAllocC, stateOpAllocD, stateOpAllocE,
		stateOpAllocF, stateOpAllocG, stateOpAllocH, stateOpAllocI,
		stateOpFreeA, stateOpFreeB, stateOpFreeC, stateOpFreeD, stateOpFreeE,
		stateOpFreeF,
		stateOpInstaA, stateOpInstaB, stateOpInstaC, stateOpInstaD, stateOpInstaE,
		stateOpInconfA, stateOpInconfB, stateOpInconfC, stateOpInconfD, stateOpInconfE, stateOpInconfF,
		stateOpInstepA, stateOpInstepB, stateOpInstepC, stateOpInstepD, stateOpInstepE,
		stateOpInstepF,
		stateOpInstopA, stateOpInstopB,
		stateOpOutstaA, stateOpOutstaB, stateOpOutstaC, stateOpOutstaD, stateOpOutstaE,
		stateOpOutconfA, stateOpOutconfB, stateOpOutconfC, stateOpOutconfD,
		stateOpOutfreeA, stateOpOutfreeB, stateOpOutfreeC, stateOpOutfreeD, stateOpOutfreeE,
		stateOpOutstepA, stateOpOutstepB, stateOpOutstepC, stateOpOutstepD, stateOpOutstepE, stateOpOutstepF
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal pgbusy: std_logic_vector(0 to pgsizeMem-1);

	type inoutbuf_t is (
		inbuf0,
		outbuf0
	);
	signal inoutbuf, inoutbuf_next: inoutbuf_t;

	signal tixVSlot, tixVSlot_next: std_logic_vector(7 downto 0);

	signal a0Tocbuf: natural range 0 to sizeTocbuf-1;
	signal lenTocbuf_rd: natural range 0 to slot; -- total number of allocted pages over slot lifetime
	signal maxlenTocbuf_rd: natural range 0 to slot; -- max number of allocated pages over slot lifetime as per alloc command reqPglen ; indicator for slot in use
	signal ix0FullTocbuf_rd: natural range 0 to slot-1; -- first fully written page
	signal lenFullTocbuf_rd: natural range 0 to slot; -- number of fully written page

	signal tixVSlotCmd: std_logic_vector(7 downto 0);

	signal tixVSlotInoutbuf: std_logic_vector(7 downto 0);
	signal ixTocbufInoutbuf_rd: natural range 0 to slot-1;

	signal enTocbuf: std_logic;
	signal weTocbuf: std_logic;
			
	signal aTocbuf, aTocbuf_next: natural range 0 to sizeTocbuf-1;
	signal aTocbuf_vec: std_logic_vector(10 downto 0);

	signal dwrTocbuf, dwrTocbuf_next: std_logic_vector(8 downto 0);

	constant a0TocbufS0: natural := 0;
	signal maxlenTocbufS0: natural range 0 to slot := 0;
	signal lenTocbufS0: natural range 0 to slot := 0;
	signal ix0FullTocbufS0: natural range 0 to slot-1 := 0;
	signal lenFullTocbufS0: natural range 0 to slot := 0;

	constant a0TocbufS1: natural := slot;
	signal maxlenTocbufS1: natural range 0 to slot := 0;
	signal lenTocbufS1: natural range 0 to slot := 0;
	signal ix0FullTocbufS1: natural range 0 to slot-1 := 0;
	signal lenFullTocbufS1: natural range 0 to slot := 0;

	constant a0TocbufS2: natural := (2*slot);
	signal maxlenTocbufS2: natural range 0 to slot := 0;
	signal lenTocbufS2: natural range 0 to slot := 0;
	signal ix0FullTocbufS2: natural range 0 to slot-1 := 0;
	signal lenFullTocbufS2: natural range 0 to slot := 0;

	constant a0TocbufS3: natural := (3*slot);
	signal maxlenTocbufS3: natural range 0 to slot := 0;
	signal lenTocbufS3: natural range 0 to slot := 0;
	signal ix0FullTocbufS3: natural range 0 to slot-1 := 0;
	signal lenFullTocbufS3: natural range 0 to slot := 0;

	constant a0TocbufS4: natural := (4*slot);
	signal maxlenTocbufS4: natural range 0 to slot := 0;
	signal lenTocbufS4: natural range 0 to slot := 0;
	signal ix0FullTocbufS4: natural range 0 to slot-1 := 0;
	signal lenFullTocbufS4: natural range 0 to slot := 0;

	constant a0TocbufS5: natural := (5*slot);
	signal maxlenTocbufS5: natural range 0 to slot := 0;
	signal lenTocbufS5: natural range 0 to slot := 0;
	signal ix0FullTocbufS5: natural range 0 to slot-1 := 0;
	signal lenFullTocbufS5: natural range 0 to slot := 0;

	constant a0TocbufS6: natural := (6*slot);
	signal maxlenTocbufS6: natural range 0 to slot := 0;
	signal lenTocbufS6: natural range 0 to slot := 0;
	signal ix0FullTocbufS6: natural range 0 to slot-1 := 0;
	signal lenFullTocbufS6: natural range 0 to slot := 0;

	constant a0TocbufS7: natural := (7*slot);
	signal maxlenTocbufS7: natural range 0 to slot := 0;
	signal lenTocbufS7: natural range 0 to slot := 0;
	signal ix0FullTocbufS7: natural range 0 to slot-1 := 0;
	signal lenFullTocbufS7: natural range 0 to slot := 0;

	signal ixTocbufInbuf0: natural range 0 to slot-1;
	signal pgaInbuf0: natural range 0 to pgsizeMem-1;

	signal ixTocbufOutbuf0: natural range 0 to slot-1;
	signal pgaOutbuf0: natural range 0 to pgsizeMem-1;

	signal reqInbufToOpStart: std_logic;
	signal ackInbufToOpStart: std_logic;

	signal reqInbufToOpConf: std_logic;
	signal ackInbufToOpConf: std_logic;

	signal reqInbufToOpStep: std_logic;
	signal ackInbufToOpStep: std_logic;
	signal dnyInbufToOpStep: std_logic;

	signal reqInbufToOpStop: std_logic;
	signal ackInbufToOpStop: std_logic;

	signal reqOutbufToOpStart: std_logic;
	signal ackOutbufToOpStart: std_logic;

	signal reqOutbufToOpConf: std_logic;
	signal ackOutbufToOpConf: std_logic;
	signal dnyOutbufToOpConf: std_logic;

	signal reqOutbufToOpFree: std_logic;
	signal ackOutbufToOpFree: std_logic;

	signal reqOutbufToOpStep: std_logic;
	signal ackOutbufToOpStep: std_logic;
	signal dnyOutbufToOpStep: std_logic;

	---- outbuf0 and readOutbuf0 command management (outbuf0)
	type stateOutbuf0_t is (
		stateOutbuf0Init,
		stateOutbuf0Idle,
		stateOutbuf0StartA, stateOutbuf0StartB, stateOutbuf0StartC,
		stateOutbuf0Ready,
		stateOutbuf0AckDone,
		stateOutbuf0Conf,
		stateOutbuf0Read,
		stateOutbuf0Free,
		stateOutbuf0Step,
		stateOutbuf0Rev,
		stateOutbuf0Ret,
		stateOutbuf0Err
	);
	signal stateOutbuf0, stateOutbuf0_next: stateOutbuf0_t;

	signal routeReadOutbuf0: std_logic_vector(7 downto 0);
	signal crefReadOutbuf0: std_logic_vector(31 downto 0);

	signal tixVSlotOutbuf0, tixVSlotOutbuf0_next: std_logic_vector(7 downto 0);
	signal freeNotKeepOutbuf0: std_logic;

	signal outbuf0Brun, outbuf0Brun_next: std_logic;

	signal maxlenOutbuf0_rd: natural range 0 to slot;

	signal highNotLowOutbuf0A, highNotLowOutbuf0A_next: std_logic;

	signal lenOutbuf0Low, lenOutbuf0Low_next: natural range 0 to sizePg;
	signal lenOutbuf0High, lenOutbuf0High_next: natural range 0 to sizePg;

	---- outbuf0 B outward/hostif-facing operation (oubtub0B)
	type stateOutbuf0B_t is (
		stateOutbuf0BInit,
		stateOutbuf0BStart,
		stateOutbuf0BWaitConfA, stateOutbuf0BWaitConfB,
		stateOutbuf0BWaitFull,
		stateOutbuf0BReady,
		stateOutbuf0BXferA, stateOutbuf0BXferB, stateOutbuf0BXferC,
		stateOutbuf0BDone
	);
	signal stateOutbuf0B, stateOutbuf0B_next: stateOutbuf0B_t;

	signal enOutbuf0B: std_logic;

	signal aOutbuf0B, aOutbuf0B_next: natural range 0 to sizePg-1;
	signal aOutbuf0B_vec: std_logic_vector(12 downto 0);

	signal highNotLowOutbuf0B, highNotLowOutbuf0B_next: std_logic;

	signal avllenOutbuf0ToHostif_sig, avllenOutbuf0ToHostif_sig_next: natural range 0 to 491520;
	signal avllenOutbuf0ToHostif_zero, avllenOutbuf0ToHostif_zero_next: std_logic;

	---- myInbuf0
	signal dInbuf0: std_logic_vector(7 downto 0);

	---- myTocbuf
	signal drdTocbuf: std_logic_vector(8 downto 0);

	---- handshake
	-- cmd to op
	signal reqCmdToOpInvAlloc, reqCmdToOpInvAlloc_next: std_logic;
	signal ackCmdToOpInvAlloc: std_logic;

	-- cmd to op
	signal reqCmdToOpInvFree, reqCmdToOpInvFree_next: std_logic;
	signal ackCmdToOpInvFree: std_logic;

	-- cmd to outbuf0
	signal reqCmdToOutbuf0Inv, reqCmdToOutbuf0Inv_next: std_logic;
	signal ackCmdToOutbuf0Inv: std_logic;
	signal dnyCmdToOutbuf0Inv: std_logic;

	-- cmd to outbuf0
	signal reqCmdToOutbuf0Rev, reqCmdToOutbuf0Rev_next: std_logic;
	signal ackCmdToOutbuf0Rev: std_logic;

	-- cmd to inbuf0
	signal reqCmdToInbuf0Inv, reqCmdToInbuf0Inv_next: std_logic;
	signal ackCmdToInbuf0Inv: std_logic;
	signal dnyCmdToInbuf0Inv: std_logic;

	-- cmd to inbuf0
	signal reqCmdToInbuf0Rev, reqCmdToInbuf0Rev_next: std_logic;
	signal ackCmdToInbuf0Rev: std_logic;

	-- inbuf0 to cmd
	signal reqInbuf0ToCmdRet: std_logic;
	signal ackInbuf0ToCmdRet, ackInbuf0ToCmdRet_next: std_logic;

	-- outbuf0 to cmd
	signal reqOutbuf0ToCmdRet: std_logic;
	signal ackOutbuf0ToCmdRet, ackOutbuf0ToCmdRet_next: std_logic;

	-- (many) to cmd
	signal reqInbuf0ToCmdErrInvalid: std_logic;
	signal reqOutbuf0ToCmdErrInvalid: std_logic;
	signal ackCmdErrInvalid, ackCmdErrInvalid_next: std_logic;

	-- inbuf0 to mem
	signal reqInbuf0ToMemWrite, reqInbuf0ToMemWrite_next: std_logic;
	signal ackInbuf0ToMemWrite, ackInbuf0ToMemWrite_next: std_logic;

	-- inbuf0 to op
	signal reqInbuf0ToOpStart: std_logic;
	signal ackInbuf0ToOpStart: std_logic;

	signal reqInbuf0ToOpConf: std_logic;
	signal ackInbuf0ToOpConf: std_logic;

	signal reqInbuf0ToOpStep: std_logic;
	signal ackInbuf0ToOpStep: std_logic;
	signal dnyInbuf0ToOpStep: std_logic;

	signal reqInbuf0ToOpStop: std_logic;
	signal ackInbuf0ToOpStop: std_logic;

	-- inbuf0B to inbuf
	signal reqInbuf0BToInbuf0Done, reqInbuf0BToInbuf0Done_next: std_logic;
	signal ackInbuf0BToInbuf0Done: std_logic;

	-- outbuf0 to mem
	signal reqOutbuf0ToMemRead, reqOutbuf0ToMemRead_next: std_logic;
	signal ackOutbuf0ToMemRead, ackOutbuf0ToMemRead_next: std_logic;

	-- outbuf0 to op
	signal reqOutbuf0ToOpStart: std_logic;
	signal ackOutbuf0ToOpStart: std_logic;

	signal reqOutbuf0ToOpConf: std_logic;
	signal ackOutbuf0ToOpConf: std_logic;
	signal dnyOutbuf0ToOpConf: std_logic;

	signal reqOutbuf0ToOpFree: std_logic;
	signal ackOutbuf0ToOpFree: std_logic;

	signal reqOutbuf0ToOpStep: std_logic;
	signal ackOutbuf0ToOpStep: std_logic;
	signal dnyOutbuf0ToOpStep: std_logic;

	-- outbuf0B to outbuf0
	signal reqOutbuf0BToOutbuf0Done, reqOutbuf0BToOutbuf0Done_next: std_logic;
	signal ackOutbuf0BToOutbuf0Done: std_logic;

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myInbuf0 : Dpbram_v1_0_size8kB
		port map (
			clkA => fastclk,

			enA => enInbuf0,
			weA => '0',

			aA => aInbuf0_vec,
			drdA => dInbuf0,
			dwrA => x"00",

			clkB => clkInbuf0FromLwiracq,

			enB => enInbuf0B,
			weB => '1',

			aB => aInbuf0B_vec,
			drdB => open,
			dwrB => dInbuf0FromLwiracq
		);

	myOutbuf0 : Dpbram_v1_0_size8kB
		port map (
			clkA => fastclk,

			enA => enOutbuf0,
			weA => '1',

			aA => aOutbuf0_vec,
			drdA => open,
			dwrA => dOutbuf0,

			clkB => clkOutbuf0ToHostif,

			enB => enOutbuf0B,
			weB => '0',

			aB => aOutbuf0B_vec,
			drdB => dOutbuf0ToHostif,
			dwrB => x"00"
		);

	myTocbuf : Spbram_v1_0_size2kB
		port map (
			clk => mclk,

			en => enTocbuf,
			we => weTocbuf,

			a => aTocbuf_vec,
			drd => drdTocbuf,
			dwr => dwrTocbuf
		);

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	rdyCmdbusFromLwiracq <= rdyCmdbusFromLwiracq_sig;
	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	reqCmdbusToLwiracq <= reqCmdbusToLwiracq_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- BEGIN
		variable lenCmdbuf: natural range 0 to sizeCmdbuf := 0;

		variable i: natural range 0 to sizeCmdbuf := 0;
		variable j: natural range 0 to sizeCmdbuf := 0;
		variable x: std_logic_vector(7 downto 0) := x"00";

		variable bytecnt: natural range 0 to sizeCmdbuf := 0;
		-- IP impl.cmd.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			reqCmdToOpInvAlloc_next <= '0';
			reqCmdToOpInvFree_next <= '0';
			reqCmdToOutbuf0Inv_next <= '0';
			reqCmdToOutbuf0Rev_next <= '0';
			reqCmdToInbuf0Inv_next <= '0';
			reqCmdToInbuf0Rev_next <= '0';
			ackInbuf0ToCmdRet_next <= '0';
			ackOutbuf0ToCmdRet_next <= '0';
			ackCmdErrInvalid_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			rdyCmdbusFromLwiracq_sig_next <= '1';
			reqCmdbusToCmdret_sig_next <= '0';
			reqCmdbusToLwiracq_sig_next <= '0';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				reqCmdToOpInvAlloc_next <= '0';
				reqCmdToOpInvFree_next <= '0';
				reqCmdToOutbuf0Inv_next <= '0';
				reqCmdToOutbuf0Rev_next <= '0';
				reqCmdToInbuf0Inv_next <= '0';
				reqCmdToInbuf0Rev_next <= '0';
				ackInbuf0ToCmdRet_next <= '0';
				ackOutbuf0ToCmdRet_next <= '0';
				ackCmdErrInvalid_next <= '0';
				rdyCmdbusFromCmdinv_sig_next <= '1';
				rdyCmdbusFromLwiracq_sig_next <= '1';
				reqCmdbusToCmdret_sig_next <= '0';
				reqCmdbusToLwiracq_sig_next <= '0';

				lenCmdbuf := 0;
				i := 0;
				j := 0;
				x := x"00";
				bytecnt := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if ((rdCmdbusFromCmdinv='1' or rdCmdbusFromLwiracq='1') and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
					rdyCmdbusFromLwiracq_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;

				elsif (reqOutbuf0ToCmdRet='1' or reqInbuf0ToCmdRet='1' or reqInbuf0ToCmdErrInvalid='1' or reqOutbuf0ToCmdErrInvalid='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
					rdyCmdbusFromLwiracq_sig_next <= '0';

					if clkCmdbus='0' then
						stateCmd_next <= stateCmdWaitLockA;

					elsif clkCmdbus='1' then
						stateCmd_next <= stateCmdWaitLockB;
					end if;
				end if;

			elsif stateCmd=stateCmdWaitLockA then
				if clkCmdbus='1' then
					stateCmd_next <= stateCmdWaitLockB;
				end if;

			elsif stateCmd=stateCmdWaitLockB then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdWaitLockC;
				end if;

			elsif stateCmd=stateCmdWaitLockC then
				if clkCmdbus='1' then
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromLwiracq='0') then
						if reqOutbuf0ToCmdRet='1' then
							stateCmd_next <= stateCmdPrepRetReadOutbuf0;

						elsif reqInbuf0ToCmdRet='1' then
							stateCmd_next <= stateCmdPrepRetWriteInbuf0;

						elsif reqInbuf0ToCmdErrInvalid='1' then
							stateCmd_next <= stateCmdPrepErrInvalidWriteInbuf0;

						elsif reqOutbuf0ToCmdErrInvalid='1' then
							stateCmd_next <= stateCmdPrepErrInvalidReadOutbuf0;

						else
							stateCmd_next <= stateCmdInit;
						end if;

					else
						stateCmd_next <= stateCmdRecvA;
					end if;
				end if;

			elsif stateCmd=stateCmdRecvA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvB then
				if clkCmdbus='1' then
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromLwiracq='0') then
						i := ixCmdbufRoute;
						j := ixCmdbufRoute+1;

						stateCmd_next <= stateCmdRecvD;

					else
						cmdbuf(lenCmdbuf) <= dCmdbus;

						stateCmd_next <= stateCmdRecvC;
					end if;
				end if;

			elsif stateCmd=stateCmdRecvC then
				if clkCmdbus='0' then
					lenCmdbuf := lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvD then
				if j=4 then
					cmdbuf(ixCmdbufRoute+3) <= x"00";

					stateCmd_next <= stateCmdRecvF;

				else
					if (i=0 and cmdbuf(j)=x"00") then
						x := tixVIdhwZedbControllerCmdret;
					else
						x := cmdbuf(j);
					end if;

					stateCmd_next <= stateCmdRecvE;
				end if;

			elsif stateCmd=stateCmdRecvE then
				cmdbuf(i) <= x;

				i := i + 1;
				j := j + 1;

				stateCmd_next <= stateCmdRecvD;

			elsif stateCmd=stateCmdRecvF then
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandAlloc and lenCmdbuf=lenCmdbufInvAlloc) then
					reqCmdToOpInvAlloc_next <= '1';

					stateCmd_next <= stateCmdRecvG;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandFree and lenCmdbuf=lenCmdbufInvFree) then
					reqCmdToOpInvFree_next <= '1';

					stateCmd_next <= stateCmdRecvG;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandReadOutbuf0 and lenCmdbuf=lenCmdbufInvReadOutbuf0) then
					if crefReadOutbuf0=x"00000000" then
						reqCmdToOutbuf0Inv_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					else
						stateCmd_next <= stateCmdPrepCreferrReadOutbuf0;
					end if;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandWriteInbuf0 and lenCmdbuf=lenCmdbufInvWriteInbuf0) then
					if crefWriteInbuf0=x"00000000" then
						reqCmdToInbuf0Inv_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					else
						stateCmd_next <= stateCmdPrepCreferrWriteInbuf0;
					end if;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRev and lenCmdbuf=lenCmdbufRev) then
					if (cmdbuf(ixCmdbufCref)=crefReadOutbuf0(31 downto 24) and cmdbuf(ixCmdbufCref+1)=crefReadOutbuf0(23 downto 16) and cmdbuf(ixCmdbufCref+2)=crefReadOutbuf0(15 downto 8) and cmdbuf(ixCmdbufCref+3)=crefReadOutbuf0(7 downto 0)) then
						reqCmdToOutbuf0Rev_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					elsif (cmdbuf(ixCmdbufCref)=crefWriteInbuf0(31 downto 24) and cmdbuf(ixCmdbufCref+1)=crefWriteInbuf0(23 downto 16) and cmdbuf(ixCmdbufCref+2)=crefWriteInbuf0(15 downto 8) and cmdbuf(ixCmdbufCref+3)=crefWriteInbuf0(7 downto 0)) then
						reqCmdToInbuf0Rev_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdRecvG then
				if ((reqCmdToOpInvAlloc='1' and ackCmdToOpInvAlloc='1') or (reqCmdToOpInvFree='1' and ackCmdToOpInvFree='1') or (reqCmdToOutbuf0Inv='1' and ackCmdToOutbuf0Inv='1') or (reqCmdToOutbuf0Rev='1' and ackCmdToOutbuf0Rev='1') or (reqCmdToInbuf0Inv='1' and ackCmdToInbuf0Inv='1') or (reqCmdToInbuf0Rev='1' and ackCmdToInbuf0Rev='1')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullA then
				if cmdbuf(ixCmdbufRoute)=tixVIdhwZedbControllerCmdret then
					reqCmdbusToCmdret_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwZedbControllerLwiracq then
					reqCmdbusToLwiracq_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullB then
				if ((wrCmdbusToCmdret='1' or wrCmdbusToLwiracq='1') and clkCmdbus='1') then
					bytecnt := 0;

					dCmdbus_sig_next <= cmdbuf(0);

					stateCmd_next <= stateCmdSendA;
				end if;

			elsif stateCmd=stateCmdSendA then
				if clkCmdbus='0' then
					bytecnt := bytecnt + 1;

					stateCmd_next <= stateCmdSendB;
				end if;

			elsif stateCmd=stateCmdSendB then
				if clkCmdbus='1' then
					if bytecnt=lenCmdbuf then
						stateCmd_next <= stateCmdSendC;

					else
						dCmdbus_sig_next <= cmdbuf(bytecnt);

						if bytecnt=(lenCmdbuf-1) then
							reqCmdbusToCmdret_sig_next <= '0';
							reqCmdbusToLwiracq_sig_next <= '0';
						end if;

						stateCmd_next <= stateCmdSendA;
					end if;
				end if;

			elsif stateCmd=stateCmdSendC then
				if (wrCmdbusToCmdret='0' and wrCmdbusToLwiracq='0') then
					if (reqOutbuf0ToCmdRet='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionRet) then
						ackOutbuf0ToCmdRet_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqInbuf0ToCmdRet='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionRet) then
						ackInbuf0ToCmdRet_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqInbuf0ToCmdErrInvalid='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionErr and cmdbuf(ixCmdbufErrError)=tixVErrorInvalid) then
						ackCmdErrInvalid_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqOutbuf0ToCmdErrInvalid='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionErr and cmdbuf(ixCmdbufErrError)=tixVErrorInvalid) then
						ackCmdErrInvalid_next <= '1';

						stateCmd_next <= stateCmdSendD;

					else
						stateCmd_next <= stateCmdInit;
					end if;
				end if;

			elsif stateCmd=stateCmdSendD then
				if ((reqOutbuf0ToCmdRet='0' and ackOutbuf0ToCmdRet='1') or (reqInbuf0ToCmdRet='0' and ackInbuf0ToCmdRet='1') or (reqInbuf0ToCmdErrInvalid='0' and reqOutbuf0ToCmdErrInvalid='0' and ackCmdErrInvalid='1')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdPrepRetAlloc then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				cmdbuf(ixCmdbufRetAllocTixVSlot) <= tixVSlotCmd;

				lenCmdbuf := lenCmdbufRetAlloc;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepRetReadOutbuf0 then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				cmdbuf(ixCmdbufCref) <= crefReadOutbuf0(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefReadOutbuf0(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefReadOutbuf0(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefReadOutbuf0(7 downto 0);

				lenCmdbuf := lenCmdbufRetReadOutbuf0;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepRetWriteInbuf0 then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				cmdbuf(ixCmdbufCref) <= crefWriteInbuf0(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefWriteInbuf0(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefWriteInbuf0(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefWriteInbuf0(7 downto 0);

				lenCmdbuf := lenCmdbufRetWriteInbuf0;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepCreferrWriteInbuf0 then
				cmdbuf(ixCmdbufCreferrCref) <= crefWriteInbuf0(31 downto 24);
				cmdbuf(ixCmdbufCreferrCref+1) <= crefWriteInbuf0(23 downto 16);
				cmdbuf(ixCmdbufCreferrCref+2) <= crefWriteInbuf0(15 downto 8);
				cmdbuf(ixCmdbufCreferrCref+3) <= crefWriteInbuf0(7 downto 0);

				stateCmd_next <= stateCmdPrepCreferr;

			elsif stateCmd=stateCmdPrepCreferrReadOutbuf0 then
				cmdbuf(ixCmdbufCreferrCref) <= crefReadOutbuf0(31 downto 24);
				cmdbuf(ixCmdbufCreferrCref+1) <= crefReadOutbuf0(23 downto 16);
				cmdbuf(ixCmdbufCreferrCref+2) <= crefReadOutbuf0(15 downto 8);
				cmdbuf(ixCmdbufCreferrCref+3) <= crefReadOutbuf0(7 downto 0);

				stateCmd_next <= stateCmdPrepCreferr;

			elsif stateCmd=stateCmdPrepCreferr then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionCreferr;

				lenCmdbuf := lenCmdbufCreferr;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepErrInvalidWriteInbuf0 then
				cmdbuf(ixCmdbufRoute) <= routeWriteInbuf0;
				cmdbuf(ixCmdbufCref) <= crefWriteInbuf0(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefWriteInbuf0(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefWriteInbuf0(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefWriteInbuf0(7 downto 0);

				stateCmd_next <= stateCmdPrepErrInvalid;

			elsif stateCmd=stateCmdPrepErrInvalidReadOutbuf0 then
				cmdbuf(ixCmdbufRoute) <= routeReadOutbuf0;
				cmdbuf(ixCmdbufCref) <= crefReadOutbuf0(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefReadOutbuf0(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefReadOutbuf0(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefReadOutbuf0(7 downto 0);

				stateCmd_next <= stateCmdPrepErrInvalid;

			elsif stateCmd=stateCmdPrepErrInvalid then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionErr;
				cmdbuf(ixCmdbufErrError) <= tixVErrorInvalid;

				lenCmdbuf := lenCmdbufErrInvalid;

				stateCmd_next <= stateCmdFullA;
			end if;
		end if;
	end process;
	-- IP impl.cmd.rising --- END

	-- IP impl.cmd.falling --- BEGIN
	process (mclk)
	begin
		if falling_edge(mclk) then
			stateCmd <= stateCmd_next;
			reqCmdToOpInvAlloc <= reqCmdToOpInvAlloc_next;
			reqCmdToOpInvFree <= reqCmdToOpInvFree_next;
			reqCmdToOutbuf0Inv <= reqCmdToOutbuf0Inv_next;
			reqCmdToOutbuf0Rev <= reqCmdToOutbuf0Rev_next;
			reqCmdToInbuf0Inv <= reqCmdToInbuf0Inv_next;
			reqCmdToInbuf0Rev <= reqCmdToInbuf0Rev_next;
			ackInbuf0ToCmdRet <= ackInbuf0ToCmdRet_next;
			ackOutbuf0ToCmdRet <= ackOutbuf0ToCmdRet_next;
			ackCmdErrInvalid <= ackCmdErrInvalid_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			dCmdbus_sig <= dCmdbus_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			rdyCmdbusFromLwiracq_sig <= rdyCmdbusFromLwiracq_sig_next;
			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
			reqCmdbusToLwiracq_sig <= reqCmdbusToLwiracq_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: inbuf0 and writeInbuf0 command management (inbuf0)
	------------------------------------------------------------------------

	maxlenInbuf0_rd <= maxlenTocbufS0 when tixVSlotInbuf0=tixVSlotS0
				else maxlenTocbufS1 when tixVSlotInbuf0=tixVSlotS1
				else maxlenTocbufS2 when tixVSlotInbuf0=tixVSlotS2
				else maxlenTocbufS3 when tixVSlotInbuf0=tixVSlotS3
				else maxlenTocbufS4 when tixVSlotInbuf0=tixVSlotS4
				else maxlenTocbufS5 when tixVSlotInbuf0=tixVSlotS5
				else maxlenTocbufS6 when tixVSlotInbuf0=tixVSlotS6
				else maxlenTocbufS7 when tixVSlotInbuf0=tixVSlotS7;

	ackCmdToInbuf0Inv <= '1' when stateInbuf0=stateInbuf0StartB else '0';
	dnyCmdToInbuf0Inv <= '1' when stateInbuf0=stateInbuf0StartC else '0';
	ackCmdToInbuf0Rev <= '1' when stateInbuf0=stateInbuf0RevB else '0';
	reqInbuf0ToMemWrite <= '1' when stateInbuf0=stateInbuf0WriteA else '0';
	reqInbuf0ToCmdRet <= '1' when stateInbuf0=stateInbuf0Ret else '0';
	reqInbuf0ToCmdErrInvalid <= '1' when stateInbuf0=stateInbuf0Err else '0';
	reqInbuf0ToOpStart <= '1' when stateInbuf0=stateInbuf0StartB else '0';
	reqInbuf0ToOpConf <= '1' when stateInbuf0=stateInbuf0WriteB else '0';
	reqInbuf0ToOpStep <= '1' when stateInbuf0=stateInbuf0Step else '0';
	reqInbuf0ToOpStop <= '1' when stateInbuf0=stateInbuf0RevA else '0';
	ackInbuf0BToInbuf0Done <= '1' when stateInbuf0=stateInbuf0WriteC else '0';
	
	process (reset, mclk, stateInbuf0)
		variable done: std_logic;

	begin
		if reset='1' then
			stateInbuf0_next <= stateInbuf0Init;
			routeWriteInbuf0 <= (others => '0');
			crefWriteInbuf0 <= (others => '0');
			tixVSlotInbuf0_next <= (others => '0');
			inbuf0Brun_next <= '0';
			highNotLowInbuf0A_next <= '0';
			lenInbuf0Low_next <= 0;
			lenInbuf0High_next <= sizePg;

		elsif rising_edge(mclk) then
			if stateInbuf0=stateInbuf0Init then
				routeWriteInbuf0 <= (others => '0');
				crefWriteInbuf0 <= (others => '0');
				tixVSlotInbuf0_next <= (others => '0');
				inbuf0Brun_next <= '0';
				highNotLowInbuf0A_next <= '0';
				lenInbuf0Low_next <= 0;
				lenInbuf0High_next <= sizePg;

				stateInbuf0_next <= stateInbuf0Idle;

				done := '0';

			elsif stateInbuf0=stateInbuf0Idle then
				if reqCmdToInbuf0Inv='1' then
					routeWriteInbuf0 <= cmdbuf(ixCmdbufRoute);

					crefWriteInbuf0(31 downto 24) <= cmdbuf(ixCmdbufCref);
					crefWriteInbuf0(23 downto 16) <= cmdbuf(ixCmdbufCref+1);
					crefWriteInbuf0(15 downto 8) <= cmdbuf(ixCmdbufCref+2);
					crefWriteInbuf0(7 downto 0) <= cmdbuf(ixCmdbufCref+3);

					tixVSlotInbuf0_next <= cmdbuf(ixCmdbufInvWriteInbuf0TixVSlot);
					
					stateInbuf0_next <= stateInbuf0StartA;
				end if;

			elsif stateInbuf0=stateInbuf0StartA then
				if maxlenInbuf0_rd/=0 then
					stateInbuf0_next <= stateInbuf0StartB;
				else
					stateInbuf0_next <= stateInbuf0StartC;
				end if;

			elsif stateInbuf0=stateInbuf0StartB then
				if (reqCmdToInbuf0Inv='0' and ackInbuf0ToOpStart='1') then
					inbuf0Brun_next <= '1';
					stateInbuf0_next <= stateInbuf0Ready;
				end if;

			elsif stateInbuf0=stateInbuf0StartC then
				if reqCmdToInbuf0Inv='0' then
					stateInbuf0_next <= stateInbuf0Init;
				end if;

			elsif stateInbuf0=stateInbuf0Ready then
				if maxlenInbuf0_rd=0 then
					stateInbuf0_next <= stateInbuf0Err;

				elsif reqCmdToInbuf0Rev='1' then
					stateInbuf0_next <= stateInbuf0RevA;

				elsif reqInbuf0BToInbuf0Done='1' then
					-- impossible to arrive here unless a page has been allocated already
					if highNotLowInbuf0A='0' then
						lenInbuf0Low_next <= sizePg;
					else
						lenInbuf0High_next <= sizePg;
					end if;

					stateInbuf0_next <= stateInbuf0WriteA;

				elsif (ixTocbufInbuf0/=(maxlenInbuf0_rd-1) and (lenInbuf0Low/=0 or lenInbuf0High/=0)) then
					stateInbuf0_next <= stateInbuf0Step;
				end if;

			elsif stateInbuf0=stateInbuf0WriteA then
				if ackInbuf0ToMemWrite='1' then
					if ixTocbufInbuf0=(maxlenInbuf0_rd-1) then
						done := '1';
					end if;

					stateInbuf0_next <= stateInbuf0WriteB;
				end if;

			elsif stateInbuf0=stateInbuf0WriteB then
				if ackInbuf0ToOpConf='1' then
					stateInbuf0_next <= stateInbuf0WriteC;
				end if;

			elsif stateInbuf0=stateInbuf0WriteC then
				if reqInbuf0BToInbuf0Done='0' then
					if done='1' then
						stateInbuf0_next <= stateInbuf0Ret;
					else
						highNotLowInbuf0A_next <= not highNotLowInbuf0A; -- next page to be written
						stateInbuf0_next <= stateInbuf0Ready;
					end if;
				end if;

			elsif stateInbuf0=stateInbuf0Step then
				if ackInbuf0ToOpStep='1' then
					if (lenInbuf0Low/=0 and lenInbuf0High/=0) then
						if highNotLowInbuf0A='0' then
							lenInbuf0Low_next <= 0;
						else
							lenInbuf0High_next <= 0;
						end if;
					elsif lenInbuf0Low/=0 then
						lenInbuf0Low_next <= 0;
					elsif lenInbuf0High/=0 then
						lenInbuf0High_next <= 0;
					end if;

					stateInbuf0_next <= stateInbuf0Ready;

				elsif dnyInbuf0ToOpStep='1' then
					-- keep trying
					stateInbuf0_next <= stateInbuf0Ready;
				end if;

			elsif stateInbuf0=stateInbuf0RevA then
				if ackInbuf0ToOpStop='1' then
					stateInbuf0_next <= stateInbuf0RevB;
				end if;

			elsif stateInbuf0=stateInbuf0RevB then
				if reqCmdToInbuf0Rev='0' then
					stateInbuf0_next <= stateInbuf0Init;
				end if;

			elsif stateInbuf0=stateInbuf0Ret then
				if ackInbuf0ToCmdRet='1' then
					stateInbuf0_next <= stateInbuf0Init;
				end if;

			elsif stateInbuf0=stateInbuf0Err then
				if ackCmdErrInvalid='1' then
					stateInbuf0_next <= stateInbuf0Init;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateInbuf0 <= stateInbuf0_next;
			tixVSlotInbuf0 <= tixVSlotInbuf0_next;
			inbuf0Brun <= inbuf0Brun_next;
			highNotLowInbuf0A <= highNotLowInbuf0A_next;
			lenInbuf0Low <= lenInbuf0Low_next;
			lenInbuf0High <= lenInbuf0High_next;
		end if;
	end process;
	
	------------------------------------------------------------------------
	-- implementation: inbuf0 B outward/lwiracq-facing operation (inbuf0B)
	------------------------------------------------------------------------

	enInbuf0B <= '1' when (stateInbuf0B=stateInbuf0BXferB and strbDInbuf0FromLwiracq='1') else '0';

	aInbuf0B_vec <= highNotLowInbuf0B & std_logic_vector(to_unsigned(aInbuf0B, 12));

	ackInbuf0FromLwiracq <= '1' when (stateInbuf0B=stateInbuf0BXferA or stateInbuf0B=stateInbuf0BXferB) else '0';

	avllenInbuf0FromLwiracq <= std_logic_vector(to_unsigned(avllenInbuf0FromLwiracq_sig, 19)) when avllenInbuf0FromLwiracq_zero='0' else (others => '0');

	process (reset, clkInbuf0FromLwiracq, stateInbuf0B)
		variable bytecnt: natural range 0 to 491520;

		variable x: std_logic_vector(18 downto 0);

	begin
		if reset='1' then
			stateInbuf0B_next <= stateInbuf0BInit;
			aInbuf0B_next <= 0;
			highNotLowInbuf0B_next <= '0';
			avllenInbuf0FromLwiracq_sig_next <= 0;
			avllenInbuf0FromLwiracq_zero_next <= '0';
			reqInbuf0BToInbuf0Done_next <= '0';

		elsif rising_edge(clkInbuf0FromLwiracq) then
			if (reqInbuf0BToInbuf0Done='1' and ackInbuf0BToInbuf0Done='1') then
				reqInbuf0BToInbuf0Done_next <= '0';
			end if;

			if (stateInbuf0B=stateInbuf0BInit or inbuf0Brun='0') then
				aInbuf0B_next <= 0;
				highNotLowInbuf0B_next <= '0';
				avllenInbuf0FromLwiracq_sig_next <= 0;
				avllenInbuf0FromLwiracq_zero_next <= '0';
				reqInbuf0BToInbuf0Done_next <= '0';

				if inbuf0Brun='0' then
					stateInbuf0B_next <= stateInbuf0BInit;
				else
					stateInbuf0B_next <= stateInbuf0BStart;
				end if;

			elsif stateInbuf0B=stateInbuf0BStart then
				x := std_logic_vector(to_unsigned(maxlenInbuf0_rd, 7)) & "000000000000";
				avllenInbuf0FromLwiracq_sig_next <= to_integer(unsigned(x));
				avllenInbuf0FromLwiracq_zero_next <= '1';

				stateInbuf0B_next <= stateInbuf0BWaitEmpty;

			elsif stateInbuf0B=stateInbuf0BWaitWriteA then
				-- only here if a second write transfer is waiting
				if (reqInbuf0BToInbuf0Done='1' and ackInbuf0BToInbuf0Done='1') then
					stateInbuf0B_next <= stateInbuf0BWaitWriteB;
				end if;

			elsif stateInbuf0B=stateInbuf0BWaitWriteB then
				reqInbuf0BToInbuf0Done_next <= '1';

				if avllenInbuf0FromLwiracq_sig=0 then
					stateInbuf0B_next <= stateInbuf0BDone;
				else
					highNotLowInbuf0B_next <= not highNotLowInbuf0B;
					stateInbuf0B_next <= stateInbuf0BWaitEmpty;
				end if;

			elsif stateInbuf0B=stateInbuf0BWaitEmpty then
				if ((highNotLowInbuf0B='0' and lenInbuf0Low=0) or (highNotLowInbuf0B='1' and lenInbuf0High=0)) then
					avllenInbuf0FromLwiracq_zero_next <= '0';
					stateInbuf0B_next <= stateInbuf0BReady;
				end if;

			elsif stateInbuf0B=stateInbuf0BReady then
				if reqInbuf0FromLwiracq='1' then
					bytecnt := 0;
					stateInbuf0B_next <= stateInbuf0BXferB;
				end if;

			elsif stateInbuf0B=stateInbuf0BXferA then -- ackInbuf0FromLwiracq='1'
				if dneInbuf0FromLwiracq='1' then
					-- confirm
					avllenInbuf0FromLwiracq_sig_next <= avllenInbuf0FromLwiracq_sig - bytecnt;

					if aInbuf0B=(sizePg-1) then
						aInbuf0B_next <= 0;
						avllenInbuf0FromLwiracq_zero_next <= '1';

						if reqInbuf0BToInbuf0Done='1' then
							-- previous write not completed
							stateInbuf0B_next <= stateInbuf0BWaitWriteA;
						else
							stateInbuf0B_next <= stateInbuf0BWaitWriteB;
						end if;
					else
						aInbuf0B_next <= aInbuf0B + 1;
						stateInbuf0B_next <= stateInbuf0BReady;
					end if;
	
				elsif reqInbuf0FromLwiracq='0' then
					-- discard
					aInbuf0B_next <= aInbuf0B - (bytecnt - 1);
					stateInbuf0B_next <= stateInbuf0BReady;
	
				elsif strbDInbuf0FromLwiracq='0' then
					if aInbuf0B=(sizePg-1) then
						-- continuous xfer beyond page size: same as confirm ; on-the-fly if possible
						aInbuf0B_next <= 0;
						avllenInbuf0FromLwiracq_sig_next <= avllenInbuf0FromLwiracq_sig - bytecnt;

						if reqInbuf0BToInbuf0Done='1' then
							-- previous write not completed
							avllenInbuf0FromLwiracq_zero_next <= '1';
							stateInbuf0B_next <= stateInbuf0BWaitWriteA;
						else
							if (avllenInbuf0FromLwiracq_sig=bytecnt or (highNotLowInbuf0B='0' and lenInbuf0High/=0) or (highNotLowInbuf0B='1' and lenInbuf0Low/=0)) then
								-- last page or next high/low not empty
								avllenInbuf0FromLwiracq_zero_next <= '1';
								stateInbuf0B_next <= stateInbuf0BWaitWriteB;
							else
								reqInbuf0BToInbuf0Done_next <= '1';
								highNotLowInbuf0B_next <= not highNotLowInbuf0B;
								bytecnt := 0;
								stateInbuf0B_next <= stateInbuf0BXferB;
							end if;
						end if;
					else
						aInbuf0B_next <= aInbuf0B + 1;
						stateInbuf0B_next <= stateInbuf0BXferB;
					end if;
				end if;

			elsif stateInbuf0B=stateInbuf0BXferB then -- ackInbuf0FromLwiracq='1'
				if strbDInbuf0FromLwiracq='1' then
					bytecnt := bytecnt + 1;
					stateInbuf0B_next <= stateInbuf0BXferA;
				end if;

			elsif stateInbuf0B=stateInbuf0BDone then
				-- if inbuf0Brun='0' then
				-- 	stateInbuf0B_next <= stateInbuf0BInit;
				-- end if;
			end if;
		end if;
	end process;

	process (clkInbuf0FromLwiracq)
	begin
		if falling_edge(clkInbuf0FromLwiracq) then
			stateInbuf0B <= stateInbuf0B_next;
			highNotLowInbuf0B <= highNotLowInbuf0B_next;
			aInbuf0B <= aInbuf0B_next;
			avllenInbuf0FromLwiracq_sig <= avllenInbuf0FromLwiracq_sig_next;
			avllenInbuf0FromLwiracq_zero <= avllenInbuf0FromLwiracq_zero_next;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			reqInbuf0BToInbuf0Done <= reqInbuf0BToInbuf0Done_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: memory read/write operation (mem) 
	------------------------------------------------------------------------

	enInbuf0 <= '1' when stateMem=stateMemWriteInbuf0A else '0';
	aInbuf0_vec <= highNotLowInbuf0A & std_logic_vector(to_unsigned(aInbuf0, 12));

	enOutbuf0 <= '1' when (stateMem=stateMemReadOutbuf0B or stateMem=stateMemReadOutbuf0C) else '0';
	aOutbuf0_vec <= highNotLowOutbuf0A & std_logic_vector(to_unsigned(aOutbuf0, 12));
	dOutbuf0 <= d;

	a <= std_logic_vector(to_unsigned(pga, 7))	& std_logic_vector(to_unsigned(a_sig, 12));
	d <= dInbuf0 when (stateMem=stateMemWriteInbuf0A or stateMem=stateMemWriteInbuf0B) else "ZZZZZZZZ";

	nce <= '0' when (stateMem=stateMemWriteInbuf0A or stateMem=stateMemReadOutbuf0A or stateMem=stateMemReadOutbuf0B or stateMem=stateMemReadOutbuf0C) else '1';
	noe <= '0' when (stateMem=stateMemReadOutbuf0A or stateMem=stateMemReadOutbuf0B or stateMem=stateMemReadOutbuf0C) else '1';
	nwe <= '0' when stateMem=stateMemWriteInbuf0A else '1';

	process (reset, fastclk, stateMem)
	begin
		if reset='1' then
			stateMem_next <= stateMemInit;
			aInbuf0_next <= 0;
			aOutbuf0_next <= 0;
			ackInbuf0ToMemWrite_next <= '0';
			ackOutbuf0ToMemRead_next <= '0';
			pga <= 0;
			a_sig <= 0;

		elsif rising_edge(fastclk) then
			if stateMem=stateMemInit then
				aInbuf0_next <= 0;
				aOutbuf0_next <= 0;
				ackInbuf0ToMemWrite_next <= '0';
				ackOutbuf0ToMemRead_next <= '0';
				pga <= 0;
				a_sig <= 0;

				stateMem_next <= stateMemIdle;

			elsif stateMem=stateMemIdle then
				if reqInbuf0ToMemWrite='1' then
					pga <= pgaInbuf0;

					stateMem_next <= stateMemWriteInbuf0A;

				elsif reqOutbuf0ToMemRead='1' then
					pga <= pgaOutbuf0;

					stateMem_next <= stateMemReadOutbuf0A;
				end if;

--- inbuf0
			elsif stateMem=stateMemWriteInbuf0A then
				a_sig <= aInbuf0;
				if aInbuf0=(sizePg-1) then
					stateMem_next <= stateMemWriteInbuf0B;
				else
					aInbuf0_next <= aInbuf0 + 1;
				end if;
				
			elsif stateMem=stateMemWriteInbuf0B then
				ackInbuf0ToMemWrite_next <= '1';
				stateMem_next <= stateMemWriteInbuf0C;
				
			elsif stateMem=stateMemWriteInbuf0C then
				if reqInbuf0ToMemWrite='0' then
					stateMem_next <= stateMemInit;
				end if;

--- outbuf0
			elsif stateMem=stateMemReadOutbuf0A then
				stateMem_next <= stateMemReadOutbuf0B;

			elsif stateMem=stateMemReadOutbuf0B then
				aOutbuf0_next <= aOutbuf0 + 1;
				a_sig <= a_sig + 1;

				if aOutbuf0=(sizePg-2) then
					stateMem_next <= stateMemReadOutbuf0C;
				end if;

			elsif stateMem=stateMemReadOutbuf0C then
				ackOutbuf0ToMemRead_next <= '1';
				stateMem_next <= stateMemReadOutbuf0D;

			elsif stateMem=stateMemReadOutbuf0D then
				if reqOutbuf0ToMemRead='0' then
					stateMem_next <= stateMemInit;
				end if;
			end if;
		end if;
	end process;

	process (fastclk)
	begin
		if falling_edge(fastclk) then
			stateMem <= stateMem_next;
			aInbuf0 <= aInbuf0_next;
			aOutbuf0 <= aOutbuf0_next;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			ackInbuf0ToMemWrite <= ackInbuf0ToMemWrite_next;
			ackOutbuf0ToMemRead <= ackOutbuf0ToMemRead_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	a0Tocbuf <= a0TocbufS0 when tixVSlot=tixVSlotS0
				else a0TocbufS1 when tixVSlot=tixVSlotS1
				else a0TocbufS2 when tixVSlot=tixVSlotS2
				else a0TocbufS3 when tixVSlot=tixVSlotS3
				else a0TocbufS4 when tixVSlot=tixVSlotS4
				else a0TocbufS5 when tixVSlot=tixVSlotS5
				else a0TocbufS6 when tixVSlot=tixVSlotS6
				else a0TocbufS7 when tixVSlot=tixVSlotS7;

	lenTocbuf_rd <= lenTocbufS0 when tixVSlot=tixVSlotS0
				else lenTocbufS1 when tixVSlot=tixVSlotS1
				else lenTocbufS2 when tixVSlot=tixVSlotS2
				else lenTocbufS3 when tixVSlot=tixVSlotS3
				else lenTocbufS4 when tixVSlot=tixVSlotS4
				else lenTocbufS5 when tixVSlot=tixVSlotS5
				else lenTocbufS6 when tixVSlot=tixVSlotS6
				else lenTocbufS7 when tixVSlot=tixVSlotS7;

	maxlenTocbuf_rd <= maxlenTocbufS0 when tixVSlot=tixVSlotS0
				else maxlenTocbufS1 when tixVSlot=tixVSlotS1
				else maxlenTocbufS2 when tixVSlot=tixVSlotS2
				else maxlenTocbufS3 when tixVSlot=tixVSlotS3
				else maxlenTocbufS4 when tixVSlot=tixVSlotS4
				else maxlenTocbufS5 when tixVSlot=tixVSlotS5
				else maxlenTocbufS6 when tixVSlot=tixVSlotS6
				else maxlenTocbufS7 when tixVSlot=tixVSlotS7;

	ix0FullTocbuf_rd <= ix0FullTocbufS0 when tixVSlot=tixVSlotS0
				else ix0FullTocbufS1 when tixVSlot=tixVSlotS1
				else ix0FullTocbufS2 when tixVSlot=tixVSlotS2
				else ix0FullTocbufS3 when tixVSlot=tixVSlotS3
				else ix0FullTocbufS4 when tixVSlot=tixVSlotS4
				else ix0FullTocbufS5 when tixVSlot=tixVSlotS5
				else ix0FullTocbufS6 when tixVSlot=tixVSlotS6
				else ix0FullTocbufS7 when tixVSlot=tixVSlotS7;

	lenFullTocbuf_rd <= lenFullTocbufS0 when tixVSlot=tixVSlotS0
				else lenFullTocbufS1 when tixVSlot=tixVSlotS1
				else lenFullTocbufS2 when tixVSlot=tixVSlotS2
				else lenFullTocbufS3 when tixVSlot=tixVSlotS3
				else lenFullTocbufS4 when tixVSlot=tixVSlotS4
				else lenFullTocbufS5 when tixVSlot=tixVSlotS5
				else lenFullTocbufS6 when tixVSlot=tixVSlotS6
				else lenFullTocbufS7 when tixVSlot=tixVSlotS7;

	tixVSlotInoutbuf <= tixVSlotInbuf0 when inoutbuf=inbuf0
		else tixVSlotOutbuf0 when inoutbuf=outbuf0
		else x"00";

	ixTocbufInoutbuf_rd <= ixTocbufInbuf0 when inoutbuf=inbuf0
		else ixTocbufOutbuf0 when inoutbuf=outbuf0
		else 0;

	enTocbuf <= '1' when (stateOp=stateOpAllocE or stateOp=stateOpAllocF or stateOp=stateOpFreeC or stateOp=stateOpInstaC or stateOp=stateOpInconfD
		or stateOp=stateOpInstepD or stateOp=stateOpOutstaC or stateOp=stateOpOutfreeC or stateOp=stateOpOutstepC) else '0';
	weTocbuf <= '1' when (stateOp=stateOpAllocE or stateOp=stateOpInstepD) else '0';

	aTocbuf_vec <= std_logic_vector(to_unsigned(aTocbuf, 11));

	ackCmdToOpInvAlloc <= '1' when stateOp=stateOpAllocI else '0';

	ackCmdToOpInvFree <= '1' when stateOp=stateOpFreeF else '0';

	reqInbufToOpStart <= reqInbuf0ToOpStart when inoutbuf=inbuf0
		else '0';

	ackInbufToOpStart <= '1' when stateOp=stateOpInstaE else '0';

	ackInbuf0ToOpStart <= ackInbufToOpStart when inoutbuf=inbuf0 else '0';

	reqInbufToOpConf <= reqInbuf0ToOpConf when inoutbuf=inbuf0
		else '0';
	
	ackInbufToOpConf <= '1' when stateOp=stateOpInconfF else '0';

	ackInbuf0ToOpConf <= ackInbufToOpConf when inoutbuf=inbuf0 else '0';

	reqInbufToOpStep <= reqInbuf0ToOpStep when inoutbuf=inbuf0
		else '0';

	ackInbufToOpStep <= '1' when stateOp=stateOpInstepE else '0';

	ackInbuf0ToOpStep <= ackInbufToOpStep when inoutbuf=inbuf0 else '0';

	dnyInbufToOpStep <= '1' when stateOp=stateOpInstepF else '0';

	dnyInbuf0ToOpStep <= dnyInbufToOpStep when inoutbuf=inbuf0 else '0';

	reqInbufToOpStop <= reqInbuf0ToOpStop when inoutbuf=inbuf0
		else '0';

	ackInbufToOpStop <= '1' when stateOp=stateOpInstopB else '0';

	ackInbuf0ToOpStop <= ackInbufToOpStop when inoutbuf=inbuf0 else '0';

	reqOutbufToOpStart <= reqOutbuf0ToOpStart when inoutbuf=outbuf0
		else '0';

	ackOutbufToOpStart <= '1' when stateOp=stateOpOutstaE else '0';

	ackOutbuf0ToOpStart <= ackOutbufToOpStart when inoutbuf=outbuf0 else '0';

	reqOutbufToOpConf <= reqOutbuf0ToOpConf when inoutbuf=outbuf0
		else '0';

	ackOutbufToOpConf <= '1' when stateOp=stateOpOutconfC else '0';

	ackOutbuf0ToOpConf <= ackOutbufToOpConf when inoutbuf=outbuf0 else '0';

	dnyOutbufToOpConf <= '1' when stateOp=stateOpOutconfD else '0';

	dnyOutbuf0ToOpConf <= dnyOutbufToOpConf when inoutbuf=outbuf0 else '0';

	reqOutbufToOpFree <= reqOutbuf0ToOpFree when inoutbuf=outbuf0
		else '0';

	ackOutbufToOpFree <= '1' when stateOp=stateOpOutfreeE else '0';

	ackOutbuf0ToOpFree <= ackOutbufToOpFree when inoutbuf=outbuf0 else '0';

	reqOutbufToOpStep <= reqOutbuf0ToOpStep when inoutbuf=outbuf0
		else '0';

	ackOutbufToOpStep <= '1' when stateOp=stateOpOutstepE else '0';

	ackOutbuf0ToOpStep <= ackOutbufToOpStep when inoutbuf=outbuf0 else '0';

	dnyOutbufToOpStep <= '1' when stateOp=stateOpOutstepF else '0';

	dnyOutbuf0ToOpStep <= dnyOutbufToOpStep when inoutbuf=outbuf0 else '0';

	process (reset, mclk, stateOp)
		variable maxlenTocbuf: natural range 0 to slot;
		variable lenTocbuf: natural range 0 to slot;

		variable Nalloc, Nfree: natural range 0 to slot;

		variable instop: std_logic;

		variable i: natural range 0 to slot;
		variable j: natural range 0 to pgsizeMem;

	begin
		if reset='1' then
			stateOp_next <= stateOpInit;
			pgbusy <= (others => '0');
			inoutbuf_next <= inbuf0;
			tixVSlot_next <= (others => '0');
			aTocbuf_next <= 0;
			dwrTocbuf_next <= (others => '0');
			maxlenTocbufS0 <= 0;
			maxlenTocbufS1 <= 0;
			maxlenTocbufS2 <= 0;
			maxlenTocbufS3 <= 0;
			maxlenTocbufS4 <= 0;
			maxlenTocbufS5 <= 0;
			maxlenTocbufS6 <= 0;
			maxlenTocbufS7 <= 0;

		elsif rising_edge(mclk) then
			if stateOp=stateOpInit then
				pgbusy <= (others => '0');
				inoutbuf_next <= inbuf0;
				tixVSlot_next <= (others => '0');
				aTocbuf_next <= 0;
				dwrTocbuf_next <= (others => '0');
				maxlenTocbufS0 <= 0;
				maxlenTocbufS1 <= 0;
				maxlenTocbufS2 <= 0;
				maxlenTocbufS3 <= 0;
				maxlenTocbufS4 <= 0;
				maxlenTocbufS5 <= 0;
				maxlenTocbufS6 <= 0;
				maxlenTocbufS7 <= 0;
				stateOp_next <= stateOpIdle;

			elsif stateOp=stateOpIdle then
				-- highest priority for requests that potentially free pages
				-- TODO: balance priority if there are multiple inoutbuf's
				if reqCmdToOpInvFree='1' then
					stateOp_next <= stateOpFreeA;
				elsif reqInbuf0ToOpStop='1' then
					inoutbuf_next <= inbuf0;
					stateOp_next <= stateOpInstopA;
				elsif reqOutbuf0ToOpFree='1' then
					inoutbuf_next <= outbuf0;
					stateOp_next <= stateOpOutfreeA;

				elsif reqCmdToOpInvAlloc='1' then
					stateOp_next <= stateOpAllocA;
				elsif reqInbuf0ToOpStart='1' then
					inoutbuf_next <= inbuf0;
					stateOp_next <= stateOpInstaA;
				elsif reqInbuf0ToOpConf='1' then
					inoutbuf_next <= inbuf0;
					stateOp_next <= stateOpInconfA;
				elsif reqInbuf0ToOpStep='1' then
					inoutbuf_next <= inbuf0;
					stateOp_next <= stateOpInstepA;
				elsif reqOutbuf0ToOpStart='1' then 
					inoutbuf_next <= outbuf0;
					stateOp_next <= stateOpOutstaA;
				elsif reqOutbuf0ToOpConf='1' then 
					inoutbuf_next <= outbuf0;
					stateOp_next <= stateOpOutconfA;
				elsif reqOutbuf0ToOpStep='1' then
					inoutbuf_next <= outbuf0;
					stateOp_next <= stateOpOutstepA;
				end if;

---
			elsif stateOp=stateOpAllocA then
				-- allocate memory using free slot
				-- maxlenTocbuf=reqPglen
				-- if static, alloc all pages, lenTocbuf=reqPglen; else alloc first page, lenTocbuf=1
				-- ix0FullTocbuf=0, lenFullTocbuf=0

				-- look for slot that is not busy
			if ((cmdbuf(ixCmdbufInvAllocDynNotStat)=fls8 and cmdbuf(ixCmdbufInvAllocReqPglen)=x"00")
							or (maxlenTocbufS0/=0 and maxlenTocbufS1/=0 and maxlenTocbufS2/=0 and maxlenTocbufS3/=0 and maxlenTocbufS4/=0
							 and maxlenTocbufS5/=0 and maxlenTocbufS6/=0 and maxlenTocbufS7/=0)) then
					tixVSlotCmd <= tixVSlotVoid;
					stateOp_next <= stateOpAllocI;

				else
					if maxlenTocbufS0=0 then
						tixVSlot_next <= tixVSlotS0;
					elsif maxlenTocbufS1=0 then
						tixVSlot_next <= tixVSlotS1;
					elsif maxlenTocbufS2=0 then
						tixVSlot_next <= tixVSlotS2;
					elsif maxlenTocbufS3=0 then
						tixVSlot_next <= tixVSlotS3;
					elsif maxlenTocbufS4=0 then
						tixVSlot_next <= tixVSlotS4;
					elsif maxlenTocbufS5=0 then
						tixVSlot_next <= tixVSlotS5;
					elsif maxlenTocbufS6=0 then
						tixVSlot_next <= tixVSlotS6;
					elsif maxlenTocbufS7=0 then
						tixVSlot_next <= tixVSlotS7;
					end if;

					stateOp_next <= stateOpAllocB;
				end if;

			elsif stateOp=stateOpAllocB then
				-- try allocating page(s)
				maxlenTocbuf := to_integer(unsigned(cmdbuf(ixCmdbufInvAllocReqPglen)));
				lenTocbuf := 0;
				aTocbuf_next <= a0Tocbuf;

				if cmdbuf(ixCmdbufInvAllocDynNotStat)=fls8 then
					Nalloc := maxlenTocbuf;
				else
					Nalloc := 1;
				end if;

				i := 0;
				
				stateOp_next <= stateOpAllocC;

			elsif stateOp=stateOpAllocC then
				if i=Nalloc then
					-- success
					lenTocbuf := i;
					stateOp_next <= stateOpAllocH;
				else
					if i=0 then
						j := 0;
					else
						j := j + 1;
					end if;
					stateOp_next <= stateOpAllocD;
				end if;

			elsif stateOp=stateOpAllocD then
				if j=pgsizeMem then
					-- no empty pages found
					aTocbuf_next <= a0Tocbuf;

					Nfree := i;

					i := 0;

					stateOp_next <= stateOpAllocF;
				else
					if pgbusy(j)='0' then
						-- reserve this page for tixVSlotCmd
						pgbusy(j) <= '1';
						dwrTocbuf_next <= "00" & std_logic_vector(to_unsigned(j, 7));
						stateOp_next <= stateOpAllocE;
					else
						j := j + 1;
					end if;
				end if;

			elsif stateOp=stateOpAllocE then -- enTocbuf='1', weTocbuf='1'
				aTocbuf_next <= aTocbuf + 1;

				i := i + 1;

				stateOp_next <= stateOpAllocC;

			elsif stateOp=stateOpAllocF then -- enTocbuf='1', weTocbuf='0'
				-- free pages allocated in vain
				if i=Nfree then
					lenTocbuf := 0;
					stateOp_next <= stateOpAllocH;
				else
					stateOp_next <= stateOpAllocG;
				end if;

			elsif stateOp=stateOpAllocG then
				j := to_integer(unsigned(drdTocbuf));
				pgbusy(j) <= '0';

				aTocbuf_next <= aTocbuf + 1;

				i := i + 1;

				stateOp_next <= stateOpAllocF;
			
			elsif stateOp=stateOpAllocH then
				-- initialize chosen slot
				if tixVSlot=tixVSlotS0 then
					maxlenTocbufS0 <= maxlenTocbuf;
					lenTocbufS0 <= lenTocbuf;
					ix0FullTocbufS0 <= 0;
					lenFullTocbufS0 <= 0;
				elsif tixVSlot=tixVSlotS1 then
					maxlenTocbufS1 <= maxlenTocbuf;
					lenTocbufS1 <= lenTocbuf;
					ix0FullTocbufS1 <= 0;
					lenFullTocbufS1 <= 0;
				elsif tixVSlot=tixVSlotS2 then
					maxlenTocbufS2 <= maxlenTocbuf;
					lenTocbufS2 <= lenTocbuf;
					ix0FullTocbufS2 <= 0;
					lenFullTocbufS2 <= 0;
				elsif tixVSlot=tixVSlotS3 then
					maxlenTocbufS3 <= maxlenTocbuf;
					lenTocbufS3 <= lenTocbuf;
					ix0FullTocbufS3 <= 0;
					lenFullTocbufS3 <= 0;
				elsif tixVSlot=tixVSlotS4 then
					maxlenTocbufS4 <= maxlenTocbuf;
					lenTocbufS4 <= lenTocbuf;
					ix0FullTocbufS4 <= 0;
					lenFullTocbufS4 <= 0;
				elsif tixVSlot=tixVSlotS5 then
					maxlenTocbufS5 <= maxlenTocbuf;
					lenTocbufS5 <= lenTocbuf;
					ix0FullTocbufS5 <= 0;
					lenFullTocbufS5 <= 0;
				elsif tixVSlot=tixVSlotS6 then
					maxlenTocbufS6 <= maxlenTocbuf;
					lenTocbufS6 <= lenTocbuf;
					ix0FullTocbufS6 <= 0;
					lenFullTocbufS6 <= 0;
				elsif tixVSlot=tixVSlotS7 then
					maxlenTocbufS7 <= maxlenTocbuf;
					lenTocbufS7 <= lenTocbuf;
					ix0FullTocbufS7 <= 0;
					lenFullTocbufS7 <= 0;
				end if;

				if lenTocbuf=0 then
					tixVSlotCmd <= tixVSlotVoid;
				else
					tixVSlotCmd <= tixVSlot;
				end if;

				stateOp_next <= stateOpAllocI;

			elsif stateOp=stateOpAllocI then -- ackCmdToOpInvAlloc='1'
				if reqCmdToOpInvAlloc='0' then
					stateOp_next <= stateOpIdle;
				end if;

---
			elsif stateOp=stateOpFreeA then
				-- free all pages from ix0FullTocbuf to lenTocbuf-1; ix0FullTocbuf can only be >0 when full page has been freed by outbuf before
				-- free slot by setting maxlenTocbuf=0
				tixVSlot_next <= cmdbuf(ixCmdbufInvFreeTixVSlot);
				stateOp_next <= stateOpFreeB;

			elsif stateOp=stateOpFreeB then
				aTocbuf_next <= a0Tocbuf + ix0FullTocbuf_rd;

				if maxlenTocbuf_rd=0 then
					if instop='1' then
						stateOp_next <= stateOpInstopB;
					else
						stateOp_next <= stateOpFreeF;
					end if;						
				else
					Nfree := lenTocbuf_rd;
				
					i := ix0FullTocbuf_rd;

					stateOp_next <= stateOpFreeC;
				end if;

			elsif stateOp=stateOpFreeC then -- enTocbuf='1', weTocbuf='0'
				if i=Nfree then
					stateOp_next <= stateOpFreeE;
				else
					stateOp_next <= stateOpFreeD;
				end if;

			elsif stateOp=stateOpFreeD then
				j := to_integer(unsigned(drdTocbuf));
				pgbusy(j) <= '0';

				aTocbuf_next <= aTocbuf + 1;

				i := i + 1;

				stateOp_next <= stateOpFreeC;

			elsif stateOp=stateOpFreeE then
				if tixVSlot=tixVSlotS0 then
					maxlenTocbufS0 <= 0;
				elsif tixVSlot=tixVSlotS1 then
					maxlenTocbufS1 <= 0;
				elsif tixVSlot=tixVSlotS2 then
					maxlenTocbufS2 <= 0;
				elsif tixVSlot=tixVSlotS3 then
					maxlenTocbufS3 <= 0;
				elsif tixVSlot=tixVSlotS4 then
					maxlenTocbufS4 <= 0;
				elsif tixVSlot=tixVSlotS5 then
					maxlenTocbufS5 <= 0;
				elsif tixVSlot=tixVSlotS6 then
					maxlenTocbufS6 <= 0;
				elsif tixVSlot=tixVSlotS7 then
					maxlenTocbufS7 <= 0;
				end if;

				if instop='1' then
					stateOp_next <= stateOpInstopB;
				else
					stateOp_next <= stateOpFreeF;
				end if;						

			elsif stateOp=stateOpFreeF then -- ackCmdToOpInvFree='1'
				if reqCmdToOpInvFree='0' then
					stateOp_next <= stateOpIdle;
				end if;

---
			elsif stateOp=stateOpInstaA then
				-- prepare for write from inbuf
				-- ixTocbufInbuf=0, fetch pgaInbuf
				tixVSlot_next <= tixVSlotInoutbuf;

				if inoutbuf=inbuf0 then
					ixTocbufInbuf0 <= 0;
				end if;

				stateOp_next <= stateOpInstaB;
			
			elsif stateOp=stateOpInstaB then
				aTocbuf_next <= a0Tocbuf;
				stateOp_next <= stateOpInstaC;

			elsif stateOp=stateOpInstaC then -- enTocbuf='1', weTocbuf='0'
				stateOp_next <= stateOpInstaD;

			elsif stateOp=stateOpInstaD then
				if inoutbuf=inbuf0 then
					pgaInbuf0 <= to_integer(unsigned(drdTocbuf));
				end if;

				stateOp_next <= stateOpInstaE;
				
			elsif stateOp=stateOpInstaE then -- ackInbufToOpStart='1'
				if reqInbufToOpStart='0' then
					stateOp_next <= stateOpIdle;
				end if;

---
			elsif stateOp=stateOpInconfA then
				-- lenFullTocbuf+=1
				-- ixTocbufInbuf++, update pgaInbuf ; requires that the next page is allocated already
				tixVSlot_next <= tixVSlotInoutbuf;

				stateOp_next <= stateOpInconfB;

			elsif stateOp=stateOpInconfB then
				if tixVSlot=tixVSlotS0 then
					lenFullTocbufS0 <= lenFullTocbufS0 + 1;
				elsif tixVSlot=tixVSlotS1 then
					lenFullTocbufS1 <= lenFullTocbufS1 + 1;
				elsif tixVSlot=tixVSlotS2 then
					lenFullTocbufS2 <= lenFullTocbufS2 + 1;
				elsif tixVSlot=tixVSlotS3 then
					lenFullTocbufS3 <= lenFullTocbufS3 + 1;
				elsif tixVSlot=tixVSlotS4 then
					lenFullTocbufS4 <= lenFullTocbufS4 + 1;
				elsif tixVSlot=tixVSlotS5 then
					lenFullTocbufS5 <= lenFullTocbufS5 + 1;
				elsif tixVSlot=tixVSlotS6 then
					lenFullTocbufS6 <= lenFullTocbufS6 + 1;
				elsif tixVSlot=tixVSlotS7 then
					lenFullTocbufS7 <= lenFullTocbufS7 + 1;
				end if;

				if ixTocbufInoutbuf_rd<(lenTocbuf_rd-1) then
					stateOp_next <= stateOpInconfC;
				else
					stateOp_next <= stateOpInconfF;
				end if;

			elsif stateOp=stateOpInconfC then
				-- ixTocbufInbuf++
				if inoutbuf=inbuf0 then
					ixTocbufInbuf0 <= ixTocbufInbuf0 + 1;
				end if;

				aTocbuf_next <= a0Tocbuf + ixTocbufInoutbuf_rd + 1;

				stateOp_next <= stateOpInconfD;

			elsif stateOp=stateOpInconfD then -- enTocbuf='1', weTocbuf='0'
				stateOp_next <= stateOpInconfE;

			elsif stateOp=stateOpInconfE then
				if inoutbuf=inbuf0 then
					pgaInbuf0 <= to_integer(unsigned(drdTocbuf));
				end if;

				stateOp_next <= stateOpInconfF;

			elsif stateOp=stateOpInconfF then -- ackInbufToOpConf='1'
				if reqInbufToOpConf='0' then
					stateOp_next <= stateOpIdle;
				end if;

---
			elsif stateOp=stateOpInstepA then
				-- if lenTocbufInbuf<maxlenTocbufInbuf, alloc new - may result in dny, else lenTocbufInbuf++
				tixVSlot_next <= tixVSlotInoutbuf;

				stateOp_next <= stateOpInstepB;

			elsif stateOp=stateOpInstepB then
				if lenTocbuf_rd<maxlenTocbuf_rd then
					-- allocate new
					j := 0;
					stateOp_next <= stateOpInstepC;
				else
					stateOp_next <= stateOpInstepE;
				end if;

			elsif stateOp=stateOpInstepC then
				if j=pgsizeMem then
					-- no empty pages found
					stateOp_next <= stateOpInstepF;
				else
					if pgbusy(j)='0' then
						-- reserve this page for tixVSlot
						pgbusy(j) <= '1';

						lenTocbuf := lenTocbuf_rd + 1;

						aTocbuf_next <= a0Tocbuf + lenTocbuf_rd;
						dwrTocbuf_next <= "00" & std_logic_vector(to_unsigned(j, 7));

						stateOp_next <= stateOpInstepD;
					else
						j := j + 1;
					end if;
				end if;

			elsif stateOp=stateOpInstepD then -- enTocbuf='1', weTocbuf='1'
				-- lenTocbuf++
				if tixVSlot=tixVSlotS0 then
					lenTocbufS0 <= lenTocbuf;
				elsif tixVSlot=tixVSlotS1 then
					lenTocbufS1 <= lenTocbuf;
				elsif tixVSlot=tixVSlotS2 then
					lenTocbufS2 <= lenTocbuf;
				elsif tixVSlot=tixVSlotS3 then
					lenTocbufS3 <= lenTocbuf;
				elsif tixVSlot=tixVSlotS4 then
					lenTocbufS4 <= lenTocbuf;
				elsif tixVSlot=tixVSlotS5 then
					lenTocbufS5 <= lenTocbuf;
				elsif tixVSlot=tixVSlotS6 then
					lenTocbufS6 <= lenTocbuf;
				elsif tixVSlot=tixVSlotS7 then
					lenTocbufS7 <= lenTocbuf;
				end if;

				stateOp_next <= stateOpInstepE;

			elsif stateOp=stateOpInstepE then -- ackInbufToOpStep='1'
				if reqInbufToOpStep='0' then
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpInstepF then -- dnyInbufToOpStep='1'
				if reqInbufToOpStep='0' then
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpInstopA then
				tixVSlot_next <= tixVSlotInoutbuf;

				instop := '1';

				stateOp_next <= stateOpFreeB;

			elsif stateOp=stateOpInstopB then -- ackInbuf0ToOpStop='1'
				if reqInbufToOpStop='0' then
					instop := '0';

					stateOp_next <= stateOpIdle;
				end if;

---
			elsif stateOp=stateOpOutstaA then
				-- prepare for read to outbuf
				-- ixTocbufOutbuf=ix0FullTocbufS0=0, fetch pgaOutbuf
				tixVSlot_next <= tixVSlotInoutbuf;

				stateOp_next <= stateOpOutstaB;

			elsif stateOp=stateOpOutstaB then
				aTocbuf_next <= a0Tocbuf + ix0FullTocbuf_rd;
				stateOp_next <= stateOpOutstaC;

			elsif stateOp=stateOpOutstaC then -- enTocbuf='1', weTocbuf='0'
				stateOp_next <= stateOpOutstaD;

			elsif stateOp=stateOpOutstaD then
				if inoutbuf=outbuf0 then
					ixTocbufOutbuf0 <= ix0FullTocbuf_rd;
					pgaOutbuf0 <= to_integer(unsigned(drdTocbuf));
				end if;

				stateOp_next <= stateOpOutstaE;

			elsif stateOp=stateOpOutstaE then -- ackOutbufToOpStart='1'
				if reqOutbufToOpStart='0' then
					stateOp_next <= stateOpIdle;
				end if;

---
			elsif stateOp=stateOpOutconfA then
				-- validate ixTocbufOutbuf is within bounds of ix0FullTocbuf .. ix0FullTocbuf+lenTocbufFull-1
				tixVSlot_next <= tixVSlotInoutbuf;

				stateOp_next <= stateOpOutconfB;

			elsif stateOp=stateOpOutconfB then
				if ((ixTocbufInoutbuf_rd>=ix0FullTocbuf_rd) and (ixTocbufInoutbuf_rd<(ix0FullTocbuf_rd+lenFullTocbuf_rd))) then
					stateOp_next <= stateOpOutconfC;
				else
					stateOp_next <= stateOpOutconfD;
				end if;
		
			elsif stateOp=stateOpOutconfC then -- ackOutbufToOpConf='1'
				if reqOutbufToOpConf='0' then
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpOutconfD then -- dnyOutbufToOpConf='1'
				if reqOutbufToOpConf='0' then
					stateOp_next <= stateOpIdle;
				end if;

---
			elsif stateOp=stateOpOutfreeA then
				-- free single page ix0FullTocbuf
				-- ix0FullTocbuf++, lenFullTocbuf--
				tixVSlot_next <= tixVSlotInoutbuf;

				stateOp_next <= stateOpOutfreeB;

			elsif stateOp=stateOpOutfreeB then
				if lenFullTocbuf_rd=0 then
					-- should not happen
					stateOp_next <= stateOpIdle;
				else
					if tixVSlot=tixVSlotS0 then
						ix0FullTocbufS0 <= ix0FullTocbufS0 + 1;
						lenFullTocbufS0 <= lenFullTocbufS0 - 1;
					elsif tixVSlot=tixVSlotS1 then
						ix0FullTocbufS1 <= ix0FullTocbufS1 + 1;
						lenFullTocbufS1 <= lenFullTocbufS1 - 1;
					elsif tixVSlot=tixVSlotS2 then
						ix0FullTocbufS2 <= ix0FullTocbufS2 + 1;
						lenFullTocbufS2 <= lenFullTocbufS2 - 1;
					elsif tixVSlot=tixVSlotS3 then
						ix0FullTocbufS3 <= ix0FullTocbufS3 + 1;
						lenFullTocbufS3 <= lenFullTocbufS3 - 1;
					elsif tixVSlot=tixVSlotS4 then
						ix0FullTocbufS4 <= ix0FullTocbufS4 + 1;
						lenFullTocbufS4 <= lenFullTocbufS4 - 1;
					elsif tixVSlot=tixVSlotS5 then
						ix0FullTocbufS5 <= ix0FullTocbufS5 + 1;
						lenFullTocbufS5 <= lenFullTocbufS5 - 1;
					elsif tixVSlot=tixVSlotS6 then
						ix0FullTocbufS6 <= ix0FullTocbufS6 + 1;
						lenFullTocbufS6 <= lenFullTocbufS6 - 1;
					elsif tixVSlot=tixVSlotS7 then
						ix0FullTocbufS7 <= ix0FullTocbufS7 + 1;
						lenFullTocbufS7 <= lenFullTocbufS7 - 1;
					end if;

					aTocbuf_next <= a0Tocbuf + ix0FullTocbuf_rd;

					stateOp_next <= stateOpOutfreeC;
				end if;

			elsif stateOp=stateOpOutfreeC then -- enTocbuf='1', weTocbuf='0'
				stateOp_next <= stateOpOutfreeD;

			elsif stateOp=stateOpOutfreeD then
				pgbusy(to_integer(unsigned(drdTocbuf))) <= '0';
				stateOp_next <= stateOpOutfreeE;

			elsif stateOp=stateOpOutfreeE then -- ackOutbufToOpFree='1'
				if reqOutbufToOpFree='0' then
					stateOp_next <= stateOpIdle;
				end if;

---
			elsif stateOp=stateOpOutstepA then
				-- move on to next page for read to outbuf
				-- ack requires that page is allocated
				-- ixTocbufOutbuf++, fetch pgaOutbuf
				tixVSlot_next <= tixVSlotInoutbuf;

				stateOp_next <= stateOpOutstepB;

			elsif stateOp=stateOpOutstepB then
				if ixTocbufInoutbuf_rd>=lenTocbuf_rd then
					stateOp_next <= stateOpOutstepF;
				else
					aTocbuf_next <= a0Tocbuf + ixTocbufInoutbuf_rd + 1;
					stateOp_next <= stateOpOutstepC;
				end if;

			elsif stateOp=stateOpOutstepC then -- enTocbuf='1', weTocbuf='0'
				stateOp_next <= stateOpOutstepD;

			elsif stateOp=stateOpOutstepD then
				if inoutbuf=outbuf0 then
					ixTocbufOutbuf0 <= ixTocbufInoutbuf_rd + 1;
					pgaOutbuf0 <= to_integer(unsigned(drdTocbuf));
				end if;
				
				stateOp_next <= stateOpOutstepE;
	
			elsif stateOp=stateOpOutstepE then -- ackOutbufToOpStep='1'
				if reqOutbufToOpStep='0' then
					stateOp_next <= stateOpIdle;
				end if;
			
			elsif stateOp=stateOpOutstepF then -- dnyOutbufToOpStep='1'
				if reqOutbufToOpStep='0' then
					stateOp_next <= stateOpIdle;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			inoutbuf <= inoutbuf_next;
			tixVSlot <= tixVSlot_next;
			aTocbuf <= aTocbuf_next;
			dwrTocbuf <= dwrTocbuf_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: outbuf0 and readOutbuf0 command management (outbuf0)
	------------------------------------------------------------------------

	maxlenOutbuf0_rd <= maxlenTocbufS0 when tixVSlotOutbuf0=tixVSlotS0
				else maxlenTocbufS1 when tixVSlotOutbuf0=tixVSlotS1
				else maxlenTocbufS2 when tixVSlotOutbuf0=tixVSlotS2
				else maxlenTocbufS3 when tixVSlotOutbuf0=tixVSlotS3
				else maxlenTocbufS4 when tixVSlotOutbuf0=tixVSlotS4
				else maxlenTocbufS5 when tixVSlotOutbuf0=tixVSlotS5
				else maxlenTocbufS6 when tixVSlotOutbuf0=tixVSlotS6
				else maxlenTocbufS7 when tixVSlotOutbuf0=tixVSlotS7;

	ackCmdToOutbuf0Inv <= '1' when stateOutbuf0=stateOutbuf0StartB else '0';
	dnyCmdToOutbuf0Inv <= '1' when stateOutbuf0=stateOutbuf0StartC else '0';
	ackCmdToOutbuf0Rev <= '1' when stateOutbuf0=stateOutbuf0Rev else '0';
	reqOutbuf0ToMemRead <= '1' when stateOutbuf0=stateOutbuf0Read else '0';
	reqOutbuf0ToCmdRet <= '1' when stateOutbuf0=stateOutbuf0Ret else '0';
	reqOutbuf0ToCmdErrInvalid <= '1' when stateOutbuf0=stateOutbuf0Err else '0';
	reqOutbuf0ToOpStart <= '1' when stateOutbuf0=stateOutbuf0StartB else '0';
	reqOutbuf0ToOpConf <= '1' when stateOutbuf0=stateOutbuf0Conf else '0';
	reqOutbuf0ToOpFree <= '1' when stateOutbuf0=stateOutbuf0Free else '0';
	reqOutbuf0ToOpStep <= '1' when stateOutbuf0=stateOutbuf0Step else '0';
	ackOutbuf0BToOutbuf0Done <= '1' when stateOutbuf0=stateOutbuf0AckDone else '0';

	process (reset, mclk, stateOutbuf0)
		variable conf: std_logic;

	begin
		if reset='1' then
			stateOutbuf0_next <= stateOutbuf0Init;
			routeReadOutbuf0 <= (others => '0');
			crefReadOutbuf0 <= (others => '0');
			tixVSlotOutbuf0_next <= (others => '0');
			freeNotKeepOutbuf0 <= '0';
			outbuf0Brun_next <= '0';
			highNotLowOutbuf0A_next <= '0';
			lenOutbuf0Low_next <= 0;
			lenOutbuf0High_next <= 0;

		elsif rising_edge(mclk) then
			if stateOutbuf0=stateOutbuf0Init then
				routeReadOutbuf0 <= (others => '0');
				crefReadOutbuf0 <= (others => '0');
				tixVSlotOutbuf0_next <= (others => '0');
				freeNotKeepOutbuf0 <= '0';
				outbuf0Brun_next <= '0';
				highNotLowOutbuf0A_next <= '0';
				lenOutbuf0Low_next <= 0;
				lenOutbuf0High_next <= 0;

				conf := '0';

				stateOutbuf0_next <= stateOutbuf0Idle;

			elsif stateOutbuf0=stateOutbuf0Idle then
				if reqCmdToOutbuf0Inv='1' then
					routeReadOutbuf0 <= cmdbuf(ixCmdbufRoute);

					crefReadOutbuf0(31 downto 24) <= cmdbuf(ixCmdbufCref);
					crefReadOutbuf0(23 downto 16) <= cmdbuf(ixCmdbufCref+1);
					crefReadOutbuf0(15 downto 8) <= cmdbuf(ixCmdbufCref+2);
					crefReadOutbuf0(7 downto 0) <= cmdbuf(ixCmdbufCref+3);
	
					tixVSlotOutbuf0_next <= cmdbuf(ixCmdbufInvReadOutbuf0TixVSlot);
					if cmdbuf(ixCmdbufInvReadOutbuf0FreeNotKeep)=fls8 then
						freeNotKeepOutbuf0 <= '0';
					else
						freeNotKeepOutbuf0 <= '1';
					end if;

					stateOutbuf0_next <= stateOutbuf0StartA;
				end if;

			elsif stateOutbuf0=stateOutbuf0StartA then
				if maxlenOutbuf0_rd/=0 then
					stateOutbuf0_next <= stateOutbuf0StartB;
				else
					stateOutbuf0_next <= stateOutbuf0StartC;
				end if;

			elsif stateOutbuf0=stateOutbuf0StartB then -- ackCmdToOutbuf0Inv='1', reqOutbuf0ToOpStart='1'
				if (reqCmdToOutbuf0Inv='0' and ackOutbuf0ToOpStart='1') then
					outbuf0Brun_next <= '1';
					stateOutbuf0_next <= stateOutbuf0Ready;
				end if;

			elsif stateOutbuf0=stateOutbuf0StartC then -- dnyCmdToOutbuf0Inv='1'
				if reqCmdToOutbuf0Inv='0' then
					stateOutbuf0_next <= stateOutbuf0Init;
				end if;

			elsif stateOutbuf0=stateOutbuf0Ready then
				if maxlenOutbuf0_rd=0 then
					stateOutbuf0_next <= stateOutbuf0Err;

				elsif reqCmdToOutbuf0Rev='1' then
					stateOutbuf0_next <= stateOutbuf0Rev;

				elsif reqOutbuf0BToOutbuf0Done='1' then
					if (lenOutbuf0Low/=0 and lenOutbuf0High/=0) then
						if highNotLowOutbuf0A='0' then
							lenOutbuf0Low_next <= 0;
						else
							lenOutbuf0High_next <= 0;
						end if;
					elsif lenOutbuf0Low/=0 then
						lenOutbuf0Low_next <= 0;
					elsif lenOutbuf0High/=0 then
						lenOutbuf0High_next <= 0;
					end if;

					stateOutbuf0_next <= stateOutbuf0AckDone;

				elsif (conf='0' and ((highNotLowOutbuf0A='0' and lenOutbuf0Low=0) or (highNotLowOutbuf0A='1' and lenOutbuf0High=0))) then
					stateOutbuf0_next <= stateOutbuf0Conf;

				elsif (conf='1' and ixTocbufOutbuf0/=(maxlenOutbuf0_rd-1)) then
					stateOutbuf0_next <= stateOutbuf0Step;
				end if;

			elsif stateOutbuf0=stateOutbuf0AckDone then -- ackOutbuf0BToOutbuf0Done='1'
				if reqOutbuf0BToOutbuf0Done='0' then
					if (ixTocbufOutbuf0=(maxlenOutbuf0_rd-1) and conf='1' and lenOutbuf0Low=0 and lenOutbuf0High=0) then
						stateOutbuf0_next <= stateOutbuf0Ret;
					else
						stateOutbuf0_next <= stateOutbuf0Ready;
					end if;
				end if;

			elsif stateOutbuf0=stateOutbuf0Conf then -- reqOutbuf0ToOpConf='1'
				if ackOutbuf0ToOpConf='1' then
					stateOutbuf0_next <= stateOutbuf0Read;
				elsif dnyOutbuf0ToOpConf='1' then
					stateOutbuf0_next <= stateOutbuf0Ready;
				end if;

			elsif stateOutbuf0=stateOutbuf0Read then -- reqOutbuf0ToMemRead='1'
				if ackOutbuf0ToMemRead='1' then
					if highNotLowOutbuf0A='0' then
						lenOutbuf0Low_next <= sizePg;
					else
						lenOutbuf0High_next <= sizePg;
					end if;
					
					highNotLowOutbuf0A_next <= not highNotLowOutbuf0A;

					conf := '1';

					if freeNotKeepOutbuf0='1' then
						stateOutbuf0_next <= stateOutbuf0Free;
					else
						stateOutbuf0_next <= stateOutbuf0Ready;
					end if;
				end if;

			elsif stateOutbuf0=stateOutbuf0Free then -- reqOutbuf0ToOpFree='1'
				if ackOutbuf0ToOpFree='1' then
					stateOutbuf0_next <= stateOutbuf0Ready;
				end if;

			elsif stateOutbuf0=stateOutbuf0Step then -- reqOutbuf0ToOpStep='1'
				if ackOutbuf0ToOpStep='1' then
					conf := '0';
					stateOutbuf0_next <= stateOutbuf0Ready;
				elsif dnyOutbuf0ToOpStep='1' then
					stateOutbuf0_next <= stateOutbuf0Ready;
				end if;

			elsif stateOutbuf0=stateOutbuf0Rev then -- ackCmdToOutbuf0Rev='1'
				if reqCmdToOutbuf0Rev='0' then
					stateOutbuf0_next <= stateOutbuf0Init;
				end if;

			elsif stateOutbuf0=stateOutbuf0Ret then -- reqOutbuf0ToCmdRet='1'
				if ackOutbuf0ToCmdRet='1' then
					stateOutbuf0_next <= stateOutbuf0Init;
				end if;

			elsif stateOutbuf0=stateOutbuf0Err then -- reqOutbuf0ToCmdErrInvalid='1'
				if ackCmdErrInvalid='1' then
					stateOutbuf0_next <= stateOutbuf0Init;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateOutbuf0 <= stateOutbuf0_next;
			tixVSlotOutbuf0 <= tixVSlotOutbuf0_next;
			outbuf0Brun <= outbuf0Brun_next;
			highNotLowOutbuf0A <= highNotLowOutbuf0A_next;
			lenOutbuf0Low <= lenOutbuf0Low_next;
			lenOutbuf0High <= lenOutbuf0High_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: outbuf0 B outward/hostif-facing operation (outbuf0B)
	------------------------------------------------------------------------

	enOutbuf0B <= '1' when (stateOutbuf0B=stateOutbuf0BXferA or (stateOutbuf0B=stateOutbuf0BXferB and strbDOutbuf0ToHostif='0')) else '0';

	aOutbuf0B_vec <= highNotLowOutbuf0B & std_logic_vector(to_unsigned(aOutbuf0B, 12));

	ackOutbuf0ToHostif <= '1' when (stateOutbuf0B=stateOutbuf0BXferB or stateOutbuf0B=stateOutbuf0BXferC) else '0';

	avllenOutbuf0ToHostif <= std_logic_vector(to_unsigned(avllenOutbuf0ToHostif_sig, 19)) when avllenOutbuf0ToHostif_zero='0' else (others => '0');

	process (reset, clkOutbuf0ToHostif, stateOutbuf0B)
		variable bytecnt: natural range 0 to 491520;

		variable x: std_logic_vector(18 downto 0);

	begin
		if reset='1' then
			stateOutbuf0B_next <= stateOutbuf0BInit;
			aOutbuf0B_next <= 0;
			highNotLowOutbuf0B_next <= '0';
			avllenOutbuf0ToHostif_sig_next <= 0;
			avllenOutbuf0ToHostif_zero_next <= '0';
			reqOutbuf0BToOutbuf0Done_next <= '0';

		elsif rising_edge(clkOutbuf0ToHostif) then
			if (reqOutbuf0BToOutbuf0Done='1' and ackOutbuf0BToOutbuf0Done='1') then
				reqOutbuf0BToOutbuf0Done_next <= '0';
			end if;

			if (stateOutbuf0B=stateOutbuf0BInit or outbuf0Brun='0') then
				aOutbuf0B_next <= 0;
				highNotLowOutbuf0B_next <= '0';
				avllenOutbuf0ToHostif_sig_next <= 0;
				avllenOutbuf0ToHostif_zero_next <= '0';
				reqOutbuf0BToOutbuf0Done_next <= '0';

				if outbuf0Brun='0' then
					stateOutbuf0B_next <= stateOutbuf0BInit;
				else
					stateOutbuf0B_next <= stateOutbuf0BStart;
				end if;

			elsif stateOutbuf0B=stateOutbuf0BStart then
				x := std_logic_vector(to_unsigned(maxlenOutbuf0_rd, 7)) & "000000000000";
				avllenOutbuf0ToHostif_sig_next <= to_integer(unsigned(x));
				avllenOutbuf0ToHostif_zero_next <= '1';
	
				stateOutbuf0B_next <= stateOutbuf0BWaitFull;

			elsif stateOutbuf0B=stateOutbuf0BWaitConfA then
				if (reqOutbuf0BToOutbuf0Done='1' and ackOutbuf0BToOutbuf0Done='1') then
					stateOutbuf0B_next <= stateOutbuf0BWaitConfB;
				end if;

			elsif stateOutbuf0B=stateOutbuf0BWaitConfB then
				reqOutbuf0BToOutbuf0Done_next <= '1';
					if avllenOutbuf0ToHostif_sig=0 then
						stateOutbuf0B_next <= stateOutbuf0BDone;
					else
						highNotLowOutbuf0B_next <= not highNotLowOutbuf0B;
						stateOutbuf0B_next <= stateOutbuf0BWaitFull;
					end if;

			elsif stateOutbuf0B=stateOutbuf0BWaitFull then
				if ((highNotLowOutbuf0B='0' and lenOutbuf0Low/=0) or (highNotLowOutbuf0B='1' and lenOutbuf0High/=0)) then
					avllenOutbuf0ToHostif_zero_next <= '0';
					stateOutbuf0B_next <= stateOutbuf0BReady;
				end if;

			elsif stateOutbuf0B=stateOutbuf0BReady then
				if (reqOutbuf0ToHostif='1' and strbDOutbuf0ToHostif='0') then
					bytecnt := 0;
					stateOutbuf0B_next <= stateOutbuf0BXferA;
				end if;

			elsif stateOutbuf0B=stateOutbuf0BXferA then
				-- load first byte before setting ackOutbuf0ToHostif high
				stateOutbuf0B_next <= stateOutbuf0BXferC;

			elsif stateOutbuf0B=stateOutbuf0BXferB then
				if dneOutbuf0ToHostif='1' then
					-- confirm
					avllenOutbuf0ToHostif_sig_next <= avllenOutbuf0ToHostif_sig - bytecnt;
					if aOutbuf0B=0 then
						avllenOutbuf0ToHostif_zero_next <= '1';
						
						if reqOutbuf0BToOutbuf0Done='1' then
							-- previous read not confirmed
							stateOutbuf0B_next <= stateOutbuf0BWaitConfA;
						else
							stateOutbuf0B_next <= stateOutbuf0BWaitConfB;
						end if;
					else
						stateOutbuf0B_next <= stateOutbuf0BReady;
					end if;

				elsif reqOutbuf0ToHostif='0' then
					-- discard
					aOutbuf0B_next <= aOutbuf0B - bytecnt;
					stateOutbuf0B_next <= stateOutbuf0BReady;

				elsif strbDOutbuf0ToHostif='0' then -- ackOutbuf0ToHostif is '1' here already
					if aOutbuf0B=0 then
						-- continuous xfer beyond buffer size: same as confirm ; on-the-fly if possible
						avllenOutbuf0ToHostif_sig_next <= avllenOutbuf0ToHostif_sig - bytecnt;
						bytecnt := 0;
						
						if reqOutbuf0BToOutbuf0Done='1' then
							-- previous read not confirmed
							avllenOutbuf0ToHostif_zero_next <= '1';
							stateOutbuf0B_next <= stateOutbuf0BWaitConfA;
						else
							if (avllenOutbuf0ToHostif_sig=bytecnt or (highNotLowOutbuf0B='0' and lenOutbuf0High=0) or (highNotLowOutbuf0B='1' and lenOutbuf0Low=0)) then
								-- last page or next high/low empty
								avllenOutbuf0ToHostif_zero_next <= '1';
								stateOutbuf0B_next <= stateOutbuf0BWaitConfB;
							else
								-- success
								reqOutbuf0BToOutbuf0Done_next <= '1';
								highNotLowOutbuf0B_next <= not highNotLowOutbuf0B;
								stateOutbuf0B_next <= stateOutbuf0BXferC;
							end if;
						end if;
					else
						stateOutbuf0B_next <= stateOutbuf0BXferC;
					end if;
				end if;

			elsif stateOutbuf0B=stateOutbuf0BXferC then
				if strbDOutbuf0ToHostif='1' then
					if aOutbuf0B=(sizePg-1) then
						aOutbuf0B_next <= 0;
					else
						aOutbuf0B_next <= aOutbuf0B + 1;
					end if;

					bytecnt := bytecnt + 1;
	
					stateOutbuf0B_next <= stateOutbuf0BXferB;
				end if;

			elsif stateOutbuf0B=stateOutbuf0BDone then
				-- if outbuf0Brun='0' then
				-- 	stateOutbuf0B_next <= stateOutbuf0BInit;
				-- end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			reqOutbuf0BToOutbuf0Done <= reqOutbuf0BToOutbuf0Done_next;
		end if;
	end process;

	process (clkOutbuf0ToHostif)
	begin
		if falling_edge(clkOutbuf0ToHostif) then
			stateOutbuf0B <= stateOutbuf0B_next;
			aOutbuf0B <= aOutbuf0B_next;
			highNotLowOutbuf0B <= highNotLowOutbuf0B_next;
			avllenOutbuf0ToHostif_sig <= avllenOutbuf0ToHostif_sig_next;
			avllenOutbuf0ToHostif_zero <= avllenOutbuf0ToHostif_zero_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	-- debug
	--pgbusy_out <= pgbusy;

end Pmmu_v1_0_120x4kB_8sl;

