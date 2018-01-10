-- file Wavegen.vhd
-- Wavegen controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

entity Wavegen is
	generic (
		fMclk: natural range 1 to 1000000
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: in std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		reqBufFromHostif: in std_logic;
		ackBufFromHostif: out std_logic;
		dneBufFromHostif: in std_logic;

		avllenBufFromHostif: out std_logic_vector(10 downto 0);

		dBufFromHostif: in std_logic_vector(7 downto 0);
		strbDBufFromHostif: in std_logic;

		acqrng: in std_logic;
		cmtclk: in std_logic;

		nss: out std_logic;
		sclk: out std_logic;
		mosi: out std_logic;
		miso: in std_logic
	);
end Wavegen;

architecture Wavegen of Wavegen is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Dpbram_v1_0_size2kB is
		port (
			clkA: in std_logic;

			enA: in std_logic;
			weA: in std_logic;

			aA: in std_logic_vector(10 downto 0);
			drdA: out std_logic_vector(7 downto 0);
			dwrA: in std_logic_vector(7 downto 0);

			clkB: in std_logic;

			enB: in std_logic;
			weB: in std_logic;

			aB: in std_logic_vector(10 downto 0);
			drdB: out std_logic_vector(7 downto 0);
			dwrB: in std_logic_vector(7 downto 0)
		);
	end component;

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

	---- buf B/hostif-facing operation (bufB)
	type stateBufB_t is (
		stateBufBIdle,
		stateBufBWriteA, stateBufBWriteB,
		stateBufBFlip
	);
	signal stateBufB, stateBufB_next: stateBufB_t := stateBufBIdle;

	signal enBufB: std_logic;
	signal highNotLowBufB: std_logic;

	signal aBufB, aBufB_next: natural range 0 to 1023;
	signal aBufB_vec: std_logic_vector(10 downto 0);

	signal ackBufFromHostif_sig: std_logic;
	signal avllenBufB_zero, avllenBufB_zero_next: std_logic;

	-- IP sigs.bufB.cust --- INSERT

	---- command execution (cmd)
	type stateCmd_t is (
		stateCmdInit,
		stateCmdEmpty,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD, stateCmdRecvE
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: setRng, setWave

	constant sizeCmdbuf: natural := 16;

	constant tixVCommandSetRng: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvSetRng: natural := 11;
	constant ixCmdbufInvSetRngRng: natural := 10;

	constant tixVCommandSetWave: std_logic_vector(7 downto 0) := x"01";
	constant lenCmdbufInvSetWave: natural := 16;
	constant ixCmdbufInvSetWaveTdly: natural := 10;
	constant ixCmdbufInvSetWaveNsmp: natural := 12;
	constant ixCmdbufInvSetWaveTsmp: natural := 14;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- main and buf A/inward-facing operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpInv,
		stateOpIdle,
		stateOpWaitSmp,
		stateOpLoadA, stateOpLoadB,
		stateOpSetA, stateOpSetB, stateOpSetC, stateOpSetD,
		stateOpFlipA, stateOpFlipB
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal rng, rng_next: std_logic;
	signal enBuf: std_logic;
	signal highNotLowBufA: std_logic;

	signal aBuf, aBuf_next: natural range 0 to 1023;
	signal aBuf_vec: std_logic_vector(10 downto 0);

	signal spilen: std_logic_vector(10 downto 0);
	signal spisend, spisend_next: std_logic_vector(7 downto 0);

	-- IP sigs.op.cust --- INSERT

	---- sample strobe (tsmp)
	type stateTsmp_t is (
		stateTsmpInit,
		stateTsmpInv,
		stateTsmpDelay,
		stateTsmpRun
	);
	signal stateTsmp, stateTsmp_next: stateTsmp_t := stateTsmpInit;

	signal strbTsmp, strbTsmp_next: std_logic;

	-- IP sigs.tsmp.cust --- INSERT

	---- myBuf
	signal drdBuf: std_logic_vector(7 downto 0);

	---- mySpi
	signal strbSpisend: std_logic;

	---- handshake
	-- op to mySpi
	signal reqSpi, reqSpi_next: std_logic;
	signal dneSpi: std_logic;

	-- bufB to op
	signal reqBufBToOpDone: std_logic;
	signal ackBufBToOpDone: std_logic;

	-- cmd to op
	signal reqCmdToOpInvSetRng, reqCmdToOpInvSetRng_next: std_logic;
	signal ackCmdToOpInvSetRng, ackCmdToOpInvSetRng_next: std_logic;

	-- cmd to (many)
	signal reqCmdInvSetWave, reqCmdInvSetWave_next: std_logic;
	signal ackCmdToOpInvSetWave, ackCmdToOpInvSetWave_next: std_logic;
	signal ackCmdToTsmpInvSetWave, ackCmdToTsmpInvSetWave_next: std_logic;

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBuf : Dpbram_v1_0_size2kB
		port map (
			clkA => mclk,

			enA => enBuf,
			weA => '0',

			aA => aBuf_vec,
			drdA => drdBuf,
			dwrA => x"00",

			clkB => mclk,

			enB => enBufB,
			weB => '1',

			aB => aBufB_vec,
			drdB => open,
			dwrB => dBufFromHostif
		);

	mySpi : Spimaster_v1_0
		generic map (
			fMclk => fMclk,

			cpol => '0',
			cpha => '0',

			fSclk => 8333333
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
	-- implementation: buf B/hostif-facing operation (bufB)
	------------------------------------------------------------------------

	-- IP impl.bufB.wiring --- RBEGIN
	enBufB <= '1' when (strbDBufFromHostif='1' and stateBufB=stateBufBWriteB) else '0';

	highNotLowBufB <= not highNotLowBufA;
	aBufB_vec <= highNotLowBufB & std_logic_vector(to_unsigned(aBufB, 10));

	ackBufFromHostif_sig <= '1' when (stateBufB=stateBufBWriteA or stateBufB=stateBufBWriteB) else '0';
	ackBufFromHostif <= ackBufFromHostif_sig;

	avllenBufFromHostif <= std_logic_vector(to_unsigned(1024, 11)) when avllenBufB_zero='0' else (others => '0');

	reqBufBToOpDone <= '1' when stateBufB=stateBufBFlip else '0';
	-- IP impl.bufB.wiring --- REND

	-- IP impl.bufB.rising --- BEGIN
	process (reset, mclk, stateBufB)
		-- IP impl.bufB.rising.vars --- BEGIN
		-- IP impl.bufB.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.bufB.rising.asyncrst --- BEGIN
			stateBufB_next <= stateBufBIdle;
			aBufB_next <= 0;
			avllenBufB_zero_next <= '0';
			-- IP impl.bufB.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateBufB=stateBufBIdle then
				if reqBufFromHostif='1' then
					stateBufB_next <= stateBufBWriteB;
				end if;

			elsif stateBufB=stateBufBWriteA then
				if dneBufFromHostif='1' then
					avllenBufB_zero_next <= '1'; -- IP impl.bufB.rising.writeA.done --- ILINE

					stateBufB_next <= stateBufBFlip;

				elsif reqBufFromHostif='0' then
					stateBufB_next <= stateBufBIdle;

				elsif strbDBufFromHostif='0' then
					aBufB_next <= aBufB + 1; -- IP impl.bufB.rising.writeA.incadr --- ILINE

					stateBufB_next <= stateBufBWriteB;
				end if;

			elsif stateBufB=stateBufBWriteB then
				if strbDBufFromHostif='1' then
					stateBufB_next <= stateBufBWriteA;
				end if;

			elsif stateBufB=stateBufBFlip then
				if ackBufBToOpDone='1' then
					stateBufB_next <= stateBufBIdle;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.bufB.rising --- END

	-- IP impl.bufB.falling --- BEGIN
	process (mclk)
		-- IP impl.bufB.falling.vars --- BEGIN
		-- IP impl.bufB.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateBufB <= stateBufB_next;
			aBufB <= aBufB_next;
			avllenBufB_zero <= avllenBufB_zero_next;
		end if;
	end process;
	-- IP impl.bufB.falling --- END

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
			reqCmdToOpInvSetRng_next <= '0';
			reqCmdInvSetWave_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				reqCmdToOpInvSetRng_next <= '0';
				reqCmdInvSetWave_next <= '0';
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
					reqCmdToOpInvSetRng_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				elsif (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetWave and lenCmdbuf=lenCmdbufInvSetWave) then
					reqCmdInvSetWave_next <= '1';

					stateCmd_next <= stateCmdRecvE;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdRecvE then
				if ((reqCmdToOpInvSetRng='1' and ackCmdToOpInvSetRng='1') or (reqCmdInvSetWave='1' and ackCmdToOpInvSetWave='1' and ackCmdToTsmpInvSetWave='1')) then
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
			reqCmdToOpInvSetRng <= reqCmdToOpInvSetRng_next;
			reqCmdInvSetWave <= reqCmdInvSetWave_next;
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
	-- implementation: main and buf A/inward-facing operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- RBEGIN
	enBuf <= '1' when stateOp=stateOpLoadA else '0';

	ackBufBToOpDone <= '1' when stateOp=stateOpFlipB else '0';

	aBuf_vec <= highNotLowBufA & std_logic_vector(to_unsigned(aBuf, 10));
	-- IP impl.op.wiring --- REND

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		variable Nsmp: natural range 1 to 1024 := 500;

		constant lenTxbuf: natural := 2;
		type txbuf_t is array(0 to lenTxbuf-1) of std_logic_vector(7 downto 0);
		variable txbuf: txbuf_t := (x"00", x"00");

		variable bytecnt: natural range 0 to lenTxbuf;

		variable x: std_logic_vector(9 downto 0);
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- BEGIN
			stateOp_next <= stateOpInit;
			rng_next <= '0';
			aBuf_next <= 0;
			reqSpi_next <= '0';
			spisend_next <= x"00";
			ackCmdToOpInvSetRng_next <= '0';
			ackCmdToOpInvSetWave_next <= '0';
			-- IP impl.op.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpInv and (reqCmdToOpInvSetRng='1' or reqCmdInvSetWave='1' or rng='0' or acqrng='0'))) then
				if reqCmdToOpInvSetRng='1' then
					-- IP impl.op.rising.init.setRng --- IBEGIN
					if cmdbuf(ixCmdbufInvSetRngRng)=tru8 then
						rng_next <= '1';
					else
						rng_next <= '0';
					end if;

					ackCmdToOpInvSetRng_next <= '1';
					ackCmdToOpInvSetWave_next <= '0';
					-- IP impl.op.rising.init.setRng --- IEND

					stateOp_next <= stateOpInv;

				elsif reqCmdInvSetWave='1' then
					-- IP impl.op.rising.init.setWave --- IBEGIN
					x := cmdbuf(ixCmdbufInvSetWaveNsmp)(1 downto 0) & cmdbuf(ixCmdbufInvSetWaveNsmp+1);
					Nsmp := to_integer(unsigned(x));

					ackCmdToOpInvSetRng_next <= '0';
					ackCmdToOpInvSetWave_next <= '1';
					-- IP impl.op.rising.init.setWave --- IEND

					stateOp_next <= stateOpInv;

				else
					-- IP impl.op.rising.syncrst --- BEGIN
					rng_next <= '0';
					aBuf_next <= 0;
					reqSpi_next <= '0';
					spisend_next <= x"00";
					ackCmdToOpInvSetRng_next <= '0';
					ackCmdToOpInvSetWave_next <= '0';

					-- IP impl.op.rising.syncrst --- END

					if (rng='0' or acqrng='0') then
						stateOp_next <= stateOpInit;

					else
						stateOp_next <= stateOpIdle;
					end if;
				end if;

			elsif stateOp=stateOpInv then
				if ((reqCmdToOpInvSetRng='0' and ackCmdToOpInvSetRng='1') or (reqCmdInvSetWave='0' and ackCmdToOpInvSetWave='1')) then
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpIdle then
				if reqBufBToOpDone='1' then
					stateOp_next <= stateOpFlipA;

				elsif (acqrng='1' and cmtclk='1') then
					aBuf_next <= 0; -- IP impl.op.rising.idle.initseq --- ILINE

					stateOp_next <= stateOpWaitSmp;
				end if;

			elsif stateOp=stateOpWaitSmp then
				if strbTsmp='1' then
					stateOp_next <= stateOpLoadA;
				end if;

			elsif stateOp=stateOpLoadA then
				stateOp_next <= stateOpLoadB;

			elsif stateOp=stateOpLoadB then
				-- IP impl.op.rising.loadB --- IBEGIN
				txbuf(0)(3 downto 0) := drdBuf(7 downto 4);
				txbuf(1)(7 downto 4) := drdBuf(3 downto 0);

				spilen <= std_logic_vector(to_unsigned(lenTxbuf, 11));

				bytecnt := 0;
				-- IP impl.op.rising.loadB --- IEND

				stateOp_next <= stateOpSetC;

			elsif stateOp=stateOpSetA then
				if dneSpi='1' then
					-- IP impl.op.rising.setA.done --- IBEGIN
					if aBuf=Nsmp-1 then
						aBuf_next <= 0;
					else
						aBuf_next <= aBuf + 1;
					end if;
					-- IP impl.op.rising.setA.done --- IEND

					stateOp_next <= stateOpWaitSmp;

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

			elsif stateOp=stateOpFlipA then
				highNotLowBufA <= not highNotLowBufA; -- IP impl.op.rising.flipA --- ILINE

				stateOp_next <= stateOpFlipB;

			elsif stateOp=stateOpFlipB then
				if reqBufBToOpDone='0' then
					stateOp_next <= stateOpIdle;
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
			rng <= rng_next;
			aBuf <= aBuf_next;
			reqSpi <= reqSpi_next;
			spisend <= spisend_next;
			ackCmdToOpInvSetRng <= ackCmdToOpInvSetRng_next;
			ackCmdToOpInvSetWave <= ackCmdToOpInvSetWave_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: sample strobe (tsmp)
	------------------------------------------------------------------------

	-- IP impl.tsmp.wiring --- BEGIN
	-- IP impl.tsmp.wiring --- END

	-- IP impl.tsmp.rising --- BEGIN
	process (reset, mclk, stateTsmp)
		-- IP impl.tsmp.rising.vars --- RBEGIN
		variable tdly: natural range 0 to 65535 := 0;
		variable Tsmp: natural range 120 to 65535 := 200; -- can't be below 20*1/8.333MHz=2.4us or 120 due to SPI

		variable i: natural range 0 to 65535; -- delay counter
		variable j: natural range 0 to 65535; -- sample clock counter

		variable x: std_logic_vector(15 downto 0);
		variable y: std_logic_vector(15 downto 0);
		-- IP impl.tsmp.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.tsmp.rising.asyncrst --- BEGIN
			stateTsmp_next <= stateTsmpInit;
			strbTsmp_next <= '0';
			ackCmdToTsmpInvSetWave_next <= '0';
			-- IP impl.tsmp.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateTsmp=stateTsmpInit or (stateTsmp/=stateTsmpInv and (reqCmdInvSetWave='1' or rng='0' or acqrng='0'))) then
				if reqCmdInvSetWave='1' then
					-- IP impl.tsmp.rising.init.setWave --- IBEGIN
					x := cmdbuf(ixCmdbufInvSetWaveTdly) & cmdbuf(ixCmdbufInvSetWaveTdly+1);
					tdly := to_integer(unsigned(x));

					y := cmdbuf(ixCmdbufInvSetWaveTsmp) & cmdbuf(ixCmdbufInvSetWaveTsmp+1);
					Tsmp := to_integer(unsigned(y));

					ackCmdToTsmpInvSetWave_next <= '1';
					-- IP impl.tsmp.rising.init.setWave --- IEND

					stateTsmp_next <= stateTsmpInv;

				else
					-- IP impl.tsmp.rising.syncrst --- RBEGIN
					ackCmdToTsmpInvSetWave_next <= '0';
					-- IP impl.tsmp.rising.syncrst --- REND

					if (rng='0' or acqrng='0') then
						strbTsmp_next <= '0'; -- IP impl.tsmp.rising.init --- ILINE

						stateTsmp_next <= stateTsmpInit;

					else
						if tdly=0 then
							-- IP impl.tsmp.rising.init.initrun --- IBEGIN
							strbTsmp_next <= '1';
							j := 0;
							-- IP impl.tsmp.rising.init.initrun --- IEND

							stateTsmp_next <= stateTsmpRun;

						else
							-- IP impl.tsmp.rising.init.initdly --- IBEGIN
							strbTsmp_next <= '0';
							i := 0;
							-- IP impl.tsmp.rising.init.initdly --- IEND

							stateTsmp_next <= stateTsmpDelay;
						end if;
					end if;
				end if;

			elsif stateTsmp=stateTsmpInv then
				if (reqCmdInvSetWave='0' and ackCmdToTsmpInvSetWave='1') then
					stateTsmp_next <= stateTsmpInit;
				end if;

			elsif stateTsmp=stateTsmpDelay then
				i := i + 1; -- IP impl.tsmp.rising.delay.ext --- ILINE

				if i=tdly then
					-- IP impl.tsmp.rising.delay.initrun --- IBEGIN
					j := 0;
					strbTsmp_next <= '1';
					-- IP impl.tsmp.rising.delay.initrun --- IEND

					stateTsmp_next <= stateTsmpRun;
				end if;

			elsif stateTsmp=stateTsmpRun then
				-- IP impl.tsmp.rising.run --- IBEGIN
				j := j + 1;
				if j=Tsmp then
					strbTsmp_next <= '1';
					j := 0;
				else
					strbTsmp_next <= '0';
				end if;
				-- IP impl.tsmp.rising.run --- IEND
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
			strbTsmp <= strbTsmp_next;
			ackCmdToTsmpInvSetWave <= ackCmdToTsmpInvSetWave_next;
		end if;
	end process;
	-- IP impl.tsmp.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Wavegen;


