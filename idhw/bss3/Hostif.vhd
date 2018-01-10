-- file Hostif.vhd
-- Hostif uarthostif_v1_0 host interface implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Idhw.all;
use work.Bss3.all;

entity Hostif is
	generic (
		fMclk: natural range 1 to 1000000;
		fSclk: natural range 100 to 50000000 := 5000000
	);
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

		avllenBufToCmdinv: in std_logic_vector(5 downto 0);

		dBufToCmdinv: out std_logic_vector(7 downto 0);
		strbDBufToCmdinv: out std_logic;

		reqBufFromCmdret: out std_logic;
		ackBufFromCmdret: in std_logic;
		dneBufFromCmdret: out std_logic;

		avllenBufFromCmdret: in std_logic_vector(7 downto 0);

		dBufFromCmdret: in std_logic_vector(7 downto 0);
		strbDBufFromCmdret: out std_logic;

		reqWrbufToQcdif: out std_logic;
		ackWrbufToQcdif: in std_logic;
		dneWrbufToQcdif: out std_logic;

		avllenWrbufToQcdif: in std_logic_vector(10 downto 0);

		dWrbufToQcdif: out std_logic_vector(7 downto 0);
		strbDWrbufToQcdif: out std_logic;

		reqRdbufFromQcdif: out std_logic;
		ackRdbufFromQcdif: in std_logic;
		dneRdbufFromQcdif: out std_logic;

		avllenRdbufFromQcdif: in std_logic_vector(10 downto 0);

		dRdbufFromQcdif: in std_logic_vector(7 downto 0);
		strbDRdbufFromQcdif: out std_logic;

		reqWrbufToDcxif: out std_logic;
		ackWrbufToDcxif: in std_logic;
		dneWrbufToDcxif: out std_logic;

		avllenWrbufToDcxif: in std_logic_vector(10 downto 0);

		dWrbufToDcxif: out std_logic_vector(7 downto 0);
		strbDWrbufToDcxif: out std_logic;

		reqRdbufFromDcxif: out std_logic;
		ackRdbufFromDcxif: in std_logic;
		dneRdbufFromDcxif: out std_logic;

		avllenRdbufFromDcxif: in std_logic_vector(10 downto 0);

		dRdbufFromDcxif: in std_logic_vector(7 downto 0);
		strbDRdbufFromDcxif: out std_logic;

		reqOutbuf0FromPmmu: out std_logic;
		ackOutbuf0FromPmmu: in std_logic;
		dneOutbuf0FromPmmu: out std_logic;

		avllenOutbuf0FromPmmu: in std_logic_vector(17 downto 0);

		dOutbuf0FromPmmu: in std_logic_vector(7 downto 0);
		strbDOutbuf0FromPmmu: out std_logic;

		rxd: in std_logic;
		txd: out std_logic
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

	component Uartrx_v1_0 is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;
			fSclk: natural range 100 to 50000000 := 9600
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			len: in std_logic_vector(10 downto 0);

			d: out std_logic_vector(7 downto 0);
			strbD: out std_logic;

			rxd: in std_logic
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

	component Uarttx_v1_0 is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;

			fSclk: natural range 100 to 50000000 := 9600;
			Nstop: natural range 1 to 8 := 1
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			len: in std_logic_vector(10 downto 0);

			d: in std_logic_vector(7 downto 0);
			strbD: out std_logic;

			txd: out std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	--- main operation
	type stateOp_t is (
		stateOpInit,
		stateOpStepXfer,
		stateOpPrepArbbx,
		stateOpPrepAvllen,
		stateOpPrepArblen,
		stateOpRxA, stateOpRxB, stateOpRxC, stateOpRxD, stateOpRxE,
		stateOpRxF, stateOpRxG, stateOpRxH,
		stateOpRxI,
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
	signal tknFromCmdret: std_logic_vector(7 downto 0) := tixWIdhwBss3BufferCmdretToHostif;
	signal tknToCmdinv: std_logic_vector(7 downto 0) := tixWIdhwBss3BufferHostifToCmdinv;
	signal tknFromPmmu: std_logic_vector(7 downto 0) := tixWIdhwBss3BufferPmmuToHostif;
	signal tknFromDcxif: std_logic_vector(7 downto 0) := tixWIdhwBss3BufferDcxifToHostif;
	signal tknToDcxif: std_logic_vector(7 downto 0) := tixWIdhwBss3BufferHostifToDcxif;
	signal tknToQcdif: std_logic_vector(7 downto 0) := tixWIdhwBss3BufferHostifToQcdif;
	signal tknFromQcdif: std_logic_vector(7 downto 0) := tixWIdhwBss3BufferQcdifToHostif;

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

	type rxerr_t is (
		rxerrOk,
		rxerrXfer,
		rxerrTkn,
		rxerrTo
	);
	signal rxerr: rxerr_t;

	signal urxlen: std_logic_vector(10 downto 0);

	signal utxlen: std_logic_vector(10 downto 0);

	signal utxd: std_logic_vector(7 downto 0);

	---- myCrc
	signal crc: std_logic_vector(15 downto 0);

	---- myRx
	signal urxd: std_logic_vector(7 downto 0);
	signal strbUrxd: std_logic;

	---- myTimeout
	signal timeout: std_logic;

	---- myTx
	signal strbUtxd: std_logic;

	---- handshake
	-- op to myCrc
	signal reqCrc: std_logic;
	signal ackCrc: std_logic;
	signal dneCrc: std_logic;

	-- op to myRx
	signal reqUrx: std_logic;
	signal ackUrx: std_logic;
	signal dneUrx: std_logic;

	-- op to myTx
	signal reqUtx: std_logic;
	signal ackUtx: std_logic;
	signal dneUtx: std_logic;

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

	myRx : Uartrx_v1_0
		port map (
			reset => reset,
			mclk => mclk,

			req => reqUrx,
			ack => ackUrx,
			dne => dneUrx,

			len => urxlen,

			d => urxd,
			strbD => strbUrxd,

			rxd => rxd
		);

	myTimeout : Timeout_v1_0
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			restart => torestart,
			timeout => timeout
		);

	myTx : Uarttx_v1_0
		port map (
			reset => reset,
			mclk => mclk,

			req => reqUtx,
			ack => ackUtx,
			dne => dneUtx,

			len => utxlen,

			d => utxd,
			strbD => strbUtxd,

			txd => txd
		);

	------------------------------------------------------------------------
	-- implementation: main operation 
	------------------------------------------------------------------------

	tknste(0) <= '0' when tknFromCmdret=tixWIdhwBss3BufferCmdretToHostif else '1';
	tknste(1) <= '0' when tknToCmdinv=tixWIdhwBss3BufferHostifToCmdinv else '1';
	tknste(2) <= '0' when tknFromPmmu=tixWIdhwBss3BufferPmmuToHostif else '1';
	tknste(3) <= '0' when tknFromDcxif=tixWIdhwBss3BufferDcxifToHostif else '1';
	tknste(4) <= '0' when tknToDcxif=tixWIdhwBss3BufferHostifToDcxif else '1';
	tknste(5) <= '0' when tknToQcdif=tixWIdhwBss3BufferHostifToQcdif else '1';
	tknste(6) <= '0' when tknFromQcdif=tixWIdhwBss3BufferQcdifToHostif else '1';
	tknste(7) <= '0';

	avlbx(0) <= '1' when avllenBufFromCmdret/=x"00" else '0';
	avlbx(1) <= '1' when avllenBufToCmdinv/="000000" else '0';
	avlbx(2) <= '1' when avllenOutbuf0FromPmmu/="000000000000000000" else '0';
	avlbx(3) <= '1' when avllenRdbufFromDcxif/="00000000000" else '0';
	avlbx(4) <= '1' when avllenWrbufToDcxif/="00000000000" else '0';
	avlbx(5) <= '1' when avllenWrbufToQcdif/="00000000000" else '0';
	avlbx(6) <= '1' when avllenRdbufFromQcdif/="00000000000" else '0';
	avlbx(7) <= '0';

	avllen <= x"000000" & avllenBufFromCmdret when (tkn=tixWIdhwBss3BufferCmdretToHostif or tkn=(not tixWIdhwBss3BufferCmdretToHostif))
				else "00000000000000000000000000" & avllenBufToCmdinv when (tkn=tixWIdhwBss3BufferHostifToCmdinv or tkn=(not tixWIdhwBss3BufferHostifToCmdinv))
				else "00000000000000" & avllenOutbuf0FromPmmu when (tkn=tixWIdhwBss3BufferPmmuToHostif or tkn=(not tixWIdhwBss3BufferPmmuToHostif))
				else "000000000000000000000" & avllenRdbufFromDcxif when (tkn=tixWIdhwBss3BufferDcxifToHostif or tkn=(not tixWIdhwBss3BufferDcxifToHostif))
				else "000000000000000000000" & avllenWrbufToDcxif when (tkn=tixWIdhwBss3BufferHostifToDcxif or tkn=(not tixWIdhwBss3BufferHostifToDcxif))
				else "000000000000000000000" & avllenWrbufToQcdif when (tkn=tixWIdhwBss3BufferHostifToQcdif or tkn=(not tixWIdhwBss3BufferHostifToQcdif))
				else "000000000000000000000" & avllenRdbufFromQcdif when (tkn=tixWIdhwBss3BufferQcdifToHostif or tkn=(not tixWIdhwBss3BufferQcdifToHostif))
				else x"00000000";

	ackTxbuf <= ackBufFromCmdret when (tkn=tixWIdhwBss3BufferCmdretToHostif or tkn=(not tixWIdhwBss3BufferCmdretToHostif))
				else ackOutbuf0FromPmmu when (tkn=tixWIdhwBss3BufferPmmuToHostif or tkn=(not tixWIdhwBss3BufferPmmuToHostif))
				else ackRdbufFromDcxif when (tkn=tixWIdhwBss3BufferDcxifToHostif or tkn=(not tixWIdhwBss3BufferDcxifToHostif))
				else ackRdbufFromQcdif when (tkn=tixWIdhwBss3BufferQcdifToHostif or tkn=(not tixWIdhwBss3BufferQcdifToHostif))
				else '0';

	dneTxbuf <= '1' when stateOp=stateOpCnfrd else '0';

	dTxbuf <= dBufFromCmdret when (tkn=tixWIdhwBss3BufferCmdretToHostif or tkn=(not tixWIdhwBss3BufferCmdretToHostif))
				else dOutbuf0FromPmmu when (tkn=tixWIdhwBss3BufferPmmuToHostif or tkn=(not tixWIdhwBss3BufferPmmuToHostif))
				else dRdbufFromDcxif when (tkn=tixWIdhwBss3BufferDcxifToHostif or tkn=(not tixWIdhwBss3BufferDcxifToHostif))
				else dRdbufFromQcdif when (tkn=tixWIdhwBss3BufferQcdifToHostif or tkn=(not tixWIdhwBss3BufferQcdifToHostif))
				else x"00";

	strbDTxbuf <= '0' when (stateOp=stateOpTxD or stateOp=stateOpTxE) else '1';

	ackRxbuf <= ackBufToCmdinv when (tkn=tixWIdhwBss3BufferHostifToCmdinv or tkn=(not tixWIdhwBss3BufferHostifToCmdinv))
				else ackWrbufToDcxif when (tkn=tixWIdhwBss3BufferHostifToDcxif or tkn=(not tixWIdhwBss3BufferHostifToDcxif))
				else ackWrbufToQcdif when (tkn=tixWIdhwBss3BufferHostifToQcdif or tkn=(not tixWIdhwBss3BufferHostifToQcdif))
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

	reqUrx <= '1' when (stateOp=stateOpRxA or stateOp=stateOpRxB or stateOp=stateOpRxC or stateOp=stateOpRxD or stateOp=stateOpRxE
				or stateOp=stateOpRxF or stateOp=stateOpRxG or stateOp=stateOpRxH) else '0';

	reqUtx <= '1' when (stateOp=stateOpTxA or stateOp=stateOpTxB or stateOp=stateOpTxC or stateOp=stateOpTxD or stateOp=stateOpTxE
				or stateOp=stateOpTxF or stateOp=stateOpTxG or stateOp=stateOpTxH or stateOp=stateOpTxI)
				else '0';

	utxd <= dTxbuf when (stateOp=stateOpTxD or stateOp=stateOpTxE or stateOp=stateOpTxF or stateOp=stateOpTxG) else d;

	-- fromCmdret
	reqBufFromCmdret <= reqTxbuf when tkn=tknFromCmdret else '0';
	dneBufFromCmdret <= dneTxbuf when tkn=tknFromCmdret else '0';

	strbDBufFromCmdret <= strbDTxbuf;

	-- toCmdinv
	reqBufToCmdinv <= reqRxbuf when tkn=tknToCmdinv else '0';
	dneBufToCmdinv <= dneRxbuf when tkn=tknToCmdinv else '0';

	dBufToCmdinv <= dRxbuf;
	strbDBufToCmdinv <= strbDRxbuf;

	-- fromPmmu
	reqOutbuf0FromPmmu <= reqTxbuf when tkn=tknFromPmmu else '0';
	dneOutbuf0FromPmmu <= dneTxbuf when tkn=tknFromPmmu else '0';

	strbDOutbuf0FromPmmu <= strbDTxbuf;

	-- fromDcxif
	reqRdbufFromDcxif <= reqTxbuf when tkn=tknFromDcxif else '0';
	dneRdbufFromDcxif <= dneTxbuf when tkn=tknFromDcxif else '0';

	strbDRdbufFromDcxif <= strbDTxbuf;

	-- toDcxif
	reqWrbufToDcxif <= reqRxbuf when tkn=tknToDcxif else '0';
	dneWrbufToDcxif <= dneRxbuf when tkn=tknToDcxif else '0';

	dWrbufToDcxif <= dRxbuf;
	strbDWrbufToDcxif <= strbDRxbuf;

	-- toQcdif
	reqWrbufToQcdif <= reqRxbuf when tkn=tknToQcdif else '0';
	dneWrbufToQcdif <= dneRxbuf when tkn=tknToQcdif else '0';

	dWrbufToQcdif <= dRxbuf;
	strbDWrbufToQcdif <= strbDRxbuf;

	-- fromQcdif
	reqRdbufFromQcdif <= reqTxbuf when tkn=tknFromQcdif else '0';
	dneRdbufFromQcdif <= dneTxbuf when tkn=tknFromQcdif else '0';

	strbDRdbufFromQcdif <= strbDTxbuf;

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
			tknFromCmdret <= tixWIdhwBss3BufferCmdretToHostif;
			tknToCmdinv <= tixWIdhwBss3BufferHostifToCmdinv;
			tknFromPmmu <= tixWIdhwBss3BufferPmmuToHostif;
			tknFromDcxif <= tixWIdhwBss3BufferDcxifToHostif;
			tknToDcxif <= tixWIdhwBss3BufferHostifToDcxif;
			tknToQcdif <= tixWIdhwBss3BufferHostifToQcdif;
			tknFromQcdif <= tixWIdhwBss3BufferQcdifToHostif;
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
					urxlen <= std_logic_vector(to_unsigned(lenAuxbufTkn, 11));

					i := 0;

					stateOp_next <= stateOpRxA;

				elsif rxerr=rxerrOk then
					-- rx/tx completed successfully
					if tixDbeVXfer=tixDbeVXferTkn then -- rx
						if auxbuf(ixAuxbufTkn)=tknReset then
							reqReset_sig_next <= '1';

						elsif auxbuf(ixAuxbufTkn)=tknPing then
							auxbuf(ixAuxbufXfer) <= tixDbeVXferTknste;
							tixDbeVXfer <= tixDbeVXferTknste;

							auxbuf(ixAuxbufTknsteTknste) <= tknste;

							utxlen <= std_logic_vector(to_unsigned(lenAuxbufTknste, 11));

							i := 0;
							d_next <= tixDbeVXferTknste;

							stateOp_next <= stateOpTxA;

						elsif (auxbuf(ixAuxbufTkn)=tknFromCmdret or auxbuf(ixAuxbufTkn)=tknToCmdinv or auxbuf(ixAuxbufTkn)=tknFromPmmu or auxbuf(ixAuxbufTkn)=tknFromDcxif or auxbuf(ixAuxbufTkn)=tknToDcxif or auxbuf(ixAuxbufTkn)=tknToQcdif or auxbuf(ixAuxbufTkn)=tknFromQcdif) then

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

						utxlen <= std_logic_vector(to_unsigned(lenAuxbufBx, 11));

						i := 0;
						d_next <= tixDbeVXferAvlbx;

						stateOp_next <= stateOpTxA;

					elsif tixDbeVXfer=tixDbeVXferAvlbx then -- tx
						tixDbeVXfer <= tixDbeVXferReqbx;

						urxlen <= std_logic_vector(to_unsigned(lenAuxbufBx, 11));
						i := 0;

						torestart_next <= '1';
						stateOp_next <= stateOpRxA;

					elsif tixDbeVXfer=tixDbeVXferReqbx then -- rx
						-- debug
						--reqbx <= auxbuf(ixAuxbufBxBx);

						auxbuf(ixAuxbufXfer) <= tixDbeVXferArbbx;
						tixDbeVXfer <= tixDbeVXferArbbx;

						-- buffer transfer arbitration
						y := avlbx and auxbuf(ixAuxbufBxBx);

						if ( ((y and tixWIdhwBss3BufferCmdretToHostif) /= x"00") and ( (lastBxPr0 /= tixWIdhwBss3BufferCmdretToHostif) or ((y and (tixWIdhwBss3BufferCmdretToHostif or tixWIdhwBss3BufferHostifToCmdinv or tixWIdhwBss3BufferPmmuToHostif)) = tixWIdhwBss3BufferCmdretToHostif) ) ) then
							arbbx <= tixWIdhwBss3BufferCmdretToHostif;
						elsif ( ((y and tixWIdhwBss3BufferHostifToCmdinv) /= x"00") and ( (lastBxPr0 /= tixWIdhwBss3BufferHostifToCmdinv) or ((y and (tixWIdhwBss3BufferCmdretToHostif or tixWIdhwBss3BufferHostifToCmdinv or tixWIdhwBss3BufferPmmuToHostif)) = tixWIdhwBss3BufferHostifToCmdinv) ) ) then
							arbbx <= tixWIdhwBss3BufferHostifToCmdinv;
						elsif ( ((y and tixWIdhwBss3BufferPmmuToHostif) /= x"00") and ( (lastBxPr0 /= tixWIdhwBss3BufferPmmuToHostif) or ((y and (tixWIdhwBss3BufferCmdretToHostif or tixWIdhwBss3BufferHostifToCmdinv or tixWIdhwBss3BufferPmmuToHostif)) = tixWIdhwBss3BufferPmmuToHostif) ) ) then
							arbbx <= tixWIdhwBss3BufferPmmuToHostif;
						elsif ((y and tixWIdhwBss3BufferDcxifToHostif) /= x"00") then
							arbbx <= tixWIdhwBss3BufferDcxifToHostif;
						elsif ( ((y and tixWIdhwBss3BufferHostifToDcxif) /= x"00") and ( (lastBxPr1 /= tixWIdhwBss3BufferHostifToDcxif) or ((y and (tixWIdhwBss3BufferDcxifToHostif or tixWIdhwBss3BufferHostifToDcxif or tixWIdhwBss3BufferHostifToQcdif or tixWIdhwBss3BufferQcdifToHostif)) = tixWIdhwBss3BufferHostifToDcxif) ) ) then
							arbbx <= tixWIdhwBss3BufferHostifToDcxif;
						elsif ( ((y and tixWIdhwBss3BufferHostifToQcdif) /= x"00") and ( (lastBxPr1 /= tixWIdhwBss3BufferHostifToQcdif) or ((y and (tixWIdhwBss3BufferDcxifToHostif or tixWIdhwBss3BufferHostifToDcxif or tixWIdhwBss3BufferHostifToQcdif or tixWIdhwBss3BufferQcdifToHostif)) = tixWIdhwBss3BufferHostifToQcdif) ) ) then
							arbbx <= tixWIdhwBss3BufferHostifToQcdif;
						elsif ( ((y and tixWIdhwBss3BufferQcdifToHostif) /= x"00") and ( (lastBxPr1 /= tixWIdhwBss3BufferQcdifToHostif) or ((y and (tixWIdhwBss3BufferDcxifToHostif or tixWIdhwBss3BufferHostifToDcxif or tixWIdhwBss3BufferHostifToQcdif or tixWIdhwBss3BufferQcdifToHostif)) = tixWIdhwBss3BufferQcdifToHostif) ) ) then
							arbbx <= tixWIdhwBss3BufferQcdifToHostif;

						else
							arbbx <= x"00";
						end if;

						stateOp_next <= stateOpPrepArbbx;

					elsif tixDbeVXfer=tixDbeVXferArbbx then -- tx
						commok_sig_next <= '1';
						stateOp_next <= stateOpInit;

					elsif tixDbeVXfer=tixDbeVXferAvllen then -- tx
						tixDbeVXfer <= tixDbeVXferReqlen;

						urxlen <= std_logic_vector(to_unsigned(lenAuxbufLen, 11));
						i := 0;

						torestart_next <= '1';
						stateOp_next <= stateOpRxA;

					elsif tixDbeVXfer=tixDbeVXferReqlen then -- rx
						auxbuf(ixAuxbufXfer) <= tixDbeVXferArblen;
						tixDbeVXfer <= tixDbeVXferArblen;

						-- length arbitration
						z := auxbuf(ixAuxbufLenLen) & auxbuf(ixAuxbufLenLen+1) & auxbuf(ixAuxbufLenLen+2) & auxbuf(ixAuxbufLenLen+3);

						-- debug
						--reqlen <= z;

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

						elsif (auxbuf(ixAuxbufTkn)=tknFromCmdret or auxbuf(ixAuxbufTkn)=tknFromPmmu or auxbuf(ixAuxbufTkn)=tknFromDcxif or auxbuf(ixAuxbufTkn)=tknFromQcdif) then
							auxbuf(ixAuxbufXfer) <= tixDbeVXferRd;
							tixDbeVXfer <= tixDbeVXferRd;

							x := to_integer(unsigned(arblen)) + 4;
							utxlen <= std_logic_vector(to_unsigned(x, 11));

							i := 0;

							d_next <= tixDbeVXferRd;
							stateOp_next <= stateOpTxA;

						elsif (auxbuf(ixAuxbufTkn)=tknToCmdinv or auxbuf(ixAuxbufTkn)=tknToDcxif or auxbuf(ixAuxbufTkn)=tknToQcdif) then
							tixDbeVXfer <= tixDbeVXferWr;

							x := to_integer(unsigned(arblen)) + 4;
							urxlen <= std_logic_vector(to_unsigned(x, 11));

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

						urxlen <= std_logic_vector(to_unsigned(lenAuxbufRdack, 11));
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

						utxlen <= std_logic_vector(to_unsigned(lenAuxbufWrack, 11));

						i := 0;
						d_next <= tixDbeVXferWrack;

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

				utxlen <= std_logic_vector(to_unsigned(lenAuxbufBx, 11));

				i := 0;
				d_next <= auxbuf(ixAuxbufXfer);

				stateOp_next <= stateOpTxA;

			elsif stateOp=stateOpPrepAvllen then
				auxbuf(ixAuxbufLenLen) <= avllen(31 downto 24);
				auxbuf(ixAuxbufLenLen+1) <= avllen(23 downto 16);
				auxbuf(ixAuxbufLenLen+2) <= avllen(15 downto 8);
				auxbuf(ixAuxbufLenLen+3) <= avllen(7 downto 0);

				utxlen <= std_logic_vector(to_unsigned(lenAuxbufLen, 11));

				i := 0;
				d_next <= auxbuf(ixAuxbufXfer);

				stateOp_next <= stateOpTxA;

			elsif stateOp=stateOpPrepArblen then
				auxbuf(ixAuxbufLenLen) <= arblen(31 downto 24);
				auxbuf(ixAuxbufLenLen+1) <= arblen(23 downto 16);
				auxbuf(ixAuxbufLenLen+2) <= arblen(15 downto 8);
				auxbuf(ixAuxbufLenLen+3) <= arblen(7 downto 0);

				utxlen <= std_logic_vector(to_unsigned(lenAuxbufLen, 11));

				i := 0;
				d_next <= auxbuf(ixAuxbufXfer);

				stateOp_next <= stateOpTxA;

