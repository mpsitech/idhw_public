-- file Cmdbus.vhd
-- Cmdbus cmdbus_v1_0 command bus controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

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

				if reqrdy(ixVSigIdhwZedbReqCmdbusAluaToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusAluaToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusAlubToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusAlubToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToAlua)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToAlua => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToAlub)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToAlub => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToDcxif)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToDcxif => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToLwiracq)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToLwiracq => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToLwiremu)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToLwiremu => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToPhiif)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToPhiif => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToPmmu)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToPmmu => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToQcdif)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToQcdif => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToThetaif)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToThetaif => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToTkclksrc)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToTkclksrc => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusCmdinvToTrigger)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusCmdinvToTrigger => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusDcxifToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusDcxifToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusLwiracqToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusLwiracqToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusLwiracqToPmmu)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusLwiracqToPmmu => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusLwiracqToTkclksrc)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusLwiracqToTkclksrc => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusPhiifToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusPhiifToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusPmmuToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusPmmuToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusPmmuToLwiracq)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusPmmuToLwiracq => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusQcdifToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusQcdifToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusThetaifToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusThetaifToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusTkclksrcToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusTkclksrcToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwZedbReqCmdbusTkclksrcToLwiracq)='1' then
					ack_sig_next <= (ixVSigIdhwZedbReqCmdbusTkclksrcToLwiracq => '1', others => '0');
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

