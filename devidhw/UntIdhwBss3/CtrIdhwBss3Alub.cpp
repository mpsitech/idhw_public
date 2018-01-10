/**
  * \file CtrIdhwBss3Alub.cpp
  * alub controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwBss3Alub.h"

/******************************************************************************
 class CtrIdhwBss3Alub::CmdValget
 ******************************************************************************/

CtrIdhwBss3Alub::CmdValget::CmdValget() : Cmd(0x04, VecVCommand::VALGET, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwBss3Alub::CmdValget::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* r1Val, const size_t r1Vallen, const unsigned char* r2Val, const size_t r2Vallen, const unsigned char* r3Val, const size_t r3Vallen, const unsigned char* r4Val, const size_t r4Vallen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwBss3Alub::CmdValget::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["r1Val"].getVblob(), parsRet["r1Val"].getLen(), parsRet["r2Val"].getVblob(), parsRet["r2Val"].getLen(), parsRet["r3Val"].getVblob(), parsRet["r3Val"].getLen(), parsRet["r4Val"].getVblob(), parsRet["r4Val"].getLen());
};

/******************************************************************************
 class CtrIdhwBss3Alub::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwBss3Alub::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "add") return ADD;
	else if (s == "sub") return SUB;
	else if (s == "mult") return MULT;
	else if (s == "div") return DIV;
	else if (s == "pow") return POW;
	else if (s == "lgcand") return LGCAND;
	else if (s == "lgcor") return LGCOR;
	else if (s == "lgcxor") return LGCXOR;
	else if (s == "lgcnot") return LGCNOT;
	else if (s == "valset") return VALSET;
	else if (s == "valget") return VALGET;

	return(0);
};

string CtrIdhwBss3Alub::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == ADD) return("add");
	else if (tix == SUB) return("sub");
	else if (tix == MULT) return("mult");
	else if (tix == DIV) return("div");
	else if (tix == POW) return("pow");
	else if (tix == LGCAND) return("lgcand");
	else if (tix == LGCOR) return("lgcor");
	else if (tix == LGCXOR) return("lgcxor");
	else if (tix == LGCNOT) return("lgcnot");
	else if (tix == VALSET) return("valset");
	else if (tix == VALGET) return("valget");

	return("");
};

void CtrIdhwBss3Alub::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {ADD,SUB,MULT,DIV,POW,LGCAND,LGCOR,LGCXOR,LGCNOT,VALSET,VALGET};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwBss3Alub::VecVError
 ******************************************************************************/

utinyint CtrIdhwBss3Alub::VecVError::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "invalid") return INVALID;
	else if (s == "mismatch") return MISMATCH;
	else if (s == "size") return SIZE;

	return(0);
};

string CtrIdhwBss3Alub::VecVError::getSref(
			const utinyint tix
		) {
	if (tix == INVALID) return("invalid");
	else if (tix == MISMATCH) return("mismatch");
	else if (tix == SIZE) return("size");

	return("");
};

string CtrIdhwBss3Alub::VecVError::getTitle(
			const utinyint tix
		) {
	if (tix == INVALID) return("invalid register for operand");
	else if (tix == MISMATCH) return("operand dimension mismatch");
	else if (tix == SIZE) return("invalid size for value");

	return("");
};

/******************************************************************************
 class CtrIdhwBss3Alub::VecVReg
 ******************************************************************************/

utinyint CtrIdhwBss3Alub::VecVReg::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "void") return VOID;
	else if (s == "r0") return R0;
	else if (s == "r1") return R1;
	else if (s == "s0") return S0;
	else if (s == "s1") return S1;
	else if (s == "s2") return S2;
	else if (s == "s3") return S3;
	else if (s == "t0") return T0;
	else if (s == "t1") return T1;
	else if (s == "t2") return T2;
	else if (s == "t3") return T3;
	else if (s == "t4") return T4;
	else if (s == "t5") return T5;
	else if (s == "t6") return T6;
	else if (s == "t7") return T7;

	return(0);
};

string CtrIdhwBss3Alub::VecVReg::getSref(
			const utinyint tix
		) {
	if (tix == VOID) return("void");
	else if (tix == R0) return("r0");
	else if (tix == R1) return("r1");
	else if (tix == S0) return("s0");
	else if (tix == S1) return("s1");
	else if (tix == S2) return("s2");
	else if (tix == S3) return("s3");
	else if (tix == T0) return("t0");
	else if (tix == T1) return("t1");
	else if (tix == T2) return("t2");
	else if (tix == T3) return("t3");
	else if (tix == T4) return("t4");
	else if (tix == T5) return("t5");
	else if (tix == T6) return("t6");
	else if (tix == T7) return("t7");

	return("");
};