-- RX BEGIN
			elsif stateOp=stateOpRxA then
				if ackUrx='1' then
					if tixDbeVXfer=tixDbeVXferWr then
						stateOp_next <= stateOpRxB;
					else
						stateOp_next <= stateOpRxG;
					end if;

				elsif (timeout='1' and tixDbeVXfer/=tixDbeVXferTkn) then
					rxerr <= rxerrTo;
					stateOp_next <= stateOpStepXfer;

				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxB then
				if strbUrxd='1' then
					auxbuf(i) <= urxd;

					if (i=0 and urxd/=tixDbeVXfer) then
						rxerr <= rxerrXfer;
						stateOp_next <= stateOpStepXfer;

					elsif (i=1 and urxd/=tkn) then
						rxerr <= rxerrTkn;
						stateOp_next <= stateOpStepXfer;

					else
						torestart_next <= '1';
						stateOp_next <= stateOpRxC;
					end if;
				end if;

			elsif stateOp=stateOpRxC then
				if strbUrxd='0' then
					i := i + 1;

					if i=ixAuxbufWrRxbuf then
						reqRxbuf_next <= '1';

						j := 0;

						stateOp_next <= stateOpRxD;
					else
						stateOp_next <= stateOpRxB;
					end if;

				elsif timeout='1' then
					rxerr <= rxerrTo;
					stateOp_next <= stateOpStepXfer;
				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxD then
				if (ackCrc='1' and ackRxbuf='1') then
					stateOp_next <= stateOpRxE;
				end if;

			elsif stateOp=stateOpRxE then
				if strbUrxd='1' then
					crcd_next <= urxd;
					dRxbuf_next <= urxd;

					torestart_next <= '1';
					stateOp_next <= stateOpRxF;
				end if;

			elsif stateOp=stateOpRxF then
				-- one clock cycle for crc to capture last byte ; allow finalizing until after last byte of transfer
				if strbUrxd='0' then
					j := j + 1;
					
					if j=to_integer(unsigned(arblen)) then
						i := ixAuxbufWrCrc;
	
						torestart_next <= '1';
						stateOp_next <= stateOpRxG;
					else
						torestart_next <= '1';
						stateOp_next <= stateOpRxE;
					end if;

				elsif timeout='1' then
					rxerr <= rxerrTo;
					stateOp_next <= stateOpStepXfer;
				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxG then
				if strbUrxd='1' then
					auxbuf(i) <= urxd;

					-- debug
					--if tixDbeVXfer=tixDbeVXferTkn then
					--	if i=0 then
					--		xfertkn(15 downto 8) <= urxd;
					--	elsif i=1 then
					--		xfertkn(7 downto 0) <= urxd;
					--	end if;
					--end if;

					if (i=0 and urxd/=tixDbeVXfer) then
						rxerr <= rxerrXfer;
						stateOp_next <= stateOpStepXfer;

					elsif (i=1 and (urxd/=tkn and tixDbeVXfer/=tixDbeVXferTkn and (tixDbeVXfer/=tixDbeVXferRdack or urxd/=(not tkn)))) then
						rxerr <= rxerrTkn;
						stateOp_next <= stateOpStepXfer;

					else
						torestart_next <= '1';
						stateOp_next <= stateOpRxH;
					end if;
				end if;

			elsif stateOp=stateOpRxH then
				if dneUrx='1' then
					if dneCrc='1' then
						crcRxbuf <= crc;
					end if;

					stateOp_next <= stateOpRxI;

				elsif strbUrxd='0' then
					i := i + 1;

					stateOp_next <= stateOpRxG;

				elsif timeout='1' then
					rxerr <= rxerrTo;
					stateOp_next <= stateOpStepXfer;
				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxI then
				if ackUrx='0' then
					rxerr <= rxerrOk;
					stateOp_next <= stateOpStepXfer;
				end if;
