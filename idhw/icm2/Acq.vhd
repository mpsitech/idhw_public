-- file Acq.vhd
-- Acq controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

entity Acq is
	generic (
		fMclk: natural range 1 to 1000000 -- in kHz
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: inout std_logic_vector(7 downto 0);

		reqCmdbusToCmdret: out std_logic;
		wrCmdbusToCmdret: in std_logic;

		reqCmdbusToRoic: out std_logic;
		wrCmdbusToRoic: in std_logic;

		reqCmdbusToTkclksrc: out std_logic;
		wrCmdbusToTkclksrc: in std_logic;

		reqCmdbusToVmon: out std_logic;
		wrCmdbusToVmon: in std_logic;

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		rdyCmdbusFromTkclksrc: out std_logic;
		rdCmdbusFromTkclksrc: in std_logic;

		rdyCmdbusFromVmon: out std_logic;
		rdCmdbusFromVmon: in std_logic;

		reqBufToHostif: in std_logic;
		ackBufToHostif: out std_logic;
		dneBufToHostif: in std_logic;

		avllenBufToHostif: out std_logic_vector(10 downto 0);

		dBufToHostif: out std_logic_vector(7 downto 0);
		strbDBufToHostif: in std_logic;

		cmtclk: in std_logic;
		tempok: in std_logic;

		prep: out std_logic;
		rng: out std_logic;

		strbPixstep: out std_logic;

		nss: out std_logic;
		sclk: out std_logic;
		mosi: out std_logic;
		miso: in std_logic
	);
end Acq;

