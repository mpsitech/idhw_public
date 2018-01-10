-- file Cmdinv.vhd
-- Cmdinv cmdinv_v1_0 command invocation buffer implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Cmdinv is
	port (
		reset: in std_logic;
		mclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: inout std_logic_vector(7 downto 0);

		reqCmdbusToAlua: out std_logic;
		wrCmdbusToAlua: in std_logic;

		reqCmdbusToAlub: out std_logic;
		wrCmdbusToAlub: in std_logic;

		reqCmdbusToDcxif: out std_logic;
		wrCmdbusToDcxif: in std_logic;

		reqCmdbusToLwiracq: out std_logic;
		wrCmdbusToLwiracq: in std_logic;

		reqCmdbusToLwiremu: out std_logic;
		wrCmdbusToLwiremu: in std_logic;

		reqCmdbusToPhiif: out std_logic;
		wrCmdbusToPhiif: in std_logic;

		reqCmdbusToPmmu: out std_logic;
		wrCmdbusToPmmu: in std_logic;

		reqCmdbusToQcdif: out std_logic;
		wrCmdbusToQcdif: in std_logic;

		reqCmdbusToThetaif: out std_logic;
		wrCmdbusToThetaif: in std_logic;

		reqCmdbusToTkclksrc: out std_logic;
		wrCmdbusToTkclksrc: in std_logic;

		reqCmdbusToTrigger: out std_logic;
		wrCmdbusToTrigger: in std_logic;

		reqBufFromHostif: in std_logic;
		ackBufFromHostif: out std_logic;
		dneBufFromHostif: in std_logic;

		avllenBufFromHostif: out std_logic_vector(5 downto 0);

		dBufFromHostif: in std_logic_vector(7 downto 0);
		strbDBufFromHostif: in std_logic
	);
end Cmdinv;

