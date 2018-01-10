/**
  * \file CtrIdhwZedbPhiif.cpp
  * phiif controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwZedbPhiif.h"

/******************************************************************************
 class CtrIdhwZedbPhiif::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwZedbPhiif::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "reset") return RESET;

	return(0);
};

string CtrIdhwZedbPhiif::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == RESET) return("reset");

	return("");
};

void CtrIdhwZedbPhiif::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {RESET};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwZedbPhiif
 ******************************************************************************/

CtrIdhwZedbPhiif::CtrIdhwZedbPhiif(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwZedbPhiif::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwZedbPhiif::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwZedbPhiif::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwZedbPhiif::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::RESET) cmd = getNewCmdReset();

	return cmd;
};

Cmd* CtrIdhwZedbPhiif::getNewCmdReset() {
	Cmd* cmd = new Cmd(0x08, VecVCommand::RESET, Cmd::VecVRettype::VOID);

	return cmd;
};

void CtrIdhwZedbPhiif::reset(
			const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdReset();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("phiif", "reset", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

