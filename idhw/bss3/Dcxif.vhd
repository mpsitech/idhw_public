-- file Dcxif.vhd
-- Dcxif spifwd_v1_0 forwarding controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Idhw.all;
use work.Bss3.all;

entity Dcxif is
	generic (
		fMclk: natural range 1 to 1000000;

		dtPing: natural range 0 to 10000;
		Nretry: natural range 1 to 5
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
end Dcxif;

architecture Dcxif of Dcxif is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Crcp_v1_0 is
		generic (
			poly: std_logic_vector(15 downto 0) := x"8005";
			bitinv: std_logic := '0'
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			fastclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			captNotFin: in std_logic;

			d: in std_logic_vector(7 downto 0);
			strbD: in std_logic;

			crc: out std_logic_vector(15 downto 0)
		);
	end component;

	component Dpbram_v1_0_size2kB is
		port (
			clkA: in std_logic;

			enA: in std_logic;
			weA: in std_logic;

			aA: in std_logic_vector(10 downto 0);
			drdA: out std_logic_vector(7 downto 0);
			dwrA: in std_logic_vector(7 downto 0);

			clkB: in std_logic;

			enB: in std_logic;
			weB: in std_logic;

			aB: in std_logic_vector(10 downto 0);
			drdB: out std_logic_vector(7 downto 0);
			dwrB: in std_logic_vector(7 downto 0)
		);
	end component;

	component Spimaster_v1_0 is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;

			cpol: std_logic := '0';
			cpha: std_logic := '0';

			nssByteNotXfer: std_logic := '0';

			fSclk: natural range 1 to 50000000 := 10000000;
			Nstop: natural range 1 to 8 := 1
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			len: in std_logic_vector(10 downto 0);

			send: in std_logic_vector(7 downto 0);
			strbSend: out std_logic;

			recv: out std_logic_vector(7 downto 0);
			strbRecv: out std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Timeout_v1_0 is
		generic (
			twait: natural range 1 to 10000 := 100
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			restart: in std_logic;
			timeout: out std_logic
		);
	end component;

																				
	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- command execution (cmd)
	type stateCmd_t is (
		stateCmdInit,
		stateCmdEmpty,
		stateCmdWaitLockA, stateCmdWaitLockB, stateCmdWaitLockC,
		stateCmdLock,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE, stateCmdRecvF,
		stateCmdRecvG,
		stateCmdFullA, stateCmdFullB,
		stateCmdSendA, stateCmdSendB, stateCmdSendC, stateCmdSendD,
		stateCmdPrepRetRead,
		stateCmdPrepRetWrite,
		stateCmdPrepCreferrRead, stateCmdPrepCreferrWrite, stateCmdPrepCreferr,
		stateCmdPrepFwderrA, stateCmdPrepFwderrB,
		stateCmdPrepErrBufxferRead,
		stateCmdPrepErrBufxferWrite,
		stateCmdPrepErrBufxfer,
		stateCmdToCmdbufA, stateCmdToCmdbufB,
		stateCmdFromCmdbufA, stateCmdFromCmdbufB
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: reset, read, write
	-- rev: read, write
	-- ret/newret: read, write
	-- err: bufxfer

	constant sizeCmdbuf: natural := 202;

	constant tixVCommandReset: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvReset: natural := 10;

	constant tixVCommandRead: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvRead: natural := 15;
	constant ixCmdbufInvReadTixWDcx3Buffer: natural := 10;
	constant ixCmdbufInvReadReqLen: natural := 11;
	constant lenCmdbufRetRead: natural := 10;

	constant tixVCommandWrite: std_logic_vector(7 downto 0) := x"03";
	constant lenCmdbufInvWrite: natural := 15;
	constant ixCmdbufInvWriteTixWDcx3Buffer: natural := 10;
	constant ixCmdbufInvWriteReqLen: natural := 11;
	constant lenCmdbufRetWrite: natural := 10;

	constant tixVErrorBufxfer: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufErrBufxfer: natural := 10;

	signal lenCmdbuf, lenCmdbuf_next: natural range 0 to sizeCmdbuf;

	signal dFromCmdbuf, dFromCmdbuf_next: std_logic_vector(7 downto 0);

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpIdle,
		stateOpPrepPingA, stateOpPrepPingB,
		stateOpStepRetry,
		stateOpStepXfer,
		stateOpPrepReqbx,
		stateOpPrepReqlen,
		stateOpRxA, stateOpRxB, stateOpRxC, stateOpRxD, stateOpRxE,
		stateOpRxF, stateOpRxG, stateOpRxH, stateOpRxI, stateOpRxJ,
		stateOpRxK,
		stateOpTxA, stateOpTxB, stateOpTxC, stateOpTxD, stateOpTxE,
		stateOpTxF, stateOpTxG, stateOpTxH, stateOpTxI, stateOpTxJ,
		stateOpTxK,
		stateOpAckReset,
		stateOpCnfRd,
		stateOpCnfWr,
		stateOpReadErr,
		stateOpWriteErr,
		stateOpFwderr
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	constant maxlenAuxbuf: natural := 6;

	type auxbuf_t is array (0 to maxlenAuxbuf-1) of std_logic_vector(7 downto 0);
	signal auxbuf: auxbuf_t;

	constant ixAuxbufXfer: natural := 0;
	constant ixAuxbufTkn: natural := 1;

	constant lenAuxbufTkn: natural := 2;

	constant lenAuxbufBx: natural := 3;
	constant ixAuxbufBxBx: natural := 2;

	constant lenAuxbufLen: natural := 6;
	constant ixAuxbufLenLen: natural := 2;

	constant lenAuxbufRd: natural := 4;
	constant ixAuxbufRdRxbuf: natural := 2;
	constant ixAuxbufRdCrc: natural := 2;

	constant lenAuxbufRdack: natural := 2;

	constant lenAuxbufWr: natural := 4;
	constant ixAuxbufWrTxbuf: natural := 2;
	constant ixAuxbufWrCrc: natural := 2;

	constant lenAuxbufWrack: natural := 2;

	constant tknReset: std_logic_vector(7 downto 0) := x"FF";
	constant tknPing: std_logic_vector(7 downto 0) := x"00";
	signal tknFromCmdret: std_logic_vector(7 downto 0) := tixWIdhwDcx3BufferCmdretToHostif;
	signal tknToCmdinv: std_logic_vector(7 downto 0) := tixWIdhwDcx3BufferHostifToCmdinv;
	signal tknFromPmmu: std_logic_vector(7 downto 0) := tixWIdhwDcx3BufferPmmuToHostif;
	signal tknToQcdif: std_logic_vector(7 downto 0) := tixWIdhwDcx3BufferHostifToQcdif;
	signal tknFromQcdif: std_logic_vector(7 downto 0) := tixWIdhwDcx3BufferQcdifToHostif;

	signal tixDbeVXfer: std_logic_vector(7 downto 0) := tixDbeVXferVoid;
	signal tkn, tkn_next: std_logic_vector(7 downto 0);

	signal reqbx: std_logic_vector(7 downto 0);

	constant ixReqbxFromCmdret: natural := 0;
	constant ixReqbxToCmdinv: natural := 1;
	constant ixReqbxFromPmmu: natural := 2;
	constant ixReqbxToQcdif: natural := 3;
	constant ixReqbxFromQcdif: natural := 4;

	signal reqlen: std_logic_vector(31 downto 0);

	signal d, d_next: std_logic_vector(7 downto 0);

	signal crcRxbuf: std_logic_vector(15 downto 0);

	signal reqRxbuf, reqRxbuf_next: std_logic;
	signal ackRxbuf: std_logic;
	signal dneRxbuf: std_logic;

	signal dRxbuf, dRxbuf_next: std_logic_vector(7 downto 0);
	signal strbDRxbuf: std_logic;

	signal reqTxbuf, reqTxbuf_next: std_logic;
	signal ackTxbuf: std_logic;
	signal dneTxbuf: std_logic;

	signal dTxbuf, dTxbuf_next: std_logic_vector(7 downto 0);
	signal strbDTxbuf: std_logic;

	signal strbDFromCmdbuf: std_logic;

	signal dToCmdbuf, dToCmdbuf_next: std_logic_vector(7 downto 0);
	signal strbDToCmdbuf: std_logic;

	signal reqRdbuf: std_logic;
	signal dneRdbuf: std_logic;
	
	signal strbDRdbuf: std_logic;
	
	signal reqWrbuf: std_logic;
	signal dneWrbuf: std_logic;
	
	signal strbDWrbuf: std_logic;

	signal crccaptNotFin: std_logic;

	signal crcd, crcd_next: std_logic_vector(7 downto 0);
	signal strbCrcd: std_logic;

	signal wurestart, wurestart_next: std_logic;

	-- timeout error not applicable
	type rxerr_t is (
		rxerrOk,
		rxerrXfer,
		rxerrTkn
	);
	signal rxerr: rxerr_t;

	signal spilen: std_logic_vector(10 downto 0);

	signal spisend: std_logic_vector(7 downto 0);

	---- rdbuf
	constant sizeRdbuf: natural := 1024;

	---- rdbuf outward/hostif-facing operation (rdbufB)
	type stateRdbufB_t is (
		stateRdbufBInit,
		stateRdbufBStart,
		stateRdbufBWaitFull,
		stateRdbufBReady,
		stateRdbufBReadA, stateRdbufBReadB, stateRdbufBReadC,
		stateRdbufBFlip,
		stateRdbufBDone
	);
	signal stateRdbufB, stateRdbufB_next: stateRdbufB_t := stateRdbufBInit;

	signal enRdbufB: std_logic;
	
	signal aRdbufB, aRdbufB_next: natural range 0 to sizeRdbuf-1;
	signal aRdbufB_vec: std_logic_vector(10 downto 0);

	signal highNotLowRdbufB, highNotLowRdbufB_next: std_logic;

	signal avllenRdbufB, avllenRdbufB_next: natural range 0 to 1024; -- TBD
	signal avllenRdbufB_zero, avllenRdbufB_zero_next: std_logic;

	---- read command (read)
	type stateRead_t is (
		stateReadInit,
		stateReadIdle,
		stateReadStart,
		stateReadReady,
		stateReadWriteA, stateReadWriteB, stateReadWriteC, stateReadWriteD,
		stateReadFlipA, stateReadFlipB,
		stateReadAckResetRev,
		stateReadRet,
		stateReadErrA, stateReadErrB
	);
	signal stateRead, stateRead_next: stateRead_t := stateReadInit;

	signal routeRead: std_logic_vector(7 downto 0);
	signal crefRead: std_logic_vector(31 downto 0);

	signal tixWDcx3BufferRead, tixWDcx3BufferRead_next: std_logic_vector(7 downto 0);
	signal reqlenRead: std_logic_vector(31 downto 0);

	signal rdbufBrun, rdbufBrun_next: std_logic;

	signal enRdbuf: std_logic;

	signal aRdbuf, aRdbuf_next: natural range 0 to sizeRdbuf-1;
	signal aRdbuf_vec: std_logic_vector(10 downto 0);

	signal highNotLowRdbufA, highNotLowRdbufA_next: std_logic;

	signal lenRdbufLow, lenRdbufLow_next: natural range 0 to sizeRdbuf := 0;
	signal lenRdbufHigh, lenRdbufHigh_next: natural range 0 to sizeRdbuf := 0;

	signal ackRdbuf: std_logic;

	signal reqlenRdbuf, reqlenRdbuf_next: natural range 0 to 1024; -- TBD
	signal reqlenRdbuf_zero, reqlenRdbuf_zero_next: std_logic;

	---- wrbuf
	constant sizeWrbuf: natural := 1024;

	---- wrbuf outward/hostif-facing operation (wrbufB)
	type stateWrbufB_t is (
		stateWrbufBInit,
		stateWrbufBStart,
		stateWrbufBWaitEmpty,
		stateWrbufBReady,
		stateWrbufBWriteA, stateWrbufBWriteB, stateWrbufBWriteC,
		stateWrbufBFlip,
		stateWrbufBDone
	);
	signal stateWrbufB, stateWrbufB_next: stateWrbufB_t := stateWrbufBInit;

	signal enWrbufB: std_logic;
	
	signal aWrbufB, aWrbufB_next: natural range 0 to sizeWrbuf-1;
	signal aWrbufB_vec: std_logic_vector(10 downto 0);

	signal highNotLowWrbufB, highNotLowWrbufB_next: std_logic;

	signal avllenWrbufB, avllenWrbufB_next: natural range 0 to 1024; -- TBD
	signal avllenWrbufB_zero, avllenWrbufB_zero_next: std_logic;

	---- wrbuf and write command management (write)
	type stateWrite_t is (
		stateWriteInit,
		stateWriteIdle,
		stateWriteStart,
		stateWriteReady,
		stateWriteReadA, stateWriteReadB, stateWriteReadC, stateWriteReadD,
		stateWriteFlipA, stateWriteFlipB,
		stateWriteAckResetRev,
		stateWriteRet,
		stateWriteErrA, stateWriteErrB
	);
	signal stateWrite, stateWrite_next: stateWrite_t := stateWriteInit;

	signal routeWrite: std_logic_vector(7 downto 0);
	signal crefWrite: std_logic_vector(31 downto 0);

	signal tixWDcx3BufferWrite, tixWDcx3BufferWrite_next: std_logic_vector(7 downto 0);
	signal reqlenWrite: std_logic_vector(31 downto 0);

	signal wrbufBrun, wrbufBrun_next: std_logic;

	signal enWrbuf: std_logic;

	signal aWrbuf, aWrbuf_next: natural range 0 to sizeWrbuf-1;
	signal aWrbuf_vec: std_logic_vector(10 downto 0);

	signal highNotLowWrbufA, highNotLowWrbufA_next: std_logic;

	signal lenWrbufLow, lenWrbufLow_next: natural range 0 to sizeWrbuf := 0;
	signal lenWrbufHigh, lenWrbufHigh_next: natural range 0 to sizeWrbuf := 0;

	signal ackWrbuf: std_logic;

	signal reqlenWrbuf, reqlenWrbuf_next: natural range 0 to 1024; -- TBD
	signal reqlenWrbuf_zero, reqlenWrbuf_zero_next: std_logic;

	---- myCrc
	signal crc: std_logic_vector(15 downto 0);

	---- mySpi
	signal strbSpisend: std_logic;

	signal spirecv: std_logic_vector(7 downto 0);
	signal strbSpirecv: std_logic;

	---- myRdbuf
	signal dRdbuf: std_logic_vector(7 downto 0);

	---- myWakeup
	signal wakeup: std_logic;

	---- myWrbuf
	signal dWrbuf: std_logic_vector(7 downto 0);

	---- handshake
	-- cmd to (many)
	signal reqCmdInvReset, reqCmdInvReset_next: std_logic;
	signal ackCmdToOpInvReset: std_logic;
	signal ackCmdToReadInvReset, ackCmdToReadInvReset_next: std_logic;
	signal ackCmdToWriteInvReset, ackCmdToWriteInvReset_next: std_logic;

	-- cmd to read
	signal reqCmdToReadInv, reqCmdToReadInv_next: std_logic;
	signal ackCmdToReadInv: std_logic;

	-- op to myCrc
	signal reqCrc: std_logic;
	signal ackCrc: std_logic;
	signal dneCrc: std_logic;

	-- cmd to read
	signal reqCmdToReadRev, reqCmdToReadRev_next: std_logic;
	signal ackCmdToReadRev, ackCmdToReadRev_next: std_logic;

	-- cmd to write
	signal reqCmdToWriteInv, reqCmdToWriteInv_next: std_logic;
	signal ackCmdToWriteInv: std_logic;

	-- cmd to write
	signal reqCmdToWriteRev, reqCmdToWriteRev_next: std_logic;
	signal ackCmdToWriteRev, ackCmdToWriteRev_next: std_logic;

	-- op to cmd
	signal reqOpToCmdLock, reqOpToCmdLock_next: std_logic;
	signal ackOpToCmdLock: std_logic;
	signal dnyOpToCmdLock: std_logic;

	-- op to mySpi
	signal reqSpi: std_logic;
	signal ackSpi: std_logic;
	signal dneSpi: std_logic;

	-- op to cmd
	signal reqOpToCmdToCmdbuf: std_logic;
	signal ackOpToCmdToCmdbuf: std_logic;
	signal dneOpToCmdToCmdbuf: std_logic;

	-- op to cmd
	signal reqOpToCmdFromCmdbuf: std_logic;
	signal ackOpToCmdFromCmdbuf: std_logic;
	signal dneOpToCmdFromCmdbuf: std_logic;

	-- op to cmd
	signal reqOpToCmdFwderr: std_logic;
	signal ackOpToCmdFwderr, ackOpToCmdFwderr_next: std_logic;

	-- op to read
	signal reqOpToReadErr: std_logic;
	signal ackOpToReadErr: std_logic;

	-- rdbufB to read
	signal reqRdbufBToReadDone: std_logic;
	signal ackRdbufBToReadDone: std_logic;

	-- read to cmd
	signal reqReadToCmdRet: std_logic;
	signal ackReadToCmdRet, ackReadToCmdRet_next: std_logic;

	-- op to write
	signal reqOpToWriteErr: std_logic;
	signal ackOpToWriteErr: std_logic;

	-- wrbufB to write
	signal reqWrbufBToWriteDone: std_logic;
	signal ackWrbufBToWriteDone: std_logic;

	-- write to cmd
	signal reqWriteToCmdRet: std_logic;
	signal ackWriteToCmdRet, ackWriteToCmdRet_next: std_logic;

	-- (many) to cmd
	signal reqReadToCmdErrBufxfer: std_logic;
	signal reqWriteToCmdErrBufxfer: std_logic;
	signal ackCmdErrBufxfer, ackCmdErrBufxfer_next: std_logic;

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myCrc : Crcp_v1_0
		port map (
			reset => reset,
			mclk => mclk,
			fastclk => fastclk,

			req => reqCrc,
			ack => ackCrc,
			dne => dneCrc,

			captNotFin => crccaptNotFin,

			d => crcd,
			strbD => strbCrcd,

			crc => crc
		);

	myRdbuf : Dpbram_v1_0_size2kB
		port map (
			clkA => mclk,

			enA => enRdbuf,
			weA => '1',

			aA => aRdbuf_vec,
			drdA => open,
			dwrA => dRdbuf,

			clkB => mclk,

			enB => enRdbufB,
			weB => '0',

			aB => aRdbufB_vec,
			drdB => dRdbufToHostif,
			dwrB => x"00"
		);

	mySpi : Spimaster_v1_0
		port map (
			reset => reset,
			mclk => mclk,

			req => reqSpi,
			ack => ackSpi,
			dne => dneSpi,

			len => spilen,

			send => spisend,
			strbSend => strbSpisend,

			recv => spirecv,
			strbRecv => strbSpirecv,

			nss => nss,
			sclk => sclk,
			mosi => mosi,
			miso => miso
		);

	myWakeup : Timeout_v1_0
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			restart => wurestart,
			timeout => wakeup
		);

	myWrbuf : Dpbram_v1_0_size2kB
		port map (
			clkA => mclk,

			enA => enWrbuf,
			weA => '0',

			aA => aWrbuf_vec,
			drdA => dWrbuf,
			dwrA => x"00",

			clkB => mclk,

			enB => enWrbufB,
			weB => '1',

			aB => aWrbufB_vec,
			drdB => open,
			dwrB => dWrbufFromHostif
		);

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	ackOpToCmdLock <= '0' when stateCmd=stateCmdLock else '1';
	dnyOpToCmdLock <= '1' when (stateCmd=stateCmdWaitLockA or stateCmd=stateCmdWaitLockB or stateCmd=stateCmdWaitLockC) else '0';

	ackOpToCmdToCmdbuf <= '0' when (stateCmd=stateCmdToCmdbufA or stateCmd=stateCmdToCmdbufB) else '1';

	ackOpToCmdFromCmdbuf <= '0' when (stateCmd=stateCmdFromCmdbufA or stateCmd=stateCmdFromCmdbufB) else '1';

	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- BEGIN
		variable i: natural range 0 to sizeCmdbuf := 0;
		variable j: natural range 0 to sizeCmdbuf := 0;
		variable x: std_logic_vector(7 downto 0) := x"00";

		variable bytecnt: natural range 0 to sizeCmdbuf := 0;
		-- IP impl.cmd.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			lenCmdbuf_next <= 0;
			dFromCmdbuf_next <= x"00";
			reqCmdInvReset_next <= '0';
			reqCmdToReadInv_next <= '0';
			reqCmdToReadRev_next <= '0';
			reqCmdToWriteInv_next <= '0';
			reqCmdToWriteRev_next <= '0';
			ackOpToCmdFwderr_next <= '0';
			ackReadToCmdRet_next <= '0';
			ackWriteToCmdRet_next <= '0';
			ackCmdErrBufxfer_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			reqCmdbusToCmdret_sig_next <= '0';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				lenCmdbuf_next <= 0;
				dFromCmdbuf_next <= x"00";
				reqCmdInvReset_next <= '0';
				reqCmdToReadInv_next <= '0';
				reqCmdToReadRev_next <= '0';
				reqCmdToWriteInv_next <= '0';
				reqCmdToWriteRev_next <= '0';
				ackOpToCmdFwderr_next <= '0';
				ackReadToCmdRet_next <= '0';
				ackWriteToCmdRet_next <= '0';
				ackCmdErrBufxfer_next <= '0';
				rdyCmdbusFromCmdinv_sig_next <= '1';
				reqCmdbusToCmdret_sig_next <= '0';

				i := 0;
				j := 0;
				x := x"00";
				bytecnt := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;

				elsif (reqOpToCmdLock='1' or reqReadToCmdRet='1' or reqWriteToCmdRet='1' or reqReadToCmdErrBufxfer='1' or reqWriteToCmdErrBufxfer='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';

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
					if rdCmdbusFromCmdinv='0' then
						if reqOpToCmdLock='1' then
							stateCmd_next <= stateCmdLock;

						elsif reqReadToCmdRet='1' then
							stateCmd_next <= stateCmdPrepRetRead;

						elsif reqWriteToCmdRet='1' then
							stateCmd_next <= stateCmdPrepRetWrite;

						elsif reqReadToCmdErrBufxfer='1' then
							stateCmd_next <= stateCmdPrepErrBufxferRead;

						elsif reqWriteToCmdErrBufxfer='1' then
							stateCmd_next <= stateCmdPrepErrBufxferWrite;

						else
							stateCmd_next <= stateCmdInit;
						end if;

					else
						stateCmd_next <= stateCmdRecvA;
					end if;
				end if;

			elsif stateCmd=stateCmdLock then
				if (reqOpToCmdLock='0' and lenCmdbuf=0) then
					stateCmd_next <= stateCmdInit;

				elsif reqOpToCmdToCmdbuf='1' then
					lenCmdbuf_next <= 0;

					stateCmd_next <= stateCmdToCmdbufB;

				elsif reqOpToCmdFromCmdbuf='1' then
					bytecnt := 0;

					dFromCmdbuf_next <= cmdbuf(0);

					stateCmd_next <= stateCmdFromCmdbufB;

				elsif reqOpToCmdFwderr='1' then
					i := ixCmdbufFwderrRoute+1;
					j := ixCmdbufRoute;

					stateCmd_next <= stateCmdPrepFwderrA;
				end if;

			elsif stateCmd=stateCmdRecvA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvB then
				if clkCmdbus='1' then
					if rdCmdbusFromCmdinv='0' then
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
					lenCmdbuf_next <= lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvD then
				if j=4 then
					cmdbuf(ixCmdbufRoute+3) <= x"00";

					stateCmd_next <= stateCmdRecvF;

				else
					if (i=0 and cmdbuf(j)=x"00") then
						x := tixVIdhwBss3ControllerCmdret;
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
				if cmdbuf(ixCmdbufRoute)=x"00" then
					if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandReset and lenCmdbuf=lenCmdbufInvReset) then
						reqCmdInvReset_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandRead and lenCmdbuf=lenCmdbufInvRead) then
						if crefRead=x"00000000" then
							reqCmdToReadInv_next <= '1';

							stateCmd_next <= stateCmdRecvG;

						else
							stateCmd_next <= stateCmdPrepCreferrRead;
						end if;

					elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandWrite and lenCmdbuf=lenCmdbufInvWrite) then
						if crefWrite=x"00000000" then
							reqCmdToWriteInv_next <= '1';

							stateCmd_next <= stateCmdRecvG;

						else
							stateCmd_next <= stateCmdPrepCreferrWrite;
						end if;

					elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRev and lenCmdbuf=lenCmdbufRev) then
						if (cmdbuf(ixCmdbufCref)=crefRead(31 downto 24) and cmdbuf(ixCmdbufCref+1)=crefRead(23 downto 16) and cmdbuf(ixCmdbufCref+2)=crefRead(15 downto 8) and cmdbuf(ixCmdbufCref+3)=crefRead(7 downto 0)) then
							reqCmdToReadRev_next <= '1';

							stateCmd_next <= stateCmdRecvG;

						elsif (cmdbuf(ixCmdbufCref)=crefWrite(31 downto 24) and cmdbuf(ixCmdbufCref+1)=crefWrite(23 downto 16) and cmdbuf(ixCmdbufCref+2)=crefWrite(15 downto 8) and cmdbuf(ixCmdbufCref+3)=crefWrite(7 downto 0)) then
							reqCmdToWriteRev_next <= '1';

							stateCmd_next <= stateCmdRecvG;

						else
							stateCmd_next <= stateCmdInit;
						end if;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				else
					stateCmd_next <= stateCmdLock;
				end if;

			elsif stateCmd=stateCmdRecvG then
				if ((reqCmdInvReset='1' and ackCmdToOpInvReset='1' and ackCmdToReadInvReset='1' and ackCmdToWriteInvReset='1') or (reqCmdToReadInv='1' and ackCmdToReadInv='1') or (reqCmdToReadRev='1' and ackCmdToReadRev='1') or (reqCmdToWriteInv='1' and ackCmdToWriteInv='1') or (reqCmdToWriteRev='1' and ackCmdToWriteRev='1')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullA then
				if cmdbuf(ixCmdbufRoute)=tixVIdhwBss3ControllerCmdret then
					reqCmdbusToCmdret_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullB then
				if (wrCmdbusToCmdret='1' and clkCmdbus='1') then
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
						end if;

						stateCmd_next <= stateCmdSendA;
					end if;
				end if;

			elsif stateCmd=stateCmdSendC then
				if wrCmdbusToCmdret='0' then
					if (reqOpToCmdFwderr='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionFwderr) then
						ackOpToCmdFwderr_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqReadToCmdRet='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionRet) then
						ackReadToCmdRet_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqWriteToCmdRet='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionRet) then
						ackWriteToCmdRet_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqReadToCmdErrBufxfer='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionErr and cmdbuf(ixCmdbufErrError)=tixVErrorBufxfer) then
						ackCmdErrBufxfer_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqWriteToCmdErrBufxfer='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionErr and cmdbuf(ixCmdbufErrError)=tixVErrorBufxfer) then
						ackCmdErrBufxfer_next <= '1';

						stateCmd_next <= stateCmdSendD;

					else
						stateCmd_next <= stateCmdInit;
					end if;
				end if;

			elsif stateCmd=stateCmdSendD then
				if ((reqReadToCmdRet='0' and ackReadToCmdRet='1') or (reqWriteToCmdRet='0' and ackWriteToCmdRet='1') or (reqReadToCmdErrBufxfer='0' and reqWriteToCmdErrBufxfer='0' and ackCmdErrBufxfer='1')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdPrepRetRead then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				cmdbuf(ixCmdbufCref) <= crefRead(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefRead(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefRead(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefRead(7 downto 0);

				lenCmdbuf_next <= lenCmdbufRetRead;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepRetWrite then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				cmdbuf(ixCmdbufCref) <= crefWrite(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefWrite(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefWrite(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefWrite(7 downto 0);

				lenCmdbuf_next <= lenCmdbufRetWrite;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepCreferrRead then
				cmdbuf(ixCmdbufCreferrCref) <= crefRead(31 downto 24);
				cmdbuf(ixCmdbufCreferrCref+1) <= crefRead(23 downto 16);
				cmdbuf(ixCmdbufCreferrCref+2) <= crefRead(15 downto 8);
				cmdbuf(ixCmdbufCreferrCref+3) <= crefRead(7 downto 0);

				stateCmd_next <= stateCmdPrepCreferr;

			elsif stateCmd=stateCmdPrepCreferrWrite then
				cmdbuf(ixCmdbufCreferrCref) <= crefWrite(31 downto 24);
				cmdbuf(ixCmdbufCreferrCref+1) <= crefWrite(23 downto 16);
				cmdbuf(ixCmdbufCreferrCref+2) <= crefWrite(15 downto 8);
				cmdbuf(ixCmdbufCreferrCref+3) <= crefWrite(7 downto 0);

				stateCmd_next <= stateCmdPrepCreferr;

			elsif stateCmd=stateCmdPrepCreferr then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionCreferr;

				lenCmdbuf_next <= lenCmdbufCreferr;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepFwderrA then
				if j=4 then
					cmdbuf(ixCmdbufAction) <= tixDbeVActionFwderr;
					cmdbuf(ixCmdbufFwderrRoute) <= tixVIdhwBss3ControllerDcxif;

					lenCmdbuf_next <= lenCmdbufFwderr;

					stateCmd_next <= stateCmdFullA;

				else
					x := cmdbuf(j);

					stateCmd_next <= stateCmdPrepFwderrB;
				end if;

			elsif stateCmd=stateCmdPrepFwderrB then
				cmdbuf(i) <= x;

				i := i + 1;
				j := j + 1;

				stateCmd_next <= stateCmdPrepFwderrA;

			elsif stateCmd=stateCmdPrepErrBufxferRead then
				cmdbuf(ixCmdbufRoute) <= routeRead;
				cmdbuf(ixCmdbufCref) <= crefRead(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefRead(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefRead(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefRead(7 downto 0);

				stateCmd_next <= stateCmdPrepErrBufxfer;

			elsif stateCmd=stateCmdPrepErrBufxferWrite then
				cmdbuf(ixCmdbufRoute) <= routeWrite;
				cmdbuf(ixCmdbufCref) <= crefWrite(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefWrite(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefWrite(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefWrite(7 downto 0);

				stateCmd_next <= stateCmdPrepErrBufxfer;

			elsif stateCmd=stateCmdPrepErrBufxfer then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionErr;
				cmdbuf(ixCmdbufErrError) <= tixVErrorBufxfer;

				lenCmdbuf_next <= lenCmdbufErrBufxfer;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdToCmdbufA then
				if reqOpToCmdToCmdbuf='0' then
					lenCmdbuf_next <= 0;

					stateCmd_next <= stateCmdLock;

				elsif dneOpToCmdToCmdbuf='1' then
					stateCmd_next <= stateCmdFullA;

				elsif strbDToCmdbuf='0' then
					stateCmd_next <= stateCmdToCmdbufB;
				end if;

			elsif stateCmd=stateCmdToCmdbufB then
				if strbDToCmdbuf='1' then
					cmdbuf(lenCmdbuf) <= dToCmdbuf;
					lenCmdbuf_next <= lenCmdbuf + 1;

					stateCmd_next <= stateCmdToCmdbufA;
				end if;

			elsif stateCmd=stateCmdFromCmdbufA then
				if reqOpToCmdFromCmdbuf='0' then
					stateCmd_next <= stateCmdLock;

				elsif dneOpToCmdFromCmdbuf='1' then
					stateCmd_next <= stateCmdInit;

				elsif strbDFromCmdbuf='0' then
					dFromCmdbuf_next <= cmdbuf(bytecnt);

					stateCmd_next <= stateCmdFromCmdbufB;
				end if;

			elsif stateCmd=stateCmdFromCmdbufB then
				if strbDFromCmdbuf='1' then
					bytecnt := bytecnt + 1;

					stateCmd_next <= stateCmdFromCmdbufA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.cmd.rising --- END

	-- IP impl.cmd.falling --- BEGIN
	process (mclk)
	begin
		if falling_edge(mclk) then
			stateCmd <= stateCmd_next;
			lenCmdbuf <= lenCmdbuf_next;
			dFromCmdbuf <= dFromCmdbuf_next;
			reqCmdInvReset <= reqCmdInvReset_next;
			reqCmdToReadInv <= reqCmdToReadInv_next;
			reqCmdToReadRev <= reqCmdToReadRev_next;
			reqCmdToWriteInv <= reqCmdToWriteInv_next;
			reqCmdToWriteRev <= reqCmdToWriteRev_next;
			ackOpToCmdFwderr <= ackOpToCmdFwderr_next;
			ackReadToCmdRet <= ackReadToCmdRet_next;
			ackWriteToCmdRet <= ackWriteToCmdRet_next;
			ackCmdErrBufxfer <= ackCmdErrBufxfer_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			dCmdbus_sig <= dCmdbus_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	reqbx(ixReqbxFromCmdret) <= '1' when (ackOpToCmdLock='1' and lenCmdbuf=0) else '0';
	reqbx(ixReqbxToCmdinv) <= '1' when (ackOpToCmdLock='1' and lenCmdbuf/=0) else '0';
	reqbx(ixReqbxFromPmmu) <= '1' when (tixWDcx3BufferRead=tixWIdhwDcx3BufferPmmuToHostif and reqlenRdbuf/=0 and reqlenRdbuf_zero='0') else '0';
	reqbx(ixReqbxToQcdif) <= '1' when (tixWDcx3BufferWrite=tixWIdhwDcx3BufferHostifToQcdif and reqlenWrbuf/=0 and reqlenWrbuf_zero='0') else '0';
	reqbx(ixReqbxFromQcdif) <= '1' when (tixWDcx3BufferRead=tixWIdhwDcx3BufferQcdifToHostif and reqlenRdbuf/=0 and reqlenRdbuf_zero='0') else '0';
	reqbx(5) <= '0';
	reqbx(6) <= '0';
	reqbx(7) <= '0';

	reqlen <= std_logic_vector(to_unsigned(sizeCmdbuf, 32)) when (tkn=tixWIdhwDcx3BufferCmdretToHostif or tkn=(not tixWIdhwDcx3BufferCmdretToHostif))
				else std_logic_vector(to_unsigned(lenCmdbuf, 32)) when (tkn=tixWIdhwDcx3BufferHostifToCmdinv or tkn=(not tixWIdhwDcx3BufferHostifToCmdinv))
				else "00000000000000000000" & std_logic_vector(to_unsigned(reqlenRdbuf, 12)) when (tkn=tixWIdhwDcx3BufferPmmuToHostif or tkn=(not tixWIdhwDcx3BufferPmmuToHostif) or tkn=tixWIdhwDcx3BufferQcdifToHostif or tkn=(not tixWIdhwDcx3BufferQcdifToHostif))
				else "00000000000000000000" & std_logic_vector(to_unsigned(reqlenWrbuf, 12)) when (tkn=tixWIdhwDcx3BufferHostifToQcdif or tkn=(not tixWIdhwDcx3BufferHostifToQcdif))
				else (others => '0');

	ackRxbuf <= ackOpToCmdToCmdbuf when (tkn=tixWIdhwDcx3BufferCmdretToHostif or tkn=(not tixWIdhwDcx3BufferCmdretToHostif))
				else ackRdbuf when (tkn=tixWIdhwDcx3BufferPmmuToHostif or tkn=(not tixWIdhwDcx3BufferPmmuToHostif) or tkn=tixWIdhwDcx3BufferQcdifToHostif or tkn=(not tixWIdhwDcx3BufferQcdifToHostif))
				else '0';

	dneRxbuf <= '1' when stateOp=stateOpCnfrd else '0';

	strbDRxbuf <= '0' when (stateOp=stateOpRxD or stateOp=stateOpRxE) else '1';

	ackTxbuf <= ackOpToCmdFromCmdbuf when (tkn=tixWIdhwDcx3BufferHostifToCmdinv or tkn=(not tixWIdhwDcx3BufferHostifToCmdinv))
				else ackWrbuf when (tkn=tixWIdhwDcx3BufferHostifToQcdif or tkn=(not tixWIdhwDcx3BufferHostifToQcdif))
				else '0';

	dneTxbuf <= '1' when stateOp=stateOpCnfwr else '0';

	dTxbuf <= dFromCmdbuf when (tkn=tixWIdhwDcx3BufferHostifToCmdinv or tkn=(not tixWIdhwDcx3BufferHostifToCmdinv))
				else dWrbuf when (tkn=tixWIdhwDcx3BufferHostifToQcdif or tkn=(not tixWIdhwDcx3BufferHostifToQcdif))
				else x"00";

	strbDTxbuf <= '0' when (stateOp=stateOpTxD or stateOp=stateOpTxE) else '1';

	reqCrc <= '1' when (stateOp=stateOpRxD or stateOp=stateOpRxE or stateOp=stateOpRxF or stateOp=stateOpRxG or stateOp=stateOpRxH
				or stateOp=stateOpTxD or stateOp=stateOpTxE or stateOp=stateOpTxF or stateOp=stateOpTxG or stateOp=stateOpTxH)
				else '0';

	crccaptNotFin <= '1' when (stateOp=stateOpRxD or stateOp=stateOpRxE or stateOp=stateOpRxF or stateOp=stateOpRxG or stateOp=stateOpTxH)
				else '0';

	strbCrcd <= '0' when (stateOp=stateOpRxD or stateOp=stateOpRxE or stateOp=stateOpRxG or stateOp=stateOpRxH or stateOp=stateOpTxD
				or stateOp=stateOpTxE or stateOp=stateOpTxG or stateOp=stateOpTxH)
				else '1';

	reqSpi <= '1' when (stateOp=stateOpRxA or stateOp=stateOpRxB or stateOp=stateOpRxC or stateOp=stateOpRxD or stateOp=stateOpRxE
				or stateOp=stateOpRxF or stateOp=stateOpRxG or stateOp=stateOpRxH or stateOp=stateOpRxI or stateOp=stateOpRxJ
				or stateOp=stateOpTxA or stateOp=stateOpTxB or stateOp=stateOpTxC or stateOp=stateOpTxD or stateOp=stateOpTxE
				or stateOp=stateOpTxF or stateOp=stateOpTxG or stateOp=stateOpTxH or stateOp=stateOpTxI or stateOp=stateOpTxJ)
				else '0';

	spisend <= dTxbuf when (stateOp=stateOpTxD or stateOp=stateOpTxE or stateOp=stateOpTxF or stateOp=stateOpTxG or stateOp=stateOpTxH) else d;

	ackCmdToOpInvReset <= '1' when stateOp=stateOpAckReset else '0';
	reqOpToReadErr <= '1' when stateOp=stateOpReadErr else '0';
	reqOpToWriteErr <= '1' when stateOp=stateOpWriteErr else '0';
	reqOpToCmdFwderr <= '1' when stateOp=stateOpFwderr else '0';

	-- to cmdbuf
	reqOpToCmdToCmdbuf <= reqRxbuf when tkn=tknFromCmdret else '0';
	dneOpToCmdToCmdbuf <= dneRxbuf when tkn=tknFromCmdret else '0';

	dToCmdbuf <= dRxbuf;
	strbDToCmdbuf <= strbDRxbuf;

	-- from cmdbuf
	reqOpToCmdFromCmdbuf <= reqTxbuf when tkn=tknToCmdinv else '0';
	dneOpToCmdFromCmdbuf <= dneTxbuf when tkn=tknToCmdinv else '0';

	strbDFromCmdbuf <= strbDTxbuf;

	-- to rdbuf / from fromPmmu, fromQcdif
	reqRdbuf <= reqRxbuf when (tkn=tknFromPmmu or tkn=tknFromQcdif) else '0';
	dneRdbuf <= dneRxbuf when (tkn=tknFromPmmu or tkn=tknFromQcdif) else '0';

	dRdbuf <= dRxbuf;
	strbDRdbuf <= strbDRxbuf;

	-- from wrbuf / to toQcdif
	reqWrbuf <= reqTxbuf when (tkn=tknToQcdif) else '0';
	dneWrbuf <= dneTxbuf when (tkn=tknToQcdif) else '0';

	strbDWrbuf <= strbDTxbuf;

	process (reset, mclk, stateOp)
		variable retry: natural range 0 to Nretry;

		variable avlbx: std_logic_vector(7 downto 0);
		variable arbbx: std_logic_vector(7 downto 0);

		variable avllen: std_logic_vector(31 downto 0);
		variable arblen: std_logic_vector(31 downto 0);

		variable i: natural range 0 to maxlenAuxbuf;
		variable j: natural range 0 to 2047;
		variable k: natural range 0 to 10;

		variable x: natural range 0 to 2047;
		variable z: std_logic_vector(31 downto 0);

	begin
		if reset='1' then
			stateOp_next <= stateOpInit;
			tkn_next <= tknPing;
			d_next <= (others => '0');
			reqRxbuf_next <= '0';
			dRxbuf_next <= (others => '0');
			reqTxbuf_next <= '0';
			dTxbuf_next <= (others => '0');
			crcd_next <= (others => '0');
			wurestart_next <= '0';
			reqOpToCmdLock_next <= '0';

		elsif rising_edge(mclk) then
			if stateOp=stateOpInit then
				tknFromCmdret <= tixWIdhwDcx3BufferCmdretToHostif;
				tknToCmdinv <= tixWIdhwDcx3BufferHostifToCmdinv;
				tknFromPmmu <= tixWIdhwDcx3BufferPmmuToHostif;
				tknToQcdif <= tixWIdhwDcx3BufferHostifToQcdif;
				tknFromQcdif <= tixWIdhwDcx3BufferQcdifToHostif;
				auxbuf(ixAuxbufXfer) <= tixDbeVXferVoid;
				tixDbeVXfer <= tixDbeVXferVoid;

				auxbuf(ixAuxbufTkn) <= tknPing;
				tkn_next <= tknPing;
				
				stateOp_next <= stateOpIdle;

			elsif stateOp=stateOpIdle then
				wurestart_next <= '0';

				auxbuf(ixAuxbufXfer) <= tixDbeVXferTkn;
				tixDbeVXfer <= tixDbeVXferTkn;

				spilen <= std_logic_vector(to_unsigned(lenAuxbufTkn, 11));

				i := 0;

				if reqCmdInvReset='1' then
					auxbuf(ixAuxbufTkn) <= tknReset;
					tkn_next <= tknReset;

					stateOp_next <= stateOpTxA;

				elsif (arbbx/=x"00" or avlbx(ixReqbxFromCmdret)='1' or reqbx(ixReqbxToCmdinv)='1' or reqbx(ixReqbxFromPmmu)='1' or reqbx(ixReqbxToQcdif)='1' or reqbx(ixReqbxFromQcdif)='1' or wakeup='1') then
					reqOpToCmdLock_next <= '1';

					stateOp_next <= stateOpPrepPingA;
				end if;

			elsif stateOp=stateOpPrepPingA then
				stateOp_next <= stateOpPrepPingB;

			elsif stateOp=stateOpPrepPingB then
				if (ackOpToCmdLock='1' or dnyOpToCmdLock='1') then
					auxbuf(ixAuxbufTkn) <= tknPing;
					tkn_next <= tknPing;

					stateOp_next <= stateOpTxA;
				end if;

			elsif stateOp=stateOpStepRetry then
				if retry=Nretry then
					if arbbx=tixWIdhwDcx3BufferCmdretToHostif then
						-- no error handling for now
					elsif arbbx=tixWIdhwDcx3BufferHostifToCmdinv then
						stateOp_next <= stateOpFwderr;
					elsif (arbbx=tixWIdhwDcx3BufferPmmuToHostif or arbbx=tixWIdhwDcx3BufferQcdifToHostif) then
						stateOp_next <= stateOpReadErr;
					elsif (arbbx=tixWIdhwDcx3BufferHostifToQcdif) then
						stateOp_next <= stateOpWriteErr;
					end if;

				else
					auxbuf(ixAuxbufXfer) <= tixDbeVXferTkn;
					tixDbeVXfer <= tixDbeVXferTkn;

					if arbbx=tixWIdhwDcx3BufferCmdretToHostif then
						auxbuf(ixAuxbufTkn) <= tknFromCmdret;
						tkn_next <= tknFromCmdret;

						stateOp_next <= stateOpTxA;

					elsif arbbx=tixWIdhwDcx3BufferHostifToCmdinv then
						auxbuf(ixAuxbufTkn) <= tknToCmdinv;
						tkn_next <= tknToCmdinv;

						reqOpToCmdLock_next <= '0';

						stateOp_next <= stateOpTxA;

					elsif arbbx=tixWIdhwDcx3BufferPmmuToHostif then
						auxbuf(ixAuxbufTkn) <= tknFromPmmu;
						tkn_next <= tknFromPmmu;

						reqOpToCmdLock_next <= '0';

						stateOp_next <= stateOpTxA;

					elsif arbbx=tixWIdhwDcx3BufferHostifToQcdif then
						auxbuf(ixAuxbufTkn) <= tknToQcdif;
						tkn_next <= tknToQcdif;

						reqOpToCmdLock_next <= '0';

						stateOp_next <= stateOpTxA;

					elsif arbbx=tixWIdhwDcx3BufferQcdifToHostif then
						auxbuf(ixAuxbufTkn) <= tknFromQcdif;
						tkn_next <= tknFromQcdif;

						reqOpToCmdLock_next <= '0';

						stateOp_next <= stateOpTxA;

					else
						wurestart_next <= '1';
						stateOp_next <= stateOpIdle;
					end if;
				end if;

			elsif stateOp=stateOpStepXfer then
				if tixDbeVXfer=tixDbeVXferVoid then
					-- should we even be here?

				elsif rxerr=rxerrOk then
					-- rx/tx completed successfully
					if tixDbeVXfer=tixDbeVXferTkn then -- tx

						if auxbuf(ixAuxbufTkn)=tknReset then
							stateOp_next <= stateOpAckReset;

						elsif auxbuf(ixAuxbufTkn)=tknPing then
							tixDbeVXfer <= tixDbeVXferAvlbx;

							spilen <= std_logic_vector(to_unsigned(lenAuxbufBx, 11));
							i := 0;

							stateOp_next <= stateOpRxA;

						elsif (auxbuf(ixAuxbufTkn)=tknFromCmdret or auxbuf(ixAuxbufTkn)=tknToCmdinv or auxbuf(ixAuxbufTkn)=tknFromPmmu or auxbuf(ixAuxbufTkn)=tknToQcdif or auxbuf(ixAuxbufTkn)=tknFromQcdif) then
							tixDbeVXfer <= tixDbeVXferAvllen;

							tkn_next <= auxbuf(ixAuxbufTkn);

							spilen <= std_logic_vector(to_unsigned(lenAuxbufLen, 11));
							i := 0;

							stateOp_next <= stateOpRxA;

						else
							-- invalid token
							stateOp_next <= stateOpInit;
						end if;

					elsif tixDbeVXfer=tixDbeVXferAvlbx then -- rx
						avlbx := auxbuf(ixAuxbufBxBx);

						auxbuf(ixAuxbufXfer) <= tixDbeVXferReqbx;
						tixDbeVXfer <= tixDbeVXferReqbx;

						stateOp_next <= stateOpPrepReqbx;

					elsif tixDbeVXfer=tixDbeVXferReqbx then -- tx
						tixDbeVXfer <= tixDbeVXferArbbx;

						spilen <= std_logic_vector(to_unsigned(lenAuxbufBx, 11));
						i := 0;

						stateOp_next <= stateOpRxA;

					elsif tixDbeVXfer=tixDbeVXferArbbx then -- rx
						arbbx := auxbuf(ixAuxbufBxBx);

						retry := 0;
						
						stateOp_next <= stateOpStepRetry;

					elsif tixDbeVXfer=tixDbeVXferAvllen then -- rx
						z := auxbuf(ixAuxbufLenLen) & auxbuf(ixAuxbufLenLen+1) & auxbuf(ixAuxbufLenLen+2) & auxbuf(ixAuxbufLenLen+3);
						avllen := z;

						auxbuf(ixAuxbufLenLen) <= tixDbeVXferReqlen;
						tixDbeVXfer <= tixDbeVXferReqlen;

						stateOp_next <= stateOpPrepReqlen;

					elsif tixDbeVXfer=tixDbeVXferReqlen then -- tx
						tixDbeVXfer <= tixDbeVXferArblen;

						spilen <= std_logic_vector(to_unsigned(lenAuxbufLen, 11));
						i := 0;

						stateOp_next <= stateOpRxA;

					elsif tixDbeVXfer=tixDbeVXferArblen then -- rx
						z := auxbuf(ixAuxbufLenLen) & auxbuf(ixAuxbufLenLen+1) & auxbuf(ixAuxbufLenLen+2) & auxbuf(ixAuxbufLenLen+3);
						arblen := z;

						if (auxbuf(ixAuxbufTkn)=tknFromCmdret or auxbuf(ixAuxbufTkn)=tknFromPmmu or auxbuf(ixAuxbufTkn)=tknFromQcdif) then
							tixDbeVXfer <= tixDbeVXferRd;

							x := to_integer(unsigned(arblen)) + 4;
							spilen <= std_logic_vector(to_unsigned(x, 11));

							i := 0;
							stateOp_next <= stateOpRxA;

						elsif (auxbuf(ixAuxbufTkn)=tknToCmdinv or auxbuf(ixAuxbufTkn)=tknToQcdif) then
							auxbuf(ixAuxbufXfer) <= tixDbeVXferWr;
							tixDbeVXfer <= tixDbeVXferWr;

							x := to_integer(unsigned(arblen)) + 4;
							spilen <= std_logic_vector(to_unsigned(x, 11));

							i := 0;

							d_next <= tixDbeVXferWr;
							stateOp_next <= stateOpTxA;

						else
							-- should not happen
							stateOp_next <= stateOpInit;
						end if;

					elsif tixDbeVXfer=tixDbeVXferRd then -- rx
						auxbuf(ixAuxbufXfer) <= tixDbeVXferRdack;
						tixDbeVXfer <= tixDbeVXferRdack;

						if (auxbuf(ixAuxbufRdCrc)=crcRxbuf(15 downto 8) and auxbuf(ixAuxbufRdCrc+1)=crcRxbuf(7 downto 0)) then
							auxbuf(ixAuxbufTkn) <= not tkn;
						end if;

						spilen <= std_logic_vector(to_unsigned(lenAuxbufRdack, 11));

						i := 0;
						d_next <= tixDbeVXferRdack;

						stateOp_next <= stateOpTxA;

					elsif tixDbeVXfer=tixDbeVXferRdack then -- tx
						if auxbuf(ixAuxbufTkn)=(not tkn) then
							stateOp_next <= stateOpCnfRd;
						else
							retry := retry + 1;
							stateOp_next <= stateOpStepRetry;
						end if;

					elsif tixDbeVXfer=tixDbeVXferWr then -- tx
						tixDbeVXfer <= tixDbeVXferWrack;

						spilen <= std_logic_vector(to_unsigned(lenAuxbufWrack, 11));
						i := 0;

						stateOp_next <= stateOpRxA;

					elsif tixDbeVXfer=tixDbeVXferWrack then -- rx
						if auxbuf(ixAuxbufTkn)=(not tkn) then
							stateOp_next <= stateOpCnfWr; -- only there, tkn flip
						else
							retry := retry + 1;
							stateOp_next <= stateOpStepRetry;
						end if;
					end if;

				else
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpPrepReqbx then
				auxbuf(ixAuxbufBxBx) <= reqbx;

				spilen <= std_logic_vector(to_unsigned(lenAuxbufBx, 11));

				i := 0;
				d_next <= auxbuf(ixAuxbufXfer);

				stateOp_next <= stateOpTxA;

			elsif stateOp=stateOpPrepReqlen then
				auxbuf(ixAuxbufLenLen) <= reqlen(31 downto 24);
				auxbuf(ixAuxbufLenLen+1) <= reqlen(23 downto 16);
				auxbuf(ixAuxbufLenLen+2) <= reqlen(15 downto 8);
				auxbuf(ixAuxbufLenLen+3) <= reqlen(7 downto 0);

				spilen <= std_logic_vector(to_unsigned(lenAuxbufLen, 11));

				i := 0;
				d_next <= auxbuf(ixAuxbufXfer);

				stateOp_next <= stateOpTxA;

-- RX BEGIN concerns rdbuf's
			elsif stateOp=stateOpRxA then
				if ackSpi='1' then
					if tixDbeVXfer=tixDbeVXferRd then
						stateOp_next <= stateOpRxB;
					else
						stateOp_next <= stateOpRxI;
					end if;
				end if;

			elsif stateOp=stateOpRxB then
				if strbSpirecv='1' then
					auxbuf(i) <= spirecv;

					if (i=0 and spirecv/=tixDbeVXfer) then
						rxerr <= rxerrXfer;
						stateOp_next <= stateOpStepXfer;

					elsif (i=1 and spirecv/=tkn) then
						rxerr <= rxerrTkn;
						stateOp_next <= stateOpStepXfer;

					else
						stateOp_next <= stateOpRxC;
					end if;
				end if;

			elsif stateOp=stateOpRxC then
				if strbSpirecv='0' then
					i := i + 1;

					if i=ixAuxbufRdRxbuf then
						reqRxbuf_next <= '1';

						j := 0;

						stateOp_next <= stateOpRxD;
					else
						stateOp_next <= stateOpRxB;
					end if;
				end if;

			elsif stateOp=stateOpRxD then
				if (ackCrc='1' and ackRxbuf='1') then
					stateOp_next <= stateOpRxE;
				end if;

			elsif stateOp=stateOpRxE then
				if strbSpirecv='1' then
					crcd_next <= spirecv;
					dRxbuf_next <= spirecv;

					stateOp_next <= stateOpRxF;
				end if;

			elsif stateOp=stateOpRxF then
				if strbSpirecv='0' then
					j := j + 1;
					
					if j=to_integer(unsigned(arblen)) then
						k := 0;
						stateOp_next <= stateOpRxG;
					else
						stateOp_next <= stateOpRxE;
					end if;
				end if;

			elsif stateOp=stateOpRxG then
				if k=10 then
					stateOp_next <= stateOpRxH;
				end if;

				k := k + 1;

			elsif stateOp=stateOpRxH then
				if dneCrc='1' then
					crcRxbuf <= crc;
					
					i := ixAuxbufRdCrc;

					stateOp_next <= stateOpRxI;
				end if;

			elsif stateOp=stateOpRxI then
				if strbSpirecv='1' then
					auxbuf(i) <= spirecv;

					if (i=0 and spirecv/=tixDbeVXfer) then
						rxerr <= rxerrXfer;
						stateOp_next <= stateOpStepXfer;

					elsif (i=1 and (spirecv/=tkn and tixDbeVXfer/=tixDbeVXferTkn and (tixDbeVXfer/=tixDbeVXferRdack or spirecv/=(not tkn)))) then
						rxerr <= rxerrTkn;
						stateOp_next <= stateOpStepXfer;

					else
						if dneSpi='1' then
							stateOp_next <= stateOpRxK;
						else
							stateOp_next <= stateOpRxJ;
						end if;
					end if;
				end if;

			elsif stateOp=stateOpRxJ then
				if strbSpirecv='0' then
					i := i + 1;

					stateOp_next <= stateOpRxI;
				end if;

			elsif stateOp=stateOpRxK then
				if ackSpi='0' then
					stateOp_next <= stateOpStepXfer;
				end if;
-- RX END
				
-- TX BEGIN concerns wrbuf's
			elsif stateOp=stateOpTxA then
				if ackSpi='1' then
					if tixDbeVXfer=tixDbeVXferWr then
						stateOp_next <= stateOpTxB;
					else
						stateOp_next <= stateOpTxJ;
					end if;
				end if;

			elsif stateOp=stateOpTxB then
				if strbSpisend='0' then
					i := i + 1;

					if i=ixAuxbufWrTxbuf then
						reqTxbuf_next <= '1';

						j := 0;

						stateOp_next <= stateOpTxD;
					else
						d_next <= auxbuf(i);
						stateOp_next <= stateOpTxC;
					end if;
				end if;

			elsif stateOp=stateOpTxC then
				if strbSpisend='1' then
					stateOp_next <= stateOpTxB;
				end if;

			elsif stateOp=stateOpTxD then
				if (ackCrc='1' and ackTxbuf='1') then
					stateOp_next <= stateOpTxE;
				end if;

			elsif stateOp=stateOpTxE then
				if strbSpisend='1' then
					crcd_next <= spisend;
					stateOp_next <= stateOpTxF;
				end if;

			elsif stateOp=stateOpTxF then
				if strbSpisend='0' then
					j := j + 1;
	
					if j=to_integer(unsigned(arblen)) then
						k := 0;
						stateOp_next <= stateOpTxG;
					else
						stateOp_next <= stateOpTxE;
					end if;
				end if;

			elsif stateOp=stateOpTxG then
				if k=10 then
					stateOp_next <= stateOpTxH;
				end if;

				k := k + 1;

			elsif stateOp=stateOpTxH then
				if dneCrc='1' then
					i := ixAuxbufWrCrc;

					auxbuf(i) <= crc(15 downto 8);
					auxbuf(i+1) <= crc(7 downto 0);
	
					d_next <= crc(15 downto 8);
	
					stateOp_next <= stateOpTxI;
				end if;

			elsif stateOp=stateOpTxI then
				if strbSpisend='1' then
					if dneSpi='1' then
						stateOp_next <= stateOpTxK;
					else
						stateOp_next <= stateOpTxJ;
					end if;
				end if;

			elsif stateOp=stateOpTxJ then
				if strbSpisend='0' then
					i := i + 1;

					d_next <= auxbuf(i);

					stateOp_next <= stateOpTxI;
				end if;

			elsif stateOp=stateOpTxK then
				if ackSpi='0' then
					stateOp_next <= stateOpStepXfer;
				end if;
-- TX END

			elsif stateOp=stateOpAckReset then -- ackCmdToOpInvReset='1'
				if reqCmdInvReset='0' then
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpCnfRd then
				if ackRxbuf='0' then
					if tkn=tknFromCmdret then
						tknFromCmdret <= not tknFromCmdret;
					elsif tkn=tknFromPmmu then
						tknFromPmmu <= not tknFromPmmu;
					elsif tkn=tknFromQcdif then
						tknFromQcdif <= not tknFromQcdif;
					end if;

					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpCnfWr then
				if ackTxbuf='0' then
					if tkn=tknToCmdinv then
						tknToCmdinv <= not tknToCmdinv;
					elsif tkn=tknToQcdif then
						tknToQcdif <= not tknToQcdif;
					end if;

					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpReadErr then
				if ackOpToReadErr='1' then
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpWriteErr then
				if ackOpToWriteErr='1' then
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpFwderr then
				if ackOpToCmdFwderr='1' then
					stateOp_next <= stateOpIdle;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			tkn <= tkn_next;
			d <= d_next;
			reqRxbuf <= reqRxbuf_next;
			drxbuf <= dRxbuf_next;
			reqTxbuf <= reqTxbuf_next;
			dTxbuf <= dTxbuf_next;
			crcd <= crcd_next;
			wurestart <= wurestart_next;
			reqOpToCmdLock <= reqOpToCmdLock_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: rdbuf outward/hostif-facing operation (rdbufB)
	------------------------------------------------------------------------

	enRdbufB <= '1' when (strbDRdbuf='0' and stateRdbufB=stateRdbufBReadA) else '0';

	aRdbufB_vec <= highNotLowRdbufB & std_logic_vector(to_unsigned(aRdbufB, 10));

	ackRdbufToHostif <= '1' when (stateRdbufB=stateRdbufBReadA or stateRdbufB=stateRdbufBReadB) else '0';

	-- TBD
	avllenRdbufToHostif <= std_logic_vector(to_unsigned(avllenRdbufB, 11)) when avllenRdbufB_zero='0' else (others => '0');

	reqRdbufBToReadDone <= '1' when stateRdbufB=stateRdbufBFlip else '0';

	process (reset, mclk, stateRdbufB)
		variable bytecnt: natural range 0 to sizeRdbuf;

	begin
		if reset='1' then
			stateRdbufB_next <= stateRdbufBInit;
			aRdbufB_next <= 0;
			highNotLowRdbufB_next <= '0';
			avllenRdbufB_next <= 0;
			avllenRdbufB_zero_next <= '0';

		elsif rising_edge(mclk) then
			if (stateRdbufB=stateRdbufBInit or rdbufBrun='0') then
				aRdbufB_next <= 0;
				highNotLowRdbufB_next <= '0';
				avllenRdbufB_next <= 0;
				avllenRdbufB_zero_next <= '0';

				if rdbufBrun='0' then
					stateRdbufB_next <= stateRdbufBInit;
				else
					stateRdbufB_next <= stateRdbufBStart;
				end if;

			elsif stateRdbufB=stateRdbufBStart then
				avllenRdbufB_next <= to_integer(unsigned(reqlenRead));
				avllenRdbufB_zero_next <= '1';

				stateRdbufB_next <= stateRdbufBWaitFull;

			elsif stateRdbufB=stateRdbufBWaitFull then
				if ((highNotLowRdbufB='0' and lenRdbufLow/=0) or (highNotLowRdbufB='1' and lenRdbufHigh/=0)) then
					avllenRdbufB_zero_next <= '0';
					stateRdbufB_next <= stateRdbufBReady;
				end if;

			elsif stateRdbufB=stateRdbufBReady then
				if reqRdbufToHostif='1' then
					bytecnt := 0;
					stateRdbufB_next <= stateRdbufBReadA;
				end if;
			
			elsif stateRdbufB=stateRdbufBReadA then -- ackRdbufToHostif='1'
				if dneRdbufToHostif='1' then
					-- confirm
					avllenRdbufB_next <= avllenRdbufB - bytecnt;
					stateRdbufB_next <= stateRdbufBReadC;

				elsif reqRdbufToHostif='0' then
					-- discard
					aRdbufB_next <= aRdbufB - bytecnt - 1;
					stateRdbufB_next <= stateRdbufBReady;

				elsif strbDRdbufToHostif='0' then
					if aRdbufB=0 then
						-- continuous read beyond buffer size: same as confirm
						avllenRdbufB_next <= avllenRdbufB - bytecnt;
						stateRdbufB_next <= stateRdbufBReadC;
					else
						stateRdbufB_next <= stateRdbufBReadB;
					end if;
				end if;

			elsif stateRdbufB=stateRdbufBReadB then -- ackRdbufToHostif='1'
				if strbDRdbufToHostif='1' then
					aRdbufB_next <= aRdbufB + 1;
					bytecnt := bytecnt + 1;

					stateRdbufB_next <= stateRdbufBReadA;
				end if;

			elsif stateRdbufB=stateRdbufBReadC then -- ackRdbufToHostif='0'
				if (aRdbufB=0 or avllenRdbufB=0) then
					-- low/high completed
					avllenRdbufB_zero_next <= '1';
					stateRdbufB_next <= stateRdbufBFlip;
				else
					stateRdbufB_next <= stateRdbufBReady;
				end if;

			elsif stateRdbufB=stateRdbufBFlip then -- reqRdbufBToReadDone='1'
				if ackRdbufBToReadDone='1' then
					if avllenRdbufB=0 then
						stateRdbufB_next <= stateRdbufBDone;
					else
						highNotLowRdbufB_next <= not highNotLowRdbufB;
						stateRdbufB_next <= stateRdbufBWaitFull;
					end if;
				end if;

			elsif stateRdbufB=stateRdbufBDone then
				-- if rdbufBrun='0' then
				-- 	stateRdbufB_next <= stateRdbufBInit;
				-- end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateRdbufB <= stateRdbufB_next;
			aRdbufB <= aRdbufB_next;
			highNotLowRdbufB <= highNotLowRdbufB_next;
			avllenRdbufB <= avllenRdbufB_next;
			avllenRdbufB_zero <= avllenRdbufB_zero_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: rdbuf and read command management (read)
	------------------------------------------------------------------------

	enRdbuf <= '1' when (strbDRdbuf='1' and stateRead=stateReadWriteB) else '0';

	aRdbuf_vec <= highNotLowRdbufA & std_logic_vector(to_unsigned(aRdbuf, 10));

	ackRdbuf <= '1' when (stateRead=stateReadWriteA or stateRead=stateReadWriteB) else '0';

	ackCmdToReadInv <= '1' when stateRead=stateReadStart else '0';
	ackOpToReadErr <= '1' when stateRead=stateReadErrB else '0';
	ackRdbufBToReadDone <= '1' when stateRead=stateReadFlipB else '0';
	reqReadToCmdRet <= '1' when stateRead=stateReadRet else '0';
	reqReadToCmdErrBufxfer <= '1' when stateRead=stateReadErrA else '0';

	process (reset, mclk, stateRead)
		variable bytecnt: natural range 0 to sizeRdbuf;

		variable x: natural range 0 to sizeRdbuf;

	begin
		if reset='1' then
			stateRead_next <= stateReadInit;
			routeRead <= (others => '0');
			crefRead <= (others => '0');
			tixWDcx3BufferRead_next <= (others => '0');
			reqlenRead <= (others => '0');
			rdbufBrun_next <= '0';
			aRdbuf_next <= 0;
			highNotLowRdbufA_next <= '0';
			lenRdbufLow_next <= 0;
			lenRdbufHigh_next <= 0;
			reqlenRdbuf_next <= 0;
			reqlenRdbuf_zero_next <= '0';
			ackCmdToReadInvReset_next <= '0';
			ackCmdToReadRev_next <= '0';

		elsif rising_edge(mclk) then
			if stateRead=stateReadInit then
				routeRead <= (others => '0');
				crefRead <= (others => '0');
				tixWDcx3BufferRead_next <= (others => '0');
				reqlenRead <= (others => '0');
				rdbufBrun_next <= '0';
				aRdbuf_next <= 0;
				highNotLowRdbufA_next <= '0';
				lenRdbufLow_next <= 0;
				lenRdbufHigh_next <= 0;
				reqlenRdbuf_next <= 0;
				reqlenRdbuf_zero_next <= '0';
				ackCmdToReadInvReset_next <= '0';
				ackCmdToReadRev_next <= '0';

				stateRead_next <= stateReadIdle;

			elsif stateRead=stateReadIdle then
				if reqCmdInvReset='1' then
					ackCmdToReadInvReset_next <= '1';
					stateRead_next <= stateReadAckResetRev;

				elsif reqCmdToReadInv='1' then
					routeRead <= cmdbuf(ixCmdbufRoute);

					crefRead(31 downto 24) <= cmdbuf(ixCmdbufCref);
					crefRead(23 downto 16) <= cmdbuf(ixCmdbufCref+1);
					crefRead(15 downto 8) <= cmdbuf(ixCmdbufCref+2);
					crefRead(7 downto 0) <= cmdbuf(ixCmdbufCref+3);

					tixWDcx3BufferRead_next <= cmdbuf(ixCmdbufInvReadTixWDcx3Buffer);

					reqlenRead(31 downto 24) <= cmdbuf(ixCmdbufInvReadReqlen);
					reqlenRead(23 downto 16) <= cmdbuf(ixCmdbufInvReadReqlen+1);
					reqlenRead(15 downto 8) <= cmdbuf(ixCmdbufInvReadReqlen+2);
					reqlenRead(7 downto 0) <= cmdbuf(ixCmdbufInvReadReqlen+3);

					stateRead_next <= stateReadStart;
				end if;

			elsif stateRead=stateReadStart then -- ackCmdToReadInv='1'
				if reqCmdToReadInv='0' then
					reqlenRdbuf_next <= to_integer(unsigned(reqlenRead));
					reqlenRdbuf_zero_next <= '0';

					rdbufBrun_next <= '1';

					stateRead_next <= stateReadReady;
				end if;

			elsif stateRead=stateReadReady then
				if reqCmdInvReset='1' then -- TBD: submit an err.invalid or fwderr
					ackCmdToReadInvReset_next <= '1';
					stateRead_next <= stateReadAckResetRev;

				elsif reqCmdToReadRev='1' then
					ackCmdToReadRev_next <= '1';
					stateRead_next <= stateReadAckResetRev;

				elsif reqRdbuf='1' then
					-- assume that aRdbuf, reqlenRdbuf, reqlenRdbuf_zero ae correct at this point
					bytecnt := 0;
					stateRead_next <= stateReadWriteB;

				elsif reqRdbufBToReadDone='1' then
					stateRead_next <= stateReadFlipA;

				elsif reqOpToReadErr='1' then
					stateRead_next <= stateReadErrA;
				end if;
				-- IP impl.read.rising.ready --- IEND

---
			elsif stateRead=stateReadWriteA then -- ackRdbuf='1'
				if dneRdbuf='1' then
					-- confirm
					aRdbuf_next <= aRdbuf + 1;
					reqlenRdbuf_next <= reqlenRdbuf - bytecnt;
					stateRead_next <= stateReadWriteC;

				elsif reqRdbuf='0' then
					-- discard
					aRdbuf_next <= aRdbuf - bytecnt - 1;
					stateRead_next <= stateReadReady;

				elsif strbDRdbuf='0' then
					aRdbuf_next <= aRdbuf + 1;

					if aRdbuf=(sizeRdbuf-1) then
						-- continuous write beyond buffer size: same as confirm
						reqlenRdbuf_next <= reqlenRdbuf - bytecnt;
						stateRead_next <= stateReadWriteC;
					else 
						stateRead_next <= stateReadWriteB;
					end if;
				end if;
			
			elsif stateRead=stateReadWriteB then -- ackRduf='1'
				if strbDRdbuf='1' then
					bytecnt := bytecnt + 1;
					stateRead_next <= stateReadWriteA;
				end if;

			elsif stateRead=stateReadWriteC then -- ackRdbuf='0'
				if (aRdbuf=0 or reqlenRdbuf=0) then
					-- low/high completed
					if aRdbuf=0 then
						x := sizeRdbuf;
					else
						x := aRdbuf - 1;
					end if;

					if highNotLowRdbufA='0' then
						lenRdbufLow_next <= x;
					else
						lenRdbufHigh_next <= x;
					end if;

					if (highNotLowRdbufA/=highNotLowRdbufB or reqlenRdbuf=0) then
						reqlenRdbuf_zero_next <= '1';
					end if;

					highNotLowRdbufA_next <= not highNotLowRdbufA;
					aRdbuf_next <= 0;
				end if;

				if (reqRdbuf='1' and dneRdbuf='1') then
					stateRead_next <= stateReadWriteD;
				else
					stateRead_next <= stateReadReady;
				end if;
				
			elsif stateRead=stateReadWriteD then -- ackRdbuf='0'
				if reqRdbuf='0' then
					stateRead_next <= stateReadReady;
				end if;

---
			elsif stateRead=stateReadFlipA then
				if highNotLowRdbufA='0' then
					lenRdbufLow_next <= 0;
				else
					lenRdbufHigh_next <= 0;
				end if;

				if (highNotLowRdbufA=highNotLowRdbufB and reqlenRdbuf/=0) then
					reqlenRdbuf_zero_next <= '0';
				end if;

				stateRead_next <= stateReadFlipB;

			elsif stateRead=stateReadFlipB then -- ackRdbufBToReadDone='1'
				if reqRdbufBToReadDone='0' then
					if (reqlenRdbuf=0 and lenRdbufLow=0 and lenRdbufHigh=0) then
						stateRead_next <= stateReadRet;
					else
						stateRead_next <= stateReadReady;
					end if;
				end if;

---
			elsif stateRead=stateReadAckResetRev then
				if ((reqCmdInvReset='0' and ackCmdToReadInvReset='1') or (reqCmdToReadRev='0' and ackCmdToReadRev='1')) then
					stateRead_next <= stateReadInit;
				end if;

			elsif stateRead=stateReadRet then -- reqReadToCmdRet='1'
				if ackReadToCmdRet='1' then
					stateRead_next <= stateReadInit;
				end if;

			elsif stateRead=stateReadErrA then -- reqReadToCmdErrBufxfer='1'
				if ackCmdErrBufxfer='1' then
					stateRead_next <= stateReadErrB;
				end if;

			elsif stateRead=stateReadErrB then -- ackOpToReadErr='1'
				if reqOpToReadErr='0' then
					stateRead_next <= stateReadInit;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateRead <= stateRead_next;
			tixWDcx3BufferRead <= tixWDcx3BufferRead_next;
			rdbufBrun <= rdbufBrun_next;
			aRdbuf <= aRdbuf_next;
			highNotLowRdbufA <= highNotLowRdbufA_next;
			lenRdbufLow <= lenRdbufLow_next;
			lenRdbufHigh <= lenRdbufHigh_next;
			reqlenRdbuf <= reqlenRdbuf_next;
			reqlenRdbuf_zero <= reqlenRdbuf_zero_next;
			ackCmdToReadInvReset <= ackCmdToReadInvReset_next;
			ackCmdToReadRev <= ackCmdToReadRev_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: wrbuf outward/hostif-facing operation (wrbufB)
	------------------------------------------------------------------------

	enWrbufB <= '1' when (strbDWrbuf='1' and stateWrbufB=stateWrbufBWriteB) else '0';

	aWrbufB_vec <= highNotLowWrbufB & std_logic_vector(to_unsigned(aWrbufB, 10));

	ackWrbufFromHostif <= '1' when (stateWrbufB=stateWrbufBWriteA or stateWrbufB=stateWrbufBWriteB) else '0';

	-- TBD
	avllenWrbufFromHostif <= std_logic_vector(to_unsigned(avllenWrbufB, 11)) when avllenWrbufB_zero='0' else (others => '0');

	reqWrbufBToWriteDone <= '1' when stateWrbufB=stateWrbufBFlip else '0';

	process (reset, mclk, stateWrbufB)
		variable bytecnt: natural range 0 to sizeWrbuf;

	begin
		if reset='1' then
			stateWrbufB_next <= stateWrbufBInit;
			aWrbufB_next <= 0;
			highNotLowWrbufB_next <= '0';
			avllenWrbufB_next <= 0;
			avllenWrbufB_zero_next <= '0';

		elsif rising_edge(mclk) then
			if (stateWrbufB=stateWrbufBInit or wrbufBrun='0') then
				aWrbufB_next <= 0;
				highNotLowWrbufB_next <= '0';
				avllenWrbufB_next <= 0;
				avllenWrbufB_zero_next <= '0';

				if wrbufBrun='0' then
					stateWrbufB_next <= stateWrbufBInit;
				else
					stateWrbufB_next <= stateWrbufBStart;
				end if;

			elsif stateWrbufB=stateWrbufBStart then
				avllenWrbufB_next <= to_integer(unsigned(reqlenWrite));
				avllenWrbufB_zero_next <= '1';

				stateWrbufB_next <= stateWrbufBWaitEmpty;

			elsif stateWrbufB=stateWrbufBWaitEmpty then
				if ((highNotLowWrbufB='0' and lenWrbufLow=0) or (highNotLowWrbufB='1' and lenWrbufHigh=0)) then
					avllenWrbufB_zero_next <= '0';
					stateWrbufB_next <= stateWrbufBReady;
				end if;

			elsif stateWrbufB=stateWrbufBReady then
				if reqWrbufFromHostif='1' then
					bytecnt := 0;
					stateWrbufB_next <= stateWrbufBWriteB;
				end if;

			elsif stateWrbufB=stateWrbufBWriteA then -- ackWrbufFromHostif='1'
				if dneWrbufFromHostif='1' then
					-- confirm
					aWrbufB_next <= aWrbufB + 1;
					avllenWrbufB_next <= avllenWrbufB - bytecnt;
					stateWrbufB_next <= stateWrbufBWriteC;

				elsif reqWrbufFromHostif='0' then
					-- discard
					aWrbufB_next <= aWrbufB - bytecnt - 1;
					stateWrbufB_next <= stateWrbufBReady;

				elsif strbDWrbufFromHostif='0' then
					aWrbufB_next <= aWrbufB + 1;

					if aWrbufB=(sizeWrbuf-1) then
						-- continuous write beyond buffer size: same as confirm
						avllenWrbufB_next <= avllenWrbufB - bytecnt;
						stateWrbufB_next <= stateWrbufBWriteC;
					else
						stateWrbufB_next <= stateWrbufBWriteB;
					end if;
				end if;

			elsif stateWrbufB=stateWrbufBWriteB then -- ackWrbufFromHostif='1'
				if strbDWrbufFromHostif='1' then
					bytecnt := bytecnt + 1;
					stateWrbufB_next <= stateWrbufBWriteA;
				end if;

			elsif stateWrbufB=stateWrbufBWriteC then -- ackWrbufFromHostif='0'
				if (aWrbufB=0 or avllenWrbufB=0) then
					-- low/high completed
					avllenWrbufB_zero_next <= '1';
					stateWrbufB_next <= stateWrbufBFlip;
				else
					stateWrbufB_next <= stateWrbufBReady;
				end if;

			elsif stateWrbufB=stateWrbufBFlip then -- reqWrbufBToWriteDone='1'
				if ackWrbufBToWriteDone='1' then
					if avllenWrbufB=0 then
						stateWrbufB_next <= stateWrbufBDone;
					else
						highNotLowWrbufB_next <= not highNotLowWrbufB;
						stateWrbufB_next <= stateWrbufBWaitEmpty;
					end if;
				end if;

			elsif stateWrbufB=stateWrbufBDone then
				-- if wrbufBrun='0' then
				-- 	stateWrbufB_next <= stateWrbufBInit;
				-- end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateWrbufB <= stateWrbufB_next;
			aWrbufB <= aWrbufB_next;
			highNotLowWrbufB <= highNotLowWrbufB_next;
			avllenWrbufB <= avllenWrbufB_next;
			avllenWrbufB_zero <= avllenWrbufB_zero_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: wrbuf and write command management (write)
	------------------------------------------------------------------------

	enWrbuf <= '1' when (strbDWrbuf='0' and stateWrite=stateWriteReadA) else '0';

	aWrbuf_vec <= highNotLowWrbufA & std_logic_vector(to_unsigned(aWrbuf, 10));

	ackWrbuf <= '1' when (stateWrite=stateWriteReadA or stateWrite=stateWriteReadB) else '0';

	ackCmdToWriteInv <= '1' when stateWrite=stateWriteStart else '0';
	ackOpToWriteErr <= '1' when stateWrite=stateWriteErrB else '0';
	ackWrbufBToWriteDone <= '1' when stateWrite=stateWriteFlipB else '0';
	reqWriteToCmdRet <= '1' when stateWrite=stateWriteRet else '0';
	reqWriteToCmdErrBufxfer <= '1' when stateWrite=stateWriteErrA else '0';

	process (reset, mclk, stateWrite)
		variable bytecnt: natural range 0 to sizeWrbuf;

		variable x: natural range 0 to sizeWrbuf;

	begin
		if reset='1' then
			stateWrite_next <= stateWriteInit;
			routeWrite <= (others => '0');
			crefWrite <= (others => '0');
			tixWDcx3BufferWrite_next <= (others => '0');
			reqlenWrite <= (others => '0');
			wrbufBrun_next <= '0';
			aWrbuf_next <= 0;
			highNotLowWrbufA_next <= '0';
			lenWrbufLow_next <= 0;
			lenWrbufHigh_next <= 0;
			reqlenWrbuf_next <= 0;
			reqlenWrbuf_zero_next <= '0';
			ackCmdToWriteInvReset_next <= '0';
			ackCmdToWriteRev_next <= '0';

		elsif rising_edge(mclk) then
			if stateWrite=stateWriteInit then
				routeWrite <= (others => '0');
				crefWrite <= (others => '0');
				tixWDcx3BufferWrite_next <= (others => '0');
				reqlenWrite <= (others => '0');
				wrbufBrun_next <= '0';
				aWrbuf_next <= 0;
				highNotLowWrbufA_next <= '0';
				lenWrbufLow_next <= 0;
				lenWrbufHigh_next <= 0;
				reqlenWrbuf_next <= 0;
				reqlenWrbuf_zero_next <= '0';
				ackCmdToWriteInvReset_next <= '0';
				ackCmdToWriteRev_next <= '0';

				stateWrite_next <= stateWriteIdle;

			elsif stateWrite=stateWriteIdle then
				if reqCmdInvReset='1' then
					ackCmdToWriteInvReset_next <= '1';
					stateWrite_next <= stateWriteAckResetRev;

				elsif reqCmdToWriteInv='1' then
					routeWrite <= cmdbuf(ixCmdbufRoute);

					crefWrite(31 downto 24) <= cmdbuf(ixCmdbufCref);
					crefWrite(23 downto 16) <= cmdbuf(ixCmdbufCref+1);
					crefWrite(15 downto 8) <= cmdbuf(ixCmdbufCref+2);
					crefWrite(7 downto 0) <= cmdbuf(ixCmdbufCref+3);
	
					tixWDcx3BufferWrite_next <= cmdbuf(ixCmdbufInvWriteTixWDcx3Buffer);
	
					reqlenWrite(31 downto 24) <= cmdbuf(ixCmdbufInvWriteReqlen);
					reqlenWrite(23 downto 16) <= cmdbuf(ixCmdbufInvWriteReqlen+1);
					reqlenWrite(15 downto 8) <= cmdbuf(ixCmdbufInvWriteReqlen+2);
					reqlenWrite(7 downto 0) <= cmdbuf(ixCmdbufInvWriteReqlen+3);
	
					stateWrite_next <= stateWriteStart;
				end if;

			elsif stateWrite=stateWriteStart then -- ackCmdToWriteInv='1'
				if reqCmdToWriteInv='0' then
					reqlenWrbuf_next <= to_integer(unsigned(reqlenWrite));
					reqlenWrbuf_zero_next <= '1';

					wrbufBrun_next <= '1';

					stateWrite_next <= stateWriteReady;
				end if;

			elsif stateWrite=stateWriteReady then
				if reqCmdInvReset='1' then -- TBD: submit an err.invalid or fwderr
					ackCmdToWriteInvReset_next <= '1';
					stateWrite_next <= stateWriteAckResetRev;

				elsif reqCmdToWriteRev='1' then
					ackCmdToWriteRev_next <= '1';
					stateWrite_next <= stateWriteAckResetRev;

				elsif reqWrbufBToWriteDone='1' then
					stateWrite_next <= stateWriteFlipA;

				elsif reqWrbuf='1' then
					bytecnt := 0;
					
					stateWrite_next <= stateWriteReadA;

				elsif reqOpToWriteErr='1' then
					stateWrite_next <= stateWriteErrA;
				end if;

---
			elsif stateWrite=stateWriteReadA then -- ackWrbuf='1'
				if dneWrbuf='1' then
					-- confirm
					reqlenWrbuf_next <= reqlenWrbuf - bytecnt;
					stateWrite_next <= stateWriteReadC;
				
				elsif reqWrbuf='0' then
					-- discard
					aWrbuf_next <= aWrbuf - bytecnt;
					stateWrite_next <= stateWriteReady;
				
				elsif strbDWrbuf='0' then
					if aWrbuf=0 then
						-- continuous read beyond buffer size: same as confirm
						reqlenWrbuf_next <= reqlenWrbuf - bytecnt;
						stateWrite_next <= stateWriteReadC;
					else
						stateWrite_next <= stateWriteReadB;
					end if;
				end if;

			elsif stateWrite=stateWriteReadB then -- ackWrbuf='1'
				if strbDWrbuf='1' then
					aWrbuf_next <= aWrbuf + 1;
					bytecnt := bytecnt + 1;

					stateWrite_next <= stateWriteReadA;
				end if;

			elsif stateWrite=stateWriteReadC then
				if reqlenWrbuf=0 then
					stateWrite_next <= stateWriteInit;
				else
					if aWrbuf=0 then
						-- low/high completed
						if highNotLowWrbufA='0' then
							lenWrbufLow_next <= 0;
						else
							lenWrbufHigh_next <= 0;
						end if;

						if ((highNotLowWrbufA='0' and lenWrbufHigh/=0) or (highNotLowWrbufA='1' and lenWrbufLow/=0)) then
							reqlenWrbuf_zero_next <= '0';
						else
							reqlenWrbuf_zero_next <= '1';
						end if;

						highNotLowWrbufA_next <= not highNotLowWrbufA;
						aWrbuf_next <= 0;
					end if;

					if (reqWrbuf='1' and dneWrbuf='1') then
						stateWrite_next <= stateWriteReadD;
					else
						stateWrite_next <= stateWriteReady;
					end if;
				end if;

			elsif stateWrite=stateWriteReadD then
				if reqWrbuf='0' then
					stateWrite_next <= stateWriteReady;
				end if;

---
			elsif stateWrite=stateWriteFlipA then
				if aWrbufB=0 then
					x := sizeWrbuf;
				else
					x := aWrbufB - 1;
				end if;

				if highNotLowWrbufB='0' then
					lenWrbufLow_next <= x;
				else
					lenWrbufHigh_next <= x;
				end if;

				stateWrite_next <= stateWriteFlipB;

			elsif stateWrite=stateWriteFlipB then -- ackWrbufBToWriteDone='1'
				if reqWrbufBToWriteDone='0' then
					if ((highNotLowWrbufA='0' and lenWrbufLow/=0) or (highNotLowWrbufA='1' and lenWrbufHigh/=0)) then
						reqlenWrbuf_zero_next <= '0';
					end if;
					
					stateWrite_next <= stateWriteReady;
				end if;

---
			elsif stateWrite=stateWriteAckResetRev then
				if ((reqCmdInvReset='0' and ackCmdToWriteInvReset='1') or (reqCmdToWriteRev='0' and ackCmdToWriteRev='1')) then
					stateWrite_next <= stateWriteInit;
				end if;

			elsif stateWrite=stateWriteRet then -- reqWriteToCmdRet='1'
				if ackWriteToCmdRet='1' then
					stateWrite_next <= stateWriteInit;
				end if;

			elsif stateWrite=stateWriteErrA then -- reqWriteToCmdErrBufxfer='1'
				if ackCmdErrBufxfer='1' then
					stateWrite_next <= stateWriteErrB;
				end if;

			elsif stateWrite=stateWriteErrB then -- ackOpToWriteErr='1'
				if reqOpToWriteErr='0' then
					stateWrite_next <= stateWriteInit;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateWrite <= stateWrite_next;
			tixWDcx3BufferWrite <= tixWDcx3BufferWrite_next;
			reqlenWrite <= reqlenWrite;
			wrbufBrun <= wrbufBrun_next;
			aWrbuf <= aWrbuf_next;
			highNotLowWrbufA <= highNotLowWrbufA_next;
			lenWrbufLow <= lenWrbufLow_next;
			lenWrbufHigh <= lenWrbufHigh_next;
			reqlenWrbuf <= reqlenWrbuf_next;
			reqlenWrbuf_zero <= reqlenWrbuf_zero_next;
			ackCmdToWriteInvReset <= ackCmdToWriteInvReset_next;
			ackCmdToWriteRev <= ackCmdToWriteRev_next;
		end if;
	end process;
	
end Dcxif;

