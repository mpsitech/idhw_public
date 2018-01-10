/**
  * \file CtrIdhwDcx3Qcdif.cpp
  * qcdif controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "CtrIdhwDcx3Qcdif.h"

/******************************************************************************
 class CtrIdhwDcx3Qcdif::VecVCommand
 ******************************************************************************/

utinyint CtrIdhwDcx3Qcdif::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "reset") return RESET;
	else if (s == "read") return READ;
	else if (s == "write") return WRITE;

	return(0);
};

string CtrIdhwDcx3Qcdif::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == RESET) return("reset");
	else if (tix == READ) return("read");
	else if (tix == WRITE) return("write");

	return("");
};

void CtrIdhwDcx3Qcdif::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {RESET,READ,WRITE};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrIdhwDcx3Qcdif::VecVError
 ******************************************************************************/

utinyint CtrIdhwDcx3Qcdif::VecVError::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "bufxfer") return BUFXFER;

	return(0);
};

string CtrIdhwDcx3Qcdif::VecVError::getSref(
			const utinyint tix
		) {
	if (tix == BUFXFER) return("bufxfer");

	return("");
};

string CtrIdhwDcx3Qcdif::VecVError::getTitle(
			const utinyint tix
		) {
	if (tix == BUFXFER) return("buffer transfer error");

	return("");
};

/******************************************************************************
 class CtrIdhwDcx3Qcdif
 ******************************************************************************/

CtrIdhwDcx3Qcdif::CtrIdhwDcx3Qcdif(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) : CtrIdhw(xchg, ixVTarget, uref) {
};

utinyint CtrIdhwDcx3Qcdif::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrIdhwDcx3Qcdif::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrIdhwDcx3Qcdif::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrIdhwDcx3Qcdif::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::RESET) cmd = getNewCmdReset();
	else if (tixVCommand == VecVCommand::READ) cmd = getNewCmdRead();
	else if (tixVCommand == VecVCommand::WRITE) cmd = getNewCmdWrite();

	return cmd;
};

Cmd* CtrIdhwDcx3Qcdif::getNewCmdReset() {
	Cmd* cmd = new Cmd(0x0A, VecVCommand::RESET, Cmd::VecVRettype::VOID);

	return cmd;
};

void CtrIdhwDcx3Qcdif::reset(
			const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdReset();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("qcdif", "reset", cmd->cref, VecVError::getSref(cmd->err.tixVError), VecVError::getTitle(cmd->err.tixVError), true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* CtrIdhwDcx3Qcdif::getNewCmdRead(
			const utinyint tixWIcm2Buffer
			, const uint reqLen
		) {
	Cmd* cmd = new Cmd(0x0A, VecVCommand::READ, Cmd::VecVRettype::DFRSNG);

	cmd->addParInv("tixWIcm2Buffer", Par::VecVType::TIX, VecWIdhwIcm2Buffer::getTix, VecWIdhwIcm2Buffer::getSref, VecWIdhwIcm2Buffer::fillFeed);
	cmd->addParInv("reqLen", Par::VecVType::UINT);

	cmd->parsInv["tixWIcm2Buffer"].setTix(tixWIcm2Buffer);
	cmd->parsInv["reqLen"].setUint(reqLen);

	return cmd;
};

Cmd* CtrIdhwDcx3Qcdif::getNewCmdWrite(
			const utinyint tixWIcm2Buffer
			, const uint reqLen
		) {
	Cmd* cmd = new Cmd(0x0A, VecVCommand::WRITE, Cmd::VecVRettype::DFRSNG);

	cmd->addParInv("tixWIcm2Buffer", Par::VecVType::TIX, VecWIdhwIcm2Buffer::getTix, VecWIdhwIcm2Buffer::getSref, VecWIdhwIcm2Buffer::fillFeed);
	cmd->addParInv("reqLen", Par::VecVType::UINT);

	cmd->parsInv["tixWIcm2Buffer"].setTix(tixWIcm2Buffer);
	cmd->parsInv["reqLen"].setUint(reqLen);

	return cmd;
};

string CtrIdhwDcx3Qcdif::getSrefByTixVError(
			const utinyint tixVError
		) {
	return VecVError::getSref(tixVError);
};

string CtrIdhwDcx3Qcdif::getTitleByTixVError(
			const utinyint tixVError
		) {
	return VecVError::getTitle(tixVError);
};

Err CtrIdhwDcx3Qcdif::getNewErr(
			const utinyint tixVError
		) {
	Err err;

	if (tixVError == VecVError::BUFXFER) err = getNewErrBufxfer();

	return err;
};

Err CtrIdhwDcx3Qcdif::getNewErrBufxfer() {
	Err err(VecDbeVAction::ERR, VecVError::BUFXFER);

	return err;
};

