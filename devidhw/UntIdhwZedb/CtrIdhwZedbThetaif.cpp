/**
  * \file CtrIdhwZedbThetaif.cpp
  * thetaif controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwZedbThetaif.h"

/******************************************************************************
 class CtrIdhwZedbThetaif::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwZedbThetaif::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "reset") return RESET;

	return(0);
};

string CtrIdhwZedbThetaif::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == RESET) return("reset");

	return("");
};

void CtrIdhwZedbThetaif::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {RESET};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwZedbThetaif
 ******************************************************************************/

CtrIdhwZedbThetaif::CtrIdhwZedbThetaif(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwZedbThetaif::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwZedbThetaif::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwZedbThetaif::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwZedbThetaif::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::RESET) cmd = getNewCmdReset();

	return cmd;
};

Cmd* CtrIdhwZedbThetaif::getNewCmdReset() {
	Cmd* cmd = new Cmd(0x0B, VecVCommand::RESET, Cmd::VecVRettype::VOID);

	return cmd;
};

void CtrIdhwZedbThetaif::reset(
			const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdReset();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("thetaif", "reset", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

