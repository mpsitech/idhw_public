-- file Fan.vhd
-- Fan controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

entity Fan is
	generic (
		Ti: natural range 1000 to 10000 := 2500 -- in tkclk periods
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: inout std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		reqCmdbusToCmdret: out std_logic;
		wrCmdbusToCmdret: in std_logic;

		rdyCmdbusFromTemp: out std_logic;
		rdCmdbusFromTemp: in std_logic;

		rng: out std_logic;

		sens: in std_logic;
		sw: out std_logic
	);
end Fan;

architecture Fan of Fan is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

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
		stateCmdInvSetRng,
		stateCmdPrepRetGetTpi
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: getTpi, setRng
	-- ret/newret: getTpi

	constant sizeCmdbuf: natural := 11;

	constant tixVCommandGetTpi: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvGetTpi: natural := 10;
	constant lenCmdbufRetGetTpi: natural := 10;
	constant ixCmdbufRetGetTpiTpi: natural := 9;

	constant tixVCommandSetRng: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvSetRng: natural := 11;
	constant ixCmdbufInvSetRngRng: natural := 10;

	signal sw_sig: std_logic;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal dCmdbus_sig, dCmdbus_sig_next: std_logic_vector(7 downto 0);

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
	signal reqCmdbusToCmdret_sig, reqCmdbusToCmdret_sig_next: std_logic;
	signal rdyCmdbusFromTemp_sig, rdyCmdbusFromTemp_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- main operation (op)

	signal rng_sig: std_logic;
	signal tpi, tpi_next: std_logic_vector(7 downto 0);
	signal strbTickrst, strbTickrst_next: std_logic;

	-- IP sigs.op.cust --- INSERT

	---- tick counter (tickcnt)
	type stateTickcnt_t is (
		stateTickcntA, stateTickcntB
	);
	signal stateTickcnt, stateTickcnt_next: stateTickcnt_t := stateTickcntA;

	signal tickcnt, tickcnt_next: std_logic_vector(7 downto 0);

	-- IP sigs.tickcnt.cust --- INSERT

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	sw <= sw_sig;
	dCmdbus <= dCmdbus_sig when (stateCmd=stateCmdSendA or stateCmd=stateCmdSendB or stateCmd=stateCmdSendC) else "ZZZZZZZZ";

	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	reqCmdbusToCmdret <= reqCmdbusToCmdret_sig;
	rdyCmdbusFromTemp <= rdyCmdbusFromTemp_sig;
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
			rdyCmdbusFromCmdinv_sig_next <= '1';
			reqCmdbusToCmdret_sig_next <= '0';
			rdyCmdbusFromTemp_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				rdyCmdbusFromCmdinv_sig_next <= '1';
				reqCmdbusToCmdret_sig_next <= '0';
				rdyCmdbusFromTemp_sig_next <= '1';

				lenCmdbuf := 0;
				i := 0;
				j := 0;
				x := x"00";
				bytecnt := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if ((rdCmdbusFromCmdinv='1' or rdCmdbusFromTemp='1') and clkCmdbus='1') then
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
					if (rdCmdbusFromCmdinv='0' and rdCmdbusFromTemp='0') then
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
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandGetTpi and lenCmdbuf=lenCmdbufInvGetTpi) then
					stateCmd_next <= stateCmdPrepRetGetTpi;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetRng and lenCmdbuf=lenCmdbufInvSetRng) then
					stateCmd_next <= stateCmdInvSetRng;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdFullA then
				if cmdbuf(ixCmdbufRoute)=tixVIdhwIcm2ControllerCmdret then
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

			elsif stateCmd=stateCmdInvSetRng then
				-- IP impl.cmd.rising.invSetRng --- IBEGIN
				if cmdbuf(ixCmdbufInvSetRngRng)=tru8 then
					sw_sig <= '1';
				else
					sw_sig <= '0';
				end if;

				stateCmd_next <= stateCmdInit;
				-- IP impl.cmd.rising.invSetRng --- IEND

				stateCmd_next <= stateCmdInit;

			elsif stateCmd=stateCmdPrepRetGetTpi then
				cmdbuf(ixCmdbufAction) <= tixDbeVActionRet;

				-- IP impl.cmd.rising.prepRetGetTpi --- IBEGIN
				cmdbuf(ixCmdbufRetGetTpiTpi) <= tpi;
				-- IP impl.cmd.rising.prepRetGetTpi --- IEND

				lenCmdbuf := lenCmdbufRetGetTpi;

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
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
			reqCmdbusToCmdret_sig <= reqCmdbusToCmdret_sig_next;
			rdyCmdbusFromTemp_sig <= rdyCmdbusFromTemp_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	rng_sig <= '1' when tpi=x"00" else '0';
	rng <= rng_sig;
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, tkclk)
		-- IP impl.op.rising.vars --- RBEGIN
		variable i: natural range 0 to Ti;

		variable x: std_logic_vector(9 downto 0);
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- RBEGIN
			tpi_next <= x"00";
			strbTickrst_next <= '0';

			i := 0;
			-- IP impl.op.rising.asyncrst --- REND

		elsif rising_edge(tkclk) then
			-- IP impl.op.rising --- IBEGIN
			i := i + 1;
			if i=Ti then
				i := 0;

				-- IIR filter with p=1/4
				x := "00" & tickcnt;
				x := std_logic_vector(unsigned(x) - unsigned(tickcnt(7 downto 2)));
				x := std_logic_vector(unsigned(x) + unsigned(tpi(7 downto 2)));

				tpi_next <= x(7 downto 0);
				strbTickrst_next <= '1';
			else
				strbTickrst_next <= '0';
			end if;
			-- IP impl.op.rising --- IEND
		end if;
	end process;
	-- IP impl.op.rising --- END

	------------------------------------------------------------------------
	-- implementation: tick counter (tickcnt)
	------------------------------------------------------------------------

	-- IP impl.tickcnt.wiring --- BEGIN
	-- IP impl.tickcnt.wiring --- END

	-- IP impl.tickcnt.rising --- BEGIN
	process (reset, tkclk, stateTickcnt)
		-- IP impl.tickcnt.rising.vars --- BEGIN
		-- IP impl.tickcnt.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.tickcnt.rising.asyncrst --- BEGIN
			stateTickcnt_next <= stateTickcntA;
			tickcnt_next <= x"00";
			-- IP impl.tickcnt.rising.asyncrst --- END

		elsif rising_edge(tkclk) then
			if strbTickrst='1' then
				-- IP impl.tickcnt.rising.syncrst --- BEGIN
				tickcnt_next <= x"00";

				stateTickcnt_next <= stateTickcntA;
				-- IP impl.tickcnt.rising.syncrst --- END

			elsif stateTickcnt=stateTickcntA then
				if sens='1' then
					tickcnt_next <= std_logic_vector(unsigned(tickcnt) + 1); -- IP impl.tickcnt.rising.a --- ILINE

					stateTickcnt_next <= stateTickcntB;
				end if;

			elsif stateTickcnt=stateTickcntB then
				if sens='0' then
					stateTickcnt_next <= stateTickcntA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.tickcnt.rising --- END

	-- IP impl.tickcnt.falling --- BEGIN
	process (tkclk)
		-- IP impl.tickcnt.falling.vars --- BEGIN
		-- IP impl.tickcnt.falling.vars --- END
	begin
		if falling_edge(tkclk) then
			stateTickcnt <= stateTickcnt_next;
			tickcnt <= tickcnt_next;
		end if;
	end process;
	-- IP impl.tickcnt.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Fan;


