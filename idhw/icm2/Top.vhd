-- file Top.vhd
-- Top top_v1_0 top implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.Dbecore.all;
use work.Icm2.all;

entity Top is
	generic (
		fExtclk: natural range 1 to 1000000 := 200000;
		fMclk: natural range 1 to 1000000 := 50000
	);
	port (
		s_mosi: out std_logic;
		s_sclk: out std_logic;
		s_ncs: out std_logic;
		s_miso: in std_logic;
		f_sens: in std_logic;
		f_sw: out std_logic;
		m_nss: in std_logic;
		m_sclk: in std_logic;
		m_mosi: in std_logic;
		m_miso: inout std_logic;
		extclkp: in std_logic;
		extclkn: in std_logic;
		q_cmt: out std_logic;
		q_decmt: out std_logic;
		q_reset: out std_logic;
		q_sbs: out std_logic;
		q_cs: out std_logic;
		q_sclk: out std_logic;
		q_mosi: out std_logic;
		q_miso: in std_logic;
		ledg: out std_logic;
		ledr: out std_logic;
		sig: out std_logic;
		a_ncs: out std_logic;
		a_sclk: out std_logic;
		a_mosi: out std_logic;
		a_miso: in std_logic;
		p_ncs: out std_logic;
		p_sclk: out std_logic;
		p_mosi: out std_logic;
		p_miso: in std_logic;
		v_ncs: out std_logic;
		v_sclk: out std_logic;
		v_mosi: out std_logic;
		v_miso: in std_logic
	);
end Top;

