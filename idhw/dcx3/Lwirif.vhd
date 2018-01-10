-- file Lwirif.vhd
-- Lwirif forwarding controller implementation
-- author Alexander Wirthmueller
-- date created: 7 Dec 2016
-- date modified: 16 Aug 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Lwirif is
	generic (
		fMclk: natural range 1 to 1000000;

		Nretry: natural range 1 to 5 := 3;
		dtRetry: natural range 0 to 10000 := 1000 -- in tkclk clocks
	);
	port (
		reset: in std_logic;

		clkCmdbus: in std_logic;

		mclk: in std_logic;

		dCmdbus: in std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		--
		reqCmdbusToCmdret: out std_logic;
		wrCmdbusToCmdret: in std_logic;
		--

		rxd: in std_logic;
		txd: out std_logic
	);
end Lwirif;

architecture Lwirif of Lwirif is

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

			fastclk: in std_logic; -- here, for capt and fin

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			captNotFin: in std_logic;

			d: in std_logic_vector(7 downto 0);
			strbD: in std_logic;

			crc: out std_logic_vector(15 downto 0)
		);
	end component;

	component Timeout_v1_0 is
		generic (
			twait: natural range 0 to 1000 -- in ms
		);
		port (
			reset: in std_logic;
	
			mclk: in std_logic;
	
			tkclk: in std_logic;
	
			restart: in std_logic;
			timeout: out std_logic
		);
	end component;

	component Uartrx_v1_0 is
		generic(
			fMclk: natural range 1 to 1000000;

			fSclk: natural range 100 to 50000000
		);
		port(
			reset: in std_logic;
		
			mclk: in std_logic;
		
			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;
		
			len: in std_logic_vector(10 downto 0);
		
			d: out std_logic_vector(7 downto 0);
			strbD: out std_logic
		);
	end component;

	component Uarttx_v1_0 is
		generic(
			fMclk: natural range 1 to 1000000;

			fSclk: natural range 100 to 50000000;
			idlecntSclk: natural range 1 to 8 := 1
		);
		port(
			reset: in std_logic;
		
			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			len: in std_logic_vector(10 downto 0);
		
			d: in std_logic_vector(7 downto 0);
			strbD: out std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- command execution
	type stateCmd_t is (
		stateCmdInit,
		stateCmdEmpty,
		stateCmdLock,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE,
		stateCmdRecvF, stateCmdRecvG,
		stateCmdFullA, stateCmdFullB,
		stateCmdSendA, stateCmdSendB, stateCmdSendC, stateCmdSendD,
		stateCmdPrepRet,
		stateCmdPrepFwderrA, stateCmdPrepFwderrB,
		stateCmdToCmdbufA, stateCmdToCmdbufB,
		stateCmdFromCmdbufA, stateCmdFromCmdbufB
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	constant sizeCmdbuf: natural := 203; -- 4+1+4+1+193 where 193=max(47,193)

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal lenCmdbuf, lenCmdbuf_next: natural range 0 to sizeCmdbuf;

	-- inv: reset, all to tau2
	-- ret: all from tau2
	-- fwderr

	constant tixVCommandReset: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvReset: natural := 10;

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;

	-- IP sigs.cmd.cust --- IBEGIN
	signal dFromCmdbuf, dFromCmdbuf_next: std_logic_vector(7 downto 0);

	constant tixVCommandSetDefaults: std_logic_vector(7 downto 0) := x"01";
	constant tixVCommandCameraReset: std_logic_vector(7 downto 0) := x"02"; -- via reset command as well
	constant tixVCommandRestoreFactoryDefault: std_logic_vector(7 downto 0) := x"03";
	constant tixVCommandSerialNumber: std_logic_vector(7 downto 0) := x"04";
	constant tixVCommandGetRevision: std_logic_vector(7 downto 0) := x"05";
	constant tixVCommandBaudRate: std_logic_vector(7 downto 0) := x"07";
	constant tixVCommandGainMode: std_logic_vector(7 downto 0) := x"0A";
	constant tixVCommandFfcModeSelect: std_logic_vector(7 downto 0) := x"0B";
	constant tixVCommandDoFfc: std_logic_vector(7 downto 0) := x"0C";
	constant tixVCommandFfcPeriod: std_logic_vector(7 downto 0) := x"0D";
	constant tixVCommandFfcTempDelta: std_logic_vector(7 downto 0) := x"0E";
	constant tixVCommandVideoMode: std_logic_vector(7 downto 0) := x"0F";
	constant tixVCommandVideoPalette: std_logic_vector(7 downto 0) := x"10";
	constant tixVCommandVideoOrientation: std_logic_vector(7 downto 0) := x"11";
	constant tixVCommandDigitalOutputMode: std_logic_vector(7 downto 0) := x"12";
	constant tixVCommandAgcType: std_logic_vector(7 downto 0) := x"13";
	constant tixVCommandContrast: std_logic_vector(7 downto 0) := x"14";
	constant tixVCommandBrightness: std_logic_vector(7 downto 0) := x"15";
	constant tixVCommandBrightnessBias: std_logic_vector(7 downto 0) := x"18";
	constant tixVCommandLensNumber: std_logic_vector(7 downto 0) := x"1E";
	constant tixVCommandSpotMeterMode: std_logic_vector(7 downto 0) := x"1F";
	constant tixVCommandReadSensor: std_logic_vector(7 downto 0) := x"20";
	constant tixVCommandExternalSync: std_logic_vector(7 downto 0) := x"21";
	constant tixVCommandIsotherm: std_logic_vector(7 downto 0) := x"22";
	constant tixVCommandIsothermThresholds: std_logic_vector(7 downto 0) := x"23";
	constant tixVCommandTestPattern: std_logic_vector(7 downto 0) := x"25";
	constant tixVCommandVideoColorMode: std_logic_vector(7 downto 0) := x"26";
	constant tixVCommandGetSpotMeter: std_logic_vector(7 downto 0) := x"2A";
	constant tixVCommandSpotDisplay: std_logic_vector(7 downto 0) := x"2B";
	constant tixVCommandDdeGain: std_logic_vector(7 downto 0) := x"2C";
	constant tixVCommandSymbolControl: std_logic_vector(7 downto 0) := x"2F";
	constant tixVCommandSplashControl: std_logic_vector(7 downto 0) := x"31";
	constant tixVCommandEzoomControl: std_logic_vector(7 downto 0) := x"32";
	constant tixVCommandFfcWarnTime: std_logic_vector(7 downto 0) := x"3C";
	constant tixVCommandAgcFilter: std_logic_vector(7 downto 0) := x"3E";
	constant tixVCommandPlateauLevel: std_logic_vector(7 downto 0) := x"3F";
	constant tixVCommandGetSpotMeterData: std_logic_vector(7 downto 0) := x"43";
	constant tixVCommandAgcRoi: std_logic_vector(7 downto 0) := x"4C";
	constant tixVCommandShutterTemp: std_logic_vector(7 downto 0) := x"4D";
	constant tixVCommandAgcMidpoint: std_logic_vector(7 downto 0) := x"55";
	constant tixVCommandCameraPart: std_logic_vector(7 downto 0) := x"66";
	constant tixVCommandReadArrayAverage: std_logic_vector(7 downto 0) := x"68";
	constant tixVCommandMaxAgcGain: std_logic_vector(7 downto 0) := x"6A";
	constant tixVCommandPanAndTilt: std_logic_vector(7 downto 0) := x"70";
	constant tixVCommandVideoStandard: std_logic_vector(7 downto 0) := x"72";
	constant tixVCommandShutterPosition: std_logic_vector(7 downto 0) := x"79";
	constant tixVCommandTransferFrame: std_logic_vector(7 downto 0) := x"82";
	constant tixVCommandCorrectionMask: std_logic_vector(7 downto 0) := x"B1";
	constant tixVCommandMemoryStatus: std_logic_vector(7 downto 0) := x"C4";
	constant tixVCommandWriteNvffcTable: std_logic_vector(7 downto 0) := x"C6";
	constant tixVCommandReadMemory: std_logic_vector(7 downto 0) := x"D2";
	constant tixVCommandEraseMemoryBlock: std_logic_vector(7 downto 0) := x"D4";
	constant tixVCommandGetNvMemorySize: std_logic_vector(7 downto 0) := x"D5";
	constant tixVCommandGetMemoryAddress: std_logic_vector(7 downto 0) := x"D6";
	constant tixVCommandGainSwitchParams: std_logic_vector(7 downto 0) := x"DB";
	constant tixVCommandDdeThreshold: std_logic_vector(7 downto 0) := x"E2";
	constant tixVCommandSpatialThreshold: std_logic_vector(7 downto 0) := x"E3";
	constant tixVCommandLensResponseParams: std_logic_vector(7 downto 0) := x"E5";
	-- IP sigs.cmd.cust --- IEND

	---- main operation (op)
	stateOp_t is (
		stateOpInit,
		stateOpIdle,
		stateOpStepXfer,
		stateOpRetry,
		stateOpTxAuxbufA, stateOpTxAuxbufB, stateOpTxAuxbufC, stateOpTxAuxbufD, stateOpTxAuxbufE,
		stateOpTxCmdbufA, stateOpTxCmdbufB, stateOpTxCmdbufC, stateOpTxCmdbufD, stateOpTxCmdbufE,
		stateOpTxCmdbufF, stateOpTxCmdbufG, stateOpTxCmdbufH, stateOpTxCmdbufI,
		stateOpTxCrcA, stateOpTxCrcB, stateOpTxCrcC,
		stateOpRxAuxbufA, stateOpRxAuxbufB, stateOpRxAuxbufC,
		stateOpRxCmdbufA, stateOpRxCmdbufB, stateOpRxCmdbufC, stateOpRxCmdbufD, stateOpRxCmdbufE,
		stateOpRxCrcA, stateOpRxCrcB,
		stateOpAckReset,
		stateOpRet,
		stateOpFwderr,
		stateOpDone
	);

	signal invVblobNotBlob: std_logic;
	signal retVoid: std_logic;
	signal retVblobNotBlob: std_logic;

	signal strbDFromCmdbuf: std_logic;

	signal dToCmdbuf, dToCmdbuf_next: std_logic_vector(7 downto 0);
	signal strbDToCmdbuf: std_logic;

	signal crccaptNotFin, crccaptNotFin_next: std_logic;

	signal crcd: std_logic_vector(7 downto 0);
	signal strbCrcd, strbCrcd_next: std_logic;

	signal torestart, torestart_next: std_logic;

	signal urxlen: std_logic_vector(10 downto 0);

	signal utxlen: std_logic_vector(10 downto 0);

	signal utxd, utxd_next: std_logic_vector(7 downto 0);

	signal wurestart, wurestart_next: std_logic;

	-- IP sigs.op.cust --- IBEGIN
	constant sizeAuxbuf: natural := 10; -- 6+2+2

	type auxbuf_t is array (0 to sizeAuxbuf-1) of std_logic_vector(7 downto 0);
	signal auxbuf: auxbuf_t;

	constant lenAuxbufPre: natural := 8;

	constant ixAuxbufPc: natural := 0;
	constant ixAuxbufStatus: natural := 1;
	constant ixAuxbufRes: natural := 2;
	constant ixAuxbufFct: natural := 3;
	constant ixAuxbufBc: natural := 4;
	constant ixAuxbufCrc1: natural := 6;
	constant ixAuxbufData: natural := 8;
	constant ixAuxbufCrc2: natural := 8;
	-- IP sigs.op.cust --- IEND

	---- handshake (new standard)
	-- cmd to op
	signal reqCmdToOpInvReset, reqCmdToOpInvReset_next: std_logic;
	signal ackCmdToOpInvReset;

	-- op to cmd
	signal reqOpToCmdFromCmdbuf: std_logic;
	signal ackOpToCmdFromCmdbuf: std_logic;

	-- op to cmd
	signal reqOpToCmdFwderr: std_logic;
	signal ackOpToCmdFwderr, ackOpToCmdFwderr_next: std_logic;

	-- op to cmd
	signal reqOpToCmdLock, reqOpToCmdLock_next: std_logic;
	signal ackOpToCmdLock: std_logic;

	-- op to cmd
	signal reqOpToCmdRet: std_logic;
	signal ackOpToCmdRet, ackOpToCmdRet_next: std_logic;

	-- op to cmd
	signal reqOpToCmdToCmdbuf: std_logic;
	signal ackOpToCmdToCmdbuf: std_logic;

	-- op to myCrc
	signal reqCrc: std_logic;
	signal ackCrc: std_logic;
	signal dneCrc: std_logic;

	-- op to myUrx
	signal reqUrx: std_logic;
	signal ackUrx: std_logic;
	signal dneUrx: std_logic;

	-- op to myUtx
	signal reqUtx: std_logic;
	signal ackUtx: std_logic;
	signal dneUtx: std_logic;

	---- other
	signal crc: std_logic_vector(15 downto 0);

	signal timeout: std_logic;

	signal urxd: std_logic_vector(7 downto 0);
	signal strbUrxd: std_logic;

	signal strbUtxd: std_logic;

	signal wakeup: std_logic;

	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myCrc: Crcp_v1_0
		generic map (
			poly => x"1021",
			bitinv => '0'
		)
		port map (
			reset => reset,

			mclk => mclk,

			fastclk => extclk,

			req => reqCrc,
			ack => ackCrc,
			dne => dneCrc,

			captNotFin => crccaptNotFin,

			d => crcd,
			strbD => strbCrcd,

			crc => crc
		);

	myTimeout: Timeout_v1_0
		generic map (
			twait => 10
		)
		port map (
			reset => reset,
			
			mclk => mclk,
			
			tkclk => tkclk,
			
			restart => torestart,
			timeout => timeout
		);

	myUartrx: Uartrx_v1_0
		generic map(
			fMclk => fMclk,
			
			fSclk => 9600
		)
		port map (
			reset => reset,

			mclk => mclk,

			req => reqUrx,
			ack => ackUrx,
			dne => dneUrx,

			len => urxlen,

			d => urxd,
			strbD => strbUrxd,

			rxd => rxd
		);

	myUarttx: Uarttx_v1_0
		generic map(
			fMclk => fMclk,
			
			fSclk => 9600,
			Nstop => 2
		)
		port map (
			reset => reset,
			
			mclk => mclk,

			req => reqUtx,
			ack => ackUtx,
			dne => dneUtx,
			
			len => utxlen,
			
			d => utxd,
			strbD => strbUtxd,

			txd => txd
		);

	myWakeup: Timeout_v1_0
		generic map (
			twait => 10
		)
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
	ackOpToCmdFromCmdbuf <= '1' when (stateCmd=stateCmdFromCmdbufA or stateCmd=stateCmdFromCmdbufB) else '0';
	ackOpToCmdLock <= '1' when stateCmd=stateCmdLock else '0';
	ackOpToCmdToCmdbuf <= '1' when (stateCmd=stateCmdToCmdbufA or stateCmd=stateCmdToCmdbufB) else '0';

	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- RBEGIN
		variable bytecnt: natural range 0 to sizeCmdbuf;

		variable i, j: natural range 0 to sizeCmdbuf;
		variable x: std_logic_vector(7 downto 0);
		-- IP impl.cmd.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			lenCmdbuf_next <= 0;
			dFromCmdbuf_next <= (others => '0');
			reqCmdToOpInvReset_next <= '0';
			ackOpToCmdFwderr_next <= '0';
			ackOpToCmdRet_next <= '0';

			dCmdbus_sig_next <= "ZZZZZZZZ";
			rdyCmdbusFromCmdinv_sig_next <= '1';
			reqCmdbusToCmdret_sig_next <= '0';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.init --- IBEGIN
				lenCmdbuf_next <= 0;
				dFromCmdbuf_next <= (others => '0');
				reqCmdToOpInvReset_next <= '0';
				ackOpToCmdFwderr_next <= '0';
				ackOpToCmdRet_next <= '0';

				rdyCmdbusFromCmdinv_sig_next <= '1';
				reqCmdbusToCmdret_sig_next <= '0';

				stateCmd_next <= stateCmdEmpty;
				-- IP impl.cmd.rising.init --- IEND

			elsif stateCmd=stateCmdEmpty then
				-- IP impl.cmd.rising.empty --- IBEGIN
				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;
				end if;
				-- IP impl.cmd.rising.empty --- IEND

			elsif stateCmd=stateCmdLock then -- ackOpToCmdLock=1
				if reqOpToCmdLock='0' then
					stateCmd_next <= stateCmdInit;

				elsif reqOpToCmdToCmdbuf='1' then
					-- IP impl.cmd.rising.lock.toCmdbuf --- IBEGIN
					lenCmdbuf_next <= 10; -- 4+1+4+1
					stateCmd_next <= stateCmdToCmdbufB; -- expect strbDToCmdbuf=0
					-- IP impl.cmd.rising.lock.toCmdbuf --- IEND

				elsif reqOpToCmdFromCmdbuf='1' then -- did not arrive here via WaitLock, but directly from RecvB
					-- IP impl.cmd.rising.lock.fromCmdbuf --- IBEGIN
					bytecnt := ixCmdbufInvCommand+1;
					
					dFromCmdbuf_next <= cmdbuf(bytecnt);
					-- IP impl.cmd.rising.lock.fromCmdbuf --- IEND

					stateCmd_next <= stateCmdFromCmdbufB; -- expect strbDFromCmdbuf=1

				elsif reqOpToCmdRet='1' then
					stateCmd_next <= stateCmdRet;

				elsif reqOpToCmdFwderr='1' then -- from fromCmdbufA
					-- IP impl.cmd.rising.lock.fwderr --- IBEGIN
					i := ixCmdbufFwderrRoute+1;
					j := ixCmdbufRoute;
					-- IP impl.cmd.rising.lock.fwderr --- IEND

					stateCmd_next <= stateCmdPrepFwderrA;
				end if;

			elsif stateCmd=stateCmdRecvA then
				-- IP impl.cmd.rising.recvA --- IBEGIN
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvB;
				end if;
				-- IP impl.cmd.rising.recvA --- IEND

			elsif stateCmd=stateCmdRecvB then
				-- IP impl.cmd.rising.recvB --- IBEGIN
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
				-- IP impl.cmd.rising.recvB --- IEND

			elsif stateCmd=stateCmdRecvC then
				-- IP impl.cmd.rising.recvC --- IBEGIN
				if clkCmdbus='0' then
					lenCmdbuf_next <= lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvB;
				end if;
				-- IP impl.cmd.rising.recvC --- IEND

			elsif stateCmd=stateCmdRecvD then
				-- IP impl.cmd.rising.recvD --- IBEGIN
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
				-- IP impl.cmd.rising.recvD --- IEND

			elsif stateCmd=stateCmdRecvE then
				-- IP impl.cmd.rising.recvE --- IBEGIN
				cmdbuf(i) <= x;

				i := i + 1;
				j := j + 1;

				stateCmd_next <= stateCmdRecvD;
				-- IP impl.cmd.rising.recvE --- IEND

			elsif stateCmd=stateCmdRecvF then
				-- IP impl.cmd.rising.recvF --- IBEGIN
				if cmdbuf(ixCmdbufRoute)=x"00" then
					-- local
					if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandReset and lenCmdbuf=lenCmdbufInvReset) then
						reqCmdToOpInvReset_next <= '1';
						stateCmd_next <= stateCmdRecvG;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				else
					stateCmd_next <= stateCmdLock;
				end if;
				-- IP impl.cmd.rising.recvF --- IEND

			elsif stateCmd=stateCmdRecvG then
				-- IP impl.cmd.rising.recvG --- IEND
				if (reqCmdToOpInvReset='1' and ackCmdToOpInvReset='1') then
					stateCmd_next <= stateCmdInit;
				end if;
				-- IP impl.cmd.rising.recvG --- IEND

			elsif stateCmd=stateCmdFullA then
				-- IP impl.cmd.rising.fullA --- IBEGIN
				if cmdbuf(ixCmdbufRoute)=tixVDcx3ControllerCmdret then
					reqCmdbusToCmdret_sig_next <= '1';
				end if;
	
				stateCmd_next <= stateCmdFullB;
				-- IP impl.cmd.rising.fullA --- IEND

			elsif stateCmd=stateCmdFullB then
				-- IP impl.cmd.rising.fullB --- IBEGIN
				if (wrCmdbusToCmdret='1' and clkCmdbus='1') then
					bytecnt := 0;

					dCmdbus_sig_next <= cmdbuf(0);

					stateCmd_next <= stateCmdSendA;
				end if;
				-- IP impl.cmd.rising.fullB --- IEND

			elsif stateCmd=stateCmdSendA then
				-- IP impl.cmd.rising.sendA --- IBEGIN
				if clkCmdbus='0' then
					bytecnt := bytecnt + 1;

					stateCmd_next <= stateCmdSendB;
				end if;
				-- IP impl.cmd.rising.sendA --- IEND

			elsif stateCmd=stateCmdSendB then
				-- IP impl.cmd.rising.sendB --- IBEGIN
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
				-- IP impl.cmd.rising.sendB --- IEND

			elsif stateCmd=stateCmdSendC then
				-- IP impl.cmd.rising.sendC --- IBEGIN
				if wrCmdbusToCmdret='0' then
					if (reqOpToCmdRet='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionRet) then
						ackOpToCmdRet_next <= '1';
						stateCmd_next <= stateCmdSendD;
					elsif (reqOpToCmdFwderr='1' and cmdbuf(ixCmdbufAction)=tixDbeVActionFwderr) then
						ackOpToCmdFwderr_next <= '1';
						stateCmd_next <= stateCmdSendD;
					else
						stateCmd_next <= stateCmdInit;
					end if;
				end if;
				-- IP impl.cmd.rising.sendC --- IEND

			elsif stateCmd=stateCmdSendD then
				-- IP impl.cmd.rising.sendD --- IBEGIN
				if ((reqOpToCmdRet='0' and ackOpToCmdRet='1') or (reqOpToCmdFwderr='0' and ackOpToCmdFwderr='1')) then
					stateCmd_next <= stateCmdInit;
				end if;
				-- IP impl.cmd.rising.sendD --- IEND

			elsif stateCmd=stateCmdPrepRet then
				-- IP impl.cmd.rising.prepRet --- IBEGIN
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				-- lenCmdbuf has been set previously in ToCmdbufA/B

				stateCmd_next <= stateCmdFullA;
				-- IP impl.cmd.rising.prepRet --- IEND

			elsif stateCmd=stateCmdPrepFwderrA then
				if j=4 then
					-- IP impl.cmd.rising.prepFwderrA.last --- IBEGIN
					cmdbuf(ixCmdbufAction) <= tixDbeVActionFwderr;

					cmdbuf(ixCmdbufFwderrRoute) <= tixVDcx3ControllerLwirif;

					lenCmdbuf_next <= lenCmdbufFwderr;
					-- IP impl.cmd.rising.prepFwderrA.last --- IEND

					stateCmd_next <= stateCmdFullA;
				else
					x := cmdbuf(j); -- IP impl.cmd.rising.prepFwderrA.load --- ILINE

					stateCmd_next <= stateCmdPrepFwderrB;
				end if;

			elsif stateCmd=stateCmdPrepFwderrB then
				-- IP impl.cmd.rising.prepFwderrB.store --- IBEGIN
				cmdbuf(i) <= x;

				i := i + 1;
				j := j + 1;
				-- IP impl.cmd.rising.prepFwderrB.store --- IEND

				stateCmd_next <= stateCmdPrepFwderrA;

			elsif stateCmd=stateCmdToCmdbufA then -- cmdret from tau2 ; ackOpToCmdToCmdbuf='1'
				-- IP impl.cmd.rising.toCmdbufA --- IBEGIN
				if reqOpToCmdToCmdbuf='0' then
					stateCmd_next <= stateCmdLock;
				elsif strbDToCmdbuf='0' then
					stateCmd_next <= stateCmdToCmdbufB;
				end if;
				-- IP impl.cmd.rising.toCmdbufA --- IEND

			elsif stateCmd=stateCmdToCmdbufB then -- ackOpToCmdToCmdbuf='1'
				-- IP impl.cmd.rising.toCmdbufB --- IBEGIN
				if strbDToCmdbuf='1' then
					cmdbuf(lenCmdbuf) <= dToCmdbuf;
					lenCmdbuf_next <= lenCmdbuf + 1;

					stateCmd_next <= stateCmdToCmdbufA;
				end if;
				-- IP impl.cmd.rising.toCmdbufB --- IEND

			elsif stateCmd=stateCmdFromCmdbufA then -- cmdinv to tau2 ; ackOpToCmdFromCmdbuf='1'
				-- IP impl.cmd.rising.fromCmdbufA --- IBEGIN
				if reqOpToCmdFromCmdbuf='0' then
					stateCmd_next <= stateCmdLock;
				elsif strbDFromCmdbuf='0' then
					dFromCmdbuf_next <= cmdbuf(bytecnt);
					stateCmd_next <= stateCmdFromCmdbufB;
				end if;
				-- IP impl.cmd.rising.fromCmdbufA --- IEND

			elsif stateCmd=stateCmdFromCmdbufB then -- ackOpToCmdFromCmdbuf='1'
				-- IP impl.cmd.rising.fromCmdbufB --- IBEGIN
				if strbDFromCmdbuf='1' then
					bytecnt := bytecnt + 1;
					stateCmd_next <= stateCmdFromCmdbufA;
				end if;
				-- IP impl.cmd.rising.fromCmdbufB --- IEND
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
			ackOpToCmdRet <= ackOpToCmdRet_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			dCmdbus_sig <= dCmdbus_sig_next;
			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- RBEGIN
	invVblobNotBlob <= '1' when (cmdbuf(ixCmdbufInvCommand)=tixVCommandBaudRate or cmdbuf(ixCmdbufInvCommand)=tixVCommandGainMode or cmdbuf(ixCmdbufInvCommand)=tixVCommandFfcModeSelect
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandFfcPeriod or cmdbuf(ixCmdbufInvCommand)=tixVCommandFfcTempDelta or cmdbuf(ixCmdbufInvCommand)=tixVCommandVideoMode
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandVideoPalette or cmdbuf(ixCmdbufInvCommand)=tixVCommandVideoOrientation or cmdbuf(ixCmdbufInvCommand)=tixVCommandDigitalOutputMode
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandAgcType or cmdbuf(ixCmdbufInvCommand)=tixVCommandContrast or cmdbuf(ixCmdbufInvCommand)=tixVCommandBrightness
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandBrightnessBias or cmdbuf(ixCmdbufInvCommand)=tixVCommandLensNumber or cmdbuf(ixCmdbufInvCommand)=tixVCommandSpotMeterMode
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandExternalSync or cmdbuf(ixCmdbufInvCommand)=tixVCommandIsotherm or cmdbuf(ixCmdbufInvCommand)=tixVCommandIsothermThresholds
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandTestPattern or cmdbuf(ixCmdbufInvCommand)=tixVCommandVideoColorMode or cmdbuf(ixCmdbufInvCommand)=tixVCommandSpotDisplay
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandDdeGain or cmdbuf(ixCmdbufInvCommand)=tixVCommandSymbolControl or cmdbuf(ixCmdbufInvCommand)=tixVCommandSplashControl
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandEzoomControl or cmdbuf(ixCmdbufInvCommand)=tixVCommandFfcWarnTime or cmdbuf(ixCmdbufInvCommand)=tixVCommandAgcFilter
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandPlateauLevel or cmdbuf(ixCmdbufInvCommand)=tixVCommandGetSpotMeterData or cmdbuf(ixCmdbufInvCommand)=tixVCommandAgcRoi
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandShutterTemp or cmdbuf(ixCmdbufInvCommand)=tixVCommandAgcMidpoint or cmdbuf(ixCmdbufInvCommand)=tixVCommandPanAndTilt
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandVideoStandard or cmdbuf(ixCmdbufInvCommand)=tixVCommandShutterPosition or cmdbuf(ixCmdbufInvCommand)=tixVCommandCorrectionMask
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandGainSwitchParams or cmdbuf(ixCmdbufInvCommand)=tixVCommandDdeThreshold or cmdbuf(ixCmdbufInvCommand)=tixVCommandSpatialThreshold
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandLensResponseParams)
 				else '0';

	retVoid <= '1' when (cmdbuf(ixCmdbufInvCommand)=tixVCommandSetDefaults or cmdbuf(ixCmdbufInvCommand)=tixVCommandCameraReset or cmdbuf(ixCmdbufInvCommand)=tixVCommandRestoreFactoryDefault
				or cmdbuf(ixCmdbufInvCommand)=tixVCommandDoFfc or cmdbuf(ixCmdbufInvCommand)=tixVCommandWriteNvffcTable)
				else '0';

	retVblobNotBlob <= '1' when (cmdbuf(ixCmdbufInvCommand)=tixVCommandFfcPeriod or cmdbuf(ixCmdbufInvCommand)=tixVCommandFfcTempDelta or cmdbuf(ixCmdbufInvCommand)=tixVCommandReadSensor
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandSymbolControl or cmdbuf(ixCmdbufInvCommand)=tixVCommandEzoomControl or cmdbuf(ixCmdbufInvCommand)=tixVCommandGetSpotMeterData
				or cmdbuf(ixCmdbufInvCommand)=tixVCommandAgcRoi or cmdbuf(ixCmdbufInvCommand)=tixVCommandShutterTemp or cmdbuf(ixCmdbufInvCommand)=tixVCommandMaxAgcGain
 				or cmdbuf(ixCmdbufInvCommand)=tixVCommandShutterPosition or cmdbuf(ixCmdbufInvCommand)=tixVCommandReadMemory or cmdbuf(ixCmdbufInvCommand)=tixVCommandLensResponseParams)
 				else '0';

	crcd <= utxd when (stateOp=stateOpTxAuxbufA or stateOp=stateOpTxAuxbufB or stateOp=stateOpTxAuxbufC or stateOp=stateOpTxAuxbufD or stateOp=stateOpTxAuxbufE
				or stateOp=stateOpTxCmdbufA or stateOp=stateOpTxCmdbufB or stateOp=stateOpTxCmdbufC or stateOp=stateOpTxCmdbufD or stateOp=stateOpTxCmdbufE
				or stateOp=stateOpTxCmdbufF or stateOp=stateOpTxCmdbufG or stateOp=stateOpTxCmdbufH or stateOp=stateOpTxCmdbufI or stateOp=stateOpTxCrcA
				or stateOp=stateOpTxCrcB or stateOp=stateOpTxCrcC) else urxd;

	strbDFromCmdbuf <= '1' when (stateOp=stateOpTxCmdbufA or stateOp=stateOpTxCmdbufC or stateOp=stateOpTxCmdbufD or stateOp=stateOpTxCmdbufE or stateOp=stateOpTxCmdbufG) else '0';

	strbDToCmdbuf <= '0' when (stateOp=stateOpRxCmdbufB or stateOp=stateOpRxCmdbufE) else '1';

	ackCmdToOpInvReset <= '1' when stateOp=stateOpAckReset else '0';

	reqOpToCmdFromCmdbuf <= '1' when (stateOp=stateOpTxCmdbufA or stateOp=stateOpTxCmdbufB or stateOp=stateOpTxCmdbufC or stateOp=stateOpTxCmdbufD or stateOp=stateOpTxCmdbufE
				or stateOp=stateOpTxCmdbufF or stateOp=stateOpTxCmdbufG) else '0';

	reqOpToCmdFwderr <= '1' when stateOp=stateOpFwderr else '0';

	reqOpToCmdLock <= '0' when stateOp=stateOpDone else '1';

	reqOpToCmdRet <= '1' when stateOp=stateOpRet else '0';

	reqOpToCmdToCmdbuf <= '1' when (stateOp=stateOpRxCmdbufA or stateOp=stateOpRxCmdbufB or stateOp=stateOpRxCmdbufC or stateOp=stateOpRxCmdbufD or stateOp=stateOpRxCmdbufE) else '0';

	reqCrc <= '1' when (stateOp=stateOpTxAuxbufA or stateOp=stateOpTxAuxbufB or stateOp=stateOpTxAuxbufC or stateOp=stateOpTxAuxbufD or stateOp=stateOpTxAuxbufE
				or stateOp=stateOpTxCmdbufD or stateOp=stateOpTxCmdbufE or stateOp=stateOpTxCmdbufF or stateOp=stateOpTxCmdbufG or stateOp=stateOpTxCmdbufH
				or stateOp=stateOpTxCmdbufI or stateOp=stateOpRxAuxbufA or stateOp=stateOpRxAuxbufB or stateOp=stateOpRxAuxbufC or stateOp=stateOpRxCmdbufC
				or stateOp=stateOpRxCmdbufD or stateOp=stateOpRxCmdbufE or stateOp=stateOpRxCrcA or stateOp=stateOpRxCrcB) else '0';

	reqUrx <= '1' when (stateOp=stateOpRxAuxbufA or stateOp=stateOpRxAuxbufB or stateOp=stateOpRxAuxbufC or stateOp=stateOpRxCmdbufC or stateOp=stateOpRxCmdbufD
				or stateOp=stateOpRxCmdbufE or stateOp=stateOpRxCrcA or stateOp=stateOpRxCrcB) else '0';

	reqUtx <= '1' when (stateOp=stateOpTxAuxbufA or stateOp=stateOpTxAuxbufB or stateOp=stateOpTxAuxbufC or stateOp=stateOpTxAuxbufD or stateOp=stateOpTxAuxbufE
				or stateOp=stateOpTxCmdbufD or stateOp=stateOpTxCmdbufE of stateOp=stateOpTxCmdbufF or stateOp=stateOpTxCmdbufG or stateOp=stateOpTxCmdbufH
				or stateOp=stateOpTxCmdbufI or stateOp=stateOpTxCrcA or stateOp=stateOpTxCrcB or stateOp=stateOpTxCrcC) else '0';
	-- IP impl.op.wiring --- REND

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		variable retry: natural range 0 to Nretry;

		type xfer_t is (xferIdle, xferTxAuxbuf, xferTxCmdbuf, xferRxAuxbuf, xferRxCmdbuf);
		variable xfer: xfer_t := xferIdle;

		type rxerr_t is (rxerrOk, rxerrStatus, rxerrCrc1, rxerrCrc2, rxerrTo);
		variable rxerr: rxerr_t := rxerrOk;

		variable lenFromCmdbuf: natural range 0 to sizeCmdbuf;
		variable lenToCmdbuf: natural range 0 to sizeCmdbuf;

		variable i: natural range 0 to sizeAuxbuf;
		variable j: natural range 0 to sizeCmdbuf;

		variable x: std_logic_vector(15 downto 0);
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- BEGIN
			stateOp_next <= stateOpInit;
			dToCmdbuf_next <= (others => '0');
			crccaptNotFin_next <= '0';
			strbCrcd_next <= '0';
			torestart_next <= '0';
			utxd_next <= (others => '0');
			wurestart_next <= '0';
			-- IP impl.op.rising.ascnyrst --- END

		elsif rising_edge(mclk) then
			if stateOp=stateOpInit then
				-- IP impl.op.rising.syncrst --- RBEGIN
				dToCmdbuf_next <= (others => '0');
				crccaptNotFin_next <= '0';
				strbCrcd_next <= '0';
				torestart_next <= '0';
				utxd_next <= (others => '0');
				wurestart_next <= '0';

				retry := 0;

				xfer := xferIdle;

				rxerr := rxerrOk;
				-- IP impl.op.rising.syncrst --- REND

				stateOp_next <= stateOpIdle;

			elsif stateOp=stateOpIdle then -- reqOpToCmdLock='1'
				if (reqCmdToOpInvReset='1' or (ackOpToCmdLock='1' and lenCmdbuf/=0)) then
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpStepXfer then
				if xfer=xferIdle then
					-- IP impl.op.rising.stepXfer.idle --- IBEGIN
					auxbuf(ixAuxbufPc) <= x"6E";
					if reqCmdToOpInvReset='1' then
						auxbuf(ixAuxbufFct) <= x"02";
					else
						auxbuf(ixAuxbufFct) <= cmdbuf(ixCmdbufInvCommand);
					end if;

					auxbuf(ixAuxbufBc) <= (others => '0');
					if reqCmdToOpInvReset='1' then
						auxbuf(ixAuxbufBc+1) <= (others => '0');
					elsif invVblobNotBlob='1' then
						auxbuf(ixAuxbufBc+1) <= std_logic_vector(to_unsigned(lenCmdbuf-11, 8));
					else
						auxbuf(ixAuxbufBc+1) <= std_logic_vector(to_unsigned(lenCmdbuf-10, 8));
					end if;

					xfer := xferTxAuxbuf;

					i := 0;

					crccaptNotFin_next <= '1';

					strbCrcd_next <= '1';

					utxlen <= std_logic_vector(to_unsigned(lenAuxbufPre, 11));

					utxd_next <= auxbuf(i);
					-- IP impl.op.rising.stepXfer.idle --- IEND

					stateOp_next <= stateOpTxAuxbufA;

				elsif xfer=xferTxAuxbuf then
					-- IP impl.op.rising.stepXfer.txAuxbuf --- IBEGIN
					xfer := xferTxCmdbuf;

					i := ixAuxbufCrc2;
					j := 0;

					crccaptNotFin_next <= '1';

					strbCrcd_next <= '1';
					-- IP impl.op.rising.stepXfer.txAuxbuf --- IEND

					if (reqCmdToOpInvReset='1' or (invVblobNotBlob='0' and lenCmdbuf<=10) or (invVblobNotBlob='1' and lenCmdbuf<=11)) then
						-- IP impl.op.rising.stepXfer.txCrc --- IBEGIN
						auxbuf(ixAuxbufCrc2) <= (others => '0');
						auxbuf(ixAuxbufCrc2+1) <= (others => '0');

						utxlen <= std_logic_vector(to_unsigned(lenAuxbufCrc, 11));

						utxd_next <= auxbuf(i);
						-- IP impl.op.rising.stepXfer.txCrc --- IEND

						stateOp_next <= stateOpTxCrcA;

					elsif invVblobNotBlob='0' then
						-- IP impl.op.rising.stepXfer.txCmdbufBlob --- IBEGIN
						lenFromCmdbuf := lenCmdbuf-8; -- lenCmdbuf-10+lenAuxbufCrc
						utxlen <= std_logic_vector(to_unsigned(lenFromCmdbuf, 11));
						-- IP impl.op.rising.stepXfer.txCmdbufBlob --- IEND

						stateOp_next <= stateOpTxCmdbufA; -- step cmdbuf pointer without outputting anything / contributing to the CRC

					elsif invVblobNotBlob='1' then
						-- IP impl.op.rising.stepXfer.txCmdbufVblob --- IBEGIN
						lenFromCmdbuf := lenCmdbuf-9; -- lenCmdbuf-11+lenAuxbufCrc
						utxlen <= std_logic_vector(to_unsigned(lenFromCmdbuf, 11));
						-- IP impl.op.rising.stepXfer.txCmdbufVblob --- IEND

						stateOp_next <= stateOpTxCmdbufC;
					end if;

				elsif xfer=xferTxCmdbuf then
					-- IP impl.op.rising.stepXfer.txCmdbuf --- IBEGIN
					xfer := xferRxAuxbuf;

					i := 0;

					crccaptNotFin_next <= '1';

					strbCrcd_next <= '0';

					urxlen <= std_logic_vector(to_unsigned(lenAuxbufPre, 11));

					torestart_next <= '0';
					-- IP impl.op.rising.stepXfer.txCmdbuf --- IEND

					stateOp_next <= stateOpRxAuxbufA;

				elsif xfer=xferRxAuxbuf then
					if rxerr=rxerrOk then
						-- IP impl.op.rising.stepXfer.rxAuxbuf --- IBEGIN
						xfer := xferRxCmdbuf;

						i := ixAuxbufCrc2;
						j := 0;

						x := auxbuf(ixAuxbufBc) & auxbuf(ixAuxbufBc+1);
						-- IP impl.op.rising.stepXfer.rxAuxbuf --- IEND

						if x=x"0000" then
							urxlen <= std_logic_vector(to_unsigned(lenAuxbufCrc, 11)); -- IP impl.op.rising.stepXfer.rxCrc --- ILINE
							stateOp_next <= stateOpRxCrcA;

						else
							-- IP impl.op.rising.stepXfer.rxCmdbuf --- IBEGIN
							lenToCmdbuf := to_integer(unsigned(x));
							urxlen <= std_logic_vector(to_unsigned(lenToCmdbuf+2, 11));
							-- IP impl.op.rising.stepXfer.rxCmdbuf --- IEND

							if retVblobNotBlob='1' then then
								stateOp_next <= stateOpRxCmdbufA; -- insert argument length in cmdbuf as first byte without receiving anything / contributing to the CRC

							else
								torestart_next <= '1'; -- IP impl.op.rising.stepXfer.rxCmdbufBlob --- ILINE
								stateOp_next <= stateOpRxCmdbufC;
							end if;
						end if;

					else
						if reqCmdToOpInvReset='1' then
							stateOp_next <= stateOpAckReset;
						else
							retry := retry + 1; -- IP impl.op.rising.stepXfer.incretry1 --- ILINE
							if retry=Nretry then
								stateOp_next <= stateOpFwderr;
							else
								wurestart_next <= '1'; -- IP impl.op.rising.stepXfer.initretry1 --- ILINE
								stateOp_next <= stateOpRetry;
							end if;
						end if;
					end if;

				elsif xfer=xferRxCmdbuf then
					if reqCmdToOpInvReset='1' then
						stateOp_next <= stateOpAckReset;
					elsif rxerr=rxerrOk then
						if retVoid='0' then
							stateOp_next <= stateOpRet;
						else
							stateOp_next <= stateOpDone;
						end if;

					else
						retry := retry + 1; -- IP impl.op.rising.stepXfer.incretry2 --- ILINE
						if retry=Nretry then
							stateOp_next <= stateOpFwderr;
						else
							wurestart_next <= '1'; -- IP impl.op.rising.stepXfer.initretry2 --- ILINE
							stateOp_next <= stateOpRetry;
						end if;
					end if;
				end if;

			elsif stateOp=stateOpRetry then
				wurestart_next <= '0'; -- IP impl.op.rising.retry.ext --- ILINE

				if wakeup='1' then
					-- IP impl.op.rising.retry.wakeup --- IBEGIN
					xfer := xferIdle;
					rxerr := rxerrOk;
					-- IP impl.op.rising.retry.wakeup --- IEND

					stateOp_next <= stateOpStepXfer;
				end if;

-- txAuxbuf BEGIN
			elsif stateOp=stateOpTxAuxbufA then
				if (ackCrc='1' and ackUtx='1') then
					stateOp_next <= stateOpTxAuxbufB;
				end if;

			elsif stateOp=stateOpTxAuxbufB then
				strbCrcd_next <= '0'; -- IP impl.op.rising.txAuxbufB.ext --- ILINE

				if strbUtxd='0' then
					i := i + 1; -- IP impl.op.rising.txAuxbufB.inc --- ILINE

					if i=ixAuxbufCrc1 then
						k := 0; -- IP impl.op.rising.txAuxbufB.initwaitcrc --- ILINE
						stateOp_next <= stateOpTxAuxbufD;
					else
						utxd_next <= auxbuf(i); -- IP impl.op.rising.txAuxbufB.out --- ILINE
						stateOp_next <= stateOpTxAuxbufC;
					end if;
				end if;

			elsif stateOp=stateOpTxAuxbufC then
				if dneUtx='1' then
					stateOp_next <= stateOpStepXfer;
				elsif strbUtxd='1' then
					strbCrcd_next <= '1'; -- IP impl.op.rising.txAuxbufC --- ILINE
					stateOp_next <= stateOpTxAuxbufB;
				end if;

			elsif stateOp=stateOpTxAuxbufD then
				k := k + 1; -- IP impl.op.rising.txAuxbufD.ext --- ILINE

				if k=10 then
					crccaptNotFin_next <= '0'; -- IP impl.op.rising.txAuxbufD --- ILINE
					stateOp_next <= stateOpTxAuxbufE;
				end if;

			elsif stateOp=stateOpTxAuxbufE then
				if dneCrc='1' then
					-- IP impl.op.rising.txAuxbufE --- IBEGIN
					auxbuf(ixAuxbufCrc1) <= crc(15 downto 8);
					auxbuf(ixAuxbufCrc1+1) <= crc(7 downto 0);

					utxd_next <= crc(15 downto 8);
					-- IP impl.op.rising.txAuxbufE --- IEND

					stateOp_next <= stateOpTxAuxbufC;
				end if;

-- txCmdbuf BEGIN
			elsif stateOp=stateOpTxCmdbufA then
				if ackOpToCmdFromCmdbuf='1' then
					stateOp_next <= stateOpTxCmdbufB;
				end if;

			elsif stateOp=stateOpTxCmdbufB then
				stateOp_next <= stateOpTxCmdbufC;

			elsif stateOp=stateOpTxCmdbufC then
				if ackOpToCmdFromCmdbuf='1' then
					utxd_next <= dFromCmdbuf; -- IP impl.op.rising.txCmdbufC --- ILINE
					stateOp_next <= stateOpTxCmdbufD;
				end if;

			elsif stateOp=stateOpTxCmdbufD then
				if (ackCrc='1' and ackUtx='1') then
					stateOp_next <= stateOpTxCmdbufE;
				end if;

			elsif stateOp=stateOpTxCmdbufE then
				strbCrcd_next <= '0'; -- IP impl.op.rising.txCmdbufE.ext --- ILINE

				if strbUtxd='0' then
					j := j + 1; -- IP impl.op.rising.txCmdbufE.inc --- ILINE

					if j=lenFromCmdbuf then
						k := 0; -- IP impl.op.rising.txCmdbufE.initwaitcrc --- ILINE
						stateOp_next <= stateOpTxCmdbufH;
					else
						stateOp_next <= stateOpTxCmdbufF;
					end if;
				end if;

			elsif stateOp=stateOpTxCmdbufF then
				stateOp_next <= stateOpTxCmdbufG;

			elsif stateOp=stateOpTxCmdbufG then
				utxd_next <= dFromCmdbuf; -- IP impl.op.rising.txCmdbufG.ext --- ILINE

				if strbUtxd='1' then
					strbCrcd_next <= '1'; -- IP impl.op.rising.txCmdbufG --- ILINE
					stateOp_next <= stateOpTxCmdbufE;
				end if;

			elsif stateOp=stateOpTxCmdbufH then
				k := k + 1; -- IP impl.op.rising.txCmdbufH.ext --- ILINE

				if k=10 then
					crccaptNotFin_next <= '0'; -- IP impl.op.rising.txCmdbufH --- ILINE
					stateOp_next <= stateOpTxCmdbufI;
				end if;

			elsif stateOp=stateOpTxCmdbufI then
				if dneCrc='1' then
					-- IP impl.op.rising.txCmdbufI --- IBEGIN
					auxbuf(ixAuxbufCrc2) <= crc(15 downto 8);
					auxbuf(ixAuxbufCrc2+1) <= crc(7 downto 0);

					utxd_next <= crc(15 downto 8);
					-- IP impl.op.rising.txCmdbufI --- IEND

					stateOp_next <= stateOpTxCrcB;
				end if;

			elsif stateOp=stateOpTxCrcA then
				if ackUtx='1' then
					stateOp_next <= stateOpTxCrcB;
				end if;

			elsif stateOp=stateOpTxCrcB then
				if dneUtx='1' then
					stateOp_next <= stateOpStepXfer;
				elsif strbUtxd='0' then
					-- IP impl.op.rising.txCrcB --- IBEGIN
					i := i + 1;
					utxd_next <= auxbuf(i);
					-- IP impl.op.rising.txCrcB --- IEND

					stateOp_next <= stateOpTxCrcC;
				end if;

			elsif stateOp=stateOpTxCrcC then
				if strbUtxd='1' then
					stateOp_next <= stateOpTxCrcB;
				end if;

-- rxAuxbuf BEGIN
			elsif stateOp=stateOpRxAuxbufA then
				torestart_next <= '0'; -- IP impl.op.rising.rxAuxbufA.ext --- ILINE

				if (ackCrc='1' and ackUrx='1') then
					stateOp_next <= stateOpRxAuxbufB;
				elsif timeout='1' then
					rxerr := rxerrTo; -- IP impl.op.rising.rxAuxbufA.timeout --- ILINE
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpRxAuxbufB then
				if strbUrxd='1' then
					-- IP impl.op.rising.rxAuxbufB --- IBEGIN
					auxbuf(i) <= urxd;
					strbCrcd_next <= '1';

					torestart_next <= '1';
					-- IP impl.op.rising.rxAuxbufB --- IEND

					stateOp_next <= stateOpRxAuxbufC;
				end if;

			elsif stateOp=stateOpRxAuxbufC then
				-- IP impl.op.rising.rxAuxbufC.ext --- IBEGIN
				strbCrcd_next <= '0';
				torestart_next <= '0';
				-- IP impl.op.rising.rxAuxbufC.ext --- IEND

				if (dneCrc='1' and dneUrx='1') then
					-- IP impl.op.rising.rxAuxbufC.done --- IBEGIN
					if (auxbuf(ixAuxbufCrc1)/=crc(15 downto 8) or auxbuf(ixAuxbufCrc1+1)/=crc(7 downto 0)) then
						rxerr := rxerrCrc1;
					elsif auxbuf(ixAuxbufStatus)/=x"00" then
						rxerr := rxerrStatus;
					end if;
					-- IP impl.op.rising.rxAuxbufC.done --- IEND

					stateOp_next <= stateOpStepXfer;

				elsif strbUrxd='0' then
					-- IP impl.op.rising.rxAuxbufC.inc --- IBEGIN
					i := i + 1;

					if i=ixAuxbufCrc1 then
						crccaptNotFin_next <= '0';
					end if;
					-- IP impl.op.rising.rxAuxbufC.inc --- IEND

					stateOp_next <= stateOpRxAuxbufB;

				elsif timeout='1' then
					rxerr := rxerrTo; -- IP impl.op.rising.rxAuxbufC.timeout --- ILINE
					stateOp_next <= stateOpStepXfer;
				end if;

-- rxCmdbuf BEGIN
			elsif stateOp=stateOpRxCmdbufA then
				if ackOpToCmdToCmdbuf='1' then
					dToCmdbuf_next <= auxbuf(ixAuxbufBc+1); -- IP impl.op.rising.rxCmdbufA --- ILINE
					stateOp_next <= stateOpRxCmdbufB;
				end if;

			elsif stateOp=stateOpRxCmdbufB then
				torestart_next <= '1'; -- IP impl.op.rising.rxCmdbufB --- ILINE
				stateOp_next <= stateOpRxCmdbufC;

			elsif stateOp=stateOpRxCmdbufC then
				torestart_next <= '0'; -- IP impl.op.rising.rxCmdbufC.ext --- ILINE

				if (ackCrc='1' and ackUrx='1') then
					stateOp_next <= stateOpRxCmdbufD;
				elsif timeout='1' then
					rxerr := rxerrTo; -- IP impl.op.rising.rxCmdbufC.timeout --- ILINE
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpRxCmdbufD then
				if strbUrxd='1' then
					-- IP impl.op.rising.rxCmdbufD --- IBEGIN
					strbCrcd_next <= '1';

					torestart_next <= '1';
					-- IP impl.op.rising.rxCmdbufD --- IEND

					stateOp_next <= stateOpRxCmdbufE;
				end if;

			elsif stateOp=stateOpRxCmdbufE then
				-- IP impl.op.rising.rxCmdbufE.ext --- IBEGIN
				strbCrcd_next <= '0';
				torestart_next <= '0';
				-- IP impl.op.rising.rxCmdbufE.ext --- IEND

				if strbUrxd='0' then
					j := j + 1;  -- IP impl.op.rising.rxCmdbufE.inc --- ILINE

					if j=lenToCmdbuf then
						crccaptNotFin_next <= '0'; -- IP impl.op.rising.rxCmdbufE.initcrc --- ILINE
						stateOp_next <= stateOpRxCrcA;
					else
						stateOp_next <= stateOpRxCmdbufD;
					end if;

				elsif timeout='1' then
					rxerr := rxerrTo; -- IP impl.op.rising.rxCmdbufE.timeout --- ILINE
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpRxCrcA then
				if strbUrxd='1' then
					-- IP impl.op.rising.rxCrcA --- IBEGIN
					auxbuf(i) <= urxd;

					torestart_next <= '1';
					-- IP impl.op.rising.rxCrcA --- IEND

					stateOp_next <= stateOpRxCrcB;
				end if;

			elsif stateOp=stateOpRxCrcB then
				torestart_next <= '0'; -- IP impl.op.rising.rxCrcB.ext --- ILINE

				if (dneCrc='1' and dneUrx='1') then
					-- IP impl.op.rising.rxCrcB.done --- IBEGIN
					if (auxbuf(ixAuxbufCrc2)/=crc(15 downto 8) or auxbuf(ixAuxbufCrc2+1)/=crc(7 downto 0)) then
						rxerr := rxerrCrc2;
					end if;
					-- IP impl.op.rising.rxCrcB.done --- IEND

					stateOp_next <= stateOpStepXfer;

				elsif strbUrxd='0' then
					i := i + 1; -- IP impl.op.rising.rxCrcB.inc --- ILINE
					stateOp_next <= stateOpRxCrcA;

				elsif timeout='1' then
					rxerr := rxerrTo; -- IP impl.op.rising.rxCrcB.timeout --- ILINE
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpAckReset then
				if reqCmdToOpInvReset='0' then
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpRet then
				if ackOpToCmdRet='1' then
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpFwderr then
				if ackOpToCmdFwderr='1' then
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpDone then
				if ackOpToCmdLock='0' then
					stateOp_next <= stateOpInit;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.op.rising --- END

	-- IP impl.op.falling --- BEGIN
	process (mclk)
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			dToCmdbuf <= dToCmdbuf_next;
			crccaptNotFin <= crccaptNotFin_next;
			strbCrcd <= strbCrcd_next;
			torestart <= torestart_next;
			utxd <= utxd_next;
			wurestart <= wurestart_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: other
	------------------------------------------------------------------------
	
	-- IP impl.oth.cust --- INSERT

end Lwirif;
