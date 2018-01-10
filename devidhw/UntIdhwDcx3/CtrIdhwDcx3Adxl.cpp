/**
  * \file CtrIdhwDcx3Adxl.cpp
  * adxl controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwDcx3Adxl.h"

/******************************************************************************
 class CtrIdhwDcx3Adxl::CmdGetAx
 ******************************************************************************/

CtrIdhwDcx3Adxl::CmdGetAx::CmdGetAx() : Cmd(0x03, VecVCommand::GETAX, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwDcx3Adxl::CmdGetAx::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint ax)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwDcx3Adxl::CmdGetAx::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["ax"].getSmallint());
};

/******************************************************************************
 class CtrIdhwDcx3Adxl::CmdGetAy
 ******************************************************************************/

CtrIdhwDcx3Adxl::CmdGetAy::CmdGetAy() : Cmd(0x03, VecVCommand::GETAY, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwDcx3Adxl::CmdGetAy::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint ay)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwDcx3Adxl::CmdGetAy::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["ay"].getSmallint());
};

/******************************************************************************
 class CtrIdhwDcx3Adxl::CmdGetAz
 ******************************************************************************/

CtrIdhwDcx3Adxl::CmdGetAz::CmdGetAz() : Cmd(0x03, VecVCommand::GETAZ, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwDcx3Adxl::CmdGetAz::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint az)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwDcx3Adxl::CmdGetAz::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["az"].getSmallint());
};

/******************************************************************************
 class CtrIdhwDcx3Adxl::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwDcx3Adxl::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "getax") return GETAX;
	else if (s == "getay") return GETAY;
	else if (s == "getaz") return GETAZ;

	return(0);
};

string CtrIdhwDcx3Adxl::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETAX) return("getAx");
	else if (tix == GETAY) return("getAy");
	else if (tix == GETAZ) return("getAz");

	return("");
};

void CtrIdhwDcx3Adxl::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GETAX,GETAY,GETAZ};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Adxl
 ******************************************************************************/

CtrIdhwDcx3Adxl::CtrIdhwDcx3Adxl(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwDcx3Adxl::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwDcx3Adxl::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwDcx3Adxl::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwDcx3Adxl::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETAX) cmd = getNewCmdGetAx();
	else if (tixVCommand == VecVCommand::GETAY) cmd = getNewCmdGetAy();
	else if (tixVCommand == VecVCommand::GETAZ) cmd = getNewCmdGetAz();

	return cmd;
};

CtrIdhwDcx3Adxl::CmdGetAx* CtrIdhwDcx3Adxl::getNewCmdGetAx() {
	CmdGetAx* cmd = new CmdGetAx();

	cmd->addParRet("ax", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrIdhwDcx3Adxl::getAx(
			smallint& ax
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetAx();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("adxl", "getAx", cmd->cref, "", "", true, true);
	else {
		ax = cmd->parsRet["ax"].getSmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

CtrIdhwDcx3Adxl::CmdGetAy* CtrIdhwDcx3Adxl::getNewCmdGetAy() {
	CmdGetAy* cmd = new CmdGetAy();

	cmd->addParRet("ay", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrIdhwDcx3Adxl::getAy(
			smallint& ay
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetAy();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("adxl", "getAy", cmd->cref, "", "", true, true);
	else {
		ay = cmd->parsRet["ay"].getSmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

CtrIdhwDcx3Adxl::CmdGetAz* CtrIdhwDcx3Adxl::getNewCmdGetAz() {
	CmdGetAz* cmd = new CmdGetAz();

	cmd->addParRet("az", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrIdhwDcx3Adxl::getAz(
			smallint& az
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetAz();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("adxl", "getAz", cmd->cref, "", "", true, true);
	else {
		az = cmd->parsRet["az"].getSmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

