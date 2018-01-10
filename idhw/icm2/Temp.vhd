-- file Temp.vhd
-- Temp controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

entity Temp is
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: inout std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		reqCmdbusToFan: out std_logic;
		wrCmdbusToFan: in std_logic;

		reqCmdbusToVmon: out std_logic;
		wrCmdbusToVmon: in std_logic;

		reqCmdbusToVset: out std_logic;
		wrCmdbusToVset: in std_logic;

		rdyCmdbusFromVmon: out std_logic;
		rdCmdbusFromVmon: in std_logic;

		acqprep: in std_logic;
		fanrng: in std_logic;
		ok: out std_logic
	);
end Temp;

architecture Temp of Temp is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Div_v3_0_15by11 is
		port (
			clk: in std_logic;
			ce: in std_logic;
			rfd: out std_logic;
			dividend: in std_logic_vector(14 downto 0);
			divisor: in std_logic_vector(10 downto 0);
			quotient: out std_logic_vector(14 downto 0);
			fractional: out std_logic_vector(10 downto 0)
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
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE,
		stateCmdFullA, stateCmdFullB,
		stateCmdSendA, stateCmdSendB, stateCmdSendC,
		stateCmdPrepInvFanSetRng,
		stateCmdPrepInvVmonGetNtc,
		stateCmdPrepInvVmonGetPt,
		stateCmdPrepInvVsetSetVtec
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: setFan, setRng, setTrgNtc
	-- external inv: fan.setRng, vmon.getNtc, vmon.getPt, vset.setVtec
	-- external ret/newret: vmon.getNtc, vmon.getPt

	constant sizeCmdbuf: natural := 15;

	constant tixVFanmodeOff: std_logic_vector(7 downto 0) := x"00";
	constant tixVFanmodeOffacq: std_logic_vector(7 downto 0) := x"01";
	constant tixVFanmodeOn: std_logic_vector(7 downto 0) := x"02";

	constant tixVCommandSetFan: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvSetFan: natural := 15;
	constant ixCmdbufInvSetFanTixVFanmode: natural := 10;
	constant ixCmdbufInvSetFanPtlow: natural := 11;
	constant ixCmdbufInvSetFanPthigh: natural := 13;

	constant tixVCommandSetRng: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvSetRng: natural := 11;
	constant ixCmdbufInvSetRngRng: natural := 10;

	constant tixVCommandSetTrgNtc: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvSetTrgNtc: natural := 12;
	constant ixCmdbufInvSetTrgNtcNtc: natural := 10;

	constant tixVIcm2FanCommandSetRng: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvFanSetRng: natural := 11;
	constant ixCmdbufInvFanSetRngRng: natural := 10;

	constant tixVIcm2VmonCommandGetNtc: std_logic_vector(7 downto 0) := x"03";
	constant lenCmdbufInvVmonGetNtc: natural := 10;
	constant lenCmdbufRetVmonGetNtc: natural := 11;
	constant ixCmdbufRetVmonGetNtcNtc: natural := 9;

	constant tixVIcm2VmonCommandGetPt: std_logic_vector(7 downto 0) := x"04";
	constant lenCmdbufInvVmonGetPt: natural := 10;
	constant lenCmdbufRetVmonGetPt: natural := 11;
	constant ixCmdbufRetVmonGetPtPt: natural := 9;

	constant tixVIcm2VsetCommandSetVtec: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvVsetSetVtec: natural := 12;
	constant ixCmdbufInvVsetSetVtecVtec: natural := 10;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal reqCmdbusToFan_sig, reqCmdbusToFan_sig_next: std_logic;
	signal reqCmdbusToVmon_sig, reqCmdbusToVmon_sig_next: std_logic;
	signal reqCmdbusToVset_sig, reqCmdbusToVset_sig_next: std_logic;
	signal rdyCmdbusFromVmon_sig, rdyCmdbusFromVmon_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpInv,
		stateOpReady,
		stateOpGetPt,
		stateOpEvalPt,
		stateOpSetFanRng,
		stateOpGetNtcA, stateOpGetNtcB, stateOpGetNtcC,
		stateOpEvalNtc,
		stateOpCalc,
		stateOpCalcConst,
		stateOpCalcMinA, stateOpCalcMinB, stateOpCalcMinC,
		stateOpSetVtecA, stateOpSetVtecB,
		stateOpUpdP
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal rng, rng_next: std_logic;
	signal fanrun, fanrun_next: std_logic;
	signal ok_sig, ok_sig_next: std_logic;
	signal ceDiv: std_logic;

	signal dNtc: integer range -4096 to 4095;
	signal dNtc_vec: std_logic_vector(14 downto 0);

	signal vtec: natural range 0 to 1023;

	signal dVtec: integer range -1024 to 1023;
	signal dVtec_vec: std_logic_vector(10 downto 0);

	-- IP sigs.op.cust --- INSERT

	---- sample clock (tsmp)
	type stateTsmp_t is (
		stateTsmpInit,
		stateTsmpReady,
		stateTsmpRunA, stateTsmpRunB, stateTsmpRunC
	);
	signal stateTsmp, stateTsmp_next: stateTsmp_t := stateTsmpInit;

	signal strbSmp: std_logic;

	-- IP sigs.tsmp.cust --- INSERT

	---- myDiv
	signal dNtcDVtec_vec: std_logic_vector(14 downto 0);

	---- handshake
	-- cmd to op
	signal reqCmdToOpInvSetFan, reqCmdToOpInvSetFan_next: std_logic;
	signal ackCmdToOpInvSetFan, ackCmdToOpInvSetFan_next: std_logic;

	-- cmd to op
	signal reqCmdToOpInvSetRng, reqCmdToOpInvSetRng_next: std_logic;
	signal ackCmdToOpInvSetRng, ackCmdToOpInvSetRng_next: std_logic;

	-- cmd to op
	signal reqCmdToOpInvSetTrgNtc, reqCmdToOpInvSetTrgNtc_next: std_logic;
	signal ackCmdToOpInvSetTrgNtc, ackCmdToOpInvSetTrgNtc_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvFanSetRng: std_logic;
	signal ackOpToCmdInvFanSetRng, ackOpToCmdInvFanSetRng_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvVmonGetNtc: std_logic;
	signal ackOpToCmdInvVmonGetNtc, ackOpToCmdInvVmonGetNtc_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvVmonGetPt: std_logic;
	signal ackOpToCmdInvVmonGetPt, ackOpToCmdInvVmonGetPt_next: std_logic;

	-- op to cmd
	signal reqOpToCmdInvVsetSetVtec: std_logic;
	signal ackOpToCmdInvVsetSetVtec, ackOpToCmdInvVsetSetVtec_next: std_logic;

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myDiv : Div_v3_0_15by11
		port map (
			clk => mclk,
			ce => ceDiv,
			rfd => open,
			dividend => dNtc_vec,
			divisor => dVtec_vec,
			quotient => dNtcDVtec_vec,
			fractional => open
		);

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	reqCmdbusToFan <= reqCmdbusToFan_sig;
	reqCmdbusToVmon <= reqCmdbusToVmon_sig;
	reqCmdbusToVset <= reqCmdbusToVset_sig;
	rdyCmdbusFromVmon <= rdyCmdbusFromVmon_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- BEGIN
		variable lenCmdbuf: natural range 0 to sizeCmdbuf := 0;

		variable bytecnt: natural range 0 to sizeCmdbuf := 0;
		-- IP impl.cmd.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			reqCmdToOpInvSetFan_next <= '0';
			reqCmdToOpInvSetRng_next <= '0';
			reqCmdToOpInvSetTrgNtc_next <= '0';
			ackOpToCmdInvFanSetRng_next <= '0';
			ackOpToCmdInvVmonGetNtc_next <= '0';
			ackOpToCmdInvVmonGetPt_next <= '0';
			ackOpToCmdInvVsetSetVtec_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			reqCmdbusToFan_sig_next <= '0';
			reqCmdbusToVmon_sig_next <= '0';
			reqCmdbusToVset_sig_next <= '0';
			rdyCmdbusFromVmon_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				reqCmdToOpInvSetFan_next <= '0';
				reqCmdToOpInvSetRng_next <= '0';
				reqCmdToOpInvSetTrgNtc_next <= '0';
				ackOpToCmdInvFanSetRng_next <= '0';
				ackOpToCmdInvVmonGetNtc_next <= '0';
				ackOpToCmdInvVmonGetPt_next <= '0';
				ackOpToCmdInvVsetSetVtec_next <= '0';
				rdyCmdbusFromCmdinv_sig_next <= '1';
				reqCmdbusToFan_sig_next <= '0';
				reqCmdbusToVmon_sig_next <= '0';
				reqCmdbusToVset_sig_next <= '0';
				rdyCmdbusFromVmon_sig_next <= '1';

				lenCmdbuf := 0;
				bytecnt := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if ((rdCmdbusFromCmdinv='1' or rdCmdbusFromVmon='1') and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
					rdyCmdbusFromVmon_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;

				elsif (reqOpToCmdInvFanSetRng='1' or reqOpToCmdInvVmonGetNtc='1' or reqOpToCmdInvVmonGetPt='1' or reqOpToCmdInvVsetSetVtec='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
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
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromVmon='0') then
						if reqOpToCmdInvFanSetRng='1' then
							stateCmd_next <= stateCmdPrepInvFanSetRng;

						elsif reqOpToCmdInvVmonGetNtc='1' then
							stateCmd_next <= stateCmdPrepInvVmonGetNtc;

						elsif reqOpToCmdInvVmonGetPt='1' then
							stateCmd_next <= stateCmdPrepInvVmonGetPt;

						elsif reqOpToCmdInvVsetSetVtec='1' then
							stateCmd_next <= stateCmdPrepInvVsetSetVtec;

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
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromVmon='0') then
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
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetFan and lenCmdbuf=lenCmdbufInvSetFan) then
					reqCmdToOpInvSetFan_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetRng and lenCmdbuf=lenCmdbufInvSetRng) then
					reqCmdToOpInvSetRng_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetTrgNtc and lenCmdbuf=lenCmdbufInvSetTrgNtc) then
					reqCmdToOpInvSetTrgNtc_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRet and cmdbuf(ixCmdbufCref)=tixVIcm2VmonCommandGetNtc and lenCmdbuf=lenCmdbufRetVmonGetNtc) then
					ackOpToCmdInvVmonGetNtc_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionRet and cmdbuf(ixCmdbufCref)=tixVIcm2VmonCommandGetPt and lenCmdbuf=lenCmdbufRetVmonGetPt) then
					ackOpToCmdInvVmonGetPt_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdRecvE then
				if ((reqCmdToOpInvSetFan='1' and ackCmdToOpInvSetFan='1') or (reqCmdToOpInvSetRng='1' and ackCmdToOpInvSetRng='1') or (reqCmdToOpInvSetTrgNtc='1' and ackCmdToOpInvSetTrgNtc='1') or (reqOpToCmdInvVmonGetNtc='0' and ackOpToCmdInvVmonGetNtc='1') or (reqOpToCmdInvVmonGetPt='0' and ackOpToCmdInvVmonGetPt='1')) then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullA then
				if cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerFan then
					reqCmdbusToFan_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerVmon then
					reqCmdbusToVmon_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerVset then
					reqCmdbusToVset_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullB then
				if ((wrCmdbusToFan='1' or wrCmdbusToVmon='1' or wrCmdbusToVset='1') and clkCmdbus='1') then
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
							reqCmdbusToFan_sig_next <= '0';
							reqCmdbusToVmon_sig_next <= '0';
							reqCmdbusToVset_sig_next <= '0';
						end if;

						stateCmd_next <= stateCmdSendA;
					end if;
				end if;

			elsif stateCmd=stateCmdSendC then
				if (wrCmdbusToFan='0' and wrCmdbusToVmon='0' and wrCmdbusToVset='0') then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdPrepInvFanSetRng then
				cmdbuf(ixCmdbufRoute) <= tixVIdhwIcm2ControllerFan;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwIcm2ControllerFan;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVIcm2FanCommandSetRng;
				cmdbuf(ixCmdbufInvCommand) <= tixVIcm2FanCommandSetRng;

				-- IP impl.cmd.rising.prepInvFanSetRng --- IBEGIN
				if fanrun='1' then
					cmdbuf(ixCmdbufInvFanSetRngRng) <= tru8;
				else
					cmdbuf(ixCmdbufInvFanSetRngRng) <= fls8;
				end if;
				-- IP impl.cmd.rising.prepInvFanSetRng --- IEND

				lenCmdbuf := lenCmdbufInvFanSetRng;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvVmonGetNtc then
				cmdbuf(ixCmdbufRoute) <= tixVIdhwIcm2ControllerVmon;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwIcm2ControllerVmon;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVIcm2VmonCommandGetNtc;
				cmdbuf(ixCmdbufInvCommand) <= tixVIcm2VmonCommandGetNtc;

				lenCmdbuf := lenCmdbufInvVmonGetNtc;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvVmonGetPt then
				cmdbuf(ixCmdbufRoute) <= tixVIdhwIcm2ControllerVmon;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwIcm2ControllerVmon;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVIcm2VmonCommandGetPt;
				cmdbuf(ixCmdbufInvCommand) <= tixVIcm2VmonCommandGetPt;

				lenCmdbuf := lenCmdbufInvVmonGetPt;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepInvVsetSetVtec then
				cmdbuf(ixCmdbufRoute) <= tixVIdhwIcm2ControllerVset;
				cmdbuf(ixCmdbufRoute+1) <= tixVIdhwIcm2ControllerVset;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionInv;
				cmdbuf(ixCmdbufCref) <= tixVIcm2VsetCommandSetVtec;
				cmdbuf(ixCmdbufInvCommand) <= tixVIcm2VsetCommandSetVtec;

				-- IP impl.cmd.rising.prepInvVsetSetVtec --- IBEGIN
				cmdbuf(ixCmdbufInvVsetSetVtecVtec) <= "000000" & std_logic_vector(to_unsigned(vtec, 10)(9 downto 8));
				cmdbuf(ixCmdbufInvVsetSetVtecVtec+1) <= std_logic_vector(to_unsigned(vtec, 10)(7 downto 0));
				-- IP impl.cmd.rising.prepInvVsetSetVtec --- IEND

				lenCmdbuf := lenCmdbufInvVsetSetVtec;

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
			reqCmdToOpInvSetFan <= reqCmdToOpInvSetFan_next;
			reqCmdToOpInvSetRng <= reqCmdToOpInvSetRng_next;
			reqCmdToOpInvSetTrgNtc <= reqCmdToOpInvSetTrgNtc_next;
			ackOpToCmdInvFanSetRng <= ackOpToCmdInvFanSetRng_next;
			ackOpToCmdInvVmonGetNtc <= ackOpToCmdInvVmonGetNtc_next;
			ackOpToCmdInvVmonGetPt <= ackOpToCmdInvVmonGetPt_next;
			ackOpToCmdInvVsetSetVtec <= ackOpToCmdInvVsetSetVtec_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			dCmdbus_sig <= dCmdbus_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			reqCmdbusToFan_sig <= reqCmdbusToFan_sig_next;
			reqCmdbusToVmon_sig <= reqCmdbusToVmon_sig_next;
			reqCmdbusToVset_sig <= reqCmdbusToVset_sig_next;
			rdyCmdbusFromVmon_sig <= rdyCmdbusFromVmon_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- RBEGIN
	reqOpToCmdInvFanSetRng <= '1' when stateOp=stateOpSetFanRng else '0';

	reqOpToCmdInvVmonGetNtc <= '1' when stateOp=stateOpGetNtcB else '0';

	reqOpToCmdInvVmonGetPt <= '1' when stateOp=stateOpGetPt else '0';

	reqOpToCmdInvVsetSetVtec <= '1' when stateOp=stateOpSetVtecB else '0';

	ok <= ok_sig;
	ceDiv <= '1' when stateOp=stateOpCalcMinB else '0';

	dNtc_vec <= std_logic_vector(to_signed(dNtc, 13)) & "00";
	dVtec_vec <= std_logic_vector(to_signed(dVtec, 11));
	-- IP impl.op.wiring --- REND

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		variable tixVFanmode: std_logic_vector(7 downto 0) := tixVFanmodeOff;

		variable fanPtlow: natural range 0 to 4095 := 0;
		variable fanPthigh: natural range 0 to 4095 := 0;

		variable trgNtc: natural range 0 to 1023 := 512;
		variable trgNtcp: natural range 0 to 1023;

		variable modeMinNotConst: std_logic := '1';

		variable pt: natural range 0 to 4095;

		variable ntc: natural range 0 to 4095;
		variable ntcp: natural range 0 to 4095;

		variable dsumNtc: integer range -8192 to 8191;

		variable vtecp: natural range 0 to 1023;

		variable dsumVtec: integer range -2048 to 2047;

		variable dNtcDVtec: integer range -1024 to 1023;

		variable trgNtcChanged: std_logic;

		variable err: integer range -1024 to 1023;

		variable oddcnt: natural range 0 to 15;

		variable i: natural range 0 to 20;

		variable x, y: std_logic_vector(15 downto 0);
		variable z: std_logic_vector(10 downto 0);
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- BEGIN
			stateOp_next <= stateOpInit;
			rng_next <= '0';
			fanrun_next <= '0';
			ackCmdToOpInvSetFan_next <= '0';
			ackCmdToOpInvSetRng_next <= '0';
			ackCmdToOpInvSetTrgNtc_next <= '0';
			ok_sig_next <= '0';
			-- IP impl.op.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpInv and (reqCmdToOpInvSetFan='1' or reqCmdToOpInvSetRng='1' or reqCmdToOpInvSetTrgNtc='1'))) then
				if reqCmdToOpInvSetFan='1' then
					-- IP impl.op.rising.init.setFan --- IBEGIN
					tixVFanmode := cmdbuf(ixCmdbufInvSetFanTixVFanmode);

					x := cmdbuf(ixCmdbufInvSetFanPtlow) & cmdbuf(ixCmdbufInvSetFanPtlow+1);
					fanPtlow := to_integer(unsigned(x));

					y := cmdbuf(ixCmdbufInvSetFanPthigh) & cmdbuf(ixCmdbufInvSetFanPthigh+1);
					fanPthigh := to_integer(unsigned(y));

					ackCmdToOpInvSetFan_next <= '1';
					ackCmdToOpInvSetRng_next <= '0';
					ackCmdToOpInvSetTrgNtc_next <= '0';
					-- IP impl.op.rising.init.setFan --- IEND

					stateOp_next <= stateOpInv;

				elsif reqCmdToOpInvSetRng='1' then
					-- IP impl.op.rising.init.setRng --- IBEGIN
					if cmdbuf(ixCmdbufInvSetRngRng)=tru8 then
						rng_next <= '1';
					else
						rng_next <= '0';
					end if;

					ackCmdToOpInvSetFan_next <= '0';
					ackCmdToOpInvSetRng_next <= '1';
					ackCmdToOpInvSetTrgNtc_next <= '0';
					-- IP impl.op.rising.init.setRng --- IEND

					stateOp_next <= stateOpInv;

				elsif reqCmdToOpInvSetTrgNtc='1' then
					-- IP impl.op.rising.init.setTrgNtc --- IBEGIN
					x := cmdbuf(ixCmdbufInvSetTrgNtcNtc) & cmdbuf(ixCmdbufInvSetTrgNtcNtc+1);
					trgNtc := to_integer(unsigned(x(11 downto 0)));

					ackCmdToOpInvSetFan_next <= '0';
					ackCmdToOpInvSetRng_next <= '0';
					ackCmdToOpInvSetTrgNtc_next <= '1';
					-- IP impl.op.rising.init.setTrgNtc --- IEND

					stateOp_next <= stateOpInv;

				else
					-- IP impl.op.rising.syncrst --- RBEGIN
					rng_next <= '0';
					fanrun_next <= '0';
					ok_sig_next <= '0';

					tixVFanmode := tixVFanmodeOff;

					fanPtlow := 0;
					fanPthigh := 0;

					trgNtc := 512;

					modeMinNotConst := '1';

					ackCmdToOpInvSetFan_next <= '0';
					ackCmdToOpInvSetRng_next <= '0';
					ackCmdToOpInvSetTrgNtc_next <= '0';
					-- IP impl.op.rising.syncrst --- REND

					stateOp_next <= stateOpReady;
				end if;

			elsif stateOp=stateOpInv then
				if ((reqCmdToOpInvSetFan='0' and ackCmdToOpInvSetFan='1') or (reqCmdToOpInvSetRng='0' and ackCmdToOpInvSetRng='1') or (reqCmdToOpInvSetTrgNtc='0' and ackCmdToOpInvSetTrgNtc='1')) then
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpReady then
				if strbSmp='1' then
					stateOp_next <= stateOpGetPt;
				end if;

			elsif stateOp=stateOpGetPt then
				if ackOpToCmdInvVmonGetPt='1' then
					-- IP impl.op.rising.getPt --- IBEGIN
					x := cmdbuf(ixCmdbufRetVmonGetPtPt) & cmdbuf(ixCmdbufRetVmonGetPtPt+1);
					pt := to_integer(unsigned(x(11 downto 0)));
					-- IP impl.op.rising.getPt --- IEND

					stateOp_next <= stateOpGetNtcA;
				end if;

			elsif stateOp=stateOpEvalPt then
				if (fanrun='0' and pt>fanPthigh and (tixVFanmode=tixVFanmodeOn or (tixVFanmode=tixVFanmodeOffacq and acqprep='0'))) then
					fanrun_next <= '1'; -- IP impl.op.rising.evalPt.fanon --- ILINE

					stateOp_next <= stateOpSetFanRng;

				elsif (fanrun='1' and (tixVFanmode=tixVFanmodeOff or (tixVFanmode=tixVFanmodeOffacq and acqprep='1') or (pt<fanPtlow and tixVFanmode=tixVFanmodeOn))) then
					fanrun_next <= '0'; -- IP impl.op.rising.evalPt.fanoff --- ILINE

					stateOp_next <= stateOpSetFanRng;

				else
					stateOp_next <= stateOpGetNtcA;
				end if;

			elsif stateOp=stateOpSetFanRng then
				if ackOpToCmdInvFanSetRng='1' then
					stateOp_next <= stateOpGetNtcA;
				end if;

			elsif stateOp=stateOpGetNtcA then
				ntcp := ntc; -- IP impl.op.rising.getNtcA --- ILINE

				stateOp_next <= stateOpGetNtcB;

			elsif stateOp=stateOpGetNtcB then
				if ackOpToCmdInvVmonGetNtc='1' then
					-- IP impl.op.rising.getNtcB --- IBEGIN
					x := cmdbuf(ixCmdbufRetVmonGetNtcNtc) & cmdbuf(ixCmdbufRetVmonGetNtcNtc+1);
					ntc := to_integer(unsigned(x(11 downto 0)));
					-- IP impl.op.rising.getNtcB --- IEND

					stateOp_next <= stateOpGetNtcC;
				end if;

			elsif stateOp=stateOpGetNtcC then
				-- IP impl.op.rising.getNtcC --- IBEGIN
				dNtc <= ntc - ntcp;

				if trgNtc/=trgNtcp then
					trgNtcChanged := '1';
				else
					trgNtcChanged := '0';
				end if;

				err := ntc - trgNtc;
				-- IP impl.op.rising.getNtcC --- IEND

				stateOp_next <= stateOpEvalNtc;

			elsif stateOp=stateOpEvalNtc then
				-- IP impl.op.rising.evalNtc --- IBEGIN
				if trgNtcChanged='1' then
					ok_sig_next <= '0';

					oddcnt := 0;
					dsumNtc := 0;
					dsumvtec := 0;
				end if;

				if modeMinNotConst='1' then
					-- switch back when target is changed or after five consecutive readings below target
					if trgNtcChanged='1' then
						modeMinNotConst := '0';
						ok_sig_next <= '0';

					else
						if ok_sig='0' then
							if (dNtc>=-5 and dNtc<=5) then -- 5*20mK = 0.1K @250K
								ok_sig_next <= '1';
							end if;
						end if;

						if err>=0 then
							oddcnt := oddcnt + 1;
				
							if oddcnt=5 then
								modeMinNotConst := '0';
								ok_sig_next <= '0';
							end if;

						else
							oddcnt := 0;
						end if;
					end if;

				else
					if ok_sig='0' then
						if (err>=-25 and err<=25) then -- 25*20mK = 0.5K @250K
							ok_sig_next <= '1';
						end if;
					end if;

					-- runaway detection
					if (dNtc<=0 and dVtec>=0 and (dNtc/=0 or dVtec/=0)) then
						oddcnt := oddcnt + 1;
						dsumNtc := dsumNtc - dNtc;
						dsumvtec := dsumVtec + dVtec;
					elsif (dNtc/=0 or dVtec/=0) then
						oddcnt := 0;
						dsumNtc := 0;
						dsumvtec := 0;
					end if;

					if (dsumNtc>=10 and dsumVtec>=10) then -- 10*20mK = 0.2K @250K, 10*4.9mV = 49mV
						modeMinNotConst := '1';
						ok_sig_next <= '0';

						oddcnt := 0;
						dsumNtc := 0;
						dsumvtec := 0;
					end if;
				end if;
				-- IP impl.op.rising.evalNtc --- IEND

				stateOp_next <= stateOpCalc;

			elsif stateOp=stateOpCalc then
				if modeMinNotConst='1' then
					stateOp_next <= stateOp;

				else
					stateOp_next <= stateOpCalcConst;
				end if;

			elsif stateOp=stateOpCalcConst then
				-- IP impl.op.rising.calcConst --- IBEGIN
				-- adjust vtec by err/4
				z := "00" & std_logic_vector(to_signed(err, 11)(10 downto 2));
				if err<0 then
					z(10 downto 9) := "11";
				end if;
				
				vtec <= vtecp - to_integer(signed(z));
				-- IP impl.op.rising.calcConst --- IEND

				stateOp_next <= stateOpSetVtecA;

			elsif stateOp=stateOpCalcMinA then
				dNtcDvtec := 0; -- IP impl.op.rising.calcMinA.ext --- ILINE

				if (dNtc/=0 and dVtec/=0) then
					i := 0; -- IP impl.op.rising.calcMinA.initdiv --- ILINE

					stateOp_next <= stateOpCalcMinB;

				else
					stateOp_next <= stateOpCalcMinC;
				end if;

			elsif stateOp=stateOpCalcMinB then
				if i=20 then
					dNtcDvtec := to_integer(signed(dNtcDVtec_vec)); -- IP impl.op.rising.calcMinB.last --- ILINE

					stateOp_next <= stateOpCalcMinC;

				else
					i := i + 1; -- IP impl.op.rising.calcMinB.inc --- ILINE

					stateOp_next <= stateOpCalcMinB;
				end if;

			elsif stateOp=stateOpCalcMinC then
				-- IP impl.op.rising.calcMinC --- IBEGIN
				if dNTCdVTEC/=0 then
					-- adjustment proportional to derivative (slope of 4 @250K factored in in _div)
					vtec <= vtecp + dNtcDVtec;
				else
					if ( (dNtc=0 and dVtec=0) or (dNtc=0 and dVtec>0) or (dNtc>0 and dVtec=0) or (dNtc>0 and dVtec>0) or (dNtc<0 and dVtec<0) ) then
						-- +1
						if vtecp=1023 then
							vtec <= 1022;
						else
							vtec <= vtecp + 1;
						end if;
					else
						-- -1
						if vtecp=0 then
							vtec <= 1;
						else
							vtec <= vtecp - 1;
						end if;
					end if;
				end if;
				-- IP impl.op.rising.calcMinC --- IEND

				stateOp_next <= stateOpSetVtecA;

			elsif stateOp=stateOpSetVtecA then
				-- IP impl.op.rising.setVtecA --- IBEGIN
				if vtec<0 then
					vtec <= 0;
				elsif vtec>1023 then
					vtec <= 1023;
				end if;
				-- IP impl.op.rising.setVtecA --- IEND

				stateOp_next <= stateOpSetVtecB;

			elsif stateOp=stateOpSetVtecB then
				if ackOpToCmdInvVsetSetVtec='1' then
					stateOp_next <= stateOpUpdP;
				end if;

			elsif stateOp=stateOpUpdP then
				-- IP impl.op.rising.updP --- IBEGIN
				-- variables for next iteration
				dVtec <= vtec - vtecp;
				vtecp := vtec;

				trgNtcp := trgNtc;
				-- IP impl.op.rising.updP --- IEND

				stateOp_next <= stateOpReady;
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
			rng <= rng_next;
			fanrun <= fanrun_next;
			ackCmdToOpInvSetFan <= ackCmdToOpInvSetFan_next;
			ackCmdToOpInvSetRng <= ackCmdToOpInvSetRng_next;
			ackCmdToOpInvSetTrgNtc <= ackCmdToOpInvSetTrgNtc_next;
			ok_sig <= ok_sig_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: sample clock (tsmp)
	------------------------------------------------------------------------

	-- IP impl.tsmp.wiring --- BEGIN
	strbSmp <= '0' when (stateTsmp=stateTsmpRunA and tkclk='1') else '1';
	-- IP impl.tsmp.wiring --- END

	-- IP impl.tsmp.rising --- BEGIN
	process (reset, mclk, stateTsmp)
		-- IP impl.tsmp.rising.vars --- RBEGIN
		variable i: natural range 0 to 10000; -- 1s
		-- IP impl.tsmp.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.tsmp.rising.asyncrst --- BEGIN
			stateTsmp_next <= stateTsmpInit;
			-- IP impl.tsmp.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateTsmp=stateTsmpInit or rng='0') then
				if rng='0' then
					stateTsmp_next <= stateTsmpInit;

				else
					stateTsmp_next <= stateTsmpReady;
				end if;

			elsif stateTsmp=stateTsmpReady then
				if tkclk='0' then
					i := 0; -- IP impl.tsmp.rising.ready.init --- ILINE

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

					if i=10000 then
						i := 0; -- IP impl.tsmp.rising.runC.init --- ILINE

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

end Temp;


