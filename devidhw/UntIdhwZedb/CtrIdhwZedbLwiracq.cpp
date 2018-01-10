/**
  * \file CtrIdhwZedbLwiracq.cpp
  * lwiracq controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwZedbLwiracq.h"

/******************************************************************************
 class CtrIdhwZedbLwiracq::CmdGetFrame
 ******************************************************************************/

CtrIdhwZedbLwiracq::CmdGetFrame::CmdGetFrame() : Cmd(0x06, VecVCommand::GETFRAME, Cmd::VecVRettype::MULT) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwZedbLwiracq::CmdGetFrame::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst, const utinyint tixVZedbPmmuSlot, const utinyint avlpglen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwZedbLwiracq::CmdGetFrame::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tkst"].getUint(), parsRet["tixVZedbPmmuSlot"].getTix(), parsRet["avlpglen"].getUtinyint());
};

/******************************************************************************
 class CtrIdhwZedbLwiracq::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwZedbLwiracq::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "getframe") return GETFRAME;

	return(0);
};

string CtrIdhwZedbLwiracq::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETFRAME) return("getFrame");

	return("");
};

void CtrIdhwZedbLwiracq::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GETFRAME};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwZedbLwiracq::VecVDepth
 ******************************************************************************/

utinyint CtrIdhwZedbLwiracq::VecVDepth::getTix(
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

string CtrIdhwZedbLwiracq::VecVDepth::getSref(
			const utinyint tix
		) {
	if (tix == D2) return("d2");
	else if (tix == D4) return("d4");
	else if (tix == D8) return("d8");
	else if (tix == D12) return("d12");
	else if (tix == D14) return("d14");

	return("");
};

void CtrIdhwZedbLwiracq::VecVDepth::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {D2,D4,D8,D12,D14};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwZedbLwiracq
 ******************************************************************************/

CtrIdhwZedbLwiracq::CtrIdhwZedbLwiracq(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwZedbLwiracq::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwZedbLwiracq::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwZedbLwiracq::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwZedbLwiracq::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETFRAME) cmd = getNewCmdGetFrame();

	return cmd;
};

CtrIdhwZedbLwiracq::CmdGetFrame* CtrIdhwZedbLwiracq::getNewCmdGetFrame(
			const utinyint tixVDepth
		) {
	CmdGetFrame* cmd = new CmdGetFrame();

	cmd->addParInv("tixVDepth", Par::VecVType::TIX, CtrIdhwZedbLwiracq::VecVDepth::getTix, CtrIdhwZedbLwiracq::VecVDepth::getSref, CtrIdhwZedbLwiracq::VecVDepth::fillFeed);

	cmd->parsInv["tixVDepth"].setTix(tixVDepth);

	cmd->addParRet("tkst", Par::VecVType::UINT);
	cmd->addParRet("tixVZedbPmmuSlot", Par::VecVType::TIX);
	cmd->addParRet("avlpglen", Par::VecVType::UTINYINT);

	return cmd;
};