architecture Acq of Acq is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

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

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- buf A/inward-facing operation (buf)
	type stateBuf_t is (
		stateBufInit,
		stateBufIdle,
		stateBufAckCnfrd,
		stateBufAckCnfwr
	);
	signal stateBuf, stateBuf_next: stateBuf_t := stateBufInit;

	signal maxpglenBuf: natural range 2 to 8;

	signal pg0Buf, pg0Buf_next: natural range 0 to 7;
	signal pglenBuf, pglenBuf_next: natural range 0 to 8;

	-- IP sigs.buf.cust --- INSERT

	---- buf B/hostif-facing operation (bufB)
	type stateBufB_t is (
		stateBufBInit,
		stateBufBIdle,
		stateBufBReadA, stateBufBReadB,
		stateBufBWaitCnfrd,
		stateBufBUpdLen
	);
	signal stateBufB, stateBufB_next: stateBufB_t := stateBufBInit;

	signal enBufB: std_logic;
	signal aBufB, aBufB_next: std_logic_vector(10 downto 0);
	signal ackBufToHostif_sig: std_logic;
	signal avllenBufToHostif_sig, avllenBufToHostif_sig_next: std_logic_vector(10 downto 0);

	-- IP sigs.bufB.cust --- INSERT

	---- command execution (cmd)
	type stateCmd_t is (
		stateCmdInit,
		stateCmdEmpty,
		stateCmdWaitLockA, stateCmdWaitLockB, stateCmdWaitLockC,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE, stateCmdRecvF,
		stateCmdRecvG,
		stateCmdFullA, stateCmdFullB,
		stateCmdSendA, stateCmdSendB, stateCmdSendC, stateCmdSendD,
		stateCmdPrepNewretGetFrame,
		stateCmdPrepNewretGetPixel,
		stateCmdPrepRetGetTrace,
		stateCmdPrepCreferrOp, stateCmdPrepCreferr,
		stateCmdPrepInvRoicSetMode,
		stateCmdPrepInvTkclksrcGetTkst,
		stateCmdPrepInvVmonGetNtc
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: getFrame, getPixel, getTrace, setAdc, setTfrm
	-- rev: getFrame, getPixel, getTrace
	-- ret/newret: getFrame, getPixel, getTrace
	-- external inv: roic.setMode, tkclksrc.getTkst, vmon.getNtc
	-- external ret/newret: tkclksrc.getTkst, vmon.getNtc

	constant sizeCmdbuf: natural := 19;

	constant tixVCommandGetFrame: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvGetFrame: natural := 12;
	constant ixCmdbufInvGetFrameNsmp: natural := 10;
	constant lenCmdbufNewretGetFrame: natural := 15;
	constant ixCmdbufNewretGetFrameTkst: natural := 9;
	constant ixCmdbufNewretGetFrameNtc: natural := 13;

	constant tixVCommandGetPixel: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvGetPixel: natural := 12;
	constant ixCmdbufInvGetPixelNsmp: natural := 10;
	constant lenCmdbufNewretGetPixel: natural := 19;
	constant ixCmdbufNewretGetPixelTkst: natural := 9;
	constant ixCmdbufNewretGetPixelNtc: natural := 13;
	constant ixCmdbufNewretGetPixelPixval: natural := 15;

	constant tixVCommandGetTrace: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvGetTrace: natural := 12;
	constant ixCmdbufInvGetTraceNsmp: natural := 10;
	constant lenCmdbufRetGetTrace: natural := 10;

	constant tixVCommandSetAdc: std_logic_vector(7 downto 0) := x"03";
	constant lenCmdbufInvSetAdc: natural := 13;
	constant ixCmdbufInvSetAdcCps: natural := 10;
	constant ixCmdbufInvSetAdcTdly: natural := 11;

	constant tixVCommandSetTfrm: std_logic_vector(7 downto 0) := x"04";
	constant lenCmdbufInvSetTfrm: natural := 12;
	constant ixCmdbufInvSetTfrmTfrm: natural := 10;

	constant tixVIcm2RoicCommandSetMode: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvRoicSetMode: natural := 15;
	constant ixCmdbufInvRoicSetModeFullfrmNotSngpix: natural := 10;
	constant ixCmdbufInvRoicSetModeTixVBias: natural := 11;
	constant ixCmdbufInvRoicSetModeAcgain300not100: natural := 12;
	constant ixCmdbufInvRoicSetModeDcgain40not20: natural := 13;
	constant ixCmdbufInvRoicSetModeAmpbwDecr: natural := 14;

	constant tixVIcm2TkclksrcCommandGetTkst: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvTkclksrcGetTkst: natural := 10;
	constant lenCmdbufRetTkclksrcGetTkst: natural := 13;
	constant ixCmdbufRetTkclksrcGetTkstTkst: natural := 9;

	constant tixVIcm2VmonCommandGetNtc: std_logic_vector(7 downto 0) := x"03";
	constant lenCmdbufInvVmonGetNtc: natural := 10;
	constant lenCmdbufRetVmonGetNtc: natural := 11;
	constant ixCmdbufRetVmonGetNtcNtc: natural := 9;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;
	signal reqCmdbusToRoic_sig, reqCmdbusToRoic_sig_next: std_logic;
	signal reqCmdbusToTkclksrc_sig, reqCmdbusToTkclksrc_sig_next: std_logic;
	signal reqCmdbusToVmon_sig, reqCmdbusToVmon_sig_next: std_logic;
	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal rdyCmdbusFromTkclksrc_sig, rdyCmdbusFromTkclksrc_sig_next: std_logic;
	signal rdyCmdbusFromVmon_sig, rdyCmdbusFromVmon_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- pixel clock (cps)
	type stateCps_t is (
		stateCpsInit,
		stateCpsInv,
		stateCpsRunA, stateCpsRunB
	);
	signal stateCps, stateCps_next: stateCps_t := stateCpsInit;

	signal strbCps, strbCps_next: std_logic;
	signal strbPixstep_sig, strbPixstep_sig_next: std_logic;

	-- IP sigs.cps.cust --- INSERT

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpInv,
		stateOpRev,
		stateOpSetMode,
		stateOpWaitTfrmBufTemp,
		stateOpGetTkst,
		stateOpGetNtc,
		stateOpAcqstart,
		stateOpSmploop,
		stateOpPixloop,
		stateOpDelay,
		stateOpWaitConv,
		stateOpGetA, stateOpGetB, stateOpGetC,
		stateOpLoadA, stateOpLoadB,
		stateOpAdd,
		stateOpStoreA, stateOpStoreB,
		stateOpPixdone,
		stateOpCnfwr,
		stateOpRet
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal bufrun: std_logic;
	signal cpsrun, cpsrun_next: std_logic;
	signal Tfrmrun, Tfrmrun_next: std_logic;

	signal tkst: std_logic_vector(31 downto 0);
	signal ntc: std_logic_vector(15 downto 0);

	signal pixval: std_logic_vector(31 downto 0);

	signal enBuf: std_logic;
	signal weBuf: std_logic;

	signal aBuf, aBuf_next: std_logic_vector(10 downto 0);
	signal dwrBuf: std_logic_vector(7 downto 0);

	signal spilen: std_logic_vector(10 downto 0);
	signal spisend: std_logic_vector(7 downto 0);

	signal prep_sig, prep_sig_next: std_logic;
	signal rng_sig, rng_sig_next: std_logic;

	signal routeOp: std_logic_vector(7 downto 0);
	signal crefOp: std_logic_vector(31 downto 0);
	signal tixVCommandOp: std_logic_vector(7 downto 0);

	-- IP sigs.op.cust --- INSERT

	---- frame clock (tfrm)
	type stateTfrm_t is (
		stateTfrmInit,
		stateTfrmInv,
		stateTfrmReady,
		stateTfrmRunA, stateTfrmRunB, stateTfrmRunC
	);
	signal stateTfrm, stateTfrm_next: stateTfrm_t := stateTfrmInit;

	signal strbTfrm: std_logic;

	-- IP sigs.tfrm.cust --- INSERT

	---- myBuf
	signal drdBuf: std_logic_vector(7 downto 0);
	signal drdBufB: std_logic_vector(7 downto 0);

	---- mySpi
	signal spirecv: std_logic_vector(7 downto 0);
	signal strbSpirecv: std_logic;

	---- handshake
	-- op to mySpi
	signal reqSpi: std_logic;
	signal dneSpi: std_logic;

	-- bufB to buf
	signal reqBufBToBufCnfrd: std_logic;
	signal ackBufBToBufCnfrd: std_logic;

	-- cmd to (many)
	signal reqCmdInvSetAdc, reqCmdInvSetAdc_next: std_logic;
	signal ackCmdToCpsInvSetAdc, ackCmdToCpsInvSetAdc_next: std_logic;
	signal ackCmdToOpInvSetAdc, ackCmdToOpInvSetAdc_next: std_logic;

	-- cmd to op
	signal reqCmdToOpInv, reqCmdToOpInv_next: std_logic;
	signal ackCmdToOpInv, ackCmdToOpInv_next: std_logic;

	-- cmd to op
	signal reqCmdToOpRev, reqCmdToOpRev_next: std_logic;
	signal ackCmdToOpRev, ackCmdToOpRev_next: std_logic;

	-- cmd to tfrm
	signal reqCmdToTfrmInvSetTfrm, reqCmdToTfrmInvSetTfrm_next: std_logic;
	signal ackCmdToTfrmInvSetTfrm, ackCmdToTfrmInvSetTfrm_next: std_logic;

	-- op to buf
	signal reqOpToBufCnfwr: std_logic;
	signal ackOpToBufCnfwr: std_logic;

	-- op to cmd
	signal reqOpToCmdNewretGetFrame, reqOpToCmdNewretGetFrame_next: std_logic;
	signal ackOpToCmdNewretGetFrame, ackOpToCmdNewretGetFrame_next: std_logic;

	-- op to cmd
	signal reqOpToCmdNewretGetPixel, reqOpToCmdNewretGetPixel_next: std_logic;
	signal ackOpToCmdNewretGetPixel, ackOpToCmdNewretGetPixel_next: std_logic;

	-- op to cmd
	signal reqOpToCmdRetGetTrace, reqOpToCmdRetGetTrace_next: std_logic;
	signal ackOpToCmdRetGetTrace, ackOpToCmdRetGetTrace_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvRoicSetMode: std_logic;
	signal ackOpToCmdInvRoicSetMode, ackOpToCmdInvRoicSetMode_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvTkclksrcGetTkst: std_logic;
	signal ackOpToCmdInvTkclksrcGetTkst, ackOpToCmdInvTkclksrcGetTkst_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvVmonGetNtc: std_logic;
	signal ackOpToCmdInvVmonGetNtc, ackOpToCmdInvVmonGetNtc_next: std_logic;

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBuf : Dpbram_v1_0_size2kB
		port map (
			clkA => mclk,

			enA => enBuf,
			weA => weBuf,

			aA => aBuf,
			drdA => drdBuf,
			dwrA => dwrBuf,

			clkB => mclk,

			enB => enBufB,
			weB => '0',

			aB => aBufB,
			drdB => drdBufB,
			dwrB => x"00"
		);

	mySpi : Spimaster_v1_0
		generic map (
			fMclk => fMclk,

			cpol => '0',
			cpha => '1',

			fSclk => 25000000
		)
		port map (
			reset => reset,
			mclk => mclk,

			req => reqSpi,
			ack => open,
			dne => dneSpi,

			len => spilen,

			send => spisend,
			strbSend => open,

			recv => spirecv,
			strbRecv => strbSpirecv,

			nss => nss,
			sclk => sclk,
			mosi => mosi,
			miso => miso
		);

	------------------------------------------------------------------------
	-- implementation: buf A/inward-facing operation (buf)
	------------------------------------------------------------------------

	-- IP impl.buf.wiring --- BEGIN
	ackBufBToBufCnfrd <= '0' when stateBuf=stateBufAckCnfrd else '1';

	ackOpToBufCnfwr <= '0' when stateBuf=stateBufAckCnfwr else '1';
	-- IP impl.buf.wiring --- END

	-- IP impl.buf.rising --- BEGIN
	process (reset, mclk, stateBuf)
		-- IP impl.buf.rising.vars --- BEGIN
		-- IP impl.buf.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.buf.rising.asyncrst --- BEGIN
			stateBuf_next <= stateBufInit;
			pg0Buf_next <= 0;
			pglenBuf_next <= 0;
			-- IP impl.buf.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateBuf=stateBufInit or bufrun='0') then
				if bufrun='0' then
					stateBuf_next <= stateBufInit;

				else
					-- IP impl.buf.rising.init.maxpglen --- IBEGIN
					if tixVCommandOp=tixVCommandGetFrame then
						maxpglenBuf <= 8;
					else
						maxpglenBuf <= 2;
					end if;
					-- IP impl.buf.rising.init.maxpglen --- IEND

					stateBuf_next <= stateBufIdle;
				end if;

			elsif stateBuf=stateBufIdle then
				if reqBufBToBufCnfrd='1' then
					-- IP impl.buf.rising.idle.cnfrd --- IBEGIN
					if pglenBuf>0 then
						if pg0Buf=maxpglenBuf-1 then
							pg0Buf_next <= 0;
						else
							pg0Buf_next <= pg0Buf+1;
						end if;
						pglenBuf_next <= pglenBuf - 1;
					end if;
					-- IP impl.buf.rising.idle.cnfrd --- IEND

					stateBuf_next <= stateBufAckCnfrd;

				elsif reqOpToBufCnfwr='1' then
					-- IP impl.buf.rising.idle.cnfwr --- IBEGIN
					if pglenBuf<maxpglenBuf then
						pglenBuf_next <= pglenBuf + 1;
					end if;
					-- IP impl.buf.rising.idle.cnfwr --- IEND

					stateBuf_next <= stateBufAckCnfwr;
				end if;

			elsif stateBuf=stateBufAckCnfrd then
				if reqBufBToBufCnfrd='0' then
					stateBuf_next <= stateBufIdle;
				end if;

			elsif stateBuf=stateBufAckCnfwr then
				if reqOpToBufCnfwr='0' then
					stateBuf_next <= stateBufIdle;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.buf.rising --- END

	-- IP impl.buf.falling --- BEGIN
	process (mclk)
		-- IP impl.buf.falling.vars --- BEGIN
		-- IP impl.buf.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateBuf <= stateBuf_next;
			pg0Buf <= pg0Buf_next;
			pglenBuf <= pglenBuf_next;
		end if;
	end process;
	-- IP impl.buf.falling --- END

	------------------------------------------------------------------------
	-- implementation: buf B/hostif-facing operation (bufB)
	------------------------------------------------------------------------

	-- IP impl.bufB.wiring --- RBEGIN
	enBufB <= '1' when (strbDBufToHostif='0' and stateBufB=stateBufBReadA) else '0';

	ackBufToHostif_sig <= '1' when (stateBufB=stateBufBReadA or stateBufB=stateBufBReadB) else '0';
	ackBufToHostif <= ackBufToHostif_sig;

	avllenBufToHostif <= avllenBufToHostif_sig;

	reqBufBToBufCnfrd <= '1' when stateBufB=stateBufBWaitCnfrd else '0';

	dBufToHostif <= drdBufB;
	-- IP impl.bufB.wiring --- REND

	-- IP impl.bufB.rising --- BEGIN
	process (reset, mclk, stateBufB)
		-- IP impl.bufB.rising.vars --- BEGIN
		-- IP impl.bufB.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.bufB.rising.asyncrst --- BEGIN
			stateBufB_next <= stateBufBInit;
			aBufB_next <= "00000000000";
			avllenBufToHostif_sig_next <= "00000000000";
			-- IP impl.bufB.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateBufB=stateBufBInit or bufrun='0') then
				if bufrun='0' then
					stateBufB_next <= stateBufBInit;

				else
					stateBufB_next <= stateBufBIdle;
				end if;

			elsif stateBufB=stateBufBIdle then
				if reqBufToHostif='1' then
					stateBufB_next <= stateBufBReadA;

				elsif ackOpToBufCnfwr='1' then
					stateBufB_next <= stateBufBUpdLen;
				end if;

			elsif stateBufB=stateBufBReadA then
				if dneBufToHostif='1' then
					stateBufB_next <= stateBufBWaitCnfrd;

				elsif reqBufToHostif='0' then
					stateBufB_next <= stateBufBUpdLen;

				elsif strbDBufToHostif='0' then
					stateBufB_next <= stateBufBReadB;
				end if;

			elsif stateBufB=stateBufBReadB then
				if strbDBufToHostif='1' then
					aBufB_next <= std_logic_vector(unsigned(aBufB) + 1); -- IP impl.bufB.rising.readB.inc --- ILINE

					stateBufB_next <= stateBufBReadA;
				end if;

			elsif stateBufB=stateBufBWaitCnfrd then
				if ackBufBToBufCnfrd='1' then
					stateBufB_next <= stateBufBUpdLen;
				end if;

			elsif stateBufB=stateBufBUpdLen then
				-- IP impl.bufB.rising.updLen --- IBEGIN
				if (maxpglenBuf=8 and pglenBuf/=0) then
					aBufB_next(10 downto 8) <= std_logic_vector(to_unsigned(pg0Buf, 4)(2 downto 0));
					aBufB_next(7 downto 0) <= (others => '0');
					avllenBufToHostif_sig_next <= std_logic_vector(to_unsigned(256, 11));
				elsif (maxpglenBuf=2 and pglenBuf/=0) then
					if pg0Buf=0 then
						aBufB_next(10) <= '0';
					else
						aBufB_next(10) <= '1';
					end if;
					aBufB_next(9 downto 0) <= (others => '0');
					avllenBufToHostif_sig_next <= std_logic_vector(to_unsigned(1024, 11));
				else
					aBufB_next <= (others => '0');
					avllenBufToHostif_sig_next <= (others => '0');
				end if;
				-- IP impl.bufB.rising.updLen --- IEND

				stateBufB_next <= stateBufBIdle;
			end if;
		end if;
	end process;
	-- IP impl.bufB.rising --- END

	-- IP impl.bufB.falling --- BEGIN
	process (mclk)
		-- IP impl.bufB.falling.vars --- BEGIN
		-- IP impl.bufB.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateBufB <= stateBufB_next;
			aBufB <= aBufB_next;
			avllenBufToHostif_sig <= avllenBufToHostif_sig_next;
		end if;
	end process;
	-- IP impl.bufB.falling --- END

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	reqCmdbusToRoic <= reqCmdbusToRoic_sig;
	reqCmdbusToTkclksrc <= reqCmdbusToTkclksrc_sig;
	reqCmdbusToVmon <= reqCmdbusToVmon_sig;
	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	rdyCmdbusFromTkclksrc <= rdyCmdbusFromTkclksrc_sig;
	rdyCmdbusFromVmon <= rdyCmdbusFromVmon_sig;
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
			reqCmdInvSetAdc_next <= '0';
			reqCmdToOpInv_next <= '0';
			reqCmdToOpRev_next <= '0';
			reqCmdToTfrmInvSetTfrm_next <= '0';
			ackOpToCmdNewretGetFrame_next <= '0';
			ackOpToCmdNewretGetPixel_next <= '0';
			ackOpToCmdRetGetTrace_next <= '0';
			ackOpToCmdInvRoicSetMode_next <= '0';
			ackOpToCmdInvTkclksrcGetTkst_next <= '0';
			ackOpToCmdInvVmonGetNtc_next <= '0';
			reqCmdbusToCmdret_sig_next <= '0';
			reqCmdbusToRoic_sig_next <= '0';
			reqCmdbusToTkclksrc_sig_next <= '0';
			reqCmdbusToVmon_sig_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			rdyCmdbusFromTkclksrc_sig_next <= '1';
			rdyCmdbusFromVmon_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				reqCmdInvSetAdc_next <= '0';
				reqCmdToOpInv_next <= '0';
				reqCmdToOpRev_next <= '0';
				reqCmdToTfrmInvSetTfrm_next <= '0';
				ackOpToCmdNewretGetFrame_next <= '0';
				ackOpToCmdNewretGetPixel_next <= '0';
				ackOpToCmdRetGetTrace_next <= '0';
				ackOpToCmdInvRoicSetMode_next <= '0';
				ackOpToCmdInvTkclksrcGetTkst_next <= '0';
				ackOpToCmdInvVmonGetNtc_next <= '0';
				reqCmdbusToCmdret_sig_next <= '0';
				reqCmdbusToRoic_sig_next <= '0';
				reqCmdbusToTkclksrc_sig_next <= '0';
				reqCmdbusToVmon_sig_next <= '0';
				rdyCmdbusFromCmdinv_sig_next <= '1';
				rdyCmdbusFromTkclksrc_sig_next <= '1';
				rdyCmdbusFromVmon_sig_next <= '1';

				lenCmdbuf := 0;
				i := 0;
				j := 0;
				x := x"00";
				bytecnt := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if ((rdCmdbusFromCmdinv='1' or rdCmdbusFromTkclksrc='1' or rdCmdbusFromVmon='1') and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
					rdyCmdbusFromTkclksrc_sig_next <= '0';
					rdyCmdbusFromVmon_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;

				elsif (reqOpToCmdNewretGetFrame='1' or reqOpToCmdNewretGetPixel='1' or reqOpToCmdRetGetTrace='1' or reqOpToCmdInvRoicSetMode='1' or reqOpToCmdInvTkclksrcGetTkst='1' or reqOpToCmdInvVmonGetNtc='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
					rdyCmdbusFromTkclksrc_sig_next <= '0';
					rdyCmdbusFromVmon_sig_next <= '0';

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
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromTkclksrc='0' and rdCmdbusFromVmon='0') then
						if reqOpToCmdNewretGetFrame='1' then
							stateCmd_next <= stateCmdPrepNewretGetFrame;

						elsif reqOpToCmdNewretGetPixel='1' then
							stateCmd_next <= stateCmdPrepNewretGetPixel;

						elsif reqOpToCmdRetGetTrace='1' then
							stateCmd_next <= stateCmdPrepRetGetTrace;

						elsif reqOpToCmdInvRoicSetMode='1' then
							stateCmd_next <= stateCmdPrepInvRoicSetMode;

						elsif reqOpToCmdInvTkclksrcGetTkst='1' then
							stateCmd_next <= stateCmdPrepInvTkclksrcGetTkst;

						elsif reqOpToCmdInvVmonGetNtc='1' then
							stateCmd_next <= stateCmdPrepInvVmonGetNtc;

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
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromTkclksrc='0' and rdCmdbusFromVmon='0') then
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
						x := tixVIdhwIcm2ControllerCmdret;
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
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetFrame and lenCmdbuf=lenCmdbufInvGetFrame) then
					if crefOp=x"00000000" then
						reqCmdToOpInv_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					else
						stateCmd_next <= stateCmdPrepCreferrOp;
					end if;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetPixel and lenCmdbuf=lenCmdbufInvGetPixel) then
					if crefOp=x"00000000" then
						reqCmdToOpInv_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					else
						stateCmd_next <= stateCmdPrepCreferrOp;
					end if;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetTrace and lenCmdbuf=lenCmdbufInvGetTrace) then
					if crefOp=x"00000000" then
						reqCmdToOpInv_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					else
						stateCmd_next <= stateCmdPrepCreferrOp;
					end if;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetAdc and lenCmdbuf=lenCmdbufInvSetAdc) then
					reqCmdInvSetAdc_next <= '1';

					stateCmd_next <= stateCmdRecvG;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetTfrm and lenCmdbuf=lenCmdbufInvSetTfrm) then
					reqCmdToTfrmInvSetTfrm_next <= '1';

					stateCmd_next <= stateCmdRecvG;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRev and lenCmdbuf=lenCmdbufRev) then
					if (cmdbuf(ixCmdbufCref)=crefOp(31 downto 24) and cmdbuf(ixCmdbufCref+1)=crefOp(23 downto 16) and cmdbuf(ixCmdbufCref+2)=crefOp(15 downto 8) and cmdbuf(ixCmdbufCref+3)=crefOp(7 downto 0)) then
						reqCmdToOpRev_next <= '1';
						reqCmdToOpRev_next <= '1';
						reqCmdToOpRev_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRet and cmdbuf(ixCmdbufCref)=tixVIcm2TkclksrcCommandGetTkst and lenCmdbuf=lenCmdbufRetTkclksrcGetTkst) then
					ackOpToCmdInvTkclksrcGetTkst_next <= '1';

					stateCmd_next <= stateCmdRecvG;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRet and cmdbuf(ixCmdbufCref)=tixVIcm2VmonCommandGetNtc and lenCmdbuf=lenCmdbufRetVmonGetNtc) then
					ackOpToCmdInvVmonGetNtc_next <= '1';

					stateCmd_next <= stateCmdRecvG;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdRecvG then
				if ((reqCmdToOpInv='1' and ackCmdToOpInv='1') or (reqCmdToOpRev='1' and ackCmdToOpRev='1') or (reqCmdInvSetAdc='1' and ackCmdToCpsInvSetAdc='1' and ackCmdToOpInvSetAdc='1') or (reqCmdToTfrmInvSetTfrm='1' and ackCmdToTfrmInvSetTfrm='1') or (reqOpToCmdInvTkclksrcGetTkst='0' and ackOpToCmdInvTkclksrcGetTkst='1') or (reqOpToCmdInvVmonGetNtc='0' and ackOpToCmdInvVmonGetNtc='1')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullA then
				if cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerCmdret then
					reqCmdbusToCmdret_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerRoic then
					reqCmdbusToRoic_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerTkclksrc then
					reqCmdbusToTkclksrc_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerVmon then
					reqCmdbusToVmon_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullB then
				if ((wrCmdbusToCmdret='1' or wrCmdbusToRoic='1' or wrCmdbusToTkclksrc='1' or wrCmdbusToVmon='1') and clkCmdbus='1') then
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
							reqCmdbusToRoic_sig_next <= '0';
							reqCmdbusToTkclksrc_sig_next <= '0';
							reqCmdbusToVmon_sig_next <= '0';
						end if;

						stateCmd_next <= stateCmdSendA;
					end if;
				end if;

			elsif stateCmd=stateCmdSendC then
				if (wrCmdbusToCmdret='0' and wrCmdbusToRoic='0' and wrCmdbusToTkclksrc='0' and wrCmdbusToVmon='0') then
					if (reqOpToCmdNewretGetFrame='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionRet) then
						ackOpToCmdNewretGetFrame_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqOpToCmdNewretGetPixel='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionRet) then
						ackOpToCmdNewretGetPixel_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqOpToCmdRetGetTrace='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionRet) then
						ackOpToCmdRetGetTrace_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqOpToCmdInvRoicSetMode='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVIcm2RoicCommandSetMode) then
						ackOpToCmdInvRoicSetMode_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqOpToCmdInvTkclksrcGetTkst='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVIcm2TkclksrcCommandGetTkst) then
						rdyCmdbusFromTkclksrc_sig_next <= '1';
						lenCmdbuf := 0;

						if (rdCmdbusFromTkclksrc='1' and clkCmdbus='1') then
							stateCmd_next <= stateCmdRecvA;
						end if;

					elsif (reqOpToCmdInvVmonGetNtc='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVIcm2VmonCommandGetNtc) then
						rdyCmdbusFromVmon_sig_next <= '1';
						lenCmdbuf := 0;

						if (rdCmdbusFromVmon='1' and clkCmdbus='1') then
							stateCmd_next <= stateCmdRecvA;
						end if;

					else
						stateCmd_next <= stateCmdInit;
					end if;
				end if;

			elsif stateCmd=stateCmdSendD then
				if ((reqOpToCmdNewretGetFrame='0' and ackOpToCmdNewretGetFrame='1') or (reqOpToCmdNewretGetPixel='0' and ackOpToCmdNewretGetPixel='1') or (reqOpToCmdRetGetTrace='0' and ackOpToCmdRetGetTrace='1')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdPrepNewretGetFrame then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionNewret;

				cmdbuf(ixCmdbufCref) <= crefOp(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefOp(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefOp(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefOp(7 downto 0);

				-- IP impl.cmd.rising.prepNewretGetFrame --- IBEGIN
				cmdbuf(ixCmdbufNewretGetFrameTkst) <= tkst(31 downto 24);
				cmdbuf(ixCmdbufNewretGetFrameTkst+1) <= tkst(23 downto 16);
				cmdbuf(ixCmdbufNewretGetFrameTkst+2) <= tkst(15 downto 8);
				cmdbuf(ixCmdbufNewretGetFrameTkst+3) <= tkst(7 downto 0);

				cmdbuf(ixCmdbufNewretGetFrameNtc) <= ntc(15 downto 8);
				cmdbuf(ixCmdbufNewretGetFrameNtc+1) <= ntc(7 downto 0);
				-- IP impl.cmd.rising.prepNewretGetFrame --- IEND

				lenCmdbuf := lenCmdbufNewretGetFrame;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepNewretGetPixel then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionNewret;

				cmdbuf(ixCmdbufCref) <= crefOp(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefOp(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefOp(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefOp(7 downto 0);

				-- IP impl.cmd.rising.prepNewretGetPixel --- IBEGIN
				cmdbuf(ixCmdbufNewretGetPixelTkst) <= tkst(31 downto 24);
				cmdbuf(ixCmdbufNewretGetPixelTkst+1) <= tkst(23 downto 16);
				cmdbuf(ixCmdbufNewretGetPixelTkst+2) <= tkst(15 downto 8);
				cmdbuf(ixCmdbufNewretGetPixelTkst+3) <= tkst(7 downto 0);

				cmdbuf(ixCmdbufNewretGetPixelNtc) <= ntc(15 downto 8);
				cmdbuf(ixCmdbufNewretGetPixelNtc+1) <= ntc(7 downto 0);

				cmdbuf(ixCmdbufNewretGetPixelPixval) <= pixval(31 downto 24);
				cmdbuf(ixCmdbufNewretGetPixelPixval+1) <= pixval(23 downto 16);
				cmdbuf(ixCmdbufNewretGetPixelPixval+2) <= pixval(15 downto 8);
				cmdbuf(ixCmdbufNewretGetPixelPixval+3) <= pixval(7 downto 0);
				-- IP impl.cmd.rising.prepNewretGetPixel --- IEND

				lenCmdbuf := lenCmdbufNewretGetPixel;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepRetGetTrace then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				cmdbuf(ixCmdbufCref) <= crefOp(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefOp(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefOp(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefOp(7 downto 0);

				lenCmdbuf := lenCmdbufRetGetTrace;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepCreferrOp then
				cmdbuf(ixCmdbufCreferrCref) <= crefOp(31 downto 24);
				cmdbuf(ixCmdbufCreferrCref+1) <= crefOp(23 downto 16);
				cmdbuf(ixCmdbufCreferrCref+2) <= crefOp(15 downto 8);
				cmdbuf(ixCmdbufCreferrCref+3) <= crefOp(7 downto 0);

				stateCmd_next <= stateCmdPrepCreferr;

			elsif stateCmd=stateCmdPrepCreferr then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionCreferr;

				lenCmdbuf := lenCmdbufCreferr;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvRoicSetMode then
				cmdbuf(ixCmdbufRoute) <= tixVIdhwIcm2ControllerRoic;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwIcm2ControllerRoic;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVIcm2RoicCommandSetMode;
				cmdbuf(ixCmdbufInvCommand) <= tixVIcm2RoicCommandSetMode;

				-- IP impl.cmd.rising.prepInvRoicSetMode --- IBEGIN
				if tixVCommandOp=tixVCommandGetFrame then
					cmdbuf(ixCmdbufInvRoicSetModeFullfrmNotSngpix) <= tru8;
				else
					cmdbuf(ixCmdbufInvRoicSetModeFullfrmNotSngpix) <= fls8;
				end if;
				-- IP impl.cmd.rising.prepInvRoicSetMode --- IEND

				lenCmdbuf := lenCmdbufInvRoicSetMode;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvTkclksrcGetTkst then
				cmdbuf(ixCmdbufRoute) <= tixVIdhwIcm2ControllerTkclksrc;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwIcm2ControllerTkclksrc;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVIcm2TkclksrcCommandGetTkst;
				cmdbuf(ixCmdbufInvCommand) <= tixVIcm2TkclksrcCommandGetTkst;

				lenCmdbuf := lenCmdbufInvTkclksrcGetTkst;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvVmonGetNtc then
				cmdbuf(ixCmdbufRoute) <= tixVIdhwIcm2ControllerVmon;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwIcm2ControllerVmon;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVIcm2VmonCommandGetNtc;
				cmdbuf(ixCmdbufInvCommand) <= tixVIcm2VmonCommandGetNtc;

				lenCmdbuf := lenCmdbufInvVmonGetNtc;

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
			reqCmdInvSetAdc <= reqCmdInvSetAdc_next;
			reqCmdToOpInv <= reqCmdToOpInv_next;
			reqCmdToOpRev <= reqCmdToOpRev_next;
			reqCmdToTfrmInvSetTfrm <= reqCmdToTfrmInvSetTfrm_next;
			ackOpToCmdNewretGetFrame <= ackOpToCmdNewretGetFrame_next;
			ackOpToCmdNewretGetPixel <= ackOpToCmdNewretGetPixel_next;
			ackOpToCmdRetGetTrace <= ackOpToCmdRetGetTrace_next;
			ackOpToCmdInvRoicSetMode <= ackOpToCmdInvRoicSetMode_next;
			ackOpToCmdInvTkclksrcGetTkst <= ackOpToCmdInvTkclksrcGetTkst_next;
			ackOpToCmdInvVmonGetNtc <= ackOpToCmdInvVmonGetNtc_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			dCmdbus_sig <= dCmdbus_sig_next;
			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
			reqCmdbusToRoic_sig <= reqCmdbusToRoic_sig_next;
			reqCmdbusToTkclksrc_sig <= reqCmdbusToTkclksrc_sig_next;
			reqCmdbusToVmon_sig <= reqCmdbusToVmon_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			rdyCmdbusFromTkclksrc_sig <= rdyCmdbusFromTkclksrc_sig_next;
			rdyCmdbusFromVmon_sig <= rdyCmdbusFromVmon_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: pixel clock (cps)
	------------------------------------------------------------------------

	-- IP impl.cps.wiring --- BEGIN
	strbPixstep <= strbPixstep_sig;
	-- IP impl.cps.wiring --- END

	-- IP impl.cps.rising --- BEGIN
	process (reset, mclk, stateCps)
		-- IP impl.cps.rising.vars --- RBEGIN
		variable cps: natural range 1 to 255 := 1;

		variable first: std_logic;

		variable i: natural range 0 to 255;
		-- IP impl.cps.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.cps.rising.asyncrst --- BEGIN
			stateCps_next <= stateCpsInit;
			strbCps_next <= '0';
			strbPixstep_sig_next <= '0';
			ackCmdToCpsInvSetAdc_next <= '0';
			-- IP impl.cps.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateCps=stateCpsInit or (stateCps/=stateCpsInv and (reqCmdInvSetAdc='1' or cpsrun='0'))) then
				if reqCmdInvSetAdc='1' then
					-- IP impl.cps.rising.init.setAdc --- IBEGIN
					cps := to_integer(unsigned(cmdbuf(ixCmdbufInvSetAdcCps)));

					ackCmdToCpsInvSetAdc_next <= '1';
					-- IP impl.cps.rising.init.setAdc --- IEND

					stateCps_next <= stateCpsInv;

				else
					-- IP impl.cps.rising.syncrst --- BEGIN
					strbCps_next <= '0';
					strbPixstep_sig_next <= '0';
					ackCmdToCpsInvSetAdc_next <= '0';

					-- IP impl.cps.rising.syncrst --- END

					if cpsrun='0' then
						stateCps_next <= stateCpsInit;

					else
						-- IP impl.cps.rising.init.initrun --- IBEGIN
						first := '1';
						i := 0;
						-- IP impl.cps.rising.init.initrun --- IEND

						stateCps_next <= stateCpsRunA;
					end if;
				end if;

			elsif stateCps=stateCpsInv then
				if (reqCmdInvSetAdc='0' and ackCmdToCpsInvSetAdc='1') then
					stateCps_next <= stateCpsInit;
				end if;

			elsif stateCps=stateCpsRunA then
				if cmtclk='1' then
					-- IP impl.cps.rising.runA --- IBEGIN
					if i=0 then
						strbCps_next <= '1';
						if first='1' then
							first := '0';
						else
							strbPixstep_sig_next <= '1';
						end if;
					end if;
					-- IP impl.cps.rising.runA --- IEND

					stateCps_next <= stateCpsRunB;
				end if;

			elsif stateCps=stateCpsRunB then
				-- IP impl.cps.rising.runB.ext --- IBEGIN
				strbCps_next <= '0';
				strbPixstep_sig_next <= '0';
				-- IP impl.cps.rising.runB.ext --- IEND

				if cmtclk='0' then
					-- IP impl.cps.rising.runB --- IBEGIN
					i := i + 1;
					if i=cps then
						i := 0;
					end if;
					-- IP impl.cps.rising.runB --- IEND

					stateCps_next <= stateCpsRunA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.cps.rising --- END

	-- IP impl.cps.falling --- BEGIN
	process (mclk)
		-- IP impl.cps.falling.vars --- BEGIN
		-- IP impl.cps.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateCps <= stateCps_next;
			strbCps <= strbCps_next;
			strbPixstep_sig <= strbPixstep_sig_next;
			ackCmdToCpsInvSetAdc <= ackCmdToCpsInvSetAdc_next;
		end if;
	end process;
	-- IP impl.cps.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	bufrun <= '1' when (stateOp=stateOpInit or stateOp=stateOpInv or stateOp=stateOpRev) else '0';

	enBuf <= '0' when (stateOp=stateOpLoadA or stateOp=stateOpStoreB) else '1';
	weBuf <= '0' when stateOp=stateOpStoreB else '1';

	reqSpi <= '0' when (stateOp=stateOpGetA or stateOp=stateOpGetB or stateOp=stateOpGetC) else '1';

	spisend <= x"FF" when (stateOp=stateOpGetA or stateOp=stateOpGetB or stateOp=stateOpGetC) else x"00";

	prep <= prep_sig;
	rng <= rng_sig;

	reqOpToBufCnfwr <= '0' when stateOp=stateOpCnfwr else '1';

	reqOpToCmdInvRoicSetMode <= '0' when stateOp=stateOpSetMode else '1';

	reqOpToCmdInvTkclksrcGetTkst <= '0' when stateOp=stateOpGetTkst else '1';

	reqOpToCmdInvVmonGetNtc <= '0' when stateOp=stateOpGetNtc else '1';
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		variable tdly: natural range 0 to 65535 := 0;

		variable Nsmp: natural range 1 to 65535 := 1;

		variable smpcnt: natural range 0 to 65535;

		variable Npix: natural range 1 to 64;
		variable pixcnt: natural range 0 to 64;

		variable i: natural range 0 to 65536;
		variable j: natural range 0 to (fMclk/10000)*16; -- tconv=1.6us

		variable bytecnt: natural range 0 to 2;

		variable adcval: std_logic_vector(13 downto 0);

		variable k: natural range 0 to 4;

		variable x: std_logic_vector(15 downto 0);
		variable y: std_logic_vector(15 downto 0);
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- BEGIN
			stateOp_next <= stateOpInit;
			cpsrun_next <= '0';
			Tfrmrun_next <= '0';
			aBuf_next <= "00000000000";
			prep_sig_next <= '0';
			rng_sig_next <= '0';
			ackCmdToOpInvSetAdc_next <= '0';
			ackCmdToOpInv_next <= '0';
			ackCmdToOpRev_next <= '0';
			reqOpToCmdNewretGetFrame_next <= '0';
			reqOpToCmdNewretGetPixel_next <= '0';
			reqOpToCmdRetGetTrace_next <= '0';
			-- IP impl.op.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpInv and stateOp/=stateOpRev and (reqCmdInvSetAdc='1' or reqCmdToOpInv='1' or reqCmdToOpRev='1'))) then
				if reqCmdInvSetAdc='1' then
					-- IP impl.op.rising.init.setAdc --- IBEGIN
					x := cmdbuf(ixCmdbufInvSetAdcTdly) & cmdbuf(ixCmdbufInvSetAdcTdly+1);
					tdly := to_integer(unsigned(x));

					ackCmdToOpInvSetAdc_next <= '1';
					ackCmdToOpInv_next <= '0';
					ackCmdToOpRev_next <= '0';
					-- IP impl.op.rising.init.setAdc --- IEND

					stateOp_next <= stateOpInv;

				elsif reqCmdToOpInv='1' then
					-- IP impl.op.rising.init.inv --- IBEGIN
					routeOp <= cmdbuf(ixCmdbufRoute);
	
					crefOp(31 downto 24) <= cmdbuf(ixCmdbufCref);
					crefOp(23 downto 16) <= cmdbuf(ixCmdbufCref+1);
					crefOp(15 downto 8) <= cmdbuf(ixCmdbufCref+2);
					crefOp(7 downto 0) <= cmdbuf(ixCmdbufCref+3);

					tixVCommandOp <= cmdbuf(ixCmdbufInvCommand);

					y := cmdbuf(ixCmdbufInvGetFrameNsmp) & cmdbuf(ixCmdbufInvGetFrameNsmp+1);
					Nsmp := to_integer(unsigned(y));

					ackCmdToOpInvSetAdc_next <= '0';
					ackCmdToOpInv_next <= '1';
					ackCmdToOpRev_next <= '0';
					-- IP impl.op.rising.init.inv --- IEND

					stateOp_next <= stateOpInv;

				elsif reqCmdToOpRev='1' then
					-- IP impl.op.rising.init.rev --- IBEGIN
					routeOp <= (others => '0');
					crefOp <= (others => '0');
					tixVCommandOp <= (others => '0');

					ackCmdToOpInvSetAdc_next <= '0';
					ackCmdToOpInv_next <= '0';
					ackCmdToOpRev_next <= '1';
					-- IP impl.op.rising.init.rev --- IEND

					stateOp_next <= stateOpRev;

				else
					-- IP impl.op.rising.init --- IBEGIN
					ackCmdToOpInvSetAdc_next <= '0';
					ackCmdToOpInv_next <= '0';
					ackCmdToOpRev_next <= '0';
					-- IP impl.op.rising.init --- IEND

					if tixVCommandOp/=x"00" then
						-- IP impl.op.rising.init.start --- IBEGIN
						if tixVCommandOp=tixVCommandGetFrame then
							Npix := 64;
						else
							Npix := 1;
						end if;

						prep_sig_next <= '1';
						-- IP impl.op.rising.init.start --- IEND

						stateOp_next <= stateOpSetMode;
					end if;
				end if;

			elsif stateOp=stateOpInv then
				if ((reqCmdInvSetAdc='0' and ackCmdToOpInvSetAdc='1') or (reqCmdToOpInv='0' and ackCmdToOpInv='1')) then
					-- IP impl.op.rising.inv --- IBEGIN
					ackCmdToOpInvSetAdc_next <= '0';
					ackCmdToOpInv_next <= '0';
					-- IP impl.op.rising.inv --- IEND

					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpRev then
				if (reqCmdToOpRev='0' and ackCmdToOpRev='1') then
					ackCmdToOpRev_next <= '0'; -- IP impl.op.rising.rev --- ILINE

					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpSetMode then
				if ackOpToCmdInvRoicSetMode='1' then
					-- IP impl.op.rising.setMode --- IBEGIN
					if tixVCommandOp/=tixVCommandGetTrace then
						Tfrmrun_next <= '1';
					end if;
					-- IP impl.op.rising.setMode --- IEND

					stateOp_next <= stateOpWaitTfrmBufTemp;
				end if;

			elsif stateOp=stateOpWaitTfrmBufTemp then
				if ((tixVCommandOp=tixVCommandGetTrace or strbTfrm='1') and (tixVCommandOp=tixVCommandGetPixel or pglenBuf/=maxpglenBuf) and tempok='1') then
					pixval <= (others => '0'); -- IP impl.op.rising.waitTfrmBufTemp.pixzero --- ILINE

					if tixVCommandOp=tixVCommandGetPixel then
						stateOp_next <= stateOpAcqstart;

					else
						-- IP impl.op.rising.waitTfrmBufTemp.initadr --- IBEGIN
						if tixVCommandOp=tixVCommandGetFrame then
							aBuf_next(10 downto 8) <= std_logic_vector(to_unsigned(pg0Buf + pglenBuf, 4)(2 downto 0));
							aBuf_next(7 downto 2) <= (others => '0');
							aBuf_next(1 downto 0) <= (others => '0');
						elsif tixVCommandOp=tixVCommandGetTrace then
							aBuf_next(10) <= std_logic(to_unsigned(pg0Buf + pglenBuf, 4)(0));
							aBuf_next(9 downto 1) <= (others => '0');
							aBuf_next(0) <= '0';
						end if;
						-- IP impl.op.rising.waitTfrmBufTemp.initadr --- IEND

						stateOp_next <= stateOpGetTkst;
					end if;
				end if;

			elsif stateOp=stateOpGetTkst then
				if ackOpToCmdInvTkclksrcGetTkst='1' then
					-- IP impl.op.rising.getTkst --- IBEGIN
					tkst(31 downto 24) <= cmdbuf(ixCmdbufRetTkclksrcGetTkstTkst);
					tkst(23 downto 16) <= cmdbuf(ixCmdbufRetTkclksrcGetTkstTkst+1);
					tkst(15 downto 8) <= cmdbuf(ixCmdbufRetTkclksrcGetTkstTkst+2);
					tkst(7 downto 0) <= cmdbuf(ixCmdbufRetTkclksrcGetTkstTkst+3);
					-- IP impl.op.rising.getTkst --- IEND

					stateOp_next <= stateOpGetNtc;
				end if;

			elsif stateOp=stateOpGetNtc then
				if ackOpToCmdInvVmonGetNtc='1' then
					-- IP impl.op.rising.getNtc --- IBEGIN
					ntc(15 downto 8) <= cmdbuf(ixCmdbufRetVmonGetNtcNtc);
					ntc(7 downto 0) <= cmdbuf(ixCmdbufRetVmonGetNtcNtc+1);
					-- IP impl.op.rising.getNtc --- IEND

					stateOp_next <= stateOpAcqstart;
				end if;

			elsif stateOp=stateOpAcqstart then
				-- IP impl.op.rising.acqstart --- IBEGIN
				smpcnt := 0;
				pixcnt := 0;

				cpsrun_next <= '1';
				rng_sig_next <= '1'; -- first cmtclk='1' will take several mclk cycles from here
				-- IP impl.op.rising.acqstart --- IEND

				stateOp_next <= stateOpSmploop;

			elsif stateOp=stateOpSmploop then
				if smpcnt=Nsmp then
					-- IP impl.op.rising.smploop.eop --- IBEGIN
					cpsrun_next <= '0';
					rng_sig_next <= '0';
					-- IP impl.op.rising.smploop.eop --- IEND

					if tixVCommandOp=tixVCommandGetPixel then
						reqOpToCmdNewretGetPixel_next <= '1'; -- IP impl.op.rising.smploop.newret --- ILINE

						stateOp_next <= stateOpRet;

					else
						stateOp_next <= stateOpCnfwr;
					end if;

				else
					stateOp_next <= stateOpPixloop;
				end if;

			elsif stateOp=stateOpPixloop then
				if pixcnt=Npix then
					-- IP impl.op.rising.pixloop.initpix --- IBEGIN
					pixcnt := 0;
					smpcnt := smpcnt + 1;
					-- IP impl.op.rising.pixloop.initpix --- IEND

					stateOp_next <= stateOpSmploop;

				elsif strbCps='1' then
					if tdly=0 then
						j := 0; -- IP impl.op.rising.pixloop.initconv --- ILINE

						stateOp_next <= stateOpWaitConv;

					else
						i := 0; -- IP impl.op.rising.pixloop.initdly --- ILINE

						stateOp_next <= stateOpDelay;
					end if;
				end if;

			elsif stateOp=stateOpDelay then
				i := i + 1; -- IP impl.op.rising.delay.ext --- ILINE

				if i=tdly then
					j := 0; -- IP impl.op.rising.delay.initconv --- ILINE

					stateOp_next <= stateOpWaitConv;
				end if;

			elsif stateOp=stateOpWaitConv then
				j := j + 1; -- IP impl.op.rising.waitConv.ext --- ILINE

				if j=16*(fMclk/10000) then
					-- IP impl.op.rising.waitConv.initspi --- IBEGIN
					spilen <= std_logic_vector(to_unsigned(2, 11));

					bytecnt := 0;
					-- IP impl.op.rising.waitConv.initspi --- IEND

					stateOp_next <= stateOpGetA;
				end if;

			elsif stateOp=stateOpGetA then
				if dneSpi='1' then
					if (tixVCommandOp=tixVCommandGetFrame and smpcnt/=0) then
						k := 0; -- IP impl.op.rising.getA.initload --- ILINE

						stateOp_next <= stateOpLoadA;

					else
						stateOp_next <= stateOpAdd;
					end if;

				elsif strbSpirecv='0' then
					stateOp_next <= stateOpGetB;
				end if;

			elsif stateOp=stateOpGetB then
				if strbSpirecv='1' then
					-- IP impl.op.rising.getB --- IBEGIN
					if bytecnt=0 then
						adcval(13 downto 6) := spirecv;
					elsif bytecnt=1 then
						adcval(5 downto 0) := spirecv(7 downto 2);
					end if;
					-- IP impl.op.rising.getB --- IEND

					stateOp_next <= stateOpGetC;
				end if;

			elsif stateOp=stateOpGetC then
				bytecnt := bytecnt + 1; -- IP impl.op.rising.getC --- ILINE

				stateOp_next <= stateOpGetA;

			elsif stateOp=stateOpLoadA then
				stateOp_next <= stateOpLoadB;

			elsif stateOp=stateOpLoadB then
				-- IP impl.op.rising.loadB.ext --- IBEGIN
				if k=0 then
					pixval(31 downto 24) <= drdBuf;
				elsif k=1 then
					pixval(23 downto 16) <= drdBuf;
				elsif k=2 then
					pixval(15 downto 8) <= drdBuf;
				elsif k=3 then
					pixval(7 downto 0) <= drdBuf;
				end if;

				k := k + 1;
				aBuf_next(1 downto 0) <= std_logic_vector(unsigned(aBuf(1 downto 0)) + 1);
				-- IP impl.op.rising.loadB.ext --- IEND

				if k=4 then
					stateOp_next <= stateOpAdd;

				else
					stateOp_next <= stateOpLoadA;
				end if;

			elsif stateOp=stateOpAdd then
				-- IP impl.op.rising.add.ext --- IBEGIN
				x := "00" & adcval;
				pixval <= std_logic_vector(unsigned(pixval) + unsigned(x));
				-- IP impl.op.rising.add.ext --- IEND

				if tixVCommandOp=tixVCommandGetFrame then
					k := 0; -- IP impl.op.rising.add.initstfr --- ILINE

					stateOp_next <= stateOpStoreA;

				elsif tixVCommandOp=tixVCommandGetTrace then
					k := 2; -- IP impl.op.rising.add.initsttr --- ILINE

					stateOp_next <= stateOpStoreA;

				else
					stateOp_next <= stateOpPixdone;
				end if;

			elsif stateOp=stateOpStoreA then
				-- IP impl.op.rising.storeA --- IBEGIN
				if k=0 then
					dwrBuf <= pixval(31 downto 24);
				elsif k=1 then
					dwrBuf <= pixval(23 downto 16);
				elsif k=2 then
					dwrBuf <= pixval(15 downto 8);
				elsif k=3 then
					dwrBuf <= pixval(7 downto 0);
				end if;
				-- IP impl.op.rising.storeA --- IEND

				stateOp_next <= stateOpStoreB;

			elsif stateOp=stateOpStoreB then
				-- IP impl.op.rising.storeB.ext --- IBEGIN
				k := k + 1;
				if tixVCommandOp=tixVCommandGetFrame then
					aBuf_next(1 downto 0) <= std_logic_vector(unsigned(aBuf(1 downto 0)) + 1);
				elsif tixVCommandOp=tixVCommandGetTrace then
					aBuf_next(0) <= not aBuf(0);
				end if;
				-- IP impl.op.rising.storeB.ext --- IEND

				if k=4 then
					stateOp_next <= stateOpPixdone;

				else
					stateOp_next <= stateOpStoreA;
				end if;

			elsif stateOp=stateOpPixdone then
				-- IP impl.op.rising.pixdone --- IBEGIN
				if tixVCommandOp=tixVCommandGetFrame then
					aBuf_next(7 downto 2) <= std_logic_vector(unsigned(aBuf(7 downto 2)) + 1);
				elsif tixVCommandOp=tixVCommandGetTrace then
					aBuf_next(9 downto 1) <= std_logic_vector(unsigned(aBuf(9 downto 1)) + 1);
				end if;

				pixcnt := pixcnt + 1;
				-- IP impl.op.rising.pixdone --- IEND

				stateOp_next <= stateOpPixloop;

			elsif stateOp=stateOpCnfwr then
				if ackOpToBufCnfwr='1' then
					-- IP impl.op.rising.cnfwr --- IBEGIN
					if tixVCommandOp=tixVCommandGetFrame then
						reqOpToCmdNewretGetFrame_next <= '1';
					elsif tixVCommandOp=tixVCommandGetTrace then
						reqOpToCmdRetGetTrace_next <= '1';
					end if;
					-- IP impl.op.rising.cnfwr --- IEND

					stateOp_next <= stateOpRet;
				end if;

			elsif stateOp=stateOpRet then
				if (ackOpToCmdRetGetTrace='1' or ackOpToCmdNewretGetFrame='1' or ackOpToCmdNewretGetPixel='1') then
					stateOp_next <= stateOpWaitTfrmBufTemp;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.op.rising --- END

	-- IP impl.op.falling --- BEGIN
	process (mclk)
		-- IP impl.op.falling.vars --- BEGIN
		-- IP impl.op.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			cpsrun <= cpsrun_next;
			Tfrmrun <= Tfrmrun_next;
			aBuf <= aBuf_next;
			prep_sig <= prep_sig_next;
			rng_sig <= rng_sig_next;
			ackCmdToOpInvSetAdc <= ackCmdToOpInvSetAdc_next;
			ackCmdToOpInv <= ackCmdToOpInv_next;
			ackCmdToOpRev <= ackCmdToOpRev_next;
			reqOpToCmdNewretGetFrame <= reqOpToCmdNewretGetFrame_next;
			reqOpToCmdNewretGetPixel <= reqOpToCmdNewretGetPixel_next;
			reqOpToCmdRetGetTrace <= reqOpToCmdRetGetTrace_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: frame clock (tfrm)
	------------------------------------------------------------------------

	-- IP impl.tfrm.wiring --- RBEGIN
	strbTfrm <= '1' when (tkclk='1' and stateTfrm=stateTfrmRunA) else '0';
	-- IP impl.tfrm.wiring --- REND

	-- IP impl.tfrm.rising --- BEGIN
	process (reset, mclk, stateTfrm)
		-- IP impl.tfrm.rising.vars --- RBEGIN
		variable Tfrm: natural range 0 to 65535;

		variable i: natural range 0 to 65535; -- frame rate counter

		variable x: std_logic_vector(15 downto 0);
		-- IP impl.tfrm.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.tfrm.rising.asyncrst --- BEGIN
			stateTfrm_next <= stateTfrmInit;
			ackCmdToTfrmInvSetTfrm_next <= '0';
			-- IP impl.tfrm.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateTfrm=stateTfrmInit or (stateTfrm/=stateTfrmInv and (reqCmdToTfrmInvSetTfrm='1' or Tfrmrun='0'))) then
				if reqCmdToTfrmInvSetTfrm='1' then
					-- IP impl.tfrm.rising.init.setTfrm --- IBEGIN
					x := cmdbuf(ixCmdbufInvSetTfrmTfrm) & cmdbuf(ixCmdbufInvSetTfrmTfrm+1);
					Tfrm := to_integer(unsigned(x));
	
					ackCmdToTfrmInvSetTfrm_next <= '1';
					-- IP impl.tfrm.rising.init.setTfrm --- IEND

					stateTfrm_next <= stateTfrmInv;

				else
					-- IP impl.tfrm.rising.syncrst --- BEGIN
					ackCmdToTfrmInvSetTfrm_next <= '0';

					-- IP impl.tfrm.rising.syncrst --- END

					if Tfrmrun='0' then
						stateTfrm_next <= stateTfrmInit;

					else
						stateTfrm_next <= stateTfrmReady;
					end if;
				end if;

			elsif stateTfrm=stateTfrmInv then
				if (reqCmdToTfrmInvSetTfrm='0' and ackCmdToTfrmInvSetTfrm='1') then
					stateTfrm_next <= stateTfrmInit;
				end if;

			elsif stateTfrm=stateTfrmReady then
				if tkclk='0' then
					i := 0; -- IP impl.tfrm.rising.ready.init --- ILINE

					stateTfrm_next <= stateTfrmRunA;
				end if;

			elsif stateTfrm=stateTfrmRunA then
				if tkclk='1' then
					stateTfrm_next <= stateTfrmRunC;
				end if;

			elsif stateTfrm=stateTfrmRunB then
				if tkclk='1' then
					stateTfrm_next <= stateTfrmRunC;
				end if;

			elsif stateTfrm=stateTfrmRunC then
				if tkclk='0' then
					i := i + 1; -- IP impl.tfrm.rising.runC.inc --- ILINE

					if i=Tfrm then
						i := 0; -- IP impl.tfrm.rising.runC.init --- ILINE

						stateTfrm_next <= stateTfrmRunA;

					else
						stateTfrm_next <= stateTfrmRunB;
					end if;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.tfrm.rising --- END

	-- IP impl.tfrm.falling --- BEGIN
	process (mclk)
		-- IP impl.tfrm.falling.vars --- BEGIN
		-- IP impl.tfrm.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateTfrm <= stateTfrm_next;
			ackCmdToTfrmInvSetTfrm <= ackCmdToTfrmInvSetTfrm_next;
		end if;
	end process;
	-- IP impl.tfrm.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Acq;


