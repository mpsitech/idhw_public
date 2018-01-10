-- file Adxl.vhd
-- Adxl controller implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 16 Aug 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Adxl is
	generic (
		fMclk: natural range 1 to 1000000;

		res: std_logic_vector(1 downto 0) := "01";
		rate: std_logic_vector(3 downto 0) := "1010";

		Tsmp: natural range 0 to 10 to 10000 := 100 -- in tkclk clocks
	);
	port (
		reset: in std_logic;

		mclk: in std_logic;

		tkclk: in std_logic;

		clkCmdbus: in std_logic;

		dCmdbus: inout std_logic_vector(7 downto 0);

		reqCmdbusToCmdret: out std_logic;
		wrCmdbusToCmdret: in std_logic;

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		nss: out std_logic;
		sclk: out std_logic;
		mosi: out std_logic;
		miso: in std_logic
	);
end Adxl;

architecture Adxl of Adxl is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Spimaster_v1_0 is
		generic (
			fMclk: natural range 0 to 1000000;
	
			cpol: std_logic := '0';
			cpha: std_logic := '0';

			nssByteNotXfer: std_logic := '0';

			fSclk: natural range 0 to 50000;
			Nstop: natural range 1 to 8 := 1
		);
		port (
			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic;

			reset: in std_logic;

			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			len: in std_logic_vector(10 downto 0);

			send: in std_logic_vector(7 downto 0);
			strbSend: out std_logic;

			recv: out std_logic_vector(7 downto 0);
			strbRecv: out std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- command execution
	type stateCmd_t is (
		stateCmdInit,
		stateCmdIdle,
		stateCmdRecvA, stateCmdRecvB,
		stateCmdInvGetX,
		stateCmdInvGetY,
		stateCmdInvGetZ,
		stateCmdPrepRetGetAx,
		stateCmdPrepRetGetAy,
		stateCmdPrepRetGetAz,
		stateCmdWaitSend, stateCmdSendA, stateCmdSendB, stateCmdSendC
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	constant tixDbeVActionInv: std_logic_vector(7 downto 0) := x"00";
	constant tixDbeVActionRet: std_logic_vector(7 downto 0) := x"80";

	constant tixVDcx3ControllerCmdinv: std_logic_vector(7 downto 0) := x"01";
	constant tixVDcx3ControllerCmdret: std_logic_vector(7 downto 0) := x"02";

	constant maxlenCmdbuf: natural range 0 to 11 := 11;

	type cmdbuf_t is array (0 to maxlenCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	constant ixCmdbufRoute: natural range 0 to maxlenCmdbuf-1 := 0;
	constant ixCmdbufAction: natural range 0 to maxlenCmdbuf-1 := 4;
	constant ixCmdbufCref: natural range 0 to maxlenCmdbuf-1 := 5;
	constant ixCmdbufInvCommand: natural range 0 to maxlenCmdbuf-1 := 9;

	-- inv: getAx, getAy, getAz
	-- ret: getX, getY, getZ

	constant tixVCommandGetX: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvGetX: natural range 0 to maxlenCmdbuf := 10;
	constant lenCmdbufRetGetX: natural range 0 to maxlenCmdbuf := 11;
	constant ixCmdbufRetGetXAx: natural range 0 to maxlenCmdbuf-1 := 9;

	constant tixVCommandGetY: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvGetY: natural range 0 to maxlenCmdbuf := 10;
	constant lenCmdbufRetGetY: natural range 0 to maxlenCmdbuf := 11;
	constant ixCmdbufRetGetYAy: natural range 0 to maxlenCmdbuf-1 := 9;

	constant tixVCommandGetZ: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvGetZ: natural range 0 to maxlenCmdbuf := 10;
	constant lenCmdbufRetGetZ: natural range 0 to maxlenCmdbuf := 11;
	constant ixCmdbufRetGetZAz: natural range 0 to maxlenCmdbuf-1 := 9;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;
	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- main operation
	type stateOp_t is (
		stateOpSetRes,
		stateOpSetRate,
		stateOpSetA, stateOpSetB, stateOpSetC, stateOpSetD,
		stateOpReady,
		stateOpGetA, stateOpGetB, stateOpGetC
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpSetRes;

	signal Tsmprun: std_logic;
	
	signal ax, ax_next: std_logic_vector(15 downto 0) := x"00";
	signal ay, ay_next: std_logic_vector(15 downto 0) := x"00";
	signal az, az_next: std_logic_vector(15 downto 0) := x"00";

	signal reqSpi, reqSpi_next: std_logic;

	signal spilen: std_logic_vector(10 downto 0);

	signal spisend, spisend_next: std_logic_vector(7 downto 0);

	-- IP sigs.op.cust --- INSERT

	---- sample clock (tsmp)
	type stateTsmp_t is (
		stateTsmpInit,
		stateTsmpReady,
		stateTsmpRunA, stateTsmpRunB, stateTsmpRunC
	);
	signal stateTsmp, stateTsmp_next: stateTsmp_t := stateTsmpInit;

	signal strbTsmp: std_logic;

	-- IP sigs.tsmp.cust --- INSERT

	---- other
	signal dneSpi: std_logic;

	signal strbSpisend: std_logic;

	signal spirecv: std_logic_vector(10 downto 0);
	signal strbSpirecv: std_logic;

	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	mySpi : Spimaster_v1_0
		generic map (
			fMclk => fMclk,

			cpol => '1',
			cpha => '1',

			nssByteNotXfer => '0',

			fSclk => 5000,
			Nstop => 1
		)
		port map (
			nss => nss,
			sclk => sclk,
			mosi => mosi,
			miso => miso,

			reset => reset,

			mclk => mclk,

			req => reqSpi,
			ack => open,
			dne => dneSpi,

			len => spilen,

			send => spisend,
			strbSend => strbSpisend,

			recv => spirecv,
			strbRecv => strbSpirecv
		);

	------------------------------------------------------------------------
	-- implementation: command execution
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- BEGIN
		variable lenCmdbuf: natural range 0 to maxlenCmdbuf;
		variable bytecnt: natural range 0 to maxlenCmdbuf;
		-- IP impl.cmd.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			dCmdbus_sig_next <= "ZZZZZZZZ";
			reqCmdbusToCmdret_sig_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				stateCmd_next <= stateCmdIdle;

			elsif stateCmd=stateCmdIdle then
				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
					lenCmdbuf := 0;

					rdyCmdbusFromCmdinv_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;

				end if;

			elsif stateCmd=stateCmdRecvA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvB then
				if rdCmdbusFromCmdinv='0' then
					if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetX and lenCmdbuf=lenCmdbufInvGetX) then
						stateCmd_next <= stateCmdInvGetX;
					elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetY and lenCmdbuf=lenCmdbufInvGetY) then
						stateCmd_next <= stateCmdInvGetY;
					elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetZ and lenCmdbuf=lenCmdbufInvGetZ) then
						stateCmd_next <= stateCmdInvGetZ;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				elsif clkCmdbus='1' then
					cmdbuf(lenCmdbuf) <= dCmdbus;
					lenCmdbuf := lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvA;
				end if;

			elsif stateCmd=stateCmdInvGetX then
				-- IP impl.cmd.rising.invGetX --- INSERT

			elsif stateCmd=stateCmdInvGetY then
				-- IP impl.cmd.rising.invGetY --- INSERT

			elsif stateCmd=stateCmdInvGetZ then
				-- IP impl.cmd.rising.invGetZ --- INSERT

			elsif stateCmd=stateCmdPrepRetGetX then
				-- IP impl.cmd.rising.prepRetGetAx --- IBEGIN
				cmdbuf(ixCmdbufRetGetAxAx) <= ax(15 downto 8);
				cmdbuf(ixCmdbufRetGetAxAx+1) <= ax(7 downto 0);
				-- IP impl.cmd.rising.prepRetGetAx --- IEND

			elsif stateCmd=stateCmdPrepRetGetY then
				-- IP impl.cmd.rising.prepRetGetAy --- IBEGIN
				cmdbuf(ixCmdbufRetGetAyAy) <= ay(15 downto 8);
				cmdbuf(ixCmdbufRetGetAyAy+1) <= ay(7 downto 0);
				-- IP impl.cmd.rising.prepRetGetAy --- IEND

			elsif stateCmd=stateCmdPrepRetGetZ then
				-- IP impl.cmd.rising.prepRetGetAz --- IBEGIN
				cmdbuf(ixCmdbufRetGetAzAz) <= az(15 downto 8);
				cmdbuf(ixCmdbufRetGetAzAz+1) <= az(7 downto 0);
				-- IP impl.cmd.rising.prepRetGetAz --- IEND

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
					dCmdbus_sig_next <= cmdbuf(bytecnt);

					bytecnt := bytecnt + 1;

					if bytecnt=lenCmdbuf then
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
	begin
		if falling_edge(mclk) then
			stateCmd <= stateCmd_next;
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
	-- implementation: main operation
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	Tsmprun <= '1' when (stateOp=stateOpRun or stateOp=stateOpGetA or stateOp=stateOpGetB or stateOp=stateOpGetC) else '0';
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		constant lenRxbuf: natural := 7;
		type rxbuf_t: array(0 to lenRxbuf-1) of std_logic_vector(7 downto 0);
		variable rxbuf: rxbuf_t;

		constant lenTxbuf: natural := 2;
		type txbuf_t: array(0 to lenTxbuf-1) of std_logic_vector(7 downto 0);
		variable txbuf: txbuf_t;

		constant ixTxbufCmd: natural := 0;

		constant cmdSetRes: std_logic_vector(7 downto 0) := x"31";
		constant ixTxbufSetResRes: natural := 1;
		
		constant cmdSetRate: std_logic_vector(7 downto 0) := x"2C";
		constant ixTxbufSetRateRate: natural := 1;

		constant cmdGetData: std_logic_vector(7 downto 0) := x"F2";
		constant ixRxbufGetDataAx: natural := 1;
		constant ixRxbufGetDataAy: natural := 3;
		constant ixRxbufGetDataAz: natural := 5;
		
		-- settings (write): DATA_FORMAT/RANGE 0x31 and BW_RATE 0x2C (2 bytes)
		-- 00-110001 RRRRRRRR and 00-101100 BBBBBBBB

		-- RRRRRRRR e.g. 0000 0 0 RR (01 for 4g)
		-- BBBBBBBB e.g. 000 0 BBBB (400Hz/1100 for 100Hz fsmp)
		
		-- data: burst read 0x32 (7 bytes)
		-- 11-110010 6xDDDDDDDD

		variable bytecnt: natural range 0 to maxlenRxbuf;

		variable x: std_logic_vector(15 downto 0);
		variable y: std_logic_vector(15 downto 0);
		variable z: std_logic_vector(15 downto 0);
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- BEGIN
			stateOp_next <= stateOpSetRes;
			ax_next <= (others => '0');
			ay_next <= (others => '0');
			az_next <= (others => '0');
			reqSpi_next <= '0';
			spisend_next <= (others => '0');
			-- IP impl.op.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateOp=stateOpSetRes then
				-- IP impl.op.rising.setRes --- IBEGIN
				txbuf(ixRxtxbufCmd) := cmdSetRes;
				txbuf(ixTxbufSetResRes) := "000000" & res;

				spilen <= std_logic_vector(to_unsigned(lenTxbuf, 11));

				bytecnt := 0;
				-- IP impl.op.rising.setRes --- IEND

				stateOp_next <= stateOpSetC;

			elsif stateOp=stateOpSetRate then
				-- IP impl.op.rising.setRate --- IBEGIN
				txbuf(ixTxbufCmd) := cmdSetRate;
				txbuf(ixTxbufSetRateRate) := "0000" & rate;

				spilen <= std_logic_vector(to_unsigned(lenTxbuf, 11));

				bytecnt := 0;
				-- IP impl.op.rising.setRate --- IEND

				stateOp_next <= stateOpSetC;

			elsif stateOp=stateOpSetA then
				if dneSpi='1' then
					reqSpi_next <= '0'; -- IP impl.op.rising.setA --- ILINE

					if txbuf(ixTxbufCmd)=cmdSetRes then
						stateOp_next <= stateOpSetRate;
					else
						stateOp_next <= stateOpReady;
					end if;
				else
					stateOp_next <= stateOpSetB;
				end if;

			elsif stateOp=stateOpSetB then
				bytecnt := bytecnt + 1; -- IP impl.op.rising.setB --- ILINE
				stateOp_next <= stateOpSetC;

			elsif stateOp=stateOpSetC then
				-- IP impl.op.rising.setC --- IBEGIN
				reqSpi_next <= '1';

				spisend_next <= txbuf(bytecnt); -- reason for reqSpi_next
				-- IP impl.op.rising.setC --- IEND

				stateOp_next <= stateOpSetD;

			elsif stateOp=stateOpSetD then
				if strbSpisend='1' then
					stateOp_next <= stateOpSetA;
				end if;

			elsif stateOp=stateOpReady then
				if strbTsmp='1' then
					-- IP impl.op.rising.ready --- IBEGIN
					reqSpi_next <= '1';

					spilen <= std_logic_vector(to_unsigned(lenTxbuf, 11));

					spisend_next <= cmdGetData;

					bytecnt := 0;
					-- IP impl.op.rising.ready --- IEND

					stateOp_next <= stateOpGetA;
				end if;

			elsif stateOp=stateOpGetA then
				if dneSpi='1' then
					-- IP impl.op.rising.getA.done --- IBEGIN
					reqSpi_next <= '0';

					x := rxbuf(ixRxbufGetDataAx) & rxbuf(ixRxbufGetDataAx+1);
					ax_next <= x;
					
					y := rxbuf(ixRxbufGetDataAy) & rxbuf(ixRxbufGetDataAy+1);
					ay_next <= y;
					
					z := rxbuf(ixRxbufGetDataAz) & rxbuf(ixRxbufGetDataAz+1);
					az_next <= z;
					-- IP impl.op.rising.getA.done --- IEND

					stateOp_next <= stateOpReady;

				elsif strbSpirecv='0' then
					stateOp_next <= stateOpGetB;
				end if;

			elsif stateOp=stateOpGetB then
				if strbSpirecv='1' then
					rxbuf(bytecnt) := spirecv; -- IP impl.op.rising.getB.copy --- ILINE
					stateOp_next <= stateOpGetC;
				end if;

			elsif stateOp=stateOpGetC then
				bytecnt := bytecnt + 1; -- IP impl.op.rising.getC --- ILINE
				stateOp_next <= stateOpGetA;
			end if;
		end if;	
	end process;
	-- IP impl.op.rising --- END

	-- IP impl.op.falling --- BEGIN
	process (mclk)
		-- IP impl.op.falling.vars --- INSERT
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			ax <= ax_next;
			ay <= ay_next;
			az <= az_next;
			reqSpi <= reqSpi_next;
			spisend <= spisend_next;
		end if;
	end process;
	-- IP impl.op.falling --- END
	
	------------------------------------------------------------------------
	-- implementation: sample clock
	------------------------------------------------------------------------

	-- IP impl.tsmp.wiring --- BEGIN
	strbTsmp <= '1' when (tkclk='1' and stateTsmp=stateTsmpRunA) else '0';
	-- IP impl.tsmp.wiring --- END

	-- IP impl.tsmp.rising --- BEGIN
	process (reset, mclk, stateTsmp)
		-- IP impl.tsmp.rising.vars --- RBEGIN
		variable i: natural range 0 to Tsmp;
		-- IP impl.tsmp.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.tsmp.rising.asyncrst --- BEGIN
			stateTsmp_next <= stateTsmpInit;
			-- IP impl.tsmp.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateTsmp=stateTsmpInit or Tsmprun='0') then
				if Tsmprun='0' then
					stateTsmp_next <= stateTsmpInit;
				else
					stateTsmp_next <= stateTsmpReady;
				end if;

			elsif stateTsmp=stateTsmpReady then
				if tkclk='0' then
					i := 0; -- IP impl.tsmp.rising.ready.initrun --- ILINE
					stateTsmp_next <= stateTsmpRunA;
				end if;

			elsif stateTsmp=stateTsmpRunA then
				if tkclk='1' then
					stateTsmp_next <= stateTsmpRunC;
				end if;

			elsif stateTsmp=stateTsmpRunB then
				if tkclk='1' then
					stateTsmp_next <= stateTsmpRunC;
				end if;

			elsif stateTsmp=stateTsmpRunC then
				if tkclk='0' then
					i := i + 1; -- IP impl.tsmp.rising.runC.inc --- ILINE
					if i=Tsmp then
						i := 0; -- IP impl.tsmp.rising.runC.initrun --- ILINE
						stateTsmp_next <= stateTsmpRunA;
					else
						stateTsmp_next <= stateTsmpRunB;
					end if;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.tsmp.rising --- END

	-- IP impl.tsmp.falling --- BEGIN
	process (mclk)
	begin
		if falling_edge(mclk) then
			stateTsmp <= stateTsmp_next;
		end if;
	end process;
	-- IP impl.tsmp.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	-- IP impl.oth.cust --- INSERT

end Adxl;
