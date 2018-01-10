/**
  * \file UntIdhwAxs2.cpp
  * axis2 unit (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwAxs2.h"

/******************************************************************************
 class UntIdhwAxs2::CmdGetState
 ******************************************************************************/

UntIdhwAxs2::CmdGetState::CmdGetState() : Cmd(VecVIdhwAxs2Command::GETSTATE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwAxs2::CmdGetState::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVState)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwAxs2::CmdGetState::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tixVState"].getTix());
};

/******************************************************************************
 class UntIdhwAxs2::CmdGetAdcCp
 ******************************************************************************/

UntIdhwAxs2::CmdGetAdcCp::CmdGetAdcCp() : Cmd(VecVIdhwAxs2Command::GETADCCP, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwAxs2::CmdGetAdcCp::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Cp)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwAxs2::CmdGetAdcCp::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["Cp"].getUsmallint());
};

/******************************************************************************
 class UntIdhwAxs2::CmdGetAdcCn
 ******************************************************************************/

UntIdhwAxs2::CmdGetAdcCn::CmdGetAdcCn() : Cmd(VecVIdhwAxs2Command::GETADCCN, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwAxs2::CmdGetAdcCn::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Cn)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwAxs2::CmdGetAdcCn::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["Cn"].getUsmallint());
};

/******************************************************************************
 class UntIdhwAxs2::CmdGetAdcSp
 ******************************************************************************/

UntIdhwAxs2::CmdGetAdcSp::CmdGetAdcSp() : Cmd(VecVIdhwAxs2Command::GETADCSP, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwAxs2::CmdGetAdcSp::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Sp)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwAxs2::CmdGetAdcSp::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["Sp"].getUsmallint());
};

/******************************************************************************
 class UntIdhwAxs2::CmdGetAdcSn
 ******************************************************************************/

UntIdhwAxs2::CmdGetAdcSn::CmdGetAdcSn() : Cmd(VecVIdhwAxs2Command::GETADCSN, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwAxs2::CmdGetAdcSn::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Sn)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwAxs2::CmdGetAdcSn::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["Sn"].getUsmallint());
};

/******************************************************************************
 class UntIdhwAxs2::CmdGetAdcVgmr
 ******************************************************************************/

UntIdhwAxs2::CmdGetAdcVgmr::CmdGetAdcVgmr() : Cmd(VecVIdhwAxs2Command::GETADCVGMR, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwAxs2::CmdGetAdcVgmr::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vgmr)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwAxs2::CmdGetAdcVgmr::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["Vgmr"].getUsmallint());
};

/******************************************************************************
 class UntIdhwAxs2::CmdGetTickval
 ******************************************************************************/

UntIdhwAxs2::CmdGetTickval::CmdGetTickval() : Cmd(VecVIdhwAxs2Command::GETTICKVAL, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwAxs2::CmdGetTickval::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint tickval)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwAxs2::CmdGetTickval::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tickval"].getSmallint());
};

/******************************************************************************
 class UntIdhwAxs2::CmdGetTpi
 ******************************************************************************/

UntIdhwAxs2::CmdGetTpi::CmdGetTpi() : Cmd(VecVIdhwAxs2Command::GETTPI, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwAxs2::CmdGetTpi::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint tickval)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwAxs2::CmdGetTpi::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["tickval"].getSmallint());
};

/******************************************************************************
 class UntIdhwAxs2::CmdGetAngle
 ******************************************************************************/

UntIdhwAxs2::CmdGetAngle::CmdGetAngle() : Cmd(VecVIdhwAxs2Command::GETANGLE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwAxs2::CmdGetAngle::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint angle)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwAxs2::CmdGetAngle::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["angle"].getSmallint());
};

/******************************************************************************
 class UntIdhwAxs2
 ******************************************************************************/

UntIdhwAxs2::UntIdhwAxs2(
			XchgIdhw* xchg
			, const uint ixVTarget
		) : UntIdhw(xchg, ixVTarget) {
	uref = xchg->addUnt(this);
};

UntIdhwAxs2::~UntIdhwAxs2() {
	xchg->removeUntByUref(uref);
};

utinyint UntIdhwAxs2::getTixVCommandBySref(
			const string& sref
		) {
	return VecVIdhwAxs2Command::getTix(sref);
};

string UntIdhwAxs2::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVIdhwAxs2Command::getSref(tixVCommand);
};

