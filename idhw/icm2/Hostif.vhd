-- file Hostif.vhd
-- Hostif spihostif_v1_0 host interface implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Idhw.all;
use work.Icm2.all;

entity Hostif is
	port (
		reset: in std_logic;
		mclk: in std_logic;
		fastclk: in std_logic;
		tkclk: in std_logic;
		commok: out std_logic;
		reqReset: out std_logic;

		reqBufToCmdinv: out std_logic;
		ackBufToCmdinv: in std_logic;
		dneBufToCmdinv: out std_logic;

		avllenBufToCmdinv: in std_logic_vector(4 downto 0);

		dBufToCmdinv: out std_logic_vector(7 downto 0);
		strbDBufToCmdinv: out std_logic;

		reqBufFromCmdret: out std_logic;
		ackBufFromCmdret: in std_logic;
		dneBufFromCmdret: out std_logic;

		avllenBufFromCmdret: in std_logic_vector(4 downto 0);

		dBufFromCmdret: in std_logic_vector(7 downto 0);
		strbDBufFromCmdret: out std_logic;

		reqBufFromAcq: out std_logic;
		ackBufFromAcq: in std_logic;
		dneBufFromAcq: out std_logic;

		avllenBufFromAcq: in std_logic_vector(10 downto 0);

		dBufFromAcq: in std_logic_vector(7 downto 0);
		strbDBufFromAcq: out std_logic;

		reqBufToWavegen: out std_logic;
		ackBufToWavegen: in std_logic;
		dneBufToWavegen: out std_logic;

		avllenBufToWavegen: in std_logic_vector(10 downto 0);

		dBufToWavegen: out std_logic_vector(7 downto 0);
		strbDBufToWavegen: out std_logic;

		nss: in std_logic;
		sclk: in std_logic;
		mosi: in std_logic;
		miso: inout std_logic
	);
end Hostif;

