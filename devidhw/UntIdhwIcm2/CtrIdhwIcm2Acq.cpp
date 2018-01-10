/**
  * \file CtrIdhwIcm2Acq.cpp
  * acq controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwIcm2Acq.h"

/******************************************************************************
 class CtrIdhwIcm2Acq::CmdGetFrame
 ******************************************************************************/

CtrIdhwIcm2Acq::CmdGetFrame::CmdGetFrame() : Cmd(0x03, VecVCommand::GETFRAME, Cmd::VecVRettype::MULT) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwIcm2Acq::CmdGetFrame::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst, const usmallint ntc)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwIcm2Acq::CmdGetFrame::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tkst"].getUint(), parsRet["ntc"].getUsmallint());
};

/******************************************************************************
 class CtrIdhwIcm2Acq::CmdGetPixel
 ******************************************************************************/

CtrIdhwIcm2Acq::CmdGetPixel::CmdGetPixel() : Cmd(0x03, VecVCommand::GETPIXEL, Cmd::VecVRettype::MULT) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwIcm2Acq::CmdGetPixel::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst, const usmallint ntc, const uint pixval)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwIcm2Acq::CmdGetPixel::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tkst"].getUint(), parsRet["ntc"].getUsmallint(), parsRet["pixval"].getUint());
};

/******************************************************************************
 class CtrIdhwIcm2Acq::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwIcm2Acq::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "getframe") return GETFRAME;
	else if (s == "getpixel") return GETPIXEL;
	else if (s == "gettrace") return GETTRACE;
	else if (s == "setadc") return SETADC;
	else if (s == "settfrm") return SETTFRM;

	return(0);
};

string CtrIdhwIcm2Acq::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETFRAME) return("getFrame");
	else if (tix == GETPIXEL) return("getPixel");
	else if (tix == GETTRACE) return("getTrace");
	else if (tix == SETADC) return("setAdc");
	else if (tix == SETTFRM) return("setTfrm");

	return("");
};

void CtrIdhwIcm2Acq::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GETFRAME,GETPIXEL,GETTRACE,SETADC,SETTFRM};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Acq
 ******************************************************************************/

CtrIdhwIcm2Acq::CtrIdhwIcm2Acq(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwIcm2Acq::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwIcm2Acq::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwIcm2Acq::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwIcm2Acq::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETFRAME) cmd = getNewCmdGetFrame();
	else if (tixVCommand == VecVCommand::GETPIXEL) cmd = getNewCmdGetPixel();
	else if (tixVCommand == VecVCommand::GETTRACE) cmd = getNewCmdGetTrace();
	else if (tixVCommand == VecVCommand::SETADC) cmd = getNewCmdSetAdc();
	else if (tixVCommand == VecVCommand::SETTFRM) cmd = getNewCmdSetTfrm();

	return cmd;
};

CtrIdhwIcm2Acq::CmdGetFrame* CtrIdhwIcm2Acq::getNewCmdGetFrame(
			const usmallint Nsmp
		) {
	CmdGetFrame* cmd = new CmdGetFrame();

	cmd->addParInv("Nsmp", Par::VecVType::USMALLINT);

	cmd->parsInv["Nsmp"].setUsmallint(Nsmp);

	cmd->addParRet("tkst", Par::VecVType::UINT);
	cmd->addParRet("ntc", Par::VecVType::USMALLINT);

	return cmd;
};

CtrIdhwIcm2Acq::CmdGetPixel* CtrIdhwIcm2Acq::getNewCmdGetPixel(
			const usmallint Nsmp
		) {
	CmdGetPixel* cmd = new CmdGetPixel();

	cmd->addParInv("Nsmp", Par::VecVType::USMALLINT);

	cmd->parsInv["Nsmp"].setUsmallint(Nsmp);

	cmd->addParRet("tkst", Par::VecVType::UINT);
	cmd->addParRet("ntc", Par::VecVType::USMALLINT);
	cmd->addParRet("pixval", Par::VecVType::UINT);

	return cmd;
};

Cmd* CtrIdhwIcm2Acq::getNewCmdGetTrace(
			const usmallint Nsmp
		) {
	Cmd* cmd = new Cmd(0x03, VecVCommand::GETTRACE, Cmd::VecVRettype::DFRSNG);

	cmd->addParInv("Nsmp", Par::VecVType::USMALLINT);

	cmd->parsInv["Nsmp"].setUsmallint(Nsmp);

	return cmd;
};

Cmd* CtrIdhwIcm2Acq::getNewCmdSetAdc(
			const utinyint cps
			, const usmallint tdly
		) {
	Cmd* cmd = new Cmd(0x03, VecVCommand::SETADC, Cmd::VecVRettype::VOID);

	cmd->addParInv("cps", Par::VecVType::UTINYINT);
	cmd->addParInv("tdly", Par::VecVType::USMALLINT);

	cmd->parsInv["cps"].setUtinyint(cps);
	cmd->parsInv["tdly"].setUsmallint(tdly);

	return cmd;
};

void CtrIdhwIcm2Acq::setAdc(
			const utinyint cps
			, const usmallint tdly
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetAdc(cps, tdly);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("acq", "setAdc", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Acq::getNewCmdSetTfrm(
			const usmallint Tfrm
		) {
	Cmd* cmd = new Cmd(0x03, VecVCommand::SETTFRM, Cmd::VecVRettype::VOID);

	cmd->addParInv("Tfrm", Par::VecVType::USMALLINT);

	cmd->parsInv["Tfrm"].setUsmallint(Tfrm);

	return cmd;
};

void CtrIdhwIcm2Acq::setTfrm(
			const usmallint Tfrm
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTfrm(Tfrm);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("acq", "setTfrm", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

