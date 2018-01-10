-- file Bss3.vhd
-- Digilent Basys3 global constants and types
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Dbecore is
	constant fls8: std_logic_vector(7 downto 0) := x"AA";
	constant fls16: std_logic_vector(15 downto 0) := x"AAAA";
	constant fls32: std_logic_vector(31 downto 0) := x"AAAAAAAA";

	constant tru8: std_logic_vector(7 downto 0) := x"55";
	constant tru16: std_logic_vector(15 downto 0) := x"5555";
	constant tru32: std_logic_vector(31 downto 0) := x"55555555";

	constant tixDbeVActionInv: std_logic_vector(7 downto 0) := x"00";
	constant tixDbeVActionRev: std_logic_vector(7 downto 0) := x"01";
	constant tixDbeVActionRet: std_logic_vector(7 downto 0) := x"80";
	constant tixDbeVActionNewret: std_logic_vector(7 downto 0) := x"81";
	constant tixDbeVActionErr: std_logic_vector(7 downto 0) := x"F0";
	constant tixDbeVActionRteerr: std_logic_vector(7 downto 0) := x"F1";
	constant tixDbeVActionCreferr: std_logic_vector(7 downto 0) := x"F2";
	constant tixDbeVActionFwderr: std_logic_vector(7 downto 0) := x"F3";
	constant tixDbeVActionCmderr: std_logic_vector(7 downto 0) := x"F4";
	constant tixDbeVActionToerr: std_logic_vector(7 downto 0) := x"F5";
	constant tixDbeVActionRsterr: std_logic_vector(7 downto 0) := x"F6";

	constant tixDbeVXferVoid: std_logic_vector(7 downto 0) := x"00";
	constant tixDbeVXferTkn: std_logic_vector(7 downto 0) := x"01";
	constant tixDbeVXferTknste: std_logic_vector(7 downto 0) := x"02";
	constant tixDbeVXferAvlbx: std_logic_vector(7 downto 0) := x"03";
	constant tixDbeVXferReqbx: std_logic_vector(7 downto 0) := x"04";
	constant tixDbeVXferArbbx: std_logic_vector(7 downto 0) := x"05";
	constant tixDbeVXferAvllen: std_logic_vector(7 downto 0) := x"06";
	constant tixDbeVXferReqlen: std_logic_vector(7 downto 0) := x"07";
	constant tixDbeVXferArblen: std_logic_vector(7 downto 0) := x"08";
	constant tixDbeVXferRd: std_logic_vector(7 downto 0) := x"09";
	constant tixDbeVXferRdack: std_logic_vector(7 downto 0) := x"0A";
	constant tixDbeVXferWr: std_logic_vector(7 downto 0) := x"0B";
	constant tixDbeVXferWrack: std_logic_vector(7 downto 0) := x"0C";

	constant ixCmdbufRoute: natural := 0;
	constant ixCmdbufAction: natural := 4;
	constant ixCmdbufCref: natural := 5;
	constant ixCmdbufInvCommand: natural := 9;
	constant ixCmdbufRevCommand: natural := 9;
	constant ixCmdbufErrError: natural := 9;
	constant ixCmdbufCreferrCref: natural := 9;
	constant ixCmdbufFwderrRoute: natural := 9;

	constant lenCmdbufRev: natural := 10;
	constant lenCmdbufCreferr: natural := 13;
	constant lenCmdbufFwderr: natural := 13;
