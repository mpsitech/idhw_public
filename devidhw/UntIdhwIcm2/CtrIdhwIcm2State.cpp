/**
  * \file CtrIdhwIcm2State.cpp
  * state controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwIcm2State.h"

/******************************************************************************
 class CtrIdhwIcm2State::CmdGet
 ******************************************************************************/

CtrIdhwIcm2State::CmdGet::CmdGet() : Cmd(0x06, VecVCommand::GET, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwIcm2State::CmdGet::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVIcm2State)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwIcm2State::CmdGet::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tixVIcm2State"].getTix());
};

/******************************************************************************
 class CtrIdhwIcm2State::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwIcm2State::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "get") return GET;

	return(0);
};

string CtrIdhwIcm2State::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GET) return("get");

	return("");
};

void CtrIdhwIcm2State::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GET};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwIcm2State
 ******************************************************************************/

CtrIdhwIcm2State::CtrIdhwIcm2State(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwIcm2State::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwIcm2State::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwIcm2State::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwIcm2State::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GET) cmd = getNewCmdGet();

	return cmd;
};

CtrIdhwIcm2State::CmdGet* CtrIdhwIcm2State::getNewCmdGet() {
	CmdGet* cmd = new CmdGet();

	cmd->addParRet("tixVIcm2State", Par::VecVType::TIX, VecVIdhwIcm2State::getTix, VecVIdhwIcm2State::getSref, VecVIdhwIcm2State::fillFeed);

	return cmd;
};

void CtrIdhwIcm2State::get(
			utinyint& tixVIcm2State
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGet();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("state", "get", cmd->cref, "", "", true, true);
	else {
		tixVIcm2State = cmd->parsRet["tixVIcm2State"].getTix();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

