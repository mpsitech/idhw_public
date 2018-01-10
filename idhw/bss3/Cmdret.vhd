-- file Cmdret.vhd
-- Cmdret cmdret_v1_0 command return buffer implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Cmdret is
	port (
		reset: in std_logic;
		mclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: in std_logic_vector(7 downto 0);

		rdyCmdbusFromAlua: out std_logic;
		rdCmdbusFromAlua: in std_logic;

		rdyCmdbusFromAlub: out std_logic;
		rdCmdbusFromAlub: in std_logic;

		rdyCmdbusFromDcxif: out std_logic;
		rdCmdbusFromDcxif: in std_logic;

		rdyCmdbusFromLwiracq: out std_logic;
		rdCmdbusFromLwiracq: in std_logic;

		rdyCmdbusFromPhiif: out std_logic;
		rdCmdbusFromPhiif: in std_logic;

		rdyCmdbusFromPmmu: out std_logic;
		rdCmdbusFromPmmu: in std_logic;

		rdyCmdbusFromQcdif: out std_logic;
		rdCmdbusFromQcdif: in std_logic;

		rdyCmdbusFromThetaif: out std_logic;
		rdCmdbusFromThetaif: in std_logic;

		rdyCmdbusFromTkclksrc: out std_logic;
		rdCmdbusFromTkclksrc: in std_logic;

		reqBufToHostif: in std_logic;
		ackBufToHostif: out std_logic;
		dneBufToHostif: in std_logic;

		avllenBufToHostif: out std_logic_vector(7 downto 0);

		dBufToHostif: out std_logic_vector(7 downto 0);
		strbDBufToHostif: in std_logic
	);
end Cmdret;