end Dbecore;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Idhw is
	constant tixWIdhwBss3BufferCmdretToHostif: std_logic_vector(7 downto 0) := x"01";
	constant tixWIdhwBss3BufferHostifToCmdinv: std_logic_vector(7 downto 0) := x"02";
	constant tixWIdhwBss3BufferPmmuToHostif: std_logic_vector(7 downto 0) := x"04";
	constant tixWIdhwBss3BufferDcxifToHostif: std_logic_vector(7 downto 0) := x"08";
	constant tixWIdhwBss3BufferHostifToDcxif: std_logic_vector(7 downto 0) := x"10";
	constant tixWIdhwBss3BufferHostifToQcdif: std_logic_vector(7 downto 0) := x"20";
	constant tixWIdhwBss3BufferQcdifToHostif: std_logic_vector(7 downto 0) := x"40";

	constant tixWIdhwDcx3BufferCmdretToHostif: std_logic_vector(7 downto 0) := x"01";
	constant tixWIdhwDcx3BufferHostifToCmdinv: std_logic_vector(7 downto 0) := x"02";
	constant tixWIdhwDcx3BufferPmmuToHostif: std_logic_vector(7 downto 0) := x"04";
	constant tixWIdhwDcx3BufferHostifToQcdif: std_logic_vector(7 downto 0) := x"08";
	constant tixWIdhwDcx3BufferQcdifToHostif: std_logic_vector(7 downto 0) := x"10";

	constant tixWIdhwIcm2BufferCmdretToHostif: std_logic_vector(7 downto 0) := x"01";
	constant tixWIdhwIcm2BufferHostifToCmdinv: std_logic_vector(7 downto 0) := x"02";
	constant tixWIdhwIcm2BufferAcqToHostif: std_logic_vector(7 downto 0) := x"04";
	constant tixWIdhwIcm2BufferHostifToWavegen: std_logic_vector(7 downto 0) := x"08";
