/**
  * \file CtrIdhwIcm2Roic.cpp
  * roic controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwIcm2Roic.h"

/******************************************************************************
 class CtrIdhwIcm2Roic::VecVBias
 ******************************************************************************/

utinyint CtrIdhwIcm2Roic::VecVBias::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "baseline") return BASELINE;
	else if (s == "decr16") return DECR16;
	else if (s == "decr32") return DECR32;
	else if (s == "decr48") return DECR48;

	return(0);
};

string CtrIdhwIcm2Roic::VecVBias::getSref(
			const utinyint tix
		) {
	if (tix == BASELINE) return("baseline");
	else if (tix == DECR16) return("decr16");
	else if (tix == DECR32) return("decr32");
	else if (tix == DECR48) return("decr48");

	return("");
};

string CtrIdhwIcm2Roic::VecVBias::getTitle(
			const utinyint tix
		) {
	return(getSref(tix));

	return("");
};

void CtrIdhwIcm2Roic::VecVBias::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {BASELINE,DECR16,DECR32,DECR48};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Roic::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwIcm2Roic::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setcmtclk") return SETCMTCLK;
	else if (s == "setmode") return SETMODE;
	else if (s == "setpixel") return SETPIXEL;

	return(0);
};

string CtrIdhwIcm2Roic::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETCMTCLK) return("setCmtclk");
	else if (tix == SETMODE) return("setMode");
	else if (tix == SETPIXEL) return("setPixel");

	return("");
};

void CtrIdhwIcm2Roic::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETCMTCLK,SETMODE,SETPIXEL};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwIcm2Roic
 ******************************************************************************/

CtrIdhwIcm2Roic::CtrIdhwIcm2Roic(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwIcm2Roic::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwIcm2Roic::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwIcm2Roic::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwIcm2Roic::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETCMTCLK) cmd = getNewCmdSetCmtclk();
	else if (tixVCommand == VecVCommand::SETMODE) cmd = getNewCmdSetMode();
	else if (tixVCommand == VecVCommand::SETPIXEL) cmd = getNewCmdSetPixel();

	return cmd;
};

Cmd* CtrIdhwIcm2Roic::getNewCmdSetCmtclk(
			const bool cmtrng
			, const usmallint Tcmtclk
			, const usmallint tdphi
		) {
	Cmd* cmd = new Cmd(0x05, VecVCommand::SETCMTCLK, Cmd::VecVRettype::VOID);

	cmd->addParInv("cmtrng", Par::VecVType::_BOOL);
	cmd->addParInv("Tcmtclk", Par::VecVType::USMALLINT);
	cmd->addParInv("tdphi", Par::VecVType::USMALLINT);

	cmd->parsInv["cmtrng"].setBool(cmtrng);
	cmd->parsInv["Tcmtclk"].setUsmallint(Tcmtclk);
	cmd->parsInv["tdphi"].setUsmallint(tdphi);

	return cmd;
};

void CtrIdhwIcm2Roic::setCmtclk(
			const bool cmtrng
			, const usmallint Tcmtclk
			, const usmallint tdphi
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetCmtclk(cmtrng, Tcmtclk, tdphi);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("roic", "setCmtclk", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Roic::getNewCmdSetMode(
			const bool fullfrmNotSngpix
			, const utinyint tixVBias
			, const bool acgain300not100
			, const bool dcgain40not20
			, const bool ampbwDecr
		) {
	Cmd* cmd = new Cmd(0x05, VecVCommand::SETMODE, Cmd::VecVRettype::VOID);

	cmd->addParInv("fullfrmNotSngpix", Par::VecVType::_BOOL);
	cmd->addParInv("tixVBias", Par::VecVType::TIX, CtrIdhwIcm2Roic::VecVBias::getTix, CtrIdhwIcm2Roic::VecVBias::getSref, CtrIdhwIcm2Roic::VecVBias::fillFeed);
	cmd->addParInv("acgain300not100", Par::VecVType::_BOOL);
	cmd->addParInv("dcgain40not20", Par::VecVType::_BOOL);
	cmd->addParInv("ampbwDecr", Par::VecVType::_BOOL);

	cmd->parsInv["fullfrmNotSngpix"].setBool(fullfrmNotSngpix);
	cmd->parsInv["tixVBias"].setTix(tixVBias);
	cmd->parsInv["acgain300not100"].setBool(acgain300not100);
	cmd->parsInv["dcgain40not20"].setBool(dcgain40not20);
	cmd->parsInv["ampbwDecr"].setBool(ampbwDecr);

	return cmd;
};

void CtrIdhwIcm2Roic::setMode(
			const bool fullfrmNotSngpix
			, const utinyint tixVBias
			, const bool acgain300not100
			, const bool dcgain40not20
			, const bool ampbwDecr
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetMode(fullfrmNotSngpix, tixVBias, acgain300not100, dcgain40not20, ampbwDecr);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("roic", "setMode", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwIcm2Roic::getNewCmdSetPixel(
			const utinyint row
			, const utinyint col
		) {
	Cmd* cmd = new Cmd(0x05, VecVCommand::SETPIXEL, Cmd::VecVRettype::VOID);

	cmd->addParInv("row", Par::VecVType::UTINYINT);
	cmd->addParInv("col", Par::VecVType::UTINYINT);

	cmd->parsInv["row"].setUtinyint(row);
	cmd->parsInv["col"].setUtinyint(col);

	return cmd;
};

void CtrIdhwIcm2Roic::setPixel(
			const utinyint row
			, const utinyint col
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetPixel(row, col);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("roic", "setPixel", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