architecture Cmdinv of Cmdinv is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Dpbram_v1_0_size4kB is
		port (
			clkA: in std_logic;

			enA: in std_logic;
			weA: in std_logic;

			aA: in std_logic_vector(11 downto 0);
			drdA: out std_logic_vector(7 downto 0);
			dwrA: in std_logic_vector(7 downto 0);

			clkB: in std_logic;

			enB: in std_logic;
			weB: in std_logic;

			aB: in std_logic_vector(11 downto 0);
			drdB: out std_logic_vector(7 downto 0);
			dwrB: in std_logic_vector(7 downto 0)
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- buf
	constant sizeBuf: natural := 4096;
	constant sizeTocBuf: natural := 256;

	constant maxlenInv: natural := 57;

	---- buf command bus-facing operation (buf)
	type stateBuf_t is (
		stateBufInit,
		stateBufIdle,
		stateBufSendInvA, stateBufSendInvB, stateBufSendInvC, stateBufSendInvD, stateBufSendInvE,
		stateBufSendInvF, stateBufSendInvG, stateBufSendInvH,
		stateBufWaitStuff,
		stateBufUpdReqA, stateBufUpdReqB, stateBufUpdReqC, stateBufUpdReqD, stateBufUpdReqE,
		stateBufUpdReqF
	);
	signal stateBuf, stateBuf_next: stateBuf_t := stateBufIdle;

	signal enBuf: std_logic;

	signal aBuf, aBuf_next: natural range 0 to sizeBuf := 0;
	signal aBuf_vec: std_logic_vector(11 downto 0);

	signal ixTocBuf: natural range 0 to sizeTocBuf-1 := 0; -- used by bufB
	signal a0Buf: natural range 0 to sizeBuf-1 := 0;

	constant a0TocBuf: natural := sizeBuf-sizeTocBuf;

	signal dCmdbus_sig: std_logic_vector(7 downto 0);

	signal wrCmdbusToAny: std_logic;

	signal reqCmdbus, reqCmdbus_next: std_logic;

	signal reqCmdbusToAlua_sig: std_logic := '0';
	signal ixTocBufAlua: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufAlua: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToAlub_sig: std_logic := '0';
	signal ixTocBufAlub: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufAlub: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToDcxif_sig: std_logic := '0';
	signal ixTocBufDcxif: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufDcxif: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToLwiracq_sig: std_logic := '0';
	signal ixTocBufLwiracq: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufLwiracq: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToLwiremu_sig: std_logic := '0';
	signal ixTocBufLwiremu: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufLwiremu: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToPhiif_sig: std_logic := '0';
	signal ixTocBufPhiif: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufPhiif: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToPmmu_sig: std_logic := '0';
	signal ixTocBufPmmu: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufPmmu: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToQcdif_sig: std_logic := '0';
	signal ixTocBufQcdif: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufQcdif: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToThetaif_sig: std_logic := '0';
	signal ixTocBufThetaif: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufThetaif: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToTkclksrc_sig: std_logic := '0';
	signal ixTocBufTkclksrc: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufTkclksrc: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToTrigger_sig: std_logic := '0';
	signal ixTocBufTrigger: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufTrigger: natural range 0 to sizeBuf-1 := 0;

	---- buf outward/hostif-facing operation (bufB)
	type stateBufB_t is (
		stateBufBInitA, stateBufBInitB, stateBufBInitC, stateBufBInitD,
		stateBufBIdle,
		stateBufBXferA, stateBufBXferB,
		stateBufBStuffA, stateBufBStuffB, stateBufBStuffC, stateBufBStuffD, stateBufBStuffE,
		stateBufBStuffF, stateBufBStuffG, stateBufBStuffH, stateBufBStuffI, stateBufBStuffJ,
		stateBufBStuffK, stateBufBStuffL, stateBufBStuffM, stateBufBStuffN, stateBufBStuffO,
		stateBufBUpdTocA, stateBufBUpdTocB,
		stateBufBWaitUpdReq
	);
	signal stateBufB, stateBufB_next: stateBufB_t := stateBufBIdle;

	signal lenBuf, lenBuf_next: natural range 0 to sizeBuf := 0;
	constant maxlenBuf: natural := sizeBuf-sizeTocBuf-maxlenInv;

	signal enBufB: std_logic;
	signal weBufB: std_logic;

	signal aBufB, aBufB_next: natural range 0 to sizeBuf := 0;
	signal aBufB_vec: std_logic_vector(11 downto 0);
	signal dwrBufB, dwrBufB_sig: std_logic_vector(7 downto 0);

	signal lenTocBuf, lenTocBuf_next: natural range 0 to sizeTocBuf := 0;

	signal avllenBufFromHostif_zero, avllenBufFromHostif_zero_next: std_logic;

	---- myBuf
	signal drdBuf: std_logic_vector(7 downto 0);
	signal drdBufB: std_logic_vector(7 downto 0);

	---- handshake
	-- bufB to buf
	signal reqBufBToBufUpdReq: std_logic;
	signal ackBufBToBufUpdReq: std_logic;

	-- buf to bufB
	signal reqBufToBufBStuff: std_logic;
	signal ackBufToBufBStuff: std_logic;

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBuf : Dpbram_v1_0_size4kB
		port map (
			clkA => mclk,

			enA => enBuf,
			weA => '0',

			aA => aBuf_vec,
			drdA => drdBuf,
			dwrA => x"00",

			clkB => mclk,

			enB => enBufB,
			weB => weBufB,

			aB => aBufB_vec,
			drdB => drdBufB,
			dwrB => dwrBufB
		);

	------------------------------------------------------------------------
	-- implementation: buf command bus-facing operation (buf)
	------------------------------------------------------------------------

	a0Buf <= a0BufAlua when ixTocBuf=ixTocBufAlua
				else a0BufAlub when ixTocBuf=ixTocBufAlub
				else a0BufDcxif when ixTocBuf=ixTocBufDcxif
				else a0BufLwiracq when ixTocBuf=ixTocBufLwiracq
				else a0BufLwiremu when ixTocBuf=ixTocBufLwiremu
				else a0BufPhiif when ixTocBuf=ixTocBufPhiif
				else a0BufPmmu when ixTocBuf=ixTocBufPmmu
				else a0BufQcdif when ixTocBuf=ixTocBufQcdif
				else a0BufThetaif when ixTocBuf=ixTocBufThetaif
				else a0BufTkclksrc when ixTocBuf=ixTocBufTkclksrc
				else a0BufTrigger when ixTocBuf=ixTocBufTrigger
				else 0;

	ackBufBToBufUpdReq <= '1' when stateBuf=stateBufUpdReqF else '0';

	reqBufToBufBStuff <= '1' when stateBuf=stateBufWaitStuff else '0';

	enBuf <= '1' when (stateBuf=stateBufSendInvB or stateBuf=stateBufSendInvD or stateBuf=stateBufSendInvG or stateBuf=stateBufUpdReqB or stateBuf=stateBufUpdReqD) else '0';
	
	aBuf_vec <= std_logic_vector(to_unsigned(aBuf, 12));

	wrCmdbusToAny <= '1' when (wrCmdbusToAlua='1' or wrCmdbusToAlub='1' or wrCmdbusToDcxif='1' or wrCmdbusToLwiracq='1' or wrCmdbusToLwiremu='1' or wrCmdbusToPhiif='1' or wrCmdbusToPmmu='1' or wrCmdbusToQcdif='1' or wrCmdbusToThetaif='1' or wrCmdbusToTkclksrc='1' or wrCmdbusToTrigger='1') else'0';

	dCmdbus <= dCmdbus_sig when wrCmdbusToAny='1' else "ZZZZZZZZ";
	
	reqCmdbusToAlua <= reqCmdbusToAlua_sig when reqCmdbus='1' else '0';
	reqCmdbusToAlub <= reqCmdbusToAlub_sig when reqCmdbus='1' else '0';
	reqCmdbusToDcxif <= reqCmdbusToDcxif_sig when reqCmdbus='1' else '0';
	reqCmdbusToLwiracq <= reqCmdbusToLwiracq_sig when reqCmdbus='1' else '0';
	reqCmdbusToLwiremu <= reqCmdbusToLwiremu_sig when reqCmdbus='1' else '0';
	reqCmdbusToPhiif <= reqCmdbusToPhiif_sig when reqCmdbus='1' else '0';
	reqCmdbusToPmmu <= reqCmdbusToPmmu_sig when reqCmdbus='1' else '0';
	reqCmdbusToQcdif <= reqCmdbusToQcdif_sig when reqCmdbus='1' else '0';
	reqCmdbusToThetaif <= reqCmdbusToThetaif_sig when reqCmdbus='1' else '0';
	reqCmdbusToTkclksrc <= reqCmdbusToTkclksrc_sig when reqCmdbus='1' else '0';
	reqCmdbusToTrigger <= reqCmdbusToTrigger_sig when reqCmdbus='1' else '0';

	process (reset, mclk, stateBuf)
		variable i: natural range 0 to maxlenInv;
		variable j: natural range 0 to sizeTocBuf; -- toc index
		variable k: natural range 0 to sizeBuf-1; -- inv start address

		variable lenInv: natural range 0 to maxlenInv;

	begin
		if reset='1' then
			stateBuf_next <= stateBufInit;
			aBuf_next <= 0;
			dCmdbus_sig <= x"00";
			reqCmdbus <= '0';

		elsif rising_edge(mclk) then
			if stateBuf=stateBufInit then
				aBuf_next <= 0;
				dCmdbus_sig <= x"00";
				reqCmdbus <= '0';

				if reqBufBToBufUpdReq='1' then
					stateBuf_next <= stateBufUpdReqA;
				end if;

			elsif stateBuf=stateBufIdle then
				if (clkCmdbus='1' and wrCmdbusToAny='1') then -- priority for command bus
					if wrCmdbusToAlua='1' then
						ixTocBuf <= ixTocBufAlua;
					elsif wrCmdbusToAlub='1' then
						ixTocBuf <= ixTocBufAlub;
					elsif wrCmdbusToDcxif='1' then
						ixTocBuf <= ixTocBufDcxif;
					elsif wrCmdbusToLwiracq='1' then
						ixTocBuf <= ixTocBufLwiracq;
					elsif wrCmdbusToLwiremu='1' then
						ixTocBuf <= ixTocBufLwiremu;
					elsif wrCmdbusToPhiif='1' then
						ixTocBuf <= ixTocBufPhiif;
					elsif wrCmdbusToPmmu='1' then
						ixTocBuf <= ixTocBufPmmu;
					elsif wrCmdbusToQcdif='1' then
						ixTocBuf <= ixTocBufQcdif;
					elsif wrCmdbusToThetaif='1' then
						ixTocBuf <= ixTocBufThetaif;
					elsif wrCmdbusToTkclksrc='1' then
						ixTocBuf <= ixTocBufTkclksrc;
					elsif wrCmdbusToTrigger='1' then
						ixTocBuf <= ixTocBufTrigger;
					end if;

					stateBuf_next <= stateBufSendInvA;

				elsif (clkCmdbus='0' and reqBufBToBufUpdReq='1') then -- sync reqCmdbus correctly
					reqCmdbus <= '0';
					stateBuf_next <= stateBufUpdReqA;
				end if;

			elsif stateBuf=stateBufSendInvA then
				-- cmdbus timing requires loading first byte before lenInv
				i := 0;

				aBuf_next <= a0Buf;

				stateBuf_next <= stateBufSendInvB;

			elsif stateBuf=stateBufSendInvB then -- enBuf='1'
				stateBuf_next <= stateBufSendInvC;

			elsif stateBuf=stateBufSendInvC then
				if clkCmdbus='0' then
					dCmdbus_sig <= drdBuf;
					i := i + 1;
					
					-- load lenInv only now
					aBuf_next <= a0TocBuf + ixTocBuf;

					stateBuf_next <= stateBufSendInvD;
				end if;

			elsif stateBuf=stateBufSendInvD then -- enBuf='1'
				stateBuf_next <= stateBufSendInvE;

			elsif stateBuf=stateBufSendInvE then
				lenInv := to_integer(unsigned(drdBuf));

				-- proceed in the regular way
				aBuf_next <= a0Buf + 1;
				if clkCmdbus='0' then
					stateBuf_next <= stateBufSendInvF;
				else
					stateBuf_next <= stateBufSendInvG;
				end if;

			elsif stateBuf=stateBufSendInvF then
				if clkCmdbus='1' then
					stateBuf_next <= stateBufSendInvG;
				end if;

			elsif stateBuf=stateBufSendInvG then -- enBuf='1'
				stateBuf_next <= stateBufSendInvH;

			elsif stateBuf=stateBufSendInvH then
				if clkCmdbus='0' then
					dCmdbus_sig <= drdBuf;

					i := i + 1;
					aBuf_next <= aBuf + 1;
					
					if i=lenInv then
						reqCmdbus <= '0';
						stateBuf_next <= stateBufWaitStuff;
					else
						stateBuf_next <= stateBufSendInvF;
					end if;
				end if;

			elsif stateBuf=stateBufWaitStuff then
				if ackBufToBufBStuff='1' then
					stateBuf_next <= stateBufUpdReqA;
				end if;

			elsif stateBuf=stateBufUpdReqA then
				-- separate preparation state due to multiple possibilities for previous state
				j := 0;
				k := 0;
				aBuf_next <= a0TocBuf;

				reqCmdbusToAlua_sig <= '0';
				reqCmdbusToAlub_sig <= '0';
				reqCmdbusToDcxif_sig <= '0';
				reqCmdbusToLwiracq_sig <= '0';
				reqCmdbusToLwiremu_sig <= '0';
				reqCmdbusToPhiif_sig <= '0';
				reqCmdbusToPmmu_sig <= '0';
				reqCmdbusToQcdif_sig <= '0';
				reqCmdbusToThetaif_sig <= '0';
				reqCmdbusToTkclksrc_sig <= '0';
				reqCmdbusToTrigger_sig <= '0';

				stateBuf_next <= stateBufUpdReqB;

			elsif stateBuf=stateBufUpdReqB then -- enBuf='1'
				if j=lenTocBuf then
					stateBuf_next <= stateBufUpdReqF;
				else
					stateBuf_next <= stateBufUpdReqC;
				end if;

			elsif stateBuf=stateBufUpdReqC then
				lenInv := to_integer(unsigned(drdBuf));

				aBuf_next <= k;

				stateBuf_next <= stateBufUpdReqD;

			elsif stateBuf=stateBufUpdReqD then -- enBuf='1'
				stateBuf_next <= stateBufUpdReqE;

			elsif stateBuf=stateBufUpdReqE then
				if (drdBuf=tixVIdhwZedbControllerAlua and reqCmdbusToAlua_sig='0') then
					reqCmdbusToAlua_sig <= '1';
					ixTocBufAlua <= j;
					a0BufAlua <= k;
				elsif (drdBuf=tixVIdhwZedbControllerAlub and reqCmdbusToAlub_sig='0') then
					reqCmdbusToAlub_sig <= '1';
					ixTocBufAlub <= j;
					a0BufAlub <= k;
				elsif (drdBuf=tixVIdhwZedbControllerDcxif and reqCmdbusToDcxif_sig='0') then
					reqCmdbusToDcxif_sig <= '1';
					ixTocBufDcxif <= j;
					a0BufDcxif <= k;
				elsif (drdBuf=tixVIdhwZedbControllerLwiracq and reqCmdbusToLwiracq_sig='0') then
					reqCmdbusToLwiracq_sig <= '1';
					ixTocBufLwiracq <= j;
					a0BufLwiracq <= k;
				elsif (drdBuf=tixVIdhwZedbControllerLwiremu and reqCmdbusToLwiremu_sig='0') then
					reqCmdbusToLwiremu_sig <= '1';
					ixTocBufLwiremu <= j;
					a0BufLwiremu <= k;
				elsif (drdBuf=tixVIdhwZedbControllerPhiif and reqCmdbusToPhiif_sig='0') then
					reqCmdbusToPhiif_sig <= '1';
					ixTocBufPhiif <= j;
					a0BufPhiif <= k;
				elsif (drdBuf=tixVIdhwZedbControllerPmmu and reqCmdbusToPmmu_sig='0') then
					reqCmdbusToPmmu_sig <= '1';
					ixTocBufPmmu <= j;
					a0BufPmmu <= k;
				elsif (drdBuf=tixVIdhwZedbControllerQcdif and reqCmdbusToQcdif_sig='0') then
					reqCmdbusToQcdif_sig <= '1';
					ixTocBufQcdif <= j;
					a0BufQcdif <= k;
				elsif (drdBuf=tixVIdhwZedbControllerThetaif and reqCmdbusToThetaif_sig='0') then
					reqCmdbusToThetaif_sig <= '1';
					ixTocBufThetaif <= j;
					a0BufThetaif <= k;
				elsif (drdBuf=tixVIdhwZedbControllerTkclksrc and reqCmdbusToTkclksrc_sig='0') then
					reqCmdbusToTkclksrc_sig <= '1';
					ixTocBufTkclksrc <= j;
					a0BufTkclksrc <= k;
				elsif (drdBuf=tixVIdhwZedbControllerTrigger and reqCmdbusToTrigger_sig='0') then
					reqCmdbusToTrigger_sig <= '1';
					ixTocBufTrigger <= j;
					a0BufTrigger <= k;
				end if;

				j := j + 1;
				aBuf_next <= a0TocBuf + j;

				k := k + lenInv;

				stateBuf_next <= stateBufUpdReqB;

			elsif stateBuf=stateBufUpdReqF then -- ackBufBToBufUpdReq='1'
				if (clkCmdbus='0' and reqBufBToBufUpdReq='0') then -- sync reqCmdbus correctly
					reqCmdbus <= '1';
					stateBuf_next <= stateBufIdle;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateBuf <= stateBuf_next;
			aBuf <= aBuf_next;
		end if;
	end process;
	
	------------------------------------------------------------------------
	-- implementation: buf outward/hostif-facing operation (bufB)
	------------------------------------------------------------------------

	ackBufFromHostif <= '1' when (stateBufB=stateBufBXferA or stateBufB=stateBufBXferB) else '0';

	reqBufBToBufUpdReq <= '1' when (stateBufB=stateBufBInitD or stateBufB=stateBufBWaitUpdReq) else '0';

	ackBufToBufBStuff <= '1' when stateBufB=stateBufBStuffO else '0';

	enBufB <= '1' when (stateBufB=stateBufBInitC or (stateBufB=stateBufBXferB and strbDBufFromHostif='1') or stateBufB=stateBufBStuffB or stateBufB=stateBufBStuffE or stateBufB=stateBufBStuffH
				or stateBufB=stateBufBStuffJ or stateBufB=stateBufBStuffL or stateBufB=stateBufBStuffN or stateBufB=stateBufBUpdTocB) else '0';

	weBufB <= '1' when (stateBufB=stateBufBInitC or stateBufB=stateBufBXferB or stateBufB=stateBufBStuffJ or stateBufB=stateBufBStuffN or stateBufB=stateBufBUpdTocB) else '0';

	aBufB_vec <= std_logic_vector(to_unsigned(aBufB, 12));

	dWrbufB <= dBufFromHostif when (stateBufB=stateBufBXferA or stateBufB=stateBufBXferB) else dWrbufB_sig;

	avllenBufFromHostif <= std_logic_vector(to_unsigned(maxlenInv, 6)) when avllenBufFromHostif_zero='0' else (others => '0');

	process (reset, mclk, stateBufB)
		variable i, j: natural range 0 to sizeBuf;
		variable k, l: natural range 0 to sizeTocBuf;
		variable m: natural range 0 to sizeTocBuf-1;

		variable difflen: natural range 0 to maxlenInv;

	begin
		if reset='1' then
			stateBufB_next <= stateBufBInitA;
			lenTocBuf_next <= 0;
			lenBuf_next <= 0;
			aBufB_next <= 0;
			avllenBufFromHostif_zero_next <= '1';

		elsif rising_edge(mclk) then
			if stateBufB=stateBufBInitA then
				lenTocBuf_next <= 0;
				lenBuf_next <= 0;
				aBufB_next <= 0;
				avllenBufFromHostif_zero_next <= '1';

				k := 0;
				
				stateBufB_next <= stateBufBInitB;

			elsif stateBufB=stateBufBInitB then
				if k=sizeTocbuf then
					stateBufB_next <= stateBufBInitD;
				else
					aBufB_next <= a0TocBuf + k;
					dwrBufB_sig <= x"00";
					stateBufB_next <= stateBufBInitC;
				end if;

			elsif stateBufB=stateBufBInitC then -- enBufB='1', weBufB='1'
				k := k + 1;
				stateBufB_next <= stateBufBInitB;

			elsif stateBufB=stateBufBInitD then -- reqBufBToBufUpdReq='1'
				if ackBufBToBufUpdReq='1' then
					avllenBufFromHostif_zero_next <= '0';
					stateBufB_next <= stateBufBIdle;
				end if;

			elsif stateBufB=stateBufBIdle then
				if reqBufFromHostif='1' then
					aBufB_next <= lenBuf;
					stateBufB_next <= stateBufBXferB;
				elsif reqBufToBufBStuff='1' then
					aBufB_next <= a0TocBuf + ixTocBuf;
					stateBufB_next <= stateBufBStuffA;
				end if;

			elsif stateBufB=stateBufBXferA then
				if reqBufFromHostif='0' then
					stateBufB_next <= stateBufBIdle;
				elsif dneBufFromHostif='1' then
					aBufB_next <= aBufB + 1;
					avllenBufFromHostif_zero_next <= '1';
					stateBufB_next <= stateBufBUpdTocA;
				elsif strbDBufFromHostif='0' then
					aBufB_next <= aBufB + 1;
					stateBufB_next <= stateBufBXferB;
				end if;

			elsif stateBufB=stateBufBXferB then -- enBufB='1', weBufB='1' if strbDBufFromHostif='1', i.e. for one clock
				if reqBufFromHostif='0' then
					stateBufB_next <= stateBufBIdle;
				elsif strbDBufFromHostif='1' then
					stateBufB_next <= stateBufBXferA;
				end if;

			elsif stateBufB=stateBufBStuffA then -- part 1: retrieve difflen=tocBuf(ixTocBuf)
				stateBufB_next <= stateBufBStuffB;

			elsif stateBufB=stateBufBStuffB then -- enBufB='1', weBufB='0'
				stateBufB_next <= stateBufBStuffC;

			elsif stateBufB=stateBufBStuffC then
				i := 0;
				m := 0;
				difflen := to_integer(unsigned(drdBufB));
				stateBufB_next <= stateBufBStuffD;

			elsif stateBufB=stateBufBStuffD then -- part 2: sum up i=tocBuf(ix=0..ixTocBuf-1)
				if m=ixTocBuf then
					j := i + difflen;
					aBufB_next <= j;
					stateBufB_next <= stateBufBStuffG;
				else
					aBufB_next <= a0TocBuf + m;
					stateBufB_next <= stateBufBStuffE;
				end if;

			elsif stateBufB=stateBufBStuffE then -- enBufB='1', weBufB='0'
				stateBufB_next <= stateBufBStuffF;

			elsif stateBufB=stateBufBStuffF then
				i := i + to_integer(unsigned(drdBufB));
				m := m + 1;

				stateBufB_next <= stateBufBStuffD;

			elsif stateBufB=stateBufBStuffG then -- part 3: stuff buf
				if j=lenBuf then
					lenBuf_next <= lenBuf - difflen;
					k := ixTocBuf;
					l := k + 1;
					stateBufB_next <= stateBufBStuffK;
				else
					aBufB_next <= j;
					stateBufB_next <= stateBufBStuffH;
				end if;

			elsif stateBufB=stateBufBStuffH then -- enBufB='1', weBufB='0'
				stateBufB_next <= stateBufBStuffI;

			elsif stateBufB=stateBufBStuffI then
				aBufB_next <= i;
				dwrBufB_sig <= drdBufB;
				stateBufB_next <= stateBufBStuffJ;

			elsif stateBufB=stateBufBStuffJ then -- enBufB='1', weBufB='1'
				i := i + 1;
				j := j + 1;
				stateBufB_next <= stateBufBStuffG;

			elsif stateBufB=stateBufBStuffK then -- part 4: stuff tocBuf
				if l=lenTocBuf then
					lenTocBuf_next <= lenTocBuf - 1;
					if lenBuf<maxlenBuf then
						avllenBufFromHostif_zero_next <= '0';
					end if;
					stateBufB_next <= stateBufBStuffO;
				else
					aBufB_next <= a0TocBuf + l;
					stateBufB_next <= stateBufBStuffL;
				end if;

			elsif stateBufB=stateBufBStuffL then -- enBufB='1', weBufB='0'
				stateBufB_next <= stateBufBStuffM;

			elsif stateBufB=stateBufBStuffM then
				aBufB_next <= a0TocBuf + k;
				dwrBufB_sig <= drdBufB;
				stateBufB_next <= stateBufBStuffN;

			elsif stateBufB=stateBufBStuffN then -- enBufB='1', weBufB='1'
				k := k + 1;
				l := l + 1;
				stateBufB_next <= stateBufBStuffK;

			elsif stateBufB=stateBufBStuffO then
				if reqBufToBufBStuff='0' then
					stateBufB_next <= stateBufBIdle;
				end if;

			elsif stateBufB=stateBufBUpdTocA then
				difflen := aBufB - lenBuf;
				lenBuf_next <= lenBuf + difflen;

				aBufB_next <= a0TocBuf + lenTocBuf;
				dwrBufB_sig <= std_logic_vector(to_unsigned(difflen, 8));

				lenTocBuf_next <= lenTocBuf + 1;

				stateBufB_next <= stateBufBUpdTocB;

			elsif stateBufB=stateBufBUpdTocB then -- enBufB='1', weBufB='1'
				if (lenBuf<maxlenBuf and lenTocBuf<(sizeTocBuf-1)) then
					avllenBufFromHostif_zero_next <= '0';
				end if;

				stateBufB_next <= stateBufBWaitUpdReq;

			elsif stateBufB=stateBufBWaitUpdReq then -- reqBufBToBufUpdReq='1'
				if ackBufBToBufUpdReq='1' then
					stateBufB_next <= stateBufBIdle;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateBufB <= stateBufB_next;
			lenTocBuf <= lenTocBuf_next;
			lenBuf <= lenBuf_next;
			aBufB <= aBufB_next;
			avllenBufFromHostif_zero <= avllenBufFromHostif_zero_next;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: other
	------------------------------------------------------------------------

end Cmdinv;

