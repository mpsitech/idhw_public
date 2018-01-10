-- file Cmdbus.vhd
-- Cmdbus cmdbus_v1_0 command bus controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Cmdbus is
	generic (
		fMclk: natural range 1 to 1000000;
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
end Cmdbus;

architecture Cmdbus of Cmdbus is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- arbiter operation (arb)

	signal ack_sig, ack_sig_next: std_logic_vector(23 downto 0);

	-- IP sigs.arb.cust --- INSERT

	---- clock (clk)

	signal clk_sig, clk_sig_next: std_logic;

	-- IP sigs.clk.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- implementation: arbiter operation (arb)
	------------------------------------------------------------------------

	-- IP impl.arb.wiring --- BEGIN
	ack <= ack_sig;
	-- IP impl.arb.wiring --- END

	process (reset, clk_sig)
		variable reqrdy: std_logic_vector(23 downto 0);

	begin
		if reset='1' then
			ack_sig_next <= (others => '0');

		elsif rising_edge(clk_sig) then
			if ack_sig=x"000000" then
				-- start new transfer
				reqrdy := req and rdy;

				if reqrdy(ixVSigIdhwBss3ReqCmdbusAluaToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusAluaToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusAlubToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusAlubToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToAlua)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToAlua => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToAlub)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToAlub => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToDcxif)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToDcxif => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToLwiracq)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToLwiracq => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToLwiremu)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToLwiremu => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToPhiif)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToPhiif => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToPmmu)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToPmmu => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToQcdif)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToQcdif => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToThetaif)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToThetaif => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToTkclksrc)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToTkclksrc => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusCmdinvToTrigger)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusCmdinvToTrigger => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusDcxifToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusDcxifToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusLwiracqToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusLwiracqToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusLwiracqToPmmu)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusLwiracqToPmmu => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusLwiracqToTkclksrc)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusLwiracqToTkclksrc => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusPhiifToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusPhiifToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusPmmuToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusPmmuToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusPmmuToLwiracq)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusPmmuToLwiracq => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusQcdifToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusQcdifToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusThetaifToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusThetaifToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusTkclksrcToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusTkclksrcToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwBss3ReqCmdbusTkclksrcToLwiracq)='1' then
					ack_sig_next <= (ixVSigIdhwBss3ReqCmdbusTkclksrcToLwiracq => '1', others => '0');
				else
					ack_sig_next <= (others => '0');
				end if;

			elsif ((ack_sig and req)=x"000000") then
				-- end transfer currently active
				ack_sig_next <= (others => '0');
			end if;
		end if;
	end process;

	-- IP impl.arb.falling --- BEGIN
	process (clk_sig)
		-- IP impl.arb.falling.vars --- BEGIN
		-- IP impl.arb.falling.vars --- END
	begin
		if falling_edge(clk_sig) then
			ack_sig <= ack_sig_next;
		end if;
	end process;
	-- IP impl.arb.falling --- END

	------------------------------------------------------------------------
	-- implementation: clock (clk)
	------------------------------------------------------------------------

	clk <= clk_sig;

	process (reset, mclk)
		constant imax: natural := ((fMclk/fClk)/2);
		variable i: natural range 0 to imax;

	begin
		if reset='1' then
			clk_sig_next <= '0';
			i := 0;

		elsif rising_edge(mclk) then
			i := i + 1;

			if i=imax then
				i := 0;

				clk_sig_next <= not clk_sig;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			clk_sig <= clk_sig_next;
		end if;
	end process;

end Cmdbus;