-- RX END
				
-- TX BEGIN
			elsif stateOp=stateOpTxA then
				if ackUtx='1' then
					if tixDbeVXfer=tixDbeVXferRd then
						stateOp_next <= stateOpTxB;
					else
						stateOp_next <= stateOpTxI;
					end if;
				end if;

			elsif stateOp=stateOpTxB then
				if strbUtxd='0' then
					i := i + 1;

					if i=ixAuxbufRdTxbuf then
						reqTxbuf_next <= '1';

						j := 0;

						stateOp_next <= stateOpTxD;
					else
						d_next <= auxbuf(i);
						stateOp_next <= stateOpTxC;
					end if;
				end if;

			elsif stateOp=stateOpTxC then
				if strbUtxd='1' then
					stateOp_next <= stateOpTxB;
				end if;

			elsif stateOp=stateOpTxD then
				if (ackCrc='1' and ackTxbuf='1') then
					stateOp_next <= stateOpTxE;
				end if;

			elsif stateOp=stateOpTxE then
				if strbUtxd='1' then
					crcd_next <= utxd;
					stateOp_next <= stateOpTxF;
				end if;

			elsif stateOp=stateOpTxF then
				-- one clock cycle for crc to capture last byte ; finalization has to terminate before next byte
				if strbUtxd='0' then
					j := j + 1;
	
					if j=to_integer(unsigned(arblen)) then
						stateOp_next <= stateOpTxG;
					else
						stateOp_next <= stateOpTxE;
					end if;
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
				if strbUtxd='1' then
					stateOp_next <= stateOpTxI;
				end if;

			elsif stateOp=stateOpTxI then
				if dneUtx='1' then
					stateOp_next <= stateOpTxJ;

				elsif strbUtxd='0' then
					i := i + 1;

					d_next <= auxbuf(i);

					stateOp_next <= stateOpTxH;
				end if;

			elsif stateOp=stateOpTxJ then
				if ackUtx='0' then
					stateOp_next <= stateOpStepXfer;
				end if;
