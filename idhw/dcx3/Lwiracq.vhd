-- file Lwiracq.vhd
-- Lwiracq controller implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 15 Aug 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Lwiracq is
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

		rdyCmdbusFromPmmu: out std_logic;
		rdCmdbusFromPmmu: in std_logic;

		reqCmdbusToTkclksrc: out std_logic;
		wrCmdbusToTkclksrc: in std_logic;

		rdyCmdbusFromTkclksrc: out std_logic;
		rdCmdbusFromTkclksrc: in std_logic;

		clkInbuf0ToPmmu: out std_logic;

		reqInbuf0ToPmmu: out std_logic;
		ackInbuf0ToPmmu: in std_logic;
		dneInbuf0ToPmmu: out std_logic;

		avllenInbuf0ToPmmu: in std_logic_vector(18 downto 0);
		-- slot size of pmmu of bss3 is 40p => 163840, pmmu of zedb/dcx3 are 132p => 540672

		dInbuf0ToPmmu: out std_logic_vector(7 downto 0);
		strbDInbuf0ToPmmu: out std_logic;

		trigLwir: in std_logic;

		clk: in std_logic;
		snc: in std_logic;
		d1: in std_logic;
		d2: in std_logic;
		extsnc: out std_logic
	);
end Lwiracq;

