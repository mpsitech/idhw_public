/**
  * \file CtrIdhwIcm2Fan.cpp
  * fan controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwIcm2Fan.h"

/******************************************************************************
 class CtrIdhwIcm2Fan::CmdGetTpi
 ******************************************************************************/

CtrIdhwIcm2Fan::CmdGetTpi::CmdGetTpi() : Cmd(0x04, VecVCommand::GETTPI, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwIcm2Fan::CmdGetTpi::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tpi)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwIcm2Fan::CmdGetTpi::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tpi"].getUtinyint());
};

/******************************************************************************
 class CtrIdhwIcm2Fan::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwIcm2Fan::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "gettpi") return GETTPI;
	else if (s == "setrng") return SETRNG;

	return(0);
};

string CtrIdhwIcm2Fan::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETTPI) return("getTpi");
	else if (tix == SETRNG) return("setRng");

	return("");
};

void CtrIdhwIcm2Fan::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GETTPI,SETRNG};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Fan
 ******************************************************************************/

CtrIdhwIcm2Fan::CtrIdhwIcm2Fan(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwIcm2Fan::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwIcm2Fan::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwIcm2Fan::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwIcm2Fan::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETTPI) cmd = getNewCmdGetTpi();
	else if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();

	return cmd;
};

CtrIdhwIcm2Fan::CmdGetTpi* CtrIdhwIcm2Fan::getNewCmdGetTpi() {
	CmdGetTpi* cmd = new CmdGetTpi();

	cmd->addParRet("tpi", Par::VecVType::UTINYINT);

	return cmd;
};

void CtrIdhwIcm2Fan::getTpi(
			utinyint& tpi
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetTpi();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("fan", "getTpi", cmd->cref, "", "", true, true);
	else {
		tpi = cmd->parsRet["tpi"].getUtinyint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Fan::getNewCmdSetRng(
			const bool rng
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);

	cmd->parsInv["rng"].setBool(rng);

	return cmd;
};

void CtrIdhwIcm2Fan::setRng(
			const bool rng
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetRng(rng);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("fan", "setRng", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