-- TX END

			elsif stateOp=stateOpCnfRd then
				if ackTxbuf='0' then
					if tkn=tknFromCmdret then
						lastBxPr0 := tixWIdhwBss3BufferCmdretToHostif;
						tknFromCmdret <= not tknFromCmdret;
					elsif tkn=tknFromPmmu then
						lastBxPr0 := tixWIdhwBss3BufferPmmuToHostif;
						tknFromPmmu <= not tknFromPmmu;
					elsif tkn=tknFromDcxif then
						lastBxPr1 := tixWIdhwBss3BufferDcxifToHostif;
						tknFromDcxif <= not tknFromDcxif;
					elsif tkn=tknFromQcdif then
						lastBxPr1 := tixWIdhwBss3BufferQcdifToHostif;
						tknFromQcdif <= not tknFromQcdif;
					end if;

					commok_sig_next <= '1';
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpCnfWr then
				if ackRxbuf='0' then
					if tkn=tknToCmdinv then
						lastBxPr0 := tixWIdhwBss3BufferHostifToCmdinv;
						tknToCmdinv <= not tknToCmdinv;
					elsif tkn=tknToDcxif then
						lastBxPr1 := tixWIdhwBss3BufferHostifToDcxif;
						tknToDcxif <= not tknToDcxif;
					elsif tkn=tknToQcdif then
						lastBxPr1 := tixWIdhwBss3BufferHostifToQcdif;
						tknToQcdif <= not tknToQcdif;
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

