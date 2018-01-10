-- file Cmdinv.vhd
-- Cmdinv cmdinv_v1_0 command invocation buffer implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

entity Cmdinv is
	port (
		reset: in std_logic;
		mclk: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: inout std_logic_vector(7 downto 0);

		reqCmdbusToAcq: out std_logic;
		wrCmdbusToAcq: in std_logic;

		reqCmdbusToFan: out std_logic;
		wrCmdbusToFan: in std_logic;

		reqCmdbusToRoic: out std_logic;
		wrCmdbusToRoic: in std_logic;

		reqCmdbusToState: out std_logic;
		wrCmdbusToState: in std_logic;

		reqCmdbusToSync: out std_logic;
		wrCmdbusToSync: in std_logic;

		reqCmdbusToTemp: out std_logic;
		wrCmdbusToTemp: in std_logic;

		reqCmdbusToTkclksrc: out std_logic;
		wrCmdbusToTkclksrc: in std_logic;

		reqCmdbusToVmon: out std_logic;
		wrCmdbusToVmon: in std_logic;

		reqCmdbusToVset: out std_logic;
		wrCmdbusToVset: in std_logic;

		reqCmdbusToWavegen: out std_logic;
		wrCmdbusToWavegen: in std_logic;

		reqBufFromHostif: in std_logic;
		ackBufFromHostif: out std_logic;
		dneBufFromHostif: in std_logic;

		avllenBufFromHostif: out std_logic_vector(4 downto 0);

		dBufFromHostif: in std_logic_vector(7 downto 0);
		strbDBufFromHostif: in std_logic
	);
end Cmdinv;

