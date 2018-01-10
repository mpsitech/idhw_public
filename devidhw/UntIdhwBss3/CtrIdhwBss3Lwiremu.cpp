/**
  * \file CtrIdhwBss3Lwiremu.cpp
  * lwiremu controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwBss3Lwiremu.h"

/******************************************************************************
 class CtrIdhwBss3Lwiremu::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwBss3Lwiremu::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "settrig") return SETTRIG;

	return(0);
};

string CtrIdhwBss3Lwiremu::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETTRIG) return("setTrig");

	return("");
};

void CtrIdhwBss3Lwiremu::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETTRIG};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwBss3Lwiremu
 ******************************************************************************/

CtrIdhwBss3Lwiremu::CtrIdhwBss3Lwiremu(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwBss3Lwiremu::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwBss3Lwiremu::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwBss3Lwiremu::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwBss3Lwiremu::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETTRIG) cmd = getNewCmdSetTrig();

	return cmd;
};

Cmd* CtrIdhwBss3Lwiremu::getNewCmdSetTrig(
			const bool extNotInt
		) {
	Cmd* cmd = new Cmd(0x07, VecVCommand::SETTRIG, Cmd::VecVRettype::VOID);

	cmd->addParInv("extNotInt", Par::VecVType::_BOOL);

	cmd->parsInv["extNotInt"].setBool(extNotInt);

	return cmd;
};

void CtrIdhwBss3Lwiremu::setTrig(
			const bool extNotInt
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTrig(extNotInt);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("lwiremu", "setTrig", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