void UntIdhwAxs2::fillFeedFCommand(
			Feed& feed
		) {
	VecVIdhwAxs2Command::fillFeed(feed);
};

Cmd* UntIdhwAxs2::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVIdhwAxs2Command::GETSTATE) cmd = getNewCmdGetState();
	else if (tixVCommand == VecVIdhwAxs2Command::SETVMOT) cmd = getNewCmdSetVmot();
	else if (tixVCommand == VecVIdhwAxs2Command::SETMOTDIR) cmd = getNewCmdSetMotdir();
	else if (tixVCommand == VecVIdhwAxs2Command::SETSINCOSCOEFF) cmd = getNewCmdSetSincosCoeff();
	else if (tixVCommand == VecVIdhwAxs2Command::SETPIDCOEFF) cmd = getNewCmdSetPidCoeff();
	else if (tixVCommand == VecVIdhwAxs2Command::GETADCCP) cmd = getNewCmdGetAdcCp();
	else if (tixVCommand == VecVIdhwAxs2Command::GETADCCN) cmd = getNewCmdGetAdcCn();
	else if (tixVCommand == VecVIdhwAxs2Command::GETADCSP) cmd = getNewCmdGetAdcSp();
	else if (tixVCommand == VecVIdhwAxs2Command::GETADCSN) cmd = getNewCmdGetAdcSn();
	else if (tixVCommand == VecVIdhwAxs2Command::GETADCVGMR) cmd = getNewCmdGetAdcVgmr();
	else if (tixVCommand == VecVIdhwAxs2Command::GETTICKVAL) cmd = getNewCmdGetTickval();
	else if (tixVCommand == VecVIdhwAxs2Command::SETTICKVAL) cmd = getNewCmdSetTickval();
	else if (tixVCommand == VecVIdhwAxs2Command::SETTICKVALMIN) cmd = getNewCmdSetTickvalMin();
	else if (tixVCommand == VecVIdhwAxs2Command::SETTICKVALMAX) cmd = getNewCmdSetTickvalMax();
	else if (tixVCommand == VecVIdhwAxs2Command::SETTICKVALTRG) cmd = getNewCmdSetTickvalTrg();
	else if (tixVCommand == VecVIdhwAxs2Command::GETTPI) cmd = getNewCmdGetTpi();
	else if (tixVCommand == VecVIdhwAxs2Command::GETANGLE) cmd = getNewCmdGetAngle();
	else if (tixVCommand == VecVIdhwAxs2Command::SETANGLEMIN) cmd = getNewCmdSetAngleMin();
	else if (tixVCommand == VecVIdhwAxs2Command::SETANGLEMAX) cmd = getNewCmdSetAngleMax();
	else if (tixVCommand == VecVIdhwAxs2Command::SETANGLETRG) cmd = getNewCmdSetAngleTrg();

	return cmd;
};

UntIdhwAxs2::CmdGetState* UntIdhwAxs2::getNewCmdGetState() {
	CmdGetState* cmd = new CmdGetState();

	cmd->addParRet("tixVState", Par::VecVType::TIX, VecVIdhwAxs2State::getTix, VecVIdhwAxs2State::getSref, VecVIdhwAxs2State::fillFeed);

	return cmd;
};

void UntIdhwAxs2::getState(
			utinyint& tixVState
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetState();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getState", cmd->cref, "", "", true, true);
	else {
		tixVState = cmd->parsRet["tixVState"].getTix();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetVmot(
			const utinyint Vmot
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETVMOT, Cmd::VecVRettype::VOID);

	cmd->addParInv("Vmot", Par::VecVType::UTINYINT);

	cmd->parsInv["Vmot"].setUtinyint(Vmot);

	return cmd;
};

void UntIdhwAxs2::setVmot(
			const utinyint Vmot
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetVmot(Vmot);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setVmot", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetMotdir(
			const utinyint tixVMotdir
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETMOTDIR, Cmd::VecVRettype::VOID);

	cmd->addParInv("tixVMotdir", Par::VecVType::TIX, VecVIdhwAxs2Motdir::getTix, VecVIdhwAxs2Motdir::getSref, VecVIdhwAxs2Motdir::fillFeed);

	cmd->parsInv["tixVMotdir"].setTix(tixVMotdir);

	return cmd;
};

