/**
  * \file CtrIdhwDcx3Trigger.cpp
  * trigger controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwDcx3Trigger.h"

/******************************************************************************
 class CtrIdhwDcx3Trigger::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwDcx3Trigger::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setrng") return SETRNG;
	else if (s == "settdlylwir") return SETTDLYLWIR;
	else if (s == "settdlyvisr") return SETTDLYVISR;
	else if (s == "settfrm") return SETTFRM;

	return(0);
};

string CtrIdhwDcx3Trigger::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETRNG) return("setRng");
	else if (tix == SETTDLYLWIR) return("setTdlyLwir");
	else if (tix == SETTDLYVISR) return("setTdlyVisr");
	else if (tix == SETTFRM) return("setTfrm");

	return("");
};

void CtrIdhwDcx3Trigger::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETRNG,SETTDLYLWIR,SETTDLYVISR,SETTFRM};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Trigger
 ******************************************************************************/

CtrIdhwDcx3Trigger::CtrIdhwDcx3Trigger(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwDcx3Trigger::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwDcx3Trigger::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwDcx3Trigger::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwDcx3Trigger::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();
	else if (tixVCommand == VecVCommand::SETTDLYLWIR) cmd = getNewCmdSetTdlyLwir();
	else if (tixVCommand == VecVCommand::SETTDLYVISR) cmd = getNewCmdSetTdlyVisr();
	else if (tixVCommand == VecVCommand::SETTFRM) cmd = getNewCmdSetTfrm();

	return cmd;
};

Cmd* CtrIdhwDcx3Trigger::getNewCmdSetRng(
			const bool rng
		) {
	Cmd* cmd = new Cmd(0x0F, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);

	cmd->parsInv["rng"].setBool(rng);

	return cmd;
};

void CtrIdhwDcx3Trigger::setRng(
			const bool rng
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetRng(rng);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("trigger", "setRng", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwDcx3Trigger::getNewCmdSetTdlyLwir(
			const usmallint tdlyLwir
		) {
	Cmd* cmd = new Cmd(0x0F, VecVCommand::SETTDLYLWIR, Cmd::VecVRettype::VOID);

	cmd->addParInv("tdlyLwir", Par::VecVType::USMALLINT);

	cmd->parsInv["tdlyLwir"].setUsmallint(tdlyLwir);

	return cmd;
};

void CtrIdhwDcx3Trigger::setTdlyLwir(
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

Cmd* CtrIdhwDcx3Trigger::getNewCmdSetTdlyVisr(
			const usmallint tdlyVisr
		) {
	Cmd* cmd = new Cmd(0x0F, VecVCommand::SETTDLYVISR, Cmd::VecVRettype::VOID);

	cmd->addParInv("tdlyVisr", Par::VecVType::USMALLINT);

	cmd->parsInv["tdlyVisr"].setUsmallint(tdlyVisr);

	return cmd;
};

void CtrIdhwDcx3Trigger::setTdlyVisr(
			const usmallint tdlyVisr
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTdlyVisr(tdlyVisr);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("trigger", "setTdlyVisr", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwDcx3Trigger::getNewCmdSetTfrm(
			const usmallint Tfrm
		) {
	Cmd* cmd = new Cmd(0x0F, VecVCommand::SETTFRM, Cmd::VecVRettype::VOID);

	cmd->addParInv("Tfrm", Par::VecVType::USMALLINT);

	cmd->parsInv["Tfrm"].setUsmallint(Tfrm);

	return cmd;
};

void CtrIdhwDcx3Trigger::setTfrm(
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

