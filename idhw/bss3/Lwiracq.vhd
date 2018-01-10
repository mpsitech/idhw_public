-- file Lwiracq.vhd
-- Lwiracq controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

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
end Lwiracq;

architecture Lwiracq of Lwiracq is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- frame acquisition (acq)
	type stateAcq_t is (
		stateAcqInit,
		stateAcqIdle,
		stateAcqRun
	);
	signal stateAcq, stateAcq_next: stateAcq_t := stateAcqInit;

	signal pixval: std_logic_vector(13 downto 0);

	-- IP sigs.acq.cust --- INSERT

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
		stateCmdPrepCreferrGetFrame, stateCmdPrepCreferr,
		stateCmdPrepInvPmmuAlloc,
		stateCmdPrepInvPmmuFree,
		stateCmdPrepInvPmmuWriteInbuf0,
		stateCmdPrepInvTkclksrcGetTkst
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: getFrame
	-- rev: getFrame
	-- ret/newret: getFrame
	-- external inv: pmmu.alloc, pmmu.free, pmmu.writeInbuf0, tkclksrc.getTkst
	-- external ret/newret: pmmu.alloc, pmmu.writeInbuf0, tkclksrc.getTkst

	constant sizeCmdbuf: natural := 15;

	constant tixVDepthD2: std_logic_vector(7 downto 0) := x"00";
	constant tixVDepthD4: std_logic_vector(7 downto 0) := x"01";
	constant tixVDepthD8: std_logic_vector(7 downto 0) := x"02";
	constant tixVDepthD12: std_logic_vector(7 downto 0) := x"03";
	constant tixVDepthD14: std_logic_vector(7 downto 0) := x"04";

	constant tixVCommandGetFrame: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvGetFrame: natural := 11;
	constant ixCmdbufInvGetFrameTixVDepth: natural := 10;
	constant lenCmdbufNewretGetFrame: natural := 15;
	constant ixCmdbufNewretGetFrameTkst: natural := 9;
	constant ixCmdbufNewretGetFrameTixVBss3PmmuSlot: natural := 13;
	constant ixCmdbufNewretGetFrameAvlpglen: natural := 14;

	constant tixVBss3PmmuCommandAlloc: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvPmmuAlloc: natural := 12;
	constant ixCmdbufInvPmmuAllocDynNotStat: natural := 10;
	constant ixCmdbufInvPmmuAllocReqPglen: natural := 11;
	constant lenCmdbufRetPmmuAlloc: natural := 10;
	constant ixCmdbufRetPmmuAllocTixVSlot: natural := 9;

	constant tixVBss3PmmuCommandFree: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvPmmuFree: natural := 11;
	constant ixCmdbufInvPmmuFreeTixVSlot: natural := 10;

	constant tixVBss3PmmuCommandWriteInbuf0: std_logic_vector(7 downto 0) := x"03";
	constant lenCmdbufInvPmmuWriteInbuf0: natural := 11;
	constant ixCmdbufInvPmmuWriteInbuf0TixVSlot: natural := 10;
	constant lenCmdbufRetPmmuWriteInbuf0: natural := 10;

	constant tixVBss3TkclksrcCommandGetTkst: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvTkclksrcGetTkst: natural := 10;
	constant lenCmdbufRetTkclksrcGetTkst: natural := 13;
	constant ixCmdbufRetTkclksrcGetTkstTkst: natural := 9;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;
	signal reqCmdbusToPmmu_sig, reqCmdbusToPmmu_sig_next: std_logic;
	signal reqCmdbusToTkclksrc_sig, reqCmdbusToTkclksrc_sig_next: std_logic;
	signal rdyCmdbusFromPmmu_sig, rdyCmdbusFromPmmu_sig_next: std_logic;
	signal rdyCmdbusFromTkclksrc_sig, rdyCmdbusFromTkclksrc_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- memory streaming operation (mem)
	type stateMem_t is (
		stateMemInit,
		stateMemIdle,
		stateMemStreamA, stateMemStreamB, stateMemStreamC,
		stateMemFillA, stateMemFillB, stateMemFillC
	);
	signal stateMem, stateMem_next: stateMem_t := stateMemInit;

	signal dInbuf0ToPmmu_sig, dInbuf0ToPmmu_sig_next: std_logic_vector(7 downto 0);
	signal strbDInbuf0ToPmmu_sig: std_logic;

	-- IP sigs.mem.cust --- INSERT

	---- main operation (op)
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
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal acqrun: std_logic;
	signal reqInbuf0ToPmmu_sig: std_logic;
	signal dneInbuf0ToPmmu_sig: std_logic;
	signal tixVDepth: std_logic_vector(7 downto 0);

	signal tkst: std_logic_vector(31 downto 0);
	signal tixVSlot: std_logic_vector(7 downto 0);

	type pixbuf_t is array (0 to 6) of std_logic_vector(7 downto 0);
	signal pixbuf: pixbuf_t;

	signal routeGetFrame: std_logic_vector(7 downto 0);
	signal crefGetFrame: std_logic_vector(31 downto 0);

	-- IP sigs.op.cust --- INSERT

	---- handshake
	-- acq to op
	signal reqAcqToOpNewfrm: std_logic;
	signal ackAcqToOpNewfrm: std_logic;

	-- acq to op
	signal reqAcqToOpNewpix: std_logic;
	signal ackAcqToOpNewpix: std_logic;

	-- cmd to op
	signal reqCmdToOpInvGetFrame, reqCmdToOpInvGetFrame_next: std_logic;
	signal ackCmdToOpInvGetFrame: std_logic;

	-- cmd to op
	signal reqCmdToOpRevGetFrame, reqCmdToOpRevGetFrame_next: std_logic;
	signal ackCmdToOpRevGetFrame: std_logic;

	-- cmd to op
	signal reqCmdToOpRetPmmuWriteInbuf0, reqCmdToOpRetPmmuWriteInbuf0_next: std_logic;
	signal ackCmdToOpRetPmmuWriteInbuf0: std_logic;

	-- op to cmd
	signal reqOpToCmdNewretGetFrame: std_logic;
	signal ackOpToCmdNewretGetFrame, ackOpToCmdNewretGetFrame_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvPmmuAlloc: std_logic;
	signal ackOpToCmdInvPmmuAlloc, ackOpToCmdInvPmmuAlloc_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvPmmuWriteInbuf0: std_logic;
	signal ackOpToCmdInvPmmuWriteInbuf0, ackOpToCmdInvPmmuWriteInbuf0_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvTkclksrcGetTkst: std_logic;
	signal ackOpToCmdInvTkclksrcGetTkst, ackOpToCmdInvTkclksrcGetTkst_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvPmmuFree: std_logic;
	signal ackOpToCmdInvPmmuFree, ackOpToCmdInvPmmuFree_next: std_logic;

	-- op to mem
	signal reqOpToMem, reqOpToMem_next: std_logic_vector(0 to 6);
	signal ackOpToMem, ackOpToMem_next: std_logic_vector(0 to 6);

	-- op to mem
	signal reqOpToMemFill: std_logic;
	signal ackOpToMemFill: std_logic;

	---- other
	constant w: natural := 640;
	constant h: natural := 480;
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- implementation: frame acquisition (acq)
	------------------------------------------------------------------------

	-- IP impl.acq.wiring --- BEGIN
	-- IP impl.acq.wiring --- END

	-- IP impl.acq.rising --- BEGIN
	process (reset, clk, stateAcq)
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

		elsif rising_edge(clk) then
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
	-- IP impl.acq.rising --- END

	-- IP impl.acq.falling --- BEGIN
	process (clk)
		-- IP impl.acq.falling.vars --- BEGIN
		-- IP impl.acq.falling.vars --- END
	begin
		if falling_edge(clk) then
			stateAcq <= stateAcq_next;
		end if;
	end process;
	-- IP impl.acq.falling --- END

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	reqCmdbusToPmmu <= reqCmdbusToPmmu_sig;
	reqCmdbusToTkclksrc <= reqCmdbusToTkclksrc_sig;
	rdyCmdbusFromPmmu <= rdyCmdbusFromPmmu_sig;
	rdyCmdbusFromTkclksrc <= rdyCmdbusFromTkclksrc_sig;
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
			reqCmdToOpInvGetFrame_next <= '0';
			reqCmdToOpRevGetFrame_next <= '0';
			reqCmdToOpRetPmmuWriteInbuf0_next <= '0';
			ackOpToCmdNewretGetFrame_next <= '0';
			ackOpToCmdInvPmmuAlloc_next <= '0';
			ackOpToCmdInvPmmuWriteInbuf0_next <= '0';
			ackOpToCmdInvTkclksrcGetTkst_next <= '0';
			ackOpToCmdInvPmmuFree_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			reqCmdbusToCmdret_sig_next <= '0';
			reqCmdbusToPmmu_sig_next <= '0';
			reqCmdbusToTkclksrc_sig_next <= '0';
			rdyCmdbusFromPmmu_sig_next <= '1';
			rdyCmdbusFromTkclksrc_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				reqCmdToOpInvGetFrame_next <= '0';
				reqCmdToOpRevGetFrame_next <= '0';
				reqCmdToOpRetPmmuWriteInbuf0_next <= '0';
				ackOpToCmdNewretGetFrame_next <= '0';
				ackOpToCmdInvPmmuAlloc_next <= '0';
				ackOpToCmdInvPmmuWriteInbuf0_next <= '0';
				ackOpToCmdInvTkclksrcGetTkst_next <= '0';
				ackOpToCmdInvPmmuFree_next <= '0';
				rdyCmdbusFromCmdinv_sig_next <= '1';
				reqCmdbusToCmdret_sig_next <= '0';
				reqCmdbusToPmmu_sig_next <= '0';
				reqCmdbusToTkclksrc_sig_next <= '0';
				rdyCmdbusFromPmmu_sig_next <= '1';
				rdyCmdbusFromTkclksrc_sig_next <= '1';

				lenCmdbuf := 0;
				i := 0;
				j := 0;
				x := x"00";
				bytecnt := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if ((rdCmdbusFromCmdinv='1' or rdCmdbusFromPmmu='1' or rdCmdbusFromTkclksrc='1') and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
					rdyCmdbusFromPmmu_sig_next <= '0';
					rdyCmdbusFromTkclksrc_sig_next <= '0';

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
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetFrame and lenCmdbuf=lenCmdbufInvGetFrame) then
					if crefGetFrame=x"00000000" then
						reqCmdToOpInvGetFrame_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					else
						stateCmd_next <= stateCmdPrepCreferrGetFrame;
					end if;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRev and lenCmdbuf=lenCmdbufRev) then
					if (cmdbuf(ixCmdbufCref)=crefGetFrame(31 downto 24) and cmdbuf(ixCmdbufCref+1)=crefGetFrame(23 downto 16) and cmdbuf(ixCmdbufCref+2)=crefGetFrame(15 downto 8) and cmdbuf(ixCmdbufCref+3)=crefGetFrame(7 downto 0)) then
						reqCmdToOpRevGetFrame_next <= '1';

						stateCmd_next <= stateCmdRecvG;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRet and cmdbuf(ixCmdbufCref)=tixVBss3PmmuCommandAlloc and lenCmdbuf=lenCmdbufRetPmmuAlloc) then
					ackOpToCmdInvPmmuAlloc_next <= '1';

					stateCmd_next <= stateCmdRecvG;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRet and cmdbuf(ixCmdbufCref)=tixVBss3TkclksrcCommandGetTkst and lenCmdbuf=lenCmdbufRetTkclksrcGetTkst) then
					ackOpToCmdInvTkclksrcGetTkst_next <= '1';

					stateCmd_next <= stateCmdRecvG;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdRecvG then
				if ((reqCmdToOpInvGetFrame='1' and ackCmdToOpInvGetFrame='1') or (reqCmdToOpRevGetFrame='1' and ackCmdToOpRevGetFrame='1') or (reqOpToCmdInvPmmuAlloc='0' and ackOpToCmdInvPmmuAlloc='1') or (reqOpToCmdInvTkclksrcGetTkst='0' and ackOpToCmdInvTkclksrcGetTkst='1')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullA then
				if cmdbuf(ixCmdbufRoute)=tixVIdhwBss3ControllerCmdret then
					reqCmdbusToCmdret_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwBss3ControllerPmmu then
					reqCmdbusToPmmu_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwBss3ControllerTkclksrc then
					reqCmdbusToTkclksrc_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				else
					stateCmd_next <= stateCmdInit;
				end if;

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
					if (reqOpToCmdNewretGetFrame='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionNewret) then
						ackOpToCmdNewretGetFrame_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqOpToCmdInvPmmuAlloc='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVBss3PmmuCommandAlloc) then
						rdyCmdbusFromPmmu_sig_next <= '1';
						lenCmdbuf := 0;

						if (rdCmdbusFromPmmu='1' and clkCmdbus='1') then
							stateCmd_next <= stateCmdRecvA;
						end if;

					elsif (reqOpToCmdInvPmmuFree='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVBss3PmmuCommandFree) then
						ackOpToCmdInvPmmuFree_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqOpToCmdInvPmmuWriteInbuf0='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVBss3PmmuCommandWriteInbuf0) then
						ackOpToCmdInvPmmuWriteInbuf0_next <= '1';

						stateCmd_next <= stateCmdSendD;

					elsif (reqOpToCmdInvTkclksrcGetTkst='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVBss3TkclksrcCommandGetTkst) then
						rdyCmdbusFromTkclksrc_sig_next <= '1';
						lenCmdbuf := 0;

						if (rdCmdbusFromTkclksrc='1' and clkCmdbus='1') then
							stateCmd_next <= stateCmdRecvA;
						end if;

					else
						stateCmd_next <= stateCmdInit;
					end if;
				end if;

			elsif stateCmd=stateCmdSendD then
				if ((reqOpToCmdNewretGetFrame='0' and ackOpToCmdNewretGetFrame='1') or (reqOpToCmdInvPmmuWriteInbuf0='0' and ackOpToCmdInvPmmuWriteInbuf0='1')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdPrepNewretGetFrame then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionNewret;

				cmdbuf(ixCmdbufCref) <= crefGetFrame(31 downto 24);
				cmdbuf(ixCmdbufCref+1) <= crefGetFrame(23 downto 16);
				cmdbuf(ixCmdbufCref+2) <= crefGetFrame(15 downto 8);
				cmdbuf(ixCmdbufCref+3) <= crefGetFrame(7 downto 0);

				-- IP impl.cmd.rising.prepNewretGetFrame --- IBEGIN
				cmdbuf(ixCmdbufNewretGetFrameTkst) <= tkst(31 downto 24);
				cmdbuf(ixCmdbufNewretGetFrameTkst+1) <= tkst(23 downto 16);
				cmdbuf(ixCmdbufNewretGetFrameTkst+2) <= tkst(15 downto 8);
				cmdbuf(ixCmdbufNewretGetFrameTkst+3) <= tkst(7 downto 0);

				cmdbuf(ixCmdbufNewretGetFrameTixVBss3PmmuSlot) <= tixVSlot;

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
				cmdbuf(ixCmdbufCreferrCref) <= crefGetFrame(31 downto 24);
				cmdbuf(ixCmdbufCreferrCref+1) <= crefGetFrame(23 downto 16);
				cmdbuf(ixCmdbufCreferrCref+2) <= crefGetFrame(15 downto 8);
				cmdbuf(ixCmdbufCreferrCref+3) <= crefGetFrame(7 downto 0);

				stateCmd_next <= stateCmdPrepCreferr;

			elsif stateCmd=stateCmdPrepCreferr then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionCreferr;

				lenCmdbuf := lenCmdbufCreferr;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvPmmuAlloc then
				cmdbuf(ixCmdbufRoute) <= tixVIdhwBss3ControllerPmmu;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwBss3ControllerPmmu;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVBss3PmmuCommandAlloc;
				cmdbuf(ixCmdbufInvCommand) <= tixVBss3PmmuCommandAlloc;

				-- IP impl.cmd.rising.prepInvPmmuAlloc --- IBEGIN
				cmdbuf(ixCmdbufInvPmmuAllocDynNotStat) <= tru8;

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
				cmdbuf(ixCmdbufRoute) <= tixVIdhwBss3ControllerPmmu;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwBss3ControllerPmmu;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVBss3PmmuCommandFree;
				cmdbuf(ixCmdbufInvCommand) <= tixVBss3PmmuCommandFree;

				cmdbuf(ixCmdbufInvPmmuFreeTixVSlot) <= tixVSlot; -- IP impl.cmd.rising.prepInvPmmuFree --- ILINE

				lenCmdbuf := lenCmdbufInvPmmuFree;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvPmmuWriteInbuf0 then
				cmdbuf(ixCmdbufRoute) <= tixVIdhwBss3ControllerPmmu;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwBss3ControllerPmmu;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVBss3PmmuCommandWriteInbuf0;
				cmdbuf(ixCmdbufInvCommand) <= tixVBss3PmmuCommandWriteInbuf0;

				cmdbuf(ixCmdbufInvPmmuWriteInbuf0TixVSlot) <= tixVSlot; -- IP impl.cmd.rising.prepInvPmmuWriteInbuf0 --- ILINE

				lenCmdbuf := lenCmdbufInvPmmuWriteInbuf0;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvTkclksrcGetTkst then
				cmdbuf(ixCmdbufRoute) <= tixVIdhwBss3ControllerTkclksrc;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwBss3ControllerTkclksrc;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVBss3TkclksrcCommandGetTkst;
				cmdbuf(ixCmdbufInvCommand) <= tixVBss3TkclksrcCommandGetTkst;

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
			ackOpToCmdInvPmmuWriteInbuf0 <= ackOpToCmdInvPmmuWriteInbuf0_next;
			ackOpToCmdInvTkclksrcGetTkst <= ackOpToCmdInvTkclksrcGetTkst_next;
			ackOpToCmdInvPmmuFree <= ackOpToCmdInvPmmuFree_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			dCmdbus_sig <= dCmdbus_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
			reqCmdbusToPmmu_sig <= reqCmdbusToPmmu_sig_next;
			reqCmdbusToTkclksrc_sig <= reqCmdbusToTkclksrc_sig_next;
			rdyCmdbusFromPmmu_sig <= rdyCmdbusFromPmmu_sig_next;
			rdyCmdbusFromTkclksrc_sig <= rdyCmdbusFromTkclksrc_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: memory streaming operation (mem)
	------------------------------------------------------------------------

	-- IP impl.mem.wiring --- BEGIN
	dInbuf0ToPmmu <= dInbuf0ToPmmu_sig;
	strbDInbuf0ToPmmu_sig <= '0' when (stateMem=stateMemStreamB or stateMem=stateMemStreamC or stateMem=stateMemFillB or stateMem=stateMemFillC) else '1';
	strbDInbuf0ToPmmu <= strbDInbuf0ToPmmu_sig;

	ackOpToMemFill <= '0' when stateMem=stateMemFillC else '1';
	-- IP impl.mem.wiring --- END

	-- IP impl.mem.rising --- BEGIN
	process (reset, fastclk, stateMem)
		-- IP impl.mem.rising.vars --- RBEGIN
		variable i: natural range 0 to 6; -- next index to pixbuf
		variable j: natural range 0 to 4096; -- down counter for page fill
		-- IP impl.mem.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.mem.rising.asyncrst --- BEGIN
			stateMem_next <= stateMemInit;
			dInbuf0ToPmmu_sig_next <= x"00";
			ackOpToMem_next <= "0000000";
			-- IP impl.mem.rising.asyncrst --- END

		elsif rising_edge(fastclk) then
			if (stateMem=stateMemInit or ackInbuf0ToPmmu='0') then
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

			elsif stateMem=stateMemStreamB then
				-- IP impl.mem.rising.streamB.ext --- IBEGIN
				ackOpToMem_next(i) <= '0'; -- op reacts to ack='1' within one clock cycle

				i := i + 1;
				if (((tixVDepth=tixVDepthD2 or tixVDepth=tixVDepthD4 or tixVDepth=tixVDepthD8) and i=1) or (tixVDepth=tixVDepthD12 and i=3) or (tixVDepth=tixVDepthD14 and i=7)) then
					i := 0;
				end if;
				-- IP impl.mem.rising.streamB.ext --- IEND

				if ((tixVDepth=tixVDepthD12 or tixVDepth=tixVDepthD14) and reqOpToMem(i)='1') then
					stateMem_next <= stateMemStreamA;

				else
					stateMem_next <= stateMemStreamC;
				end if;

			elsif stateMem=stateMemStreamC then
				if reqOpToMem(i)='1' then
					stateMem_next <= stateMemStreamA;

				elsif ackInbuf0ToPmmu='0' then
					stateMem_next <= stateMemInit;
				end if;

			elsif stateMem=stateMemFillA then
				dInbuf0ToPmmu_sig_next <= x"00"; -- IP impl.mem.rising.fillA --- ILINE

				stateMem_next <= stateMemFillB;

			elsif stateMem=stateMemFillB then
				j := j - 1; -- IP impl.mem.rising.fillB.ext --- ILINE

				if j=0 then
					stateMem_next <= stateMemFillC;

				else
					stateMem_next <= stateMemFillA;
				end if;

			elsif stateMem=stateMemFillC then
				if reqOpToMemFill='0' then
					stateMem_next <= stateMemInit;

				elsif ackInbuf0ToPmmu='0' then
					stateMem_next <= stateMemInit;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.mem.rising --- END

	-- IP impl.mem.falling --- BEGIN
	process (fastclk)
		-- IP impl.mem.falling.vars --- BEGIN
		-- IP impl.mem.falling.vars --- END
	begin
		if falling_edge(fastclk) then
			stateMem <= stateMem_next;
			dInbuf0ToPmmu_sig <= dInbuf0ToPmmu_sig_next;
			ackOpToMem <= ackOpToMem_next;
		end if;
	end process;
	-- IP impl.mem.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	acqrun <= '0' when (stateOp=stateOpWaitNewfrm or stateOp=stateOpGetTkst or stateOp=stateOpAlloc or stateOp=stateOpInvWrite
				 or stateOp=stateOpNewret or stateOp=stateOpStreamA or stateOp=stateOpStreamB) else '1';
	reqInbuf0ToPmmu_sig <= '0' when (stateOp=stateOpStreamA or stateOp=stateOpStreamB or stateOp=stateOpStreamC or stateOp=stateOpStreamD
				 or stateOp=stateOpFillA or stateOp=stateOpFillB or stateOp=stateOpFillC) else '1';
	reqInbuf0ToPmmu <= reqInbuf0ToPmmu_sig;
	dneInbuf0ToPmmu_sig <= '0' when (stateOp=stateOpStreamD or stateOp=stateOpFillC) else '0';
	dneInbuf0ToPmmu <= dneInbuf0ToPmmu_sig;

	ackCmdToOpInvGetFrame <= '0' when stateOp=stateOpStart else '1';

	ackCmdToOpRevGetFrame <= '0' when stateOp=stateOpStop else '1';

	ackCmdToOpRetPmmuWriteInbuf0 <= '0' when stateOp=stateOpWaitRetWriteB else '1';

	reqOpToCmdNewretGetFrame <= '0' when stateOp=stateOpNewret else '1';

	reqOpToCmdInvPmmuAlloc <= '0' when stateOp=stateOpAlloc else '1';

	reqOpToCmdInvPmmuWriteInbuf0 <= '0' when stateOp=stateOpInvWrite else '1';

	reqOpToCmdInvTkclksrcGetTkst <= '0' when stateOp=stateOpGetTkst else '1';

	reqOpToCmdInvPmmuFree <= '0' when stateOp=stateOpFree else '1';

	reqOpToMemFill <= '0' when (stateOp=stateOpFillB or stateOp=stateOpFillC) else '1';
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
			reqOpToMem_next <= "0000000";
			-- IP impl.op.rising.asyncrst --- END

		elsif rising_edge(fastclk) then
			if stateOp=stateOpInit then
				stateOp_next <= stateOpIdle;

			elsif stateOp=stateOpIdle then
				if reqCmdToOpInvGetFrame='1' then
					-- IP impl.op.rising.idle --- IBEGIN
					routeGetFrame <= cmdbuf(ixCmdbufRoute);
	
					crefGetFrame(31 downto 24) <= cmdbuf(ixCmdbufCref);
					crefGetFrame(23 downto 16) <= cmdbuf(ixCmdbufCref+1);
					crefGetFrame(15 downto 8) <= cmdbuf(ixCmdbufCref+2);
					crefGetFrame(7 downto 0) <= cmdbuf(ixCmdbufCref+3);
	
					tixVDepth <= cmdbuf(ixCmdbufInvGetFrameTixVDepth);
					-- IP impl.op.rising.idle --- IEND

					stateOp_next <= stateOpStart;
				end if;

			elsif stateOp=stateOpStart then
				if reqCmdToOpInvGetFrame='1' then
					stateOp_next <= stateOpWaitNewfrm;
				end if;

			elsif stateOp=stateOpWaitNewfrm then
				if reqCmdToOpRevGetFrame='1' then
					stateOp_next <= stateOpStop;

				elsif reqAcqToOpNewfrm='1' then
					ackAcqToOpNewfrm <= '1'; -- IP impl.op.rising.waitNewfrm --- ILINE

					stateOp_next <= stateOpGetTkst;
				end if;

			elsif stateOp=stateOpGetTkst then
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

			elsif stateOp=stateOpAlloc then
				if ackOpToCmdInvPmmuAlloc='1' then
					if cmdbuf(ixCmdbufRetPmmuAllocTixVSlot)=x"00" then
						stateOp_next <= stateOpWaitNewfrm;

					else
						tixVSlot <= cmdbuf(ixCmdbufRetPmmuAllocTixVSlot); -- IP impl.op.rising.alloc --- ILINE

						stateOp_next <= stateOpInvWrite;
					end if;
				end if;

			elsif stateOp=stateOpInvWrite then
				if ackOpToCmdInvPmmuWriteInbuf0='1' then
					stateOp_next <= stateOpNewret;
				end if;

			elsif stateOp=stateOpNewret then
				if ackOpToCmdNewretGetFrame='1' then
					stateOp_next <= stateOpStreamA;
				end if;

			elsif stateOp=stateOpStreamA then
				if ackInbuf0ToPmmu='1' then
					stateOp_next <= stateOpStreamB;
				end if;

			elsif stateOp=stateOpStreamB then
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

						if i=w*h then
							stateOp_next <= stateOpStreamC;

						else
							stateOp_next <= stateOpStreamB;
						end if;

					else
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

			elsif stateOp=stateOpStreamD then
				if ackInbuf0ToPmmu='1' then
					stateOp_next <= stateOpStreamE;
				end if;

			elsif stateOp=stateOpStreamE then
				if to_integer(unsigned(avllenInbuf0ToPmmu))=0 then
					stateOp_next <= stateOpWaitRetWriteA;

				else
					stateOp_next <= stateOpFillA;
				end if;

			elsif stateOp=stateOpFillA then
				if ackInbuf0ToPmmu='1' then
					stateOp_next <= stateOpFillB;
				end if;

			elsif stateOp=stateOpFillB then
				if ackOpToMemFill='1' then
					stateOp_next <= stateOpFillC;
				end if;

			elsif stateOp=stateOpFillC then
				if ackInbuf0ToPmmu='0' then
					stateOp_next <= stateOpWaitRetWriteA;
				end if;

			elsif stateOp=stateOpWaitRetWriteA then
				if reqCmdToOpRetPmmuWriteInbuf0='1' then
					stateOp_next <= stateOpWaitRetWriteB;
				end if;

			elsif stateOp=stateOpWaitRetWriteB then
				if reqCmdToOpRetPmmuWriteInbuf0='0' then
					stateOp_next <= stateOpWaitNewfrm;
				end if;

			elsif stateOp=stateOpFree then
				if ackOpToCmdInvPmmuFree='1' then
					stateOp_next <= stateOpWaitNewfrm;
				end if;

			elsif stateOp=stateOpStop then
				if reqCmdToOpRevGetFrame='0' then
					stateOp_next <= stateOpInit;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.op.rising --- END

	-- IP impl.op.falling --- BEGIN
	process (fastclk)
		-- IP impl.op.falling.vars --- BEGIN
		-- IP impl.op.falling.vars --- END
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


