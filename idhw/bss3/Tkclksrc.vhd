-- file Tkclksrc.vhd
-- Tkclksrc tkclksrc_v1_0 controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Tkclksrc is
	generic (
		fMclk: natural range 1 to 1000000
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: out std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: inout std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		rdyCmdbusFromLwiracq: out std_logic;
		rdCmdbusFromLwiracq: in std_logic;

		reqCmdbusToCmdret: out std_logic;
		wrCmdbusToCmdret: in std_logic;

		reqCmdbusToLwiracq: out std_logic;
		wrCmdbusToLwiracq: in std_logic
	);
end Tkclksrc;

architecture Tkclksrc of Tkclksrc is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- command execution
	type stateCmd_t is (
		stateCmdInit,
		stateCmdEmpty,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE, stateCmdRecvF,
		stateCmdRecvG,
		stateCmdFullA, stateCmdFullB,
		stateCmdSendA, stateCmdSendB, stateCmdSendC,
		stateCmdPrepRetGetTkst
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	constant sizeCmdbuf: natural := 14;

	constant tixVCommandGetTkst: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvGetTkst: natural := 10;
	constant lenCmdbufRetGetTkst: natural := 13;
	constant ixCmdbufRetGetTkstTkst: natural := 9;

	constant tixVCommandSetTkst: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvSetTkst: natural := 14;
	constant ixCmdbufInvSetTkstTkst: natural := 10;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal rdyCmdbusFromLwiracq_sig, rdyCmdbusFromLwiracq_sig_next: std_logic;
	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;
	signal reqCmdbusToLwiracq_sig, reqCmdbusToLwiracq_sig_next: std_logic;

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpIdle,
		stateOpInv,
		stateOpRun
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal tkclk_sig, tkclk_sig_next: std_logic;
	signal tkst, tkst_next: std_logic_vector(31 downto 0);

	---- handshake
	-- cmd to op
	signal reqCmdToOpInvSetTkst, reqCmdToOpInvSetTkst_next: std_logic;
	signal ackCmdToOpInvSetTkst: std_logic;

	---- other
	signal lenCmdbuf_out_sig: natural range 0 to sizeCmdbuf := 0;

begin

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	rdyCmdbusFromLwiracq <= rdyCmdbusFromLwiracq_sig;
	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	reqCmdbusToLwiracq <= reqCmdbusToLwiracq_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- RBEGIN
		variable lenCmdbuf: natural range 0 to sizeCmdbuf;
		variable bytecnt: natural range 0 to sizeCmdbuf;

		variable i, j: natural range 0 to sizeCmdbuf;
		variable x: std_logic_vector(7 downto 0);
		-- IP impl.cmd.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			reqCmdToOpInvSetTkst_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			rdyCmdbusFromLwiracq_sig_next <= '1';
			reqCmdbusToCmdret_sig_next <= '0';
			reqCmdbusToLwiracq_sig_next <= '0';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				reqCmdToOpInvSetTkst_next <= '0';
				rdyCmdbusFromCmdinv_sig_next <= '1';
				rdyCmdbusFromLwiracq_sig_next <= '1';
				reqCmdbusToCmdret_sig_next <= '0';
				reqCmdbusToLwiracq_sig_next <= '0';

				lenCmdbuf := 0;
				i := 0;
				j := 0;
				x := x"00";
				bytecnt := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if ((rdCmdbusFromCmdinv='1' or rdCmdbusFromLwiracq='1') and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';
					rdyCmdbusFromLwiracq_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;
				end if;

			elsif stateCmd=stateCmdRecvA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvB then
				if clkCmdbus='1' then
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromLwiracq='0') then
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
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetTkst and lenCmdbuf=lenCmdbufInvGetTkst) then
					stateCmd_next <= stateCmdPrepRetGetTkst;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetTkst and lenCmdbuf=lenCmdbufInvSetTkst) then
					reqCmdToOpInvSetTkst_next <= '1';

					stateCmd_next <= stateCmdRecvG;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdRecvG then
				if (reqCmdToOpInvSetTkst='1' and ackCmdToOpInvSetTkst='1') then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullA then
				if cmdbuf(ixCmdbufRoute)=tixVIdhwBss3ControllerCmdret then
					reqCmdbusToCmdret_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				elsif cmdbuf(ixCmdbufRoute)=tixVIdhwBss3ControllerLwiracq then
					reqCmdbusToLwiracq_sig_next <= '1';

					stateCmd_next <= stateCmdFullB;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullB then
				if ((wrCmdbusToCmdret='1' or wrCmdbusToLwiracq='1') and clkCmdbus='1') then
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
							reqCmdbusToLwiracq_sig_next <= '0';
						end if;

						stateCmd_next <= stateCmdSendA;
					end if;
				end if;

			elsif stateCmd=stateCmdSendC then
				if (wrCmdbusToCmdret='0' and wrCmdbusToLwiracq='0') then
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdPrepRetGetTkst then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				cmdbuf(ixCmdbufRetGetTkstTkst) <= tkst(31 downto 24);
				cmdbuf(ixCmdbufRetGetTkstTkst+1) <= tkst(23 downto 16);
				cmdbuf(ixCmdbufRetGetTkstTkst+2) <= tkst(15 downto 8);
				cmdbuf(ixCmdbufRetGetTkstTkst+3) <= tkst(7 downto 0);

				lenCmdbuf := lenCmdbufRetGetTkst;

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
			reqCmdToOpInvSetTkst <= reqCmdToOpInvSetTkst_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			dCmdbus_sig <= dCmdbus_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			rdyCmdbusFromLwiracq_sig <= rdyCmdbusFromLwiracq_sig_next;
			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
			reqCmdbusToLwiracq_sig <= reqCmdbusToLwiracq_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	ackCmdToOpInvSetTkst <= '1' when stateOp=stateOpInv else '0';

	tkclk <= tkclk_sig;

	process (reset, mclk, stateOp)
		variable i: natural range 0 to (fMclk/10)/2;

	begin
		if reset='1' then
			stateOp_next <= stateOpInit;
			tkclk_sig_next <= '0';
			tkst_next <= (others => '0');

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpIdle and stateOp/=stateOpInv and reqCmdToOpInvSetTkst='1')) then
				tkclk_sig_next <= '0';
				tkst_next <= (others => '0');

				i := 0;

				stateOp_next <= stateOpIdle;

			elsif stateOp=stateOpIdle then
				if reqCmdToOpInvSetTkst='1' then
					tkst_next <= cmdbuf(ixCmdbufInvSetTkstTkst) & cmdbuf(ixCmdbufInvSetTkstTkst+1) & cmdbuf(ixCmdbufInvSetTkstTkst+2) & cmdbuf(ixCmdbufInvSetTkstTkst+3);

					stateOp_next <= stateOpInv;
				else
					stateOp_next <= stateOpRun;
				end if;

			elsif stateOp=stateOpInv then
				if reqCmdToOpInvSetTkst='0' then
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpRun then
				i := i + 1;
				if i=(fMclk/10)/2 then
					i := 0;
					if tkclk_sig='1' then
						tkst_next <= std_logic_vector(unsigned(tkst) + 1);
					end if;
					tkclk_sig_next <= not tkclk_sig;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			tkclk_sig <= tkclk_sig_next;
			tkst <= tkst_next;
		end if;
	end process;

end Tkclksrc;


