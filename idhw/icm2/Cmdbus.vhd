-- file Cmdbus.vhd
-- Cmdbus cmdbus_v1_0 command bus controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Icm2.all;

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

				if reqrdy(ixVSigIdhwIcm2ReqCmdbusAcqToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusAcqToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusAcqToRoic)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusAcqToRoic => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusAcqToTkclksrc)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusAcqToTkclksrc => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusAcqToVmon)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusAcqToVmon => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusCmdinvToAcq)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusCmdinvToAcq => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusCmdinvToFan)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusCmdinvToFan => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusCmdinvToRoic)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusCmdinvToRoic => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusCmdinvToState)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusCmdinvToState => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusCmdinvToSync)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusCmdinvToSync => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusCmdinvToTemp)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusCmdinvToTemp => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusCmdinvToTkclksrc)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusCmdinvToTkclksrc => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusCmdinvToVmon)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusCmdinvToVmon => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusCmdinvToVset)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusCmdinvToVset => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusCmdinvToWavegen)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusCmdinvToWavegen => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusFanToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusFanToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusStateToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusStateToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusTempToFan)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusTempToFan => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusTempToVmon)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusTempToVmon => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusTempToVset)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusTempToVset => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusTkclksrcToAcq)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusTkclksrcToAcq => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusTkclksrcToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusTkclksrcToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusVmonToAcq)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusVmonToAcq => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusVmonToCmdret)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusVmonToCmdret => '1', others => '0');
				elsif reqrdy(ixVSigIdhwIcm2ReqCmdbusVmonToTemp)='1' then
					ack_sig_next <= (ixVSigIdhwIcm2ReqCmdbusVmonToTemp => '1', others => '0');
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

