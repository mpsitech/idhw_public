-- file Trigger.vhd
-- Trigger controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Trigger is
	generic (
		fMclk: natural range 1 to 1000000 := 50000 -- in kHz
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: in std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		btn: in std_logic;
		trigLwir: out std_logic;
		rng: out std_logic;
		mtrig: out std_logic
	);
end Trigger;

architecture Trigger of Trigger is

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
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: setRng, setTdlyLwir, setTfrm

	constant sizeCmdbuf: natural := 12;

	constant tixVCommandSetRng: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvSetRng: natural := 12;
	constant ixCmdbufInvSetRngRng: natural := 10;
	constant ixCmdbufInvSetRngBtnNotTfrm: natural := 11;

	constant tixVCommandSetTdlyLwir: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvSetTdlyLwir: natural := 12;
	constant ixCmdbufInvSetTdlyLwirTdlyLwir: natural := 10;

	constant tixVCommandSetTfrm: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvSetTfrm: natural := 12;
	constant ixCmdbufInvSetTfrmTfrm: natural := 10;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- LWIR trigger (lwir)
	type stateLwir_t is (
		stateLwirInit,
		stateLwirInv,
		stateLwirReady,
		stateLwirDelayA, stateLwirDelayB, stateLwirDelayC,
		stateLwirOn
	);
	signal stateLwir, stateLwir_next: stateLwir_t := stateLwirInit;

	signal trigLwir_sig: std_logic;

	-- IP sigs.lwir.cust --- INSERT

	---- frame clock (tfrm)
	type stateTfrm_t is (
		stateTfrmInit,
		stateTfrmInv,
		stateTfrmReady,
		stateTfrmRunA, stateTfrmRunB, stateTfrmRunC,
		stateTfrmBtnA, stateTfrmBtnB
	);
	signal stateTfrm, stateTfrm_next: stateTfrm_t := stateTfrmInit;

	signal rng_sig, rng_sig_next: std_logic;
	signal strbTfrm: std_logic;
	signal mtrig_sig: std_logic;

	-- IP sigs.tfrm.cust --- INSERT

	---- handshake
	-- cmd to tfrm
	signal reqCmdToTfrmInvSetRng, reqCmdToTfrmInvSetRng_next: std_logic;
	signal ackCmdToTfrmInvSetRng, ackCmdToTfrmInvSetRng_next: std_logic;

	-- cmd to lwir
	signal reqCmdToLwirInvSetTdlyLwir, reqCmdToLwirInvSetTdlyLwir_next: std_logic;
	signal ackCmdToLwirInvSetTdlyLwir, ackCmdToLwirInvSetTdlyLwir_next: std_logic;

	-- cmd to tfrm
	signal reqCmdToTfrmInvSetTfrm, reqCmdToTfrmInvSetTfrm_next: std_logic;
	signal ackCmdToTfrmInvSetTfrm, ackCmdToTfrmInvSetTfrm_next: std_logic;

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
	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- BEGIN
		variable lenCmdbuf: natural range 0 to sizeCmdbuf := 0;
		-- IP impl.cmd.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			reqCmdToTfrmInvSetRng_next <= '0';
			reqCmdToLwirInvSetTdlyLwir_next <= '0';
			reqCmdToTfrmInvSetTfrm_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				reqCmdToTfrmInvSetRng_next <= '0';
				reqCmdToLwirInvSetTdlyLwir_next <= '0';
				reqCmdToTfrmInvSetTfrm_next <= '0';
				rdyCmdbusFromCmdinv_sig_next <= '1';

				lenCmdbuf := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;
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
					lenCmdbuf := lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvD then
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetRng and lenCmdbuf=lenCmdbufInvSetRng) then
					reqCmdToTfrmInvSetRng_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetTdlyLwir and lenCmdbuf=lenCmdbufInvSetTdlyLwir) then
					reqCmdToLwirInvSetTdlyLwir_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetTfrm and lenCmdbuf=lenCmdbufInvSetTfrm) then
					reqCmdToTfrmInvSetTfrm_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdRecvE then
				if ((reqCmdToTfrmInvSetRng='1' and ackCmdToTfrmInvSetRng='1') or (reqCmdToLwirInvSetTdlyLwir='1' and ackCmdToLwirInvSetTdlyLwir='1') or (reqCmdToTfrmInvSetTfrm='1' and ackCmdToTfrmInvSetTfrm='1')) then
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
			reqCmdToTfrmInvSetRng <= reqCmdToTfrmInvSetRng_next;
			reqCmdToLwirInvSetTdlyLwir <= reqCmdToLwirInvSetTdlyLwir_next;
			reqCmdToTfrmInvSetTfrm <= reqCmdToTfrmInvSetTfrm_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: LWIR trigger (lwir)
	------------------------------------------------------------------------

	-- IP impl.lwir.wiring --- BEGIN
	trigLwir_sig <= '0' when stateLwir=stateLwirOn else '1';
	trigLwir <= trigLwir_sig;
	-- IP impl.lwir.wiring --- END

	-- IP impl.lwir.rising --- BEGIN
	process (reset, mclk, stateLwir)
		-- IP impl.lwir.rising.vars --- RBEGIN
		variable tdly: natural range 0 to 65535;

		variable i: natural range 0 to 65535; -- delay counter
		variable j: natural range 0 to (fMclk/1000); -- counter to 1µs

		variable x: std_logic_vector(15 downto 0);
		-- IP impl.lwir.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.lwir.rising.asyncrst --- BEGIN
			stateLwir_next <= stateLwirInit;
			ackCmdToLwirInvSetTdlyLwir_next <= '0';
			-- IP impl.lwir.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateLwir=stateLwirInit or (stateLwir/=stateLwirInv and (reqCmdToLwirInvSetTdlyLwir='1' or rng_sig='0'))) then
				if reqCmdToLwirInvSetTdlyLwir='1' then
					-- IP impl.lwir.rising.init.set --- IBEGIN
					x := cmdbuf(ixCmdbufInvSetTdlyLwirTdlyLwir) & cmdbuf(ixCmdbufInvSetTdlyLwirTdlyLwir+1);
					tdly := to_integer(unsigned(x));

					ackCmdToLwirInvSetTdlyLwir_next <= '1';
					-- IP impl.lwir.rising.init.set --- IEND

					stateLwir_next <= stateLwirInv;

				else
					-- IP impl.lwir.rising.syncrst --- BEGIN
					ackCmdToLwirInvSetTdlyLwir_next <= '0';

					-- IP impl.lwir.rising.syncrst --- END

					if rng_sig='0' then
						stateLwir_next <= stateLwirInit;

					else
						stateLwir_next <= stateLwirReady;
					end if;
				end if;

			elsif stateLwir=stateLwirInv then
				if (reqCmdToLwirInvSetTdlyLwir='0' and ackCmdToLwirInvSetTdlyLwir='1') then
					stateLwir_next <= stateLwirInit;
				end if;

			elsif stateLwir=stateLwirReady then
				if strbTfrm='1' then
					if tdly=0 then
						j := 0; -- IP impl.lwir.rising.ready.initon --- ILINE

						stateLwir_next <= stateLwirOn;

					else
						i := 0; -- IP impl.lwir.rising.ready.initdly --- ILINE

						stateLwir_next <= stateLwirDelayC;
					end if;
				end if;

			elsif stateLwir=stateLwirDelayA then
				if tkclk='1' then
					j := 0; -- IP impl.lwir.rising.delayA --- ILINE

					stateLwir_next <= stateLwirOn;
				end if;

			elsif stateLwir=stateLwirDelayB then
				if tkclk='1' then
					stateLwir_next <= stateLwirDelayC;
				end if;

			elsif stateLwir=stateLwirDelayC then
				if tkclk='0' then
					i := i + 1; -- IP impl.lwir.rising.delayC.inc --- ILINE

					if i=tdly then
						i := 0; -- IP impl.lwir.rising.delayC.initdly --- ILINE

						stateLwir_next <= stateLwirDelayA;

					else
						stateLwir_next <= stateLwirDelayB;
					end if;
				end if;

			elsif stateLwir=stateLwirOn then
				j := j + 1; -- IP impl.lwir.rising.on.ext --- ILINE

				if j=fMclk/1000 then
					stateLwir_next <= stateLwirReady;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.lwir.rising --- END

	-- IP impl.lwir.falling --- BEGIN
	process (mclk)
		-- IP impl.lwir.falling.vars --- BEGIN
		-- IP impl.lwir.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateLwir <= stateLwir_next;
			ackCmdToLwirInvSetTdlyLwir <= ackCmdToLwirInvSetTdlyLwir_next;
		end if;
	end process;
	-- IP impl.lwir.falling --- END

	------------------------------------------------------------------------
	-- implementation: frame clock (tfrm)
	------------------------------------------------------------------------

	-- IP impl.tfrm.wiring --- RBEGIN
	strbTfrm <= '1' when ((tkclk='1' and stateTfrm=stateTfrmRunA) or (btn='1' and stateTfrm=stateTfrmBtnA)) else '0';

	rng <= rng_sig;

	mtrig <= strbTfrm;
	-- IP impl.tfrm.wiring --- REND

	-- IP impl.tfrm.rising --- BEGIN
	process (reset, mclk, stateTfrm)
		-- IP impl.tfrm.rising.vars --- RBEGIN
		variable btnNotTfrm: std_logic;

		variable Tfrm: natural range 0 to 65535;

		variable i: natural range 0 to 65535; -- frame rate counter

		variable x: std_logic_vector(15 downto 0);
		-- IP impl.tfrm.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.tfrm.rising.asyncrst --- BEGIN
			stateTfrm_next <= stateTfrmInit;
			rng_sig_next <= '0';
			ackCmdToTfrmInvSetRng_next <= '0';
			ackCmdToTfrmInvSetTfrm_next <= '0';
			-- IP impl.tfrm.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateTfrm=stateTfrmInit or (stateTfrm/=stateTfrmInv and (reqCmdToTfrmInvSetRng='1' or reqCmdToTfrmInvSetTfrm='1' or rng_sig='0'))) then
				if reqCmdToTfrmInvSetRng='1' then
					-- IP impl.tfrm.rising.init.invSetRng --- IBEGIN
					if cmdbuf(ixCmdbufInvSetRngRng)=tru8 then
						rng_sig_next <= '1';
					else
						rng_sig_next <= '0';
					end if;
	
					if cmdbuf(ixCmdbufInvSetRngBtnNotTfrm)=fls8 then
						btnNotTfrm := '0';
					else
						btnNotTfrm := '1';
					end if;
	
					ackCmdToTfrmInvSetRng_next <= '1';
					ackCmdToTfrmInvSetTfrm_next <= '0';
					-- IP impl.tfrm.rising.init.invSetRng --- IEND

					stateTfrm_next <= stateTfrmInv;

				elsif reqCmdToTfrmInvSetTfrm='1' then
					-- IP impl.tfrm.rising.init.invSetTfrm --- IBEGIN
					x := cmdbuf(ixCmdbufInvSetTfrmTfrm) & cmdbuf(ixCmdbufInvSetTfrmTfrm+1);
					Tfrm := to_integer(unsigned(x));
	
					ackCmdToTfrmInvSetRng_next <= '0';
					ackCmdToTfrmInvSetTfrm_next <= '1';
					-- IP impl.tfrm.rising.init.invSetTfrm --- IEND

					stateTfrm_next <= stateTfrmInv;

				else
					-- IP impl.tfrm.rising.syncrst --- RBEGIN
					ackCmdToTfrmInvSetRng_next <= '0';
					ackCmdToTfrmInvSetTfrm_next <= '0';
					-- IP impl.tfrm.rising.syncrst --- REND

					if rng_sig='0' then
						stateTfrm_next <= stateTfrmInit;

					else
						stateTfrm_next <= stateTfrmReady;
					end if;
				end if;

			elsif stateTfrm=stateTfrmInv then
				if ((reqCmdToTfrmInvSetRng='0' and ackCmdToTfrmInvSetRng='1') or (reqCmdToTfrmInvSetTfrm='0' and ackCmdToTfrmInvSetTfrm='1')) then
					stateTfrm_next <= stateTfrmInit;
				end if;

			elsif stateTfrm=stateTfrmReady then
				if btnNotTfrm='0' then
					if tkclk='0' then
						i := 0; -- IP impl.tfrm.rising.ready.init --- ILINE

						stateTfrm_next <= stateTfrmRunA;
					end if;

				else
					if btn='0' then
						stateTfrm_next <= stateTfrmBtnA;
					end if;
				end if;

			elsif stateTfrm=stateTfrmRunA then
				if tkclk='1' then
					stateTfrm_next <= stateTfrmRunC;
				end if;

			elsif stateTfrm=stateTfrmRunB then
				if tkclk='1' then
					stateTfrm_next <= stateTfrmRunC;
				end if;

			elsif stateTfrm=stateTfrmRunC then
				if tkclk='0' then
					i := i + 1; -- IP impl.tfrm.rising.runC.inc --- ILINE

					if i=Tfrm then
						i := 0; -- IP impl.tfrm.rising.runC.init --- ILINE

						stateTfrm_next <= stateTfrmRunA;

					else
						stateTfrm_next <= stateTfrmRunB;
					end if;
				end if;

			elsif stateTfrm=stateTfrmBtnA then
				if btn='1' then
					stateTfrm_next <= stateTfrmBtnB;
				end if;

			elsif stateTfrm=stateTfrmBtnB then
				if btn='0' then
					stateTfrm_next <= stateTfrmBtnA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.tfrm.rising --- END

	-- IP impl.tfrm.falling --- BEGIN
	process (mclk)
		-- IP impl.tfrm.falling.vars --- BEGIN
		-- IP impl.tfrm.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateTfrm <= stateTfrm_next;
			rng_sig <= rng_sig_next;
			ackCmdToTfrmInvSetRng <= ackCmdToTfrmInvSetRng_next;
			ackCmdToTfrmInvSetTfrm <= ackCmdToTfrmInvSetTfrm_next;
		end if;
	end process;
	-- IP impl.tfrm.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Trigger;