void UntIdhwAxs2::setMotdir(
			const utinyint tixVMotdir
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetMotdir(tixVMotdir);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setMotdir", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetSincosCoeff(
			const smallint Ox
			, const smallint Oy
			, const smallint Axm
			, const smallint Aym
			, const smallint phix
			, const smallint phiy
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETSINCOSCOEFF, Cmd::VecVRettype::VOID);

	cmd->addParInv("Ox", Par::VecVType::SMALLINT);
	cmd->addParInv("Oy", Par::VecVType::SMALLINT);
	cmd->addParInv("Axm", Par::VecVType::SMALLINT);
	cmd->addParInv("Aym", Par::VecVType::SMALLINT);
	cmd->addParInv("phix", Par::VecVType::SMALLINT);
	cmd->addParInv("phiy", Par::VecVType::SMALLINT);

	cmd->parsInv["Ox"].setSmallint(Ox);
	cmd->parsInv["Oy"].setSmallint(Oy);
	cmd->parsInv["Axm"].setSmallint(Axm);
	cmd->parsInv["Aym"].setSmallint(Aym);
	cmd->parsInv["phix"].setSmallint(phix);
	cmd->parsInv["phiy"].setSmallint(phiy);

	return cmd;
};

void UntIdhwAxs2::setSincosCoeff(
			const smallint Ox
			, const smallint Oy
			, const smallint Axm
			, const smallint Aym
			, const smallint phix
			, const smallint phiy
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetSincosCoeff(Ox, Oy, Axm, Aym, phix, phiy);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setSincosCoeff", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetPidCoeff(
			const smallint Kp
			, const smallint Ki
			, const smallint Kd
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETPIDCOEFF, Cmd::VecVRettype::VOID);

	cmd->addParInv("Kp", Par::VecVType::SMALLINT);
	cmd->addParInv("Ki", Par::VecVType::SMALLINT);
	cmd->addParInv("Kd", Par::VecVType::SMALLINT);

	cmd->parsInv["Kp"].setSmallint(Kp);
	cmd->parsInv["Ki"].setSmallint(Ki);
	cmd->parsInv["Kd"].setSmallint(Kd);

	return cmd;
};

void UntIdhwAxs2::setPidCoeff(
			const smallint Kp
			, const smallint Ki
			, const smallint Kd
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetPidCoeff(Kp, Ki, Kd);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setPidCoeff", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwAxs2::CmdGetAdcCp* UntIdhwAxs2::getNewCmdGetAdcCp() {
	CmdGetAdcCp* cmd = new CmdGetAdcCp();

	cmd->addParRet("Cp", Par::VecVType::USMALLINT);

	return cmd;
};

