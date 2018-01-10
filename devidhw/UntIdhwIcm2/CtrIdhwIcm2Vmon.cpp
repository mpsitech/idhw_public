/**
  * \file CtrIdhwIcm2Vmon.cpp
  * vmon controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwIcm2Vmon.h"

/******************************************************************************
 class CtrIdhwIcm2Vmon::CmdGetVref
 ******************************************************************************/

CtrIdhwIcm2Vmon::CmdGetVref::CmdGetVref() : Cmd(0x0A, VecVCommand::GETVREF, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwIcm2Vmon::CmdGetVref::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vref)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwIcm2Vmon::CmdGetVref::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["Vref"].getUsmallint());
};

/******************************************************************************
 class CtrIdhwIcm2Vmon::CmdGetVdd
 ******************************************************************************/

CtrIdhwIcm2Vmon::CmdGetVdd::CmdGetVdd() : Cmd(0x0A, VecVCommand::GETVDD, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwIcm2Vmon::CmdGetVdd::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vdd)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwIcm2Vmon::CmdGetVdd::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["Vdd"].getUsmallint());
};

/******************************************************************************
 class CtrIdhwIcm2Vmon::CmdGetVtec
 ******************************************************************************/

CtrIdhwIcm2Vmon::CmdGetVtec::CmdGetVtec() : Cmd(0x0A, VecVCommand::GETVTEC, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwIcm2Vmon::CmdGetVtec::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vtec)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwIcm2Vmon::CmdGetVtec::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["Vtec"].getUsmallint());
};

/******************************************************************************
 class CtrIdhwIcm2Vmon::CmdGetNtc
 ******************************************************************************/

CtrIdhwIcm2Vmon::CmdGetNtc::CmdGetNtc() : Cmd(0x0A, VecVCommand::GETNTC, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwIcm2Vmon::CmdGetNtc::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint ntc)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwIcm2Vmon::CmdGetNtc::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["ntc"].getUsmallint());
};

/******************************************************************************
 class CtrIdhwIcm2Vmon::CmdGetPt
 ******************************************************************************/

CtrIdhwIcm2Vmon::CmdGetPt::CmdGetPt() : Cmd(0x0A, VecVCommand::GETPT, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwIcm2Vmon::CmdGetPt::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint pt)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwIcm2Vmon::CmdGetPt::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["pt"].getUsmallint());
};

/******************************************************************************
 class CtrIdhwIcm2Vmon::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwIcm2Vmon::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "getvref") return GETVREF;
	else if (s == "getvdd") return GETVDD;
	else if (s == "getvtec") return GETVTEC;
	else if (s == "getntc") return GETNTC;
	else if (s == "getpt") return GETPT;

	return(0);
};

string CtrIdhwIcm2Vmon::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETVREF) return("getVref");
	else if (tix == GETVDD) return("getVdd");
	else if (tix == GETVTEC) return("getVtec");
	else if (tix == GETNTC) return("getNtc");
	else if (tix == GETPT) return("getPt");

	return("");
};

void CtrIdhwIcm2Vmon::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GETVREF,GETVDD,GETVTEC,GETNTC,GETPT};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Vmon
 ******************************************************************************/

CtrIdhwIcm2Vmon::CtrIdhwIcm2Vmon(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwIcm2Vmon::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwIcm2Vmon::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwIcm2Vmon::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwIcm2Vmon::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETVREF) cmd = getNewCmdGetVref();
	else if (tixVCommand == VecVCommand::GETVDD) cmd = getNewCmdGetVdd();
	else if (tixVCommand == VecVCommand::GETVTEC) cmd = getNewCmdGetVtec();
	else if (tixVCommand == VecVCommand::GETNTC) cmd = getNewCmdGetNtc();
	else if (tixVCommand == VecVCommand::GETPT) cmd = getNewCmdGetPt();

	return cmd;
};

CtrIdhwIcm2Vmon::CmdGetVref* CtrIdhwIcm2Vmon::getNewCmdGetVref() {
	CmdGetVref* cmd = new CmdGetVref();

	cmd->addParRet("Vref", Par::VecVType::USMALLINT);

	return cmd;
};

void CtrIdhwIcm2Vmon::getVref(
			usmallint& Vref
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetVref();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("vmon", "getVref", cmd->cref, "", "", true, true);
	else {
		Vref = cmd->parsRet["Vref"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

CtrIdhwIcm2Vmon::CmdGetVdd* CtrIdhwIcm2Vmon::getNewCmdGetVdd() {
	CmdGetVdd* cmd = new CmdGetVdd();

	cmd->addParRet("Vdd", Par::VecVType::USMALLINT);

	return cmd;
};

void CtrIdhwIcm2Vmon::getVdd(
			usmallint& Vdd
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetVdd();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("vmon", "getVdd", cmd->cref, "", "", true, true);
	else {
		Vdd = cmd->parsRet["Vdd"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

CtrIdhwIcm2Vmon::CmdGetVtec* CtrIdhwIcm2Vmon::getNewCmdGetVtec() {
	CmdGetVtec* cmd = new CmdGetVtec();

	cmd->addParRet("Vtec", Par::VecVType::USMALLINT);

	return cmd;
};

void CtrIdhwIcm2Vmon::getVtec(
			usmallint& Vtec
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetVtec();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("vmon", "getVtec", cmd->cref, "", "", true, true);
	else {
		Vtec = cmd->parsRet["Vtec"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

CtrIdhwIcm2Vmon::CmdGetNtc* CtrIdhwIcm2Vmon::getNewCmdGetNtc() {
	CmdGetNtc* cmd = new CmdGetNtc();

	cmd->addParRet("ntc", Par::VecVType::USMALLINT);

	return cmd;
};

void CtrIdhwIcm2Vmon::getNtc(
			usmallint& ntc
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetNtc();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("vmon", "getNtc", cmd->cref, "", "", true, true);
	else {
		ntc = cmd->parsRet["ntc"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

CtrIdhwIcm2Vmon::CmdGetPt* CtrIdhwIcm2Vmon::getNewCmdGetPt() {
	CmdGetPt* cmd = new CmdGetPt();

	cmd->addParRet("pt", Par::VecVType::USMALLINT);

	return cmd;
};

void CtrIdhwIcm2Vmon::getPt(
			usmallint& pt
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetPt();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("vmon", "getPt", cmd->cref, "", "", true, true);
	else {
		pt = cmd->parsRet["pt"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

