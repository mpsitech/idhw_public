/**
  * \file CtrIdhwDcx3Led.cpp
  * led controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwDcx3Led.h"

/******************************************************************************
 class CtrIdhwDcx3Led::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwDcx3Led::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setton15") return SETTON15;
	else if (s == "setton60") return SETTON60;

	return(0);
};

string CtrIdhwDcx3Led::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETTON15) return("setTon15");
	else if (tix == SETTON60) return("setTon60");

	return("");
};

void CtrIdhwDcx3Led::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETTON15,SETTON60};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Led
 ******************************************************************************/

CtrIdhwDcx3Led::CtrIdhwDcx3Led(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwDcx3Led::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwDcx3Led::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwDcx3Led::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwDcx3Led::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETTON15) cmd = getNewCmdSetTon15();
	else if (tixVCommand == VecVCommand::SETTON60) cmd = getNewCmdSetTon60();

	return cmd;
};

Cmd* CtrIdhwDcx3Led::getNewCmdSetTon15(
			const utinyint ton15
		) {
	Cmd* cmd = new Cmd(0x05, VecVCommand::SETTON15, Cmd::VecVRettype::VOID);

	cmd->addParInv("ton15", Par::VecVType::UTINYINT);

	cmd->parsInv["ton15"].setUtinyint(ton15);

	return cmd;
};

void CtrIdhwDcx3Led::setTon15(
			const utinyint ton15
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTon15(ton15);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("led", "setTon15", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwDcx3Led::getNewCmdSetTon60(
			const utinyint ton60
		) {
	Cmd* cmd = new Cmd(0x05, VecVCommand::SETTON60, Cmd::VecVRettype::VOID);

	cmd->addParInv("ton60", Par::VecVType::UTINYINT);

	cmd->parsInv["ton60"].setUtinyint(ton60);

	return cmd;
};

void CtrIdhwDcx3Led::setTon60(
			const utinyint ton60
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTon60(ton60);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("led", "setTon60", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

