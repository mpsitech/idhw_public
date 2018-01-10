-- file Lwiremu.vhd
-- Lwiremu controller implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Lwiremu is
	generic (
		fMclk: natural range 1 to 1000000 := 50000 -- in kHz
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		fastclk: in std_logic;
		tkclk: in std_logic;

		lw_clk_wrp: out std_logic;
		lw_snc_wrp: out std_logic;
		lw_d1_wrp: out std_logic;
		lw_d2_wrp: out std_logic;
		lw_extsnc_wrp: in std_logic;

		clkCmdbus: in std_logic;
		dCmdbus: in std_logic_vector(7 downto 0);

		rdyCmdbusFromCmdinv: out std_logic;
		rdCmdbusFromCmdinv: in std_logic;

		rowsqr_out: out std_logic_vector(19 downto 0);
		colsqr_out: out std_logic_vector(19 downto 0);
		rsqr_out: out std_logic_vector(19 downto 0)
	);
end Lwiremu;

architecture Lwiremu of Lwiremu is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Mult_v12_0_10by10_0to19 is
		port (
			clk: in std_logic;
			ce: in std_logic;
			sclr: in std_logic;
			a: in std_logic_vector(9 downto 0);
			b: in std_logic_vector(9 downto 0);
			p: out std_logic_vector(19 downto 0)
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- command execution (cmd)
	type stateCmd_t is (
		stateCmdInit,
		stateCmdEmpty,
		stateCmdRecvA, stateCmdRecvB, stateCmdRecvC, stateCmdRecvD,
		stateCmdInvSetTrig
	);
	signal stateCmd, stateCmd_next: stateCmd_t := stateCmdInit;

	-- inv: setTrig

	constant sizeCmdbuf: natural := 11;

	constant tixVCommandSetTrig: std_logic_vector(7 downto 0) := x"00";
	constant lenCmdbufInvSetTrig: natural := 11;
	constant ixCmdbufInvSetTrigExtNotInt: natural := 10;

	signal trigExtNotInt, trigExtNotInt_next: std_logic;

	type cmdbuf_t is array (0 to sizeCmdbuf-1) of std_logic_vector(7 downto 0);
	signal cmdbuf: cmdbuf_t;

	signal rdyCmdbusFromCmdinv_sig, rdyCmdbusFromCmdinv_sig_next: std_logic;

	-- IP sigs.cmd.cust --- INSERT

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpIdle,
		stateOpFrmstartA, stateOpFrmstartB, stateOpFrmstartC,
		stateOpValidA, stateOpValidB, stateOpValidC,
		stateOpPadrowA, stateOpPadrowB, stateOpPadrowC, stateOpPadrowD
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal col, col_next: std_logic_vector(9 downto 0);
	signal row, row_next: std_logic_vector(9 downto 0);
	signal rsqr: natural range 0 to 1048575;

	signal oddval: natural range 0 to 16383;
	signal evval: natural range 0 to 16383;
	signal pix, pix_next: natural range 0 to 16383;

	-- IP sigs.op.cust --- INSERT

	---- output signal generation (out)
	type stateOut_t is (
		stateOutStart,
		stateOutRun
	);
	signal stateOut, stateOut_next: stateOut_t := stateOutStart;

	signal snc, snc_next: std_logic;
	signal d1, d1_next: std_logic;
	signal d2, d2_next: std_logic;

	-- IP sigs.out.cust --- INSERT

	---- frame clock (tfrm)
	type stateTfrm_t is (
		stateTfrmInit,
		stateTfrmReady,
		stateTfrmRunA, stateTfrmRunB, stateTfrmRunC
	);
	signal stateTfrm, stateTfrm_next: stateTfrm_t := stateTfrmInit;

	signal strbTfrm, strbTfrm_next: std_logic;

	-- IP sigs.tfrm.cust --- INSERT

	---- myColsqrmult
	signal colsqr: std_logic_vector(19 downto 0);

	---- myRowsqrmult
	signal rowsqr: std_logic_vector(19 downto 0);

	---- handshake
	-- (many) to out
	signal reqOpToOutFrmstart: std_logic;
	signal reqOpToOutValid: std_logic;
	signal ackOpToOut, ackOpToOut_next: std_logic;

	---- other
	-- IP sigs.oth.cust --- IBEGIN
	constant Tfrm: natural := 250; -- 40Hz
	-- IP sigs.oth.cust --- IEND

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myColsqrmult : Mult_v12_0_10by10_0to19
		port map (
			clk => mclk,
			ce => '1',
			sclr => '0',
			a => col,
			b => col,
			p => colsqr
		);

	myRowsqrmult : Mult_v12_0_10by10_0to19
		port map (
			clk => mclk,
			ce => '1',
			sclr => '0',
			a => row,
			b => row,
			p => rowsqr
		);

	------------------------------------------------------------------------
	-- implementation: command execution (cmd)
	------------------------------------------------------------------------

	-- IP impl.cmd.wiring --- BEGIN
	rdyCmdbusFromCmdinv <= rdyCmdbusFromCmdinv_sig;
	-- IP impl.cmd.wiring --- END

	-- IP impl.cmd.rising --- BEGIN
	process (reset, mclk, stateCmd)
		-- IP impl.cmd.rising.vars --- BEGIN
		variable lenCmdbuf: natural range 0 to sizeCmdbuf := 0;
		-- IP impl.cmd.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.cmd.rising.asyncrst --- BEGIN
			stateCmd_next <= stateCmdInit;
			trigExtNotInt_next <= '0';
			rdyCmdbusFromCmdinv_sig_next <= '1';
			-- IP impl.cmd.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateCmd=stateCmdInit then
				-- IP impl.cmd.rising.syncrst --- BEGIN
				trigExtNotInt_next <= '0';
				rdyCmdbusFromCmdinv_sig_next <= '1';

				lenCmdbuf := 0;
				-- IP impl.cmd.rising.syncrst --- END

				stateCmd_next <= stateCmdEmpty;

			elsif stateCmd=stateCmdEmpty then
				if (rdCmdbusFromCmdinv='1' and clkCmdbus='1') then
					rdyCmdbusFromCmdinv_sig_next <= '0';

					stateCmd_next <= stateCmdRecvA;
				end if;

			elsif stateCmd=stateCmdRecvA then
				if clkCmdbus='0' then
					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvB then
				if clkCmdbus='1' then
					if rdCmdbusFromCmdinv='0' then
						stateCmd_next <= stateCmdRecvD;

					else
						cmdbuf(lenCmdbuf) <= dCmdbus;

						stateCmd_next <= stateCmdRecvC;
					end if;
				end if;

			elsif stateCmd=stateCmdRecvC then
				if clkCmdbus='0' then
					lenCmdbuf := lenCmdbuf + 1;

					stateCmd_next <= stateCmdRecvB;
				end if;

			elsif stateCmd=stateCmdRecvD then
				if (cmdbuf(ixCmdbufAction)=tixDbeVActionInv and cmdbuf(ixCmdbufInvCommand)=tixVCommandSetTrig and lenCmdbuf=lenCmdbufInvSetTrig) then
					stateCmd_next <= stateCmdInvSetTrig;

				else
					stateCmd_next <= stateCmdInit;
				end if;

			elsif stateCmd=stateCmdInvSetTrig then
				-- IP impl.cmd.rising.invSetTrig --- IBEGIN
				if cmdbuf(ixCmdbufInvSetTrigExtNotInt)=fls8 then
					trigExtNotInt_next <= '0';
				else
					trigExtNotInt_next <= '1';
				end if;
				-- IP impl.cmd.rising.invSetTrig --- IEND

				stateCmd_next <= stateCmdInit;
			end if;
		end if;
	end process;
	-- IP impl.cmd.rising --- END

	-- IP impl.cmd.falling --- BEGIN
	process (mclk)
	begin
		if falling_edge(mclk) then
			stateCmd <= stateCmd_next;
			trigExtNotInt <= trigExtNotInt_next;
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
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	reqOpToOutFrmstart <= '0' when (stateOp=stateOpFrmstartB or stateOp=stateOpFrmstartC) else '1';
	reqOpToOutValid <= '0' when (stateOp=stateOpValidB or stateOp=stateOpValidC) else '1';
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		constant w: natural := 640;
		constant h: natural := 512;

		constant rsqr0: natural := (h*h)/4 + (w*w)/4; -- used in calculation of rsqr
		
		constant r0sqrmin: natural := (h/3-5) * (h/3-5);
		constant r0sqrmax: natural := (h/3+5) * (h/3+5);

		constant lhmin: natural := h/2-5;
		constant lhmax: natural := h/2+5;

		constant lvmin: natural := w/2-5;
		constant lvmax: natural := w/2+5;

		variable barmin: natural range 0 to h;
		variable barmax: natural range 0 to h;
		variable barup: std_logic;

		constant incr: natural := (16384/w);

		variable x, y, z: std_logic_vector(19 downto 0);

		constant imax: natural := ((32*fMclk)/10000);
		variable i: natural range 0 to imax; -- counter to 3.2µs
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- BEGIN
			stateOp_next <= stateOpInit;
			col_next <= "0000000000";
			row_next <= "0000000000";
			pix_next <= 0;
			-- IP impl.op.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateOp=stateOpInit then
				stateOp_next <= stateOpIdle;

			elsif stateOp=stateOpIdle then
				if ((trigExtNotInt='0' and strbTfrm='1') or (trigExtNotInt='1' and lw_extsnc_wrp='1')) then
					if ackOpToOut='0' then
						stateOp_next <= stateOpFrmstartB;

					else
						stateOp_next <= stateOpFrmstartA;
					end if;
				end if;

			elsif stateOp=stateOpFrmstartA then
				if ackOpToOut='0' then
					stateOp_next <= stateOpFrmstartB;
				end if;

			elsif stateOp=stateOpFrmstartB then
				if ackOpToOut='1' then
					stateOp_next <= stateOpFrmstartC;
				end if;

			elsif stateOp=stateOpFrmstartC then
				if ackOpToOut='0' then
					stateOp_next <= stateOpValidA;
				end if;

			elsif stateOp=stateOpValidA then
				-- IP impl.op.rising.validA --- IBEGIN
				-- calculation of pixel value

				-- full rsqr calculation:
				-- x := "0" & row & "000000000"; -- row*512 = row*h
				-- y := "0" & col & "000000000"; -- col*512 = row*(w-128)
				-- z := "000" & col & "0000000"; -- col*128
				-- rsqr <= rsqr0 + to_integer(unsigned(rowsqr)) + to_integer(unsigned(colsqr)) - to_integer(unsigned(x)) - to_integer(unsigned(y)) - to_integer(unsigned(z));

				if (row="0100000000" and col="0101000000") then
					rowsqr_out <= rowsqr;
					colsqr_out <= colsqr;
					rsqr_out <= std_logic_vector(to_unsigned(rsqr, 20));
				end if;

				if ((to_integer(unsigned(row))>=lhmin and to_integer(unsigned(row))<lhmax and to_integer(unsigned(col))>=(w/2)) or (to_integer(unsigned(col))>=lvmin and to_integer(unsigned(col))<lvmax and to_integer(unsigned(row))>=(h/2))) then
					pix_next <= 0;
				elsif ((rsqr>=r0sqrmin and rsqr<=r0sqrmax) or (to_integer(unsigned(row))>=barmin and to_integer(unsigned(row))<barmax)) then
					pix_next <= 16383;
				elsif row(4)='1' then
					pix_next <= oddval;
				else
					pix_next <= evval;
				end if;
				-- IP impl.op.rising.validA --- IEND

				stateOp_next <= stateOpValidB;

			elsif stateOp=stateOpValidB then
				if ackOpToOut='1' then
					rsqr <= rsqr0 + to_integer(unsigned(rowsqr)) + to_integer(unsigned(colsqr)); -- IP impl.op.rising.validB --- ILINE

					stateOp_next <= stateOpValidC;
				end if;

			elsif stateOp=stateOpValidC then
				if ackOpToOut='0' then
					-- IP impl.op.rising.validC.calcrsqr --- IBEGIN
					x := "0" & row & "000000000";
					y := "0" & col & "000000000";
					z := "000" & col & "0000000";
					rsqr <= rsqr - to_integer(unsigned(x)) - to_integer(unsigned(y)) - to_integer(unsigned(z));
					-- IP impl.op.rising.validC.calcrsqr --- IEND

					if col=std_logic_vector(to_unsigned(w-1, 10)) then
						-- IP impl.op.rising.validC.eol --- IBEGIN
						col_next <= (others => '0');
						-- colsqr <= col*col; (two cycles delay)

						oddval <= 16383;
						evval <= 0;
						-- IP impl.op.rising.validC.eol --- IEND

						if row=std_logic_vector(to_unsigned(h-1, 10)) then
							-- IP impl.op.rising.validC.eof --- IBEGIN
							row_next <= (others => '0');

							if barup='1' then
								barmin := barmin - 1;
								barmax := barmax - 1;
								if barmin=0 then
									barup := '0';
								end if;
							else
								barmin := barmin + 1;
								barmax := barmax + 1;
								if barmax=h then
									barup := '1';
								end if;
							end if;
							-- IP impl.op.rising.validC.eof --- IEND

							stateOp_next <= stateOpIdle;

						else
							-- IP impl.op.rising.validC.incrow --- IBEGIN
							row_next <= std_logic_vector(unsigned(row) + 1);
							-- rowsqr <= row*row; (two cycles delay)

							i := 0;
							-- IP impl.op.rising.validC.incrow --- IEND

							stateOp_next <= stateOpPadrowA;
						end if;

					else
						-- IP impl.op.rising.validC.inccol --- IBEGIN
						col_next <= std_logic_vector(unsigned(col) + 1);
						-- colsqr <= col*col; (two cycles delay)

						oddval <= oddval - incr;
						evval <= evval + incr;
						-- IP impl.op.rising.validC.inccol --- IEND

						stateOp_next <= stateOpValidA;
					end if;
				end if;

			elsif stateOp=stateOpPadrowA then
				i := i + 1; -- IP impl.op.rising.padrowA.ext --- ILINE

				if i=imax then
					if ackOpToOut='0' then
						stateOp_next <= stateOpPadrowC;

					else
						stateOp_next <= stateOpPadrowB;
					end if;
				end if;

			elsif stateOp=stateOpPadrowB then
				if ackOpToOut='0' then
					stateOp_next <= stateOpPadrowC;
				end if;

			elsif stateOp=stateOpPadrowC then
				if ackOpToOut='1' then
					stateOp_next <= stateOpPadrowD;
				end if;

			elsif stateOp=stateOpPadrowD then
				if ackOpToOut='0' then
					stateOp_next <= stateOpValidA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.op.rising --- END

	-- IP impl.op.falling --- BEGIN
	process (mclk)
		-- IP impl.op.falling.vars --- BEGIN
		-- IP impl.op.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			col <= col_next;
			row <= row_next;
			pix <= pix_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: output signal generation (out)
	------------------------------------------------------------------------

	-- IP impl.out.wiring --- BEGIN
	lw_snc_wrp <= snc;
	lw_d1_wrp <= d1;
	lw_d2_wrp <= d2;
	-- IP impl.out.wiring --- END

	-- IP impl.out.rising --- BEGIN
	process (reset, fastclk, stateOut)
		-- IP impl.out.rising.vars --- RBEGIN
		constant tknIdle: std_logic_vector(6 downto 0) := "1100000";
		constant tknFrmstart: std_logic_vector(6 downto 0) := "1110000";
		constant tknValid: std_logic_vector(6 downto 0) := "1100100";
		variable tkn: std_logic_vector(6 downto 0);

		variable data1, data2: std_logic_vector(6 downto 0);

		variable i: natural range 0 to 6; -- bit counter
		variable x: std_logic_vector(13 downto 0);
		-- IP impl.out.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.out.rising.asyncrst --- BEGIN
			stateOut_next <= stateOutStart;
			snc_next <= '0';
			d1_next <= '0';
			d2_next <= '0';
			ackOpToOut_next <= '0';
			-- IP impl.out.rising.asyncrst --- END

		elsif rising_edge(fastclk) then
			if stateOut=stateOutStart then
				-- IP impl.out.rising.start --- IBEGIN
				if reqOpToOutFrmstart='1' then
					tkn := tknFrmstart;
					data1 := "0000000";
					data2 := "0000000";

				elsif reqOpToOutValid='1' then
					tkn := tknValid;
					x := std_logic_vector(to_unsigned(pix, 14));
					data1 := x(6 downto 0);
					data2 := x(13 downto 7);

				else
					tkn := tknIdle;
					data1 := "0000000";
					data2 := "0000000";
				end if;

				i := 6;

				snc_next <= tkn(i);
				d1_next <= data1(i);
				d2_next <= data2(i);

				ackOpToOut_next <= '0';
				-- IP impl.out.rising.start --- IEND

				stateOut_next <= stateOutRun;

			elsif stateOut=stateOutRun then
				-- IP impl.out.rising.run.ext --- IBEGIN
				i := i - 1;

				snc_next <= tkn(i);
				d1_next <= data1(i);
				d2_next <= data2(i);
				-- IP impl.out.rising.run.ext --- IEND

				if i=0 then
					stateOut_next <= stateOutStart;

				elsif i=1 then
					ackOpToOut_next <= '1'; -- IP impl.out.rising.run.ack --- ILINE

					stateOut_next <= stateOutRun;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.out.rising --- END

	-- IP impl.out.falling --- BEGIN
	process (fastclk)
		-- IP impl.out.falling.vars --- BEGIN
		-- IP impl.out.falling.vars --- END
	begin
		if falling_edge(fastclk) then
			stateOut <= stateOut_next;
			snc <= snc_next;
			d1 <= d1_next;
			d2 <= d2_next;
			ackOpToOut <= ackOpToOut_next;
		end if;
	end process;
	-- IP impl.out.falling --- END

	------------------------------------------------------------------------
	-- implementation: frame clock (tfrm)
	------------------------------------------------------------------------

	-- IP impl.tfrm.wiring --- BEGIN
	strbTfrm <= '0' when (stateTfrm=stateTfrmRunA and tkclk='1') else '1';
	-- IP impl.tfrm.wiring --- END

	-- IP impl.tfrm.rising --- BEGIN
	process (reset, mclk, stateTfrm)
		-- IP impl.tfrm.rising.vars --- RBEGIN
		variable i: natural range 0 to Tfrm; -- frame rate counter
		-- IP impl.tfrm.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.tfrm.rising.asyncrst --- BEGIN
			stateTfrm_next <= stateTfrmInit;
			strbTfrm_next <= '0';
			-- IP impl.tfrm.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateTfrm=stateTfrmInit then
				stateTfrm_next <= stateTfrmReady;

			elsif stateTfrm=stateTfrmReady then
				if tkclk='0' then
					i := 0; -- IP impl.tfrm.rising.ready --- ILINE

					stateTfrm_next <= stateTfrmRunA;
				end if;

			elsif stateTfrm=stateTfrmRunA then
				if tkclk='1' then
					stateTfrm_next <= stateTfrmRunC;
				end if;

			elsif stateTfrm=stateTfrmRunB then
				if tkclk='1' then
					stateTfrm_next <= stateTfrmRunC;
				end if;

			elsif stateTfrm=stateTfrmRunC then
				if tkclk='0' then
					i := i + 1; -- IP impl.tfrm.rising.runC.inc --- ILINE

					if i=Tfrm then
						i := 0; -- IP impl.tfrm.rising.runC.init --- ILINE

						stateTfrm_next <= stateTfrmRunA;

					else
						stateTfrm_next <= stateTfrmRunB;
					end if;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.tfrm.rising --- END

	-- IP impl.tfrm.falling --- BEGIN
	process (mclk)
		-- IP impl.tfrm.falling.vars --- BEGIN
		-- IP impl.tfrm.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateTfrm <= stateTfrm_next;
			strbTfrm <= strbTfrm_next;
		end if;
	end process;
	-- IP impl.tfrm.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- IBEGIN
	lw_clk_wrp <= not fastclk;
	-- IP impl.oth.cust --- IEND

end Lwiremu;