void UntIdhwAxs2::getAdcCp(
			usmallint& Cp
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetAdcCp();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getAdcCp", cmd->cref, "", "", true, true);
	else {
		Cp = cmd->parsRet["Cp"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwAxs2::CmdGetAdcCn* UntIdhwAxs2::getNewCmdGetAdcCn() {
	CmdGetAdcCn* cmd = new CmdGetAdcCn();

	cmd->addParRet("Cn", Par::VecVType::USMALLINT);

	return cmd;
};

void UntIdhwAxs2::getAdcCn(
			usmallint& Cn
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetAdcCn();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getAdcCn", cmd->cref, "", "", true, true);
	else {
		Cn = cmd->parsRet["Cn"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwAxs2::CmdGetAdcSp* UntIdhwAxs2::getNewCmdGetAdcSp() {
	CmdGetAdcSp* cmd = new CmdGetAdcSp();

	cmd->addParRet("Sp", Par::VecVType::USMALLINT);

	return cmd;
};

void UntIdhwAxs2::getAdcSp(
			usmallint& Sp
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetAdcSp();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getAdcSp", cmd->cref, "", "", true, true);
	else {
		Sp = cmd->parsRet["Sp"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwAxs2::CmdGetAdcSn* UntIdhwAxs2::getNewCmdGetAdcSn() {
	CmdGetAdcSn* cmd = new CmdGetAdcSn();

	cmd->addParRet("Sn", Par::VecVType::USMALLINT);

	return cmd;
};

void UntIdhwAxs2::getAdcSn(
			usmallint& Sn
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetAdcSn();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getAdcSn", cmd->cref, "", "", true, true);
	else {
		Sn = cmd->parsRet["Sn"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwAxs2::CmdGetAdcVgmr* UntIdhwAxs2::getNewCmdGetAdcVgmr() {
	CmdGetAdcVgmr* cmd = new CmdGetAdcVgmr();

	cmd->addParRet("Vgmr", Par::VecVType::USMALLINT);

	return cmd;
};

void UntIdhwAxs2::getAdcVgmr(
			usmallint& Vgmr
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetAdcVgmr();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getAdcVgmr", cmd->cref, "", "", true, true);
	else {
		Vgmr = cmd->parsRet["Vgmr"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwAxs2::CmdGetTickval* UntIdhwAxs2::getNewCmdGetTickval() {
	CmdGetTickval* cmd = new CmdGetTickval();

	cmd->addParRet("tickval", Par::VecVType::SMALLINT);

	return cmd;
};

void UntIdhwAxs2::getTickval(
			smallint& tickval
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetTickval();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getTickval", cmd->cref, "", "", true, true);
	else {
		tickval = cmd->parsRet["tickval"].getSmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetTickval(
			const smallint tickval
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETTICKVAL, Cmd::VecVRettype::VOID);

	cmd->addParInv("tickval", Par::VecVType::SMALLINT);

	cmd->parsInv["tickval"].setSmallint(tickval);

	return cmd;
};

void UntIdhwAxs2::setTickval(
			const smallint tickval
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTickval(tickval);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setTickval", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetTickvalMin(
			const smallint min
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETTICKVALMIN, Cmd::VecVRettype::VOID);

	cmd->addParInv("min", Par::VecVType::SMALLINT);

	cmd->parsInv["min"].setSmallint(min);

	return cmd;
};

void UntIdhwAxs2::setTickvalMin(
			const smallint min
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTickvalMin(min);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setTickvalMin", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetTickvalMax(
			const smallint max
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETTICKVALMAX, Cmd::VecVRettype::VOID);

	cmd->addParInv("max", Par::VecVType::SMALLINT);

	cmd->parsInv["max"].setSmallint(max);

	return cmd;
};

void UntIdhwAxs2::setTickvalMax(
			const smallint max
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTickvalMax(max);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setTickvalMax", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetTickvalTrg(
			const smallint trg
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETTICKVALTRG, Cmd::VecVRettype::VOID);

	cmd->addParInv("trg", Par::VecVType::SMALLINT);

	cmd->parsInv["trg"].setSmallint(trg);

	return cmd;
};

void UntIdhwAxs2::setTickvalTrg(
			const smallint trg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetTickvalTrg(trg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setTickvalTrg", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwAxs2::CmdGetTpi* UntIdhwAxs2::getNewCmdGetTpi() {
	CmdGetTpi* cmd = new CmdGetTpi();

	cmd->addParRet("tickval", Par::VecVType::SMALLINT);

	return cmd;
};

void UntIdhwAxs2::getTpi(
			smallint& tickval
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetTpi();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getTpi", cmd->cref, "", "", true, true);
	else {
		tickval = cmd->parsRet["tickval"].getSmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwAxs2::CmdGetAngle* UntIdhwAxs2::getNewCmdGetAngle() {
	CmdGetAngle* cmd = new CmdGetAngle();

	cmd->addParRet("angle", Par::VecVType::SMALLINT);

	return cmd;
};

void UntIdhwAxs2::getAngle(
			smallint& angle
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetAngle();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getAngle", cmd->cref, "", "", true, true);
	else {
		angle = cmd->parsRet["angle"].getSmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetAngleMin(
			const smallint min
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETANGLEMIN, Cmd::VecVRettype::VOID);

	cmd->addParInv("min", Par::VecVType::SMALLINT);

	cmd->parsInv["min"].setSmallint(min);

	return cmd;
};

void UntIdhwAxs2::setAngleMin(
			const smallint min
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetAngleMin(min);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setAngleMin", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetAngleMax(
			const smallint max
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETANGLEMAX, Cmd::VecVRettype::VOID);

	cmd->addParInv("max", Par::VecVType::SMALLINT);

	cmd->parsInv["max"].setSmallint(max);

	return cmd;
};

void UntIdhwAxs2::setAngleMax(
			const smallint max
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetAngleMax(max);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setAngleMax", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwAxs2::getNewCmdSetAngleTrg(
			const smallint trg
		) {
	Cmd* cmd = new Cmd(VecVIdhwAxs2Command::SETANGLETRG, Cmd::VecVRettype::VOID);

	cmd->addParInv("trg", Par::VecVType::SMALLINT);

	cmd->parsInv["trg"].setSmallint(trg);

	return cmd;
};

void UntIdhwAxs2::setAngleTrg(
			const smallint trg
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetAngleTrg(trg);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setAngleTrg", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

