-- file Roic.vhd
-- Roic controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

entity Roic is
	generic (
		fMclk: natural range 1 to 1000000
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: in std_logic_vector(7 downto 0);

		rdyCmdbusFromAcq: out std_logic;
		rdCmdbusFromAcq: in std_logic;

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		cmtclk: out std_logic;
		acqrng: in std_logic;
		strbPixstep: in std_logic;
		cmt: out std_logic;
		decmt: out std_logic;

		rst: out std_logic;
		sbs: out std_logic;

		nss: out std_logic;
		sclk: out std_logic;
		mosi: out std_logic;
		miso: in std_logic
	);
end Roic;

architecture Roic of Roic is

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
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: setCmtclk, setMode, setPixel

	constant sizeCmdbuf: natural := 15;

	constant tixVBiasBaseline: std_logic_vector(7 downto 0) := x"00";
	constant tixVBiasDecr16: std_logic_vector(7 downto 0) := x"01";
	constant tixVBiasDecr32: std_logic_vector(7 downto 0) := x"02";
	constant tixVBiasDecr48: std_logic_vector(7 downto 0) := x"03";

	constant tixVCommandSetCmtclk: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvSetCmtclk: natural := 15;
	constant ixCmdbufInvSetCmtclkCmtrng: natural := 10;
	constant ixCmdbufInvSetCmtclkTcmtclk: natural := 11;
	constant ixCmdbufInvSetCmtclkTdphi: natural := 13;

	constant tixVCommandSetMode: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvSetMode: natural := 15;
	constant ixCmdbufInvSetModeFullfrmNotSngpix: natural := 10;
	constant ixCmdbufInvSetModeTixVBias: natural := 11;
	constant ixCmdbufInvSetModeAcgain300not100: natural := 12;
	constant ixCmdbufInvSetModeDcgain40not20: natural := 13;
	constant ixCmdbufInvSetModeAmpbwDecr: natural := 14;

	constant tixVCommandSetPixel: std_logic_vector(7 downto 0) := x"02";
	constant lenCmdbufInvSetPixel: natural := 12;
	constant ixCmdbufInvSetPixelRow: natural := 10;
	constant ixCmdbufInvSetPixelCol: natural := 11;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal rdyCmdbusFromAcq_sig, rdyCmdbusFromAcq_sig_next: std_logic;
	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- commutation clock (cmtclk)
	type stateCmtclk_t is (
		stateCmtclkInit,
		stateCmtclkRun
	);
	signal stateCmtclk, stateCmtclk_next: stateCmtclk_t := stateCmtclkInit;

	signal cmtclk_sig, cmtclk_sig_next: std_logic;
	signal cmt_sig: std_logic;

	-- IP sigs.cmtclk.cust --- INSERT

	---- decommutation clock (decmtclk)
	type stateDecmtclk_t is (
		stateDecmtclkInit,
		stateDecmtclkDelay,
		stateDecmtclkRun
	);
	signal stateDecmtclk, stateDecmtclk_next: stateDecmtclk_t := stateDecmtclkInit;

	signal decmtclk, decmtclk_next: std_logic;

	-- IP sigs.decmtclk.cust --- INSERT

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpInv,
		stateOpReset,
		stateOpSetModeA, stateOpSetModeB, stateOpSetModeC, stateOpSetModeD,
		stateOpSetPixelA, stateOpSetPixelB, stateOpSetPixelC, stateOpSetPixelD,
		stateOpRun,
		stateOpStep
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal rst_sig: std_logic;
	signal sbs_sig: std_logic;
	signal rng: std_logic;
	signal fullfrmNotSngpix: std_logic;

	signal cmtrng: std_logic;
	signal Tcmtclk: natural range 160 to 65535;
	signal tdphi: natural range 0 to 65535;

	signal spilen: std_logic_vector(10 downto 0);
	signal spisend, spisend_next: std_logic_vector(7 downto 0);

	-- IP sigs.op.cust --- INSERT

	---- mySpi
	signal strbSpisend: std_logic;

	---- handshake
	-- op to mySpi
	signal reqSpi, reqSpi_next: std_logic;
	signal dneSpi: std_logic;

	-- cmd to op
	signal reqCmdToOpInvSetCmtclk, reqCmdToOpInvSetCmtclk_next: std_logic;
	signal ackCmdToOpInvSetCmtclk, ackCmdToOpInvSetCmtclk_next: std_logic;

	-- cmd to op
	signal reqCmdToOpInvSetMode, reqCmdToOpInvSetMode_next: std_logic;
	signal ackCmdToOpInvSetMode, ackCmdToOpInvSetMode_next: std_logic;

	-- cmd to op
	signal reqCmdToOpInvSetPixel, reqCmdToOpInvSetPixel_next: std_logic;
	signal ackCmdToOpInvSetPixel, ackCmdToOpInvSetPixel_next: std_logic;

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
			strbSend => strbSpisend,

			recv => open,
			strbRecv => open,

			nss => nss,
			sclk => sclk,
			mosi => mosi,
			miso => miso
		);

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	rdyCmdbusFromAcq <= rdyCmdbusFromAcq_sig;
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
			reqCmdToOpInvSetCmtclk_next <= '0';
			reqCmdToOpInvSetMode_next <= '0';
			reqCmdToOpInvSetPixel_next <= '0';
			rdyCmdbusFromAcq_sig_next <= '1';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				reqCmdToOpInvSetCmtclk_next <= '0';
				reqCmdToOpInvSetMode_next <= '0';
				reqCmdToOpInvSetPixel_next <= '0';
				rdyCmdbusFromAcq_sig_next <= '1';
				rdyCmdbusFromCmdinv_sig_next <= '1';

				lenCmdbuf := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if ((rdCmdbusFromAcq='1' or rdCmdbusFromCmdinv='1') and clkCmdbus='1') then
					rdyCmdbusFromAcq_sig_next <= '0';
					rdyCmdbusFromCmdinv_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;
				end if;

			elsif stateCmd=stateCmdRecvA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvB then
				if clkCmdbus='1' then
					if (rdCmdbusFromAcq='0' and rdCmdbusFromCmdinv='0') then
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
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetCmtclk and lenCmdbuf=lenCmdbufInvSetCmtclk) then
					reqCmdToOpInvSetCmtclk_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetMode and lenCmdbuf=lenCmdbufInvSetMode) then
					reqCmdToOpInvSetMode_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetPixel and lenCmdbuf=lenCmdbufInvSetPixel) then
					reqCmdToOpInvSetPixel_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdRecvE then
				if ((reqCmdToOpInvSetCmtclk='1' and ackCmdToOpInvSetCmtclk='1') or (reqCmdToOpInvSetMode='1' and ackCmdToOpInvSetMode='1') or (reqCmdToOpInvSetPixel='1' and ackCmdToOpInvSetPixel='1')) then
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
			reqCmdToOpInvSetCmtclk <= reqCmdToOpInvSetCmtclk_next;
			reqCmdToOpInvSetMode <= reqCmdToOpInvSetMode_next;
			reqCmdToOpInvSetPixel <= reqCmdToOpInvSetPixel_next;
		end if;
	end process;

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			rdyCmdbusFromAcq_sig <= rdyCmdbusFromAcq_sig_next;
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: commutation clock (cmtclk)
	------------------------------------------------------------------------

	-- IP impl.cmtclk.wiring --- RBEGIN
	cmt_sig <= cmtclk_sig when cmtrng='1' else '0';
	cmt <= cmt_sig;

	cmtclk <= cmtclk_sig;
	-- IP impl.cmtclk.wiring --- REND

	-- IP impl.cmtclk.rising --- BEGIN
	process (reset, mclk, stateCmtclk)
		-- IP impl.cmtclk.rising.vars --- RBEGIN
		variable i: natural range 0 to 32768;
		variable imax: natural range 0 to 32768;
		-- IP impl.cmtclk.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.cmtclk.rising.asyncrst --- BEGIN
			stateCmtclk_next <= stateCmtclkInit;
			cmtclk_sig_next <= '0';
			-- IP impl.cmtclk.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateCmtclk=stateCmtclkInit or rng='0') then
				if rng='0' then
					stateCmtclk_next <= stateCmtclkInit;

				else
					-- IP impl.cmtclk.rising.init.initrun --- IBEGIN
					i := 0;
					imax := to_integer(unsigned(std_logic_vector(to_unsigned(Tcmtclk, 16)(15 downto 1))));

					cmtclk_sig_next <= '1';
					-- IP impl.cmtclk.rising.init.initrun --- IEND

					stateCmtclk_next <= stateCmtclkRun;
				end if;

			elsif stateCmtclk=stateCmtclkRun then
				i := i + 1; -- IP impl.cmtclk.rising.run.ext --- ILINE

				if i=imax then
					-- IP impl.cmtclk.rising.run.toggle --- IBEGIN
					i := 0;
					cmtclk_sig_next <= not cmtclk_sig;
					-- IP impl.cmtclk.rising.run.toggle --- IEND

					stateCmtclk_next <= stateCmtclkRun;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.cmtclk.rising --- END

	-- IP impl.cmtclk.falling --- BEGIN
	process (mclk)
		-- IP impl.cmtclk.falling.vars --- BEGIN
		-- IP impl.cmtclk.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateCmtclk <= stateCmtclk_next;
			cmtclk_sig <= cmtclk_sig_next;
		end if;
	end process;
	-- IP impl.cmtclk.falling --- END

	------------------------------------------------------------------------
	-- implementation: decommutation clock (decmtclk)
	------------------------------------------------------------------------

	-- IP impl.decmtclk.wiring --- BEGIN
	decmt <= decmtclk;
	-- IP impl.decmtclk.wiring --- END

	-- IP impl.decmtclk.rising --- BEGIN
	process (reset, mclk, stateDecmtclk)
		-- IP impl.decmtclk.rising.vars --- RBEGIN
		variable i: natural range 0 to 32768;
		variable imax: natural range 0 to 32768;

		variable j: natural range 0 to 65536;
		-- IP impl.decmtclk.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.decmtclk.rising.asyncrst --- BEGIN
			stateDecmtclk_next <= stateDecmtclkInit;
			decmtclk_next <= '0';
			-- IP impl.decmtclk.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateDecmtclk=stateDecmtclkInit or rng='0') then
				if rng='0' then
					-- IP impl.decmtclk.rising.syncrst --- BEGIN
					decmtclk_next <= '0';

					-- IP impl.decmtclk.rising.syncrst --- END

					stateDecmtclk_next <= stateDecmtclkInit;

				else
					-- IP impl.decmtclk.rising.init.set --- IBEGIN
					i := 0;
					imax := to_integer(unsigned(std_logic_vector(to_unsigned(Tcmtclk, 16)(15 downto 1))));
					-- IP impl.decmtclk.rising.init.set --- IEND

					if tdphi=0 then
						decmtclk_next <= '1'; -- IP impl.decmtclk.rising.init.initrun --- ILINE

						stateDecmtclk_next <= stateDecmtclkRun;

					else
						-- IP impl.decmtclk.rising.init.initdly --- IBEGIN
						decmtclk_next <= '0';
						j := 0;
						-- IP impl.decmtclk.rising.init.initdly --- IEND

						stateDecmtclk_next <= stateDecmtclkDelay;
					end if;
				end if;

			elsif stateDecmtclk=stateDecmtclkDelay then
				j := j + 1; -- IP impl.decmtclk.rising.delay.ext --- ILINE

				if j=tdphi then
					decmtclk_next <= '1'; -- IP impl.decmtclk.rising.delay.initrun --- ILINE

					stateDecmtclk_next <= stateDecmtclkRun;
				end if;

			elsif stateDecmtclk=stateDecmtclkRun then
				i := i + 1; -- IP impl.decmtclk.rising.run.ext --- ILINE

				if i=imax then
					-- IP impl.decmtclk.rising.run.toggle --- IBEGIN
					i := 0;
					decmtclk_next <= not decmtclk;
					-- IP impl.decmtclk.rising.run.toggle --- IEND

					stateDecmtclk_next <= stateDecmtclkRun;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.decmtclk.rising --- END

	-- IP impl.decmtclk.falling --- BEGIN
	process (mclk)
		-- IP impl.decmtclk.falling.vars --- BEGIN
		-- IP impl.decmtclk.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateDecmtclk <= stateDecmtclk_next;
			decmtclk <= decmtclk_next;
		end if;
	end process;
	-- IP impl.decmtclk.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	rst_sig <= '0' when stateOp=stateOpReset else '1';
	rst <= rst_sig;
	sbs_sig <= '0' when (stateOp=stateOpStep and fullfrmNotSngpix='1') else '1';
	sbs <= sbs_sig;
	rng <= '0' when (stateOp=stateOpRun or stateOp=stateOpStep) else '1';
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		variable tixVBias: std_logic_vector(7 downto 0) := tixVBiasBaseline;
		variable acgain300not100: std_logic := '0';
		variable dcgain40not20: std_logic := '0';
		variable ampbwDecr: std_logic := '0';

		variable row: std_logic_vector(2 downto 0) := "000";
		variable col: std_logic_vector(2 downto 0) := "000";

		variable i: natural range 0 to 50; -- 1us
		variable bytecnt: natural range 0 to 2;

		variable x: std_logic_vector(15 downto 0);
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- BEGIN
			stateOp_next <= stateOpInit;
			reqSpi_next <= '0';
			spisend_next <= x"00";
			ackCmdToOpInvSetCmtclk_next <= '0';
			ackCmdToOpInvSetMode_next <= '0';
			ackCmdToOpInvSetPixel_next <= '0';
			-- IP impl.op.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpInv and (reqCmdToOpInvSetCmtclk='1' or reqCmdToOpInvSetMode='1' or reqCmdToOpInvSetPixel='1' or acqrng='0'))) then
				if reqCmdToOpInvSetCmtclk='1' then
					-- IP impl.op.rising.init.setCmtclk --- IBEGIN
					if cmdbuf(ixCmdbufInvSetCmtclkCmtrng)=tru8 then
						cmtrng <= '1';
					else
						cmtrng <= '0';
					end if;

					x := cmdbuf(ixCmdbufInvSetCmtclkTcmtclk) & cmdbuf(ixCmdbufInvSetCmtclkTcmtclk+1);
					Tcmtclk <= to_integer(unsigned(x));

					x := cmdbuf(ixCmdbufInvSetCmtclkTdphi) & cmdbuf(ixCmdbufInvSetCmtclkTdphi+1);
					tdphi <= to_integer(unsigned(x));

					ackCmdToOpInvSetCmtclk_next <= '1';
					ackCmdToOpInvSetMode_next <= '0';
					ackCmdToOpInvSetPixel_next <= '0';
					-- IP impl.op.rising.init.setCmtclk --- IEND

					stateOp_next <= stateOpInv;

				elsif reqCmdToOpInvSetMode='1' then
					-- IP impl.op.rising.init.setMode --- IBEGIN
					if cmdbuf(ixCmdbufInvSetModeFullfrmNotSngpix)=tru8 then
						fullfrmNotSngpix <= '1';
					else
						fullfrmNotSngpix <= '0';
					end if;

					tixVBias := cmdbuf(ixCmdbufInvSetModeTixVBias);
					if cmdbuf(ixCmdbufInvSetModeAcgain300not100)=tru8 then
						acgain300not100 := '1';
					else
						acgain300not100 := '0';
					end if;
					if cmdbuf(ixCmdbufInvSetModeDcgain40not20)=tru8 then
						dcgain40not20 := '1';
					else
						dcgain40not20 := '0';
					end if;
					if cmdbuf(ixCmdbufInvSetModeAmpbwDecr)=tru8 then
						ampbwDecr := '1';
					else
						ampbwDecr := '0';
					end if;

					ackCmdToOpInvSetCmtclk_next <= '0';
					ackCmdToOpInvSetMode_next <= '1';
					ackCmdToOpInvSetPixel_next <= '0';
					-- IP impl.op.rising.init.setMode --- IEND

					stateOp_next <= stateOpInv;

				elsif reqCmdToOpInvSetPixel='1' then
					-- IP impl.op.rising.init.setPixel --- IBEGIN
					row := cmdbuf(ixCmdbufInvSetPixelRow)(2 downto 0);
					col := cmdbuf(ixCmdbufInvSetPixelCol)(2 downto 0);

					ackCmdToOpInvSetCmtclk_next <= '0';
					ackCmdToOpInvSetMode_next <= '0';
					ackCmdToOpInvSetPixel_next <= '1';
					-- IP impl.op.rising.init.setPixel --- IEND

					stateOp_next <= stateOpInv;

				else
					-- IP impl.op.rising.syncrst --- BEGIN
					reqSpi_next <= '0';
					spisend_next <= x"00";
					ackCmdToOpInvSetCmtclk_next <= '0';
					ackCmdToOpInvSetMode_next <= '0';
					ackCmdToOpInvSetPixel_next <= '0';

					-- IP impl.op.rising.syncrst --- END

					if acqrng='0' then
						stateOp_next <= stateOpInit;

					else
						i := 0; -- IP impl.op.rising.init.initrun --- ILINE

						stateOp_next <= stateOpReset;
					end if;
				end if;

			elsif stateOp=stateOpInv then
				if ((reqCmdToOpInvSetCmtclk='0' and ackCmdToOpInvSetCmtclk='1') or (reqCmdToOpInvSetMode='0' and ackCmdToOpInvSetMode='1') or (reqCmdToOpInvSetPixel='0' and ackCmdToOpInvSetPixel='1')) then
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpReset then
				i := i + 1; -- IP impl.op.rising.reset.ext --- ILINE

				if i=50 then
					-- IP impl.op.rising.reset.initspimode --- IBEGIN
					spilen <= std_logic_vector(to_unsigned(2, 11));

					bytecnt := 0;
					-- IP impl.op.rising.reset.initspimode --- IEND

					stateOp_next <= stateOpSetModeC;
				end if;

			elsif stateOp=stateOpSetModeA then
				if dneSpi='1' then
					-- IP impl.op.rising.setModeA.initspipix --- IBEGIN
					reqSpi_next <= '0';

					spilen <= std_logic_vector(to_unsigned(2, 11));

					bytecnt := 0;
					-- IP impl.op.rising.setModeA.initspipix --- IEND

					stateOp_next <= stateOpSetPixelC;

				else
					stateOp_next <= stateOpSetModeB;
				end if;

			elsif stateOp=stateOpSetModeB then
				bytecnt := bytecnt + 1; -- IP impl.op.rising.setModeB --- ILINE

				stateOp_next <= stateOpSetModeC;

			elsif stateOp=stateOpSetModeC then
				-- IP impl.op.rising.setModeC --- IBEGIN
				reqSpi_next <= '1';

				if bytecnt=0 then
					spisend_next <= "00101101";
				elsif bytecnt=1 then
					spisend_next(7 downto 6) <= tixVBias(1 downto 0);
					spisend_next(5) <= ampbwDecr;
					spisend_next(4) <= dcgain40not20;
					spisend_next(3) <= acgain300not100;
					spisend_next(2) <= fullfrmNotSngpix;
					spisend_next(1) <= cmtrng;
					spisend_next(0) <= '0';
				end if;
				-- IP impl.op.rising.setModeC --- IEND

				stateOp_next <= stateOpSetModeD;

			elsif stateOp=stateOpSetModeD then
				if strbSpisend='1' then
					stateOp_next <= stateOpSetModeA;
				end if;

			elsif stateOp=stateOpSetPixelA then
				if dneSpi='1' then
					reqSpi_next <= '0'; -- IP impl.op.rising.setPixelA.done --- ILINE

					stateOp_next <= stateOpRun;

				else
					stateOp_next <= stateOpSetPixelB;
				end if;

			elsif stateOp=stateOpSetPixelB then
				bytecnt := bytecnt + 1; -- IP impl.op.rising.setPixelB --- ILINE

				stateOp_next <= stateOpSetPixelC;

			elsif stateOp=stateOpSetPixelC then
				-- IP impl.op.rising.setPixelC --- IBEGIN
				reqSpi_next <= '1';

				if bytecnt=0 then
					spisend_next <= "00101110";
				elsif bytecnt=1 then
					spisend_next(7) <= not fullfrmNotSngpix;
					spisend_next(6) <= not fullfrmNotSngpix;
					spisend_next(5 downto 3) <= row;
					spisend_next(2 downto 0) <= col;
				end if;
				-- IP impl.op.rising.setPixelC --- IEND

				stateOp_next <= stateOpSetPixelD;

			elsif stateOp=stateOpSetPixelD then
				if strbSpisend='1' then
					stateOp_next <= stateOpSetPixelA;
				end if;

			elsif stateOp=stateOpRun then
				if strbPixstep='1' then
					i := 0; -- IP impl.op.rising.run --- ILINE

					stateOp_next <= stateOpStep;
				end if;

			elsif stateOp=stateOpStep then
				i := i + 1; -- IP impl.op.rising.step.ext --- ILINE

				if i=50 then
					stateOp_next <= stateOpRun;
				end if;
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
			reqSpi <= reqSpi_next;
			spisend <= spisend_next;
			ackCmdToOpInvSetCmtclk <= ackCmdToOpInvSetCmtclk_next;
			ackCmdToOpInvSetMode <= ackCmdToOpInvSetMode_next;
			ackCmdToOpInvSetPixel <= ackCmdToOpInvSetPixel_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Roic;


