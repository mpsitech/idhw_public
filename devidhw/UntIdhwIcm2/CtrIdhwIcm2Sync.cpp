/**
  * \file CtrIdhwIcm2Sync.cpp
  * sync controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwIcm2Sync.h"

/******************************************************************************
 class CtrIdhwIcm2Sync::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwIcm2Sync::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setpulse") return SETPULSE;
	else if (s == "setrng") return SETRNG;

	return(0);
};

string CtrIdhwIcm2Sync::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETPULSE) return("setPulse");
	else if (tix == SETRNG) return("setRng");

	return("");
};

void CtrIdhwIcm2Sync::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETPULSE,SETRNG};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Sync
 ******************************************************************************/

CtrIdhwIcm2Sync::CtrIdhwIcm2Sync(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwIcm2Sync::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwIcm2Sync::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwIcm2Sync::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwIcm2Sync::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETPULSE) cmd = getNewCmdSetPulse();
	else if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();

	return cmd;
};

Cmd* CtrIdhwIcm2Sync::getNewCmdSetPulse(
			const usmallint tdly
			, const usmallint ton
		) {
	Cmd* cmd = new Cmd(0x07, VecVCommand::SETPULSE, Cmd::VecVRettype::VOID);

	cmd->addParInv("tdly", Par::VecVType::USMALLINT);
	cmd->addParInv("ton", Par::VecVType::USMALLINT);

	cmd->parsInv["tdly"].setUsmallint(tdly);
	cmd->parsInv["ton"].setUsmallint(ton);

	return cmd;
};

void CtrIdhwIcm2Sync::setPulse(
			const usmallint tdly
			, const usmallint ton
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetPulse(tdly, ton);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("sync", "setPulse", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Sync::getNewCmdSetRng(
			const bool rng
		) {
	Cmd* cmd = new Cmd(0x07, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);

	cmd->parsInv["rng"].setBool(rng);

	return cmd;
};

void CtrIdhwIcm2Sync::setRng(
			const bool rng
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetRng(rng);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("sync", "setRng", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

