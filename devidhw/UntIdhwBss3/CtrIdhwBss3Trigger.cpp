/**
  * \file CtrIdhwBss3Trigger.cpp
  * trigger controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwBss3Trigger.h"

/******************************************************************************
 class CtrIdhwBss3Trigger::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwBss3Trigger::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setrng") return SETRNG;
	else if (s == "settdlylwir") return SETTDLYLWIR;
	else if (s == "settfrm") return SETTFRM;

	return(0);
};

string CtrIdhwBss3Trigger::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETRNG) return("setRng");
	else if (tix == SETTDLYLWIR) return("setTdlyLwir");
	else if (tix == SETTFRM) return("setTfrm");

	return("");
};

void CtrIdhwBss3Trigger::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETRNG,SETTDLYLWIR,SETTFRM};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwBss3Trigger
 ******************************************************************************/

CtrIdhwBss3Trigger::CtrIdhwBss3Trigger(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwBss3Trigger::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwBss3Trigger::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwBss3Trigger::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwBss3Trigger::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();
	else if (tixVCommand == VecVCommand::SETTDLYLWIR) cmd = getNewCmdSetTdlyLwir();
	else if (tixVCommand == VecVCommand::SETTFRM) cmd = getNewCmdSetTfrm();

	return cmd;
};

Cmd* CtrIdhwBss3Trigger::getNewCmdSetRng(
			const bool rng
			, const bool btnNotTfrm
		) {
	Cmd* cmd = new Cmd(0x0D, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);
	cmd->addParInv("btnNotTfrm", Par::VecVType::_BOOL);

	cmd->parsInv["rng"].setBool(rng);
	cmd->parsInv["btnNotTfrm"].setBool(btnNotTfrm);

	return cmd;
};

void CtrIdhwBss3Trigger::setRng(
			const bool rng
			, const bool btnNotTfrm
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetRng(rng, btnNotTfrm);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("trigger", "setRng", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Trigger::getNewCmdSetTdlyLwir(
			const usmallint tdlyLwir
		) {
	Cmd* cmd = new Cmd(0x0D, VecVCommand::SETTDLYLWIR, Cmd::VecVRettype::VOID);

	cmd->addParInv("tdlyLwir", Par::VecVType::USMALLINT);

	cmd->parsInv["tdlyLwir"].setUsmallint(tdlyLwir);

	return cmd;
};

void CtrIdhwBss3Trigger::setTdlyLwir(
			const usmallint tdlyLwir
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTdlyLwir(tdlyLwir);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("trigger", "setTdlyLwir", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Trigger::getNewCmdSetTfrm(
			const usmallint Tfrm
		) {
	Cmd* cmd = new Cmd(0x0D, VecVCommand::SETTFRM, Cmd::VecVRettype::VOID);

	cmd->addParInv("Tfrm", Par::VecVType::USMALLINT);

	cmd->parsInv["Tfrm"].setUsmallint(Tfrm);

	return cmd;
};

void CtrIdhwBss3Trigger::setTfrm(
			const usmallint Tfrm
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTfrm(Tfrm);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("trigger", "setTfrm", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