architecture Top of Top is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Acq is
		generic (
			fMclk: natural range 1 to 1000000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			reqCmdbusToRoic: out std_logic;
			wrCmdbusToRoic: in std_logic;

			reqCmdbusToTkclksrc: out std_logic;
			wrCmdbusToTkclksrc: in std_logic;

			reqCmdbusToVmon: out std_logic;
			wrCmdbusToVmon: in std_logic;

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			rdyCmdbusFromTkclksrc: out std_logic;
			rdCmdbusFromTkclksrc: in std_logic;

			rdyCmdbusFromVmon: out std_logic;
			rdCmdbusFromVmon: in std_logic;

			reqBufToHostif: in std_logic;
			ackBufToHostif: out std_logic;
			dneBufToHostif: in std_logic;

			avllenBufToHostif: out std_logic_vector(10 downto 0);

			dBufToHostif: out std_logic_vector(7 downto 0);
			strbDBufToHostif: in std_logic;

			cmtclk: in std_logic;
			tempok: in std_logic;

			prep: out std_logic;
			rng: out std_logic;

			strbPixstep: out std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Cmdbus is
		generic (
			fMclk: natural range 1 to 1000000 := 50000;
			fClk: natural range 1 to 100000 := 12500
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			clk: out std_logic;

			rdy: in std_logic_vector(23 downto 0);

			req: in std_logic_vector(23 downto 0);
			ack: out std_logic_vector(23 downto 0)
		);
	end component;

	component Cmdinv is
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
	end component;

	component Cmdret is
		port (
			reset: in std_logic;
			mclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: in std_logic_vector(7 downto 0);

			rdyCmdbusFromAcq: out std_logic;
			rdCmdbusFromAcq: in std_logic;

			rdyCmdbusFromFan: out std_logic;
			rdCmdbusFromFan: in std_logic;

			rdyCmdbusFromState: out std_logic;
			rdCmdbusFromState: in std_logic;

			rdyCmdbusFromTkclksrc: out std_logic;
			rdCmdbusFromTkclksrc: in std_logic;

			rdyCmdbusFromVmon: out std_logic;
			rdCmdbusFromVmon: in std_logic;

			reqBufToHostif: in std_logic;
			ackBufToHostif: out std_logic;
			dneBufToHostif: in std_logic;

			avllenBufToHostif: out std_logic_vector(4 downto 0);

			dBufToHostif: out std_logic_vector(7 downto 0);
			strbDBufToHostif: in std_logic
		);
	end component;

	component Fan is
		generic (
			Ti: natural range 1000 to 10000 := 2500
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			rdyCmdbusFromTemp: out std_logic;
			rdCmdbusFromTemp: in std_logic;

			rng: out std_logic;

			sens: in std_logic;
			sw: out std_logic
		);
	end component;

	component Hostif is
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
	end component;

	component Roic is
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
	end component;

	component State is
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			acqrng: in std_logic;
			commok: in std_logic;
			tempok: in std_logic;

			ledg: out std_logic;
			ledr: out std_logic
		);
	end component;

	component Sync is
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
	end component;

	component Temp is
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToFan: out std_logic;
			wrCmdbusToFan: in std_logic;

			reqCmdbusToVmon: out std_logic;
			wrCmdbusToVmon: in std_logic;

			reqCmdbusToVset: out std_logic;
			wrCmdbusToVset: in std_logic;

			rdyCmdbusFromVmon: out std_logic;
			rdCmdbusFromVmon: in std_logic;

			acqprep: in std_logic;
			fanrng: in std_logic;
			ok: out std_logic
		);
	end component;

	component Tkclksrc is
		generic (
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: out std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromAcq: out std_logic;
			rdCmdbusFromAcq: in std_logic;

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			reqCmdbusToAcq: out std_logic;
			wrCmdbusToAcq: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic
		);
	end component;

	component Vmon is
		generic (
			Tsmp: natural range 10 to 10000 := 100;
			fMclk: natural range 1 to 1000000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			clkCmdbus: in std_logic;
			dCmdbus: inout std_logic_vector(7 downto 0);

			rdyCmdbusFromAcq: out std_logic;
			rdCmdbusFromAcq: in std_logic;

			rdyCmdbusFromCmdinv: out std_logic;
			rdCmdbusFromCmdinv: in std_logic;

			rdyCmdbusFromTemp: out std_logic;
			rdCmdbusFromTemp: in std_logic;

			reqCmdbusToAcq: out std_logic;
			wrCmdbusToAcq: in std_logic;

			reqCmdbusToCmdret: out std_logic;
			wrCmdbusToCmdret: in std_logic;

			reqCmdbusToTemp: out std_logic;
			wrCmdbusToTemp: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Vset is
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

			rdyCmdbusFromTemp: out std_logic;
			rdCmdbusFromTemp: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Wavegen is
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
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- master clock (mclk)

	signal mclk, mclk_sig: std_logic;

	---- reset (rst)
	type stateRst_t is (
		stateRstReset,
		stateRstRun
	);
	signal stateRst, stateRst_next: stateRst_t := stateRstReset;

	signal reset: std_logic;

	---- myAcq
	signal acqprep: std_logic;
	signal acqrng: std_logic;

	signal strbPixstep: std_logic;
	signal avllenBufAcqToHostif: std_logic_vector(10 downto 0);

	signal dBufAcqToHostif: std_logic_vector(7 downto 0);

	---- myCmdbus
	signal clkCmdbus, clkCmdbus_sig: std_logic;
	signal ackCmdbus: std_logic_vector(23 downto 0);

	---- myCmdinv
	signal avllenBufHostifToCmdinv: std_logic_vector(4 downto 0);

	---- myCmdret
	signal avllenBufCmdretToHostif: std_logic_vector(4 downto 0);

	signal dBufCmdretToHostif: std_logic_vector(7 downto 0);

	---- myFan
	signal fanrng: std_logic;

	---- myHostif
	signal commok: std_logic;

	signal dBufHostifToCmdinv: std_logic_vector(7 downto 0);
	signal strbDBufHostifToCmdinv: std_logic;

	signal strbDBufCmdretToHostif: std_logic;

	signal strbDBufAcqToHostif: std_logic;

	signal dBufHostifToWavegen: std_logic_vector(7 downto 0);
	signal strbDBufHostifToWavegen: std_logic;

	---- myIbufgdsExtclk
	signal extclk: std_logic;

	---- myRoic
	signal cmtclk: std_logic;

	---- myTemp
	signal tempok: std_logic;

	---- myTkclksrc
	signal tkclk: std_logic;

	---- myWavegen
	signal avllenBufHostifToWavegen: std_logic_vector(10 downto 0);

	---- handshake
	-- myHostif to myCmdinv
	signal reqBufHostifToCmdinv: std_logic;
	signal ackBufHostifToCmdinv: std_logic;
	signal dneBufHostifToCmdinv: std_logic;

	-- myHostif to myCmdret
	signal reqBufCmdretToHostif: std_logic;
	signal ackBufCmdretToHostif: std_logic;
	signal dneBufCmdretToHostif: std_logic;

	-- myHostif to myAcq
	signal reqBufAcqToHostif: std_logic;
	signal ackBufAcqToHostif: std_logic;
	signal dneBufAcqToHostif: std_logic;

	-- myHostif to myWavegen
	signal reqBufHostifToWavegen: std_logic;
	signal ackBufHostifToWavegen: std_logic;
	signal dneBufHostifToWavegen: std_logic;

	---- other
	signal reqReset: std_logic := '0';

	signal dCmdbus: std_logic_vector(7 downto 0) := x"00";
	signal rdyCmdbus: std_logic_vector(23 downto 0) := x"000000";
	signal reqCmdbus: std_logic_vector(23 downto 0) := x"000000";
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myAcq : Acq
		generic map (
			fMclk => fMclk -- in kHz
		)
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusAcqToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwIcm2AckCmdbusAcqToCmdret),

			reqCmdbusToRoic => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusAcqToRoic),
			wrCmdbusToRoic => ackCmdbus(ixVSigIdhwIcm2AckCmdbusAcqToRoic),

			reqCmdbusToTkclksrc => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusAcqToTkclksrc),
			wrCmdbusToTkclksrc => ackCmdbus(ixVSigIdhwIcm2AckCmdbusAcqToTkclksrc),

			reqCmdbusToVmon => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusAcqToVmon),
			wrCmdbusToVmon => ackCmdbus(ixVSigIdhwIcm2AckCmdbusAcqToVmon),

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusCmdinvToAcq),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToAcq),

			rdyCmdbusFromTkclksrc => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusTkclksrcToAcq),
			rdCmdbusFromTkclksrc => ackCmdbus(ixVSigIdhwIcm2AckCmdbusTkclksrcToAcq),

			rdyCmdbusFromVmon => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusVmonToAcq),
			rdCmdbusFromVmon => ackCmdbus(ixVSigIdhwIcm2AckCmdbusVmonToAcq),

			reqBufToHostif => reqBufAcqToHostif,
			ackBufToHostif => ackBufAcqToHostif,
			dneBufToHostif => dneBufAcqToHostif,

			avllenBufToHostif => avllenBufAcqToHostif,

			dBufToHostif => dBufAcqToHostif,
			strbDBufToHostif => strbDBufAcqToHostif,

			cmtclk => cmtclk,
			tempok => tempok,

			prep => acqprep,
			rng => acqrng,

			strbPixstep => strbPixstep,

			nss => s_mosi,
			sclk => s_sclk,
			mosi => s_ncs,
			miso => s_miso
		);

	myBufgClkCmdbus : BUFG
		port map (
			I => clkCmdbus,
			O => clkCmdbus_sig
		);

	myBufgMclk : BUFG
		port map (
			I => mclk,
			O => mclk_sig
		);

	myCmdbus : Cmdbus
		generic map (
			fMclk => fMclk,
			fClk => 12500
		)
		port map (
			reset => reset,
			mclk => mclk_sig,
			clk => clkCmdbus,

			rdy => rdyCmdbus,

			req => reqCmdbus,
			ack => ackCmdbus
		);

	myCmdinv : Cmdinv
		port map (
			reset => reset,
			mclk => mclk_sig,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			reqCmdbusToAcq => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusCmdinvToAcq),
			wrCmdbusToAcq => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToAcq),

			reqCmdbusToFan => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusCmdinvToFan),
			wrCmdbusToFan => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToFan),

			reqCmdbusToRoic => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusCmdinvToRoic),
			wrCmdbusToRoic => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToRoic),

			reqCmdbusToState => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusCmdinvToState),
			wrCmdbusToState => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToState),

			reqCmdbusToSync => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusCmdinvToSync),
			wrCmdbusToSync => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToSync),

			reqCmdbusToTemp => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusCmdinvToTemp),
			wrCmdbusToTemp => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToTemp),

			reqCmdbusToTkclksrc => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusCmdinvToTkclksrc),
			wrCmdbusToTkclksrc => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToTkclksrc),

			reqCmdbusToVmon => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusCmdinvToVmon),
			wrCmdbusToVmon => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToVmon),

			reqCmdbusToVset => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusCmdinvToVset),
			wrCmdbusToVset => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToVset),

			reqCmdbusToWavegen => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusCmdinvToWavegen),
			wrCmdbusToWavegen => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToWavegen),

			reqBufFromHostif => reqBufHostifToCmdinv,
			ackBufFromHostif => ackBufHostifToCmdinv,
			dneBufFromHostif => dneBufHostifToCmdinv,

			avllenBufFromHostif => avllenBufHostifToCmdinv,

			dBufFromHostif => dBufHostifToCmdinv,
			strbDBufFromHostif => strbDBufHostifToCmdinv
		);

	myCmdret : Cmdret
		port map (
			reset => reset,
			mclk => mclk_sig,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromAcq => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusAcqToCmdret),
			rdCmdbusFromAcq => ackCmdbus(ixVSigIdhwIcm2AckCmdbusAcqToCmdret),

			rdyCmdbusFromFan => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusFanToCmdret),
			rdCmdbusFromFan => ackCmdbus(ixVSigIdhwIcm2AckCmdbusFanToCmdret),

			rdyCmdbusFromState => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusStateToCmdret),
			rdCmdbusFromState => ackCmdbus(ixVSigIdhwIcm2AckCmdbusStateToCmdret),

			rdyCmdbusFromTkclksrc => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusTkclksrcToCmdret),
			rdCmdbusFromTkclksrc => ackCmdbus(ixVSigIdhwIcm2AckCmdbusTkclksrcToCmdret),

			rdyCmdbusFromVmon => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusVmonToCmdret),
			rdCmdbusFromVmon => ackCmdbus(ixVSigIdhwIcm2AckCmdbusVmonToCmdret),

			reqBufToHostif => reqBufCmdretToHostif,
			ackBufToHostif => ackBufCmdretToHostif,
			dneBufToHostif => dneBufCmdretToHostif,

			avllenBufToHostif => avllenBufCmdretToHostif,

			dBufToHostif => dBufCmdretToHostif,
			strbDBufToHostif => strbDBufCmdretToHostif
		);

	myFan : Fan
		generic map (
			Ti => 2500 -- in tkclk periods
		)
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusCmdinvToFan),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToFan),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusFanToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwIcm2AckCmdbusFanToCmdret),

			rdyCmdbusFromTemp => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusTempToFan),
			rdCmdbusFromTemp => ackCmdbus(ixVSigIdhwIcm2AckCmdbusTempToFan),

			rng => fanrng,

			sens => f_sens,
			sw => f_sw
		);

	myHostif : Hostif
		port map (
			reset => reset,
			mclk => mclk_sig,
			fastclk => extclk,
			tkclk => tkclk,
			commok => commok,
			reqReset => reqReset,

			reqBufToCmdinv => reqBufHostifToCmdinv,
			ackBufToCmdinv => ackBufHostifToCmdinv,
			dneBufToCmdinv => dneBufHostifToCmdinv,

			avllenBufToCmdinv => avllenBufHostifToCmdinv,

			dBufToCmdinv => dBufHostifToCmdinv,
			strbDBufToCmdinv => strbDBufHostifToCmdinv,

			reqBufFromCmdret => reqBufCmdretToHostif,
			ackBufFromCmdret => ackBufCmdretToHostif,
			dneBufFromCmdret => dneBufCmdretToHostif,

			avllenBufFromCmdret => avllenBufCmdretToHostif,

			dBufFromCmdret => dBufCmdretToHostif,
			strbDBufFromCmdret => strbDBufCmdretToHostif,

			reqBufFromAcq => reqBufAcqToHostif,
			ackBufFromAcq => ackBufAcqToHostif,
			dneBufFromAcq => dneBufAcqToHostif,

			avllenBufFromAcq => avllenBufAcqToHostif,

			dBufFromAcq => dBufAcqToHostif,
			strbDBufFromAcq => strbDBufAcqToHostif,

			reqBufToWavegen => reqBufHostifToWavegen,
			ackBufToWavegen => ackBufHostifToWavegen,
			dneBufToWavegen => dneBufHostifToWavegen,

			avllenBufToWavegen => avllenBufHostifToWavegen,

			dBufToWavegen => dBufHostifToWavegen,
			strbDBufToWavegen => strbDBufHostifToWavegen,

			nss => m_nss,
			sclk => m_sclk,
			mosi => m_mosi,
			miso => m_miso
		);

	myIbufgdsExtclk : IBUFGDS
		port map (
			I => extclkp,
			IB => extclkn,
			O => extclk
		);

	myRoic : Roic
		generic map (
			fMclk => fMclk
		)
		port map (
			reset => reset,
			mclk => mclk_sig,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromAcq => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusAcqToRoic),
			rdCmdbusFromAcq => ackCmdbus(ixVSigIdhwIcm2AckCmdbusAcqToRoic),

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusCmdinvToRoic),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToRoic),

			cmtclk => cmtclk,
			acqrng => acqrng,
			strbPixstep => strbPixstep,
			cmt => q_cmt,
			decmt => q_decmt,

			rst => q_reset,
			sbs => q_sbs,

			nss => q_cs,
			sclk => q_sclk,
			mosi => q_mosi,
			miso => q_miso
		);

	myState : State
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusCmdinvToState),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToState),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusStateToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwIcm2AckCmdbusStateToCmdret),

			acqrng => acqrng,
			commok => commok,
			tempok => tempok,

			ledg => ledg,
			ledr => ledr
		);

	mySync : Sync
		port map (
			reset => reset,
			mclk => mclk_sig,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusCmdinvToSync),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToSync),

			cmtclk => cmtclk,
			sig => sig
		);

	myTemp : Temp
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusCmdinvToTemp),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToTemp),

			reqCmdbusToFan => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusTempToFan),
			wrCmdbusToFan => ackCmdbus(ixVSigIdhwIcm2AckCmdbusTempToFan),

			reqCmdbusToVmon => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusTempToVmon),
			wrCmdbusToVmon => ackCmdbus(ixVSigIdhwIcm2AckCmdbusTempToVmon),

			reqCmdbusToVset => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusTempToVset),
			wrCmdbusToVset => ackCmdbus(ixVSigIdhwIcm2AckCmdbusTempToVset),

			rdyCmdbusFromVmon => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusVmonToTemp),
			rdCmdbusFromVmon => ackCmdbus(ixVSigIdhwIcm2AckCmdbusVmonToTemp),

			acqprep => acqprep,
			fanrng => fanrng,
			ok => tempok
		);

	myTkclksrc : Tkclksrc
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromAcq => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusAcqToTkclksrc),
			rdCmdbusFromAcq => ackCmdbus(ixVSigIdhwIcm2AckCmdbusAcqToTkclksrc),

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusCmdinvToTkclksrc),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToTkclksrc),

			reqCmdbusToAcq => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusTkclksrcToAcq),
			wrCmdbusToAcq => ackCmdbus(ixVSigIdhwIcm2AckCmdbusTkclksrcToAcq),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusTkclksrcToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwIcm2AckCmdbusTkclksrcToCmdret)
		);

	myVmon : Vmon
		generic map (
			Tsmp => 100, -- in tkclk periods
			fMclk => fMclk
		)
		port map (
			reset => reset,
			mclk => mclk_sig,
			tkclk => tkclk,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromAcq => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusAcqToVmon),
			rdCmdbusFromAcq => ackCmdbus(ixVSigIdhwIcm2AckCmdbusAcqToVmon),

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusCmdinvToVmon),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToVmon),

			rdyCmdbusFromTemp => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusTempToVmon),
			rdCmdbusFromTemp => ackCmdbus(ixVSigIdhwIcm2AckCmdbusTempToVmon),

			reqCmdbusToAcq => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusVmonToAcq),
			wrCmdbusToAcq => ackCmdbus(ixVSigIdhwIcm2AckCmdbusVmonToAcq),

			reqCmdbusToCmdret => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusVmonToCmdret),
			wrCmdbusToCmdret => ackCmdbus(ixVSigIdhwIcm2AckCmdbusVmonToCmdret),

			reqCmdbusToTemp => reqCmdbus(ixVSigIdhwIcm2ReqCmdbusVmonToTemp),
			wrCmdbusToTemp => ackCmdbus(ixVSigIdhwIcm2AckCmdbusVmonToTemp),

			nss => a_ncs,
			sclk => a_sclk,
			mosi => a_mosi,
			miso => a_miso
		);

	myVset : Vset
		generic map (
			fMclk => fMclk
		)
		port map (
			reset => reset,
			mclk => mclk_sig,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusCmdinvToVset),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToVset),

			rdyCmdbusFromTemp => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusTempToVset),
			rdCmdbusFromTemp => ackCmdbus(ixVSigIdhwIcm2AckCmdbusTempToVset),

			nss => p_ncs,
			sclk => p_sclk,
			mosi => p_mosi,
			miso => p_miso
		);

	myWavegen : Wavegen
		generic map (
			fMclk => fMclk
		)
		port map (
			reset => reset,
			mclk => mclk_sig,

			clkCmdbus => clkCmdbus_sig,
			dCmdbus => dCmdbus,

			rdyCmdbusFromCmdinv => rdyCmdbus(ixVSigIdhwIcm2RdyCmdbusCmdinvToWavegen),
			rdCmdbusFromCmdinv => ackCmdbus(ixVSigIdhwIcm2AckCmdbusCmdinvToWavegen),

			reqBufFromHostif => reqBufHostifToWavegen,
			ackBufFromHostif => ackBufHostifToWavegen,
			dneBufFromHostif => dneBufHostifToWavegen,

			avllenBufFromHostif => avllenBufHostifToWavegen,

			dBufFromHostif => dBufHostifToWavegen,
			strbDBufFromHostif => strbDBufHostifToWavegen,

			acqrng => acqrng,
			cmtclk => cmtclk,

			nss => v_ncs,
			sclk => v_sclk,
			mosi => v_mosi,
			miso => v_miso
		);

	------------------------------------------------------------------------
	-- implementation: master clock (mclk)
	------------------------------------------------------------------------

	process (extclk)
		variable i: natural range 0 to (fExtclk/fMclk)/2;
	begin
		if falling_edge(extclk) then
			i := i + 1;
			if i=(fExtclk/fMclk)/2 then
				mclk <= not mclk;
				i := 0;
			end if;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: reset (rst)
	------------------------------------------------------------------------

	-- IP impl.rst.wiring --- BEGIN
	reset <= '0' when stateRst=stateRstReset else '1';
	-- IP impl.rst.wiring --- END

	process (reqReset, mclk_sig)
		variable i: natural range 0 to 16 := 0;
	begin
		if reqReset='1' then
			i := 0;
			stateRst <= stateRstReset;
		elsif rising_edge(mclk_sig) then
			if stateRst=stateRstReset then
				i := i + 1;
				if i=16 then
					i := 0;
					stateRst <= stateRstRun;
				end if;
			end if;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Top;

