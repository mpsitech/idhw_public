/**
  * \file CtrIdhwZedbTkclksrc.cpp
  * tkclksrc controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwZedbTkclksrc.h"

/******************************************************************************
 class CtrIdhwZedbTkclksrc::CmdGetTkst
 ******************************************************************************/

CtrIdhwZedbTkclksrc::CmdGetTkst::CmdGetTkst() : Cmd(0x0C, VecVCommand::GETTKST, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwZedbTkclksrc::CmdGetTkst::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwZedbTkclksrc::CmdGetTkst::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tkst"].getUint());
};

/******************************************************************************
 class CtrIdhwZedbTkclksrc::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwZedbTkclksrc::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "gettkst") return GETTKST;
	else if (s == "settkst") return SETTKST;

	return(0);
};

string CtrIdhwZedbTkclksrc::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETTKST) return("getTkst");
	else if (tix == SETTKST) return("setTkst");

	return("");
};

void CtrIdhwZedbTkclksrc::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GETTKST,SETTKST};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwZedbTkclksrc
 ******************************************************************************/

CtrIdhwZedbTkclksrc::CtrIdhwZedbTkclksrc(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwZedbTkclksrc::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwZedbTkclksrc::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwZedbTkclksrc::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwZedbTkclksrc::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETTKST) cmd = getNewCmdGetTkst();
	else if (tixVCommand == VecVCommand::SETTKST) cmd = getNewCmdSetTkst();

	return cmd;
};

CtrIdhwZedbTkclksrc::CmdGetTkst* CtrIdhwZedbTkclksrc::getNewCmdGetTkst() {
	CmdGetTkst* cmd = new CmdGetTkst();

	cmd->addParRet("tkst", Par::VecVType::UINT);

	return cmd;
};

void CtrIdhwZedbTkclksrc::getTkst(
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

Cmd* CtrIdhwZedbTkclksrc::getNewCmdSetTkst(
			const uint tkst
		) {
	Cmd* cmd = new Cmd(0x0C, VecVCommand::SETTKST, Cmd::VecVRettype::VOID);

	cmd->addParInv("tkst", Par::VecVType::UINT);

	cmd->parsInv["tkst"].setUint(tkst);

	return cmd;
};

void CtrIdhwZedbTkclksrc::setTkst(
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

