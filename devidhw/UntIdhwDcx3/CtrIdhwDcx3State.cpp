/**
  * \file CtrIdhwDcx3State.cpp
  * state controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwDcx3State.h"

/******************************************************************************
 class CtrIdhwDcx3State::CmdGet
 ******************************************************************************/

CtrIdhwDcx3State::CmdGet::CmdGet() : Cmd(0x0C, VecVCommand::GET, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwDcx3State::CmdGet::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVDcx3State)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwDcx3State::CmdGet::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tixVDcx3State"].getTix());
};

/******************************************************************************
 class CtrIdhwDcx3State::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwDcx3State::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "get") return GET;

	return(0);
};

string CtrIdhwDcx3State::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GET) return("get");

	return("");
};

void CtrIdhwDcx3State::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GET};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwDcx3State
 ******************************************************************************/

CtrIdhwDcx3State::CtrIdhwDcx3State(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwDcx3State::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwDcx3State::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwDcx3State::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwDcx3State::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GET) cmd = getNewCmdGet();

	return cmd;
};

CtrIdhwDcx3State::CmdGet* CtrIdhwDcx3State::getNewCmdGet() {
	CmdGet* cmd = new CmdGet();

	cmd->addParRet("tixVDcx3State", Par::VecVType::TIX, VecVIdhwDcx3State::getTix, VecVIdhwDcx3State::getSref, VecVIdhwDcx3State::fillFeed);

	return cmd;
};

void CtrIdhwDcx3State::get(
			utinyint& tixVDcx3State
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGet();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("state", "get", cmd->cref, "", "", true, true);
	else {
		tixVDcx3State = cmd->parsRet["tixVDcx3State"].getTix();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

