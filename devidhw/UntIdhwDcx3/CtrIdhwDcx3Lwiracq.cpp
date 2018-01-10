/**
  * \file CtrIdhwDcx3Lwiracq.cpp
  * lwiracq controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwDcx3Lwiracq.h"

/******************************************************************************
 class CtrIdhwDcx3Lwiracq::CmdGetFrame
 ******************************************************************************/

CtrIdhwDcx3Lwiracq::CmdGetFrame::CmdGetFrame() : Cmd(0x06, VecVCommand::GETFRAME, Cmd::VecVRettype::MULT) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwDcx3Lwiracq::CmdGetFrame::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst, const utinyint tixVDcx3PmmuSlot, const utinyint avlpglen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwDcx3Lwiracq::CmdGetFrame::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tkst"].getUint(), parsRet["tixVDcx3PmmuSlot"].getTix(), parsRet["avlpglen"].getUtinyint());
};

/******************************************************************************
 class CtrIdhwDcx3Lwiracq::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwDcx3Lwiracq::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "getframe") return GETFRAME;

	return(0);
};

string CtrIdhwDcx3Lwiracq::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETFRAME) return("getFrame");

	return("");
};

void CtrIdhwDcx3Lwiracq::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GETFRAME};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Lwiracq::VecVDepth
 ******************************************************************************/

utinyint CtrIdhwDcx3Lwiracq::VecVDepth::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "d2") return D2;
	else if (s == "d4") return D4;
	else if (s == "d8") return D8;
	else if (s == "d12") return D12;
	else if (s == "d14") return D14;

	return(0);
};

string CtrIdhwDcx3Lwiracq::VecVDepth::getSref(
			const utinyint tix
		) {
	if (tix == D2) return("d2");
	else if (tix == D4) return("d4");
	else if (tix == D8) return("d8");
	else if (tix == D12) return("d12");
	else if (tix == D14) return("d14");

	return("");
};

void CtrIdhwDcx3Lwiracq::VecVDepth::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {D2,D4,D8,D12,D14};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Lwiracq
 ******************************************************************************/

CtrIdhwDcx3Lwiracq::CtrIdhwDcx3Lwiracq(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwDcx3Lwiracq::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwDcx3Lwiracq::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwDcx3Lwiracq::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwDcx3Lwiracq::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETFRAME) cmd = getNewCmdGetFrame();

	return cmd;
};

CtrIdhwDcx3Lwiracq::CmdGetFrame* CtrIdhwDcx3Lwiracq::getNewCmdGetFrame(
			const utinyint tixVDepth
		) {
	CmdGetFrame* cmd = new CmdGetFrame();

	cmd->addParInv("tixVDepth", Par::VecVType::TIX, CtrIdhwDcx3Lwiracq::VecVDepth::getTix, CtrIdhwDcx3Lwiracq::VecVDepth::getSref, CtrIdhwDcx3Lwiracq::VecVDepth::fillFeed);

	cmd->parsInv["tixVDepth"].setTix(tixVDepth);

	cmd->addParRet("tkst", Par::VecVType::UINT);
	cmd->addParRet("tixVDcx3PmmuSlot", Par::VecVType::TIX);
	cmd->addParRet("avlpglen", Par::VecVType::UTINYINT);

	return cmd;
};

