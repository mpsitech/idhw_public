/**
  * \file CtrIdhwIcm2Tkclksrc.cpp
  * tkclksrc controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwIcm2Tkclksrc.h"

/******************************************************************************
 class CtrIdhwIcm2Tkclksrc::CmdGetTkst
 ******************************************************************************/

CtrIdhwIcm2Tkclksrc::CmdGetTkst::CmdGetTkst() : Cmd(0x09, VecVCommand::GETTKST, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwIcm2Tkclksrc::CmdGetTkst::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwIcm2Tkclksrc::CmdGetTkst::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tkst"].getUint());
};

/******************************************************************************
 class CtrIdhwIcm2Tkclksrc::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwIcm2Tkclksrc::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "gettkst") return GETTKST;
	else if (s == "settkst") return SETTKST;

	return(0);
};

string CtrIdhwIcm2Tkclksrc::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETTKST) return("getTkst");
	else if (tix == SETTKST) return("setTkst");

	return("");
};

void CtrIdhwIcm2Tkclksrc::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GETTKST,SETTKST};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Tkclksrc
 ******************************************************************************/

CtrIdhwIcm2Tkclksrc::CtrIdhwIcm2Tkclksrc(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwIcm2Tkclksrc::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwIcm2Tkclksrc::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwIcm2Tkclksrc::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwIcm2Tkclksrc::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETTKST) cmd = getNewCmdGetTkst();
	else if (tixVCommand == VecVCommand::SETTKST) cmd = getNewCmdSetTkst();

	return cmd;
};

CtrIdhwIcm2Tkclksrc::CmdGetTkst* CtrIdhwIcm2Tkclksrc::getNewCmdGetTkst() {
	CmdGetTkst* cmd = new CmdGetTkst();

	cmd->addParRet("tkst", Par::VecVType::UINT);

	return cmd;
};

void CtrIdhwIcm2Tkclksrc::getTkst(
			uint& tkst
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetTkst();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("tkclksrc", "getTkst", cmd->cref, "", "", true, true);
	else {
		tkst = cmd->parsRet["tkst"].getUint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Tkclksrc::getNewCmdSetTkst(
			const uint tkst
		) {
	Cmd* cmd = new Cmd(0x09, VecVCommand::SETTKST, Cmd::VecVRettype::VOID);

	cmd->addParInv("tkst", Par::VecVType::UINT);

	cmd->parsInv["tkst"].setUint(tkst);

	return cmd;
};

void CtrIdhwIcm2Tkclksrc::setTkst(
			const uint tkst
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTkst(tkst);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("tkclksrc", "setTkst", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

