/**
  * \file CtrIdhwBss3Pmmu.cpp
  * pmmu controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwBss3Pmmu.h"

/******************************************************************************
 class CtrIdhwBss3Pmmu::CmdAlloc
 ******************************************************************************/

CtrIdhwBss3Pmmu::CmdAlloc::CmdAlloc() : Cmd(0x09, VecVCommand::ALLOC, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void CtrIdhwBss3Pmmu::CmdAlloc::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVSlot)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void CtrIdhwBss3Pmmu::CmdAlloc::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tixVSlot"].getTix());
};

/******************************************************************************
 class CtrIdhwBss3Pmmu::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwBss3Pmmu::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "alloc") return ALLOC;
	else if (s == "free") return FREE;
	else if (s == "readoutbuf0") return READOUTBUF0;
	else if (s == "writeinbuf0") return WRITEINBUF0;

	return(0);
};

string CtrIdhwBss3Pmmu::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == ALLOC) return("alloc");
	else if (tix == FREE) return("free");
	else if (tix == READOUTBUF0) return("readOutbuf0");
	else if (tix == WRITEINBUF0) return("writeInbuf0");

	return("");
};

void CtrIdhwBss3Pmmu::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {ALLOC,FREE,READOUTBUF0,WRITEINBUF0};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwBss3Pmmu::VecVError
 ******************************************************************************/

utinyint CtrIdhwBss3Pmmu::VecVError::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "invalid") return INVALID;

	return(0);
};

string CtrIdhwBss3Pmmu::VecVError::getSref(
			const utinyint tix
		) {
	if (tix == INVALID) return("invalid");

	return("");
};

string CtrIdhwBss3Pmmu::VecVError::getTitle(
			const utinyint tix
		) {
	return(getSref(tix));

	return("");
};

/******************************************************************************
 class CtrIdhwBss3Pmmu::VecVSlot
 ******************************************************************************/

utinyint CtrIdhwBss3Pmmu::VecVSlot::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "void") return VOID;
	else if (s == "s0") return S0;
	else if (s == "s1") return S1;
	else if (s == "s2") return S2;
	else if (s == "s3") return S3;

	return(0);
};

string CtrIdhwBss3Pmmu::VecVSlot::getSref(
			const utinyint tix
		) {
	if (tix == VOID) return("void");
	else if (tix == S0) return("s0");
	else if (tix == S1) return("s1");
	else if (tix == S2) return("s2");
	else if (tix == S3) return("s3");

	return("");
};

string CtrIdhwBss3Pmmu::VecVSlot::getTitle(
			const utinyint tix
		) {
	return(getSref(tix));

	return("");
};

void CtrIdhwBss3Pmmu::VecVSlot::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {VOID,S0,S1,S2,S3};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 class CtrIdhwBss3Pmmu
 ******************************************************************************/

CtrIdhwBss3Pmmu::CtrIdhwBss3Pmmu(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwBss3Pmmu::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwBss3Pmmu::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwBss3Pmmu::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwBss3Pmmu::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::ALLOC) cmd = getNewCmdAlloc();
	else if (tixVCommand == VecVCommand::FREE) cmd = getNewCmdFree();
	else if (tixVCommand == VecVCommand::READOUTBUF0) cmd = getNewCmdReadOutbuf0();
	else if (tixVCommand == VecVCommand::WRITEINBUF0) cmd = getNewCmdWriteInbuf0();

	return cmd;
};

CtrIdhwBss3Pmmu::CmdAlloc* CtrIdhwBss3Pmmu::getNewCmdAlloc(
			const bool dynNotStat
			, const utinyint reqPglen
		) {
	CmdAlloc* cmd = new CmdAlloc();

	cmd->addParInv("dynNotStat", Par::VecVType::_BOOL);
	cmd->addParInv("reqPglen", Par::VecVType::UTINYINT);

	cmd->parsInv["dynNotStat"].setBool(dynNotStat);
	cmd->parsInv["reqPglen"].setUtinyint(reqPglen);

	cmd->addParRet("tixVSlot", Par::VecVType::TIX, CtrIdhwBss3Pmmu::VecVSlot::getTix, CtrIdhwBss3Pmmu::VecVSlot::getSref, CtrIdhwBss3Pmmu::VecVSlot::fillFeed);

	return cmd;
};

void CtrIdhwBss3Pmmu::alloc(
			const bool dynNotStat
			, const utinyint reqPglen
			, utinyint& tixVSlot
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdAlloc(dynNotStat, reqPglen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("pmmu", "alloc", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	else {
		tixVSlot = cmd->parsRet["tixVSlot"].getTix();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Pmmu::getNewCmdFree(
			const utinyint tixVSlot
		) {
	Cmd* cmd = new Cmd(0x09, VecVCommand::FREE, Cmd::VecVRettype::VOID);

	cmd->addParInv("tixVSlot", Par::VecVType::TIX, CtrIdhwBss3Pmmu::VecVSlot::getTix, CtrIdhwBss3Pmmu::VecVSlot::getSref, CtrIdhwBss3Pmmu::VecVSlot::fillFeed);

	cmd->parsInv["tixVSlot"].setTix(tixVSlot);

	return cmd;
};

void CtrIdhwBss3Pmmu::free(
			const utinyint tixVSlot
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdFree(tixVSlot);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("pmmu", "free", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Pmmu::getNewCmdReadOutbuf0(
			const utinyint tixVSlot
			, const bool freeNotKeep
		) {
	Cmd* cmd = new Cmd(0x09, VecVCommand::READOUTBUF0, Cmd::VecVRettype::DFRSNG);

	cmd->addParInv("tixVSlot", Par::VecVType::TIX, CtrIdhwBss3Pmmu::VecVSlot::getTix, CtrIdhwBss3Pmmu::VecVSlot::getSref, CtrIdhwBss3Pmmu::VecVSlot::fillFeed);
	cmd->addParInv("freeNotKeep", Par::VecVType::_BOOL);

	cmd->parsInv["tixVSlot"].setTix(tixVSlot);
	cmd->parsInv["freeNotKeep"].setBool(freeNotKeep);

	return cmd;
};

Cmd* CtrIdhwBss3Pmmu::getNewCmdWriteInbuf0(
			const utinyint tixVSlot
		) {
	Cmd* cmd = new Cmd(0x09, VecVCommand::WRITEINBUF0, Cmd::VecVRettype::DFRSNG);

	cmd->addParInv("tixVSlot", Par::VecVType::TIX, CtrIdhwBss3Pmmu::VecVSlot::getTix, CtrIdhwBss3Pmmu::VecVSlot::getSref, CtrIdhwBss3Pmmu::VecVSlot::fillFeed);

	cmd->parsInv["tixVSlot"].setTix(tixVSlot);

	return cmd;
};

string CtrIdhwBss3Pmmu::getSrefByTixVError(
			const utinyint tixVError
		) {
	return VecVError::getSref(tixVError);
};

string CtrIdhwBss3Pmmu::getTitleByTixVError(
			const utinyint tixVError
		) {
	return VecVError::getTitle(tixVError);
};

Err CtrIdhwBss3Pmmu::getNewErr(
			const utinyint tixVError
		) {
	Err err;

	if (tixVError == VecVError::INVALID) err = getNewErrInvalid();

	return err;
};

Err CtrIdhwBss3Pmmu::getNewErrInvalid() {
	Err err(VecDbeVAction::ERR, VecVError::INVALID);

	return err;
};

