-- file Spbram_v1_0_size480kB.vhd
-- Spbram_v1_0_size480kB spbram_v1_0 implementation
-- author Alexander Wirthmueller
-- date created: 22 Sep 2017
-- date modified: 22 Sep 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Spbram_v1_0_size480kB is
	port (
		clk: in std_logic;

		en: in std_logic;
		we: in std_logic;

		a: in std_logic_vector(18 downto 0);
		drd: out std_logic_vector(7 downto 0);
		dwr: in std_logic_vector(7 downto 0)
	);
end Spbram_v1_0_size480kB;

architecture Spbram_v1_0_size480kB of Spbram_v1_0_size480kB is

	-- IP sigs --- BEGIN
	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	signal en0: std_logic := '0';
	signal en1: std_logic := '0';
	signal en2: std_logic := '0';
	signal en3: std_logic := '0';
	signal en4: std_logic := '0';
	signal en5: std_logic := '0';
	signal en6: std_logic := '0';
	signal en7: std_logic := '0';
	signal en8: std_logic := '0';
	signal en9: std_logic := '0';
	signal en10: std_logic := '0';
	signal en11: std_logic := '0';
	signal en12: std_logic := '0';
	signal en13: std_logic := '0';
	signal en14: std_logic := '0';
	signal en15: std_logic := '0';
	signal en16: std_logic := '0';
	signal en17: std_logic := '0';
	signal en18: std_logic := '0';
	signal en19: std_logic := '0';
	signal en20: std_logic := '0';
	signal en21: std_logic := '0';
	signal en22: std_logic := '0';
	signal en23: std_logic := '0';
	signal en24: std_logic := '0';
	signal en25: std_logic := '0';
	signal en26: std_logic := '0';
	signal en27: std_logic := '0';
	signal en28: std_logic := '0';
	signal en29: std_logic := '0';
	signal en30: std_logic := '0';
	signal en31: std_logic := '0';
	signal en32: std_logic := '0';
	signal en33: std_logic := '0';
	signal en34: std_logic := '0';
	signal en35: std_logic := '0';
	signal en36: std_logic := '0';
	signal en37: std_logic := '0';
	signal en38: std_logic := '0';
	signal en39: std_logic := '0';
	signal en40: std_logic := '0';
	signal en41: std_logic := '0';
	signal en42: std_logic := '0';
	signal en43: std_logic := '0';
	signal en44: std_logic := '0';
	signal en45: std_logic := '0';
	signal en46: std_logic := '0';
	signal en47: std_logic := '0';
	signal en48: std_logic := '0';
	signal en49: std_logic := '0';
	signal en50: std_logic := '0';
	signal en51: std_logic := '0';
	signal en52: std_logic := '0';
	signal en53: std_logic := '0';
	signal en54: std_logic := '0';
	signal en55: std_logic := '0';
	signal en56: std_logic := '0';
	signal en57: std_logic := '0';
	signal en58: std_logic := '0';
	signal en59: std_logic := '0';
	signal en60: std_logic := '0';
	signal en61: std_logic := '0';
	signal en62: std_logic := '0';
	signal en63: std_logic := '0';
	signal en64: std_logic := '0';
	signal en65: std_logic := '0';
	signal en66: std_logic := '0';
	signal en67: std_logic := '0';
	signal en68: std_logic := '0';
	signal en69: std_logic := '0';
	signal en70: std_logic := '0';
	signal en71: std_logic := '0';
	signal en72: std_logic := '0';
	signal en73: std_logic := '0';
	signal en74: std_logic := '0';
	signal en75: std_logic := '0';
	signal en76: std_logic := '0';
	signal en77: std_logic := '0';
	signal en78: std_logic := '0';
	signal en79: std_logic := '0';
	signal en80: std_logic := '0';
	signal en81: std_logic := '0';
	signal en82: std_logic := '0';
	signal en83: std_logic := '0';
	signal en84: std_logic := '0';
	signal en85: std_logic := '0';
	signal en86: std_logic := '0';
	signal en87: std_logic := '0';
	signal en88: std_logic := '0';
	signal en89: std_logic := '0';
	signal en90: std_logic := '0';
	signal en91: std_logic := '0';
	signal en92: std_logic := '0';
	signal en93: std_logic := '0';
	signal en94: std_logic := '0';
	signal en95: std_logic := '0';
	signal en96: std_logic := '0';
	signal en97: std_logic := '0';
	signal en98: std_logic := '0';
	signal en99: std_logic := '0';
	signal en100: std_logic := '0';
	signal en101: std_logic := '0';
	signal en102: std_logic := '0';
	signal en103: std_logic := '0';
	signal en104: std_logic := '0';
	signal en105: std_logic := '0';
	signal en106: std_logic := '0';
	signal en107: std_logic := '0';
	signal en108: std_logic := '0';
	signal en109: std_logic := '0';
	signal en110: std_logic := '0';
	signal en111: std_logic := '0';
	signal en112: std_logic := '0';
	signal en113: std_logic := '0';
	signal en114: std_logic := '0';
	signal en115: std_logic := '0';
	signal en116: std_logic := '0';
	signal en117: std_logic := '0';
	signal en118: std_logic := '0';
	signal en119: std_logic := '0';
	signal en120: std_logic := '0';
	signal en121: std_logic := '0';
	signal en122: std_logic := '0';
	signal en123: std_logic := '0';
	signal en124: std_logic := '0';
	signal en125: std_logic := '0';
	signal en126: std_logic := '0';
	signal en127: std_logic := '0';
	signal en128: std_logic := '0';
	signal en129: std_logic := '0';
	signal en130: std_logic := '0';
	signal en131: std_logic := '0';
	signal en132: std_logic := '0';
	signal en133: std_logic := '0';
	signal en134: std_logic := '0';
	signal en135: std_logic := '0';
	signal en136: std_logic := '0';
	signal en137: std_logic := '0';
	signal en138: std_logic := '0';
	signal en139: std_logic := '0';
	signal en140: std_logic := '0';
	signal en141: std_logic := '0';
	signal en142: std_logic := '0';
	signal en143: std_logic := '0';
	signal en144: std_logic := '0';
	signal en145: std_logic := '0';
	signal en146: std_logic := '0';
	signal en147: std_logic := '0';
	signal en148: std_logic := '0';
	signal en149: std_logic := '0';
	signal en150: std_logic := '0';
	signal en151: std_logic := '0';
	signal en152: std_logic := '0';
	signal en153: std_logic := '0';
	signal en154: std_logic := '0';
	signal en155: std_logic := '0';
	signal en156: std_logic := '0';
	signal en157: std_logic := '0';
	signal en158: std_logic := '0';
	signal en159: std_logic := '0';
	signal en160: std_logic := '0';
	signal en161: std_logic := '0';
	signal en162: std_logic := '0';
	signal en163: std_logic := '0';
	signal en164: std_logic := '0';
	signal en165: std_logic := '0';
	signal en166: std_logic := '0';
	signal en167: std_logic := '0';
	signal en168: std_logic := '0';
	signal en169: std_logic := '0';
	signal en170: std_logic := '0';
	signal en171: std_logic := '0';
	signal en172: std_logic := '0';
	signal en173: std_logic := '0';
	signal en174: std_logic := '0';
	signal en175: std_logic := '0';
	signal en176: std_logic := '0';
	signal en177: std_logic := '0';
	signal en178: std_logic := '0';
	signal en179: std_logic := '0';
	signal en180: std_logic := '0';
	signal en181: std_logic := '0';
	signal en182: std_logic := '0';
	signal en183: std_logic := '0';
	signal en184: std_logic := '0';
	signal en185: std_logic := '0';
	signal en186: std_logic := '0';
	signal en187: std_logic := '0';
	signal en188: std_logic := '0';
	signal en189: std_logic := '0';
	signal en190: std_logic := '0';
	signal en191: std_logic := '0';
	signal en192: std_logic := '0';
	signal en193: std_logic := '0';
	signal en194: std_logic := '0';
	signal en195: std_logic := '0';
	signal en196: std_logic := '0';
	signal en197: std_logic := '0';
	signal en198: std_logic := '0';
	signal en199: std_logic := '0';
	signal en200: std_logic := '0';
	signal en201: std_logic := '0';
	signal en202: std_logic := '0';
	signal en203: std_logic := '0';
	signal en204: std_logic := '0';
	signal en205: std_logic := '0';
	signal en206: std_logic := '0';
	signal en207: std_logic := '0';
	signal en208: std_logic := '0';
	signal en209: std_logic := '0';
	signal en210: std_logic := '0';
	signal en211: std_logic := '0';
	signal en212: std_logic := '0';
	signal en213: std_logic := '0';
	signal en214: std_logic := '0';
	signal en215: std_logic := '0';
	signal en216: std_logic := '0';
	signal en217: std_logic := '0';
	signal en218: std_logic := '0';
	signal en219: std_logic := '0';
	signal en220: std_logic := '0';
	signal en221: std_logic := '0';
	signal en222: std_logic := '0';
	signal en223: std_logic := '0';
	signal en224: std_logic := '0';
	signal en225: std_logic := '0';
	signal en226: std_logic := '0';
	signal en227: std_logic := '0';
	signal en228: std_logic := '0';
	signal en229: std_logic := '0';
	signal en230: std_logic := '0';
	signal en231: std_logic := '0';
	signal en232: std_logic := '0';
	signal en233: std_logic := '0';
	signal en234: std_logic := '0';
	signal en235: std_logic := '0';
	signal en236: std_logic := '0';
	signal en237: std_logic := '0';
	signal en238: std_logic := '0';
	signal en239: std_logic := '0';

	signal drd0: std_logic_vector(7 downto 0) := x"00";
	signal drd1: std_logic_vector(7 downto 0) := x"00";
	signal drd2: std_logic_vector(7 downto 0) := x"00";
	signal drd3: std_logic_vector(7 downto 0) := x"00";
	signal drd4: std_logic_vector(7 downto 0) := x"00";
	signal drd5: std_logic_vector(7 downto 0) := x"00";
	signal drd6: std_logic_vector(7 downto 0) := x"00";
	signal drd7: std_logic_vector(7 downto 0) := x"00";
	signal drd8: std_logic_vector(7 downto 0) := x"00";
	signal drd9: std_logic_vector(7 downto 0) := x"00";
	signal drd10: std_logic_vector(7 downto 0) := x"00";
	signal drd11: std_logic_vector(7 downto 0) := x"00";
	signal drd12: std_logic_vector(7 downto 0) := x"00";
	signal drd13: std_logic_vector(7 downto 0) := x"00";
	signal drd14: std_logic_vector(7 downto 0) := x"00";
	signal drd15: std_logic_vector(7 downto 0) := x"00";
	signal drd16: std_logic_vector(7 downto 0) := x"00";
	signal drd17: std_logic_vector(7 downto 0) := x"00";
	signal drd18: std_logic_vector(7 downto 0) := x"00";
	signal drd19: std_logic_vector(7 downto 0) := x"00";
	signal drd20: std_logic_vector(7 downto 0) := x"00";
	signal drd21: std_logic_vector(7 downto 0) := x"00";
	signal drd22: std_logic_vector(7 downto 0) := x"00";
	signal drd23: std_logic_vector(7 downto 0) := x"00";
	signal drd24: std_logic_vector(7 downto 0) := x"00";
	signal drd25: std_logic_vector(7 downto 0) := x"00";
	signal drd26: std_logic_vector(7 downto 0) := x"00";
	signal drd27: std_logic_vector(7 downto 0) := x"00";
	signal drd28: std_logic_vector(7 downto 0) := x"00";
	signal drd29: std_logic_vector(7 downto 0) := x"00";
	signal drd30: std_logic_vector(7 downto 0) := x"00";
	signal drd31: std_logic_vector(7 downto 0) := x"00";
	signal drd32: std_logic_vector(7 downto 0) := x"00";
	signal drd33: std_logic_vector(7 downto 0) := x"00";
	signal drd34: std_logic_vector(7 downto 0) := x"00";
	signal drd35: std_logic_vector(7 downto 0) := x"00";
	signal drd36: std_logic_vector(7 downto 0) := x"00";
	signal drd37: std_logic_vector(7 downto 0) := x"00";
	signal drd38: std_logic_vector(7 downto 0) := x"00";
	signal drd39: std_logic_vector(7 downto 0) := x"00";
	signal drd40: std_logic_vector(7 downto 0) := x"00";
	signal drd41: std_logic_vector(7 downto 0) := x"00";
	signal drd42: std_logic_vector(7 downto 0) := x"00";
	signal drd43: std_logic_vector(7 downto 0) := x"00";
	signal drd44: std_logic_vector(7 downto 0) := x"00";
	signal drd45: std_logic_vector(7 downto 0) := x"00";
	signal drd46: std_logic_vector(7 downto 0) := x"00";
	signal drd47: std_logic_vector(7 downto 0) := x"00";
	signal drd48: std_logic_vector(7 downto 0) := x"00";
	signal drd49: std_logic_vector(7 downto 0) := x"00";
	signal drd50: std_logic_vector(7 downto 0) := x"00";
	signal drd51: std_logic_vector(7 downto 0) := x"00";
	signal drd52: std_logic_vector(7 downto 0) := x"00";
	signal drd53: std_logic_vector(7 downto 0) := x"00";
	signal drd54: std_logic_vector(7 downto 0) := x"00";
	signal drd55: std_logic_vector(7 downto 0) := x"00";
	signal drd56: std_logic_vector(7 downto 0) := x"00";
	signal drd57: std_logic_vector(7 downto 0) := x"00";
	signal drd58: std_logic_vector(7 downto 0) := x"00";
	signal drd59: std_logic_vector(7 downto 0) := x"00";
	signal drd60: std_logic_vector(7 downto 0) := x"00";
	signal drd61: std_logic_vector(7 downto 0) := x"00";
	signal drd62: std_logic_vector(7 downto 0) := x"00";
	signal drd63: std_logic_vector(7 downto 0) := x"00";
	signal drd64: std_logic_vector(7 downto 0) := x"00";
	signal drd65: std_logic_vector(7 downto 0) := x"00";
	signal drd66: std_logic_vector(7 downto 0) := x"00";
	signal drd67: std_logic_vector(7 downto 0) := x"00";
	signal drd68: std_logic_vector(7 downto 0) := x"00";
	signal drd69: std_logic_vector(7 downto 0) := x"00";
	signal drd70: std_logic_vector(7 downto 0) := x"00";
	signal drd71: std_logic_vector(7 downto 0) := x"00";
	signal drd72: std_logic_vector(7 downto 0) := x"00";
	signal drd73: std_logic_vector(7 downto 0) := x"00";
	signal drd74: std_logic_vector(7 downto 0) := x"00";
	signal drd75: std_logic_vector(7 downto 0) := x"00";
	signal drd76: std_logic_vector(7 downto 0) := x"00";
	signal drd77: std_logic_vector(7 downto 0) := x"00";
	signal drd78: std_logic_vector(7 downto 0) := x"00";
	signal drd79: std_logic_vector(7 downto 0) := x"00";
	signal drd80: std_logic_vector(7 downto 0) := x"00";
	signal drd81: std_logic_vector(7 downto 0) := x"00";
	signal drd82: std_logic_vector(7 downto 0) := x"00";
	signal drd83: std_logic_vector(7 downto 0) := x"00";
	signal drd84: std_logic_vector(7 downto 0) := x"00";
	signal drd85: std_logic_vector(7 downto 0) := x"00";
	signal drd86: std_logic_vector(7 downto 0) := x"00";
	signal drd87: std_logic_vector(7 downto 0) := x"00";
	signal drd88: std_logic_vector(7 downto 0) := x"00";
	signal drd89: std_logic_vector(7 downto 0) := x"00";
	signal drd90: std_logic_vector(7 downto 0) := x"00";
	signal drd91: std_logic_vector(7 downto 0) := x"00";
	signal drd92: std_logic_vector(7 downto 0) := x"00";
	signal drd93: std_logic_vector(7 downto 0) := x"00";
	signal drd94: std_logic_vector(7 downto 0) := x"00";
	signal drd95: std_logic_vector(7 downto 0) := x"00";
	signal drd96: std_logic_vector(7 downto 0) := x"00";
	signal drd97: std_logic_vector(7 downto 0) := x"00";
	signal drd98: std_logic_vector(7 downto 0) := x"00";
	signal drd99: std_logic_vector(7 downto 0) := x"00";
	signal drd100: std_logic_vector(7 downto 0) := x"00";
	signal drd101: std_logic_vector(7 downto 0) := x"00";
	signal drd102: std_logic_vector(7 downto 0) := x"00";
	signal drd103: std_logic_vector(7 downto 0) := x"00";
	signal drd104: std_logic_vector(7 downto 0) := x"00";
	signal drd105: std_logic_vector(7 downto 0) := x"00";
	signal drd106: std_logic_vector(7 downto 0) := x"00";
	signal drd107: std_logic_vector(7 downto 0) := x"00";
	signal drd108: std_logic_vector(7 downto 0) := x"00";
	signal drd109: std_logic_vector(7 downto 0) := x"00";
	signal drd110: std_logic_vector(7 downto 0) := x"00";
	signal drd111: std_logic_vector(7 downto 0) := x"00";
	signal drd112: std_logic_vector(7 downto 0) := x"00";
	signal drd113: std_logic_vector(7 downto 0) := x"00";
	signal drd114: std_logic_vector(7 downto 0) := x"00";
	signal drd115: std_logic_vector(7 downto 0) := x"00";
	signal drd116: std_logic_vector(7 downto 0) := x"00";
	signal drd117: std_logic_vector(7 downto 0) := x"00";
	signal drd118: std_logic_vector(7 downto 0) := x"00";
	signal drd119: std_logic_vector(7 downto 0) := x"00";
	signal drd120: std_logic_vector(7 downto 0) := x"00";
	signal drd121: std_logic_vector(7 downto 0) := x"00";
	signal drd122: std_logic_vector(7 downto 0) := x"00";
	signal drd123: std_logic_vector(7 downto 0) := x"00";
	signal drd124: std_logic_vector(7 downto 0) := x"00";
	signal drd125: std_logic_vector(7 downto 0) := x"00";
	signal drd126: std_logic_vector(7 downto 0) := x"00";
	signal drd127: std_logic_vector(7 downto 0) := x"00";
	signal drd128: std_logic_vector(7 downto 0) := x"00";
	signal drd129: std_logic_vector(7 downto 0) := x"00";
	signal drd130: std_logic_vector(7 downto 0) := x"00";
	signal drd131: std_logic_vector(7 downto 0) := x"00";
	signal drd132: std_logic_vector(7 downto 0) := x"00";
	signal drd133: std_logic_vector(7 downto 0) := x"00";
	signal drd134: std_logic_vector(7 downto 0) := x"00";
	signal drd135: std_logic_vector(7 downto 0) := x"00";
	signal drd136: std_logic_vector(7 downto 0) := x"00";
	signal drd137: std_logic_vector(7 downto 0) := x"00";
	signal drd138: std_logic_vector(7 downto 0) := x"00";
	signal drd139: std_logic_vector(7 downto 0) := x"00";
	signal drd140: std_logic_vector(7 downto 0) := x"00";
	signal drd141: std_logic_vector(7 downto 0) := x"00";
	signal drd142: std_logic_vector(7 downto 0) := x"00";
	signal drd143: std_logic_vector(7 downto 0) := x"00";
	signal drd144: std_logic_vector(7 downto 0) := x"00";
	signal drd145: std_logic_vector(7 downto 0) := x"00";
	signal drd146: std_logic_vector(7 downto 0) := x"00";
	signal drd147: std_logic_vector(7 downto 0) := x"00";
	signal drd148: std_logic_vector(7 downto 0) := x"00";
	signal drd149: std_logic_vector(7 downto 0) := x"00";
	signal drd150: std_logic_vector(7 downto 0) := x"00";
	signal drd151: std_logic_vector(7 downto 0) := x"00";
	signal drd152: std_logic_vector(7 downto 0) := x"00";
	signal drd153: std_logic_vector(7 downto 0) := x"00";
	signal drd154: std_logic_vector(7 downto 0) := x"00";
	signal drd155: std_logic_vector(7 downto 0) := x"00";
	signal drd156: std_logic_vector(7 downto 0) := x"00";
	signal drd157: std_logic_vector(7 downto 0) := x"00";
	signal drd158: std_logic_vector(7 downto 0) := x"00";
	signal drd159: std_logic_vector(7 downto 0) := x"00";
	signal drd160: std_logic_vector(7 downto 0) := x"00";
	signal drd161: std_logic_vector(7 downto 0) := x"00";
	signal drd162: std_logic_vector(7 downto 0) := x"00";
	signal drd163: std_logic_vector(7 downto 0) := x"00";
	signal drd164: std_logic_vector(7 downto 0) := x"00";
	signal drd165: std_logic_vector(7 downto 0) := x"00";
	signal drd166: std_logic_vector(7 downto 0) := x"00";
	signal drd167: std_logic_vector(7 downto 0) := x"00";
	signal drd168: std_logic_vector(7 downto 0) := x"00";
	signal drd169: std_logic_vector(7 downto 0) := x"00";
	signal drd170: std_logic_vector(7 downto 0) := x"00";
	signal drd171: std_logic_vector(7 downto 0) := x"00";
	signal drd172: std_logic_vector(7 downto 0) := x"00";
	signal drd173: std_logic_vector(7 downto 0) := x"00";
	signal drd174: std_logic_vector(7 downto 0) := x"00";
	signal drd175: std_logic_vector(7 downto 0) := x"00";
	signal drd176: std_logic_vector(7 downto 0) := x"00";
	signal drd177: std_logic_vector(7 downto 0) := x"00";
	signal drd178: std_logic_vector(7 downto 0) := x"00";
	signal drd179: std_logic_vector(7 downto 0) := x"00";
	signal drd180: std_logic_vector(7 downto 0) := x"00";
	signal drd181: std_logic_vector(7 downto 0) := x"00";
	signal drd182: std_logic_vector(7 downto 0) := x"00";
	signal drd183: std_logic_vector(7 downto 0) := x"00";
	signal drd184: std_logic_vector(7 downto 0) := x"00";
	signal drd185: std_logic_vector(7 downto 0) := x"00";
	signal drd186: std_logic_vector(7 downto 0) := x"00";
	signal drd187: std_logic_vector(7 downto 0) := x"00";
	signal drd188: std_logic_vector(7 downto 0) := x"00";
	signal drd189: std_logic_vector(7 downto 0) := x"00";
	signal drd190: std_logic_vector(7 downto 0) := x"00";
	signal drd191: std_logic_vector(7 downto 0) := x"00";
	signal drd192: std_logic_vector(7 downto 0) := x"00";
	signal drd193: std_logic_vector(7 downto 0) := x"00";
	signal drd194: std_logic_vector(7 downto 0) := x"00";
	signal drd195: std_logic_vector(7 downto 0) := x"00";
	signal drd196: std_logic_vector(7 downto 0) := x"00";
	signal drd197: std_logic_vector(7 downto 0) := x"00";
	signal drd198: std_logic_vector(7 downto 0) := x"00";
	signal drd199: std_logic_vector(7 downto 0) := x"00";
	signal drd200: std_logic_vector(7 downto 0) := x"00";
	signal drd201: std_logic_vector(7 downto 0) := x"00";
	signal drd202: std_logic_vector(7 downto 0) := x"00";
	signal drd203: std_logic_vector(7 downto 0) := x"00";
	signal drd204: std_logic_vector(7 downto 0) := x"00";
	signal drd205: std_logic_vector(7 downto 0) := x"00";
	signal drd206: std_logic_vector(7 downto 0) := x"00";
	signal drd207: std_logic_vector(7 downto 0) := x"00";
	signal drd208: std_logic_vector(7 downto 0) := x"00";
	signal drd209: std_logic_vector(7 downto 0) := x"00";
	signal drd210: std_logic_vector(7 downto 0) := x"00";
	signal drd211: std_logic_vector(7 downto 0) := x"00";
	signal drd212: std_logic_vector(7 downto 0) := x"00";
	signal drd213: std_logic_vector(7 downto 0) := x"00";
	signal drd214: std_logic_vector(7 downto 0) := x"00";
	signal drd215: std_logic_vector(7 downto 0) := x"00";
	signal drd216: std_logic_vector(7 downto 0) := x"00";
	signal drd217: std_logic_vector(7 downto 0) := x"00";
	signal drd218: std_logic_vector(7 downto 0) := x"00";
	signal drd219: std_logic_vector(7 downto 0) := x"00";
	signal drd220: std_logic_vector(7 downto 0) := x"00";
	signal drd221: std_logic_vector(7 downto 0) := x"00";
	signal drd222: std_logic_vector(7 downto 0) := x"00";
	signal drd223: std_logic_vector(7 downto 0) := x"00";
	signal drd224: std_logic_vector(7 downto 0) := x"00";
	signal drd225: std_logic_vector(7 downto 0) := x"00";
	signal drd226: std_logic_vector(7 downto 0) := x"00";
	signal drd227: std_logic_vector(7 downto 0) := x"00";
	signal drd228: std_logic_vector(7 downto 0) := x"00";
	signal drd229: std_logic_vector(7 downto 0) := x"00";
	signal drd230: std_logic_vector(7 downto 0) := x"00";
	signal drd231: std_logic_vector(7 downto 0) := x"00";
	signal drd232: std_logic_vector(7 downto 0) := x"00";
	signal drd233: std_logic_vector(7 downto 0) := x"00";
	signal drd234: std_logic_vector(7 downto 0) := x"00";
	signal drd235: std_logic_vector(7 downto 0) := x"00";
	signal drd236: std_logic_vector(7 downto 0) := x"00";
	signal drd237: std_logic_vector(7 downto 0) := x"00";
	signal drd238: std_logic_vector(7 downto 0) := x"00";
	signal drd239: std_logic_vector(7 downto 0) := x"00";
	-- IP sigs --- END

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBram0 : RAMB16_S9
		port map (
			DO => drd0,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en0,
			SSR => '0',
			WE => we
		);

	myBram1 : RAMB16_S9
		port map (
			DO => drd1,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en1,
			SSR => '0',
			WE => we
		);

	myBram10 : RAMB16_S9
		port map (
			DO => drd10,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en10,
			SSR => '0',
			WE => we
		);

	myBram100 : RAMB16_S9
		port map (
			DO => drd100,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en100,
			SSR => '0',
			WE => we
		);

	myBram101 : RAMB16_S9
		port map (
			DO => drd101,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en101,
			SSR => '0',
			WE => we
		);

	myBram102 : RAMB16_S9
		port map (
			DO => drd102,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en102,
			SSR => '0',
			WE => we
		);

	myBram103 : RAMB16_S9
		port map (
			DO => drd103,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en103,
			SSR => '0',
			WE => we
		);

	myBram104 : RAMB16_S9
		port map (
			DO => drd104,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en104,
			SSR => '0',
			WE => we
		);

	myBram105 : RAMB16_S9
		port map (
			DO => drd105,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en105,
			SSR => '0',
			WE => we
		);

	myBram106 : RAMB16_S9
		port map (
			DO => drd106,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en106,
			SSR => '0',
			WE => we
		);

	myBram107 : RAMB16_S9
		port map (
			DO => drd107,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en107,
			SSR => '0',
			WE => we
		);

	myBram108 : RAMB16_S9
		port map (
			DO => drd108,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en108,
			SSR => '0',
			WE => we
		);

	myBram109 : RAMB16_S9
		port map (
			DO => drd109,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en109,
			SSR => '0',
			WE => we
		);

	myBram11 : RAMB16_S9
		port map (
			DO => drd11,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en11,
			SSR => '0',
			WE => we
		);

	myBram110 : RAMB16_S9
		port map (
			DO => drd110,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en110,
			SSR => '0',
			WE => we
		);

	myBram111 : RAMB16_S9
		port map (
			DO => drd111,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en111,
			SSR => '0',
			WE => we
		);

	myBram112 : RAMB16_S9
		port map (
			DO => drd112,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en112,
			SSR => '0',
			WE => we
		);

	myBram113 : RAMB16_S9
		port map (
			DO => drd113,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en113,
			SSR => '0',
			WE => we
		);

	myBram114 : RAMB16_S9
		port map (
			DO => drd114,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en114,
			SSR => '0',
			WE => we
		);

	myBram115 : RAMB16_S9
		port map (
			DO => drd115,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en115,
			SSR => '0',
			WE => we
		);

	myBram116 : RAMB16_S9
		port map (
			DO => drd116,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en116,
			SSR => '0',
			WE => we
		);

	myBram117 : RAMB16_S9
		port map (
			DO => drd117,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en117,
			SSR => '0',
			WE => we
		);

	myBram118 : RAMB16_S9
		port map (
			DO => drd118,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en118,
			SSR => '0',
			WE => we
		);

	myBram119 : RAMB16_S9
		port map (
			DO => drd119,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en119,
			SSR => '0',
			WE => we
		);

	myBram12 : RAMB16_S9
		port map (
			DO => drd12,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en12,
			SSR => '0',
			WE => we
		);

	myBram120 : RAMB16_S9
		port map (
			DO => drd120,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en120,
			SSR => '0',
			WE => we
		);

	myBram121 : RAMB16_S9
		port map (
			DO => drd121,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en121,
			SSR => '0',
			WE => we
		);

	myBram122 : RAMB16_S9
		port map (
			DO => drd122,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en122,
			SSR => '0',
			WE => we
		);

	myBram123 : RAMB16_S9
		port map (
			DO => drd123,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en123,
			SSR => '0',
			WE => we
		);

	myBram124 : RAMB16_S9
		port map (
			DO => drd124,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en124,
			SSR => '0',
			WE => we
		);

	myBram125 : RAMB16_S9
		port map (
			DO => drd125,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en125,
			SSR => '0',
			WE => we
		);

	myBram126 : RAMB16_S9
		port map (
			DO => drd126,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en126,
			SSR => '0',
			WE => we
		);

	myBram127 : RAMB16_S9
		port map (
			DO => drd127,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en127,
			SSR => '0',
			WE => we
		);

	myBram128 : RAMB16_S9
		port map (
			DO => drd128,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en128,
			SSR => '0',
			WE => we
		);

	myBram129 : RAMB16_S9
		port map (
			DO => drd129,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en129,
			SSR => '0',
			WE => we
		);

	myBram13 : RAMB16_S9
		port map (
			DO => drd13,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en13,
			SSR => '0',
			WE => we
		);

	myBram130 : RAMB16_S9
		port map (
			DO => drd130,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en130,
			SSR => '0',
			WE => we
		);

	myBram131 : RAMB16_S9
		port map (
			DO => drd131,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en131,
			SSR => '0',
			WE => we
		);

	myBram132 : RAMB16_S9
		port map (
			DO => drd132,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en132,
			SSR => '0',
			WE => we
		);

	myBram133 : RAMB16_S9
		port map (
			DO => drd133,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en133,
			SSR => '0',
			WE => we
		);

	myBram134 : RAMB16_S9
		port map (
			DO => drd134,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en134,
			SSR => '0',
			WE => we
		);

	myBram135 : RAMB16_S9
		port map (
			DO => drd135,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en135,
			SSR => '0',
			WE => we
		);

	myBram136 : RAMB16_S9
		port map (
			DO => drd136,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en136,
			SSR => '0',
			WE => we
		);

	myBram137 : RAMB16_S9
		port map (
			DO => drd137,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en137,
			SSR => '0',
			WE => we
		);

	myBram138 : RAMB16_S9
		port map (
			DO => drd138,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en138,
			SSR => '0',
			WE => we
		);

	myBram139 : RAMB16_S9
		port map (
			DO => drd139,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en139,
			SSR => '0',
			WE => we
		);

	myBram14 : RAMB16_S9
		port map (
			DO => drd14,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en14,
			SSR => '0',
			WE => we
		);

	myBram140 : RAMB16_S9
		port map (
			DO => drd140,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en140,
			SSR => '0',
			WE => we
		);

	myBram141 : RAMB16_S9
		port map (
			DO => drd141,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en141,
			SSR => '0',
			WE => we
		);

	myBram142 : RAMB16_S9
		port map (
			DO => drd142,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en142,
			SSR => '0',
			WE => we
		);

	myBram143 : RAMB16_S9
		port map (
			DO => drd143,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en143,
			SSR => '0',
			WE => we
		);

	myBram144 : RAMB16_S9
		port map (
			DO => drd144,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en144,
			SSR => '0',
			WE => we
		);

	myBram145 : RAMB16_S9
		port map (
			DO => drd145,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en145,
			SSR => '0',
			WE => we
		);

	myBram146 : RAMB16_S9
		port map (
			DO => drd146,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en146,
			SSR => '0',
			WE => we
		);

	myBram147 : RAMB16_S9
		port map (
			DO => drd147,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en147,
			SSR => '0',
			WE => we
		);

	myBram148 : RAMB16_S9
		port map (
			DO => drd148,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en148,
			SSR => '0',
			WE => we
		);

	myBram149 : RAMB16_S9
		port map (
			DO => drd149,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en149,
			SSR => '0',
			WE => we
		);

	myBram15 : RAMB16_S9
		port map (
			DO => drd15,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en15,
			SSR => '0',
			WE => we
		);

	myBram150 : RAMB16_S9
		port map (
			DO => drd150,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en150,
			SSR => '0',
			WE => we
		);

	myBram151 : RAMB16_S9
		port map (
			DO => drd151,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en151,
			SSR => '0',
			WE => we
		);

	myBram152 : RAMB16_S9
		port map (
			DO => drd152,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en152,
			SSR => '0',
			WE => we
		);

	myBram153 : RAMB16_S9
		port map (
			DO => drd153,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en153,
			SSR => '0',
			WE => we
		);

	myBram154 : RAMB16_S9
		port map (
			DO => drd154,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en154,
			SSR => '0',
			WE => we
		);

	myBram155 : RAMB16_S9
		port map (
			DO => drd155,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en155,
			SSR => '0',
			WE => we
		);

	myBram156 : RAMB16_S9
		port map (
			DO => drd156,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en156,
			SSR => '0',
			WE => we
		);

	myBram157 : RAMB16_S9
		port map (
			DO => drd157,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en157,
			SSR => '0',
			WE => we
		);

	myBram158 : RAMB16_S9
		port map (
			DO => drd158,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en158,
			SSR => '0',
			WE => we
		);

	myBram159 : RAMB16_S9
		port map (
			DO => drd159,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en159,
			SSR => '0',
			WE => we
		);

	myBram16 : RAMB16_S9
		port map (
			DO => drd16,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en16,
			SSR => '0',
			WE => we
		);

	myBram160 : RAMB16_S9
		port map (
			DO => drd160,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en160,
			SSR => '0',
			WE => we
		);

	myBram161 : RAMB16_S9
		port map (
			DO => drd161,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en161,
			SSR => '0',
			WE => we
		);

	myBram162 : RAMB16_S9
		port map (
			DO => drd162,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en162,
			SSR => '0',
			WE => we
		);

	myBram163 : RAMB16_S9
		port map (
			DO => drd163,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en163,
			SSR => '0',
			WE => we
		);

	myBram164 : RAMB16_S9
		port map (
			DO => drd164,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en164,
			SSR => '0',
			WE => we
		);

	myBram165 : RAMB16_S9
		port map (
			DO => drd165,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en165,
			SSR => '0',
			WE => we
		);

	myBram166 : RAMB16_S9
		port map (
			DO => drd166,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en166,
			SSR => '0',
			WE => we
		);

	myBram167 : RAMB16_S9
		port map (
			DO => drd167,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en167,
			SSR => '0',
			WE => we
		);

	myBram168 : RAMB16_S9
		port map (
			DO => drd168,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en168,
			SSR => '0',
			WE => we
		);

	myBram169 : RAMB16_S9
		port map (
			DO => drd169,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en169,
			SSR => '0',
			WE => we
		);

	myBram17 : RAMB16_S9
		port map (
			DO => drd17,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en17,
			SSR => '0',
			WE => we
		);

	myBram170 : RAMB16_S9
		port map (
			DO => drd170,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en170,
			SSR => '0',
			WE => we
		);

	myBram171 : RAMB16_S9
		port map (
			DO => drd171,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en171,
			SSR => '0',
			WE => we
		);

	myBram172 : RAMB16_S9
		port map (
			DO => drd172,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en172,
			SSR => '0',
			WE => we
		);

	myBram173 : RAMB16_S9
		port map (
			DO => drd173,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en173,
			SSR => '0',
			WE => we
		);

	myBram174 : RAMB16_S9
		port map (
			DO => drd174,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en174,
			SSR => '0',
			WE => we
		);

	myBram175 : RAMB16_S9
		port map (
			DO => drd175,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en175,
			SSR => '0',
			WE => we
		);

	myBram176 : RAMB16_S9
		port map (
			DO => drd176,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en176,
			SSR => '0',
			WE => we
		);

	myBram177 : RAMB16_S9
		port map (
			DO => drd177,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en177,
			SSR => '0',
			WE => we
		);

	myBram178 : RAMB16_S9
		port map (
			DO => drd178,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en178,
			SSR => '0',
			WE => we
		);

	myBram179 : RAMB16_S9
		port map (
			DO => drd179,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en179,
			SSR => '0',
			WE => we
		);

	myBram18 : RAMB16_S9
		port map (
			DO => drd18,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en18,
			SSR => '0',
			WE => we
		);

	myBram180 : RAMB16_S9
		port map (
			DO => drd180,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en180,
			SSR => '0',
			WE => we
		);

	myBram181 : RAMB16_S9
		port map (
			DO => drd181,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en181,
			SSR => '0',
			WE => we
		);

	myBram182 : RAMB16_S9
		port map (
			DO => drd182,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en182,
			SSR => '0',
			WE => we
		);

	myBram183 : RAMB16_S9
		port map (
			DO => drd183,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en183,
			SSR => '0',
			WE => we
		);

	myBram184 : RAMB16_S9
		port map (
			DO => drd184,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en184,
			SSR => '0',
			WE => we
		);

	myBram185 : RAMB16_S9
		port map (
			DO => drd185,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en185,
			SSR => '0',
			WE => we
		);

	myBram186 : RAMB16_S9
		port map (
			DO => drd186,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en186,
			SSR => '0',
			WE => we
		);

	myBram187 : RAMB16_S9
		port map (
			DO => drd187,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en187,
			SSR => '0',
			WE => we
		);

	myBram188 : RAMB16_S9
		port map (
			DO => drd188,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en188,
			SSR => '0',
			WE => we
		);

	myBram189 : RAMB16_S9
		port map (
			DO => drd189,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en189,
			SSR => '0',
			WE => we
		);

	myBram19 : RAMB16_S9
		port map (
			DO => drd19,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en19,
			SSR => '0',
			WE => we
		);

	myBram190 : RAMB16_S9
		port map (
			DO => drd190,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en190,
			SSR => '0',
			WE => we
		);

	myBram191 : RAMB16_S9
		port map (
			DO => drd191,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en191,
			SSR => '0',
			WE => we
		);

	myBram192 : RAMB16_S9
		port map (
			DO => drd192,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en192,
			SSR => '0',
			WE => we
		);

	myBram193 : RAMB16_S9
		port map (
			DO => drd193,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en193,
			SSR => '0',
			WE => we
		);

	myBram194 : RAMB16_S9
		port map (
			DO => drd194,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en194,
			SSR => '0',
			WE => we
		);

	myBram195 : RAMB16_S9
		port map (
			DO => drd195,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en195,
			SSR => '0',
			WE => we
		);

	myBram196 : RAMB16_S9
		port map (
			DO => drd196,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en196,
			SSR => '0',
			WE => we
		);

	myBram197 : RAMB16_S9
		port map (
			DO => drd197,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en197,
			SSR => '0',
			WE => we
		);

	myBram198 : RAMB16_S9
		port map (
			DO => drd198,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en198,
			SSR => '0',
			WE => we
		);

	myBram199 : RAMB16_S9
		port map (
			DO => drd199,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en199,
			SSR => '0',
			WE => we
		);

	myBram2 : RAMB16_S9
		port map (
			DO => drd2,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en2,
			SSR => '0',
			WE => we
		);

	myBram20 : RAMB16_S9
		port map (
			DO => drd20,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en20,
			SSR => '0',
			WE => we
		);

	myBram200 : RAMB16_S9
		port map (
			DO => drd200,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en200,
			SSR => '0',
			WE => we
		);

	myBram201 : RAMB16_S9
		port map (
			DO => drd201,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en201,
			SSR => '0',
			WE => we
		);

	myBram202 : RAMB16_S9
		port map (
			DO => drd202,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en202,
			SSR => '0',
			WE => we
		);

	myBram203 : RAMB16_S9
		port map (
			DO => drd203,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en203,
			SSR => '0',
			WE => we
		);

	myBram204 : RAMB16_S9
		port map (
			DO => drd204,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en204,
			SSR => '0',
			WE => we
		);

	myBram205 : RAMB16_S9
		port map (
			DO => drd205,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en205,
			SSR => '0',
			WE => we
		);

	myBram206 : RAMB16_S9
		port map (
			DO => drd206,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en206,
			SSR => '0',
			WE => we
		);

	myBram207 : RAMB16_S9
		port map (
			DO => drd207,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en207,
			SSR => '0',
			WE => we
		);

	myBram208 : RAMB16_S9
		port map (
			DO => drd208,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en208,
			SSR => '0',
			WE => we
		);

	myBram209 : RAMB16_S9
		port map (
			DO => drd209,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en209,
			SSR => '0',
			WE => we
		);

	myBram21 : RAMB16_S9
		port map (
			DO => drd21,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en21,
			SSR => '0',
			WE => we
		);

	myBram210 : RAMB16_S9
		port map (
			DO => drd210,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en210,
			SSR => '0',
			WE => we
		);

	myBram211 : RAMB16_S9
		port map (
			DO => drd211,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en211,
			SSR => '0',
			WE => we
		);

	myBram212 : RAMB16_S9
		port map (
			DO => drd212,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en212,
			SSR => '0',
			WE => we
		);

	myBram213 : RAMB16_S9
		port map (
			DO => drd213,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en213,
			SSR => '0',
			WE => we
		);

	myBram214 : RAMB16_S9
		port map (
			DO => drd214,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en214,
			SSR => '0',
			WE => we
		);

	myBram215 : RAMB16_S9
		port map (
			DO => drd215,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en215,
			SSR => '0',
			WE => we
		);

	myBram216 : RAMB16_S9
		port map (
			DO => drd216,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en216,
			SSR => '0',
			WE => we
		);

	myBram217 : RAMB16_S9
		port map (
			DO => drd217,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en217,
			SSR => '0',
			WE => we
		);

	myBram218 : RAMB16_S9
		port map (
			DO => drd218,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en218,
			SSR => '0',
			WE => we
		);

	myBram219 : RAMB16_S9
		port map (
			DO => drd219,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en219,
			SSR => '0',
			WE => we
		);

	myBram22 : RAMB16_S9
		port map (
			DO => drd22,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en22,
			SSR => '0',
			WE => we
		);

	myBram220 : RAMB16_S9
		port map (
			DO => drd220,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en220,
			SSR => '0',
			WE => we
		);

	myBram221 : RAMB16_S9
		port map (
			DO => drd221,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en221,
			SSR => '0',
			WE => we
		);

	myBram222 : RAMB16_S9
		port map (
			DO => drd222,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en222,
			SSR => '0',
			WE => we
		);

	myBram223 : RAMB16_S9
		port map (
			DO => drd223,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en223,
			SSR => '0',
			WE => we
		);

	myBram224 : RAMB16_S9
		port map (
			DO => drd224,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en224,
			SSR => '0',
			WE => we
		);

	myBram225 : RAMB16_S9
		port map (
			DO => drd225,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en225,
			SSR => '0',
			WE => we
		);

	myBram226 : RAMB16_S9
		port map (
			DO => drd226,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en226,
			SSR => '0',
			WE => we
		);

	myBram227 : RAMB16_S9
		port map (
			DO => drd227,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en227,
			SSR => '0',
			WE => we
		);

	myBram228 : RAMB16_S9
		port map (
			DO => drd228,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en228,
			SSR => '0',
			WE => we
		);

	myBram229 : RAMB16_S9
		port map (
			DO => drd229,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en229,
			SSR => '0',
			WE => we
		);

	myBram23 : RAMB16_S9
		port map (
			DO => drd23,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en23,
			SSR => '0',
			WE => we
		);

	myBram230 : RAMB16_S9
		port map (
			DO => drd230,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en230,
			SSR => '0',
			WE => we
		);

	myBram231 : RAMB16_S9
		port map (
			DO => drd231,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en231,
			SSR => '0',
			WE => we
		);

	myBram232 : RAMB16_S9
		port map (
			DO => drd232,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en232,
			SSR => '0',
			WE => we
		);

	myBram233 : RAMB16_S9
		port map (
			DO => drd233,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en233,
			SSR => '0',
			WE => we
		);

	myBram234 : RAMB16_S9
		port map (
			DO => drd234,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en234,
			SSR => '0',
			WE => we
		);

	myBram235 : RAMB16_S9
		port map (
			DO => drd235,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en235,
			SSR => '0',
			WE => we
		);

	myBram236 : RAMB16_S9
		port map (
			DO => drd236,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en236,
			SSR => '0',
			WE => we
		);

	myBram237 : RAMB16_S9
		port map (
			DO => drd237,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en237,
			SSR => '0',
			WE => we
		);

	myBram238 : RAMB16_S9
		port map (
			DO => drd238,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en238,
			SSR => '0',
			WE => we
		);

	myBram239 : RAMB16_S9
		port map (
			DO => drd239,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en239,
			SSR => '0',
			WE => we
		);

	myBram24 : RAMB16_S9
		port map (
			DO => drd24,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en24,
			SSR => '0',
			WE => we
		);

	myBram25 : RAMB16_S9
		port map (
			DO => drd25,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en25,
			SSR => '0',
			WE => we
		);

	myBram26 : RAMB16_S9
		port map (
			DO => drd26,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en26,
			SSR => '0',
			WE => we
		);

	myBram27 : RAMB16_S9
		port map (
			DO => drd27,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en27,
			SSR => '0',
			WE => we
		);

	myBram28 : RAMB16_S9
		port map (
			DO => drd28,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en28,
			SSR => '0',
			WE => we
		);

	myBram29 : RAMB16_S9
		port map (
			DO => drd29,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en29,
			SSR => '0',
			WE => we
		);

	myBram3 : RAMB16_S9
		port map (
			DO => drd3,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en3,
			SSR => '0',
			WE => we
		);

	myBram30 : RAMB16_S9
		port map (
			DO => drd30,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en30,
			SSR => '0',
			WE => we
		);

	myBram31 : RAMB16_S9
		port map (
			DO => drd31,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en31,
			SSR => '0',
			WE => we
		);

	myBram32 : RAMB16_S9
		port map (
			DO => drd32,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en32,
			SSR => '0',
			WE => we
		);

	myBram33 : RAMB16_S9
		port map (
			DO => drd33,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en33,
			SSR => '0',
			WE => we
		);

	myBram34 : RAMB16_S9
		port map (
			DO => drd34,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en34,
			SSR => '0',
			WE => we
		);

	myBram35 : RAMB16_S9
		port map (
			DO => drd35,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en35,
			SSR => '0',
			WE => we
		);

	myBram36 : RAMB16_S9
		port map (
			DO => drd36,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en36,
			SSR => '0',
			WE => we
		);

	myBram37 : RAMB16_S9
		port map (
			DO => drd37,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en37,
			SSR => '0',
			WE => we
		);

	myBram38 : RAMB16_S9
		port map (
			DO => drd38,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en38,
			SSR => '0',
			WE => we
		);

	myBram39 : RAMB16_S9
		port map (
			DO => drd39,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en39,
			SSR => '0',
			WE => we
		);

	myBram4 : RAMB16_S9
		port map (
			DO => drd4,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en4,
			SSR => '0',
			WE => we
		);

	myBram40 : RAMB16_S9
		port map (
			DO => drd40,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en40,
			SSR => '0',
			WE => we
		);

	myBram41 : RAMB16_S9
		port map (
			DO => drd41,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en41,
			SSR => '0',
			WE => we
		);

	myBram42 : RAMB16_S9
		port map (
			DO => drd42,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en42,
			SSR => '0',
			WE => we
		);

	myBram43 : RAMB16_S9
		port map (
			DO => drd43,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en43,
			SSR => '0',
			WE => we
		);

	myBram44 : RAMB16_S9
		port map (
			DO => drd44,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en44,
			SSR => '0',
			WE => we
		);

	myBram45 : RAMB16_S9
		port map (
			DO => drd45,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en45,
			SSR => '0',
			WE => we
		);

	myBram46 : RAMB16_S9
		port map (
			DO => drd46,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en46,
			SSR => '0',
			WE => we
		);

	myBram47 : RAMB16_S9
		port map (
			DO => drd47,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en47,
			SSR => '0',
			WE => we
		);

	myBram48 : RAMB16_S9
		port map (
			DO => drd48,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en48,
			SSR => '0',
			WE => we
		);

	myBram49 : RAMB16_S9
		port map (
			DO => drd49,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en49,
			SSR => '0',
			WE => we
		);

	myBram5 : RAMB16_S9
		port map (
			DO => drd5,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en5,
			SSR => '0',
			WE => we
		);

	myBram50 : RAMB16_S9
		port map (
			DO => drd50,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en50,
			SSR => '0',
			WE => we
		);

	myBram51 : RAMB16_S9
		port map (
			DO => drd51,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en51,
			SSR => '0',
			WE => we
		);

	myBram52 : RAMB16_S9
		port map (
			DO => drd52,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en52,
			SSR => '0',
			WE => we
		);

	myBram53 : RAMB16_S9
		port map (
			DO => drd53,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en53,
			SSR => '0',
			WE => we
		);

	myBram54 : RAMB16_S9
		port map (
			DO => drd54,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en54,
			SSR => '0',
			WE => we
		);

	myBram55 : RAMB16_S9
		port map (
			DO => drd55,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en55,
			SSR => '0',
			WE => we
		);

	myBram56 : RAMB16_S9
		port map (
			DO => drd56,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en56,
			SSR => '0',
			WE => we
		);

	myBram57 : RAMB16_S9
		port map (
			DO => drd57,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en57,
			SSR => '0',
			WE => we
		);

	myBram58 : RAMB16_S9
		port map (
			DO => drd58,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en58,
			SSR => '0',
			WE => we
		);

	myBram59 : RAMB16_S9
		port map (
			DO => drd59,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en59,
			SSR => '0',
			WE => we
		);

	myBram6 : RAMB16_S9
		port map (
			DO => drd6,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en6,
			SSR => '0',
			WE => we
		);

	myBram60 : RAMB16_S9
		port map (
			DO => drd60,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en60,
			SSR => '0',
			WE => we
		);

	myBram61 : RAMB16_S9
		port map (
			DO => drd61,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en61,
			SSR => '0',
			WE => we
		);

	myBram62 : RAMB16_S9
		port map (
			DO => drd62,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en62,
			SSR => '0',
			WE => we
		);

	myBram63 : RAMB16_S9
		port map (
			DO => drd63,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en63,
			SSR => '0',
			WE => we
		);

	myBram64 : RAMB16_S9
		port map (
			DO => drd64,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en64,
			SSR => '0',
			WE => we
		);

	myBram65 : RAMB16_S9
		port map (
			DO => drd65,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en65,
			SSR => '0',
			WE => we
		);

	myBram66 : RAMB16_S9
		port map (
			DO => drd66,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en66,
			SSR => '0',
			WE => we
		);

	myBram67 : RAMB16_S9
		port map (
			DO => drd67,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en67,
			SSR => '0',
			WE => we
		);

	myBram68 : RAMB16_S9
		port map (
			DO => drd68,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en68,
			SSR => '0',
			WE => we
		);

	myBram69 : RAMB16_S9
		port map (
			DO => drd69,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en69,
			SSR => '0',
			WE => we
		);

	myBram7 : RAMB16_S9
		port map (
			DO => drd7,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en7,
			SSR => '0',
			WE => we
		);

	myBram70 : RAMB16_S9
		port map (
			DO => drd70,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en70,
			SSR => '0',
			WE => we
		);

	myBram71 : RAMB16_S9
		port map (
			DO => drd71,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en71,
			SSR => '0',
			WE => we
		);

	myBram72 : RAMB16_S9
		port map (
			DO => drd72,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en72,
			SSR => '0',
			WE => we
		);

	myBram73 : RAMB16_S9
		port map (
			DO => drd73,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en73,
			SSR => '0',
			WE => we
		);

	myBram74 : RAMB16_S9
		port map (
			DO => drd74,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en74,
			SSR => '0',
			WE => we
		);

	myBram75 : RAMB16_S9
		port map (
			DO => drd75,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en75,
			SSR => '0',
			WE => we
		);

	myBram76 : RAMB16_S9
		port map (
			DO => drd76,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en76,
			SSR => '0',
			WE => we
		);

	myBram77 : RAMB16_S9
		port map (
			DO => drd77,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en77,
			SSR => '0',
			WE => we
		);

	myBram78 : RAMB16_S9
		port map (
			DO => drd78,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en78,
			SSR => '0',
			WE => we
		);

	myBram79 : RAMB16_S9
		port map (
			DO => drd79,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en79,
			SSR => '0',
			WE => we
		);

	myBram8 : RAMB16_S9
		port map (
			DO => drd8,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en8,
			SSR => '0',
			WE => we
		);

	myBram80 : RAMB16_S9
		port map (
			DO => drd80,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en80,
			SSR => '0',
			WE => we
		);

	myBram81 : RAMB16_S9
		port map (
			DO => drd81,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en81,
			SSR => '0',
			WE => we
		);

	myBram82 : RAMB16_S9
		port map (
			DO => drd82,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en82,
			SSR => '0',
			WE => we
		);

	myBram83 : RAMB16_S9
		port map (
			DO => drd83,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en83,
			SSR => '0',
			WE => we
		);

	myBram84 : RAMB16_S9
		port map (
			DO => drd84,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en84,
			SSR => '0',
			WE => we
		);

	myBram85 : RAMB16_S9
		port map (
			DO => drd85,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en85,
			SSR => '0',
			WE => we
		);

	myBram86 : RAMB16_S9
		port map (
			DO => drd86,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en86,
			SSR => '0',
			WE => we
		);

	myBram87 : RAMB16_S9
		port map (
			DO => drd87,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en87,
			SSR => '0',
			WE => we
		);

	myBram88 : RAMB16_S9
		port map (
			DO => drd88,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en88,
			SSR => '0',
			WE => we
		);

	myBram89 : RAMB16_S9
		port map (
			DO => drd89,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en89,
			SSR => '0',
			WE => we
		);

	myBram9 : RAMB16_S9
		port map (
			DO => drd9,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en9,
			SSR => '0',
			WE => we
		);

	myBram90 : RAMB16_S9
		port map (
			DO => drd90,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en90,
			SSR => '0',
			WE => we
		);

	myBram91 : RAMB16_S9
		port map (
			DO => drd91,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en91,
			SSR => '0',
			WE => we
		);

	myBram92 : RAMB16_S9
		port map (
			DO => drd92,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en92,
			SSR => '0',
			WE => we
		);

	myBram93 : RAMB16_S9
		port map (
			DO => drd93,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en93,
			SSR => '0',
			WE => we
		);

	myBram94 : RAMB16_S9
		port map (
			DO => drd94,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en94,
			SSR => '0',
			WE => we
		);

	myBram95 : RAMB16_S9
		port map (
			DO => drd95,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en95,
			SSR => '0',
			WE => we
		);

	myBram96 : RAMB16_S9
		port map (
			DO => drd96,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en96,
			SSR => '0',
			WE => we
		);

	myBram97 : RAMB16_S9
		port map (
			DO => drd97,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en97,
			SSR => '0',
			WE => we
		);

	myBram98 : RAMB16_S9
		port map (
			DO => drd98,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en98,
			SSR => '0',
			WE => we
		);

	myBram99 : RAMB16_S9
		port map (
			DO => drd99,
			DOP => open,
			ADDR => a(10 downto 0),
			CLK => clk,
			DI => dwr,
			DIP => "0",
			EN => en99,
			SSR => '0',
			WE => we
		);

	-- IP impl --- BEGIN
	------------------------------------------------------------------------
	-- implementation
	------------------------------------------------------------------------

	en0 <= '1' when (a(18 downto 11)=x"00" and en='1') else '0';
	en1 <= '1' when (a(18 downto 11)=x"01" and en='1') else '0';
	en2 <= '1' when (a(18 downto 11)=x"02" and en='1') else '0';
	en3 <= '1' when (a(18 downto 11)=x"03" and en='1') else '0';
	en4 <= '1' when (a(18 downto 11)=x"04" and en='1') else '0';
	en5 <= '1' when (a(18 downto 11)=x"05" and en='1') else '0';
	en6 <= '1' when (a(18 downto 11)=x"06" and en='1') else '0';
	en7 <= '1' when (a(18 downto 11)=x"07" and en='1') else '0';
	en8 <= '1' when (a(18 downto 11)=x"08" and en='1') else '0';
	en9 <= '1' when (a(18 downto 11)=x"09" and en='1') else '0';
	en10 <= '1' when (a(18 downto 11)=x"0A" and en='1') else '0';
	en11 <= '1' when (a(18 downto 11)=x"0B" and en='1') else '0';
	en12 <= '1' when (a(18 downto 11)=x"0C" and en='1') else '0';
	en13 <= '1' when (a(18 downto 11)=x"0D" and en='1') else '0';
	en14 <= '1' when (a(18 downto 11)=x"0E" and en='1') else '0';
	en15 <= '1' when (a(18 downto 11)=x"0F" and en='1') else '0';
	en16 <= '1' when (a(18 downto 11)=x"10" and en='1') else '0';
	en17 <= '1' when (a(18 downto 11)=x"11" and en='1') else '0';
	en18 <= '1' when (a(18 downto 11)=x"12" and en='1') else '0';
	en19 <= '1' when (a(18 downto 11)=x"13" and en='1') else '0';
	en20 <= '1' when (a(18 downto 11)=x"14" and en='1') else '0';
	en21 <= '1' when (a(18 downto 11)=x"15" and en='1') else '0';
	en22 <= '1' when (a(18 downto 11)=x"16" and en='1') else '0';
	en23 <= '1' when (a(18 downto 11)=x"17" and en='1') else '0';
	en24 <= '1' when (a(18 downto 11)=x"18" and en='1') else '0';
	en25 <= '1' when (a(18 downto 11)=x"19" and en='1') else '0';
	en26 <= '1' when (a(18 downto 11)=x"1A" and en='1') else '0';
	en27 <= '1' when (a(18 downto 11)=x"1B" and en='1') else '0';
	en28 <= '1' when (a(18 downto 11)=x"1C" and en='1') else '0';
	en29 <= '1' when (a(18 downto 11)=x"1D" and en='1') else '0';
	en30 <= '1' when (a(18 downto 11)=x"1E" and en='1') else '0';
	en31 <= '1' when (a(18 downto 11)=x"1F" and en='1') else '0';
	en32 <= '1' when (a(18 downto 11)=x"20" and en='1') else '0';
	en33 <= '1' when (a(18 downto 11)=x"21" and en='1') else '0';
	en34 <= '1' when (a(18 downto 11)=x"22" and en='1') else '0';
	en35 <= '1' when (a(18 downto 11)=x"23" and en='1') else '0';
	en36 <= '1' when (a(18 downto 11)=x"24" and en='1') else '0';
	en37 <= '1' when (a(18 downto 11)=x"25" and en='1') else '0';
	en38 <= '1' when (a(18 downto 11)=x"26" and en='1') else '0';
	en39 <= '1' when (a(18 downto 11)=x"27" and en='1') else '0';
	en40 <= '1' when (a(18 downto 11)=x"28" and en='1') else '0';
	en41 <= '1' when (a(18 downto 11)=x"29" and en='1') else '0';
	en42 <= '1' when (a(18 downto 11)=x"2A" and en='1') else '0';
	en43 <= '1' when (a(18 downto 11)=x"2B" and en='1') else '0';
	en44 <= '1' when (a(18 downto 11)=x"2C" and en='1') else '0';
	en45 <= '1' when (a(18 downto 11)=x"2D" and en='1') else '0';
	en46 <= '1' when (a(18 downto 11)=x"2E" and en='1') else '0';
	en47 <= '1' when (a(18 downto 11)=x"2F" and en='1') else '0';
	en48 <= '1' when (a(18 downto 11)=x"30" and en='1') else '0';
	en49 <= '1' when (a(18 downto 11)=x"31" and en='1') else '0';
	en50 <= '1' when (a(18 downto 11)=x"32" and en='1') else '0';
	en51 <= '1' when (a(18 downto 11)=x"33" and en='1') else '0';
	en52 <= '1' when (a(18 downto 11)=x"34" and en='1') else '0';
	en53 <= '1' when (a(18 downto 11)=x"35" and en='1') else '0';
	en54 <= '1' when (a(18 downto 11)=x"36" and en='1') else '0';
	en55 <= '1' when (a(18 downto 11)=x"37" and en='1') else '0';
	en56 <= '1' when (a(18 downto 11)=x"38" and en='1') else '0';
	en57 <= '1' when (a(18 downto 11)=x"39" and en='1') else '0';
	en58 <= '1' when (a(18 downto 11)=x"3A" and en='1') else '0';
	en59 <= '1' when (a(18 downto 11)=x"3B" and en='1') else '0';
	en60 <= '1' when (a(18 downto 11)=x"3C" and en='1') else '0';
	en61 <= '1' when (a(18 downto 11)=x"3D" and en='1') else '0';
	en62 <= '1' when (a(18 downto 11)=x"3E" and en='1') else '0';
	en63 <= '1' when (a(18 downto 11)=x"3F" and en='1') else '0';
	en64 <= '1' when (a(18 downto 11)=x"40" and en='1') else '0';
	en65 <= '1' when (a(18 downto 11)=x"41" and en='1') else '0';
	en66 <= '1' when (a(18 downto 11)=x"42" and en='1') else '0';
	en67 <= '1' when (a(18 downto 11)=x"43" and en='1') else '0';
	en68 <= '1' when (a(18 downto 11)=x"44" and en='1') else '0';
	en69 <= '1' when (a(18 downto 11)=x"45" and en='1') else '0';
	en70 <= '1' when (a(18 downto 11)=x"46" and en='1') else '0';
	en71 <= '1' when (a(18 downto 11)=x"47" and en='1') else '0';
	en72 <= '1' when (a(18 downto 11)=x"48" and en='1') else '0';
	en73 <= '1' when (a(18 downto 11)=x"49" and en='1') else '0';
	en74 <= '1' when (a(18 downto 11)=x"4A" and en='1') else '0';
	en75 <= '1' when (a(18 downto 11)=x"4B" and en='1') else '0';
	en76 <= '1' when (a(18 downto 11)=x"4C" and en='1') else '0';
	en77 <= '1' when (a(18 downto 11)=x"4D" and en='1') else '0';
	en78 <= '1' when (a(18 downto 11)=x"4E" and en='1') else '0';
	en79 <= '1' when (a(18 downto 11)=x"4F" and en='1') else '0';
	en80 <= '1' when (a(18 downto 11)=x"50" and en='1') else '0';
	en81 <= '1' when (a(18 downto 11)=x"51" and en='1') else '0';
	en82 <= '1' when (a(18 downto 11)=x"52" and en='1') else '0';
	en83 <= '1' when (a(18 downto 11)=x"53" and en='1') else '0';
	en84 <= '1' when (a(18 downto 11)=x"54" and en='1') else '0';
	en85 <= '1' when (a(18 downto 11)=x"55" and en='1') else '0';
	en86 <= '1' when (a(18 downto 11)=x"56" and en='1') else '0';
	en87 <= '1' when (a(18 downto 11)=x"57" and en='1') else '0';
	en88 <= '1' when (a(18 downto 11)=x"58" and en='1') else '0';
	en89 <= '1' when (a(18 downto 11)=x"59" and en='1') else '0';
	en90 <= '1' when (a(18 downto 11)=x"5A" and en='1') else '0';
	en91 <= '1' when (a(18 downto 11)=x"5B" and en='1') else '0';
	en92 <= '1' when (a(18 downto 11)=x"5C" and en='1') else '0';
	en93 <= '1' when (a(18 downto 11)=x"5D" and en='1') else '0';
	en94 <= '1' when (a(18 downto 11)=x"5E" and en='1') else '0';
	en95 <= '1' when (a(18 downto 11)=x"5F" and en='1') else '0';
	en96 <= '1' when (a(18 downto 11)=x"60" and en='1') else '0';
	en97 <= '1' when (a(18 downto 11)=x"61" and en='1') else '0';
	en98 <= '1' when (a(18 downto 11)=x"62" and en='1') else '0';
	en99 <= '1' when (a(18 downto 11)=x"63" and en='1') else '0';
	en100 <= '1' when (a(18 downto 11)=x"64" and en='1') else '0';
	en101 <= '1' when (a(18 downto 11)=x"65" and en='1') else '0';
	en102 <= '1' when (a(18 downto 11)=x"66" and en='1') else '0';
	en103 <= '1' when (a(18 downto 11)=x"67" and en='1') else '0';
	en104 <= '1' when (a(18 downto 11)=x"68" and en='1') else '0';
	en105 <= '1' when (a(18 downto 11)=x"69" and en='1') else '0';
	en106 <= '1' when (a(18 downto 11)=x"6A" and en='1') else '0';
	en107 <= '1' when (a(18 downto 11)=x"6B" and en='1') else '0';
	en108 <= '1' when (a(18 downto 11)=x"6C" and en='1') else '0';
	en109 <= '1' when (a(18 downto 11)=x"6D" and en='1') else '0';
	en110 <= '1' when (a(18 downto 11)=x"6E" and en='1') else '0';
	en111 <= '1' when (a(18 downto 11)=x"6F" and en='1') else '0';
	en112 <= '1' when (a(18 downto 11)=x"70" and en='1') else '0';
	en113 <= '1' when (a(18 downto 11)=x"71" and en='1') else '0';
	en114 <= '1' when (a(18 downto 11)=x"72" and en='1') else '0';
	en115 <= '1' when (a(18 downto 11)=x"73" and en='1') else '0';
	en116 <= '1' when (a(18 downto 11)=x"74" and en='1') else '0';
	en117 <= '1' when (a(18 downto 11)=x"75" and en='1') else '0';
	en118 <= '1' when (a(18 downto 11)=x"76" and en='1') else '0';
	en119 <= '1' when (a(18 downto 11)=x"77" and en='1') else '0';
	en120 <= '1' when (a(18 downto 11)=x"78" and en='1') else '0';
	en121 <= '1' when (a(18 downto 11)=x"79" and en='1') else '0';
	en122 <= '1' when (a(18 downto 11)=x"7A" and en='1') else '0';
	en123 <= '1' when (a(18 downto 11)=x"7B" and en='1') else '0';
	en124 <= '1' when (a(18 downto 11)=x"7C" and en='1') else '0';
	en125 <= '1' when (a(18 downto 11)=x"7D" and en='1') else '0';
	en126 <= '1' when (a(18 downto 11)=x"7E" and en='1') else '0';
	en127 <= '1' when (a(18 downto 11)=x"7F" and en='1') else '0';
	en128 <= '1' when (a(18 downto 11)=x"80" and en='1') else '0';
	en129 <= '1' when (a(18 downto 11)=x"81" and en='1') else '0';
	en130 <= '1' when (a(18 downto 11)=x"82" and en='1') else '0';
	en131 <= '1' when (a(18 downto 11)=x"83" and en='1') else '0';
	en132 <= '1' when (a(18 downto 11)=x"84" and en='1') else '0';
	en133 <= '1' when (a(18 downto 11)=x"85" and en='1') else '0';
	en134 <= '1' when (a(18 downto 11)=x"86" and en='1') else '0';
	en135 <= '1' when (a(18 downto 11)=x"87" and en='1') else '0';
	en136 <= '1' when (a(18 downto 11)=x"88" and en='1') else '0';
	en137 <= '1' when (a(18 downto 11)=x"89" and en='1') else '0';
	en138 <= '1' when (a(18 downto 11)=x"8A" and en='1') else '0';
	en139 <= '1' when (a(18 downto 11)=x"8B" and en='1') else '0';
	en140 <= '1' when (a(18 downto 11)=x"8C" and en='1') else '0';
	en141 <= '1' when (a(18 downto 11)=x"8D" and en='1') else '0';
	en142 <= '1' when (a(18 downto 11)=x"8E" and en='1') else '0';
	en143 <= '1' when (a(18 downto 11)=x"8F" and en='1') else '0';
	en144 <= '1' when (a(18 downto 11)=x"90" and en='1') else '0';
	en145 <= '1' when (a(18 downto 11)=x"91" and en='1') else '0';
	en146 <= '1' when (a(18 downto 11)=x"92" and en='1') else '0';
	en147 <= '1' when (a(18 downto 11)=x"93" and en='1') else '0';
	en148 <= '1' when (a(18 downto 11)=x"94" and en='1') else '0';
	en149 <= '1' when (a(18 downto 11)=x"95" and en='1') else '0';
	en150 <= '1' when (a(18 downto 11)=x"96" and en='1') else '0';
	en151 <= '1' when (a(18 downto 11)=x"97" and en='1') else '0';
	en152 <= '1' when (a(18 downto 11)=x"98" and en='1') else '0';
	en153 <= '1' when (a(18 downto 11)=x"99" and en='1') else '0';
	en154 <= '1' when (a(18 downto 11)=x"9A" and en='1') else '0';
	en155 <= '1' when (a(18 downto 11)=x"9B" and en='1') else '0';
	en156 <= '1' when (a(18 downto 11)=x"9C" and en='1') else '0';
	en157 <= '1' when (a(18 downto 11)=x"9D" and en='1') else '0';
	en158 <= '1' when (a(18 downto 11)=x"9E" and en='1') else '0';
	en159 <= '1' when (a(18 downto 11)=x"9F" and en='1') else '0';
	en160 <= '1' when (a(18 downto 11)=x"A0" and en='1') else '0';
	en161 <= '1' when (a(18 downto 11)=x"A1" and en='1') else '0';
	en162 <= '1' when (a(18 downto 11)=x"A2" and en='1') else '0';
	en163 <= '1' when (a(18 downto 11)=x"A3" and en='1') else '0';
	en164 <= '1' when (a(18 downto 11)=x"A4" and en='1') else '0';
	en165 <= '1' when (a(18 downto 11)=x"A5" and en='1') else '0';
	en166 <= '1' when (a(18 downto 11)=x"A6" and en='1') else '0';
	en167 <= '1' when (a(18 downto 11)=x"A7" and en='1') else '0';
	en168 <= '1' when (a(18 downto 11)=x"A8" and en='1') else '0';
	en169 <= '1' when (a(18 downto 11)=x"A9" and en='1') else '0';
	en170 <= '1' when (a(18 downto 11)=x"AA" and en='1') else '0';
	en171 <= '1' when (a(18 downto 11)=x"AB" and en='1') else '0';
	en172 <= '1' when (a(18 downto 11)=x"AC" and en='1') else '0';
	en173 <= '1' when (a(18 downto 11)=x"AD" and en='1') else '0';
	en174 <= '1' when (a(18 downto 11)=x"AE" and en='1') else '0';
	en175 <= '1' when (a(18 downto 11)=x"AF" and en='1') else '0';
	en176 <= '1' when (a(18 downto 11)=x"B0" and en='1') else '0';
	en177 <= '1' when (a(18 downto 11)=x"B1" and en='1') else '0';
	en178 <= '1' when (a(18 downto 11)=x"B2" and en='1') else '0';
	en179 <= '1' when (a(18 downto 11)=x"B3" and en='1') else '0';
	en180 <= '1' when (a(18 downto 11)=x"B4" and en='1') else '0';
	en181 <= '1' when (a(18 downto 11)=x"B5" and en='1') else '0';
	en182 <= '1' when (a(18 downto 11)=x"B6" and en='1') else '0';
	en183 <= '1' when (a(18 downto 11)=x"B7" and en='1') else '0';
	en184 <= '1' when (a(18 downto 11)=x"B8" and en='1') else '0';
	en185 <= '1' when (a(18 downto 11)=x"B9" and en='1') else '0';
	en186 <= '1' when (a(18 downto 11)=x"BA" and en='1') else '0';
	en187 <= '1' when (a(18 downto 11)=x"BB" and en='1') else '0';
	en188 <= '1' when (a(18 downto 11)=x"BC" and en='1') else '0';
	en189 <= '1' when (a(18 downto 11)=x"BD" and en='1') else '0';
	en190 <= '1' when (a(18 downto 11)=x"BE" and en='1') else '0';
	en191 <= '1' when (a(18 downto 11)=x"BF" and en='1') else '0';
	en192 <= '1' when (a(18 downto 11)=x"C0" and en='1') else '0';
	en193 <= '1' when (a(18 downto 11)=x"C1" and en='1') else '0';
	en194 <= '1' when (a(18 downto 11)=x"C2" and en='1') else '0';
	en195 <= '1' when (a(18 downto 11)=x"C3" and en='1') else '0';
	en196 <= '1' when (a(18 downto 11)=x"C4" and en='1') else '0';
	en197 <= '1' when (a(18 downto 11)=x"C5" and en='1') else '0';
	en198 <= '1' when (a(18 downto 11)=x"C6" and en='1') else '0';
	en199 <= '1' when (a(18 downto 11)=x"C7" and en='1') else '0';
	en200 <= '1' when (a(18 downto 11)=x"C8" and en='1') else '0';
	en201 <= '1' when (a(18 downto 11)=x"C9" and en='1') else '0';
	en202 <= '1' when (a(18 downto 11)=x"CA" and en='1') else '0';
	en203 <= '1' when (a(18 downto 11)=x"CB" and en='1') else '0';
	en204 <= '1' when (a(18 downto 11)=x"CC" and en='1') else '0';
	en205 <= '1' when (a(18 downto 11)=x"CD" and en='1') else '0';
	en206 <= '1' when (a(18 downto 11)=x"CE" and en='1') else '0';
	en207 <= '1' when (a(18 downto 11)=x"CF" and en='1') else '0';
	en208 <= '1' when (a(18 downto 11)=x"D0" and en='1') else '0';
	en209 <= '1' when (a(18 downto 11)=x"D1" and en='1') else '0';
	en210 <= '1' when (a(18 downto 11)=x"D2" and en='1') else '0';
	en211 <= '1' when (a(18 downto 11)=x"D3" and en='1') else '0';
	en212 <= '1' when (a(18 downto 11)=x"D4" and en='1') else '0';
	en213 <= '1' when (a(18 downto 11)=x"D5" and en='1') else '0';
	en214 <= '1' when (a(18 downto 11)=x"D6" and en='1') else '0';
	en215 <= '1' when (a(18 downto 11)=x"D7" and en='1') else '0';
	en216 <= '1' when (a(18 downto 11)=x"D8" and en='1') else '0';
	en217 <= '1' when (a(18 downto 11)=x"D9" and en='1') else '0';
	en218 <= '1' when (a(18 downto 11)=x"DA" and en='1') else '0';
	en219 <= '1' when (a(18 downto 11)=x"DB" and en='1') else '0';
	en220 <= '1' when (a(18 downto 11)=x"DC" and en='1') else '0';
	en221 <= '1' when (a(18 downto 11)=x"DD" and en='1') else '0';
	en222 <= '1' when (a(18 downto 11)=x"DE" and en='1') else '0';
	en223 <= '1' when (a(18 downto 11)=x"DF" and en='1') else '0';
	en224 <= '1' when (a(18 downto 11)=x"E0" and en='1') else '0';
	en225 <= '1' when (a(18 downto 11)=x"E1" and en='1') else '0';
	en226 <= '1' when (a(18 downto 11)=x"E2" and en='1') else '0';
	en227 <= '1' when (a(18 downto 11)=x"E3" and en='1') else '0';
	en228 <= '1' when (a(18 downto 11)=x"E4" and en='1') else '0';
	en229 <= '1' when (a(18 downto 11)=x"E5" and en='1') else '0';
	en230 <= '1' when (a(18 downto 11)=x"E6" and en='1') else '0';
	en231 <= '1' when (a(18 downto 11)=x"E7" and en='1') else '0';
	en232 <= '1' when (a(18 downto 11)=x"E8" and en='1') else '0';
	en233 <= '1' when (a(18 downto 11)=x"E9" and en='1') else '0';
	en234 <= '1' when (a(18 downto 11)=x"EA" and en='1') else '0';
	en235 <= '1' when (a(18 downto 11)=x"EB" and en='1') else '0';
	en236 <= '1' when (a(18 downto 11)=x"EC" and en='1') else '0';
	en237 <= '1' when (a(18 downto 11)=x"ED" and en='1') else '0';
	en238 <= '1' when (a(18 downto 11)=x"EE" and en='1') else '0';
	en239 <= '1' when (a(18 downto 11)=x"EF" and en='1') else '0';

	drd <= drd0 when a(18 downto 11)=x"00"
		else drd1 when a(18 downto 11)=x"01"
		else drd2 when a(18 downto 11)=x"02"
		else drd3 when a(18 downto 11)=x"03"
		else drd4 when a(18 downto 11)=x"04"
		else drd5 when a(18 downto 11)=x"05"
		else drd6 when a(18 downto 11)=x"06"
		else drd7 when a(18 downto 11)=x"07"
		else drd8 when a(18 downto 11)=x"08"
		else drd9 when a(18 downto 11)=x"09"
		else drd10 when a(18 downto 11)=x"0A"
		else drd11 when a(18 downto 11)=x"0B"
		else drd12 when a(18 downto 11)=x"0C"
		else drd13 when a(18 downto 11)=x"0D"
		else drd14 when a(18 downto 11)=x"0E"
		else drd15 when a(18 downto 11)=x"0F"
		else drd16 when a(18 downto 11)=x"10"
		else drd17 when a(18 downto 11)=x"11"
		else drd18 when a(18 downto 11)=x"12"
		else drd19 when a(18 downto 11)=x"13"
		else drd20 when a(18 downto 11)=x"14"
		else drd21 when a(18 downto 11)=x"15"
		else drd22 when a(18 downto 11)=x"16"
		else drd23 when a(18 downto 11)=x"17"
		else drd24 when a(18 downto 11)=x"18"
		else drd25 when a(18 downto 11)=x"19"
		else drd26 when a(18 downto 11)=x"1A"
		else drd27 when a(18 downto 11)=x"1B"
		else drd28 when a(18 downto 11)=x"1C"
		else drd29 when a(18 downto 11)=x"1D"
		else drd30 when a(18 downto 11)=x"1E"
		else drd31 when a(18 downto 11)=x"1F"
		else drd32 when a(18 downto 11)=x"20"
		else drd33 when a(18 downto 11)=x"21"
		else drd34 when a(18 downto 11)=x"22"
		else drd35 when a(18 downto 11)=x"23"
		else drd36 when a(18 downto 11)=x"24"
		else drd37 when a(18 downto 11)=x"25"
		else drd38 when a(18 downto 11)=x"26"
		else drd39 when a(18 downto 11)=x"27"
		else drd40 when a(18 downto 11)=x"28"
		else drd41 when a(18 downto 11)=x"29"
		else drd42 when a(18 downto 11)=x"2A"
		else drd43 when a(18 downto 11)=x"2B"
		else drd44 when a(18 downto 11)=x"2C"
		else drd45 when a(18 downto 11)=x"2D"
		else drd46 when a(18 downto 11)=x"2E"
		else drd47 when a(18 downto 11)=x"2F"
		else drd48 when a(18 downto 11)=x"30"
		else drd49 when a(18 downto 11)=x"31"
		else drd50 when a(18 downto 11)=x"32"
		else drd51 when a(18 downto 11)=x"33"
		else drd52 when a(18 downto 11)=x"34"
		else drd53 when a(18 downto 11)=x"35"
		else drd54 when a(18 downto 11)=x"36"
		else drd55 when a(18 downto 11)=x"37"
		else drd56 when a(18 downto 11)=x"38"
		else drd57 when a(18 downto 11)=x"39"
		else drd58 when a(18 downto 11)=x"3A"
		else drd59 when a(18 downto 11)=x"3B"
		else drd60 when a(18 downto 11)=x"3C"
		else drd61 when a(18 downto 11)=x"3D"
		else drd62 when a(18 downto 11)=x"3E"
		else drd63 when a(18 downto 11)=x"3F"
		else drd64 when a(18 downto 11)=x"40"
		else drd65 when a(18 downto 11)=x"41"
		else drd66 when a(18 downto 11)=x"42"
		else drd67 when a(18 downto 11)=x"43"
		else drd68 when a(18 downto 11)=x"44"
		else drd69 when a(18 downto 11)=x"45"
		else drd70 when a(18 downto 11)=x"46"
		else drd71 when a(18 downto 11)=x"47"
		else drd72 when a(18 downto 11)=x"48"
		else drd73 when a(18 downto 11)=x"49"
		else drd74 when a(18 downto 11)=x"4A"
		else drd75 when a(18 downto 11)=x"4B"
		else drd76 when a(18 downto 11)=x"4C"
		else drd77 when a(18 downto 11)=x"4D"
		else drd78 when a(18 downto 11)=x"4E"
		else drd79 when a(18 downto 11)=x"4F"
		else drd80 when a(18 downto 11)=x"50"
		else drd81 when a(18 downto 11)=x"51"
		else drd82 when a(18 downto 11)=x"52"
		else drd83 when a(18 downto 11)=x"53"
		else drd84 when a(18 downto 11)=x"54"
		else drd85 when a(18 downto 11)=x"55"
		else drd86 when a(18 downto 11)=x"56"
		else drd87 when a(18 downto 11)=x"57"
		else drd88 when a(18 downto 11)=x"58"
		else drd89 when a(18 downto 11)=x"59"
		else drd90 when a(18 downto 11)=x"5A"
		else drd91 when a(18 downto 11)=x"5B"
		else drd92 when a(18 downto 11)=x"5C"
		else drd93 when a(18 downto 11)=x"5D"
		else drd94 when a(18 downto 11)=x"5E"
		else drd95 when a(18 downto 11)=x"5F"
		else drd96 when a(18 downto 11)=x"60"
		else drd97 when a(18 downto 11)=x"61"
		else drd98 when a(18 downto 11)=x"62"
		else drd99 when a(18 downto 11)=x"63"
		else drd100 when a(18 downto 11)=x"64"
		else drd101 when a(18 downto 11)=x"65"
		else drd102 when a(18 downto 11)=x"66"
		else drd103 when a(18 downto 11)=x"67"
		else drd104 when a(18 downto 11)=x"68"
		else drd105 when a(18 downto 11)=x"69"
		else drd106 when a(18 downto 11)=x"6A"
		else drd107 when a(18 downto 11)=x"6B"
		else drd108 when a(18 downto 11)=x"6C"
		else drd109 when a(18 downto 11)=x"6D"
		else drd110 when a(18 downto 11)=x"6E"
		else drd111 when a(18 downto 11)=x"6F"
		else drd112 when a(18 downto 11)=x"70"
		else drd113 when a(18 downto 11)=x"71"
		else drd114 when a(18 downto 11)=x"72"
		else drd115 when a(18 downto 11)=x"73"
		else drd116 when a(18 downto 11)=x"74"
		else drd117 when a(18 downto 11)=x"75"
		else drd118 when a(18 downto 11)=x"76"
		else drd119 when a(18 downto 11)=x"77"
		else drd120 when a(18 downto 11)=x"78"
		else drd121 when a(18 downto 11)=x"79"
		else drd122 when a(18 downto 11)=x"7A"
		else drd123 when a(18 downto 11)=x"7B"
		else drd124 when a(18 downto 11)=x"7C"
		else drd125 when a(18 downto 11)=x"7D"
		else drd126 when a(18 downto 11)=x"7E"
		else drd127 when a(18 downto 11)=x"7F"
		else drd128 when a(18 downto 11)=x"80"
		else drd129 when a(18 downto 11)=x"81"
		else drd130 when a(18 downto 11)=x"82"
		else drd131 when a(18 downto 11)=x"83"
		else drd132 when a(18 downto 11)=x"84"
		else drd133 when a(18 downto 11)=x"85"
		else drd134 when a(18 downto 11)=x"86"
		else drd135 when a(18 downto 11)=x"87"
		else drd136 when a(18 downto 11)=x"88"
		else drd137 when a(18 downto 11)=x"89"
		else drd138 when a(18 downto 11)=x"8A"
		else drd139 when a(18 downto 11)=x"8B"
		else drd140 when a(18 downto 11)=x"8C"
		else drd141 when a(18 downto 11)=x"8D"
		else drd142 when a(18 downto 11)=x"8E"
		else drd143 when a(18 downto 11)=x"8F"
		else drd144 when a(18 downto 11)=x"90"
		else drd145 when a(18 downto 11)=x"91"
		else drd146 when a(18 downto 11)=x"92"
		else drd147 when a(18 downto 11)=x"93"
		else drd148 when a(18 downto 11)=x"94"
		else drd149 when a(18 downto 11)=x"95"
		else drd150 when a(18 downto 11)=x"96"
		else drd151 when a(18 downto 11)=x"97"
		else drd152 when a(18 downto 11)=x"98"
		else drd153 when a(18 downto 11)=x"99"
		else drd154 when a(18 downto 11)=x"9A"
		else drd155 when a(18 downto 11)=x"9B"
		else drd156 when a(18 downto 11)=x"9C"
		else drd157 when a(18 downto 11)=x"9D"
		else drd158 when a(18 downto 11)=x"9E"
		else drd159 when a(18 downto 11)=x"9F"
		else drd160 when a(18 downto 11)=x"A0"
		else drd161 when a(18 downto 11)=x"A1"
		else drd162 when a(18 downto 11)=x"A2"
		else drd163 when a(18 downto 11)=x"A3"
		else drd164 when a(18 downto 11)=x"A4"
		else drd165 when a(18 downto 11)=x"A5"
		else drd166 when a(18 downto 11)=x"A6"
		else drd167 when a(18 downto 11)=x"A7"
		else drd168 when a(18 downto 11)=x"A8"
		else drd169 when a(18 downto 11)=x"A9"
		else drd170 when a(18 downto 11)=x"AA"
		else drd171 when a(18 downto 11)=x"AB"
		else drd172 when a(18 downto 11)=x"AC"
		else drd173 when a(18 downto 11)=x"AD"
		else drd174 when a(18 downto 11)=x"AE"
		else drd175 when a(18 downto 11)=x"AF"
		else drd176 when a(18 downto 11)=x"B0"
		else drd177 when a(18 downto 11)=x"B1"
		else drd178 when a(18 downto 11)=x"B2"
		else drd179 when a(18 downto 11)=x"B3"
		else drd180 when a(18 downto 11)=x"B4"
		else drd181 when a(18 downto 11)=x"B5"
		else drd182 when a(18 downto 11)=x"B6"
		else drd183 when a(18 downto 11)=x"B7"
		else drd184 when a(18 downto 11)=x"B8"
		else drd185 when a(18 downto 11)=x"B9"
		else drd186 when a(18 downto 11)=x"BA"
		else drd187 when a(18 downto 11)=x"BB"
		else drd188 when a(18 downto 11)=x"BC"
		else drd189 when a(18 downto 11)=x"BD"
		else drd190 when a(18 downto 11)=x"BE"
		else drd191 when a(18 downto 11)=x"BF"
		else drd192 when a(18 downto 11)=x"C0"
		else drd193 when a(18 downto 11)=x"C1"
		else drd194 when a(18 downto 11)=x"C2"
		else drd195 when a(18 downto 11)=x"C3"
		else drd196 when a(18 downto 11)=x"C4"
		else drd197 when a(18 downto 11)=x"C5"
		else drd198 when a(18 downto 11)=x"C6"
		else drd199 when a(18 downto 11)=x"C7"
		else drd200 when a(18 downto 11)=x"C8"
		else drd201 when a(18 downto 11)=x"C9"
		else drd202 when a(18 downto 11)=x"CA"
		else drd203 when a(18 downto 11)=x"CB"
		else drd204 when a(18 downto 11)=x"CC"
		else drd205 when a(18 downto 11)=x"CD"
		else drd206 when a(18 downto 11)=x"CE"
		else drd207 when a(18 downto 11)=x"CF"
		else drd208 when a(18 downto 11)=x"D0"
		else drd209 when a(18 downto 11)=x"D1"
		else drd210 when a(18 downto 11)=x"D2"
		else drd211 when a(18 downto 11)=x"D3"
		else drd212 when a(18 downto 11)=x"D4"
		else drd213 when a(18 downto 11)=x"D5"
		else drd214 when a(18 downto 11)=x"D6"
		else drd215 when a(18 downto 11)=x"D7"
		else drd216 when a(18 downto 11)=x"D8"
		else drd217 when a(18 downto 11)=x"D9"
		else drd218 when a(18 downto 11)=x"DA"
		else drd219 when a(18 downto 11)=x"DB"
		else drd220 when a(18 downto 11)=x"DC"
		else drd221 when a(18 downto 11)=x"DD"
		else drd222 when a(18 downto 11)=x"DE"
		else drd223 when a(18 downto 11)=x"DF"
		else drd224 when a(18 downto 11)=x"E0"
		else drd225 when a(18 downto 11)=x"E1"
		else drd226 when a(18 downto 11)=x"E2"
		else drd227 when a(18 downto 11)=x"E3"
		else drd228 when a(18 downto 11)=x"E4"
		else drd229 when a(18 downto 11)=x"E5"
		else drd230 when a(18 downto 11)=x"E6"
		else drd231 when a(18 downto 11)=x"E7"
		else drd232 when a(18 downto 11)=x"E8"
		else drd233 when a(18 downto 11)=x"E9"
		else drd234 when a(18 downto 11)=x"EA"
		else drd235 when a(18 downto 11)=x"EB"
		else drd236 when a(18 downto 11)=x"EC"
		else drd237 when a(18 downto 11)=x"ED"
		else drd238 when a(18 downto 11)=x"EE"
		else drd239 when a(18 downto 11)=x"EF"
		else x"00";
	-- IP impl --- END

end Spbram_v1_0_size480kB;

