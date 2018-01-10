/**
  * \file CtrIdhwDcx3Align.cpp
  * align controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwDcx3Align.h"

/******************************************************************************
 class CtrIdhwDcx3Align::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwDcx3Align::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setseq") return SETSEQ;

	return(0);
};

string CtrIdhwDcx3Align::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETSEQ) return("setSeq");

	return("");
};

void CtrIdhwDcx3Align::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETSEQ};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Align
 ******************************************************************************/

CtrIdhwDcx3Align::CtrIdhwDcx3Align(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwDcx3Align::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwDcx3Align::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwDcx3Align::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwDcx3Align::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETSEQ) cmd = getNewCmdSetSeq();

	return cmd;
};

Cmd* CtrIdhwDcx3Align::getNewCmdSetSeq(
			const unsigned char* seq
			, const size_t seqlen
		) {
	Cmd* cmd = new Cmd(0x04, VecVCommand::SETSEQ, Cmd::VecVRettype::VOID);

	cmd->addParInv("seq", Par::VecVType::VBLOB, NULL, NULL, NULL, 32);

	cmd->parsInv["seq"].setVblob(seq, seqlen);

	return cmd;
};

void CtrIdhwDcx3Align::setSeq(
			const unsigned char* seq
			, const size_t seqlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetSeq(seq, seqlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("align", "setSeq", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

