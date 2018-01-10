/**
  * \file CtrIdhwIcm2Temp.cpp
  * temp controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwIcm2Temp.h"

/******************************************************************************
 class CtrIdhwIcm2Temp::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwIcm2Temp::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setfan") return SETFAN;
	else if (s == "setrng") return SETRNG;
	else if (s == "settrgntc") return SETTRGNTC;

	return(0);
};

string CtrIdhwIcm2Temp::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETFAN) return("setFan");
	else if (tix == SETRNG) return("setRng");
	else if (tix == SETTRGNTC) return("setTrgNtc");

	return("");
};

void CtrIdhwIcm2Temp::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETFAN,SETRNG,SETTRGNTC};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Temp::VecVFanmode
 ******************************************************************************/

utinyint CtrIdhwIcm2Temp::VecVFanmode::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "off") return OFF;
	else if (s == "offacq") return OFFACQ;
	else if (s == "on") return ON;

	return(0);
};

string CtrIdhwIcm2Temp::VecVFanmode::getSref(
			const utinyint tix
		) {
	if (tix == OFF) return("off");
	else if (tix == OFFACQ) return("offacq");
	else if (tix == ON) return("on");

	return("");
};

string CtrIdhwIcm2Temp::VecVFanmode::getTitle(
			const utinyint tix
		) {
	if (tix == OFF) return("off");
	else if (tix == OFFACQ) return("off during acquisition");
	else if (tix == ON) return("on");

	return("");
};

void CtrIdhwIcm2Temp::VecVFanmode::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {OFF,OFFACQ,ON};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Temp
 ******************************************************************************/

CtrIdhwIcm2Temp::CtrIdhwIcm2Temp(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwIcm2Temp::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwIcm2Temp::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwIcm2Temp::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwIcm2Temp::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETFAN) cmd = getNewCmdSetFan();
	else if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();
	else if (tixVCommand == VecVCommand::SETTRGNTC) cmd = getNewCmdSetTrgNtc();

	return cmd;
};

Cmd* CtrIdhwIcm2Temp::getNewCmdSetFan(
			const utinyint tixVFanmode
			, const usmallint ptlow
			, const usmallint pthigh
		) {
	Cmd* cmd = new Cmd(0x08, VecVCommand::SETFAN, Cmd::VecVRettype::VOID);

	cmd->addParInv("tixVFanmode", Par::VecVType::TIX, CtrIdhwIcm2Temp::VecVFanmode::getTix, CtrIdhwIcm2Temp::VecVFanmode::getSref, CtrIdhwIcm2Temp::VecVFanmode::fillFeed);
	cmd->addParInv("ptlow", Par::VecVType::USMALLINT);
	cmd->addParInv("pthigh", Par::VecVType::USMALLINT);

	cmd->parsInv["tixVFanmode"].setTix(tixVFanmode);
	cmd->parsInv["ptlow"].setUsmallint(ptlow);
	cmd->parsInv["pthigh"].setUsmallint(pthigh);

	return cmd;
};

void CtrIdhwIcm2Temp::setFan(
			const utinyint tixVFanmode
			, const usmallint ptlow
			, const usmallint pthigh
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetFan(tixVFanmode, ptlow, pthigh);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("temp", "setFan", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Temp::getNewCmdSetRng(
			const bool rng
		) {
	Cmd* cmd = new Cmd(0x08, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);

	cmd->parsInv["rng"].setBool(rng);

	return cmd;
};

void CtrIdhwIcm2Temp::setRng(
			const bool rng
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetRng(rng);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("temp", "setRng", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Temp::getNewCmdSetTrgNtc(
			const usmallint ntc
		) {
	Cmd* cmd = new Cmd(0x08, VecVCommand::SETTRGNTC, Cmd::VecVRettype::VOID);

	cmd->addParInv("ntc", Par::VecVType::USMALLINT);

	cmd->parsInv["ntc"].setUsmallint(ntc);

	return cmd;
};

void CtrIdhwIcm2Temp::setTrgNtc(
			const usmallint ntc
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTrgNtc(ntc);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("temp", "setTrgNtc", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

