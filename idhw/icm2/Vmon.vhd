-- file Vmon.vhd
-- Vmon controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

entity Vmon is
	generic (
		Tsmp: natural range 10 to 10000 := 100; -- in tkclk periods
		fMclk: natural range 1 to 1000000
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: inout std_logic_vector(7 downto 0);

		rdyCmdbusFromAcq: out std_logic;
		rdCmdbusFromAcq: in std_logic;

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		rdyCmdbusFromTemp: out std_logic;
		rdCmdbusFromTemp: in std_logic;

		reqCmdbusToAcq: out std_logic;
		wrCmdbusToAcq: in std_logic;

		reqCmdbusToCmdret: out std_logic;
		wrCmdbusToCmdret: in std_logic;

		reqCmdbusToTemp: out std_logic;
		wrCmdbusToTemp: in std_logic;

		nss: out std_logic;
		sclk: out std_logic;
		mosi: out std_logic;
		miso: in std_logic
	);
end Vmon;

architecture Vmon of Vmon is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

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

	---- command execution (cmd)
	type stateCmd_t is (
		stateCmdInit,
		stateCmdEmpty,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE, stateCmdRecvF,
		stateCmdFullA, stateCmdFullB,
		stateCmdSendA, stateCmdSendB, stateCmdSendC,
		stateCmdPrepRetGetVref,
		stateCmdPrepRetGetVdd,
		stateCmdPrepRetGetVtec,
		stateCmdPrepRetGetNtc,
		stateCmdPrepRetGetPt
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: getVref, getVdd, getVtec, getNtc, getPt
	-- ret/newret: getVref, getVdd, getVtec, getNtc, getPt

	constant sizeCmdbuf: natural := 11;

	constant tixVCommandGetVref: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvGetVref: natural := 10;
	constant lenCmdbufRetGetVref: natural := 11;
	constant ixCmdbufRetGetVrefVref: natural := 9;

	constant tixVCommandGetVdd: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvGetVdd: natural := 10;
	constant lenCmdbufRetGetVdd: natural := 11;
	constant ixCmdbufRetGetVddVdd: natural := 9;

	constant tixVCommandGetVtec: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvGetVtec: natural := 10;
	constant lenCmdbufRetGetVtec: natural := 11;
	constant ixCmdbufRetGetVtecVtec: natural := 9;

	constant tixVCommandGetNtc: std_logic_vector(7 downto 0) := x"03";
	constant lenCmdbufInvGetNtc: natural := 10;
	constant lenCmdbufRetGetNtc: natural := 11;
	constant ixCmdbufRetGetNtcNtc: natural := 9;

	constant tixVCommandGetPt: std_logic_vector(7 downto 0) := x"04";
	constant lenCmdbufInvGetPt: natural := 10;
	constant lenCmdbufRetGetPt: natural := 11;
	constant ixCmdbufRetGetPtPt: natural := 9;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal rdyCmdbusFromAcq_sig, rdyCmdbusFromAcq_sig_next: std_logic;
	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal rdyCmdbusFromTemp_sig, rdyCmdbusFromTemp_sig_next: std_logic;
	signal reqCmdbusToAcq_sig, reqCmdbusToAcq_sig_next: std_logic;
	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;
	signal reqCmdbusToTemp_sig, reqCmdbusToTemp_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- main operation (op)
	type stateOp_t is (
		stateOpReady,
		stateOpGetA, stateOpGetB, stateOpGetC, stateOpGetD
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpReady;

	signal adcval_next: std_logic_vector(11 downto 0);
	signal strbAdcval_next: std_logic;

	signal ch: natural range 0 to 5;
	signal spilen: std_logic_vector(10 downto 0);
	signal spisend, spisend_next: std_logic_vector(7 downto 0);

	-- IP sigs.op.cust --- IBEGIN
	signal Vref: std_logic_vector(11 downto 0) := "000000000000";
	signal Vdd: std_logic_vector(11 downto 0) := "000000000000";
	signal Vtec: std_logic_vector(11 downto 0) := "000000000000";
	signal Ntc: std_logic_vector(11 downto 0) := "000000000000";
	signal Pt: std_logic_vector(11 downto 0) := "000000000000";
	-- IP sigs.op.cust --- IEND

	---- sample clock (tsmp)
	type stateTsmp_t is (
		stateTsmpReady,
		stateTsmpRunA, stateTsmpRunB, stateTsmpRunC
	);
	signal stateTsmp, stateTsmp_next: stateTsmp_t := stateTsmpReady;

	signal strbTsmp: std_logic;

	-- IP sigs.tsmp.cust --- INSERT

	---- mySpi
	signal spirecv: std_logic_vector(7 downto 0);
	signal strbSpirecv: std_logic;

	---- handshake
	-- op to mySpi
	signal reqSpi: std_logic;
	signal dneSpi: std_logic;

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	mySpi : Spimaster_v1_0
		generic map (
			fMclk => fMclk,

			cpol => '0',
			cpha => '0',

			fSclk => 2000000
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
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromAcq <= rdyCmdbusFromAcq_sig;
	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	rdyCmdbusFromTemp <= rdyCmdbusFromTemp_sig;
	reqCmdbusToAcq <= reqCmdbusToAcq_sig;
	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	reqCmdbusToTemp <= reqCmdbusToTemp_sig;
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
			rdyCmdbusFromAcq_sig_next <= '1';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			rdyCmdbusFromTemp_sig_next <= '1';
			reqCmdbusToAcq_sig_next <= '0';
			reqCmdbusToCmdret_sig_next <= '0';
			reqCmdbusToTemp_sig_next <= '0';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				rdyCmdbusFromAcq_sig_next <= '1';
				rdyCmdbusFromCmdinv_sig_next <= '1';
				rdyCmdbusFromTemp_sig_next <= '1';
				reqCmdbusToAcq_sig_next <= '0';
				reqCmdbusToCmdret_sig_next <= '0';
				reqCmdbusToTemp_sig_next <= '0';

				lenCmdbuf := 0;
				i := 0;
				j := 0;
				x := x"00";
				bytecnt := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if ((rdCmdbusFromAcq='1' or rdCmdbusFromCmdinv='1' or rdCmdbusFromTemp='1') and clkCmdbus='1') then
					rdyCmdbusFromAcq_sig_next <= '0';
					rdyCmdbusFromCmdinv_sig_next <= '0';
					rdyCmdbusFromTemp_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;
				end if;

			elsif stateCmd=stateCmdRecvA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvB then
				if clkCmdbus='1' then
					if (rdCmdbusFromAcq='0' and rdCmdbusFromCmdinv='0' and rdCmdbusFromTemp='0') then
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
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetVref and lenCmdbuf=lenCmdbufInvGetVref) then
					stateCmd_next <= stateCmdPrepRetGetVref;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetVdd and lenCmdbuf=lenCmdbufInvGetVdd) then
					stateCmd_next <= stateCmdPrepRetGetVdd;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetVtec and lenCmdbuf=lenCmdbufInvGetVtec) then
					stateCmd_next <= stateCmdPrepRetGetVtec;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetNtc and lenCmdbuf=lenCmdbufInvGetNtc) then
					stateCmd_next <= stateCmdPrepRetGetNtc;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetPt and lenCmdbuf=lenCmdbufInvGetPt) then
					stateCmd_next <= stateCmdPrepRetGetPt;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullA then
				if cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerAcq then
					reqCmdbusToAcq_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerCmdret then
					reqCmdbusToCmdret_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerTemp then
					reqCmdbusToTemp_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullB then
				if ((wrCmdbusToAcq='1' or wrCmdbusToCmdret='1' or wrCmdbusToTemp='1') and clkCmdbus='1') then
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
							reqCmdbusToAcq_sig_next <= '0';
							reqCmdbusToCmdret_sig_next <= '0';
							reqCmdbusToTemp_sig_next <= '0';
						end if;

						stateCmd_next <= stateCmdSendA;
					end if;
				end if;

			elsif stateCmd=stateCmdSendC then
				if (wrCmdbusToAcq='0' and wrCmdbusToCmdret='0' and wrCmdbusToTemp='0') then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdPrepRetGetVref then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				-- IP impl.cmd.rising.prepRetGetVref --- IBEGIN
				cmdbuf(ixCmdbufRetGetVrefVref) <= "0000" & Vref(11 downto 8);
				cmdbuf(ixCmdbufRetGetVrefVref+1) <= Vref(7 downto 0);
				-- IP impl.cmd.rising.prepRetGetVref --- IEND

				lenCmdbuf := lenCmdbufRetGetVref;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepRetGetVdd then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				-- IP impl.cmd.rising.prepRetGetVdd --- IBEGIN
				cmdbuf(ixCmdbufRetGetVddVdd) <= "0000" & Vdd(11 downto 8);
				cmdbuf(ixCmdbufRetGetVddVdd+1) <= Vdd(7 downto 0);
				-- IP impl.cmd.rising.prepRetGetVdd --- IEND

				lenCmdbuf := lenCmdbufRetGetVdd;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepRetGetVtec then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				-- IP impl.cmd.rising.prepRetGetVtec --- IBEGIN
				cmdbuf(ixCmdbufRetGetVtecVtec) <= "0000" & Vtec(11 downto 8);
				cmdbuf(ixCmdbufRetGetVtecVtec+1) <= Vtec(7 downto 0);
				-- IP impl.cmd.rising.prepRetGetVtec --- IEND

				lenCmdbuf := lenCmdbufRetGetVtec;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepRetGetNtc then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				-- IP impl.cmd.rising.prepRetGetNtc --- IBEGIN
				cmdbuf(ixCmdbufRetGetNtcNtc) <= "0000" & Ntc(11 downto 8);
				cmdbuf(ixCmdbufRetGetNtcNtc+1) <= Ntc(7 downto 0);
				-- IP impl.cmd.rising.prepRetGetNtc --- IEND

				lenCmdbuf := lenCmdbufRetGetNtc;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepRetGetPt then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				-- IP impl.cmd.rising.prepRetGetPt --- IBEGIN
				cmdbuf(ixCmdbufRetGetPtPt) <= "0000" & Pt(11 downto 8);
				cmdbuf(ixCmdbufRetGetPtPt+1) <= Pt(7 downto 0);
				-- IP impl.cmd.rising.prepRetGetPt --- IEND

				lenCmdbuf := lenCmdbufRetGetPt;

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
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			dCmdbus_sig <= dCmdbus_sig_next;
			rdyCmdbusFromAcq_sig <= rdyCmdbusFromAcq_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			rdyCmdbusFromTemp_sig <= rdyCmdbusFromTemp_sig_next;
			reqCmdbusToAcq_sig <= reqCmdbusToAcq_sig_next;
			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
			reqCmdbusToTemp_sig <= reqCmdbusToTemp_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	reqSpi <= '0' when (stateOp=stateOpGetB or stateOp=stateOpGetC or stateOp=stateOpGetD) else '1';
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		variable bytecnt: natural range 0 to 3;
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- RBEGIN
			stateOp_next <= stateOpReady;
			adcval_next <= (others => '0');
			strbAdcval_next <= '0';
			spisend_next <= (others => '0');
			ch <= 0;
			-- IP impl.op.rising.asyncrst --- REND

		elsif rising_edge(mclk) then
			if stateOp=stateOpReady then
				if strbTsmp='1' then
					ch <= 0; -- IP impl.op.rising.ready.initch --- ILINE

					stateOp_next <= stateOpGetA;
				end if;

			elsif stateOp=stateOpGetA then
				if ch=5 then
					stateOp_next <= stateOpReady;

				else
					-- IP impl.op.rising.getA.initspi --- IBEGIN
					spilen <= std_logic_vector(to_unsigned(3, 11));

					spisend_next <= "1" & std_logic_vector(to_unsigned(ch, 3)) & "1111";

					bytecnt := 0;
					-- IP impl.op.rising.getA.initspi --- IEND

					stateOp_next <= stateOpGetB;
				end if;

			elsif stateOp=stateOpGetB then
				if dneSpi='1' then
					ch <= ch + 1; -- IP impl.op.rising.getB.incch --- ILINE

					stateOp_next <= stateOpGetA;

				elsif strbSpirecv='0' then
					stateOp_next <= stateOpGetC;
				end if;

			elsif stateOp=stateOpGetC then
				if strbSpirecv='1' then
					-- IP impl.op.rising.getC --- IBEGIN
					spisend_next <= (others => '0');

					if bytecnt=1 then
						adcval_next(11 downto 8) <= spirecv(3 downto 0);
					elsif bytecnt=2 then
						adcval_next(7 downto 0) <= spirecv;
						strbAdcval_next <= '1';
					end if;
					-- IP impl.op.rising.getC --- IEND

					stateOp_next <= stateOpGetD;
				end if;

			elsif stateOp=stateOpGetD then
				-- IP impl.op.rising.getD --- IBEGIN
				strbAdcval_next <= '0';

				bytecnt := bytecnt + 1;
				-- IP impl.op.rising.getD --- IEND

				stateOp_next <= stateOpGetB;
			end if;
		end if;
	end process;
	-- IP impl.op.rising --- END

	-- IP impl.op.falling --- RBEGIN
	process (mclk)
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			if strbAdcval_next='1' then
				if ch=0 then
					Vref <= adcval_next;
				elsif ch=1 then
					Vdd <= adcval_next;
				elsif ch=2 then
					Vtec <= adcval_next;
				elsif ch=3 then
					Ntc <= adcval_next;
				elsif ch=4 then
					Pt <= adcval_next;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.op.falling --- REND

	------------------------------------------------------------------------
	-- implementation: sample clock (tsmp)
	------------------------------------------------------------------------

	-- IP impl.tsmp.wiring --- RBEGIN
	strbTsmp <= '1' when (tkclk='1' and stateTsmp=stateTsmpRunA) else '0';
	-- IP impl.tsmp.wiring --- REND

	-- IP impl.tsmp.rising --- BEGIN
	process (reset, mclk, stateTsmp)
		-- IP impl.tsmp.rising.vars --- RBEGIN
		variable i: natural range 0 to Tsmp;
		-- IP impl.tsmp.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.tsmp.rising.asyncrst --- BEGIN
			stateTsmp_next <= stateTsmpReady;
			-- IP impl.tsmp.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateTsmp=stateTsmpReady then
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
		-- IP impl.tsmp.falling.vars --- BEGIN
		-- IP impl.tsmp.falling.vars --- END
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

end Vmon;


