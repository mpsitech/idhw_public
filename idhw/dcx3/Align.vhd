-- file Align.vhd
-- Align controller implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 16 Aug 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- IP libs.cust --- INSERT

entity Align is
	generic (
		fMclk: natural range 1 to 1000000
	);
	port (
		reset: in std_logic;

		clkCmdbus: in std_logic;

		mclk: in std_logic;

		trigrng: in std_logic;
		trigVisl: in std_logic;

		dCmdbus: in std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		nss: out std_logic;
		sclk: out std_logic;
		mosi: out std_logic;
		miso: in std_logic
	);
end Align;

architecture Align of Align is

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
		stateCmdInvSetSeq
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	constant tixDbeVActionInv: std_logic_vector(7 downto 0) := x"00";

	constant tixVDcx3ControllerCmdinv: std_logic_vector(7 downto 0) := x"01";

	constant maxlenCmdbuf: natural range 0 to 43 := 43;

	type cmdbuf_t is array (0 to maxlenCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	constant ixCmdbufRoute: natural range 0 to maxlenCmdbuf-1 := 0;
	constant ixCmdbufAction: natural range 0 to maxlenCmdbuf-1 := 4;
	constant ixCmdbufCref: natural range 0 to maxlenCmdbuf-1 := 5;
	constant ixCmdbufInvCommand: natural range 0 to maxlenCmdbuf-1 := 9;

	-- inv: setSeq

	constant tixVCommandSetSeq: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvSetSeq: natural range 0 to maxlenCmdbuf := 43;
	constant ixCmdbufInvSetSeqSeq: natural range 0 to maxlenCmdbuf-1 := 10;

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- main operation
	type stateOp_t is (
		stateOpInit,
		stateOpIdle,
		stateOpInvA, stateOpInvB,
		stateOpReady,
		stateOpSetA, stateOpSetB, stateOpSetC, stateOpSetD
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal reqSpi, reqSpi_next: std_logic;

	signal spilen: std_logic_vector(10 downto 0);

	signal spisend, spisend_next: std_logic_vector(7 downto 0);

	-- IP sigs.op.cust --- IBEGIN
	constant maxlenSeq: natural := 32;

	signal lenSeq: natural range 0 to maxlenSeq := 0;

	type seq_t is array (0 to maxlenSeq-1) of std_logic_vector(7 downto 0);
	signal seq: seq_t;
	-- IP sigs.op.cust --- IEND

	---- other
	signal dneSpi: std_logic;

	signal strbSpisend: std_logic;

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

			nssByteNotXfer => '0',

			fSclk => 8333,
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

			recv => open,
			strbRecv => open
		);

	------------------------------------------------------------------------
	-- implementation: command execution
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- BEGIN
		variable lenCmdbuf: natural range 0 to maxlenCmdbuf;
		-- IP impl.cmd.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
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
					if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetSeq and lenCmdbuf=lenCmdbufInvSetSeq) then
						stateCmd_next <= stateCmdInvSetSeq;

					else
						stateCmd_next <= stateCmdInit;
					end if;

				elsif clkCmdbus='1' then
					cmdbuf(lenCmdbuf) <= dCmdbus;
					lenCmdbuf := lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvA;
				end if;

			elsif stateCmd=stateCmdInvSetSeq then
				-- IP impl.cmd.rising.invSetSeq --- INSERT
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
			rdyCmdbusFromCmdinv_sig <= rdyCmdbusFromCmdinv_sig_next;
		end if;
	end process;
	-- IP impl.cmd.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	ackCmdToOpInvSetSeq <= '1' when stateOp=stateOpInvB else '0';
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		constant lenTxbuf: natural := 2;
		type txbuf_t: array(0 to lenTxbuf-1) of std_logic_vector(7 downto 0);
		variable txbuf: txbuf_t := (x"00", x"00");

		variable bytecnt: natural range 0 to lenTxbuf;

		variable i: natural range 0 to maxlenCmdbuf;
		variable j: natural range 0 to maxlenSeq;

		variable k: natural range 0 to maxlenSeq;

		variable x: std_logic_vector(7 downto 0);
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- BEGIN
			stateOp_next <= stateOpIdle;
			reqSpi_next <= '0';
			spisend_next <= (others => '0');
			-- IP impl.op.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpIdle and stateOp/=stateOpInvA and stateOp/=stateOpInvB and reqCmdToOpInvSetSeq='1') or trigrng='0') then
				-- IP impl.op.rising.syncrst --- BEGIN
				reqSpi_next <= '0';
				spisend_next <= (others => '0');
				-- IP impl.op.rising.syncrst --- END

				if trigrng='0' then
					stateOp_next <= stateOpInit;
				else
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpIdle then
				if reqCmdToOpInvSetSeq='1' then
					lenSeq <= cmdbuf(ixCmdbufInvSetSeqSeq); -- IP impl.op.rising.idle --- ILINE

					if cmdbuf(ixCmdbufInvSetSeqSeq)/=0 then
						-- IP impl.op.rising.idle.initcopy --- IBEGIN
						i := ixCmdbufInvSetSeqSeq+1;
						j := 0;
						-- IP impl.op.rising.idle.initcopy --- IEND

						stateOp_next <= stateOpInvA;
					else
						stateOp_next <= stateOpInvB;
					end if;
				end if;

			elsif stateOp=stateOpInvA then
				-- IP impl.op.rising.invA.ext --- IBEGIN
				x := cmdbuf(i);
				seq(j) <= x;

				i := i + 1;
				j := j + 1;
				-- IP impl.op.rising.invA.ext --- IEND

				if j=lenSeq then
					stateOp_next <= stateOpInvB;
				end if;

			elsif stateOp=stateOpInvB then
				if reqCmdToOpInvSetSeq='0' then
					if lenSeq=0 then
						stateOp_next <= stateOpIdle;
					elsif trigVisl='0' then
						k := 0; -- IP impl.op.rising.invB.initseq --- ILINE
						stateOp_next <= stateOpReady;
					end if;
				end if;

			elsif stateOp=stateOpReady then
				if trigVisl='1' then
					-- IP impl.op.rising.ready --- IBEGIN
					x := seq(k);

					txbuf(0)(3 downto 0) := x(7 downto 4);
					txbuf(1)(7 downto 4) := x(3 downto 0);

					spilen <= std_logic_vector(to_unsigned(lenTxbuf, 11));

					bytecnt := 0;
					-- IP impl.op.rising.ready --- IEND

					stateOp_next <= stateOpSetC;
				end if;

			elsif stateOp=stateOpSetA then
				if dneSpi='1' then
					-- IP impl.op.rising.setA.done --- IBEGIN
					reqSpi_next <= '0';

					k := k + 1;
					if k=lenSeq then
						k := 0;
					end if;
					-- IP impl.op.rising.setA.done --- IEND

					stateOp_next <= stateOpReady; -- xfer longer than trigVisl high (1us)
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
			reqSpi <= reqSpi_next;
			spisend <= spisend_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Align;