architecture Lwiracq of Lwiracq is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	constant fls: std_logic_vector(7 downto 0) := x"55";
	constant tru: std_logic_vector(7 downto 0) := x"AA";

	constant w: natural range 0 to 640 := 640;
	constant h: natural range 0 to 480 := 480;

	---- frame acquisition
	type stateAcq_t is (
		stateAcqInit,
		stateAcqIdle,
		stateAcqRun
	);
	signal stateAcq, stateAcq_next: stateAcq_t := stateAcqIdle;

	signal enBufA: std_logic := '0';

	signal aBufA: std_logic_vector(12 downto 0) := "0000000000000";
	signal dwrBufA: std_logic_vector(7 downto 0) := x"00";

	-- IP sigs.acq.cust --- IBEGIN
	signal pixval: std_logic_vector(13 downto 0);
	-- IP sigs.acq.cust --- IEND

	---- command execution
	type stateCmd_t is (
		stateCmdInit,
		stateCmdEmpty,
		stateCmdWaitLockA, stateCmdWaitLockB, stateCmdWaitLockC,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE,
		stateCmdRecvF, stateCmdRecvG,
		stateCmdFullA, stateCmdFullB,
		stateCmdSendA, stateCmdSendB, stateCmdSendC, stateCmdSendD,
		stateCmdPrepNewretGetFrame,
		stateCmdPrepCreferrGetFrame,
		stateCmdPrepCreferr,
		stateCmdPrepInvPmmuAlloc,
		stateCmdPrepInvPmmuFree,
		stateCmdPrepInvPmmuWriteInbuf0,
		stateCmdPrepInvTkclksrcGetTkst
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	constant tixDbeVActionInv: std_logic_vector(7 downto 0) := x"00";
	constant tixDbeVActionRev: std_logic_vector(7 downto 0) := x"01";
	constant tixDbeVActionRet: std_logic_vector(7 downto 0) := x"80";
	constant tixDbeVActionNewret: std_logic_vector(7 downto 0) := x"81";
	constant tixDbeVActionCreferr: std_logic_vector(7 downto 0) := x"F2";

	constant tixVDcx3ControllerCmdinv: std_logic_vector(7 downto 0) := x"01";
	constant tixVDcx3ControllerCmdret: std_logic_vector(7 downto 0) := x"02";
	constant tixVDcx3ControllerLwiracq: std_logic_vector(7 downto 0) := x"06";
	constant tixVDcx3ControllerPmmu: std_logic_vector(7 downto 0) := x"08";
	constant tixVDcx3ControllerTkclksrc: std_logic_vector(7 downto 0) := x"0B";

	constant tixVDepthD2: std_logic_vector(7 downto 0) := x"01";
	constant tixVDepthD4: std_logic_vector(7 downto 0) := x"02";
	constant tixVDepthD8: std_logic_vector(7 downto 0) := x"03";
	constant tixVDepthD12: std_logic_vector(7 downto 0) := x"04";
	constant tixVDepthD14: std_logic_vector(7 downto 0) := x"05";

	constant sizeCmdbuf: natural range 0 to 15 := 15;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	constant ixCmdbufRoute: natural range 0 to sizeCmdbuf-1 := 0;
	constant ixCmdbufAction: natural range 0 to sizeCmdbuf-1 := 4;
	constant ixCmdbufCref: natural range 0 to sizeCmdbuf-1 := 5;
	constant ixCmdbufInvCommand: natural range 0 to sizeCmdbuf-1 := 9;
	constant ixCmdbufCreferrCref: natural range 0 to sizeCmdbuf-1 := 9;

	constant lenCmdbufRev: natural range 0 to sizeCmdbuf := 9;
	constant lenCmdbufCreferr: natural range 0 to sizeCmdbuf := 13;

	-- inv: getFrame
	-- rev: getFrame
	-- newret: getFrame
	-- creferr

	-- outgoing inv: pmmu.alloc, pmmu.free, pmmu.writeInbuf0, tkclksrc.getTkst
	-- incoming ret: pmmu.alloc, tkclksrc.getTkst
	-- deferred incoming ret: pmmu.writeInbuf0

	constant tixVCommandGetFrame: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvGetFrame: natural range 0 to sizeCmdbuf := 11;
	constant ixCmdbufInvGetFrameTixVDepth: natural range 0 to sizeCmdbuf-1 := 10;
	constant lenCmdbufNewretGetFrame: natural range 0 to sizeCmdbuf := 15;
	constant ixCmdbufNewretGetFrameTkst: natural range 0 to sizeCmdbuf-1 := 9;
	constant ixCmdbufNewretGetFrameTixVDcx3PmmuSlot: natural range 0 to sizeCmdbuf-1 := 13;
	constant ixCmdbufNewretGetFrameAvlpglen: natural range 0 to sizeCmdbuf-1 := 14;

	constant tixVDcx3PmmuCommandAlloc: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvPmmuAlloc: natural range 0 to sizeCmdbuf := 12;
	constant ixCmdbufInvPmmuAllocDynNotStat: natural range 0 to sizeCmdbuf-1 := 10;
	constant ixCmdbufInvPmmuAllocReqPglen: natural range 0 to sizeCmdbuf-1 := 11;
	constant lenCmdbufRetPmmuAlloc: natural range 0 to sizeCmdbuf := 10;
	constant ixCmdbufRetPmmuAllocTixVSlot: natural range 0 to sizeCmdbuf-1 := 9;

	constant tixVDcx3PmmuCommandFree: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvPmmuFree: natural range 0 to sizeCmdbuf := 11;
	constant ixCmdbufInvPmmuFreeTixVSlot: natural range 0 to sizeCmdbuf-1 := 10;

	constant tixVDcx3PmmuCommandWriteInbuf0: std_logic_vector(7 downto 0) := x"03";
	constant lenCmdbufInvPmmuWriteInbuf0: natural range 0 to sizeCmdbuf := 11;
	constant ixCmdbufInvPmmuWriteInbuf0TixVSlot: natural range 0 to sizeCmdbuf-1 := 10;
	constant lenCmdbufRetPmmuWriteInbuf0: natural range 0 to sizeCmdbuf := 9;

	constant tixVDcx3TkclksrcCommandGetTkst: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvTkclksrcGetTkst: natural range 0 to sizeCmdbuf := 10;
	constant lenCmdbufRetTkclksrcGetTkst: natural range 0 to sizeCmdbuf := 13;
	constant ixCmdbufRetTkclksrcGetTkstTkst: natural range 0 to sizeCmdbuf-1 := 9;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal rdyCmdbusFromPmmu_sig, rdyCmdbusFromPmmu_sig_next: std_logic;
	signal rdyCmdbusFromTkclksrc_sig, rdyCmdbusFromTkclksrc_sig_next: std_logic;
	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;
	signal reqCmdbusToPmmu_sig, reqCmdbusToPmmu_sig_next: std_logic;
	signal reqCmdbusToTkclksrc_sig, reqCmdbusToTkclksrc_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- memory streaming operation
	type stateMem_t is (
		stateMemInit,
		stateMemIdle,
		stateMemStreamA, stateMemStreamB, stateMemStreamC,
		stateMemFillA, stateMemFillB, stateMemFillC
	);
	signal stateMem, stateMem_next: stateMem_t := stateMemIdle;

	signal dInbuf0ToPmmu_sig, dInbuf0ToPmmu_sig_next: std_logic_vector(7 downto 0);

	---- main operation
	type stateOp_t is (
		stateOpInit,
		stateOpIdle,
		stateOpStart,
		stateOpWaitNewfrm,
		stateOpGetTkst,
		stateOpAlloc,
		stateOpInvWrite,
		stateOpNewret,
		stateOpStreamA, stateOpStreamB, stateOpStreamC, stateOpStreamD, stateOpStreamE,
		stateOpFillA, stateOpFillB, stateOpFillC,
		stateOpWaitRetWriteA, stateOpWaitRetWriteB,
		stateOpFree,
		stateOpStop
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpIdle;

	-- IP sigs.op.cust --- IBEGIN
	signal acqrun: std_logic;

	signal routeOp: std_logic_vector(7 downto 0);
	signal crefOp: std_logic_vector(31 downto 0);

	signal tixVDepth: std_logic_vector(7 downto 0);

	signal tkst: std_logic_vector(31 downto 0);
	signal tixVSlot: std_logic_vector(7 downto 0);

	type pixbuf_t is array (0 to 6) of std_logic_vector(7 downto 0);
	signal pixbuf: pixbuf_t;
	-- IP sigs.op.cust --- IEND

	---- handshake
	-- acq to op
	signal reqAcqToOpNewfrm: std_logic;
	signal ackAcqToOpNewfrm: std_logic;

	signal reqAcqToOpNewpix: std_logic;
	signal ackAcqToOpNewpix: std_logic;

	-- cmd to op
	signal reqCmdToOpInvGetFrame, reqCmdToOpInvGetFrame_next: std_logic;
	signal ackCmdToOpInvGetFrame: std_logic;

	signal reqCmdToOpRevGetFrame, reqCmdToOpRevGetFrame_next: std_logic;
	signal ackCmdToOpRevGetFrame: std_logic;

	signal reqCmdToOpRetPmmuWriteInbuf0, reqCmdToOpRetPmmuWriteInbuf0_next: std_logic;
	signal ackCmdToOpRetPmmuWriteInbuf0: std_logic;

	-- op to cmd
	signal reqOpToCmdNewretGetFrame: std_logic;
	signal ackOpToCmdNewretGetFrame, ackOpToCmdNewretGetFrame_next: std_logic;

	signal reqOpToCmdInvPmmuAlloc: std_logic;
	signal ackOpToCmdInvPmmuAlloc, ackOpToCmdInvPmmuAlloc_next: std_logic;

	signal reqOpToCmdInvPmmuFree: std_logic;
	signal ackOpToCmdInvPmmuFree, ackOpToCmdInvPmmuFree_next: std_logic;

	signal reqOpToCmdInvPmmuWriteInbuf0: std_logic;
	signal ackOpToCmdInvPmmuWriteInbuf0, ackOpToCmdInvPmmuWriteInbuf0_next: std_logic;

	signal reqOpToCmdInvTkclksrcGetTkst: std_logic;
	signal ackOpToCmdInvTkclksrcGetTkst, ackOpToCmdInvTkclksrcGetTkst_next: std_logic;

	-- op to mem
	signal reqOpToMem, reqOpToMem_next: std_logic_vector(0 to 6);
	signal ackOpToMem, ackOpToMem_next: std_logic_vector(0 to 6);

	signal reqOpToMemFill: std_logic;
	signal ackOpToMemFill: std_logic;

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- implementation: frame acquisition
	------------------------------------------------------------------------

	-- IP impl.acq.wiring --- BEGIN
	-- IP impl.acq.wiring --- END

	process (reset, clk)
		-- IP impl.acq.rising.vars --- RBEGIN
		constant tknIdle: std_logic_vector(6 downto 0) := "1100000";
		constant tknFrmstart: std_logic_vector(6 downto 0) := "1110000";
		constant tknValid: std_logic_vector(6 downto 0) := "1100100";
		variable tkn: std_logic_vector(6 downto 0);

		variable data1, data2: std_logic_vector(6 downto 0);

		variable i: natural range 0 to 512; -- row counter
		variable j: natural range 0 to 640; -- column counter
		-- IP impl.acq.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.acq.rising.asyncrst --- BEGIN
			stateAcq_next <= stateAcqInit;
			-- IP impl.acq.rising.asyncrst --- END

		elsif falling_edge(clk) then
			if (stateAcq=stateAcqInit or acqrun='0') then
				-- IP impl.acq.rising.syncrst --- RBEGIN
				reqAcqToOpNewfrm <= '0';
				reqAcqToOpNewpix <= '0';

				tkn := "0000000";
				-- IP impl.acq.rising.syncrst --- REND

				if acqrun='0' then
					stateAcq_next <= stateAcqInit;
				else
					stateAcq_next <= stateAcqIdle;
				end if;

			elsif stateAcq=stateAcqIdle then
				tkn := tkn(5 downto 0) & snc; -- IP impl.acq.rising.idle.ext --- ILINE

				if tkn=tknFrmstart then
					-- IP impl.acq.rising.idle.start --- IBEGIN
					i := 0;
					j := 0;

					reqAcqToOpNewfrm <= '1';
					-- IP impl.acq.rising.idle.start --- IEND

					stateAcq_next <= stateAcqRun;

				elsif ackAcqToOpNewpix='1' then
					reqAcqToOpNewpix <= '0'; -- IP impl.acq.rising.idle.reset --- ILINE
					stateAcq_next <= stateAcqIdle;
				end if;

			elsif stateAcq=stateAcqRun then
				-- IP impl.acq.rising.run.ext --- IBEGIN
				if ackAcqToOpNewfrm='1' then
					reqAcqToOpNewfrm <= '0';
				end if;

				tkn := tkn(5 downto 0) & snc;
				data1 := data1(5 downto 0) & d1;
				data2 := data2(5 downto 0) & d2;
				-- IP impl.acq.rising.run.ext --- IEND

				if tkn=tknValid then
					-- IP impl.acq.rising.run.valid --- IBEGIN
					-- new pixel received
					pixval <= data2 & data1;

					if (i>=16 and i<496) then -- padding to 640x480 ; at 60Hz frame rate this corr. to 520µs or 26'000 mclk cycles
						reqAcqToOpNewpix <= '1';
					end if;

					j := j + 1;
					-- IP impl.acq.rising.run.valid --- IEND

					if j=640 then
						-- IP impl.acq.rising.run.eol --- IBEGIN
						j := 0;
						
						i := i + 1;
						-- IP impl.acq.rising.run.eol --- IEND

						if i=512 then
							i := 0; -- IP impl.acq.rising.run.eof --- ILINE

							stateAcq_next <= stateAcqIdle;
						end if;
					end if;

				else
					-- IP impl.acq.rising.run.invalid --- IBEGIN
					if ackAcqToOpNewpix='1' then
						reqAcqToOpNewpix <= '0';
					end if;
					-- IP impl.acq.rising.run.invalid --- IEND

					if (tkn="0000000" or tkn=tknFrmstart) then
						stateAcq_next <= stateAcqInit;
					end if;
				end if;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			stateAcq <= stateAcq_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: command execution
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	rdyCmdbusFromPmmu <= rdyCmdbusFromPmmu_sig;
	rdyCmdbusFromTkclksrc <= rdyCmdbusFromTkclksrc_sig;
	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	reqCmdbusToPmmu <= reqCmdbusToPmmu_sig;
	reqCmdbusToTkclksrc <= reqCmdbusToTkclksrc_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- BEGIN
		variable lenCmdbuf: natural range 0 to sizeCmdbuf;
		variable bytecnt: natural range 0 to sizeCmdbuf;

		variable i, j: natural range 0 to sizeCmdbuf;
		variable x: std_logic_vector(7 downto 0);
		-- IP impl.cmd.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			reqCmdToOpInvGetFrame_next <= '0';
			reqCmdToOpRevGetFrame_next <= '0';
			reqCmdToOpRetPmmuWriteInbuf0_next <= '0';
			ackOpToCmdNewretGetFrame_next <= '0';
			ackOpToCmdInvPmmuAlloc_next <= '0';
			ackOpToCmdInvPmmuFree_next <= '0';
			ackOpToCmdInvPmmuWriteInbuf0_next <= '0';
			ackOpToCmdInvTkclksrcGetTkst_next <= '0';
			dCmdbus_sig_next <= "ZZZZZZZZ";
			rdyCmdbusFromCmdinv_sig_next <= '1';
			rdyCmdbusFromPmmu_sig_next <= '1';
			rdyCmdbusFromTkclksrc_sig_next <= '1';
			reqCmdbusToCmdret_sig_next <= '0';
			reqCmdbusToPmmu_sig_next <= '0';
			reqCmdbusToTkclksrc_sig_next <= '0';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				reqCmdToOpInvGetFrame_next <= '0';
				reqCmdToOpRevGetFrame_next <= '0';
				reqCmdToOpRetPmmuWriteInbuf0_next <= '0';
				ackOpToCmdNewretGetFrame_next <= '0';
				ackOpToCmdInvPmmuAlloc_next <= '0';
				ackOpToCmdInvPmmuFree_next <= '0';
				ackOpToCmdInvPmmuWriteInbuf0_next <= '0';
				ackOpToCmdInvTkclksrcGetTkst_next <= '0';

				dCmdbus_sig_next <= "ZZZZZZZZ";

				rdyCmdbusFromCmdinv_sig_next <= '1';
				rdyCmdbusFromPmmu_sig_next <= '1';
				rdyCmdbusFromTkclksrc_sig_next <= '1';
				reqCmdbusToCmdret_sig_next <= '0';
				reqCmdbusToPmmu_sig_next <= '0';
				reqCmdbusToTkclksrc_sig_next <= '0';

				lenCmdbuf := 0;

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
	
					stateCmd_next <= stateCmdRecvA;
	
				elsif (reqOpToCmdNewretGetFrame='1' or reqOpToCmdInvPmmuAlloc='1' or reqOpToCmdInvPmmuFree='1' or reqOpToCmdInvPmmuWriteInbuf0='1' or reqOpToCmdInvTkclksrcGetTkst='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
					rdyCmdbusFromPmmu_sig_next <= '0';
					rdyCmdbusFromTkclksrc_sig_next <= '0';
	
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
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromPmmu='0' and rdCmdbusFromTkclksrc='0') then
						if reqOpToCmdNewretGetFrame='1' then
							stateCmd_next <= stateCmdPrepNewretGetFrame;
						elsif reqOpToCmdInvPmmuAlloc='1' then
							stateCmd_next <= stateCmdPrepInvPmmuAlloc;
						elsif reqOpToCmdInvPmmuFree='1' then
							stateCmd_next <= stateCmdPrepInvPmmuFree;
						elsif reqOpToCmdInvPmmuWriteInbuf0='1' then
							stateCmd_next <= stateCmdPrepInvPmmuWriteInbuf0;
						elsif reqOpToCmdInvTkclksrcGetTkst='1' then
							stateCmd_next <= stateCmdPrepInvTkclksrcGetTkst;
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
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromPmmu='0' and rdCmdbusFromTkclksrc='0') then
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
						x := tixVDcx3ControllerCmdret;
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
						reqCmdToOpInvGetFrame_next <= '1';
						stateCmd_next <= stateCmdRecvG;
					else
						stateCmd_next <= stateCmdPrepCreferrGetFrame;
					end if;
	
				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRev and lenCmdbuf=lenCmdbufRev) then
					if (cmdbuf(ixCmdbufCref)=crefOp(31 downto 24) and cmdbuf(ixCmdbufCref+1)=crefOp(23 downto 16) and cmdbuf(ixCmdbufCref+2)=crefOp(15 downto 8) and cmdbuf(ixCmdbufCref+3)=crefOp(7 downto 0)) then
						reqCmdToOpRevGetFrame_next <= '1';
						stateCmd_next <= stateCmdRecvG;
					else
						stateCmd_next <= stateCmdPrepCreferrGetFrame;
					end if;
	
				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRet and cmdbuf(ixCmdbufCref)=tixVDcx3PmmuCommandAlloc and	lenCmdbuf=lenCmdbufRetPmmuAlloc) then
					ackOpToCmdInvPmmuAlloc_next <= '1';
					stateCmd_next <= stateCmdRecvG;
				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRet and cmdbuf(ixCmdbufCref)=tixVDcx3PmmuCommandWriteInbuf0 and	lenCmdbuf=lenCmdbufRetPmmuWriteInbuf0) then
					reqCmdToOpRetPmmuWriteInbuf0_next <= '1';
					stateCmd_next <= stateCmdRecvG;
				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRet and cmdbuf(ixCmdbufCref)=tixVDcx3TkclksrcCommandGetTkst and	lenCmdbuf=lenCmdbufRetTkclksrcGetTkst) then
					ackOpToCmdInvTkclksrcGetTkst_next <= '1';
					stateCmd_next <= stateCmdRecvG;
	
				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdRecvG then
				if ((reqCmdToOpInvGetFrame='1' and ackCmdToOpInvGetFrame='1') or (reqCmdToOpRevGetFrame='1' and ackCmdToOpRevGetFrame='1') or (ackOpToCmdInvPmmuAlloc='1' and reqOpToCmdInvPmmuAlloc='0')
							or (reqCmdToOpRetPmmuWriteInbuf0='1' and ackCmdToOpRetPmmuWriteInbuf0='1') or (ackOpToCmdInvTkclksrcGetTkst='1' and reqOpToCmdInvTkclksrcGetTkst='0')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullA then
				if cmdbuf(ixCmdbufRoute)=tixVDcx3ControllerCmdret then
					reqCmdbusToCmdret_sig_next <= '1';
				elsif cmdbuf(ixCmdbufRoute)=tixVDcx3ControllerPmmu then
					reqCmdbusToPmmu_sig_next <= '1';
				elsif cmdbuf(ixCmdbufRoute)=tixVDcx3ControllerTkclksrc then
					reqCmdbusToTkclksrc_sig_next <= '1';
				end if;

				stateCmd_next <= stateCmdFullB;

			elsif stateCmd=stateCmdFullB then
				if ((wrCmdbusToCmdret='1' or wrCmdbusToPmmu='1' or wrCmdbusToTkclksrc='1') and clkCmdbus='1') then
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
							reqCmdbusToPmmu_sig_next <= '0';
							reqCmdbusToTkclksrc_sig_next <= '0';
						end if;
						
						stateCmd_next <= stateCmdSendA;
					end if;
				end if;

			elsif stateCmd=stateCmdSendC then
				if (wrCmdbusToCmdret='0' and wrCmdbusToPmmu='0' and wrCmdbusToTkclksrc='0') then
					if (reqOpToCmdNewretGetFrame='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionNewret and cmdbuf(ixCmdbufCref)=crefOp(31 downto 24) and cmdbuf(ixCmdbufCref+1)=crefOp(23 downto 16) and cmdbuf(ixCmdbufCref+2)=crefOp(15 downto 8) and cmdbuf(ixCmdbufCref+3)=crefOp(7 downto 0)) then
						ackOpToCmdNewretGetFrame_next <= '1';
						stateCmd_next <= stateCmdSendD;
					elsif (reqOpToCmdInvPmmuFree='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufCref)=tixVDcx3PmmuCommandFree) then
						ackOpToCmdInvPmmuFree_next <= '1';
						stateCmd_next <= stateCmdSendD;
					elsif (reqOpToCmdInvPmmuWriteInbuf0='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufCref)=tixVDcx3PmmuCommandWriteInbuf0) then
						ackOpToCmdInvPmmuWriteInbuf0_next <= '1';
						stateCmd_next <= stateCmdSendD;

					else
						stateCmd_next <= stateCmdInit;
					end if;
				end if;

			elsif stateCmd=stateCmdSendD then
				if ((ackOpToCmdNewretGetFrame='1' and reqOpToCmdNewretGetFrame='0') or (ackOpToCmdInvPmmuWriteInbuf0='1' and reqOpToCmdInvPmmuWriteInbuf0='0')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdPrepNewretGetFrame then
				cmdbuf(ixCmdbufCref) <= crefOp(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefOp(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefOp(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefOp(7 downto 0);

				-- IP impl.cmd.rising.prepNewretGetFrame --- IBEGIN
				cmdbuf(ixCmdbufNewretGetFrameTkst) <= tkst(31 downto 24);
				cmdbuf(ixCmdbufNewretGetFrameTkst+1) <= tkst(23 downto 16);
				cmdbuf(ixCmdbufNewretGetFrameTkst+2) <= tkst(15 downto 8);
				cmdbuf(ixCmdbufNewretGetFrameTkst+3) <= tkst(7 downto 0);

				cmdbuf(ixCmdbufNewretGetFrameTixVDcx3PmmuSlot) <= tixVSlot;

				if tixVDepth=tixVDepthD2 then
					cmdbuf(ixCmdbufNewretGetFrameAvlpglen) <= std_logic_vector(to_unsigned(19, 8));
				elsif tixVDepth=tixVDepthD4 then
					cmdbuf(ixCmdbufNewretGetFrameAvlpglen) <= std_logic_vector(to_unsigned(38, 8));
				elsif tixVDepth=tixVDepthD8 then
					cmdbuf(ixCmdbufNewretGetFrameAvlpglen) <= std_logic_vector(to_unsigned(75, 8));
				elsif tixVDepth=tixVDepthD12 then
					cmdbuf(ixCmdbufNewretGetFrameAvlpglen) <= std_logic_vector(to_unsigned(113, 8));
				elsif tixVDepth=tixVDepthD14 then
					cmdbuf(ixCmdbufNewretGetFrameAvlpglen) <= std_logic_vector(to_unsigned(132, 8));
				end if;
				-- IP impl.cmd.rising.prepNewretGetFrame --- IEND

				lenCmdbuf := lenCmdbufNewretGetFrame;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepCreferrGetFrame then
				cmdbuf(ixCmdbufCref) <= crefOp(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefOp(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefOp(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefOp(7 downto 0);

				stateCmd_next <= stateCmdPrepCreferr;

			elsif stateCmd=stateCmdPrepCreferr then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionCreferr;
	
				lenCmdbuf := lenCmdbufCreferr;
	
				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvPmmuAlloc then
				cmdbuf(ixCmdbufRoute) <= tixVDcx3ControllerPmmu;
				cmdbuf(ixCmdbufRoute+1) <= tixVDcx3ControllerLwiracq;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVDcx3PmmuCommandAlloc;
				cmdbuf(ixCmdbufInvCommand) <= tixVDcx3PmmuCommandAlloc;

				-- IP impl.cmd.rising.prepInvPmmuAlloc --- IBEGIN
				cmdbuf(ixCmdbufInvPmmuAllocDynNotStat) <= tru;

				if tixVDepth=tixVDepthD2 then
					cmdbuf(ixCmdbufInvPmmuAllocReqPglen) <= std_logic_vector(to_unsigned(19, 8));
				elsif tixVDepth=tixVDepthD4 then
					cmdbuf(ixCmdbufInvPmmuAllocReqPglen) <= std_logic_vector(to_unsigned(38, 8));
				elsif tixVDepth=tixVDepthD8 then
					cmdbuf(ixCmdbufInvPmmuAllocReqPglen) <= std_logic_vector(to_unsigned(75, 8));
				elsif tixVDepth=tixVDepthD12 then
					cmdbuf(ixCmdbufInvPmmuAllocReqPglen) <= std_logic_vector(to_unsigned(113, 8));
				elsif tixVDepth=tixVDepthD14 then
					cmdbuf(ixCmdbufInvPmmuAllocReqPglen) <= std_logic_vector(to_unsigned(132, 8));
				end if;
				-- IP impl.cmd.rising.prepInvPmmuAlloc --- IEND

				lenCmdbuf := lenCmdbufInvPmmuAlloc;
	
				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvPmmuFree then
				cmdbuf(ixCmdbufRoute) <= tixVDcx3ControllerPmmu;
				cmdbuf(ixCmdbufRoute+1) <= tixVDcx3ControllerLwiracq;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVDcx3PmmuCommandFree;
				cmdbuf(ixCmdbufInvCommand) <= tixVDcx3PmmuCommandFree;

				cmdbuf(ixCmdbufInvPmmuFreeTixVSlot) <= tixVSlot; -- IP impl.cmd.rising.prepInvPmmuFree --- ILINE

				lenCmdbuf := lenCmdbufInvPmmuFree;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvPmmuWriteInbuf0 then
				cmdbuf(ixCmdbufRoute) <= tixVDcx3ControllerPmmu;
				cmdbuf(ixCmdbufRoute+1) <= tixVDcx3ControllerLwiracq;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVDcx3PmmuCommandWriteInbuf0;
				cmdbuf(ixCmdbufInvCommand) <= tixVDcx3PmmuCommandWriteInbuf0;

				cmdbuf(ixCmdbufInvPmmuWriteInbuf0TixVSlot) <= tixVSlot; -- IP impl.cmd.rising.prepInvPmmuWriteInbuf0 --- ILINE

				lenCmdbuf := lenCmdbufInvPmmuWriteInbuf0;
	
				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvTkclksrcGetTkst then
				cmdbuf(ixCmdbufRoute) <= tixVDcx3ControllerTkclksrc;
				cmdbuf(ixCmdbufRoute+1) <= tixVDcx3ControllerLwiracq;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVDcx3TkclksrcCommandGetTkst;
				cmdbuf(ixCmdbufInvCommand) <= tixVDcx3TkclksrcCommandGetTkst;
	
				lenCmdbuf := lenCmdbufInvTkclksrcGetTkst;

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
			reqCmdToOpInvGetFrame <= reqCmdToOpInvGetFrame_next;
			reqCmdToOpRevGetFrame <= reqCmdToOpRevGetFrame_next;
			reqCmdToOpRetPmmuWriteInbuf0 <= reqCmdToOpRetPmmuWriteInbuf0_next;
			ackOpToCmdNewretGetFrame <= ackOpToCmdNewretGetFrame_next;
			ackOpToCmdInvPmmuAlloc <= ackOpToCmdInvPmmuAlloc_next;
			ackOpToCmdInvPmmuFree <= ackOpToCmdInvPmmuFree_next;
			ackOpToCmdInvPmmuWriteInbuf0 <= ackOpToCmdInvPmmuWriteInbuf0_next;
			ackOpToCmdInvTkclksrcGetTkst <= ackOpToCmdInvTkclksrcGetTkst_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			dCmdbus_sig <= dCmdbus_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			rdyCmdbusFromPmmu_sig <= rdyCmdbusFromPmmu_sig_next;
			rdyCmdbusFromTkclksrc_sig <= rdyCmdbusFromTkclksrc_sig_next;
			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
			reqCmdbusToPmmu_sig <= reqCmdbusToPmmu_sig_next;
			reqCmdbusToTkclksrc_sig <= reqCmdbusToTkclksrc_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: memory streaming operation
	------------------------------------------------------------------------

	-- IP impl.mem.wiring --- BEGIN
	ackOpToMemFill <= '1' when stateMem=stateMemFillC else '0';

	dInbuf0ToPmmu <= dInbuf0ToPmmu_sig;
	strbDInbuf0ToPmmu <= '1' when (stateMem=stateMemStreamB or stateMem=stateMemStreamC or stateMem=stateMemFillB or stateMem=stateMemFillC) else '0';
	-- IP impl.mem.wiring --- END

	process (reset, fastclk, stateMem)
		-- IP impl.mem.rising.vars --- RBEGIN
		variable i: natural range 0 to 6; -- next index to pixbuf
		variable j: natural range 0 to 4096; -- down counter for page fill
		-- IP impl.mem.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.mem.rising.asyncrst --- BEGIN
			stateMem_next <= stateMemInit;
			dInbuf0ToPmmu_sig_next <= (others => '0');
			ackOpToMem_next <= (others => '0');
			-- IP impl.mem.rising.asyncrst --- END

		elsif rising_edge(fastclk) then
			if (stateMem=stateMemInit or ackInbuf0ToPmmu='0') then
				-- IP impl.mem.rising.syncrst --- RBEGIN
				dInbuf0ToPmmu_sig_next <= x"00";
				ackOpToMem_next <= "0000000";

				i := 0;
				j := 0;
				-- IP impl.mem.rising.syncrst --- REND

				if ackInbuf0ToPmmu='0' then
					stateMem_next <= stateMemInit;
				else
					stateMem_next <= stateMemIdle;
				end if;

			elsif stateMem=stateMemIdle then
				if reqOpToMem(i)='1' then
					stateMem_next <= stateMemStreamA;
				elsif reqOpToMemFill='1' then
					j := to_integer(unsigned(avllenInbuf0ToPmmu(11 downto 0))); -- remaining page length < 4096 -- IP impl.mem.rising.idle.initfill --- ILINE
					stateMem_next <= stateMemFillA;
				end if;

			elsif stateMem=stateMemStreamA then
				-- IP impl.mem.rising.streamA --- IBEGIN
				ackOpToMem_next(i) <= '1';
				dInbuf0ToPmmu_sig_next <= pixbuf(i);
				-- IP impl.mem.rising.streamA --- IEND

				stateMem_next <= stateMemStreamB;

			elsif stateMem=stateMemStreamB then -- strbDInbuf0ToPmmu='1'
				-- IP impl.mem.rising.streamB.ext --- IBEGIN
				ackOpToMem_next(i) <= '0'; -- op reacts to ack='1' within one clock cycle

				i := i + 1;
				if (((tixVDepth=tixVDepthD2 or tixVDepth=tixVDepthD4 or tixVDepth=tixVDepthD8) and i=1) or (tixVDepth=tixVDepthD12 and i=3) or (tixVDepth=tixVDepthD14 and i=7)) then
					i := 0;
				end if;
				-- IP impl.mem.rising.streamB.ext --- IEND

				if ((tixVDepth=tixVDepthD12 or tixVDepth=tixVDepthD14) and reqOpToMem(i)='1') then
					stateMem_next <= stateMemStreamA; -- fast/burst write
				else
					stateMem_next <= stateMemStreamC;
				end if;

			elsif stateMem=stateMemStreamC then -- strbDInbuf0ToPmmu='1'
				if reqOpToMem(i)='1' then
					stateMem_next <= stateMemStreamA;
				 elsif ackInbuf0ToPmmu='0' then
				 	stateMem_next <= stateMemInit;
				end if;

			elsif stateMem=stateMemFillA then
				dInbuf0ToPmmu_sig_next <= x"00"; -- IP impl.mem.rising.fillA --- ILINE
				stateMem_next <= stateMemFillB;

			elsif stateMem=stateMemFillB then -- strbDInbuf0ToPmmu='1'
				j := j - 1; -- IP impl.mem.rising.fillB.ext --- ILINE

				if j=0 then
					stateMem_next <= stateMemFillC;
				else
					stateMem_next <= stateMemFillA;
				end if;

			elsif stateMem=stateMemFillC then -- strbDInbuf0ToPmmu='1', ackOpToMemFill='1'
				if reqOpToMemFill='0' then
					stateMem_next <= stateMemInit;
				elsif ackInbuf0ToPmmu='0' then
				 	stateMem_next <= stateMemInit;
				end if;
			end if;
		end if;
	end process;

	process (fastclk)
	begin
		if falling_edge(fastclk) then
			stateMem <= stateMem_next;
			dInbuf0ToPmmu_sig <= dInbuf0ToPmmu_sig_next;
			ackOpToMem <= ackOpToMem_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: main operation
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	acqrun <= '1' when (stateOp=stateOpWaitNewfrm or stateOp=stateOpGetTkst or stateOp=stateOpAlloc or stateOp=stateOpInvWrite or stateOp=stateOpNewret
		or stateOp=stateOpStreamA or stateOp=stateOpStreamB) else '0';

	ackCmdToOpInvGetFrame <= '1' when stateOp=stateOpStart else '0';
	reqOpToCmdInvTkclksrcGetTkst <= '1' when stateOp=stateOpGetTkst else '0';
	reqOpToCmdInvPmmuAlloc <= '1' when stateOp=stateOpAlloc else '0';
	reqOpToCmdInvPmmuWriteInbuf0 <= '1' when stateOp=stateOpInvWrite else '0';
	reqOpToCmdNewretGetFrame <= '1' when stateOp=stateOpNewret else '0';
	reqOpToMemFill <= '1' when (stateOp=stateOpFillB or stateOp=stateOpFillC) else '0';
	ackCmdToOpRetPmmuWriteInbuf0 <= '1' when stateOp=stateOpWaitRetWriteB else '0';
	reqOpToCmdInvPmmuFree <= '1' when stateOp=stateOpFree else '0';
	ackCmdToOpRevGetFrame <= '1' when stateOp=stateOpStop else '0';

	reqInbuf0ToPmmu <= '1' when (stateOp=stateOpStreamA or stateOp=stateOpStreamB or stateOp=stateOpStreamC or stateOp=stateOpStreamD or stateOp=stateOpFillA
		or stateOp=stateOpFillB or stateOp=stateOpFillC) else '0';
	dneInbuf0ToPmmu <= '1' when (stateOp=stateOpStreamD or stateOp=stateOpFillC) else '0';
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, fastclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		variable i: natural range 0 to (w*h); -- pixel count
		variable j: natural range 0 to 4; -- pixel count in pixbuf

		variable x: std_logic_vector(0 to 6);
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- BEGIN
			stateOp_next <= stateOpInit;
			reqOpToMem_next <= (others => '0');
			-- IP impl.op.rising.asyncrst --- END

		elsif rising_edge(fastclk) then
			if stateOp=stateOpInit then
				-- IP impl.op.rising.syncrst --- BEGIN
				reqOpToMem_next <= (others => '0');
				-- IP impl.op.rising.syncrst --- END

				stateOp_next <= stateOpIdle;

			elsif stateOp=stateOpIdle then
				if reqCmdToOpInvGetFrame='1' then
					-- IP impl.op.rising.idle --- IBEGIN
					routeOp <= cmdbuf(ixCmdbufRoute);
	
					crefOp(31 downto 24) <= cmdbuf(ixCmdbufCref);
					crefOp(23 downto 16) <= cmdbuf(ixCmdbufCref+1);
					crefOp(15 downto 8) <= cmdbuf(ixCmdbufCref+2);
					crefOp(7 downto 0) <= cmdbuf(ixCmdbufCref+3);
	
					tixVDepth <= cmdbuf(ixCmdbufInvGetFrameTixVDepth);
					-- IP impl.op.rising.idle --- IEND

					stateOp_next <= stateOpStart;
				end if;

			elsif stateOp=stateOpStart then -- ackCmdToOpInvGetFrame='1'
				if reqCmdToOpInvGetFrame='0' then
					stateOp_next <= stateOpWaitNewfrm;
				end if;

			elsif stateOp=stateOpWaitNewfrm then -- acqrun='1' up to StreamB
				if reqCmdToOpRevGetFrame='1' then
					stateOp_next <= stateOpStop;
				elsif reqAcqToOpNewfrm='1' then
					ackAcqToOpNewfrm <= '1'; -- IP impl.op.rising.waitNewfrm --- ILINE
					stateOp_next <= stateOpGetTkst;
				end if;

			elsif stateOp=stateOpGetTkst then -- reqOpToCmdInvTkclksrcGetTkst='1'
				-- IP impl.op.rising.getTkst.ext --- IBEGIN
				if (reqAcqToOpNewfrm='0' and ackAcqToOpNewfrm='1') then
					ackAcqToOpNewfrm <= '0';
				end if;
				-- IP impl.op.rising.getTkst.ext --- IEND

				if ackOpToCmdInvTkclksrcGetTkst='1' then
					-- IP impl.op.rising.getTkst --- IBEGIN
					tkst(31 downto 24) <= cmdbuf(ixCmdbufRetTkclksrcGetTkstTkst);
					tkst(23 downto 16) <= cmdbuf(ixCmdbufRetTkclksrcGetTkstTkst+1);
					tkst(15 downto 8) <= cmdbuf(ixCmdbufRetTkclksrcGetTkstTkst+2);
					tkst(7 downto 0) <= cmdbuf(ixCmdbufRetTkclksrcGetTkstTkst+3);
					-- IP impl.op.rising.getTkst --- IEND

					stateOp_next <= stateOpAlloc;
				end if;

			elsif stateOp=stateOpAlloc then -- reqOpToCmdInvPmmuAlloc='1'
				if ackOpToCmdInvPmmuAlloc='1' then
					if cmdbuf(ixCmdbufRetPmmuAllocTixVSlot)=x"00" then
						-- skip to next frame
						stateOp_next <= stateOpWaitNewfrm;
					else
						tixVSlot <= cmdbuf(ixCmdbufRetPmmuAllocTixVSlot); -- IP impl.op.rising.alloc --- ILINE
						stateOp_next <= stateOpInvWrite;
					end if;
				end if;

			elsif stateOp=stateOpInvWrite then -- reqOpToCmdInvPmmuWriteInbuf0='1'
				if ackOpToCmdInvPmmuWriteInbuf0='1' then
					stateOp_next <= stateOpNewret;
				end if;

			elsif stateOp=stateOpNewret then -- reqOpToCmdNewretGetFrame='1'
				if ackOpToCmdNewretGetFrame='1' then
					stateOp_next <= stateOpStreamA;
				end if;

			elsif stateOp=stateOpStreamA then -- reqInbuf0ToPmmu='1' up to streamD
				if ackInbuf0ToPmmu='1' then
					stateOp_next <= stateOpStreamB;
				end if;

			elsif stateOp=stateOpStreamB then -- stream
				if ackInbuf0ToPmmu='0' then
					stateOp_next <= stateOpFree;
				else
					-- IP impl.op.rising.streamB.match --- IBEGIN
					x := reqOpToMem and (not ackOpToMem);
					-- IP impl.op.rising.streamB.match --- IEND

					if (reqAcqToOpNewpix='1' and ackAcqToOpNewpix='0') then
						-- IP impl.op.rising.streamB.copy --- IBEGIN
						if tixVDepth=tixVDepthD2 then
							if j=0 then
								pixbuf(0)(7 downto 6) <= pixval(13 downto 12);
							elsif j=1 then
								pixbuf(0)(5 downto 4) <= pixval(13 downto 12);
							elsif j=2 then
								pixbuf(0)(3 downto 2) <= pixval(13 downto 12);
							elsif j=3 then
								pixbuf(0)(1 downto 0) <= pixval(13 downto 12);
								x(0) := '1';
							end if;
	
							j := j + 1;
							if j=4 then
								j := 0;
							end if;
	
						elsif tixVDepth=tixVDepthD4 then
							if j=0 then
								pixbuf(0)(7 downto 4) <= pixval(13 downto 10);
							elsif j=1 then
								pixbuf(0)(3 downto 0) <= pixval(13 downto 10);
								x(0) := '1';
							end if;
	
							j := j + 1;
							if j=2 then
								j := 0;
							end if;
	
						elsif tixVDepth=tixVDepthD8 then
							pixbuf(0) <= pixval(13 downto 6);
							x(0) := '1';
	
						elsif tixVDepth=tixVDepthD12 then
							if j=0 then
								pixbuf(0) <= pixval(13 downto 6);
								pixbuf(1)(7 downto 4) <= pixval(5 downto 2);
								x(0) := '1';
							elsif j=1 then
								pixbuf(1)(3 downto 0) <= pixval(13 downto 10);
								pixbuf(2) <= pixval(9 downto 2);
								x(1 to 2) := "11";
							end if;
	
							j := j + 1;
							if j=2 then
								j := 0;
							end if;
	
						elsif tixVDepth=tixVDepthD14 then
							if j=0 then
								pixbuf(0) <= pixval(13 downto 6);
								pixbuf(1)(7 downto 2) <= pixval(5 downto 0);
								x(0) := '1';
							elsif j=1 then
								pixbuf(1)(1 downto 0) <= pixval(13 downto 12);
								pixbuf(2) <= pixval(11 downto 4);
								pixbuf(3)(7 downto 4) <= pixval(3 downto 0);
								x(1 to 2) := "11";
							elsif j=2 then
								pixbuf(3)(3 downto 0) <= pixval(13 downto 10);
								pixbuf(4) <= pixval(9 downto 2);
								pixbuf(5)(7 downto 6) <= pixval(1 downto 0);
								x(3 to 4) := "11";
							elsif j=3 then
								pixbuf(5)(5 downto 0) <= pixval(13 downto 8);
								pixbuf(6) <= pixval(7 downto 0);
								x(5 to 6) := "11";
							end if;
	
							j := j + 1;
							if j=4 then
								j := 0;
							end if;
						end if;
	
						reqOpToMem_next <= x;
	
						ackAcqToOpNewpix <= '1';
	
						i := i + 1;
						-- IP impl.op.rising.streamB.copy --- IEND

						if i=(w*h) then
							stateOp_next <= stateOpStreamC;
						else
							stateOp_next <= stateOpStreamB;
						end if;

					elsif reqAcqToOpNewpix='0' then
						ackAcqToOpNewpix <= '0'; -- IP impl.op.rising.streamB.reset --- ILINE
						stateOp_next <= stateOpStreamB;
					end if;
				end if;

			elsif stateOp=stateOpStreamC then
				-- IP impl.op.rising.streamC.ext --- IBEGIN
				x := reqOpToMem and (not ackOpToMem);
				reqOpToMem_next	<= x;
				-- IP impl.op.rising.streamC.ext --- IEND

				if x=x"00" then
					stateOp_next <= stateOpStreamD;
				end if;

			elsif stateOp=stateOpStreamD then -- dneInbuf0ToPmmu='1'
				if ackInbuf0ToPmmu='0' then
					stateOp_next <= stateOpStreamE;
				end if;

			elsif stateOp=stateOpStreamE then
				if to_integer(unsigned(avllenInbuf0ToPmmu))=0 then
					stateOp_next <= stateOpWaitRetWriteA;
				else
					stateOp_next <= stateOpFillA;
				end if;

			elsif stateOp=stateOpFillA then -- reqInbuf0ToPmmu='1' up to fillC
				if ackInbuf0ToPmmu='1' then
					stateOp_next <= stateOpFillB;
				end if;

			elsif stateOp=stateOpFillB then -- reqOpToMemFill='1'
				if ackOpToMemFill='1' then
					stateOp_next <= stateOpFillC;
				end if;

			elsif stateOp=stateOpFillC then -- reqOpToMemFill='1', dneInbuf0ToPmmu='1'
				if ackInbuf0ToPmmu='0' then
					stateOp_next <= stateOpWaitRetWriteA;
				end if;

			elsif stateOp=stateOpWaitRetWriteA then
				if reqCmdToOpRetPmmuWriteInbuf0='1' then
					stateOp_next <= stateOpStreamE;
				end if;

			elsif stateOp=stateOpWaitRetWriteB then -- ackCmdToOpRetPmmuWriteInbuf0='1'
				if reqCmdToOpRetPmmuWriteInbuf0='0' then
					stateOp_next <= stateOpWaitNewfrm;
				end if;

			elsif stateOp=stateOpFree then -- reqOpToCmdInvPmmuFree='1'
				if ackOpToCmdInvPmmuFree='1' then
					stateOp_next <= stateOpWaitNewfrm;
				end if;

			elsif stateOp=stateOpStop then -- ackCmdToOpRevGetFrame='1'
				if reqCmdToOpRevGetFrame='0' then
					stateOp_next <= stateOpInit;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.op.rising --- END

	-- IP impl.op.falling --- BEGIN
	process (fastclk)
		-- IP impl.op.falling.vars --- INSERT
	begin
		if falling_edge(fastclk) then
			stateOp <= stateOp_next;
			reqOpToMem <= reqOpToMem_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------
	
	-- IP impl.oth.cust --- IBEGIN
	clkInbuf0ToPmmu <= fastclk;

	extsnc <= trigLwir;
	-- IP impl.oth.cust --- IEND

end Lwiracq;
