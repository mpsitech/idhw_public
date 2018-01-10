-- file Lwirif.vhd
-- Lwirif forwarding controller implementation
-- author Alexander Wirthmueller
-- date created: 7 Dec 2016
-- date modified: 18 Jan 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Lwirif is
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
		stateCmdIdle,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE,
		stateCmdRecvF, stateCmdRecvG,
		stateCmdPrepTx,
		stateCmdTxA, stateCmdTxB, stateCmdTxC, stateCmdTxD, stateCmdTxE,
		stateCmdTxF, stateCmdTxG, stateCmdTxH,
		stateCmdPrepRx,
		stateCmdRxA, stateCmdRxB, stateCmdRxC, stateCmdRxD, stateCmdRxE,
		stateCmdRxF, stateCmdRxG, stateCmdRxH,
		stateCmdPrepRetA, stateCmdPrepRetB,
		stateCmdWaitSend, stateCmdSendA, stateCmdSendB, stateCmdSendC
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;

	-- IP sigs.cmd.cust --- IBEGIN
	constant tixDbeVActionInv: std_logic_vector(7 downto 0) := x"00";
	constant tixDbeVActionRet: std_logic_vector(7 downto 0) := x"80";

	constant tixVDcx3ControllerCmdinv: std_logic_vector(7 downto 0) := x"01";
	constant tixVDcx3ControllerCmdret: std_logic_vector(7 downto 0) := x"02";

	constant maxlenCmdbuf: natural range 0 to 10 := 10;

	type cmdbuf_t is array (0 to maxlenCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	constant ixCmdbufRoute: natural range 0 to maxlenCmdbuf-1 := 0;
	constant ixCmdbufAction: natural range 0 to maxlenCmdbuf-1 := 4;
	constant ixCmdbufCref: natural range 0 to maxlenCmdbuf-1 := 5;
	constant ixCmdbufInvCommand: natural range 0 to maxlenCmdbuf-1 := 9;

	constant tixVCommandSetDefaults: std_logic_vector(7 downto 0) := x"01";
	constant tixVCommandCameraReset: std_logic_vector(7 downto 0) := x"02";
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

	signal reqCrc: std_logic;

	signal crccaptNotFin: std_logic;

	signal crcd, crcd_next: std_logic_vector(7 downto 0);
	signal strbCrcd: std_logic;

	signal torestart, torestart_next: std_logic;

	constant maxlenRxbuf: natural range 0 to 202 := 202; -- 6+2+192+2

	type rxbuf_t is array (0 to maxlenRxbuf-1) of std_logic_vector(7 downto 0);
	signal rxbuf: rxbuf_t;

	signal lenRxbuf: natural range 0 to maxlenRxbuf;

	constant ixRxtxbufPc: natural range 0 to maxlenRxbuf-1 := 0;
	constant ixRxtxbufStatus: natural range 0 to maxlenRxbuf-1 := 1;
	constant ixRxtxbufRes: natural range 0 to maxlenRxbuf-1 := 2;
	constant ixRxtxbufFct: natural range 0 to maxlenRxbuf-1 := 3;
	constant ixRxtxbufBc: natural range 0 to maxlenRxbuf-1 := 4;
	constant ixRxtxbufCrc1: natural range 0 to maxlenRxbuf-1 := 6;
	constant ixRxtxbufData: natural range 0 to maxlenRxbuf-1 := 8;

	signal ixRxbufCrc2: natural range 0 to maxlenRxbuf-1;

	type rxerr_t is (
		rxerrOk,
		rxerrStatus,
		rxerrCrc1,
		rxerrCrc2,
		rxerrTo
	);
	signal rxerr: rxerr_t;

	signal reqUrx: std_logic;

	signal urxlen: std_logic_vector(10 downto 0);

	constant maxlenTxbuf: natural range 0 to 56 := 56; -- 6+2+46+2

	type txbuf_t is array (0 to maxlenTxbuf-1) of std_logic_vector(7 downto 0);
	signal txbuf: txbuf_t;

	signal lenTxbuf: natural range 0 to maxlenTxbuf;

	signal ixTxbufCrc2: natural range 0 to maxlenTxbuf-1;

	signal reqUtx: std_logic;

	signal utxlen: std_logic_vector(10 downto 0);

	signal utxd, utxd_next: std_logic_vector(7 downto 0);
	-- IP sigs.cmd.cust --- IEND

	---- other
	-- IP sigs.oth.cust --- IBEGIN
	signal ackCrc: std_logic;
	signal dneCrc: std_logic;

	signal crc: std_logic_vector(15 downto 0);

	signal timeout: std_logic;

	signal ackUrx: std_logic;
	signal dneUrx: std_logic;

	signal urxd: std_logic_vector(7 downto 0);
	signal strbUrxd: std_logic;

	signal ackUtx: std_logic;
	signal dneUtx: std_logic;

	signal strbUtxd: std_logic;
	-- IP sigs.oth.cust --- IEND

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

	------------------------------------------------------------------------
	-- implementation: command execution
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- RBEGIN
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;

	reqCrc <= '1' when (stateCmd=stateCmdTxA or stateCmd=stateCmdTxB or stateCmd=stateCmdTxC or stateCmd=stateCmdTxD or stateCmd=stateCmdTxE
				or stateCmd=stateCmdRxA or stateCmd=stateCmdRxB or stateCmd=stateCmdRxC or stateCmd=stateCmdRxD or stateCmd=stateCmdRxE)
				else '0';
	
	crccaptNotFin <= '1' when (stateCmd=stateCmdTxA or stateCmd=stateCmdTxB or stateCmd=stateCmdTxC or stateCmd=stateCmdTxD
				or stateCmd=stateCmdRxA or stateCmd=stateCmdRxB or stateCmd=stateCmdRxC or stateCmd=stateCmdRxD)
				else '0';

	strbCrcd <= '1' when (stateCmd=stateCmdTxB or stateCmd=stateCmdRxC) else '0';

	reqUrx <= '1' when (stateCmd=stateCmdRxA or stateCmd=stateCmdRxB or stateCmd=stateCmdRxC or stateCmd=stateCmdRxD or stateCmd=stateCmdRxE or stateCmd=stateCmdRxF or stateCmd=stateCmdRxG) else '0';

	reqUtx <= '1' when (stateCmd=stateCmdTxA or stateCmd=stateCmdTxB or stateCmd=stateCmdTxC or stateCmd=stateCmdTxD or stateCmd=stateCmdTxE or stateCmd=stateCmdTxF or stateCmd=stateCmdTxG) else '0';

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
	-- IP impl.cmd.wiring --- REND

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- IBEGIN
		variable i: natural range 0 to maxlenRxbuf-1;
		variable j: natural range 0 to maxlenTxbuf-1;
		variable k: natural range 0 to 10;

		variable rx2NotRx1: std_logic;
		variable tx2NotTx1: std_logic;

		variable hostcrc1: std_logic_vector(15 downto 0);
		variable hostcrc2: std_logic_vector(15 downto 0);

		variable bytecnt: natural range 0 to maxlenCmdbuf-1+1+maxlenRxbuf-8-2;
		variable bytecntmax: natural range 0 to maxlenCmdbuf-1+1+maxlenRxbuf-8-2;

		variable l, m: natural range 0 to 5;

		variable x: std_logic_vector(7 downto 0);
		variable y: std_logic_vector(15 downto 0);
		-- IP impl.cmd.rising.vars --- IEND

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			dCmdbus_sig_next <= "ZZZZZZZZ";
			rdyCmdbusFromCmdinv_sig_next <= '1';
			reqCmdbusToCmdret_sig_next <= '1';
			crcd_next <= x"00";
			torestart_next <= '0';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.init --- IBEGIN
				txbuf(ixRxtxbufPc) <= x"6E";
				txbuf(ixRxtxbufStatus) <= x"00";
				txbuf(ixRxtxbufRes) <= x"00";
				txbuf(ixRxtxbufCrc1) <= x"00";
				txbuf(ixRxtxbufCrc1+1) <= x"00";
				txbuf(ixRxtxbufCrc2) <= x"00";
				txbuf(ixRxtxbufCrc2+1) <= x"00";

				stateCmd_next <= stateCmdIdle;
				-- IP impl.cmd.rising.init --- IEND

			elsif stateCmd=stateCmdIdle then
				-- IP impl.cmd.rising.idle --- IBEGIN
				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
					lenCmdbuf := 0;

					rdyCmdbusFromCmdinv_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;
				end if;
				-- IP impl.cmd.rising.idle --- IEND

			elsif stateCmd=stateCmdRecvA then
				-- IP impl.cmd.rising.recvA --- IBEGIN
				if clkCmdbus='0' then
						stateCmd_next <= stateCmdRecvB;
				end if;
				-- IP impl.cmd.rising.recvA --- IEND

			elsif stateCmd=stateCmdRecvB then
				-- IP impl.cmd.rising.recvB --- IBEGIN
				if	rdCmdbusFromCmdinv='0' then
					if cmdbuf(ixCmdbufAction)=tixDbeVActionInv then
						stateCmd_next <= stateCmdRecvG;
					else
						stateCmd_next <= stateCmdInit;
					end if;

				elsif clkCmdbus='1' then
					cmdbuf(lenCmdbuf) <= dCmdbus;
					lenCmdbuf := lenCmdbuf + 1;

					if lenCmdbuf=maxlenCmdbuf then
						j := 8; -- index for txbuf

						if invVlobNotBlob='1' then
							stateCmd_next <= stateCmdRecvC;						
						else
							stateCmd_next <= stateCmdRecvE;
						end if;
					else
						stateCmd_next <= stateCmdRecvA;
					end if;
				end if;
				-- IP impl.cmd.rising.recvB --- IEND

			elsif stateCmd=stateCmdRecvC then -- skip vblob length byte
				-- IP impl.cmd.rising.recvC --- IBEGIN
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvD;
				end if;
				-- IP impl.cmd.rising.recvC --- IEND

			elsif stateCmd=stateCmdRecvD then
				-- IP impl.cmd.rising.recvD --- IBEGIN
				if rdCmdbusFromCmdinv='0' then
					if cmdbuf(ixCmdbufAction)=tixDbeVActionInv then
						stateCmd_next <= stateCmdRecvG;
					else
						stateCmd_next <= stateCmdInit;
					end if;

				elsif clkCmdbus='1' then
					stateCmd_next <= stateCmdRecvE;
				end if;
				-- IP impl.cmd.rising.recvD --- IEND

			elsif stateCmd=stateCmdRecvE then
				-- IP impl.cmd.rising.recvE --- IBEGIN
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvF;
				end if;
				-- IP impl.cmd.rising.recvE --- IEND

			elsif stateCmd=stateCmdRecvF then
				-- IP impl.cmd.rising.recvF --- IBEGIN
				if rdCmdbusFromCmdinv='0' then
					if cmdbuf(ixCmdbufAction)=tixDbeVActionInv then
						stateCmd_next <= stateCmdRecvG;
					else
						stateCmd_next <= stateCmdInit;
					end if;

				elsif clkCmdbus='1' then
					txbuf(j) <= dCmdbus;

					j := j + 1;
				end if;
				-- IP impl.cmd.rising.recvF --- IEND

			elsif stateCmd=stateCmdRecvG then -- j points to the first byte in txbuf that is free
				-- IP impl.cmd.rising.recvG --- IBEGIN
				txbuf(ixRxtxbufFct) <= cmdbuf(ixCmdbufInvCommand);
				txbuf(ixRxtxbufBc) <= x"00";
				txbuf(ixRxtxbufBc+1) <= std_logic_vector(to_unsigned(j - 8, 8));

				txbuf(ixRxtxbufCrc1) <= x"00";
				txbuf(ixRxtxbufCrc1+1) <= x"00";

				ixTxbufCrc2 <= j;
				txbuf(j) <= x"00";
				txbuf(j+1) <= x"00";

				lenTxbuf <= j + 2;

				tx2NotTx1 := '0';

				stateCmd_next <= stateCmdPrepTx;
				-- IP impl.cmd.rising.recvG --- IEND

			elsif stateCmd=stateCmdPrepTx then
				-- IP impl.cmd.rising.prepTx --- IBEGIN
				if tx2NotTx1='0' then
					utxlen <= std_logic_vector(to_unsigned(8, 10));
					j := 0;
				else
					utxlen <= std_logic_vector(to_unsigned(lenTxbuf-8, 10));
					j := ixRxtxbufData;
				end if;

				stateCmd_next <= stateCmdTxA;
				-- IP impl.cmd.rising.prepTx --- IEND

			elsif stateCmd=stateCmdTxA then
				-- IP impl.cmd.rising.txA --- IBEGIN
				if (ackUtx='1' and ackCrc='1') then
					stateCmd_next <= stateCmdTxB;
				end if;
				-- IP impl.cmd.rising.txA --- IEND

			elsif stateCmd=stateCmdTxB then
				-- IP impl.cmd.rising.txB --- IBEGIN
				if strbUtxd='0' then
					j := j + 1;

					utxd_next <= txbuf(j);
					crcd_next <= txbuf(j);

					if ((tx2NotTx1='0' and j=ixRxtxbufCrc1) or (tx2NotTx1='1' and j=ixTxbufCrc2)) then
						k := 0;
						stateCmd_next <= stateCmdTxD;
					else
						stateCmd_next <= stateCmdTxC;
					end if;
				end if;
				-- IP impl.cmd.rising.txB --- IEND

			elsif stateCmd=stateCmdTxC then
				-- IP impl.cmd.rising.txC --- IBEGIN
				if strbUtxd='1' then
					stateCmd_next <= stateCmdTxB;
				end if;
				-- IP impl.cmd.rising.txC --- IEND

			elsif stateCmd=stateCmdTxD then
				-- IP impl.cmd.rising.txD --- IBEGIN
				if k=10 then
					stateCmd_next <= stateCmdTxE;
				end if;

				k := k + 1;
				-- IP impl.cmd.rising.txD --- IEND

			elsif stateCmd=stateCmdTxE then
				-- IP impl.cmd.rising.txE --- IBEGIN
				if dneCrc='1' then
					if tx2NotTx1='0' then
						txbuf(ixRxtxbufCrc1) <= crc(15 downto 8);
						txbuf(ixRxtxbufCrc1+1) <= crc(7 downto 0);
					else
						txbuf(ixTxbufCrc2) <= crc(15 downto 8);
						txbuf(ixTxbufCrc2+1) <= crc(7 downto 0);
					end if;

					utxD_next <= crc(15 downto 8);

					stateCmd_next <= stateCmdTxF;
				end if;
				-- IP impl.cmd.rising.txE --- IEND

			elsif stateCmd=stateCmdTxF then
				-- IP impl.cmd.rising.txF --- IBEGIN
				if strbUtxd='1' then
					stateCmd_next <= stateCmdTxG;
				end if;
				-- IP impl.cmd.rising.txF --- IEND

			elsif stateCmd=stateCmdTxG then
				-- IP impl.cmd.rising.txG --- IBEGIN
				if dneUtx='1' then
					stateCmd_next <= stateCmdTxH;

				elsif strbUtxd='0' then
					j := j + 1;

					utxD_next <= txbuf(j);

					stateCmd_next <= stateCmdTxF;
				end if;
				-- IP impl.cmd.rising.txG --- IEND

			elsif stateCmd=stateCmdTxH then
				-- IP impl.cmd.rising.txH --- IBEGIN
				if ackUtx='0' then
					if tx2NotTx1='0' then
						tx2NotTx1 := '1';
						stateCmd_next <= stateCmdPrepTx;
					else
						rxerr <= rxerrOk;

						rx2NotRx1 := '0';

						stateCmd_next <= stateCmdPrepRx;
					end if;
				end if;
				-- IP impl.cmd.rising.txH --- IEND

			elsif stateCmd=stateCmdPrepRx then
				-- IP impl.cmd.rising.prepRx --- IBEGIN
				if rx2NotRx1='0' then
					urxlen <= std_logic_vector(to_unsigned(8, 10));
					i := 0;
				else
					urxlen <= std_logic_vector(to_unsigned(lenRxbuf-8, 10));
					i := ixRxtxbufData;
				end if;

				torestart_next <= '1';

				stateCmd_next <= stateCmdRxA;
				-- IP impl.cmd.rising.prepRx --- IEND

			elsif stateCmd=stateCmdRxA then
				-- IP impl.cmd.rising.rxA --- IBEGIN
				if (ackUrx='1' and ackCrc='1') then
					torestart_next <= '1';

					stateCmd_next <= stateCmdRxB;

				elsif timeout='1' then
					rxerr <= rxerrTo;

					stateCmd_next <= stateCmdPrepRetA;

				else
					torestart_next <= '0';
				end if;
				-- IP impl.cmd.rising.rxA --- IEND

			elsif stateCmd=stateCmdRxB then
				-- IP impl.cmd.rising.rxB --- IBEGIN
				if strbUrxd='1' then
					rxbuf(i) <= urxd;
					crcd_next <= urxd;

					stateCmd_next <= stateCmdRxC;

				elsif timeout='1' then
					rxerr <= rxerrTo;

					stateCmd_next <= stateCmdPrepRetA;

				else
					torestart_next <= '0';
				end if;
				-- IP impl.cmd.rising.rxB --- IEND

			elsif stateCmd=stateCmdRxC then
				-- IP impl.cmd.rising.rxC --- IBEGIN
				if strbUrxd='0' then
					i := i + 1;

					if ((rx2NotRx1='0' and i=ixRxtxbufCrc1) or (rx2NotRx1='1' and i=ixRxbufCrc2)) then
						k := 0;
						stateCmd_next <= stateCmdRxD;
					else
						torestart_next <= '1';

						stateCmd_next <= stateCmdRxB;
					end if;
				end if;
				-- IP impl.cmd.rising.rxC --- IEND

			elsif stateCmd=stateCmdRxD then
				-- IP impl.cmd.rising.rxD --- IBEGIN
				if k=10 then
					stateCmd_next <= stateCmdRxE;
				end if;

				k := k + 1;
				-- IP impl.cmd.rising.rxD --- IEND

			elsif stateCmd=stateCmdRxE then
				-- IP impl.cmd.rising.rxE --- IBEGIN
				if dneCrc='1' then
					if rx2NotRx1='0' then
						hostcrc1 := crc;
					else
						hostcrc2 := crc;
					end if;

					torestart_next <= '1';

					stateCmd_next <= stateCmdRxF;
				end if;
				-- IP impl.cmd.rising.rxE --- IEND

			elsif stateCmd=stateCmdRxF then
				-- IP impl.cmd.rising.rxF --- IBEGIN
				if strbUrxd='1' then
					rxbuf(i) <= urxd;

					if dneUrx='1' then
						stateCmd_next <= stateCmdRxH;
					else
						stateCmd_next <= stateCmdRxG;
					end if;

				elsif timeout='1' then
					rxerr <= rxerrTo;

					stateCmd_next <= stateCmdPrepRetA;

				else
					torestart_next <= '0';
				end if;
				-- IP impl.cmd.rising.rxF --- IEND

			elsif stateCmd=stateCmdRxG then
				-- IP impl.cmd.rising.rxG --- IBEGIN
				if strbUrxd='0' then
					i := i + 1;

					torestart_next <= '1';

					stateCmd_next <= stateCmdRxF;
				end if;
				-- IP impl.cmd.rising.rxG --- IEND

			elsif stateCmd=stateCmdRxH then
				-- IP impl.cmd.rising.rxH --- IBEGIN
				if ackUrx='0' then
					if rx2NotRx1='0' then
						if rxbuf(ixRxtxbufStatus)/=x"00" then
							rxerr <= rxerrStatus;
							stateCmd_next <= stateCmdPrepRetA;

						elsif (rxbuf(ixRxtxbufCrc1)/=hostcrc1(15 downto 8) or rxbuf(ixRxtxbufCrc1+1)/=hostcrc1(7 downto 0)) then
							rxerr <= rxerrCrc1;
							stateCmd_next <= stateCmdPrepRetA;

						else
							y := rxbuf(ixRxtxbufBc) & rxbuf(ixRxtxbufBc+1);
							i := to_integer(unsigned(y)) + 8;

							ixRxbufCrc2 <= i;
							rxbuf(i) <= x"00";
							rxbuf(i+1) <= x"00";

							lenRxbuf <= i + 2;

							rx2NotRx1 := '1';
							stateCmd_next <= stateCmdPrepRx;
						end if;

					else
						if (rxbuf(ixRxbufCrc2)/=hostcrc2(15 downto 8) or rxbuf(ixRxbufCrc2+1)/=hostcrc2(7 downto 0)) then
							rxerr <= rxerrCrc2;
						end if;

						stateCmd_next <= stateCmdPrepRetA;
					end if;
				end if;
				-- IP impl.cmd.rising.rxH --- IEND

			elsif stateCmd=stateCmdPrepRetA then
				-- IP impl.cmd.rising.prepRetA --- IBEGIN
				if retVoid='1' then
					stateCmd_next <= stateCmdInit;

				else
					if rxerr=rxerrOk then
						x := rxbuf(ixRxtxbufBc+1);
						if retVblobNotBlob='0' then
							bytecntmax := to_integer(unsigned(x)) + maxlenCmdbuf-1;
						else
							bytecntmax := to_integer(unsigned(x)) + maxlenCmdbuf;
						end if;
					else
						bytecntmax := maxlenCmdbuf-1;
					end if;

					l := 0;
					m := 1;
		
					stateCmd_next <= stateCmdPrepRetB;
				end if;
				-- IP impl.cmd.rising.prepRetA --- IEND

			elsif stateCmd=stateCmdPrepRetB then
				-- IP impl.cmd.rising.prepRetB --- IBEGIN
				if l=5 then
					if cmdbuf(ixCmdbufRoute)=tixVDcx3ControllerCmdret then
						reqCmdbusToCmdret_sig_next <= '1';
					end if;
					
					stateCmd_next <= stateCmdWaitSend;

				else
					if l=ixCmdbufRoute then
						if cmdbuf(m)=x"00" then
							x := tixVDcx3ControllerCmdret;
						else
							x := cmdbuf(m);
						end if;
					elsif l=ixCmdbufRoute+3 then
						x := x"00";
					elsif l=ixCmdbufAction then
						x := tixDbeVActionRet;
					else
						x := cmdbuf(m);
					end if;

					stateCmd_next <= stateCmdPrepRetC;
				end if; 
				-- IP impl.cmd.rising.prepRetB --- IEND

			elsif stateCmd=stateCmdPrepRetC then
				-- IP impl.cmd.rising.prepRetC --- IBEGIN
				cmdbuf(l) <= x;
				
				if l/=ixCmdbufAction then
					m := m + 1;
				end if;
				l := l + 1;
				
				stateCmd_next <= stateCmdPrepRetB;
				-- IP impl.cmd.rising.prepRetC --- IEND

			elsif stateCmd=stateCmdWaitSend then
				if (wrCmdbusToCmdret='1' and clkCmdbus='1') then
					dCmdbus_sig_next <= cmdbuf(0);
					bytecnt := 1; -- byte count made available to dCmdbus
					
					stateCmd_next <= stateCmdSendA;
				end if;

			elsif stateCmd=stateCmdSendA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdSendB;
				end if;
			
			elsif stateCmd=stateCmdSendB then
				if clkCmdbus='1' then
					if bytecnt<(maxlenCmdbuf-1) then
						dCmdbus_sig_next <= cmdbuf(bytecnt);

					elsif rxerr=rxerrOk then
						if retVblobNotBlob='0' then
							if bytecnt=(maxlenCmdbuf-1) then
								dCmdbus_sig_next <= rxbuf(ixRxtxbufBc+1);
							else
								dCmdbus_sig_next <= rxbuf(bytecnt-maxlenCmdbuf+8);
							end if;
						else
							dCmdbus_sig_next <= rxbuf(bytecnt-maxlenCmdbuf-1+8);
						end if;
					end if;

					bytecnt := bytecnt + 1;

					if bytecnt=bytecntmax then
						reqCmdbusToCmdret_sig_next <= '0';
						
						stateCmd_next <= stateCmdSendC;
					
					else
						stateCmd_next <= stateCmdSendA;
					end if;
				end if;

			elsif stateCmd=stateCmdSendC then
				if wrCmdbusToCmdret='0' then
					stateCmd_next <= stateCmdInit;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.cmd.rising --- END

	-- IP impl.cmd.falling --- BEGIN
	process (mclk)
		-- IP impl.cmd.falling.vars --- INSERT
	begin
		if falling_edge(mclk) then
			stateCmd <= stateCmd_next;
			crcd <= crcd_next;
			torestart <= torestart_next;
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
	-- implementation: other
	------------------------------------------------------------------------
	
	-- IP impl.oth.cust --- INSERT

end Lwirif;