architecture Cmdinv of Cmdinv is

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

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- buf
	constant sizeBuf: natural := 2048;
	constant sizeTocBuf: natural := 128;

	constant maxlenInv: natural := 16;

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
	signal aBuf_vec: std_logic_vector(10 downto 0);

	signal ixTocBuf: natural range 0 to sizeTocBuf-1 := 0; -- used by bufB
	signal a0Buf: natural range 0 to sizeBuf-1 := 0;

	constant a0TocBuf: natural := sizeBuf-sizeTocBuf;

	signal dCmdbus_sig: std_logic_vector(7 downto 0);

	signal wrCmdbusToAny: std_logic;

	signal reqCmdbus, reqCmdbus_next: std_logic;

	signal reqCmdbusToAcq_sig: std_logic := '0';
	signal ixTocBufAcq: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufAcq: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToFan_sig: std_logic := '0';
	signal ixTocBufFan: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufFan: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToRoic_sig: std_logic := '0';
	signal ixTocBufRoic: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufRoic: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToState_sig: std_logic := '0';
	signal ixTocBufState: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufState: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToSync_sig: std_logic := '0';
	signal ixTocBufSync: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufSync: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToTemp_sig: std_logic := '0';
	signal ixTocBufTemp: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufTemp: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToTkclksrc_sig: std_logic := '0';
	signal ixTocBufTkclksrc: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufTkclksrc: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToVmon_sig: std_logic := '0';
	signal ixTocBufVmon: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufVmon: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToVset_sig: std_logic := '0';
	signal ixTocBufVset: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufVset: natural range 0 to sizeBuf-1 := 0;

	signal reqCmdbusToWavegen_sig: std_logic := '0';
	signal ixTocBufWavegen: natural range 0 to sizeTocBuf-1 := 0;
	signal a0BufWavegen: natural range 0 to sizeBuf-1 := 0;

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
	signal aBufB_vec: std_logic_vector(10 downto 0);
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
			weB => weBufB,

			aB => aBufB_vec,
			drdB => drdBufB,
			dwrB => dwrBufB
		);

	------------------------------------------------------------------------
	-- implementation: buf command bus-facing operation (buf)
	------------------------------------------------------------------------

	a0Buf <= a0BufAcq when ixTocBuf=ixTocBufAcq
				else a0BufFan when ixTocBuf=ixTocBufFan
				else a0BufRoic when ixTocBuf=ixTocBufRoic
				else a0BufState when ixTocBuf=ixTocBufState
				else a0BufSync when ixTocBuf=ixTocBufSync
				else a0BufTemp when ixTocBuf=ixTocBufTemp
				else a0BufTkclksrc when ixTocBuf=ixTocBufTkclksrc
				else a0BufVmon when ixTocBuf=ixTocBufVmon
				else a0BufVset when ixTocBuf=ixTocBufVset
				else a0BufWavegen when ixTocBuf=ixTocBufWavegen
				else 0;

	ackBufBToBufUpdReq <= '1' when stateBuf=stateBufUpdReqF else '0';

	reqBufToBufBStuff <= '1' when stateBuf=stateBufWaitStuff else '0';

	enBuf <= '1' when (stateBuf=stateBufSendInvB or stateBuf=stateBufSendInvD or stateBuf=stateBufSendInvG or stateBuf=stateBufUpdReqB or stateBuf=stateBufUpdReqD) else '0';
	
	aBuf_vec <= std_logic_vector(to_unsigned(aBuf, 11));

	wrCmdbusToAny <= '1' when (wrCmdbusToAcq='1' or wrCmdbusToFan='1' or wrCmdbusToRoic='1' or wrCmdbusToState='1' or wrCmdbusToSync='1' or wrCmdbusToTemp='1' or wrCmdbusToTkclksrc='1' or wrCmdbusToVmon='1' or wrCmdbusToVset='1' or wrCmdbusToWavegen='1') else'0';

	dCmdbus <= dCmdbus_sig when wrCmdbusToAny='1' else "ZZZZZZZZ";
	
	reqCmdbusToAcq <= reqCmdbusToAcq_sig when reqCmdbus='1' else '0';
	reqCmdbusToFan <= reqCmdbusToFan_sig when reqCmdbus='1' else '0';
	reqCmdbusToRoic <= reqCmdbusToRoic_sig when reqCmdbus='1' else '0';
	reqCmdbusToState <= reqCmdbusToState_sig when reqCmdbus='1' else '0';
	reqCmdbusToSync <= reqCmdbusToSync_sig when reqCmdbus='1' else '0';
	reqCmdbusToTemp <= reqCmdbusToTemp_sig when reqCmdbus='1' else '0';
	reqCmdbusToTkclksrc <= reqCmdbusToTkclksrc_sig when reqCmdbus='1' else '0';
	reqCmdbusToVmon <= reqCmdbusToVmon_sig when reqCmdbus='1' else '0';
	reqCmdbusToVset <= reqCmdbusToVset_sig when reqCmdbus='1' else '0';
	reqCmdbusToWavegen <= reqCmdbusToWavegen_sig when reqCmdbus='1' else '0';

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
					if wrCmdbusToAcq='1' then
						ixTocBuf <= ixTocBufAcq;
					elsif wrCmdbusToFan='1' then
						ixTocBuf <= ixTocBufFan;
					elsif wrCmdbusToRoic='1' then
						ixTocBuf <= ixTocBufRoic;
					elsif wrCmdbusToState='1' then
						ixTocBuf <= ixTocBufState;
					elsif wrCmdbusToSync='1' then
						ixTocBuf <= ixTocBufSync;
					elsif wrCmdbusToTemp='1' then
						ixTocBuf <= ixTocBufTemp;
					elsif wrCmdbusToTkclksrc='1' then
						ixTocBuf <= ixTocBufTkclksrc;
					elsif wrCmdbusToVmon='1' then
						ixTocBuf <= ixTocBufVmon;
					elsif wrCmdbusToVset='1' then
						ixTocBuf <= ixTocBufVset;
					elsif wrCmdbusToWavegen='1' then
						ixTocBuf <= ixTocBufWavegen;
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

				reqCmdbusToAcq_sig <= '0';
				reqCmdbusToFan_sig <= '0';
				reqCmdbusToRoic_sig <= '0';
				reqCmdbusToState_sig <= '0';
				reqCmdbusToSync_sig <= '0';
				reqCmdbusToTemp_sig <= '0';
				reqCmdbusToTkclksrc_sig <= '0';
				reqCmdbusToVmon_sig <= '0';
				reqCmdbusToVset_sig <= '0';
				reqCmdbusToWavegen_sig <= '0';

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
				if (drdBuf=tixVIdhwIcm2ControllerAcq and reqCmdbusToAcq_sig='0') then
					reqCmdbusToAcq_sig <= '1';
					ixTocBufAcq <= j;
					a0BufAcq <= k;
				elsif (drdBuf=tixVIdhwIcm2ControllerFan and reqCmdbusToFan_sig='0') then
					reqCmdbusToFan_sig <= '1';
					ixTocBufFan <= j;
					a0BufFan <= k;
				elsif (drdBuf=tixVIdhwIcm2ControllerRoic and reqCmdbusToRoic_sig='0') then
					reqCmdbusToRoic_sig <= '1';
					ixTocBufRoic <= j;
					a0BufRoic <= k;
				elsif (drdBuf=tixVIdhwIcm2ControllerState and reqCmdbusToState_sig='0') then
					reqCmdbusToState_sig <= '1';
					ixTocBufState <= j;
					a0BufState <= k;
				elsif (drdBuf=tixVIdhwIcm2ControllerSync and reqCmdbusToSync_sig='0') then
					reqCmdbusToSync_sig <= '1';
					ixTocBufSync <= j;
					a0BufSync <= k;
				elsif (drdBuf=tixVIdhwIcm2ControllerTemp and reqCmdbusToTemp_sig='0') then
					reqCmdbusToTemp_sig <= '1';
					ixTocBufTemp <= j;
					a0BufTemp <= k;
				elsif (drdBuf=tixVIdhwIcm2ControllerTkclksrc and reqCmdbusToTkclksrc_sig='0') then
					reqCmdbusToTkclksrc_sig <= '1';
					ixTocBufTkclksrc <= j;
					a0BufTkclksrc <= k;
				elsif (drdBuf=tixVIdhwIcm2ControllerVmon and reqCmdbusToVmon_sig='0') then
					reqCmdbusToVmon_sig <= '1';
					ixTocBufVmon <= j;
					a0BufVmon <= k;
				elsif (drdBuf=tixVIdhwIcm2ControllerVset and reqCmdbusToVset_sig='0') then
					reqCmdbusToVset_sig <= '1';
					ixTocBufVset <= j;
					a0BufVset <= k;
				elsif (drdBuf=tixVIdhwIcm2ControllerWavegen and reqCmdbusToWavegen_sig='0') then
					reqCmdbusToWavegen_sig <= '1';
					ixTocBufWavegen <= j;
					a0BufWavegen <= k;
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

	aBufB_vec <= std_logic_vector(to_unsigned(aBufB, 11));

	dWrbufB <= dBufFromHostif when (stateBufB=stateBufBXferA or stateBufB=stateBufBXferB) else dWrbufB_sig;

	avllenBufFromHostif <= std_logic_vector(to_unsigned(maxlenInv, 5)) when avllenBufFromHostif_zero='0' else (others => '0');

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