architecture Cmdret of Cmdret is

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

	constant maxlenRet: natural := 202;

	---- buf command bus-facing operation (buf)
	type stateBuf_t is (
		stateBufIdle,
		stateBufFull,
		stateBufRecvRetA, stateBufRecvRetB, stateBufRecvRetC,
		stateBufWaitUpdToc,
		stateBufLock,
		stateBufUpdFull
	);
	signal stateBuf, stateBuf_next: stateBuf_t := stateBufIdle;

	signal enBuf: std_logic;

	signal aBuf, aBuf_next: natural range 0 to sizeBuf := 0;
	signal aBuf_vec: std_logic_vector(11 downto 0);
	
	signal lenTocBuf, lenTocBuf_next: natural range 0 to sizeTocBuf := 0;
	constant a0TocBuf: natural := sizeBuf-sizeTocBuf;

	signal rdyCmdbusFromAny, rdyCmdbusFromAny_next: std_logic;
	signal rdCmdbusFromAny: std_logic;

	---- buf outward/hostif-facing operation (bufB)
	type stateBufB_t is (
		stateBufBInit,
		stateBufBIdle,
		stateBufBXferA, stateBufBXferB,
		stateBufBWaitLock,
		stateBufBStuffB, stateBufBStuffC, stateBufBStuffD, stateBufBStuffE,
		stateBufBStuffF, stateBufBStuffG, stateBufBStuffH, stateBufBStuffI, stateBufBStuffJ,
		stateBufBStuffK, stateBufBStuffL,
		stateBufBUpdTocA, stateBufBUpdTocB, stateBufBUpdTocC
	);
	signal stateBufB, stateBufB_next: stateBufB_t := stateBufBInit;

	signal lenBuf, lenBuf_next: natural range 0 to sizeBuf := 0;
	constant maxlenBuf: natural := sizeBuf-sizeTocBuf-maxlenRet;

	signal enBufB: std_logic;
	signal weBufB: std_logic;

	signal aBufB, aBufB_next: natural range 0 to sizeBuf := 0;
	signal aBufB_vec: std_logic_vector(11 downto 0);
	signal dwrBufB: std_logic_vector(7 downto 0);

	signal avllenBufToHostif_sig, avllenBufToHostif_sig_next: std_logic_vector(7 downto 0);
	signal avllenBufToHostif_zero, avllenBufToHostif_zero_next: std_logic;

	---- myBuf
	signal drdBufB: std_logic_vector(7 downto 0);

	---- handshake
	-- buf to bufB
	signal reqBufToBufBUpdToc: std_logic;
	signal ackBufToBufBUpdToc: std_logic;

	-- bufB to buf
	signal reqBufBToBufLock: std_logic;
	signal ackBufBToBufLock: std_logic;

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBuf : Dpbram_v1_0_size4kB
		port map (
			clkA => mclk,

			enA => enBuf,
			weA => '1',

			aA => aBuf_vec,
			drdA => open,
			dwrA => dCmdbus,

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

	ackBufBToBufLock <= '1' when stateBuf=stateBufLock else '0';

	reqBufToBufBUpdToc <= '1' when stateBuf=stateBufWaitUpdToc else '0';

	enBuf <= '1' when (stateBuf=stateBufRecvRetB and clkCmdbus='1') else '0';

	aBuf_vec <= std_logic_vector(to_unsigned(aBuf, 12));

	rdyCmdbusFromAlua <= rdyCmdbusFromAny;
	rdyCmdbusFromAlub <= rdyCmdbusFromAny;
	rdyCmdbusFromDcxif <= rdyCmdbusFromAny;
	rdyCmdbusFromLwiracq <= rdyCmdbusFromAny;
	rdyCmdbusFromPhiif <= rdyCmdbusFromAny;
	rdyCmdbusFromPmmu <= rdyCmdbusFromAny;
	rdyCmdbusFromQcdif <= rdyCmdbusFromAny;
	rdyCmdbusFromThetaif <= rdyCmdbusFromAny;
	rdyCmdbusFromTkclksrc <= rdyCmdbusFromAny;

	rdCmdbusFromAny <= '1' when (rdCmdbusFromAlua='1' or rdCmdbusFromAlub='1' or rdCmdbusFromDcxif='1' or rdCmdbusFromLwiracq='1' or rdCmdbusFromPhiif='1'
				or rdCmdbusFromPmmu='1' or rdCmdbusFromQcdif='1' or rdCmdbusFromThetaif='1' or rdCmdbusFromTkclksrc='1') else '0';

	process (reset, mclk, stateBuf)
	begin
		if reset='1' then
			stateBuf_next <= stateBufIdle;
			aBuf_next <= 0;
			rdyCmdbusFromAny_next <= '1';

		elsif rising_edge(mclk) then
			if stateBuf=stateBufIdle then
				if (clkCmdbus='1' and rdCmdbusFromAny='1') then -- priority for command bus
					rdyCmdbusFromAny_next <= '0';
					stateBuf_next <= stateBufRecvRetA;

				elsif reqBufBToBufLock='1' then
					rdyCmdbusFromAny_next <= '0';
					stateBuf_next <= stateBufLock;
				end if;

			elsif stateBuf=stateBufFull then
				if reqBufBToBufLock='1' then
					stateBuf_next <= stateBufLock;
				end if;

			elsif stateBuf=stateBufRecvRetA then
				if clkCmdbus='0' then
					stateBuf_next <= stateBufRecvRetB;
				end if;

			elsif stateBuf=stateBufRecvRetB then -- enBuf <= '1' for one cycle when clkCmdbus='1'
				if rdCmdbusFromAny='0' then
					stateBuf_next <= stateBufWaitUpdToc;
				elsif clkCmdbus='1' then
					stateBuf_next <= stateBufRecvRetC;
				end if;

			elsif stateBuf=stateBufRecvRetC then
				if clkCmdbus='0' then
					aBuf_next <= aBuf + 1;
					stateBuf_next <= stateBufRecvRetB;
				end if;

			elsif stateBuf=stateBufWaitUpdToc then
				if ackBufToBufBUpdToc='1' then
					stateBuf_next <= stateBufUpdFull;
				end if;

			elsif stateBuf=stateBufLock then
				if reqBufBToBufLock='0' then
					stateBuf_next <= stateBufUpdFull;
				end if;

			elsif stateBuf=stateBufUpdFull then
				aBuf_next <= lenBuf;
				if (lenBuf<maxlenBuf and lenTocBuf<sizeTocBuf) then
					rdyCmdbusFromAny_next <= '1';
					stateBuf_next <= stateBufIdle;
				else
					stateBuf_next <= stateBufFull;
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

	process (clkCmdbus)
	begin
		if falling_edge(clkCmdbus) then
			rdyCmdbusFromAny <= rdyCmdbusFromAny_next;
		end if;
	end process;
	
	------------------------------------------------------------------------
	-- implementation: buf outward/hostif-facing operation (bufB)
	------------------------------------------------------------------------

	reqBufBToBufLock <= '1' when (stateBufB=stateBufBWaitLock or stateBufB=stateBufBStuffB or stateBufB=stateBufBStuffC or stateBufB=stateBufBStuffD or stateBufB=stateBufBStuffE
				or stateBufB=stateBufBStuffF or stateBufB=stateBufBStuffG or stateBufB=stateBufBStuffH or stateBufB=stateBufBStuffI or stateBufB=stateBufBStuffJ
				or stateBufB=stateBufBStuffK or stateBufB=stateBufBStuffL) else '0';

	ackBufToBufBUpdToc <= '1' when stateBufB=stateBufBUpdTocC else '0';

	ackBufToHostif <= '1' when (stateBufB=stateBufBXferA or stateBufB=stateBufBXferB) else '0';

	enBufB <= '1' when ((stateBufB=stateBufBXferA and strbDBufToHostif='0') or stateBufB=stateBufBStuffB or stateBufB=stateBufBStuffE or stateBufB=stateBufBStuffG or stateBufB=stateBufBStuffI
				or stateBufB=stateBufBStuffK or stateBufB=stateBufBStuffL or stateBufB=stateBufBUpdTocB) else '0';

	weBufB <= '1' when (stateBufB=stateBufBStuffG or stateBufB=stateBufBStuffK or stateBufB=stateBufBStuffL or stateBufB=stateBufBUpdTocB) else '0';

	aBufB_vec <= std_logic_vector(to_unsigned(aBufB, 12));

	avllenBufToHostif <= avllenBufToHostif_sig when avllenBufToHostif_zero='0' else (others => '0');

	dBufToHostif <= drdBufB;

	process (reset, mclk, stateBufB)
		variable stuff: std_logic;

		variable difflen: natural range 0 to maxlenRet;

		variable i, j: natural range 0 to sizeBuf;
		variable k, l: natural range 0 to sizeTocBuf;

	begin
		if reset='1' then
			stateBufB_next <= stateBufBInit;
			lenTocBuf_next <= 0;
			lenBuf_next <= 0;
			aBufB_next <= 0;
			avllenBufToHostif_sig_next <= (others => '0');
			avllenBufToHostif_zero_next <= '0';

		elsif rising_edge(mclk) then
			if stateBufB=stateBufBInit then
				aBufB_next <= 0;
				avllenBufToHostif_zero_next <= '0';

				stuff := '0';

				stateBufB_next <= stateBufBIdle;

			elsif stateBufB=stateBufBIdle then
				if reqBufToHostif='1' then
					aBufB_next <= 0;
					stateBufB_next <= stateBufBXferA;
				elsif reqBufToBufBUpdToc='1' then
					avllenBufToHostif_zero_next <= '1';
					stateBufB_next <= stateBufBUpdTocA;
				end if;

			elsif stateBufB=stateBufBXferA then -- enBufB='1' if strbDBufFromHostif='0', i.e. for one clock
				if reqBufToHostif='0' then
					stateBufB_next <= stateBufBIdle;
				elsif dneBufToHostif='1' then
					avllenBufToHostif_zero_next <= '1';
					stuff := '1';
					stateBufB_next <= stateBufBWaitLock;
				elsif strbDBufToHostif='0' then
					stateBufB_next <= stateBufBXferB;
				end if;

			elsif stateBufB=stateBufBXferB then
				if reqBufToHostif='0' then
					stateBufB_next <= stateBufBIdle;
				elsif strbDBufToHostif='1' then
					aBufB_next <= aBufB + 1;
					stateBufB_next <= stateBufBXferA;
				end if;

			elsif stateBufB=stateBufBWaitLock then
				if reqBufToBufBUpdToc='1' then
					stateBufB_next <= stateBufBUpdTocA; -- deadlock protection
				elsif ackBufBToBufLock='1' then
					aBufB_next <= a0TocBuf;
					stateBufB_next <= stateBufBStuffB;
				end if;
				
			elsif stateBufB=stateBufBStuffB then -- part 1: retrieve difflen=tocBuf(0) ; enBufB='1', weBufB='0'
				stateBufB_next <= stateBufBStuffC;

			elsif stateBufB=stateBufBStuffC then
				i := 0;
				difflen := to_integer(unsigned(drdBufB));
				j := difflen;
				stateBufB_next <= stateBufBStuffD;

			elsif stateBufB=stateBufBStuffD then -- part 2: stuff buf
				if j=lenBuf then
					lenBuf_next <= lenBuf - difflen;
					k := 0;
					l := 1;
					stateBufB_next <= stateBufBStuffH;
				else
					aBufB_next <= j;
					stateBufB_next <= stateBufBStuffE;
				end if;

			elsif stateBufB=stateBufBStuffE then -- enBufB='1', weBufB='0'
				stateBufB_next <= stateBufBStuffF;

			elsif stateBufB=stateBufBStuffF then
				aBufB_next <= i;
				dwrBufB <= drdBufB;
				stateBufB_next <= stateBufBStuffG;

			elsif stateBufB=stateBufBStuffG then -- enBufB='1', weBufB='1'
				i := i + 1;
				j := j + 1;
				stateBufB_next <= stateBufBStuffD;

			elsif stateBufB=stateBufBStuffH then -- part 3: stuff tocBuf
				if l=lenTocBuf then
					lenTocBuf_next <= lenTocBuf - 1;
					aBufB_next <= a0TocBuf + k;
					dwrBufB <= x"00";
					stateBufB_next <= stateBufBStuffL;
				else
					aBufB_next <= a0TocBuf + l;
					stateBufB_next <= stateBufBStuffI;
				end if;

			elsif stateBufB=stateBufBStuffI then -- enBufB='1', weBufB='0'
				stateBufB_next <= stateBufBStuffJ;

			elsif stateBufB=stateBufBStuffJ then
				aBufB_next <= a0TocBuf + k;
				if k=0 then
					avllenBufToHostif_sig_next <= drdBufB(7 downto 0);
				end if;
				dwrBufB <= drdBufB;
				stateBufB_next <= stateBufBStuffK;

			elsif stateBufB=stateBufBStuffK then -- enBufB='1', weBufB='1'
				k := k + 1;
				l := l + 1;
				stateBufB_next <= stateBufBStuffH;

			elsif stateBufB=stateBufBStuffL then -- part 4: set tocBuf(lenTocBuf)=0, enBufB='1', weBufB='1'
				if k=0 then
					avllenBufToHostif_sig_next <= std_logic_vector(to_unsigned(0, 8));
				end if;
				stateBufB_next <= stateBufBInit;

			elsif stateBufB=stateBufBUpdTocA then
				-- separate preparation state due to multiple possibilities for previous state
				lenBuf_next <= aBuf;
				lenTocBuf_next <= lenTocBuf + 1;

				difflen := aBuf - lenBuf;
				avllenBufToHostif_sig_next <= std_logic_vector(to_unsigned(difflen, 8));

				aBufB_next <= a0TocBuf + lenTocBuf;
				dwrBufB <= std_logic_vector(to_unsigned(difflen, 8));

				stateBufB_next <= stateBufBUpdTocB;

			elsif stateBufB=stateBufBUpdTocB then -- enBufB='1', weBufB='1'
				stateBufB_next <= stateBufBUpdTocC;

			elsif stateBufB=stateBufBUpdTocC then
				if reqBufToBufBUpdToc='0' then
					if stuff='1' then
						stateBufB_next <= stateBufBWaitLock;
					else
						stateBufB_next <= stateBufBInit;
					end if;
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
			avllenBufToHostif_sig <= avllenBufToHostif_sig_next;
			avllenBufToHostif_zero <= avllenBufToHostif_zero_next;
		end if;
	end process;

end Cmdret;

