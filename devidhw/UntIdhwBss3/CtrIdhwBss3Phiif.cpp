/**
  * \file CtrIdhwBss3Phiif.cpp
  * phiif controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwBss3Phiif.h"

/******************************************************************************
 class CtrIdhwBss3Phiif::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwBss3Phiif::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "reset") return RESET;

	return(0);
};

string CtrIdhwBss3Phiif::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == RESET) return("reset");

	return("");
};

void CtrIdhwBss3Phiif::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {RESET};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwBss3Phiif
 ******************************************************************************/

CtrIdhwBss3Phiif::CtrIdhwBss3Phiif(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwBss3Phiif::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwBss3Phiif::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwBss3Phiif::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwBss3Phiif::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::RESET) cmd = getNewCmdReset();

	return cmd;
};

Cmd* CtrIdhwBss3Phiif::getNewCmdReset() {
	Cmd* cmd = new Cmd(0x08, VecVCommand::RESET, Cmd::VecVRettype::VOID);

	return cmd;
};

void CtrIdhwBss3Phiif::reset(
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

