/**
  * \file CtrIdhwZedbLwiremu.cpp
  * lwiremu controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwZedbLwiremu.h"

/******************************************************************************
 class CtrIdhwZedbLwiremu::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwZedbLwiremu::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "settrig") return SETTRIG;

	return(0);
};

string CtrIdhwZedbLwiremu::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETTRIG) return("setTrig");

	return("");
};

void CtrIdhwZedbLwiremu::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETTRIG};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwZedbLwiremu
 ******************************************************************************/

CtrIdhwZedbLwiremu::CtrIdhwZedbLwiremu(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwZedbLwiremu::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwZedbLwiremu::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwZedbLwiremu::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwZedbLwiremu::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETTRIG) cmd = getNewCmdSetTrig();

	return cmd;
};

Cmd* CtrIdhwZedbLwiremu::getNewCmdSetTrig(
			const bool extNotInt
		) {
	Cmd* cmd = new Cmd(0x07, VecVCommand::SETTRIG, Cmd::VecVRettype::VOID);

	cmd->addParInv("extNotInt", Par::VecVType::_BOOL);

	cmd->parsInv["extNotInt"].setBool(extNotInt);

	return cmd;
};

void CtrIdhwZedbLwiremu::setTrig(
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