string CtrIdhwBss3Alub::VecVReg::getTitle(
			const utinyint tix
		) {
	if (tix == VOID) return("none");
	else if (tix == R0) return("64bit, s0&s1");
	else if (tix == R1) return("64bit, s2&s3");
	else if (tix == S0) return("32bit, t0&t1");
	else if (tix == S1) return("32bit, t2&t3");
	else if (tix == S2) return("32bit, t4&t5");
	else if (tix == S3) return("32bit, t6&t7");
	else if (tix == T0) return("16bit");
	else if (tix == T1) return("16bit");
	else if (tix == T2) return("16bit");
	else if (tix == T3) return("16bit");
	else if (tix == T4) return("16bit");
	else if (tix == T5) return("16bit");
	else if (tix == T6) return("16bit");
	else if (tix == T7) return("16bit");

	return("");
};

void CtrIdhwBss3Alub::VecVReg::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {VOID,R0,R1,S0,S1,S2,S3,T0,T1,T2,T3,T4,T5,T6,T7};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 class CtrIdhwBss3Alub
 ******************************************************************************/

CtrIdhwBss3Alub::CtrIdhwBss3Alub(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwBss3Alub::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwBss3Alub::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwBss3Alub::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwBss3Alub::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::ADD) cmd = getNewCmdAdd();
	else if (tixVCommand == VecVCommand::SUB) cmd = getNewCmdSub();
	else if (tixVCommand == VecVCommand::MULT) cmd = getNewCmdMult();
	else if (tixVCommand == VecVCommand::DIV) cmd = getNewCmdDiv();
	else if (tixVCommand == VecVCommand::POW) cmd = getNewCmdPow();
	else if (tixVCommand == VecVCommand::LGCAND) cmd = getNewCmdLgcand();
	else if (tixVCommand == VecVCommand::LGCOR) cmd = getNewCmdLgcor();
	else if (tixVCommand == VecVCommand::LGCXOR) cmd = getNewCmdLgcxor();
	else if (tixVCommand == VecVCommand::LGCNOT) cmd = getNewCmdLgcnot();
	else if (tixVCommand == VecVCommand::VALSET) cmd = getNewCmdValset();
	else if (tixVCommand == VecVCommand::VALGET) cmd = getNewCmdValget();

	return cmd;
};

