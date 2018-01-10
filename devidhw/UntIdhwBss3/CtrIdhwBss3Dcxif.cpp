/**
  * \file CtrIdhwBss3Dcxif.cpp
  * dcxif controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwBss3Dcxif.h"

/******************************************************************************
 class CtrIdhwBss3Dcxif::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwBss3Dcxif::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "reset") return RESET;
	else if (s == "read") return READ;
	else if (s == "write") return WRITE;

	return(0);
};

string CtrIdhwBss3Dcxif::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == RESET) return("reset");
	else if (tix == READ) return("read");
	else if (tix == WRITE) return("write");

	return("");
};

void CtrIdhwBss3Dcxif::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {RESET,READ,WRITE};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwBss3Dcxif::VecVError
 ******************************************************************************/

utinyint CtrIdhwBss3Dcxif::VecVError::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "bufxfer") return BUFXFER;

	return(0);
};

string CtrIdhwBss3Dcxif::VecVError::getSref(
			const utinyint tix
		) {
	if (tix == BUFXFER) return("bufxfer");

	return("");
};

string CtrIdhwBss3Dcxif::VecVError::getTitle(
			const utinyint tix
		) {
	if (tix == BUFXFER) return("buffer transfer error");

	return("");
};

/******************************************************************************
 class CtrIdhwBss3Dcxif
 ******************************************************************************/

CtrIdhwBss3Dcxif::CtrIdhwBss3Dcxif(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwBss3Dcxif::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwBss3Dcxif::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwBss3Dcxif::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwBss3Dcxif::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::RESET) cmd = getNewCmdReset();
	else if (tixVCommand == VecVCommand::READ) cmd = getNewCmdRead();
	else if (tixVCommand == VecVCommand::WRITE) cmd = getNewCmdWrite();

	return cmd;
};

Cmd* CtrIdhwBss3Dcxif::getNewCmdReset() {
	Cmd* cmd = new Cmd(0x05, VecVCommand::RESET, Cmd::VecVRettype::VOID);

	return cmd;
};

void CtrIdhwBss3Dcxif::reset(
			const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdReset();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("dcxif", "reset", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwBss3Dcxif::getNewCmdRead(
			const utinyint tixWDcx3Buffer
			, const uint reqLen
		) {
	Cmd* cmd = new Cmd(0x05, VecVCommand::READ, Cmd::VecVRettype::DFRSNG);

	cmd->addParInv("tixWDcx3Buffer", Par::VecVType::TIX, VecWIdhwDcx3Buffer::getTix, VecWIdhwDcx3Buffer::getSref, VecWIdhwDcx3Buffer::fillFeed);
	cmd->addParInv("reqLen", Par::VecVType::UINT);

	cmd->parsInv["tixWDcx3Buffer"].setTix(tixWDcx3Buffer);
	cmd->parsInv["reqLen"].setUint(reqLen);

	return cmd;
};

Cmd* CtrIdhwBss3Dcxif::getNewCmdWrite(
			const utinyint tixWDcx3Buffer
			, const uint reqLen
		) {
	Cmd* cmd = new Cmd(0x05, VecVCommand::WRITE, Cmd::VecVRettype::DFRSNG);

	cmd->addParInv("tixWDcx3Buffer", Par::VecVType::TIX, VecWIdhwDcx3Buffer::getTix, VecWIdhwDcx3Buffer::getSref, VecWIdhwDcx3Buffer::fillFeed);
	cmd->addParInv("reqLen", Par::VecVType::UINT);

	cmd->parsInv["tixWDcx3Buffer"].setTix(tixWDcx3Buffer);
	cmd->parsInv["reqLen"].setUint(reqLen);

	return cmd;
};

string CtrIdhwBss3Dcxif::getSrefByTixVError(
			const utinyint tixVError
		) {
	return VecVError::getSref(tixVError);
};

string CtrIdhwBss3Dcxif::getTitleByTixVError(
			const utinyint tixVError
		) {
	return VecVError::getTitle(tixVError);
};

Err CtrIdhwBss3Dcxif::getNewErr(
			const utinyint tixVError
		) {
	Err err;

	if (tixVError == VecVError::BUFXFER) err = getNewErrBufxfer();

	return err;
};

Err CtrIdhwBss3Dcxif::getNewErrBufxfer() {
	Err err(VecDbeVAction::ERR, VecVError::BUFXFER);

	return err;
};

