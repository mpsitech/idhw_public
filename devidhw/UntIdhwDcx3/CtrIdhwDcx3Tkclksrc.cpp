/**
  * \file CtrIdhwDcx3Tkclksrc.cpp
  * tkclksrc controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwDcx3Tkclksrc.h"

/******************************************************************************
 class CtrIdhwDcx3Tkclksrc::CmdGetTkst
 ******************************************************************************/

CtrIdhwDcx3Tkclksrc::CmdGetTkst::CmdGetTkst() : Cmd(0x0E, VecVCommand::GETTKST, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwDcx3Tkclksrc::CmdGetTkst::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwDcx3Tkclksrc::CmdGetTkst::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tkst"].getUint());
};

/******************************************************************************
 class CtrIdhwDcx3Tkclksrc::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwDcx3Tkclksrc::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "gettkst") return GETTKST;
	else if (s == "settkst") return SETTKST;

	return(0);
};

string CtrIdhwDcx3Tkclksrc::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETTKST) return("getTkst");
	else if (tix == SETTKST) return("setTkst");

	return("");
};

void CtrIdhwDcx3Tkclksrc::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GETTKST,SETTKST};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Tkclksrc
 ******************************************************************************/

CtrIdhwDcx3Tkclksrc::CtrIdhwDcx3Tkclksrc(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwDcx3Tkclksrc::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwDcx3Tkclksrc::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwDcx3Tkclksrc::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwDcx3Tkclksrc::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETTKST) cmd = getNewCmdGetTkst();
	else if (tixVCommand == VecVCommand::SETTKST) cmd = getNewCmdSetTkst();

	return cmd;
};

CtrIdhwDcx3Tkclksrc::CmdGetTkst* CtrIdhwDcx3Tkclksrc::getNewCmdGetTkst() {
	CmdGetTkst* cmd = new CmdGetTkst();

	cmd->addParRet("tkst", Par::VecVType::UINT);

	return cmd;
};

void CtrIdhwDcx3Tkclksrc::getTkst(
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

Cmd* CtrIdhwDcx3Tkclksrc::getNewCmdSetTkst(
			const uint tkst
		) {
	Cmd* cmd = new Cmd(0x0E, VecVCommand::SETTKST, Cmd::VecVRettype::VOID);

	cmd->addParInv("tkst", Par::VecVType::UINT);

	cmd->parsInv["tkst"].setUint(tkst);

	return cmd;
};

void CtrIdhwDcx3Tkclksrc::setTkst(
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

