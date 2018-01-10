/**
  * \file CtrIdhwDcx3Shfbox.cpp
  * shfbox controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwDcx3Shfbox.h"

/******************************************************************************
 class CtrIdhwDcx3Shfbox::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwDcx3Shfbox::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setspicfg") return SETSPICFG;
	else if (s == "setgpiocfg") return SETGPIOCFG;
	else if (s == "setledcfg") return SETLEDCFG;

	return(0);
};

string CtrIdhwDcx3Shfbox::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETSPICFG) return("setSpicfg");
	else if (tix == SETGPIOCFG) return("setGpiocfg");
	else if (tix == SETLEDCFG) return("setLedcfg");

	return("");
};

void CtrIdhwDcx3Shfbox::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETSPICFG,SETGPIOCFG,SETLEDCFG};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Shfbox::VecVGpiocfg
 ******************************************************************************/

utinyint CtrIdhwDcx3Shfbox::VecVGpiocfg::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "vislvisr") return VISLVISR;
	else if (s == "visrvisl") return VISRVISL;

	return(0);
};

string CtrIdhwDcx3Shfbox::VecVGpiocfg::getSref(
			const utinyint tix
		) {
	if (tix == VISLVISR) return("vislVisr");
	else if (tix == VISRVISL) return("visrVisl");

	return("");
};

string CtrIdhwDcx3Shfbox::VecVGpiocfg::getTitle(
			const utinyint tix
		) {
	if (tix == VISLVISR) return("GPIOL: VIS-L, GPIOR: VIS-R");
	else if (tix == VISRVISL) return("GPIOL: VIS-R, GPIOR: VIS-L");

	return("");
};

void CtrIdhwDcx3Shfbox::VecVGpiocfg::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {VISLVISR,VISRVISL};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Shfbox::VecVLedcfg
 ******************************************************************************/

utinyint CtrIdhwDcx3Shfbox::VecVLedcfg::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "led15led60") return LED15LED60;
	else if (s == "led60led15") return LED60LED15;

	return(0);
};

string CtrIdhwDcx3Shfbox::VecVLedcfg::getSref(
			const utinyint tix
		) {
	if (tix == LED15LED60) return("led15Led60");
	else if (tix == LED60LED15) return("led60Led15");

	return("");
};

string CtrIdhwDcx3Shfbox::VecVLedcfg::getTitle(
			const utinyint tix
		) {
	if (tix == LED15LED60) return("LED15: LED15, LED60: LED60");
	else if (tix == LED60LED15) return("LED15: LED60, LED60: LED15");

	return("");
};

void CtrIdhwDcx3Shfbox::VecVLedcfg::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {LED15LED60,LED60LED15};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Shfbox::VecVSpicfg
 ******************************************************************************/

utinyint CtrIdhwDcx3Shfbox::VecVSpicfg::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "thetaphiqcd") return THETAPHIQCD;
	else if (s == "thetaqcdphi") return THETAQCDPHI;
	else if (s == "phithetaqcd") return PHITHETAQCD;
	else if (s == "phiqcdtheta") return PHIQCDTHETA;
	else if (s == "qcdthetaphi") return QCDTHETAPHI;
	else if (s == "qcdphitheta") return QCDPHITHETA;

	return(0);
};

string CtrIdhwDcx3Shfbox::VecVSpicfg::getSref(
			const utinyint tix
		) {
	if (tix == THETAPHIQCD) return("thetaPhiQcd");
	else if (tix == THETAQCDPHI) return("thetaQcdPhi");
	else if (tix == PHITHETAQCD) return("phiThetaQcd");
	else if (tix == PHIQCDTHETA) return("phiQcdTheta");
	else if (tix == QCDTHETAPHI) return("qcdThetaPhi");
	else if (tix == QCDPHITHETA) return("qcdPhiTheta");

	return("");
};