architecture Hostif of Hostif is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Crcp_v1_0 is
		generic (
			poly: std_logic_vector(15 downto 0) := x"8005";
			bitinv: std_logic := '0'
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			fastclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			captNotFin: in std_logic;

			d: in std_logic_vector(7 downto 0);
			strbD: in std_logic;

			crc: out std_logic_vector(15 downto 0)
		);
	end component;

	component Spislave_v1_0 is
		generic (
			cpol: std_logic := '0';
			cpha: std_logic := '0';

			nssByteNotXfer: std_logic := '0';
			misoPrecphaNotCpha: std_logic := '0'
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

			nss: in std_logic;
			sclk: in std_logic;
			mosi: in std_logic;
			miso: inout std_logic
		);
	end component;

	component Timeout_v1_0 is
		generic (
			twait: natural range 1 to 10000 := 100
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			restart: in std_logic;
			timeout: out std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- main operation
	type stateOp_t is (
		stateOpInit,
		stateOpStepXfer,
		stateOpPrepArbbx,
		stateOpPrepAvllen,
		stateOpPrepArblen,
		stateOpRxA, stateOpRxB, stateOpRxC, stateOpRxD, stateOpRxE,
		stateOpRxF, stateOpRxG, stateOpRxH, stateOpRxI,
		stateOpTxA, stateOpTxB, stateOpTxC, stateOpTxD, stateOpTxE,
		stateOpTxF, stateOpTxG, stateOpTxH, stateOpTxI, stateOpTxJ,
		stateOpCnfRd,
		stateOpCnfWr
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	constant maxlenAuxbuf: natural := 6;

	type auxbuf_t is array (0 to maxlenAuxbuf-1) of std_logic_vector(7 downto 0);
	signal auxbuf: auxbuf_t;

	constant ixAuxbufXfer: natural := 0;
	constant ixAuxbufTkn: natural := 1;

	constant lenAuxbufTkn: natural := 2;

	constant lenAuxbufTknste: natural := 3;
	constant ixAuxbufTknsteTknste: natural := 2;

	constant lenAuxbufBx: natural := 3;
	constant ixAuxbufBxBx: natural := 2;

	constant lenAuxbufLen: natural := 6;
	constant ixAuxbufLenLen: natural := 2;

	constant lenAuxbufRd: natural := 4;
	constant ixAuxbufRdTxbuf: natural := 2;
	constant ixAuxbufRdCrc: natural := 2;

	constant lenAuxbufRdack: natural := 2;

	constant lenAuxbufWr: natural := 4;
	constant ixAuxbufWrRxbuf: natural := 2;
	constant ixAuxbufWrCrc: natural := 2;

	constant lenAuxbufWrack: natural := 2;

	constant tknReset: std_logic_vector(7 downto 0) := x"FF";
	constant tknPing: std_logic_vector(7 downto 0) := x"00";
	signal tknFromCmdret: std_logic_vector(7 downto 0) := tixWIdhwIcm2BufferCmdretToHostif;
	signal tknToCmdinv: std_logic_vector(7 downto 0) := tixWIdhwIcm2BufferHostifToCmdinv;
	signal tknFromAcq: std_logic_vector(7 downto 0) := tixWIdhwIcm2BufferAcqToHostif;
	signal tknToWavegen: std_logic_vector(7 downto 0) := tixWIdhwIcm2BufferHostifToWavegen;

	signal tixDbeVXfer: std_logic_vector(7 downto 0) := tixDbeVXferVoid; -- tixDbeVXfer only used within op, so no _next needed
	signal tkn, tkn_next: std_logic_vector(7 downto 0);

	signal tknste: std_logic_vector(7 downto 0);

	signal avlbx: std_logic_vector(7 downto 0) := x"00";
	signal arbbx: std_logic_vector(7 downto 0) := x"00";

	signal avllen: std_logic_vector(31 downto 0) := x"00000000";
	signal arblen: std_logic_vector(31 downto 0) := x"00000000";

	signal d, d_next: std_logic_vector(7 downto 0);

	signal reqTxbuf, reqTxbuf_next: std_logic;
	signal ackTxbuf: std_logic;
	signal dneTxbuf: std_logic;

	signal dTxbuf: std_logic_vector(7 downto 0);
	signal strbDTxbuf: std_logic;

	signal crcRxbuf: std_logic_vector(15 downto 0);

	signal reqRxbuf, reqRxbuf_next: std_logic;
	signal ackRxbuf: std_logic;
	signal dneRxbuf: std_logic;

	signal dRxbuf, dRxbuf_next: std_logic_vector(7 downto 0);
	signal strbDRxbuf: std_logic;

	signal commok_sig, commok_sig_next: std_logic;
	
	signal reqReset_sig, reqReset_sig_next: std_logic;

	signal crccaptNotFin: std_logic;

	signal crcd, crcd_next: std_logic_vector(7 downto 0);
	signal strbCrcd: std_logic;

	signal torestart, torestart_next: std_logic;

	type rxtxerr_t is (
		rxtxerrOk,
		rxtxerrXfer,
		rxtxerrTkn,
		rxtxerrTo,
		rxtxerrAbrt
	);
	signal rxtxerr: rxtxerr_t;

	signal spilen: std_logic_vector(10 downto 0);

	signal spisend: std_logic_vector(7 downto 0);

	---- myCrc
	signal crc: std_logic_vector(15 downto 0);

	---- mySpi
	signal spirecv: std_logic_vector(7 downto 0);
	signal strbSpirecv: std_logic;

	signal strbSpisend: std_logic;

	---- myTimeout
	signal timeout: std_logic;

	---- handshake
	-- op to myCrc
	signal reqCrc: std_logic;
	signal ackCrc: std_logic;
	signal dneCrc: std_logic;

	-- op to mySpi
	signal reqSpi: std_logic;
	signal ackSpi: std_logic;
	signal dneSpi: std_logic;

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myCrc : Crcp_v1_0
		port map (
			reset => reset,
			mclk => mclk,
			fastclk => fastclk,

			req => reqCrc,
			ack => ackCrc,
			dne => dneCrc,

			captNotFin => crccaptNotFin,

			d => crcd,
			strbD => strbCrcd,

			crc => crc
		);

	mySpi : Spislave_v1_0
		port map (
			reset => reset,
			mclk => mclk,

			req => reqSpi,
			ack => ackSpi,
			dne => dneSpi,

			len => spilen,

			send => spisend,
			strbSend => strbSpisend,

			recv => spirecv,
			strbRecv => strbSpirecv,

			nss => nss,
			sclk => sclk,
			mosi => mosi,
			miso => miso
		);

	myTimeout : Timeout_v1_0
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			restart => torestart,
			timeout => timeout
		);

	------------------------------------------------------------------------
	-- implementation: main operation 
	------------------------------------------------------------------------

	tknste(0) <= '0' when tknFromCmdret=tixWIdhwIcm2BufferCmdretToHostif else '1';
	tknste(1) <= '0' when tknToCmdinv=tixWIdhwIcm2BufferHostifToCmdinv else '1';
	tknste(2) <= '0' when tknFromAcq=tixWIdhwIcm2BufferAcqToHostif else '1';
	tknste(3) <= '0' when tknToWavegen=tixWIdhwIcm2BufferHostifToWavegen else '1';
	tknste(4) <= '0';
	tknste(5) <= '0';
	tknste(6) <= '0';
	tknste(7) <= '0';

	avlbx(0) <= '1' when avllenBufFromCmdret/="00000" else '0';
	avlbx(1) <= '1' when avllenBufToCmdinv/="00000" else '0';
	avlbx(2) <= '1' when avllenBufFromAcq/="00000000000" else '0';
	avlbx(3) <= '1' when avllenBufToWavegen/="00000000000" else '0';
	avlbx(4) <= '0';
	avlbx(5) <= '0';
	avlbx(6) <= '0';
	avlbx(7) <= '0';

	avllen <= "000000000000000000000000000" & avllenBufFromCmdret when (tkn=tixWIdhwIcm2BufferCmdretToHostif or tkn=(not tixWIdhwIcm2BufferCmdretToHostif))
				else "000000000000000000000000000" & avllenBufToCmdinv when (tkn=tixWIdhwIcm2BufferHostifToCmdinv or tkn=(not tixWIdhwIcm2BufferHostifToCmdinv))
				else "000000000000000000000" & avllenBufFromAcq when (tkn=tixWIdhwIcm2BufferAcqToHostif or tkn=(not tixWIdhwIcm2BufferAcqToHostif))
				else "000000000000000000000" & avllenBufToWavegen when (tkn=tixWIdhwIcm2BufferHostifToWavegen or tkn=(not tixWIdhwIcm2BufferHostifToWavegen))
				else x"00000000";

	ackTxbuf <= ackBufFromCmdret when (tkn=tixWIdhwIcm2BufferCmdretToHostif or tkn=(not tixWIdhwIcm2BufferCmdretToHostif))
				else ackBufFromAcq when (tkn=tixWIdhwIcm2BufferAcqToHostif or tkn=(not tixWIdhwIcm2BufferAcqToHostif))
				else '0';

	dneTxbuf <= '1' when stateOp=stateOpCnfrd else '0';

	dTxbuf <= dBufFromCmdret when (tkn=tixWIdhwIcm2BufferCmdretToHostif or tkn=(not tixWIdhwIcm2BufferCmdretToHostif))
				else dBufFromAcq when (tkn=tixWIdhwIcm2BufferAcqToHostif or tkn=(not tixWIdhwIcm2BufferAcqToHostif))
				else x"00";

	strbDTxbuf <= '0' when (stateOp=stateOpTxD or stateOp=stateOpTxE) else '1';

	ackRxbuf <= ackBufToCmdinv when (tkn=tixWIdhwIcm2BufferHostifToCmdinv or tkn=(not tixWIdhwIcm2BufferHostifToCmdinv))
				else ackBufToWavegen when (tkn=tixWIdhwIcm2BufferHostifToWavegen or tkn=(not tixWIdhwIcm2BufferHostifToWavegen))
				else '0';

	dneRxbuf <= '1' when stateOp=stateOpCnfwr else '0';

	strbDRxbuf <= '0' when (stateOp=stateOpRxD or stateOp=stateOpRxE) else '1';

	commok <= commok_sig;

	reqReset <= reqReset_sig;

	reqCrc <= '1' when (stateOp=stateOpRxD or stateOp=stateOpRxE or stateOp=stateOpRxF or stateOp=stateOpRxG or stateOp=stateOpRxH
				or stateOp=stateOpTxD or stateOp=stateOpTxE or stateOp=stateOpTxF or stateOp=stateOpTxG) else '0';

	crccaptNotFin <= '1' when (stateOp=stateOpRxD or stateOp=stateOpRxE or stateOp=stateOpRxF or stateOp=stateOpTxD or stateOp=stateOpTxE
				or stateOp=stateOpTxF) else '0';

	strbCrcd <= '0' when (stateOp=stateOpRxD or stateOp=stateOpRxE or stateOp=stateOpTxD or stateOp=stateOpTxE or stateOp=stateOpTxG) else '1';

	reqSpi <= '1' when (stateOp=stateOpRxA or stateOp=stateOpRxB or stateOp=stateOpRxC or stateOp=stateOpRxD or stateOp=stateOpRxE
				or stateOp=stateOpRxF or stateOp=stateOpRxG or stateOp=stateOpRxH or stateOp=stateOpTxA or stateOp=stateOpTxB
				or stateOp=stateOpTxC or stateOp=stateOpTxD or stateOp=stateOpTxE	or stateOp=stateOpTxF or stateOp=stateOpTxG
				or stateOp=stateOpTxH or stateOp=stateOpTxI) else '0';

	spisend <= dTxbuf when (stateOp=stateOpTxD or stateOp=stateOpTxE or stateOp=stateOpTxF or stateOp=stateOpTxG) else d;

	-- fromCmdret
	reqBufFromCmdret <= reqTxbuf when tkn=tknFromCmdret else '0';
	dneBufFromCmdret <= dneTxbuf when tkn=tknFromCmdret else '0';

	strbDBufFromCmdret <= strbDTxbuf;

	-- toCmdinv
	reqBufToCmdinv <= reqRxbuf when tkn=tknToCmdinv else '0';
	dneBufToCmdinv <= dneRxbuf when tkn=tknToCmdinv else '0';

	dBufToCmdinv <= dRxbuf;
	strbDBufToCmdinv <= strbDRxbuf;

	-- fromAcq
	reqBufFromAcq <= reqTxbuf when tkn=tknFromAcq else '0';
	dneBufFromAcq <= dneTxbuf when tkn=tknFromAcq else '0';

	strbDBufFromAcq <= strbDTxbuf;

	-- toWavegen
	reqBufToWavegen <= reqRxbuf when tkn=tknToWavegen else '0';
	dneBufToWavegen <= dneRxbuf when tkn=tknToWavegen else '0';

	dBufToWavegen <= dRxbuf;
	strbDBufToWavegen <= strbDRxbuf;

	process (reset, mclk, stateOp)
		variable lastBxPr0: std_logic_vector(7 downto 0) := x"00";
		variable lastBxPr1: std_logic_vector(7 downto 0) := x"00";

		variable i: natural range 0 to maxlenAuxbuf;
		variable j: natural range 0 to 2047;

		variable x: natural range 0 to 2047;
		variable y: std_logic_vector(7 downto 0);
		variable z: std_logic_vector(31 downto 0);

	begin
		if reset='1' then
			stateOp_next <= stateOpInit;
			tknFromCmdret <= tixWIdhwIcm2BufferCmdretToHostif;
			tknToCmdinv <= tixWIdhwIcm2BufferHostifToCmdinv;
			tknFromAcq <= tixWIdhwIcm2BufferAcqToHostif;
			tknToWavegen <= tixWIdhwIcm2BufferHostifToWavegen;
			tkn_next <= tknPing;
			d_next <= x"00";
			reqTxbuf_next <= '0';
			reqRxbuf_next <= '0';
			dRxbuf_next <= x"00";
			commok_sig_next <= '0';
			reqReset_sig_next <= '0';
			crcd_next <= x"00";
			torestart_next <= '0';

		elsif rising_edge(mclk) then
			if stateOp=stateOpInit then
				auxbuf(ixAuxbufXfer) <= tixDbeVXferVoid;
				tixDbeVXfer <= tixDbeVXferVoid;

				auxbuf(ixAuxbufTkn) <= tknPing;
				tkn_next <= tknPing;

				reqTxbuf_next <= '0';
				reqRxbuf_next <= '0';

				stateOp_next <= stateOpStepXfer;

			elsif stateOp=stateOpStepXfer then
				if tixDbeVXfer=tixDbeVXferVoid then
					tixDbeVXfer <= tixDbeVXferTkn;
					spilen <= std_logic_vector(to_unsigned(lenAuxbufTkn, 11));

					i := 0;

					stateOp_next <= stateOpRxA;

				elsif rxtxerr=rxtxerrOk then
					-- rx/tx completed successfully
					if tixDbeVXfer=tixDbeVXferTkn then -- rx
						if auxbuf(ixAuxbufTkn)=tknReset then
							reqReset_sig_next <= '1';

						elsif auxbuf(ixAuxbufTkn)=tknPing then
							auxbuf(ixAuxbufXfer) <= tixDbeVXferTknste;
							tixDbeVXfer <= tixDbeVXferTknste;

							auxbuf(ixAuxbufTknsteTknste) <= tknste;

							spilen <= std_logic_vector(to_unsigned(lenAuxbufTknste, 11));

							i := 0;
							d_next <= tixDbeVXferTknste;

							torestart_next <= '1';
							stateOp_next <= stateOpTxA;

						elsif (auxbuf(ixAuxbufTkn)=tknFromCmdret or auxbuf(ixAuxbufTkn)=tknToCmdinv or auxbuf(ixAuxbufTkn)=tknFromAcq or auxbuf(ixAuxbufTkn)=tknToWavegen) then

							tkn_next <= auxbuf(ixAuxbufTkn);

							auxbuf(ixAuxbufXfer) <= tixDbeVXferAvllen;
							tixDbeVXfer <= tixDbeVXferAvllen;

							stateOp_next <= stateOpPrepAvllen;

						else
							-- invalid token
							commok_sig_next <= '0';
							stateOp_next <= stateOpInit;
						end if;

					elsif tixDbeVXfer=tixDbeVXferTknste then -- tx
						auxbuf(ixAuxbufXfer) <= tixDbeVXferAvlbx;
						tixDbeVXfer <= tixDbeVXferAvlbx;

						auxbuf(ixAuxbufBxBx) <= avlbx;

						spilen <= std_logic_vector(to_unsigned(lenAuxbufBx, 11));

						i := 0;
						d_next <= tixDbeVXferAvlbx;

						torestart_next <= '1';
						stateOp_next <= stateOpTxA;

					elsif tixDbeVXfer=tixDbeVXferAvlbx then -- tx
						tixDbeVXfer <= tixDbeVXferReqbx;

						spilen <= std_logic_vector(to_unsigned(lenAuxbufBx, 11));
						i := 0;

						torestart_next <= '1';
						stateOp_next <= stateOpRxA;

					elsif tixDbeVXfer=tixDbeVXferReqbx then -- rx
						auxbuf(ixAuxbufXfer) <= tixDbeVXferArbbx;
						tixDbeVXfer <= tixDbeVXferArbbx;

						-- buffer transfer arbitration
						y := avlbx and auxbuf(ixAuxbufBxBx);

						if ( ((y and tixWIdhwIcm2BufferCmdretToHostif) /= x"00") and ( (lastBxPr0 /= tixWIdhwIcm2BufferCmdretToHostif) or ((y and (tixWIdhwIcm2BufferCmdretToHostif or tixWIdhwIcm2BufferHostifToCmdinv)) = tixWIdhwIcm2BufferCmdretToHostif) ) ) then
							arbbx <= tixWIdhwIcm2BufferCmdretToHostif;
						elsif ( ((y and tixWIdhwIcm2BufferHostifToCmdinv) /= x"00") and ( (lastBxPr0 /= tixWIdhwIcm2BufferHostifToCmdinv) or ((y and (tixWIdhwIcm2BufferCmdretToHostif or tixWIdhwIcm2BufferHostifToCmdinv)) = tixWIdhwIcm2BufferHostifToCmdinv) ) ) then
							arbbx <= tixWIdhwIcm2BufferHostifToCmdinv;
						elsif ((y and tixWIdhwIcm2BufferAcqToHostif) /= x"00") then
							arbbx <= tixWIdhwIcm2BufferAcqToHostif;
						elsif ( ((y and tixWIdhwIcm2BufferHostifToWavegen) /= x"00") and ( (lastBxPr1 /= tixWIdhwIcm2BufferHostifToWavegen) or ((y and (tixWIdhwIcm2BufferAcqToHostif or tixWIdhwIcm2BufferHostifToWavegen)) = tixWIdhwIcm2BufferHostifToWavegen) ) ) then
							arbbx <= tixWIdhwIcm2BufferHostifToWavegen;

						else
							arbbx <= x"00";
						end if;

						stateOp_next <= stateOpPrepArbbx;

					elsif tixDbeVXfer=tixDbeVXferArbbx then -- tx
						commok_sig_next <= '1';
						stateOp_next <= stateOpInit;

					elsif tixDbeVXfer=tixDbeVXferAvllen then -- tx
						tixDbeVXfer <= tixDbeVXferReqlen;

						spilen <= std_logic_vector(to_unsigned(lenAuxbufLen, 11));
						i := 0;

						torestart_next <= '1';
						stateOp_next <= stateOpRxA;

					elsif tixDbeVXfer=tixDbeVXferReqlen then -- rx
						auxbuf(ixAuxbufXfer) <= tixDbeVXferArblen;
						tixDbeVXfer <= tixDbeVXferArblen;

						-- length arbitration
						z := auxbuf(ixAuxbufLenLen) & auxbuf(ixAuxbufLenLen+1) & auxbuf(ixAuxbufLenLen+2) & auxbuf(ixAuxbufLenLen+3);

						if to_integer(unsigned(avllen))<to_integer(unsigned(z)) then
							arblen <= avllen;
						else
							arblen <= z;
						end if;

						stateOp_next <= stateOpPrepArblen;

					elsif tixDbeVXfer=tixDbeVXferArblen then -- tx
						if to_integer(unsigned(arblen))=0 then
							commok_sig_next <= '1';
							stateOp_next <= stateOpInit;

						elsif to_integer(unsigned(arblen))>1024 then
							commok_sig_next <= '0';
							stateOp_next <= stateOpInit;

						elsif (auxbuf(ixAuxbufTkn)=tknFromCmdret or auxbuf(ixAuxbufTkn)=tknFromAcq) then
							auxbuf(ixAuxbufXfer) <= tixDbeVXferRd;
							tixDbeVXfer <= tixDbeVXferRd;

							x := to_integer(unsigned(arblen)) + 4;
							spilen <= std_logic_vector(to_unsigned(x, 11));

							i := 0;

							d_next <= tixDbeVXferRd;

							torestart_next <= '1';
							stateOp_next <= stateOpTxA;

						elsif (auxbuf(ixAuxbufTkn)=tknToCmdinv or auxbuf(ixAuxbufTkn)=tknToWavegen) then
							tixDbeVXfer <= tixDbeVXferWr;

							x := to_integer(unsigned(arblen)) + 4;
							spilen <= std_logic_vector(to_unsigned(x, 11));

							i := 0;

							torestart_next <= '1';
							stateOp_next <= stateOpRxA;

						else
							-- should not happen
							commok_sig_next <= '0';
							stateOp_next <= stateOpInit;
						end if;

					elsif tixDbeVXfer=tixDbeVXferRd then -- tx
						tixDbeVXfer <= tixDbeVXferRdack;

						spilen <= std_logic_vector(to_unsigned(lenAuxbufRdack, 11));
						i := 0;

						torestart_next <= '1';
						stateOp_next <= stateOpRxA;

					elsif tixDbeVXfer=tixDbeVXferRdack then -- rx
						if auxbuf(ixAuxbufTkn)=(not tkn) then
							stateOp_next <= stateOpCnfRd;
						else
							commok_sig_next <= '0';
							stateOp_next <= stateOpInit;
						end if;

					elsif tixDbeVXfer=tixDbeVXferWr then -- rx
						auxbuf(ixAuxbufXfer) <= tixDbeVXferWrack;
						tixDbeVXfer <= tixDbeVXferWrack;

						if (auxbuf(ixAuxbufWrCrc)=crcRxbuf(15 downto 8) and auxbuf(ixAuxbufWrCrc+1)=crcRxbuf(7 downto 0)) then
							auxbuf(ixAuxbufTkn) <= not tkn;
						end if;

						spilen <= std_logic_vector(to_unsigned(lenAuxbufWrack, 11));

						i := 0;
						d_next <= tixDbeVXferWrack;

						torestart_next <= '1';
						stateOp_next <= stateOpTxA;

					elsif tixDbeVXfer=tixDbeVXferWrack then -- tx
						if auxbuf(ixAuxbufTkn)=(not tkn) then
							stateOp_next <= stateOpCnfWr; -- only there, tkn flip, pr update
						else
							commok_sig_next <= '0';
							stateOp_next <= stateOpInit;
						end if;
					end if;

				else
					-- as opposed to reset
					commok_sig_next <= '0';

					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpPrepArbbx then
				auxbuf(ixAuxbufBxBx) <= arbbx;

				spilen <= std_logic_vector(to_unsigned(lenAuxbufBx, 11));

				i := 0;
				d_next <= auxbuf(ixAuxbufXfer);

				torestart_next <= '1';
				stateOp_next <= stateOpTxA;

			elsif stateOp=stateOpPrepAvllen then
				auxbuf(ixAuxbufLenLen) <= avllen(31 downto 24);
				auxbuf(ixAuxbufLenLen+1) <= avllen(23 downto 16);
				auxbuf(ixAuxbufLenLen+2) <= avllen(15 downto 8);
				auxbuf(ixAuxbufLenLen+3) <= avllen(7 downto 0);

				spilen <= std_logic_vector(to_unsigned(lenAuxbufLen, 11));

				i := 0;
				d_next <= auxbuf(ixAuxbufXfer);

				torestart_next <= '1';
				stateOp_next <= stateOpTxA;

			elsif stateOp=stateOpPrepArblen then
				auxbuf(ixAuxbufLenLen) <= arblen(31 downto 24);
				auxbuf(ixAuxbufLenLen+1) <= arblen(23 downto 16);
				auxbuf(ixAuxbufLenLen+2) <= arblen(15 downto 8);
				auxbuf(ixAuxbufLenLen+3) <= arblen(7 downto 0);

				spilen <= std_logic_vector(to_unsigned(lenAuxbufLen, 11));

				i := 0;
				d_next <= auxbuf(ixAuxbufXfer);

				torestart_next <= '1';
				stateOp_next <= stateOpTxA;

-- RX BEGIN
			elsif stateOp=stateOpRxA then
				if ackSpi='1' then
					if tixDbeVXfer=tixDbeVXferWr then
						stateOp_next <= stateOpRxB;
					else
						stateOp_next <= stateOpRxG;
					end if;

				elsif (timeout='1' and tixDbeVXfer/=tixDbeVXferTkn) then
					rxtxerr <= rxtxerrTo;
					stateOp_next <= stateOpStepXfer;

				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxB then
				if strbSpirecv='1' then
					auxbuf(i) <= spirecv;

					if (i=0 and spirecv/=tixDbeVXfer) then
						rxtxerr <= rxtxerrXfer;
						stateOp_next <= stateOpStepXfer;

					elsif (i=1 and spirecv/=tkn) then
						rxtxerr <= rxtxerrTkn;
						stateOp_next <= stateOpStepXfer;

					else
						stateOp_next <= stateOpRxC;
					end if;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpRxC then
				if strbSpirecv='0' then
					i := i + 1;

					if i=ixAuxbufWrRxbuf then
						reqRxbuf_next <= '1';

						j := 0;

						stateOp_next <= stateOpRxD;
					else
						stateOp_next <= stateOpRxB;
					end if;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpRxD then
				if (ackCrc='1' and ackRxbuf='1') then
					stateOp_next <= stateOpRxE;
				end if;

			elsif stateOp=stateOpRxE then
				if strbSpirecv='1' then
					crcd_next <= spirecv;
					dRxbuf_next <= spirecv;

					stateOp_next <= stateOpRxF;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpRxF then
				-- one clock cycle for crc to capture last byte ; allow finalizing until after last byte of transfer
				if strbSpirecv='0' then
					j := j + 1;
					
					if j=to_integer(unsigned(arblen)) then
						i := ixAuxbufWrCrc;
						stateOp_next <= stateOpRxG;
					else
						stateOp_next <= stateOpRxE;
					end if;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpRxG then
				if strbSpirecv='1' then
					auxbuf(i) <= spirecv;

					if (i=0 and spirecv/=tixDbeVXfer) then
						rxtxerr <= rxtxerrXfer;
						stateOp_next <= stateOpStepXfer;

					elsif (i=1 and (spirecv/=tkn and tixDbeVXfer/=tixDbeVXferTkn and (tixDbeVXfer/=tixDbeVXferRdack or spirecv/=(not tkn)))) then
						rxtxerr <= rxtxerrTkn;
						stateOp_next <= stateOpStepXfer;

					else
						stateOp_next <= stateOpRxH;
					end if;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpRxH then
				if dneSpi='1' then
					if dneCrc='1' then
						crcRxbuf <= crc;
					end if;

					stateOp_next <= stateOpRxI;

				elsif strbSpirecv='0' then
					i := i + 1;

					stateOp_next <= stateOpRxG;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpRxI then
				if ackSpi='0' then
					rxtxerr <= rxtxerrOk;
					stateOp_next <= stateOpStepXfer;
				end if;
-- RX END

-- TX BEGIN
			elsif stateOp=stateOpTxA then
				if ackSpi='1' then
					if tixDbeVXfer=tixDbeVXferRd then
						stateOp_next <= stateOpTxB;
					else
						stateOp_next <= stateOpTxI;
					end if;

				elsif timeout='1' then
					rxtxerr <= rxtxerrTo;
					stateOp_next <= stateOpStepXfer;

				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpTxB then
				if strbSpisend='0' then
					i := i + 1;

					if i=ixAuxbufRdTxbuf then
						reqTxbuf_next <= '1';

						j := 0;

						stateOp_next <= stateOpTxD;
					else
						d_next <= auxbuf(i);
						stateOp_next <= stateOpTxC;
					end if;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpTxC then
				if strbSpisend='1' then
					stateOp_next <= stateOpTxB;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpTxD then
				if (ackCrc='1' and ackTxbuf='1') then
					stateOp_next <= stateOpTxE;
				end if;

			elsif stateOp=stateOpTxE then
				if strbSpisend='1' then
					crcd_next <= spisend;
					stateOp_next <= stateOpTxF;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpTxF then
				-- one clock cycle for crc to capture last byte ; finalization has to terminate before next byte
				if strbSpisend='0' then
					j := j + 1;
	
					if j=to_integer(unsigned(arblen)) then
						stateOp_next <= stateOpTxG;
					else
						stateOp_next <= stateOpTxE;
					end if;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpTxG then
			 if dneCrc='1' then
				 i := ixAuxbufRdCrc;

				 auxbuf(i) <= crc(15 downto 8);
				 auxbuf(i+1) <= crc(7 downto 0);
 
				 d_next <= crc(15 downto 8);
	
				 stateOp_next <= stateOpTxH;
			 end if;

			elsif stateOp=stateOpTxH then
				if strbSpisend='1' then
					stateOp_next <= stateOpTxI;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpTxI then
				if dneSpi='1' then
					stateOp_next <= stateOpTxJ;

				elsif strbSpisend='0' then
					i := i + 1;

					d_next <= auxbuf(i);

					stateOp_next <= stateOpTxH;

				elsif ackSpi='0' then
					rxtxerr <= rxtxerrAbrt;
					stateOp_next <= stateOpStepXfer;
				end if;

			elsif stateOp=stateOpTxJ then
				if ackSpi='0' then
					rxtxerr <= rxtxerrOk;
					stateOp_next <= stateOpStepXfer;
				end if;
-- TX END

			elsif stateOp=stateOpCnfRd then
				if ackTxbuf='0' then
					if tkn=tknFromCmdret then
						lastBxPr0 := tixWIdhwIcm2BufferCmdretToHostif;
						tknFromCmdret <= not tknFromCmdret;
					elsif tkn=tknFromAcq then
						lastBxPr1 := tixWIdhwIcm2BufferAcqToHostif;
						tknFromAcq <= not tknFromAcq;
					end if;

					commok_sig_next <= '1';
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpCnfWr then
				if ackRxbuf='0' then
					if tkn=tknToCmdinv then
						lastBxPr0 := tixWIdhwIcm2BufferHostifToCmdinv;
						tknToCmdinv <= not tknToCmdinv;
					elsif tkn=tknToWavegen then
						lastBxPr1 := tixWIdhwIcm2BufferHostifToWavegen;
						tknToWavegen <= not tknToWavegen;
					end if;

					commok_sig_next <= '1';
					stateOp_next <= stateOpInit;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			tkn <= tkn_next;
			d <= d_next;
			reqTxbuf <= reqTxbuf_next;
			reqRxbuf <= reqRxbuf_next;
			dRxbuf <= dRxbuf_next;
			commok_sig <= commok_sig_next;
			reqReset_sig <= reqReset_sig_next;
			crcd <= crcd_next;
			torestart <= torestart_next;
		end if;
	end process;

end Hostif;

