/**
  * \file CtrIdhwIcm2Wavegen.cpp
  * wavegen controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwIcm2Wavegen.h"

/******************************************************************************
 class CtrIdhwIcm2Wavegen::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwIcm2Wavegen::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setrng") return SETRNG;
	else if (s == "setwave") return SETWAVE;

	return(0);
};

string CtrIdhwIcm2Wavegen::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETRNG) return("setRng");
	else if (tix == SETWAVE) return("setWave");

	return("");
};

void CtrIdhwIcm2Wavegen::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETRNG,SETWAVE};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Wavegen
 ******************************************************************************/

CtrIdhwIcm2Wavegen::CtrIdhwIcm2Wavegen(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwIcm2Wavegen::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwIcm2Wavegen::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwIcm2Wavegen::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwIcm2Wavegen::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();
	else if (tixVCommand == VecVCommand::SETWAVE) cmd = getNewCmdSetWave();

	return cmd;
};

Cmd* CtrIdhwIcm2Wavegen::getNewCmdSetRng(
			const bool rng
		) {
	Cmd* cmd = new Cmd(0x0C, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);

	cmd->parsInv["rng"].setBool(rng);

	return cmd;
};

void CtrIdhwIcm2Wavegen::setRng(
			const bool rng
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetRng(rng);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("wavegen", "setRng", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Wavegen::getNewCmdSetWave(
			const usmallint tdly
			, const usmallint Nsmp
			, const usmallint Tsmp
		) {
	Cmd* cmd = new Cmd(0x0C, VecVCommand::SETWAVE, Cmd::VecVRettype::VOID);

	cmd->addParInv("tdly", Par::VecVType::USMALLINT);
	cmd->addParInv("Nsmp", Par::VecVType::USMALLINT);
	cmd->addParInv("Tsmp", Par::VecVType::USMALLINT);

	cmd->parsInv["tdly"].setUsmallint(tdly);
	cmd->parsInv["Nsmp"].setUsmallint(Nsmp);
	cmd->parsInv["Tsmp"].setUsmallint(Tsmp);

	return cmd;
};

void CtrIdhwIcm2Wavegen::setWave(
			const usmallint tdly
			, const usmallint Nsmp
			, const usmallint Tsmp
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetWave(tdly, Nsmp, Tsmp);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("wavegen", "setWave", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

