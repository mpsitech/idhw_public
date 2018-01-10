-- IP file --- KEEP

-- file Sync.vhd
-- Sync controller implementation
-- author Alexander Wirthmueller
-- date created: 19 Sep 2017
-- date modified: 19 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

entity Sync is
	port (
		reset: in std_logic;
		mclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: in std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		cmtclk: in std_logic;
		sig: out std_logic
	);
end Sync;

architecture Sync of Sync is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

--	---- command execution (cmd)
--	type stateCmd_t is (
--		stateCmdInit,
--		stateCmdEmpty,
--		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE,
--		stateCmdInvSetRng
--	);
--	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;
--
--	-- inv: setPulse, setRng
--
--	constant sizeCmdbuf: natural := 14;
--
--	constant tixVCommandSetPulse: std_logic_vector(7 downto 0) := x"00";
--	constant lenCmdbufInvSetPulse: natural := 14;
--	constant ixCmdbufInvSetPulseTdly: natural := 10;
--	constant ixCmdbufInvSetPulseTon: natural := 12;
--
--	constant tixVCommandSetRng: std_logic_vector(7 downto 0) := x"01";
--	constant lenCmdbufInvSetRng: natural := 11;
--	constant ixCmdbufInvSetRngRng: natural := 10;
--
--	signal rng, rng_next: std_logic;
--
--	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
--	signal cmdbuf: cmdbuf_t;
--
--	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;
--
--	-- IP sigs.cmd.cust --- INSERT
--
--	---- pulse operation (pls)
--	type statePls_t is (
--		statePlsInit,
--		statePlsInv,
--		statePlsWaitCmtclkA, statePlsWaitCmtclkB,
--		statePlsDelay,
--		statePlsOn
--	);
--	signal statePls, statePls_next: statePls_t := statePlsInit;
--
--	signal sig_sig: std_logic;
--
--	-- IP sigs.pls.cust --- INSERT
--
--	---- handshake
--	-- cmd to pls
--	signal reqCmdToPlsInvSetPulse, reqCmdToPlsInvSetPulse_next: std_logic;
--	signal ackCmdToPlsInvSetPulse, ackCmdToPlsInvSetPulse_next: std_logic;
--
--	---- other
--	-- IP sigs.oth.cust --- INSERT

begin

	-- stripped down to meet FPGA area constraint
	rdyCmdbusFromCmdinv <= '0';

	sig <= '0';

