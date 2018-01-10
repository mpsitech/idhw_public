/**
  * \file CtrIdhwIcm2Vset.cpp
  * vset controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwIcm2Vset.h"

/******************************************************************************
 class CtrIdhwIcm2Vset::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwIcm2Vset::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setvdd") return SETVDD;
	else if (s == "setvref") return SETVREF;
	else if (s == "setvtec") return SETVTEC;

	return(0);
};

string CtrIdhwIcm2Vset::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETVDD) return("setVdd");
	else if (tix == SETVREF) return("setVref");
	else if (tix == SETVTEC) return("setVtec");

	return("");
};

void CtrIdhwIcm2Vset::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETVDD,SETVREF,SETVTEC};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Vset
 ******************************************************************************/

CtrIdhwIcm2Vset::CtrIdhwIcm2Vset(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwIcm2Vset::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwIcm2Vset::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwIcm2Vset::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwIcm2Vset::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETVDD) cmd = getNewCmdSetVdd();
	else if (tixVCommand == VecVCommand::SETVREF) cmd = getNewCmdSetVref();
	else if (tixVCommand == VecVCommand::SETVTEC) cmd = getNewCmdSetVtec();

	return cmd;
};

Cmd* CtrIdhwIcm2Vset::getNewCmdSetVdd(
			const usmallint Vdd
		) {
	Cmd* cmd = new Cmd(0x0B, VecVCommand::SETVDD, Cmd::VecVRettype::VOID);

	cmd->addParInv("Vdd", Par::VecVType::USMALLINT);

	cmd->parsInv["Vdd"].setUsmallint(Vdd);

	return cmd;
};

void CtrIdhwIcm2Vset::setVdd(
			const usmallint Vdd
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetVdd(Vdd);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("vset", "setVdd", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Vset::getNewCmdSetVref(
			const usmallint Vref
		) {
	Cmd* cmd = new Cmd(0x0B, VecVCommand::SETVREF, Cmd::VecVRettype::VOID);

	cmd->addParInv("Vref", Par::VecVType::USMALLINT);

	cmd->parsInv["Vref"].setUsmallint(Vref);

	return cmd;
};

void CtrIdhwIcm2Vset::setVref(
			const usmallint Vref
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetVref(Vref);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("vset", "setVref", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Vset::getNewCmdSetVtec(
			const usmallint Vtec
		) {
	Cmd* cmd = new Cmd(0x0B, VecVCommand::SETVTEC, Cmd::VecVRettype::VOID);

	cmd->addParInv("Vtec", Par::VecVType::USMALLINT);

	cmd->parsInv["Vtec"].setUsmallint(Vtec);

	return cmd;
};

void CtrIdhwIcm2Vset::setVtec(
			const usmallint Vtec
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetVtec(Vtec);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("vset", "setVtec", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

