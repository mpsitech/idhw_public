-- file Alub.vhd
-- Alub controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Alub is
	port (
		reset: in std_logic;
		mclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: inout std_logic_vector(7 downto 0);

		reqCmdbusToCmdret: out std_logic;
		wrCmdbusToCmdret: in std_logic;

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		btn: in std_logic;

		r0_out: out std_logic_vector(63 downto 0);
		r1_out: out std_logic_vector(63 downto 0)
	);
end Alub;

architecture Alub of Alub is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Div_v5_1_32by16 is
		port (
			aclk: in std_logic;
			aclken: in std_logic;
			aresetn: in std_logic;
			s_axis_divisor_tvalid: in std_logic;
			s_axis_divisor_tready: out std_logic;
			s_axis_divisor_tdata: in std_logic_vector(15 downto 0);
			s_axis_dividend_tvalid: in std_logic;
			s_axis_dividend_tready: out std_logic;
			s_axis_dividend_tdata: in std_logic_vector(31 downto 0);
			m_axis_dout_tvalid: out std_logic;
			m_axis_dout_tdata: out std_logic_vector(47 downto 0)
		);
	end component;

	component Mult_v12_0_32by32_0to63 is
		port (
			clk: in std_logic;
			ce: in std_logic;
			sclr: in std_logic;
			a: in std_logic_vector(31 downto 0);
			b: in std_logic_vector(31 downto 0);
			p: out std_logic_vector(63 downto 0)
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
		stateCmdFullA, stateCmdFullB,
		stateCmdSendA, stateCmdSendB, stateCmdSendC,
		stateCmdInvAddA, stateCmdInvAddB,
		stateCmdInvSubA, stateCmdInvSubB,
		stateCmdInvMultA, stateCmdInvMultB, stateCmdInvMultC,
		stateCmdInvDivA, stateCmdInvDivB, stateCmdInvDivC,
		stateCmdInvPowA, stateCmdInvPowB, stateCmdInvPowC, stateCmdInvPowD, stateCmdInvPowE,
		stateCmdInvLgcandA, stateCmdInvLgcandB, stateCmdInvLgcandC,
		stateCmdInvLgcorA, stateCmdInvLgcorB, stateCmdInvLgcorC,
		stateCmdInvLgcxorA, stateCmdInvLgcxorB, stateCmdInvLgcxorC,
		stateCmdInvLgcnotA, stateCmdInvLgcnotB,
		stateCmdInvValsetA, stateCmdInvValsetB, stateCmdInvValsetC,
		stateCmdPrepRetValgetA, stateCmdPrepRetValgetB, stateCmdPrepRetValgetC, stateCmdPrepRetValgetD,
		stateCmdPrepErrInvalid,
		stateCmdPrepErrMismatch,
		stateCmdPrepErrSize,
		stateCmdLoad,
		stateCmdStore
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: add, sub, mult, div, pow, lgcand, lgcor, lgcxor, lgcnot, valset, valget
	-- ret/newret: valget
	-- err: invalid, mismatch, size

	constant sizeCmdbuf: natural := 50;

	constant tixVRegVoid: std_logic_vector(7 downto 0) := x"00";
	constant tixVRegR0: std_logic_vector(7 downto 0) := x"01";
	constant tixVRegR1: std_logic_vector(7 downto 0) := x"02";
	constant tixVRegS0: std_logic_vector(7 downto 0) := x"03";
	constant tixVRegS1: std_logic_vector(7 downto 0) := x"04";
	constant tixVRegS2: std_logic_vector(7 downto 0) := x"05";
	constant tixVRegS3: std_logic_vector(7 downto 0) := x"06";
	constant tixVRegT0: std_logic_vector(7 downto 0) := x"07";
	constant tixVRegT1: std_logic_vector(7 downto 0) := x"08";
	constant tixVRegT2: std_logic_vector(7 downto 0) := x"09";
	constant tixVRegT3: std_logic_vector(7 downto 0) := x"0A";
	constant tixVRegT4: std_logic_vector(7 downto 0) := x"0B";
	constant tixVRegT5: std_logic_vector(7 downto 0) := x"0C";
	constant tixVRegT6: std_logic_vector(7 downto 0) := x"0D";
	constant tixVRegT7: std_logic_vector(7 downto 0) := x"0E";

	constant tixVCommandAdd: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvAdd: natural := 13;
	constant ixCmdbufInvAddATixVReg: natural := 10;
	constant ixCmdbufInvAddBTixVReg: natural := 11;
	constant ixCmdbufInvAddCTixVReg: natural := 12;

	constant tixVCommandSub: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvSub: natural := 13;
	constant ixCmdbufInvSubATixVReg: natural := 10;
	constant ixCmdbufInvSubBTixVReg: natural := 11;
	constant ixCmdbufInvSubCTixVReg: natural := 12;

	constant tixVCommandMult: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvMult: natural := 13;
	constant ixCmdbufInvMultATixVReg: natural := 10;
	constant ixCmdbufInvMultBTixVReg: natural := 11;
	constant ixCmdbufInvMultCTixVReg: natural := 12;

	constant tixVCommandDiv: std_logic_vector(7 downto 0) := x"03";
	constant lenCmdbufInvDiv: natural := 13;
	constant ixCmdbufInvDivATixVReg: natural := 10;
	constant ixCmdbufInvDivBTixVReg: natural := 11;
	constant ixCmdbufInvDivCTixVReg: natural := 12;

	constant tixVCommandPow: std_logic_vector(7 downto 0) := x"04";
	constant lenCmdbufInvPow: natural := 13;
	constant ixCmdbufInvPowATixVReg: natural := 10;
	constant ixCmdbufInvPowExp: natural := 11;
	constant ixCmdbufInvPowCTixVReg: natural := 12;

	constant tixVCommandLgcand: std_logic_vector(7 downto 0) := x"05";
	constant lenCmdbufInvLgcand: natural := 13;
	constant ixCmdbufInvLgcandATixVReg: natural := 10;
	constant ixCmdbufInvLgcandBTixVReg: natural := 11;
	constant ixCmdbufInvLgcandCTixVReg: natural := 12;

	constant tixVCommandLgcor: std_logic_vector(7 downto 0) := x"06";
	constant lenCmdbufInvLgcor: natural := 13;
	constant ixCmdbufInvLgcorATixVReg: natural := 10;
	constant ixCmdbufInvLgcorBTixVReg: natural := 11;
	constant ixCmdbufInvLgcorCTixVReg: natural := 12;

	constant tixVCommandLgcxor: std_logic_vector(7 downto 0) := x"07";
	constant lenCmdbufInvLgcxor: natural := 13;
	constant ixCmdbufInvLgcxorATixVReg: natural := 10;
	constant ixCmdbufInvLgcxorBTixVReg: natural := 11;
	constant ixCmdbufInvLgcxorCTixVReg: natural := 12;

	constant tixVCommandLgcnot: std_logic_vector(7 downto 0) := x"08";
	constant lenCmdbufInvLgcnot: natural := 12;
	constant ixCmdbufInvLgcnotATixVReg: natural := 10;
	constant ixCmdbufInvLgcnotCTixVReg: natural := 11;

	constant tixVCommandValset: std_logic_vector(7 downto 0) := x"09";
	constant maxlenCmdbufInvValset: natural := 20;
	constant ixCmdbufInvValsetR1TixVReg: natural := 10;
	constant ixCmdbufInvValsetR1Val: natural := 11;

	constant tixVCommandValget: std_logic_vector(7 downto 0) := x"0A";
	constant lenCmdbufInvValget: natural := 14;
	constant ixCmdbufInvValgetR1TixVReg: natural := 10;
	constant ixCmdbufInvValgetR2TixVReg: natural := 11;
	constant ixCmdbufInvValgetR3TixVReg: natural := 12;
	constant ixCmdbufInvValgetR4TixVReg: natural := 13;
	constant maxlenCmdbufRetValget: natural := 18;
	constant ixCmdbufRetValgetR1Val: natural := 9;

	constant tixVErrorInvalid: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufErrInvalid: natural := 12;
	constant ixCmdbufErrInvalidA: natural := 10;
	constant ixCmdbufErrInvalidB: natural := 11;

	constant tixVErrorMismatch: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufErrMismatch: natural := 10;

	constant tixVErrorSize: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufErrSize: natural := 14;
	constant ixCmdbufErrSizeR1: natural := 10;
	constant ixCmdbufErrSizeR2: natural := 11;
	constant ixCmdbufErrSizeR3: natural := 12;
	constant ixCmdbufErrSizeR4: natural := 13;

	signal tixVRegA: std_logic_vector(7 downto 0);
	signal tixVRegB: std_logic_vector(7 downto 0);
	signal tixVRegC: std_logic_vector(7 downto 0);

	signal r2TixVReg: std_logic_vector(7 downto 0);
	signal r3TixVReg: std_logic_vector(7 downto 0);
	signal r4TixVReg: std_logic_vector(7 downto 0);

	signal r0: std_logic_vector(63 downto 0);
	signal r1: std_logic_vector(63 downto 0);

	signal a: std_logic_vector(63 downto 0);
	signal b: std_logic_vector(63 downto 0);
	signal c: std_logic_vector(63 downto 0);

	signal ceDiv: std_logic;
	signal ceMult: std_logic;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;
	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- myDiv
	signal cdiv: std_logic_vector(47 downto 0);
	signal cmult: std_logic_vector(63 downto 0);

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myDiv : Div_v5_1_32by16
		port map (
			aclk => mclk,
			aclken => ceDiv,
			aresetn => ceDiv,
			s_axis_divisor_tvalid => '1',
			s_axis_divisor_tready => open,
			s_axis_divisor_tdata => b(15 downto 0),
			s_axis_dividend_tvalid => '1',
			s_axis_dividend_tready => open,
			s_axis_dividend_tdata => a(31 downto 0),
			m_axis_dout_tvalid => open,
			m_axis_dout_tdata => cdiv
		);

	myMult : Mult_v12_0_32by32_0to63
		port map (
			clk => mclk,
			ce => ceMult,
			sclr => '0',
			a => a(31 downto 0),
			b => b(31 downto 0),
			p => cmult
		);

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	ceDiv <= '0' when stateCmd=stateCmdInvDivC else '1';
	ceMult <= '0' when (stateCmd=stateCmdInvMultC or stateCmd=stateCmdInvPowE) else '1';
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- RBEGIN
		variable lenCmdbuf: natural range 0 to sizeCmdbuf;
		variable bytecnt: natural range 0 to sizeCmdbuf;

		variable i, j: natural range 0 to sizeCmdbuf;
		variable x: std_logic_vector(7 downto 0);

		variable valget: std_logic;

		variable invalidA, invalidB: std_logic;

		variable mismatch: std_logic;

		variable k: natural range 0 to 5; -- mult latency 5
		variable l: natural range 0 to 44; -- div latency 35 ; pipeline length 8
		variable m: std_logic_vector(7 downto 0); -- pow
		
		variable n: natural range 0 to 4; -- valset

		variable o: natural range 0 to 4; -- valget
		variable p: natural range 0 to 8; -- valget copy from reg
		variable q: natural range 0 to sizeCmdbuf; -- valget copy from req
		-- IP impl.cmd.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			reqCmdbusToCmdret_sig_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				reqCmdbusToCmdret_sig_next <= '0';
				rdyCmdbusFromCmdinv_sig_next <= '1';

				valget := '0';
				lenCmdbuf := 0;
				invalidA := '0';
				i := 0;
				invalidB := '0';
				j := 0;
				mismatch := '0';
				x := x"00";
				bytecnt := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;

				elsif btn='1' then
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
						if btn='1' then
							stateCmd_next <= stateCmdLock;

						else
							stateCmd_next <= stateCmdInit;
						end if;

					else
						stateCmd_next <= stateCmdRecvA;
					end if;
				end if;

			elsif stateCmd=stateCmdLock then
				if btn='0' then
					stateCmd_next <= stateCmdInit;
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
					lenCmdbuf := lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvD then
				if j=4 then
					cmdbuf(ixCmdbufRoute+3) <= x"00";

					stateCmd_next <= stateCmdRecvF;

				else
					if (i=0 and cmdbuf(j)=x"00") then
						x := tixVIdhwZedbControllerCmdret;
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
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandAdd and lenCmdbuf=lenCmdbufInvAdd) then
					stateCmd_next <= stateCmdInvAddA;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSub and lenCmdbuf=lenCmdbufInvSub) then
					stateCmd_next <= stateCmdInvSubA;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandMult and lenCmdbuf=lenCmdbufInvMult) then
					stateCmd_next <= stateCmdInvMultA;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandDiv and lenCmdbuf=lenCmdbufInvDiv) then
					stateCmd_next <= stateCmdInvDivA;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandPow and lenCmdbuf=lenCmdbufInvPow) then
					stateCmd_next <= stateCmdInvPowA;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandLgcand and lenCmdbuf=lenCmdbufInvLgcand) then
					stateCmd_next <= stateCmdInvLgcandA;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandLgcor and lenCmdbuf=lenCmdbufInvLgcor) then
					stateCmd_next <= stateCmdInvLgcorA;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandLgcxor and lenCmdbuf=lenCmdbufInvLgcxor) then
					stateCmd_next <= stateCmdInvLgcxorA;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandLgcnot and lenCmdbuf=lenCmdbufInvLgcnot) then
					stateCmd_next <= stateCmdInvLgcnotA;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandValset and lenCmdbuf<=maxlenCmdbufInvValset) then
					stateCmd_next <= stateCmdInvValsetA;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandValget and lenCmdbuf=lenCmdbufInvValget) then
					stateCmd_next <= stateCmdPrepRetValgetA;

				else
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
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdInvAddA then
				-- IP impl.cmd.rising.invAddA --- IBEGIN
				tixVRegA <= cmdbuf(ixCmdbufInvAddATixVReg);
				tixVRegB <= cmdbuf(ixCmdbufInvAddBTixVReg);
				tixVRegC <= cmdbuf(ixCmdbufInvAddCTixVReg);
				-- IP impl.cmd.rising.invAddA --- IEND

				stateCmd_next <= stateCmdLoad;

			elsif stateCmd=stateCmdInvAddB then
				c <= std_logic_vector(unsigned(a) + unsigned(b)); -- IP impl.cmd.rising.invAddB --- ILINE

				stateCmd_next <= stateCmdStore;

			elsif stateCmd=stateCmdInvSubA then
				-- IP impl.cmd.rising.invSubA --- IBEGIN
				tixVRegA <= cmdbuf(ixCmdbufInvSubATixVReg);
				tixVRegB <= cmdbuf(ixCmdbufInvSubBTixVReg);
				tixVRegC <= cmdbuf(ixCmdbufInvSubCTixVReg);
				-- IP impl.cmd.rising.invSubA --- IEND

				stateCmd_next <= stateCmdLoad;

			elsif stateCmd=stateCmdInvSubB then
				c <= std_logic_vector(unsigned(a) - unsigned(b)); -- IP impl.cmd.rising.invSubB --- ILINE

				stateCmd_next <= stateCmdStore;

			elsif stateCmd=stateCmdInvMultA then
				-- IP impl.cmd.rising.invMultA --- IBEGIN
				tixVRegA <= cmdbuf(ixCmdbufInvMultATixVReg);
				tixVRegB <= cmdbuf(ixCmdbufInvMultBTixVReg);
				tixVRegC <= cmdbuf(ixCmdbufInvMultCTixVReg);
				-- IP impl.cmd.rising.invMultA --- IEND

				stateCmd_next <= stateCmdInvMultB;

			elsif stateCmd=stateCmdInvMultB then
				-- IP impl.cmd.rising.invMultB.ext --- IBEGIN
				-- A,B can only be max 32bit/16bit registers
				if (tixVRegA=tixVRegR0 or tixVRegA=tixVRegR1) then
					invalidA := '1';
				end if;

				if (tixVRegB=tixVRegR0 or tixVRegB=tixVRegR1) then
					invalidB := '1';
				end if;
				-- IP impl.cmd.rising.invMultB.ext --- IEND

				if (invalidA='1' or invalidB='1') then
					stateCmd_next <= stateCmdPrepErrInvalid;

				else
					stateCmd_next <= stateCmdLoad;
				end if;

			elsif stateCmd=stateCmdInvMultC then
				if k=5 then
					c <= cmult; -- IP impl.cmd.rising.invMultC.last --- ILINE

					stateCmd_next <= stateCmdStore;

				else
					k := k + 1; -- IP impl.cmd.rising.invMultC.inc --- ILINE

					stateCmd_next <= stateCmdInvMultC;
				end if;

			elsif stateCmd=stateCmdInvDivA then
				-- IP impl.cmd.rising.invDivA --- IBEGIN
				tixVRegA <= cmdbuf(ixCmdbufInvDivATixVReg);
				tixVRegB <= cmdbuf(ixCmdbufInvDivBTixVReg);
				tixVRegC <= cmdbuf(ixCmdbufInvDivCTixVReg);
				-- IP impl.cmd.rising.invDivA --- IEND

				stateCmd_next <= stateCmdInvDivB;

			elsif stateCmd=stateCmdInvDivB then
				-- IP impl.cmd.rising.invDivB.ext --- IBEGIN
				-- A can only be 32bit/16bit registers
				if (tixVRegA=tixVRegR0 or tixVRegA=tixVRegR1) then
					invalidA := '1';
				end if;
	
				-- B can only be 16bit registers
				if (tixVRegB=tixVRegR0 or tixVRegB=tixVRegR1 or tixVRegB=tixVRegS0 or tixVRegB=tixVRegS1 or tixVRegB=tixVRegS2 or tixVRegB=tixVRegS3) then
					invalidB := '1';
				end if;
				-- IP impl.cmd.rising.invDivB.ext --- IEND

				if (invalidA='1' or invalidB='1') then
					stateCmd_next <= stateCmdPrepErrInvalid;

				else
					stateCmd_next <= stateCmdLoad;
				end if;

			elsif stateCmd=stateCmdInvDivC then
				if l=44 then
					c <= x"00000000" & cdiv(47 downto 16); -- IP impl.cmd.rising.invDivC.last --- ILINE

					stateCmd_next <= stateCmdStore;

				else
					l := l + 1; -- IP impl.cmd.rising.invDivC.inc --- ILINE

					stateCmd_next <= stateCmdInvDivC;
				end if;

			elsif stateCmd=stateCmdInvPowA then
				-- IP impl.cmd.rising.invPowA --- IBEGIN
				tixVRegA <= cmdbuf(ixCmdbufInvPowATixVReg);
				tixVRegB <= cmdbuf(ixCmdbufInvPowATixVReg);
				tixVRegC <= cmdbuf(ixCmdbufInvPowCTixVReg);
				-- IP impl.cmd.rising.invPowA --- IEND

				stateCmd_next <= stateCmdInvPowB;

			elsif stateCmd=stateCmdInvPowB then
				-- IP impl.cmd.rising.invPowB.ext --- IBEGIN
				-- A can only be 32bit/16bit registers
				if (tixVRegA=tixVRegR0 or tixVRegA=tixVRegR1) then
					invalidA := '1';
				end if;
				-- IP impl.cmd.rising.invPowB.ext --- IEND

				if invalidA='1' then
					stateCmd_next <= stateCmdPrepErrInvalid;

				else
					stateCmd_next <= stateCmdLoad;
				end if;

			elsif stateCmd=stateCmdInvPowC then
				c <= x"0000000000000001"; -- IP impl.cmd.rising.invPowC --- ILINE

				stateCmd_next <= stateCmdInvPowD;

			elsif stateCmd=stateCmdInvPowD then
				if m=cmdbuf(ixCmdbufInvPowExp) then
					stateCmd_next <= stateCmdStore;

				else
					-- IP impl.cmd.rising.invPowD.next --- IBEGIN
					a <= c;
					k := 0;
					-- IP impl.cmd.rising.invPowD.next --- IEND

					stateCmd_next <= stateCmdInvPowE;
				end if;

			elsif stateCmd=stateCmdInvPowE then
				if k=5 then
					-- IP impl.cmd.rising.invPowE.last --- IBEGIN
					c <= cmult;
					m := std_logic_vector(unsigned(m) + 1);
					-- IP impl.cmd.rising.invPowE.last --- IEND

					stateCmd_next <= stateCmdInvPowD;

				else
					k := k + 1; -- IP impl.cmd.rising.invPowE.inc --- ILINE

					stateCmd_next <= stateCmdInvPowE;
				end if;

			elsif stateCmd=stateCmdInvLgcandA then
				-- IP impl.cmd.rising.invLgcandA --- IBEGIN
				tixVRegA <= cmdbuf(ixCmdbufInvLgcandATixVReg);
				tixVRegB <= cmdbuf(ixCmdbufInvLgcandBTixVReg);
				tixVRegC <= cmdbuf(ixCmdbufInvLgcandCTixVReg);
				-- IP impl.cmd.rising.invLgcandA --- IEND

				stateCmd_next <= stateCmdInvLgcandB;

			elsif stateCmd=stateCmdInvLgcandB then
				-- IP impl.cmd.rising.invLgcandB.ext --- IBEGIN
				if (tixVRegA=tixVRegR0 or tixVRegA=tixVRegR1) then
					if (tixVRegB/=tixVRegR0 and tixVRegB/=tixVRegR1) then
						mismatch := '1';
					end if;
				elsif (tixVRegA=tixVRegS0 or tixVRegA=tixVRegS1 or tixVRegA=tixVRegS2 or tixVRegA=tixVRegS3) then
					if (tixVRegB/=tixVRegS0 and tixVRegB/=tixVRegS1 and tixVRegB/=tixVRegS2 and tixVRegB/=tixVRegS3) then
						mismatch := '1';
					end if;
				else
					if (tixVRegB/=tixVRegT0 and tixVRegB/=tixVRegT1 and tixVRegB/=tixVRegT2 and tixVRegB/=tixVRegT3 and tixVRegB/=tixVRegT4 and tixVRegB/=tixVRegT5 and tixVRegB/=tixVRegT6 and tixVRegB/=tixVRegT7) then
						mismatch := '1';
					end if;
				end if;
				-- IP impl.cmd.rising.invLgcandB.ext --- IEND

				if mismatch='1' then
					stateCmd_next <= stateCmdPrepErrMismatch;

				else
					stateCmd_next <= stateCmdLoad;
				end if;

			elsif stateCmd=stateCmdInvLgcandC then
				c <= a and b; -- IP impl.cmd.rising.invLgcandC --- ILINE

				stateCmd_next <= stateCmdStore;

			elsif stateCmd=stateCmdInvLgcorA then
				-- IP impl.cmd.rising.invLgcorA --- IBEGIN
				tixVRegA <= cmdbuf(ixCmdbufInvLgcorATixVReg);
				tixVRegB <= cmdbuf(ixCmdbufInvLgcorBTixVReg);
				tixVRegC <= cmdbuf(ixCmdbufInvLgcorCTixVReg);
				-- IP impl.cmd.rising.invLgcorA --- IEND

				stateCmd_next <= stateCmdInvLgcorB;

			elsif stateCmd=stateCmdInvLgcorB then
				-- IP impl.cmd.rising.invLgcorB.ext --- IBEGIN
				if (tixVRegA=tixVRegR0 or tixVRegA=tixVRegR1) then
					if (tixVRegB/=tixVRegR0 and tixVRegB/=tixVRegR1) then
						mismatch := '1';
					end if;
				elsif (tixVRegA=tixVRegS0 or tixVRegA=tixVRegS1 or tixVRegA=tixVRegS2 or tixVRegA=tixVRegS3) then
					if (tixVRegB/=tixVRegS0 and tixVRegB/=tixVRegS1 and tixVRegB/=tixVRegS2 and tixVRegB/=tixVRegS3) then
						mismatch := '1';
					end if;
				else
					if (tixVRegB/=tixVRegT0 and tixVRegB/=tixVRegT1 and tixVRegB/=tixVRegT2 and tixVRegB/=tixVRegT3 and tixVRegB/=tixVRegT4 and tixVRegB/=tixVRegT5 and tixVRegB/=tixVRegT6 and tixVRegB/=tixVRegT7) then
						mismatch := '1';
					end if;
				end if;
				-- IP impl.cmd.rising.invLgcorB.ext --- IEND

				if mismatch='1' then
					stateCmd_next <= stateCmdPrepErrMismatch;

				else
					stateCmd_next <= stateCmdLoad;
				end if;

			elsif stateCmd=stateCmdInvLgcorC then
				c <= a or b; -- IP impl.cmd.rising.invLgcorC --- ILINE

				stateCmd_next <= stateCmdStore;

			elsif stateCmd=stateCmdInvLgcxorA then
				-- IP impl.cmd.rising.invLgcxorA --- IBEGIN
				tixVRegA <= cmdbuf(ixCmdbufInvLgcxorATixVReg);
				tixVRegB <= cmdbuf(ixCmdbufInvLgcxorBTixVReg);
				tixVRegC <= cmdbuf(ixCmdbufInvLgcxorCTixVReg);
				-- IP impl.cmd.rising.invLgcxorA --- IEND

				stateCmd_next <= stateCmdInvLgcorB;

			elsif stateCmd=stateCmdInvLgcxorB then
				-- IP impl.cmd.rising.invLgcxorB.ext --- IBEGIN
				if (tixVRegA=tixVRegR0 or tixVRegA=tixVRegR1) then
					if (tixVRegB/=tixVRegR0 and tixVRegB/=tixVRegR1) then
						mismatch := '1';
					end if;
				elsif (tixVRegA=tixVRegS0 or tixVRegA=tixVRegS1 or tixVRegA=tixVRegS2 or tixVRegA=tixVRegS3) then
					if (tixVRegB/=tixVRegS0 and tixVRegB/=tixVRegS1 and tixVRegB/=tixVRegS2 and tixVRegB/=tixVRegS3) then
						mismatch := '1';
					end if;
				else
					if (tixVRegB/=tixVRegT0 and tixVRegB/=tixVRegT1 and tixVRegB/=tixVRegT2 and tixVRegB/=tixVRegT3 and tixVRegB/=tixVRegT4 and tixVRegB/=tixVRegT5 and tixVRegB/=tixVRegT6 and tixVRegB/=tixVRegT7) then
						mismatch := '1';
					end if;
				end if;
				-- IP impl.cmd.rising.invLgcxorB.ext --- IEND

				if mismatch='1' then
					stateCmd_next <= stateCmdPrepErrMismatch;

				else
					stateCmd_next <= stateCmdLoad;
				end if;

			elsif stateCmd=stateCmdInvLgcxorC then
				c <= a xor b; -- IP impl.cmd.rising.invLgcxorC --- ILINE

				stateCmd_next <= stateCmdStore;

			elsif stateCmd=stateCmdInvLgcnotA then
				-- IP impl.cmd.rising.invLgcnotA --- IBEGIN
				tixVRegA <= cmdbuf(ixCmdbufInvLgcnotATixVReg);
				tixVRegC <= cmdbuf(ixCmdbufInvLgcnotCTixVReg);
				-- IP impl.cmd.rising.invLgcnotA --- IEND

				stateCmd_next <= stateCmdLoad;

			elsif stateCmd=stateCmdInvLgcnotB then
				c <= not a; -- IP impl.cmd.rising.invLgcnotB --- ILINE

				stateCmd_next <= stateCmdStore;

			elsif stateCmd=stateCmdInvValsetA then
				i := ixCmdbufInvValsetR1TixVReg; -- IP impl.cmd.rising.invValsetA --- ILINE

				stateCmd_next <= stateCmdInvValsetB;

			elsif stateCmd=stateCmdInvValsetB then
				if n=4 then
					stateCmd_next <= stateCmdInit;

				else
					tixVRegC <= cmdbuf(i); -- IP impl.cmd.rising.invValsetB.copy --- ILINE

					if cmdbuf(i)=tixVRegVoid then
						if cmdbuf(i+1)=x"00" then
							i := i + 2; -- IP impl.cmd.rising.invValsetB.void --- ILINE

							stateCmd_next <= stateCmdInvValsetC;

						else
							stateCmd_next <= stateCmdPrepErrSize;
						end if;

					elsif (cmdbuf(i)=tixVRegR0 or cmdbuf(i)=tixVRegR1) then
						if cmdbuf(i+1)=x"08" then
							-- IP impl.cmd.rising.invValsetB.regR --- IBEGIN
							c <= cmdbuf(i+2) & cmdbuf(i+3) & cmdbuf(i+4) & cmdbuf(i+5) & cmdbuf(i+6) & cmdbuf(i+7) & cmdbuf(i+8) & cmdbuf(i+9);
							i := i + 10;
							-- IP impl.cmd.rising.invValsetB.regR --- IEND

							stateCmd_next <= stateCmdStore;

						else
							stateCmd_next <= stateCmdPrepErrSize;
						end if;

					elsif (cmdbuf(i)=tixVRegS0 or cmdbuf(i)=tixVRegS1 or cmdbuf(i)=tixVRegS2 or cmdbuf(i)=tixVRegS3) then
						if cmdbuf(i+1)=x"04" then
							-- IP impl.cmd.rising.invValsetB.regS --- IBEGIN
							c <= x"00000000" & cmdbuf(i+2) & cmdbuf(i+3) & cmdbuf(i+4) & cmdbuf(i+5);
							i := i + 6;
							-- IP impl.cmd.rising.invValsetB.regS --- IEND

							stateCmd_next <= stateCmdStore;

						else
							stateCmd_next <= stateCmdPrepErrSize;
						end if;

					elsif (cmdbuf(i)=tixVRegT0 or cmdbuf(i)=tixVRegT1 or cmdbuf(i)=tixVRegT2 or cmdbuf(i)=tixVRegT3 or cmdbuf(i)=tixVRegT4 or cmdbuf(i)=tixVRegT5 or cmdbuf(i)=tixVRegT6 or cmdbuf(i)=tixVRegT7) then
						if cmdbuf(i+1)=x"02" then
							-- IP impl.cmd.rising.invValsetB.regT --- IBEGIN
							c <= x"000000000000" & cmdbuf(i+2) & cmdbuf(i+3);
							i := i + 4;
							-- IP impl.cmd.rising.invValsetB.regT --- IEND

							stateCmd_next <= stateCmdStore;

						else
							stateCmd_next <= stateCmdPrepErrSize;
						end if;

					else
						stateCmd_next <= stateCmdPrepErrSize;
					end if;
				end if;

			elsif stateCmd=stateCmdInvValsetC then
				n := n + 1; -- IP impl.cmd.rising.invValsetC --- ILINE

				stateCmd_next <= stateCmdInvValsetB;

			elsif stateCmd=stateCmdPrepRetValgetA then
				-- IP impl.cmd.rising.prepRetValgetA --- IBEGIN
				tixVRegB <= tixVRegVoid;

				r2TixVReg <= cmdbuf(ixCmdbufInvValgetR2TixVReg);
				r3TixVReg <= cmdbuf(ixCmdbufInvValgetR3TixVReg);
				r4TixVReg <= cmdbuf(ixCmdbufInvValgetR4TixVReg);

				valget := '1';
				q := ixCmdbufRetValgetR1Val;
				-- IP impl.cmd.rising.prepRetValgetA --- IEND

				stateCmd_next <= stateCmdPrepRetValgetB;

			elsif stateCmd=stateCmdPrepRetValgetB then
				if o=4 then
					-- IP impl.cmd.rising.prepRetValgetB.last --- IBEGIN
					cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;
					lenCmdbuf := q;
					-- IP impl.cmd.rising.prepRetValgetB.last --- IEND

					stateCmd_next <= stateCmdFullA;

				else
					-- IP impl.cmd.rising.prepRetValgetB.copy --- IBEGIN
					if o=0 then
						tixVRegA <= cmdbuf(ixCmdbufInvValgetR1TixVReg);
					elsif o=1 then
						tixVRegA <= r2TixVReg;
					elsif o=2 then
						tixVRegA <= r3TixVReg;
					elsif o=3 then
						tixVRegA <= r4TixVReg;
					end if;
					-- IP impl.cmd.rising.prepRetValgetB.copy --- IEND

					stateCmd_next <= stateCmdLoad;
				end if;

			elsif stateCmd=stateCmdPrepRetValgetC then
				-- IP impl.cmd.rising.prepRetValgetC --- IBEGIN
				if (tixVRegA=tixVRegR0 or tixVRegA=tixVRegR1) then
					p := 8;
				elsif (tixVRegA=tixVRegS0 or tixVRegA=tixVRegS1 or tixVRegA=tixVRegS2 or tixVRegA=tixVRegS3) then
					p := 4;
				elsif (tixVRegA=tixVRegT0 or tixVRegA=tixVRegT1 or tixVRegA=tixVRegT2 or tixVRegA=tixVRegT3 or tixVRegA=tixVRegT4 or tixVRegA=tixVRegT5 or tixVRegA=tixVRegT6 or tixVRegA=tixVRegT7) then
					p := 2;
				else
					p := 0;
				end if;

				cmdbuf(q) <= std_logic_vector(to_unsigned(p, 8));
				q := q + 1;
				-- IP impl.cmd.rising.prepRetValgetC --- IEND

				stateCmd_next <= stateCmdPrepRetValgetD;

			elsif stateCmd=stateCmdPrepRetValgetD then
				if p=0 then
					o := o + 1; -- IP impl.cmd.rising.prepRetValgetD.last --- ILINE

					stateCmd_next <= stateCmdPrepRetValgetB;

				else
					-- IP impl.cmd.rising.prepRetValgetD.copy --- IBEGIN
					if p=8 then
						cmdbuf(q) <= a(63 downto 56);
					elsif p=7 then
						cmdbuf(q) <= a(55 downto 48);
					elsif p=6 then
						cmdbuf(q) <= a(47 downto 40);
					elsif p=5 then
						cmdbuf(q) <= a(39 downto 32);
					elsif p=4 then
						cmdbuf(q) <= a(31 downto 24);
					elsif p=3 then
						cmdbuf(q) <= a(23 downto 16);
					elsif p=2 then
						cmdbuf(q) <= a(15 downto 8);
					elsif p=1 then
						cmdbuf(q) <= a(7 downto 0);
					end if;

					p := p - 1;
					q := q + 1;
					-- IP impl.cmd.rising.prepRetValgetD.copy --- IEND

					stateCmd_next <= stateCmdPrepRetValgetD;
				end if;

			elsif stateCmd=stateCmdPrepErrInvalid then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionErr;
				cmdbuf(ixCmdbufErrError) <= tixVErrorInvalid;

				-- IP impl.cmd.rising.prepErrInvalid --- IBEGIN
				if invalidA='1' then
					cmdbuf(ixCmdbufErrInvalidA) <= tru8;
				else
					cmdbuf(ixCmdbufErrInvalidA) <= fls8;
				end if;					
				if invalidB='1' then
					cmdbuf(ixCmdbufErrInvalidB) <= tru8;
				else
					cmdbuf(ixCmdbufErrInvalidB) <= fls8;
				end if;
				-- IP impl.cmd.rising.prepErrInvalid --- IEND

				lenCmdbuf := lenCmdbufErrInvalid;

				stateCmd_next <= stateCmdFullA;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionErr;
				cmdbuf(ixCmdbufErrError) <= tixVErrorInvalid;

				-- IP impl.cmd.rising.prepErrInvalid --- IBEGIN
				if invalidA='1' then
					cmdbuf(ixCmdbufErrInvalidA) <= tru8;
				else
					cmdbuf(ixCmdbufErrInvalidA) <= fls8;
				end if;					
				if invalidB='1' then
					cmdbuf(ixCmdbufErrInvalidB) <= tru8;
				else
					cmdbuf(ixCmdbufErrInvalidB) <= fls8;
				end if;
				-- IP impl.cmd.rising.prepErrInvalid --- IEND

				lenCmdbuf := lenCmdbufErrInvalid;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepErrMismatch then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionErr;
				cmdbuf(ixCmdbufErrError) <= tixVErrorMismatch;

				lenCmdbuf := lenCmdbufErrMismatch;

				stateCmd_next <= stateCmdFullA;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionErr;
				cmdbuf(ixCmdbufErrError) <= tixVErrorMismatch;

				lenCmdbuf := lenCmdbufErrMismatch;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdPrepErrSize then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionErr;
				cmdbuf(ixCmdbufErrError) <= tixVErrorSize;

				-- IP impl.cmd.rising.prepErrSize --- IBEGIN
				if n=0 then
					cmdbuf(ixCmdbufErrSizeR1) <= tru8;
				else
					cmdbuf(ixCmdbufErrSizeR1) <= fls8;
				end if;
				if n=1 then
					cmdbuf(ixCmdbufErrSizeR2) <= tru8;
				else
					cmdbuf(ixCmdbufErrSizeR2) <= fls8;
				end if;
				if n=2 then
					cmdbuf(ixCmdbufErrSizeR3) <= tru8;
				else
					cmdbuf(ixCmdbufErrSizeR3) <= fls8;
				end if;
				if n=3 then
					cmdbuf(ixCmdbufErrSizeR4) <= tru8;
				else
					cmdbuf(ixCmdbufErrSizeR4) <= fls8;
				end if;
				-- IP impl.cmd.rising.prepErrSize --- IEND

				lenCmdbuf := lenCmdbufErrSize;

				stateCmd_next <= stateCmdFullA;
				cmdbuf(ixCmdbufAction) <= tixDbeVActionErr;
				cmdbuf(ixCmdbufErrError) <= tixVErrorSize;

				-- IP impl.cmd.rising.prepErrSize --- IBEGIN
				if n=0 then
					cmdbuf(ixCmdbufErrSizeR1) <= tru8;
				else
					cmdbuf(ixCmdbufErrSizeR1) <= fls8;
				end if;
				if n=1 then
					cmdbuf(ixCmdbufErrSizeR2) <= tru8;
				else
					cmdbuf(ixCmdbufErrSizeR2) <= fls8;
				end if;
				if n=2 then
					cmdbuf(ixCmdbufErrSizeR3) <= tru8;
				else
					cmdbuf(ixCmdbufErrSizeR3) <= fls8;
				end if;
				if n=3 then
					cmdbuf(ixCmdbufErrSizeR4) <= tru8;
				else
					cmdbuf(ixCmdbufErrSizeR4) <= fls8;
				end if;
				-- IP impl.cmd.rising.prepErrSize --- IEND

				lenCmdbuf := lenCmdbufErrSize;

				stateCmd_next <= stateCmdFullA;

			elsif stateCmd=stateCmdLoad then
				-- IP impl.cmd.rising.load.ext --- IBEGIN
				if tixVRegA=tixVRegR0 then
					a <= r0;
				elsif tixVRegA=tixVRegR1 then
					a <= r1;
				elsif tixVRegA=tixVRegS0 then
					a <= x"00000000" & r0(63 downto 32);
				elsif tixVRegA=tixVRegS1 then
					a <= x"00000000" & r0(31 downto 0);
				elsif tixVRegA=tixVRegS2 then
					a <= x"00000000" & r1(63 downto 32);
				elsif tixVRegA=tixVRegS3 then
					a <= x"00000000" & r1(31 downto 0);
				elsif tixVRegA=tixVRegT0 then
					a <= x"000000000000" & r0(63 downto 48);
				elsif tixVRegA=tixVRegT1 then
					a <= x"000000000000" & r0(47 downto 32);
				elsif tixVRegA=tixVRegT2 then
					a <= x"000000000000" & r0(31 downto 16);
				elsif tixVRegA=tixVRegT3 then
					a <= x"000000000000" & r0(15 downto 0);
				elsif tixVRegA=tixVRegT4 then
					a <= x"000000000000" & r1(63 downto 48);
				elsif tixVRegA=tixVRegT5 then
					a <= x"000000000000" & r1(47 downto 32);
				elsif tixVRegA=tixVRegT6 then
					a <= x"000000000000" & r1(31 downto 16);
				elsif tixVRegA=tixVRegT7 then
					a <= x"000000000000" & r1(15 downto 0);
				else
					a <= (others => '0');
				end if;

				if tixVRegB=tixVRegR0 then
					b <= r0;
				elsif tixVRegB=tixVRegR1 then
					b <= r1;
				elsif tixVRegB=tixVRegS0 then
					b <= x"00000000" & r0(63 downto 32);
				elsif tixVRegB=tixVRegS1 then
					b <= x"00000000" & r0(31 downto 0);
				elsif tixVRegB=tixVRegS2 then
					b <= x"00000000" & r1(63 downto 32);
				elsif tixVRegB=tixVRegS3 then
					b <= x"00000000" & r1(31 downto 0);
				elsif tixVRegB=tixVRegT0 then
					b <= x"000000000000" & r0(63 downto 48);
				elsif tixVRegB=tixVRegT1 then
					b <= x"000000000000" & r0(47 downto 32);
				elsif tixVRegB=tixVRegT2 then
					b <= x"000000000000" & r0(31 downto 16);
				elsif tixVRegB=tixVRegT3 then
					b <= x"000000000000" & r0(15 downto 0);
				elsif tixVRegB=tixVRegT4 then
					b <= x"000000000000" & r1(63 downto 48);
				elsif tixVRegB=tixVRegT5 then
					b <= x"000000000000" & r1(47 downto 32);
				elsif tixVRegB=tixVRegT6 then
					b <= x"000000000000" & r1(31 downto 16);
				elsif tixVRegB=tixVRegT7 then
					b <= x"000000000000" & r1(15 downto 0);
				else
					b <= (others => '0');
				end if;
				-- IP impl.cmd.rising.load.ext --- IEND

				if valget='1' then
					stateCmd_next <= stateCmdPrepRetValgetB;

				elsif cmdbuf(ixCmdbufInvCommand)=tixVCommandAdd then
					stateCmd_next <= stateCmdInvAddB;

				elsif cmdbuf(ixCmdbufInvCommand)=tixVCommandSub then
					stateCmd_next <= stateCmdInvSubB;

				elsif cmdbuf(ixCmdbufInvCommand)=tixVCommandMult then
					k := 0; -- IP impl.cmd.rising.load.mult --- ILINE

					stateCmd_next <= stateCmdInvMultC;

				elsif cmdbuf(ixCmdbufInvCommand)=tixVCommandDiv then
					l := 0; -- IP impl.cmd.rising.load.div --- ILINE

					stateCmd_next <= stateCmdInvDivC;

				elsif cmdbuf(ixCmdbufInvCommand)=tixVCommandPow then
					stateCmd_next <= stateCmdInvPowC;

				elsif cmdbuf(ixCmdbufInvCommand)=tixVCommandLgcand then
					stateCmd_next <= stateCmdInvLgcandC;

				elsif cmdbuf(ixCmdbufInvCommand)=tixVCommandLgcor then
					stateCmd_next <= stateCmdInvLgcorC;

				elsif cmdbuf(ixCmdbufInvCommand)=tixVCommandLgcxor then
					stateCmd_next <= stateCmdInvLgcxorC;

				elsif cmdbuf(ixCmdbufInvCommand)=tixVCommandLgcnot then
					stateCmd_next <= stateCmdInvLgcnotB;
				end if;

			elsif stateCmd=stateCmdStore then
				-- IP impl.cmd.rising.store.ext --- IBEGIN
				if tixVRegC=tixVRegR0 then
					r0 <= c;
				elsif tixVRegC=tixVRegR1 then
					r1 <= c;
				elsif tixVRegC=tixVRegS0 then
					r0(63 downto 32) <= c(31 downto 0);
				elsif tixVRegC=tixVRegS1 then
					r0(31 downto 0) <= c(31 downto 0);
				elsif tixVRegC=tixVRegS2 then
					r1(63 downto 32) <= c(31 downto 0);
				elsif tixVRegC=tixVRegS3 then
					r1(31 downto 0) <= c(31 downto 0);
				elsif tixVRegC=tixVRegT0 then
					r0(63 downto 48) <= c(15 downto 0);
				elsif tixVRegC=tixVRegT1 then
					r0(47 downto 32) <= c(15 downto 0);
				elsif tixVRegC=tixVRegT2 then
					r0(31 downto 16) <= c(15 downto 0);
				elsif tixVRegC=tixVRegT3 then
					r0(15 downto 0) <= c(15 downto 0);
				elsif tixVRegC=tixVRegT4 then
					r1(63 downto 48) <= c(15 downto 0);
				elsif tixVRegC=tixVRegT5 then
					r1(47 downto 32) <= c(15 downto 0);
				elsif tixVRegC=tixVRegT6 then
					r1(31 downto 16) <= c(15 downto 0);
				elsif tixVRegC=tixVRegT7 then
					r1(15 downto 0) <= c(15 downto 0);
				end if;
				-- IP impl.cmd.rising.store.ext --- IEND

				if cmdbuf(ixCmdbufInvCommand)=tixVCommandValset then
					stateCmd_next <= stateCmdInvValsetB;

				else
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
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- IBEGIN
--	-- stripped down version
--	reqCmdbusToCmdret <= '0';

--	rdyCmdbusFromCmdinv <= '0';

--	r0_out <= (others => '0');
--	r1_out <= (others => '0');

	-- debug
	r0_out <= r0;
	r1_out <= r1;
	-- IP impl.oth.cust --- IEND

end Alub;