end Idhw;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Bss3 is
	constant tixVIdhwBss3ControllerCmdinv: std_logic_vector(7 downto 0) := x"01";
	constant tixVIdhwBss3ControllerCmdret: std_logic_vector(7 downto 0) := x"02";
	constant tixVIdhwBss3ControllerAlua: std_logic_vector(7 downto 0) := x"03";
	constant tixVIdhwBss3ControllerAlub: std_logic_vector(7 downto 0) := x"04";
	constant tixVIdhwBss3ControllerDcxif: std_logic_vector(7 downto 0) := x"05";
	constant tixVIdhwBss3ControllerLwiracq: std_logic_vector(7 downto 0) := x"06";
	constant tixVIdhwBss3ControllerLwiremu: std_logic_vector(7 downto 0) := x"07";
	constant tixVIdhwBss3ControllerPhiif: std_logic_vector(7 downto 0) := x"08";
	constant tixVIdhwBss3ControllerPmmu: std_logic_vector(7 downto 0) := x"09";
	constant tixVIdhwBss3ControllerQcdif: std_logic_vector(7 downto 0) := x"0A";
	constant tixVIdhwBss3ControllerThetaif: std_logic_vector(7 downto 0) := x"0B";
	constant tixVIdhwBss3ControllerTkclksrc: std_logic_vector(7 downto 0) := x"0C";
	constant tixVIdhwBss3ControllerTrigger: std_logic_vector(7 downto 0) := x"0D";

	constant ixVSigIdhwBss3AckCmdbusAluaToCmdret: natural := 0;
	constant ixVSigIdhwBss3AckCmdbusAlubToCmdret: natural := 1;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToAlua: natural := 2;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToAlub: natural := 3;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToDcxif: natural := 4;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToLwiracq: natural := 5;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToLwiremu: natural := 6;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToPhiif: natural := 7;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToPmmu: natural := 8;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToQcdif: natural := 9;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToThetaif: natural := 10;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToTkclksrc: natural := 11;
	constant ixVSigIdhwBss3AckCmdbusCmdinvToTrigger: natural := 12;
	constant ixVSigIdhwBss3AckCmdbusDcxifToCmdret: natural := 13;
	constant ixVSigIdhwBss3AckCmdbusLwiracqToCmdret: natural := 14;
	constant ixVSigIdhwBss3AckCmdbusLwiracqToPmmu: natural := 15;
	constant ixVSigIdhwBss3AckCmdbusLwiracqToTkclksrc: natural := 16;
	constant ixVSigIdhwBss3AckCmdbusPhiifToCmdret: natural := 17;
	constant ixVSigIdhwBss3AckCmdbusPmmuToCmdret: natural := 18;
	constant ixVSigIdhwBss3AckCmdbusPmmuToLwiracq: natural := 19;
	constant ixVSigIdhwBss3AckCmdbusQcdifToCmdret: natural := 20;
	constant ixVSigIdhwBss3AckCmdbusThetaifToCmdret: natural := 21;
	constant ixVSigIdhwBss3AckCmdbusTkclksrcToCmdret: natural := 22;
	constant ixVSigIdhwBss3AckCmdbusTkclksrcToLwiracq: natural := 23;

	constant ixVSigIdhwBss3RdyCmdbusAluaToCmdret: natural := 0;
	constant ixVSigIdhwBss3RdyCmdbusAlubToCmdret: natural := 1;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToAlua: natural := 2;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToAlub: natural := 3;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToDcxif: natural := 4;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToLwiracq: natural := 5;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToLwiremu: natural := 6;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToPhiif: natural := 7;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToPmmu: natural := 8;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToQcdif: natural := 9;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToThetaif: natural := 10;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToTkclksrc: natural := 11;
	constant ixVSigIdhwBss3RdyCmdbusCmdinvToTrigger: natural := 12;
	constant ixVSigIdhwBss3RdyCmdbusDcxifToCmdret: natural := 13;
	constant ixVSigIdhwBss3RdyCmdbusLwiracqToCmdret: natural := 14;
	constant ixVSigIdhwBss3RdyCmdbusLwiracqToPmmu: natural := 15;
	constant ixVSigIdhwBss3RdyCmdbusLwiracqToTkclksrc: natural := 16;
	constant ixVSigIdhwBss3RdyCmdbusPhiifToCmdret: natural := 17;
	constant ixVSigIdhwBss3RdyCmdbusPmmuToCmdret: natural := 18;
	constant ixVSigIdhwBss3RdyCmdbusPmmuToLwiracq: natural := 19;
	constant ixVSigIdhwBss3RdyCmdbusQcdifToCmdret: natural := 20;
	constant ixVSigIdhwBss3RdyCmdbusThetaifToCmdret: natural := 21;
	constant ixVSigIdhwBss3RdyCmdbusTkclksrcToCmdret: natural := 22;
	constant ixVSigIdhwBss3RdyCmdbusTkclksrcToLwiracq: natural := 23;

	constant ixVSigIdhwBss3ReqCmdbusAluaToCmdret: natural := 0;
	constant ixVSigIdhwBss3ReqCmdbusAlubToCmdret: natural := 1;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToAlua: natural := 2;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToAlub: natural := 3;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToDcxif: natural := 4;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToLwiracq: natural := 5;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToLwiremu: natural := 6;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToPhiif: natural := 7;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToPmmu: natural := 8;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToQcdif: natural := 9;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToThetaif: natural := 10;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToTkclksrc: natural := 11;
	constant ixVSigIdhwBss3ReqCmdbusCmdinvToTrigger: natural := 12;
	constant ixVSigIdhwBss3ReqCmdbusDcxifToCmdret: natural := 13;
	constant ixVSigIdhwBss3ReqCmdbusLwiracqToCmdret: natural := 14;
	constant ixVSigIdhwBss3ReqCmdbusLwiracqToPmmu: natural := 15;
	constant ixVSigIdhwBss3ReqCmdbusLwiracqToTkclksrc: natural := 16;
	constant ixVSigIdhwBss3ReqCmdbusPhiifToCmdret: natural := 17;
	constant ixVSigIdhwBss3ReqCmdbusPmmuToCmdret: natural := 18;
	constant ixVSigIdhwBss3ReqCmdbusPmmuToLwiracq: natural := 19;
	constant ixVSigIdhwBss3ReqCmdbusQcdifToCmdret: natural := 20;
	constant ixVSigIdhwBss3ReqCmdbusThetaifToCmdret: natural := 21;
	constant ixVSigIdhwBss3ReqCmdbusTkclksrcToCmdret: natural := 22;
	constant ixVSigIdhwBss3ReqCmdbusTkclksrcToLwiracq: natural := 23;
end Bss3;