string CtrIdhwDcx3Shfbox::VecVSpicfg::getTitle(
			const utinyint tix
		) {
	if (tix == THETAPHIQCD) return("SPIT: theta axis, SPIP: phi axis, SPIQ: QCD detector");
	else if (tix == THETAQCDPHI) return("SPIT: theta axis, SPIP: QCD detector, SPIQ: phi axis");
	else if (tix == PHITHETAQCD) return("SPIT: phi axis, SPIP: theta axis, SPIQ: QCD detector");
	else if (tix == PHIQCDTHETA) return("SPIT: phi axis, SPIP: QCD detector, SPIQ: theta axis");
	else if (tix == QCDTHETAPHI) return("SPIT: QCD detector, SPIP: theta axis, SPIQ: phi axis");
	else if (tix == QCDPHITHETA) return("SPIT: QCD detector, SPIP: phi axis, SPIQ: theta axis");

	return("");
};

void CtrIdhwDcx3Shfbox::VecVSpicfg::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {THETAPHIQCD,THETAQCDPHI,PHITHETAQCD,PHIQCDTHETA,QCDTHETAPHI,QCDPHITHETA};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Shfbox
 ******************************************************************************/

CtrIdhwDcx3Shfbox::CtrIdhwDcx3Shfbox(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwDcx3Shfbox::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwDcx3Shfbox::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwDcx3Shfbox::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwDcx3Shfbox::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETSPICFG) cmd = getNewCmdSetSpicfg();
	else if (tixVCommand == VecVCommand::SETGPIOCFG) cmd = getNewCmdSetGpiocfg();
	else if (tixVCommand == VecVCommand::SETLEDCFG) cmd = getNewCmdSetLedcfg();

	return cmd;
};

Cmd* CtrIdhwDcx3Shfbox::getNewCmdSetSpicfg(
			const utinyint tixVSpicfg
		) {
	Cmd* cmd = new Cmd(0x0B, VecVCommand::SETSPICFG, Cmd::VecVRettype::VOID);

	cmd->addParInv("tixVSpicfg", Par::VecVType::TIX, CtrIdhwDcx3Shfbox::VecVSpicfg::getTix, CtrIdhwDcx3Shfbox::VecVSpicfg::getSref, CtrIdhwDcx3Shfbox::VecVSpicfg::fillFeed);

	cmd->parsInv["tixVSpicfg"].setTix(tixVSpicfg);

	return cmd;
};

void CtrIdhwDcx3Shfbox::setSpicfg(
			const utinyint tixVSpicfg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetSpicfg(tixVSpicfg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("shfbox", "setSpicfg", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwDcx3Shfbox::getNewCmdSetGpiocfg(
			const utinyint tixVGpiocfg
		) {
	Cmd* cmd = new Cmd(0x0B, VecVCommand::SETGPIOCFG, Cmd::VecVRettype::VOID);

	cmd->addParInv("tixVGpiocfg", Par::VecVType::TIX, CtrIdhwDcx3Shfbox::VecVGpiocfg::getTix, CtrIdhwDcx3Shfbox::VecVGpiocfg::getSref, CtrIdhwDcx3Shfbox::VecVGpiocfg::fillFeed);

	cmd->parsInv["tixVGpiocfg"].setTix(tixVGpiocfg);

	return cmd;
};

void CtrIdhwDcx3Shfbox::setGpiocfg(
			const utinyint tixVGpiocfg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetGpiocfg(tixVGpiocfg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("shfbox", "setGpiocfg", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwDcx3Shfbox::getNewCmdSetLedcfg(
			const utinyint tixVLedcfg
		) {
	Cmd* cmd = new Cmd(0x0B, VecVCommand::SETLEDCFG, Cmd::VecVRettype::VOID);

	cmd->addParInv("tixVLedcfg", Par::VecVType::TIX, CtrIdhwDcx3Shfbox::VecVLedcfg::getTix, CtrIdhwDcx3Shfbox::VecVLedcfg::getSref, CtrIdhwDcx3Shfbox::VecVLedcfg::fillFeed);

	cmd->parsInv["tixVLedcfg"].setTix(tixVLedcfg);

	return cmd;
};

void CtrIdhwDcx3Shfbox::setLedcfg(
			const utinyint tixVLedcfg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetLedcfg(tixVLedcfg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("shfbox", "setLedcfg", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