Cmd* CtrIdhwBss3Alub::getNewCmdAdd(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::ADD, Cmd::VecVRettype::VOID);

	cmd->addParInv("aTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("bTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("cTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);

	cmd->parsInv["aTixVReg"].setTix(aTixVReg);
	cmd->parsInv["bTixVReg"].setTix(bTixVReg);
	cmd->parsInv["cTixVReg"].setTix(cTixVReg);

	return cmd;
};

void CtrIdhwBss3Alub::add(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdAdd(aTixVReg, bTixVReg, cTixVReg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "add", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Alub::getNewCmdSub(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::SUB, Cmd::VecVRettype::VOID);

	cmd->addParInv("aTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("bTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("cTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);

	cmd->parsInv["aTixVReg"].setTix(aTixVReg);
	cmd->parsInv["bTixVReg"].setTix(bTixVReg);
	cmd->parsInv["cTixVReg"].setTix(cTixVReg);

	return cmd;
};

void CtrIdhwBss3Alub::sub(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSub(aTixVReg, bTixVReg, cTixVReg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "sub", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Alub::getNewCmdMult(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::MULT, Cmd::VecVRettype::VOID);

	cmd->addParInv("aTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("bTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("cTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);

	cmd->parsInv["aTixVReg"].setTix(aTixVReg);
	cmd->parsInv["bTixVReg"].setTix(bTixVReg);
	cmd->parsInv["cTixVReg"].setTix(cTixVReg);

	return cmd;
};

void CtrIdhwBss3Alub::mult(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdMult(aTixVReg, bTixVReg, cTixVReg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "mult", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Alub::getNewCmdDiv(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::DIV, Cmd::VecVRettype::VOID);

	cmd->addParInv("aTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("bTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("cTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);

	cmd->parsInv["aTixVReg"].setTix(aTixVReg);
	cmd->parsInv["bTixVReg"].setTix(bTixVReg);
	cmd->parsInv["cTixVReg"].setTix(cTixVReg);

	return cmd;
};

void CtrIdhwBss3Alub::div(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdDiv(aTixVReg, bTixVReg, cTixVReg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "div", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Alub::getNewCmdPow(
			const utinyint aTixVReg
			, const utinyint exp
			, const utinyint cTixVReg
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::POW, Cmd::VecVRettype::VOID);

	cmd->addParInv("aTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("exp", Par::VecVType::UTINYINT);
	cmd->addParInv("cTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);

	cmd->parsInv["aTixVReg"].setTix(aTixVReg);
	cmd->parsInv["exp"].setUtinyint(exp);
	cmd->parsInv["cTixVReg"].setTix(cTixVReg);

	return cmd;
};

void CtrIdhwBss3Alub::pow(
			const utinyint aTixVReg
			, const utinyint exp
			, const utinyint cTixVReg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdPow(aTixVReg, exp, cTixVReg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "pow", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Alub::getNewCmdLgcand(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::LGCAND, Cmd::VecVRettype::VOID);

	cmd->addParInv("aTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("bTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("cTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);

	cmd->parsInv["aTixVReg"].setTix(aTixVReg);
	cmd->parsInv["bTixVReg"].setTix(bTixVReg);
	cmd->parsInv["cTixVReg"].setTix(cTixVReg);

	return cmd;
};

void CtrIdhwBss3Alub::lgcand(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdLgcand(aTixVReg, bTixVReg, cTixVReg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "lgcand", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Alub::getNewCmdLgcor(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::LGCOR, Cmd::VecVRettype::VOID);

	cmd->addParInv("aTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("bTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("cTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);

	cmd->parsInv["aTixVReg"].setTix(aTixVReg);
	cmd->parsInv["bTixVReg"].setTix(bTixVReg);
	cmd->parsInv["cTixVReg"].setTix(cTixVReg);

	return cmd;
};

void CtrIdhwBss3Alub::lgcor(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdLgcor(aTixVReg, bTixVReg, cTixVReg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "lgcor", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Alub::getNewCmdLgcxor(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::LGCXOR, Cmd::VecVRettype::VOID);

	cmd->addParInv("aTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("bTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("cTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);

	cmd->parsInv["aTixVReg"].setTix(aTixVReg);
	cmd->parsInv["bTixVReg"].setTix(bTixVReg);
	cmd->parsInv["cTixVReg"].setTix(cTixVReg);

	return cmd;
};

void CtrIdhwBss3Alub::lgcxor(
			const utinyint aTixVReg
			, const utinyint bTixVReg
			, const utinyint cTixVReg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdLgcxor(aTixVReg, bTixVReg, cTixVReg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "lgcxor", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Alub::getNewCmdLgcnot(
			const utinyint aTixVReg
			, const utinyint cTixVReg
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::LGCNOT, Cmd::VecVRettype::VOID);

	cmd->addParInv("aTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("cTixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);

	cmd->parsInv["aTixVReg"].setTix(aTixVReg);
	cmd->parsInv["cTixVReg"].setTix(cTixVReg);

	return cmd;
};

void CtrIdhwBss3Alub::lgcnot(
			const utinyint aTixVReg
			, const utinyint cTixVReg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdLgcnot(aTixVReg, cTixVReg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "lgcnot", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Alub::getNewCmdValset(
			const utinyint r1TixVReg
			, const unsigned char* r1Val
			, const size_t r1Vallen
			, const utinyint r2TixVReg
			, const unsigned char* r2Val
			, const size_t r2Vallen
			, const utinyint r3TixVReg
			, const unsigned char* r3Val
			, const size_t r3Vallen
			, const utinyint r4TixVReg
			, const unsigned char* r4Val
			, const size_t r4Vallen
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::VALSET, Cmd::VecVRettype::VOID);

	cmd->addParInv("r1TixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("r1Val", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);
	cmd->addParInv("r2TixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("r2Val", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);
	cmd->addParInv("r3TixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("r3Val", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);
	cmd->addParInv("r4TixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("r4Val", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);

	cmd->parsInv["r1TixVReg"].setTix(r1TixVReg);
	cmd->parsInv["r1Val"].setVblob(r1Val, r1Vallen);
	cmd->parsInv["r2TixVReg"].setTix(r2TixVReg);
	cmd->parsInv["r2Val"].setVblob(r2Val, r2Vallen);
	cmd->parsInv["r3TixVReg"].setTix(r3TixVReg);
	cmd->parsInv["r3Val"].setVblob(r3Val, r3Vallen);
	cmd->parsInv["r4TixVReg"].setTix(r4TixVReg);
	cmd->parsInv["r4Val"].setVblob(r4Val, r4Vallen);

	return cmd;
};

void CtrIdhwBss3Alub::valset(
			const utinyint r1TixVReg
			, const unsigned char* r1Val
			, const size_t r1Vallen
			, const utinyint r2TixVReg
			, const unsigned char* r2Val
			, const size_t r2Vallen
			, const utinyint r3TixVReg
			, const unsigned char* r3Val
			, const size_t r3Vallen
			, const utinyint r4TixVReg
			, const unsigned char* r4Val
			, const size_t r4Vallen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdValset(r1TixVReg, r1Val, r1Vallen, r2TixVReg, r2Val, r2Vallen, r3TixVReg, r3Val, r3Vallen, r4TixVReg, r4Val, r4Vallen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "valset", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

CtrIdhwBss3Alub::CmdValget* CtrIdhwBss3Alub::getNewCmdValget(
			const utinyint r1TixVReg
			, const utinyint r2TixVReg
			, const utinyint r3TixVReg
			, const utinyint r4TixVReg
		) {
	CmdValget* cmd = new CmdValget();

	cmd->addParInv("r1TixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("r2TixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("r3TixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);
	cmd->addParInv("r4TixVReg", Par::VecVType::TIX, CtrIdhwBss3Alub::VecVReg::getTix, CtrIdhwBss3Alub::VecVReg::getSref, CtrIdhwBss3Alub::VecVReg::fillFeed);

	cmd->parsInv["r1TixVReg"].setTix(r1TixVReg);
	cmd->parsInv["r2TixVReg"].setTix(r2TixVReg);
	cmd->parsInv["r3TixVReg"].setTix(r3TixVReg);
	cmd->parsInv["r4TixVReg"].setTix(r4TixVReg);

	cmd->addParRet("r1Val", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);
	cmd->addParRet("r2Val", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);
	cmd->addParRet("r3Val", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);
	cmd->addParRet("r4Val", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);

	return cmd;
};

void CtrIdhwBss3Alub::valget(
			const utinyint r1TixVReg
			, const utinyint r2TixVReg
			, const utinyint r3TixVReg
			, const utinyint r4TixVReg
			, unsigned char*& r1Val
			, size_t& r1Vallen
			, unsigned char*& r2Val
			, size_t& r2Vallen
			, unsigned char*& r3Val
			, size_t& r3Vallen
			, unsigned char*& r4Val
			, size_t& r4Vallen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdValget(r1TixVReg, r2TixVReg, r3TixVReg, r4TixVReg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("alub", "valget", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	else {
		r1Val = cmd->parsRet["r1Val"].getVblob();
		r1Vallen = cmd->parsRet["r1Val"].getLen();
		r2Val = cmd->parsRet["r2Val"].getVblob();
		r2Vallen = cmd->parsRet["r2Val"].getLen();
		r3Val = cmd->parsRet["r3Val"].getVblob();
		r3Vallen = cmd->parsRet["r3Val"].getLen();
		r4Val = cmd->parsRet["r4Val"].getVblob();
		r4Vallen = cmd->parsRet["r4Val"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

string CtrIdhwBss3Alub::getSrefByTixVError(
			const utinyint tixVError
		) {
	return VecVError::getSref(tixVError);
};

string CtrIdhwBss3Alub::getTitleByTixVError(
			const utinyint tixVError
		) {
	return VecVError::getTitle(tixVError);
};

Err CtrIdhwBss3Alub::getNewErr(
			const utinyint tixVError
		) {
	Err err;

	if (tixVError == VecVError::INVALID) err = getNewErrInvalid();
	else if (tixVError == VecVError::MISMATCH) err = getNewErrMismatch();
	else if (tixVError == VecVError::SIZE) err = getNewErrSize();

	return err;
};

Err CtrIdhwBss3Alub::getNewErrInvalid() {
	Err err(VecDbeVAction::ERR, VecVError::INVALID);

	err.addPar("a", Par::VecVType::_BOOL);
	err.addPar("b", Par::VecVType::_BOOL);

	return err;
};

Err CtrIdhwBss3Alub::getNewErrMismatch() {
	Err err(VecDbeVAction::ERR, VecVError::MISMATCH);

	return err;
};

Err CtrIdhwBss3Alub::getNewErrSize() {
	Err err(VecDbeVAction::ERR, VecVError::SIZE);

	err.addPar("r1", Par::VecVType::_BOOL);
	err.addPar("r2", Par::VecVType::_BOOL);
	err.addPar("r3", Par::VecVType::_BOOL);
	err.addPar("r4", Par::VecVType::_BOOL);

	return err;
};

