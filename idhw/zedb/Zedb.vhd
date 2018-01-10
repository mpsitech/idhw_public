-- file Zedb.vhd
-- ZedBoard global constants and types
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
	constant tixWIdhwZedbBufferCmdretToHostif: std_logic_vector(7 downto 0) := x"01";
	constant tixWIdhwZedbBufferHostifToCmdinv: std_logic_vector(7 downto 0) := x"02";
	constant tixWIdhwZedbBufferPmmuToHostif: std_logic_vector(7 downto 0) := x"04";
	constant tixWIdhwZedbBufferDcxifToHostif: std_logic_vector(7 downto 0) := x"08";
	constant tixWIdhwZedbBufferHostifToDcxif: std_logic_vector(7 downto 0) := x"10";
	constant tixWIdhwZedbBufferHostifToQcdif: std_logic_vector(7 downto 0) := x"20";
	constant tixWIdhwZedbBufferQcdifToHostif: std_logic_vector(7 downto 0) := x"40";

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

package Zedb is
	constant tixVIdhwZedbControllerCmdinv: std_logic_vector(7 downto 0) := x"01";
	constant tixVIdhwZedbControllerCmdret: std_logic_vector(7 downto 0) := x"02";
	constant tixVIdhwZedbControllerAlua: std_logic_vector(7 downto 0) := x"03";
	constant tixVIdhwZedbControllerAlub: std_logic_vector(7 downto 0) := x"04";
	constant tixVIdhwZedbControllerDcxif: std_logic_vector(7 downto 0) := x"05";
	constant tixVIdhwZedbControllerLwiracq: std_logic_vector(7 downto 0) := x"06";
	constant tixVIdhwZedbControllerLwiremu: std_logic_vector(7 downto 0) := x"07";
	constant tixVIdhwZedbControllerPhiif: std_logic_vector(7 downto 0) := x"08";
	constant tixVIdhwZedbControllerPmmu: std_logic_vector(7 downto 0) := x"09";
	constant tixVIdhwZedbControllerQcdif: std_logic_vector(7 downto 0) := x"0A";
	constant tixVIdhwZedbControllerThetaif: std_logic_vector(7 downto 0) := x"0B";
	constant tixVIdhwZedbControllerTkclksrc: std_logic_vector(7 downto 0) := x"0C";
	constant tixVIdhwZedbControllerTrigger: std_logic_vector(7 downto 0) := x"0D";

	constant ixVSigIdhwZedbAckCmdbusAluaToCmdret: natural := 0;
	constant ixVSigIdhwZedbAckCmdbusAlubToCmdret: natural := 1;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToAlua: natural := 2;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToAlub: natural := 3;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToDcxif: natural := 4;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToLwiracq: natural := 5;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToLwiremu: natural := 6;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToPhiif: natural := 7;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToPmmu: natural := 8;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToQcdif: natural := 9;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToThetaif: natural := 10;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToTkclksrc: natural := 11;
	constant ixVSigIdhwZedbAckCmdbusCmdinvToTrigger: natural := 12;
	constant ixVSigIdhwZedbAckCmdbusDcxifToCmdret: natural := 13;
	constant ixVSigIdhwZedbAckCmdbusLwiracqToCmdret: natural := 14;
	constant ixVSigIdhwZedbAckCmdbusLwiracqToPmmu: natural := 15;
	constant ixVSigIdhwZedbAckCmdbusLwiracqToTkclksrc: natural := 16;
	constant ixVSigIdhwZedbAckCmdbusPhiifToCmdret: natural := 17;
	constant ixVSigIdhwZedbAckCmdbusPmmuToCmdret: natural := 18;
	constant ixVSigIdhwZedbAckCmdbusPmmuToLwiracq: natural := 19;
	constant ixVSigIdhwZedbAckCmdbusQcdifToCmdret: natural := 20;
	constant ixVSigIdhwZedbAckCmdbusThetaifToCmdret: natural := 21;
	constant ixVSigIdhwZedbAckCmdbusTkclksrcToCmdret: natural := 22;
	constant ixVSigIdhwZedbAckCmdbusTkclksrcToLwiracq: natural := 23;

	constant ixVSigIdhwZedbRdyCmdbusAluaToCmdret: natural := 0;
	constant ixVSigIdhwZedbRdyCmdbusAlubToCmdret: natural := 1;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToAlua: natural := 2;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToAlub: natural := 3;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToDcxif: natural := 4;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToLwiracq: natural := 5;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToLwiremu: natural := 6;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToPhiif: natural := 7;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToPmmu: natural := 8;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToQcdif: natural := 9;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToThetaif: natural := 10;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToTkclksrc: natural := 11;
	constant ixVSigIdhwZedbRdyCmdbusCmdinvToTrigger: natural := 12;
	constant ixVSigIdhwZedbRdyCmdbusDcxifToCmdret: natural := 13;
	constant ixVSigIdhwZedbRdyCmdbusLwiracqToCmdret: natural := 14;
	constant ixVSigIdhwZedbRdyCmdbusLwiracqToPmmu: natural := 15;
	constant ixVSigIdhwZedbRdyCmdbusLwiracqToTkclksrc: natural := 16;
	constant ixVSigIdhwZedbRdyCmdbusPhiifToCmdret: natural := 17;
	constant ixVSigIdhwZedbRdyCmdbusPmmuToCmdret: natural := 18;
	constant ixVSigIdhwZedbRdyCmdbusPmmuToLwiracq: natural := 19;
	constant ixVSigIdhwZedbRdyCmdbusQcdifToCmdret: natural := 20;
	constant ixVSigIdhwZedbRdyCmdbusThetaifToCmdret: natural := 21;
	constant ixVSigIdhwZedbRdyCmdbusTkclksrcToCmdret: natural := 22;
	constant ixVSigIdhwZedbRdyCmdbusTkclksrcToLwiracq: natural := 23;

	constant ixVSigIdhwZedbReqCmdbusAluaToCmdret: natural := 0;
	constant ixVSigIdhwZedbReqCmdbusAlubToCmdret: natural := 1;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToAlua: natural := 2;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToAlub: natural := 3;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToDcxif: natural := 4;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToLwiracq: natural := 5;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToLwiremu: natural := 6;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToPhiif: natural := 7;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToPmmu: natural := 8;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToQcdif: natural := 9;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToThetaif: natural := 10;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToTkclksrc: natural := 11;
	constant ixVSigIdhwZedbReqCmdbusCmdinvToTrigger: natural := 12;
	constant ixVSigIdhwZedbReqCmdbusDcxifToCmdret: natural := 13;
	constant ixVSigIdhwZedbReqCmdbusLwiracqToCmdret: natural := 14;
	constant ixVSigIdhwZedbReqCmdbusLwiracqToPmmu: natural := 15;
	constant ixVSigIdhwZedbReqCmdbusLwiracqToTkclksrc: natural := 16;
	constant ixVSigIdhwZedbReqCmdbusPhiifToCmdret: natural := 17;
	constant ixVSigIdhwZedbReqCmdbusPmmuToCmdret: natural := 18;
	constant ixVSigIdhwZedbReqCmdbusPmmuToLwiracq: natural := 19;
	constant ixVSigIdhwZedbReqCmdbusQcdifToCmdret: natural := 20;
	constant ixVSigIdhwZedbReqCmdbusThetaifToCmdret: natural := 21;
	constant ixVSigIdhwZedbReqCmdbusTkclksrcToCmdret: natural := 22;
	constant ixVSigIdhwZedbReqCmdbusTkclksrcToLwiracq: natural := 23;
end Zedb;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Oled128x32_v1_0_lib is
	type bitmap32x128_t is array(0 to 31) of std_logic_vector(0 to 127);
	type char4x20_t is array(0 to 3, 0 to 19) of character;
	type hex4x16_t is array(0 to 3) of std_logic_vector(63 downto 0);
	type bin4x16_t is array(0 to 3) of std_logic_vector(15 downto 0);
end Oled128x32_v1_0_lib;

