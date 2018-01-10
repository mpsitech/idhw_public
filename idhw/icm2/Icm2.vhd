-- file Icm2.vhd
-- icacam2 global constants and types
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
	constant tixWIdhwIcm2BufferCmdretToHostif: std_logic_vector(7 downto 0) := x"01";
	constant tixWIdhwIcm2BufferHostifToCmdinv: std_logic_vector(7 downto 0) := x"02";
	constant tixWIdhwIcm2BufferAcqToHostif: std_logic_vector(7 downto 0) := x"04";
	constant tixWIdhwIcm2BufferHostifToWavegen: std_logic_vector(7 downto 0) := x"08";
end Idhw;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Icm2 is
	constant tixVIdhwIcm2ControllerCmdinv: std_logic_vector(7 downto 0) := x"01";
	constant tixVIdhwIcm2ControllerCmdret: std_logic_vector(7 downto 0) := x"02";
	constant tixVIdhwIcm2ControllerAcq: std_logic_vector(7 downto 0) := x"03";
	constant tixVIdhwIcm2ControllerFan: std_logic_vector(7 downto 0) := x"04";
	constant tixVIdhwIcm2ControllerRoic: std_logic_vector(7 downto 0) := x"05";
	constant tixVIdhwIcm2ControllerState: std_logic_vector(7 downto 0) := x"06";
	constant tixVIdhwIcm2ControllerSync: std_logic_vector(7 downto 0) := x"07";
	constant tixVIdhwIcm2ControllerTemp: std_logic_vector(7 downto 0) := x"08";
	constant tixVIdhwIcm2ControllerTkclksrc: std_logic_vector(7 downto 0) := x"09";
	constant tixVIdhwIcm2ControllerVmon: std_logic_vector(7 downto 0) := x"0A";
	constant tixVIdhwIcm2ControllerVset: std_logic_vector(7 downto 0) := x"0B";
	constant tixVIdhwIcm2ControllerWavegen: std_logic_vector(7 downto 0) := x"0C";

	constant tixVIdhwIcm2StateNc: std_logic_vector(7 downto 0) := x"00";
	constant tixVIdhwIcm2StateCool: std_logic_vector(7 downto 0) := x"01";
	constant tixVIdhwIcm2StateReady: std_logic_vector(7 downto 0) := x"02";
	constant tixVIdhwIcm2StateActive: std_logic_vector(7 downto 0) := x"03";

	constant ixVSigIdhwIcm2AckCmdbusAcqToCmdret: natural := 0;
	constant ixVSigIdhwIcm2AckCmdbusAcqToRoic: natural := 1;
	constant ixVSigIdhwIcm2AckCmdbusAcqToTkclksrc: natural := 2;
	constant ixVSigIdhwIcm2AckCmdbusAcqToVmon: natural := 3;
	constant ixVSigIdhwIcm2AckCmdbusCmdinvToAcq: natural := 4;
	constant ixVSigIdhwIcm2AckCmdbusCmdinvToFan: natural := 5;
	constant ixVSigIdhwIcm2AckCmdbusCmdinvToRoic: natural := 6;
	constant ixVSigIdhwIcm2AckCmdbusCmdinvToState: natural := 7;
	constant ixVSigIdhwIcm2AckCmdbusCmdinvToSync: natural := 8;
	constant ixVSigIdhwIcm2AckCmdbusCmdinvToTemp: natural := 9;
	constant ixVSigIdhwIcm2AckCmdbusCmdinvToTkclksrc: natural := 10;
	constant ixVSigIdhwIcm2AckCmdbusCmdinvToVmon: natural := 11;
	constant ixVSigIdhwIcm2AckCmdbusCmdinvToVset: natural := 12;
	constant ixVSigIdhwIcm2AckCmdbusCmdinvToWavegen: natural := 13;
	constant ixVSigIdhwIcm2AckCmdbusFanToCmdret: natural := 14;
	constant ixVSigIdhwIcm2AckCmdbusStateToCmdret: natural := 15;
	constant ixVSigIdhwIcm2AckCmdbusTempToFan: natural := 16;
	constant ixVSigIdhwIcm2AckCmdbusTempToVmon: natural := 17;
	constant ixVSigIdhwIcm2AckCmdbusTempToVset: natural := 18;
	constant ixVSigIdhwIcm2AckCmdbusTkclksrcToAcq: natural := 19;
	constant ixVSigIdhwIcm2AckCmdbusTkclksrcToCmdret: natural := 20;
	constant ixVSigIdhwIcm2AckCmdbusVmonToAcq: natural := 21;
	constant ixVSigIdhwIcm2AckCmdbusVmonToCmdret: natural := 22;
	constant ixVSigIdhwIcm2AckCmdbusVmonToTemp: natural := 23;

	constant ixVSigIdhwIcm2RdyCmdbusAcqToCmdret: natural := 0;
	constant ixVSigIdhwIcm2RdyCmdbusAcqToRoic: natural := 1;
	constant ixVSigIdhwIcm2RdyCmdbusAcqToTkclksrc: natural := 2;
	constant ixVSigIdhwIcm2RdyCmdbusAcqToVmon: natural := 3;
	constant ixVSigIdhwIcm2RdyCmdbusCmdinvToAcq: natural := 4;
	constant ixVSigIdhwIcm2RdyCmdbusCmdinvToFan: natural := 5;
	constant ixVSigIdhwIcm2RdyCmdbusCmdinvToRoic: natural := 6;
	constant ixVSigIdhwIcm2RdyCmdbusCmdinvToState: natural := 7;
	constant ixVSigIdhwIcm2RdyCmdbusCmdinvToSync: natural := 8;
	constant ixVSigIdhwIcm2RdyCmdbusCmdinvToTemp: natural := 9;
	constant ixVSigIdhwIcm2RdyCmdbusCmdinvToTkclksrc: natural := 10;
	constant ixVSigIdhwIcm2RdyCmdbusCmdinvToVmon: natural := 11;
	constant ixVSigIdhwIcm2RdyCmdbusCmdinvToVset: natural := 12;
	constant ixVSigIdhwIcm2RdyCmdbusCmdinvToWavegen: natural := 13;
	constant ixVSigIdhwIcm2RdyCmdbusFanToCmdret: natural := 14;
	constant ixVSigIdhwIcm2RdyCmdbusStateToCmdret: natural := 15;
	constant ixVSigIdhwIcm2RdyCmdbusTempToFan: natural := 16;
	constant ixVSigIdhwIcm2RdyCmdbusTempToVmon: natural := 17;
	constant ixVSigIdhwIcm2RdyCmdbusTempToVset: natural := 18;
	constant ixVSigIdhwIcm2RdyCmdbusTkclksrcToAcq: natural := 19;
	constant ixVSigIdhwIcm2RdyCmdbusTkclksrcToCmdret: natural := 20;
	constant ixVSigIdhwIcm2RdyCmdbusVmonToAcq: natural := 21;
	constant ixVSigIdhwIcm2RdyCmdbusVmonToCmdret: natural := 22;
	constant ixVSigIdhwIcm2RdyCmdbusVmonToTemp: natural := 23;

	constant ixVSigIdhwIcm2ReqCmdbusAcqToCmdret: natural := 0;
	constant ixVSigIdhwIcm2ReqCmdbusAcqToRoic: natural := 1;
	constant ixVSigIdhwIcm2ReqCmdbusAcqToTkclksrc: natural := 2;
	constant ixVSigIdhwIcm2ReqCmdbusAcqToVmon: natural := 3;
	constant ixVSigIdhwIcm2ReqCmdbusCmdinvToAcq: natural := 4;
	constant ixVSigIdhwIcm2ReqCmdbusCmdinvToFan: natural := 5;
	constant ixVSigIdhwIcm2ReqCmdbusCmdinvToRoic: natural := 6;
	constant ixVSigIdhwIcm2ReqCmdbusCmdinvToState: natural := 7;
	constant ixVSigIdhwIcm2ReqCmdbusCmdinvToSync: natural := 8;
	constant ixVSigIdhwIcm2ReqCmdbusCmdinvToTemp: natural := 9;
	constant ixVSigIdhwIcm2ReqCmdbusCmdinvToTkclksrc: natural := 10;
	constant ixVSigIdhwIcm2ReqCmdbusCmdinvToVmon: natural := 11;
	constant ixVSigIdhwIcm2ReqCmdbusCmdinvToVset: natural := 12;
	constant ixVSigIdhwIcm2ReqCmdbusCmdinvToWavegen: natural := 13;
	constant ixVSigIdhwIcm2ReqCmdbusFanToCmdret: natural := 14;
	constant ixVSigIdhwIcm2ReqCmdbusStateToCmdret: natural := 15;
	constant ixVSigIdhwIcm2ReqCmdbusTempToFan: natural := 16;
	constant ixVSigIdhwIcm2ReqCmdbusTempToVmon: natural := 17;
	constant ixVSigIdhwIcm2ReqCmdbusTempToVset: natural := 18;
	constant ixVSigIdhwIcm2ReqCmdbusTkclksrcToAcq: natural := 19;
	constant ixVSigIdhwIcm2ReqCmdbusTkclksrcToCmdret: natural := 20;
	constant ixVSigIdhwIcm2ReqCmdbusVmonToAcq: natural := 21;
	constant ixVSigIdhwIcm2ReqCmdbusVmonToCmdret: natural := 22;
	constant ixVSigIdhwIcm2ReqCmdbusVmonToTemp: natural := 23;
end Icm2;

