-- file Phiif.vhd
-- Phiif spifwd_v1_0 forwarding controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Idhw.all;
use work.Zedb.all;

entity Phiif is
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

		nss: out std_logic;
		sclk: out std_logic;
		mosi: out std_logic;
		miso: in std_logic
	);
end Phiif;

architecture Phiif of Phiif is

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
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE,
		stateCmdFullA, stateCmdFullB,
		stateCmdSendA, stateCmdSendB, stateCmdSendC, stateCmdSendD,
		stateCmdPrepFwderrA, stateCmdPrepFwderrB,
		stateCmdToCmdbufA, stateCmdToCmdbufB,
		stateCmdFromCmdbufA, stateCmdFromCmdbufB
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: reset

	constant sizeCmdbuf: natural := 22;

	constant tixVCommandReset: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvReset: natural := 10;

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
	signal tknFromCmdret: std_logic_vector(7 downto 0) := x"01";
	signal tknToCmdinv: std_logic_vector(7 downto 0) := x"02";

	signal tixDbeVXfer: std_logic_vector(7 downto 0) := tixDbeVXferVoid;
	signal tkn, tkn_next: std_logic_vector(7 downto 0);

	signal reqbx: std_logic_vector(7 downto 0);

	constant ixReqbxFromCmdret: natural := 0;
	constant ixReqbxToCmdinv: natural := 1;

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

	---- myCrc
	signal crc: std_logic_vector(15 downto 0);

	---- mySpi
	signal strbSpisend: std_logic;

	signal spirecv: std_logic_vector(7 downto 0);
	signal strbSpirecv: std_logic;

	---- myWakeup
	signal wakeup: std_logic;

	---- handshake
	-- op to myCrc
	signal reqCrc: std_logic;
	signal ackCrc: std_logic;
	signal dneCrc: std_logic;

	-- cmd to op
	signal reqCmdToOpInvReset, reqCmdToOpInvReset_next: std_logic;
	signal ackCmdToOpInvReset: std_logic;

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
			reqCmdToOpInvReset_next <= '0';
			ackOpToCmdFwderr_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			reqCmdbusToCmdret_sig_next <= '0';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				lenCmdbuf_next <= 0;
				dFromCmdbuf_next <= x"00";
				reqCmdToOpInvReset_next <= '0';
				ackOpToCmdFwderr_next <= '0';
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

				elsif reqOpToCmdLock='1' then
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
				if cmdbuf(ixCmdbufRoute)=x"00" then
					if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandReset and lenCmdbuf=lenCmdbufInvReset) then
						reqCmdToOpInvReset_next <= '1';

						stateCmd_next <= stateCmdRecvE;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				else
					stateCmd_next <= stateCmdLock;
				end if;

			elsif stateCmd=stateCmdRecvE then
				if (reqCmdToOpInvReset='1' and ackCmdToOpInvReset='1') then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullA then
				if cmdbuf(ixCmdbufRoute)=tixVIdhwZedbControllerCmdret then
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

					else
						stateCmd_next <= stateCmdInit;
					end if;
				end if;

			elsif stateCmd=stateCmdSendD then
				stateCmd_next <= stateCmdInit;

			elsif stateCmd=stateCmdPrepFwderrA then
				if j=4 then
					cmdbuf(ixCmdbufAction) <= tixDbeVActionFwderr;
					cmdbuf(ixCmdbufFwderrRoute) <= tixVIdhwZedbControllerPhiif;

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
			reqCmdToOpInvReset <= reqCmdToOpInvReset_next;
			ackOpToCmdFwderr <= ackOpToCmdFwderr_next;
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
	reqbx(1) <= '0';
	reqbx(2) <= '0';
	reqbx(3) <= '0';
	reqbx(4) <= '0';
	reqbx(5) <= '0';
	reqbx(6) <= '0';
	reqbx(7) <= '0';

	reqlen <= std_logic_vector(to_unsigned(sizeCmdbuf, 32)) when (tkn=x"01" or tkn=(not x"01"))
				else std_logic_vector(to_unsigned(lenCmdbuf, 32)) when (tkn=x"02" or tkn=(not x"02"))
				else (others => '0');

	ackRxbuf <= ackOpToCmdToCmdbuf when (tkn=x"01" or tkn=(not x"01"))
				else '0';

	dneRxbuf <= '1' when stateOp=stateOpCnfrd else '0';

	strbDRxbuf <= '0' when (stateOp=stateOpRxD or stateOp=stateOpRxE) else '1';

	ackTxbuf <= ackOpToCmdFromCmdbuf when (tkn=x"02" or tkn=(not x"02"))
				else '0';

	dneTxbuf <= '1' when stateOp=stateOpCnfwr else '0';

	dTxbuf <= dFromCmdbuf when (tkn=x"02" or tkn=(not x"02"))
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
				tknFromCmdret <= x"01";
				tknToCmdinv <= x"02";
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

				if reqCmdToOpInvReset='1' then
					auxbuf(ixAuxbufTkn) <= tknReset;
					tkn_next <= tknReset;

					stateOp_next <= stateOpTxA;

				elsif (arbbx/=x"00" or avlbx(ixReqbxFromCmdret)='1' or reqbx(ixReqbxToCmdinv)='1' or wakeup='1') then
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
					if arbbx=x"01" then
						-- no error handling for now
					elsif arbbx=x"02" then
						stateOp_next <= stateOpFwderr;
					end if;

				else
					auxbuf(ixAuxbufXfer) <= tixDbeVXferTkn;
					tixDbeVXfer <= tixDbeVXferTkn;

					if arbbx=x"01" then
						auxbuf(ixAuxbufTkn) <= tknFromCmdret;
						tkn_next <= tknFromCmdret;

						stateOp_next <= stateOpTxA;
					elsif arbbx=x"02" then
						auxbuf(ixAuxbufTkn) <= tknToCmdinv;
						tkn_next <= tknToCmdinv;

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

						elsif (auxbuf(ixAuxbufTkn)=tknFromCmdret or auxbuf(ixAuxbufTkn)=tknToCmdinv) then
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

						if auxbuf(ixAuxbufTkn)=tknFromCmdret then
							tixDbeVXfer <= tixDbeVXferRd;

							x := to_integer(unsigned(arblen)) + 4;
							spilen <= std_logic_vector(to_unsigned(x, 11));

							i := 0;
							stateOp_next <= stateOpRxA;

						elsif auxbuf(ixAuxbufTkn)=tknToCmdinv then
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
				if reqCmdToOpInvReset='0' then
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpCnfRd then
				if ackRxbuf='0' then
					if tkn=tknFromCmdret then
						tknFromCmdret <= not tknFromCmdret;
					end if;

					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpCnfWr then
				if ackTxbuf='0' then
					if tkn=tknToCmdinv then
						tknToCmdinv <= not tknToCmdinv;
					end if;

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

	
end Phiif;