--	------------------------------------------------------------------------
--	-- sub-module instantiation
--	------------------------------------------------------------------------
--
--	------------------------------------------------------------------------
--	-- implementation: command execution (cmd)
--	------------------------------------------------------------------------
--
--	-- IP impl.cmd.wiring --- BEGIN
--	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
--	-- IP impl.cmd.wiring --- END
--
--	-- IP impl.cmd.rising --- BEGIN
--	process (reset, mclk, stateCmd)
--		-- IP impl.cmd.rising.vars --- BEGIN
--		variable lenCmdbuf: natural range 0 to sizeCmdbuf := 0;
--		-- IP impl.cmd.rising.vars --- END
--
--	begin
--		if reset='1' then
--			-- IP impl.cmd.rising.asyncrst --- BEGIN
--			stateCmd_next <= stateCmdInit;
--			rng_next <= '0';
--			reqCmdToPlsInvSetPulse_next <= '0';
--			rdyCmdbusFromCmdinv_sig_next <= '1';
--			-- IP impl.cmd.rising.asyncrst --- END
--
--		elsif rising_edge(mclk) then
--			if stateCmd=stateCmdInit then
--				-- IP impl.cmd.rising.syncrst --- BEGIN
--				rng_next <= '0';
--				reqCmdToPlsInvSetPulse_next <= '0';
--				rdyCmdbusFromCmdinv_sig_next <= '1';
--
--				lenCmdbuf := 0;
--				-- IP impl.cmd.rising.syncrst --- END
--
--				stateCmd_next <= stateCmdEmpty;
--
--			elsif stateCmd=stateCmdEmpty then
--				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
--					rdyCmdbusFromCmdinv_sig_next <= '0';
--
--					stateCmd_next <= stateCmdRecvA;
--				end if;
--
--			elsif stateCmd=stateCmdRecvA then
--				if clkCmdbus='0' then
--					stateCmd_next <= stateCmdRecvB;
--				end if;
--
--			elsif stateCmd=stateCmdRecvB then
--				if clkCmdbus='1' then
--					if rdCmdbusFromCmdinv='0' then
--						stateCmd_next <= stateCmdRecvD;
--
--					else
--						cmdbuf(lenCmdbuf) <= dCmdbus;
--
--						stateCmd_next <= stateCmdRecvC;
--					end if;
--				end if;
--
--			elsif stateCmd=stateCmdRecvC then
--				if clkCmdbus='0' then
--					lenCmdbuf := lenCmdbuf + 1;
--
--					stateCmd_next <= stateCmdRecvB;
--				end if;
--
--			elsif stateCmd=stateCmdRecvD then
--				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetPulse and lenCmdbuf=lenCmdbufInvSetPulse) then
--					reqCmdToPlsInvSetPulse_next <= '1';
--
--					stateCmd_next <= stateCmdRecvE;
--
--				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetRng and lenCmdbuf=lenCmdbufInvSetRng) then
--					stateCmd_next <= stateCmdInvSetRng;
--
--				else
--					stateCmd_next <= stateCmdInit;
--				end if;
--
--			elsif stateCmd=stateCmdRecvE then
--				if (reqCmdToPlsInvSetPulse='1' and ackCmdToPlsInvSetPulse='1') then
--					stateCmd_next <= stateCmdInit;
--				end if;
--
--			elsif stateCmd=stateCmdInvSetRng then
--				-- IP impl.cmd.rising.invSetRng --- IBEGIN
--				if cmdbuf(ixCmdbufInvSetRngRng)=tru8 then
--					rng_next <= '1';
--				else
--					rng_next <= '0';
--				end if;
--				-- IP impl.cmd.rising.invSetRng --- IEND
--
--				stateCmd_next <= stateCmdInit;
--			end if;
--		end if;
--	end process;
--	-- IP impl.cmd.rising --- END
--
--	-- IP impl.cmd.falling --- BEGIN
--	process (mclk)
--	begin
--		if falling_edge(mclk) then
--			stateCmd <= stateCmd_next;
--			rng <= rng_next;
--			reqCmdToPlsInvSetPulse <= reqCmdToPlsInvSetPulse_next;
--		end if;
--	end process;
--
--	process (clkCmdbus)
--	begin
--		if falling_edge(clkCmdbus) then
--			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
--		end if;
--	end process;
--	-- IP impl.cmd.falling --- END
--
--	------------------------------------------------------------------------
--	-- implementation: pulse operation (pls)
--	------------------------------------------------------------------------
--
--	-- IP impl.pls.wiring --- RBEGIN
--	sig_sig <= '1' when (rng='1' and statePls=statePlsOn) else '0';
--	sig <= sig_sig;
--	-- IP impl.pls.wiring --- REND
--
--	-- IP impl.pls.rising --- BEGIN
--	process (reset, mclk, statePls)
--		-- IP impl.pls.rising.vars --- RBEGIN
--		variable tdly: natural range 0 to 65535;
--		variable ton: natural range 0 to 65535;
--
--		variable i: natural range 0 to 65536; -- delay counter
--		variable j: natural range 0 to 65536; -- on counter
--
--		variable x: std_logic_vector(15 downto 0);
--		-- IP impl.pls.rising.vars --- REND
--
--	begin
--		if reset='1' then
--			-- IP impl.pls.rising.asyncrst --- BEGIN
--			statePls_next <= statePlsInit;
--			ackCmdToPlsInvSetPulse_next <= '0';
--			-- IP impl.pls.rising.asyncrst --- END
--
--		elsif rising_edge(mclk) then
--			if (statePls=statePlsInit or (statePls/=statePlsInv and (reqCmdToPlsInvSetPulse='1' or rng='0'))) then
--				if reqCmdToPlsInvSetPulse='1' then
--					-- IP impl.pls.rising.init.setPulse --- IBEGIN
--					x := cmdbuf(ixCmdbufInvSetPulseTdly) & cmdbuf(ixCmdbufInvSetPulseTdly+1);
--					tdly := to_integer(unsigned(x));
--
--					x := cmdbuf(ixCmdbufInvSetPulseTon) & cmdbuf(ixCmdbufInvSetPulseTon+1);
--					ton := to_integer(unsigned(x));
--
--					ackCmdToPlsInvSetPulse_next <= '1';
--					-- IP impl.pls.rising.init.setPulse --- IEND
--
--					statePls_next <= statePlsInv;
--
--				else
--					-- IP impl.pls.rising.syncrst --- BEGIN
--					ackCmdToPlsInvSetPulse_next <= '0';
--
--					-- IP impl.pls.rising.syncrst --- END
--
--					if rng='0' then
--						statePls_next <= statePlsInit;
--
--					else
--						statePls_next <= statePlsWaitCmtclkA;
--					end if;
--				end if;
--
--			elsif statePls=statePlsInv then
--				if (reqCmdToPlsInvSetPulse='0' and ackCmdToPlsInvSetPulse='1') then
--					statePls_next <= statePlsInit;
--				end if;
--
--			elsif statePls=statePlsWaitCmtclkA then
--				if cmtclk='0' then
--					statePls_next <= statePlsWaitCmtclkB;
--				end if;
--
--			elsif statePls=statePlsWaitCmtclkB then
--				if cmtclk='1' then
--					if tdly=0 then
--						j := 0; -- IP impl.pls.rising.waitCmtclkB.initon --- ILINE
--
--						statePls_next <= statePlsOn;
--
--					else
--						i := 0; -- IP impl.pls.rising.waitCmtclkB.initdly --- ILINE
--
--						statePls_next <= statePlsDelay;
--					end if;
--				end if;
--
--			elsif statePls=statePlsDelay then
--				i := i + 1; -- IP impl.pls.rising.delay.ext --- ILINE
--
--				if i=tdly then
--					j := 0; -- IP impl.pls.rising.delay.initon --- ILINE
--
--					statePls_next <= statePlsOn;
--				end if;
--
--			elsif statePls=statePlsOn then
--				j := j + 1; -- IP impl.pls.rising.on.ext --- ILINE
--
--				if j=ton then
--					statePls_next <= statePlsWaitCmtclkA;
--				end if;
--			end if;
--		end if;
--	end process;
--	-- IP impl.pls.rising --- END
--
--	-- IP impl.pls.falling --- BEGIN
--	process (mclk)
--		-- IP impl.pls.falling.vars --- BEGIN
--		-- IP impl.pls.falling.vars --- END
--	begin
--		if falling_edge(mclk) then
--			statePls <= statePls_next;
--			ackCmdToPlsInvSetPulse <= ackCmdToPlsInvSetPulse_next;
--		end if;
--	end process;
--	-- IP impl.pls.falling --- END
--
--	------------------------------------------------------------------------
--	-- implementation: other 
--	------------------------------------------------------------------------
--
--	
--	-- IP impl.oth.cust --- INSERT

end Sync;


