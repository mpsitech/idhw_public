/**
  * \file Idhw.cpp
  * Idhw global functionality and inter-thread exchange object (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "Idhw.h"

/******************************************************************************
 class SysIdhw
 ******************************************************************************/

SysIdhw::SysIdhw(
			unsigned char Nretry
			, unsigned int dtPing
			, XchgIdhw** xchg
		) {
	this->xchg = new XchgIdhw();
	*xchg = this->xchg;

	this->Nretry = Nretry;
	this->dtPing = dtPing;

	dumpexc = false;
	dumprxtx = false;
};

SysIdhw::~SysIdhw() {
	delete xchg;
};

UntIdhw* SysIdhw::connectToTarget(
			const uint ixVTarget
		) {
	return NULL;
};

uint SysIdhw::getIxVTargetBySref(
			const string& sref
		) {
	return 0;
};

string SysIdhw::getSrefByIxVTarget(
			const uint ixVTarget
		) {
	return "";
};

void SysIdhw::fillFeedFTarget(
			Feed& feed
		) {
	feed.clear();
};

utinyint SysIdhw::getTixVControllerBySref(
			const uint ixVTarget
			, const string& sref
		) {
	return 0;
};

string SysIdhw::getSrefByTixVController(
			const uint ixVTarget
			, const utinyint tixVController
		) {
	return "";
};

void SysIdhw::fillFeedFController(
			const uint ixVTarget
			, Feed& feed
		) {
	feed.clear();
};

utinyint SysIdhw::getTixWBufferBySref(
			const uint ixVTarget
			, const string& sref
		) {
	return 0;
};

string SysIdhw::getSrefByTixWBuffer(
			const uint ixVTarget
			, const utinyint tixWBuffer
		) {
	return "";
};

void SysIdhw::fillFeedFBuffer(
			const uint ixVTarget
			, Feed& feed
		) {
	feed.clear();
};

utinyint SysIdhw::getTixVCommandBySref(
			const uint ixVTarget
			, const utinyint tixVController
			, const string& sref
		) {
	return 0;
};

string SysIdhw::getSrefByTixVCommand(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVCommand
		) {
	return "";
};

void SysIdhw::fillFeedFCommand(
			const uint ixVTarget
			, const utinyint tixVController
			, Feed& feed
		) {
	feed.clear();
};

string SysIdhw::getSrefByTixVError(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	return "";
};

string SysIdhw::getTitleByTixVError(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	return "";
};

Bufxf* SysIdhw::getNewBufxf(
			const uint ixVTarget
			, const utinyint tixWBuffer
			, const size_t reqlen
		) {
	return NULL;
};

Cmd* SysIdhw::getNewCmd(
			const uint ixVTarget
			, const utinyint tixVController
			, const uint tixVCommand
		) {
	return NULL;
};

string SysIdhw::getCmdInvTemplate(
			const uint ixVTarget
			, const utinyint tixVController
			, const uint tixVCommand
		) {
	string retval;

	Cmd* cmd = getNewCmd(ixVTarget, tixVController, tixVCommand);

	if (cmd) {
		retval = getSrefByTixVController(ixVTarget, tixVController);
		if (retval != "") retval += ".";
		retval += getSrefByTixVCommand(ixVTarget, tixVController, tixVCommand);

		retval += "(" + cmd->parsInvToTemplate() + ")";

		delete cmd;
	};

	return retval;
};

string SysIdhw::getCmdErrMessage(
			Cmd* cmd
			, const bool cmdNotErronly
			, const bool titleNotSref
		) {
	string msg;

	if (cmd) msg = cmd->err.getMessage(getSrefByTixVController(cmd->ixVTarget, cmd->tixVController), getSrefByTixVCommand(cmd->ixVTarget, cmd->tixVController, cmd->tixVCommand), cmd->cref,
				getSrefByTixVError(cmd->ixVTarget, cmd->tixVController, cmd->err.tixVError), getTitleByTixVError(cmd->ixVTarget, cmd->tixVController, cmd->err.tixVError), cmdNotErronly, titleNotSref);

	return msg;
};

/******************************************************************************
 class UntIdhw
 ******************************************************************************/

UntIdhw::UntIdhw(
			XchgIdhw* xchg
			, const uint ixVTarget
		) {
	this->xchg = xchg;

	this->ixVTarget = ixVTarget;
	uref = 0;

	t0 = 0.0;
	t0 = getDt();
};

UntIdhw::~UntIdhw() {
};

double UntIdhw::getDt() {
	timeval t;

	gettimeofday(&t, NULL);

	return((1.0*t.tv_sec + 1e-6*t.tv_usec) - t0);
};

bool UntIdhw::reset() {
	return xchg->runRst(new Rst(ixVTarget, uref));
};

bool UntIdhw::runBufxf(
			Bufxf* bufxf
			, const unsigned int to
		) {
	bufxf->ixVTarget = ixVTarget;
	bufxf->uref = uref;

	return(xchg->runBufxf(bufxf, to));
};

ubigint UntIdhw::startBufxf(
			Bufxf* bufxf
		) {
	bufxf->ixVTarget = ixVTarget;
	bufxf->uref = uref;

	return(xchg->addBufxf(bufxf));
};

void UntIdhw::abortBufxf(
			Bufxf* bufxf
			, const bool elim
		) {
	xchg->abortBufxf(bufxf, elim);
};

bool UntIdhw::runCmd(
			Cmd* cmd
			, const unsigned int to
		) {
	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	return(xchg->runCmd(cmd, to));
};

uint UntIdhw::invokeCmd(
			Cmd* cmd
		) {
	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	return(xchg->addCmd(cmd));
};

void UntIdhw::invokeCmds(
			vector<Cmd*>& cmds
		) {
	for (unsigned int i=0;i<cmds.size();i++) {
		cmds[i]->ixVTarget = ixVTarget;
		cmds[i]->uref = uref;
	};

	xchg->addCmds(cmds);
};

void UntIdhw::revokeCmd(
			Cmd* cmd
			, const bool elim
		) {
	xchg->revokeCmd(cmd, elim);
};

/******************************************************************************
 class CtrIdhw
 ******************************************************************************/

CtrIdhw::CtrIdhw(
			XchgIdhw* xchg
			, const uint ixVTarget
			, const ubigint uref
		) {
	this->xchg = xchg;

	this->ixVTarget = ixVTarget;
	this->uref = uref;
};

CtrIdhw::~CtrIdhw() {
};

/******************************************************************************
 class XchgIdhw
 ******************************************************************************/

XchgIdhw::XchgIdhw() {
	// unit connection list
	urefseq = new Refseq("urefseq");
	Mutex::init(&mUnts, true, "mUnts", "XchgIdhw", "XchgIdhw");

	// condition for preparation processor
	Mutex::init(&mcPrepprc, true, "mcPrepprc", "XchgIdhw", "XchgIdhw");
	Cond::init(&cPrepprc, "cPrepprc", "XchgIdhw", "XchgIdhw");

	// condition for request processor
	Mutex::init(&mcReqprc, true, "mcReqprc", "XchgIdhw", "XchgIdhw");
	Cond::init(&cReqprc, "cReqprc", "XchgIdhw", "XchgIdhw");

	// request lists protection
	Mutex::init(&mRstsBufxfsCmds, true, "mRstsBufxfsCmds", "XchgIdhw", "XchgIdhw");

	// reset list
	rrefseq = new Refseq("rrefseq");

	// buffer transfer list
	brefseq = new Refseq("brefseq");

	// command list
	crefseq = new Refseq("crefseq");
};

XchgIdhw::~XchgIdhw() {
	// empty out lists
	for (auto it=unts.begin();it!=unts.end();it++) delete(it->second);
	for (auto it=rsts.begin();it!=rsts.end();it++) delete(it->second);
	for (auto it=bufxfs.begin();it!=bufxfs.end();it++) delete(it->second);
	for (auto it=cmds.begin();it!=cmds.end();it++) delete(it->second);

	// unit connection list
	delete urefseq;
	Mutex::destroy(&mUnts, true, "mUnts", "XchgIdhw", "~XchgIdhw");

	// condition for preparation processor
	Mutex::destroy(&mcPrepprc, true, "mcPrepprc", "XchgIdhw", "~XchgIdhw");
	Cond::destroy(&cPrepprc, "cPrepprc", "XchgIdhw", "~XchgIdhw");

	// condition for request processor
	Mutex::destroy(&mcReqprc, true, "mcReqprc", "XchgIdhw", "~XchgIdhw");
	Cond::destroy(&cReqprc, "cReqprc", "XchgIdhw", "~XchgIdhw");

	// request lists protection
	Mutex::destroy(&mRstsBufxfsCmds, true, "mRstsBufxfsCmds", "XchgIdhw", "~XchgIdhw");

	// reset list
	delete rrefseq;

	// buffer transfer list
	delete brefseq;

	// command list
	delete crefseq;
};

ubigint XchgIdhw::addUnt(
			UntIdhw* unt
		) {
	// get new uref and append to unit connection list
	Mutex::lock(&mUnts, "mUnts", "XchgIdhw", "addUnt");

	unt->uref = urefseq->getNewRef();
	unts[unt->uref] = unt;

	Mutex::unlock(&mUnts, "mUnts", "XchgIdhw", "addUnt");

	return(unt->uref);
};

UntIdhw* XchgIdhw::getUntByUref(
			const ubigint uref
		) {
	UntIdhw* unt = NULL;

	Mutex::lock(&mUnts, "mUnts", "XchgIdhw", "getUntByUref");

	auto it = unts.find(uref);
	if (it != unts.end()) unt = it->second;

	Mutex::unlock(&mUnts, "mUnts", "XchgIdhw", "getUntByUref");

	return unt;
};

void XchgIdhw::removeUntByUref(
			const ubigint uref
		) {
	UntIdhw* unt = NULL;

	Mutex::lock(&mUnts, "mUnts", "XchgIdhw", "removeUntByUref");

	unt = getUntByUref(uref);

	if (unt) {
		removeRstsByUref(unt->ixVTarget, uref);
		removeBufxfsByUref(unt->ixVTarget, uref);
		removeCmdsByUref(unt->ixVTarget, uref);

		unts.erase(uref);
	};

	Mutex::unlock(&mUnts, "mUnts", "XchgIdhw", "removeUntByUref");
};

ubigint XchgIdhw::addRst(
			Rst* rst
		) {
	if (rst->ixVState == Rst::VecVState::VOID) rst->ixVState = Rst::VecVState::WAITPREP;
	if (rst->rref == 0) rst->rref = rrefseq->getNewRef();

	rstref_t rref(rst->ixVState, rst->rref);
	rstref2_t rref2(rst->ixVTarget, rst->uref, rst->rref);

	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "addRst");

	rsts.insert(pair<rstref_t,Rst*>(rref, rst));
	rref2sRsts.insert(pair<rstref2_t,rstref_t>(rref2, rref));

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "addRst");

	if (rst->ixVState == Rst::VecVState::WAITPREP) Cond::signal(&cPrepprc, &mcPrepprc, "cPrepprc", "mcPrepprc", "XchgIdhw", "addRst");
	else if (rst->ixVState == Rst::VecVState::WAITRST) Cond::signal(&cReqprc, &mcReqprc, "cReqprc", "mcReqprc", "XchgIdhw", "addRst");

	return rst->rref;
};

void XchgIdhw::changeRstState(
			Rst* rst
			, const uint ixVState
		) {
	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "changeRstState");

	auto it2 = rref2sRsts.find(rstref2_t(rst->ixVTarget, rst->uref, rst->rref));
	if (it2 != rref2sRsts.end()) {

		auto it = rsts.find(it2->second);
		if (it != rsts.end()) {
			rst->lockAccess("XchgIdhw", "changeRstState");

			rst->ixVState = ixVState;

			rsts.erase(it);
			rref2sRsts.erase(it2);

			addRst(rst);

			if (rst->progressCallback) rst->progressCallback(rst, rst->argProgressCallback);

			rst->unlockAccess("XchgIdhw", "changeRstState");
		};
	};

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "changeRstState");
};

bool XchgIdhw::runRst(
			Rst* rst
			, const unsigned int to
		) {
	bool success = false;
	int res;

	pthread_cond_t cProgress;

	Cond::init(&cProgress, "cProgress", "XchgIdhw", "runRst");
	rst->setProgressCallback(runRst_callback, &cProgress);

	// add and wait for preparation processor
	rst->lockAccess("XchgIdhw", "runRst");

	addRst(rst);

	res = Cond::timedwait(&cProgress, &(rst->mAccess), to, "cProgress", "XchgIdhw", "runRst[1]");

	// at this stage, mAccess is locked again

	if (res == ETIMEDOUT) {
		removeRst(rst);
		rst->unlockAccess("XchgIdhw", "runRst[1]");

	} else if (rst->ixVState == Rst::VecVState::WAITRST) {
		res = Cond::timedwait(&cProgress, &(rst->mAccess), to, "cProgress", "XchgIdhw", "runRst[2]");

		// at this stage, mAccess is locked again

		if (res == ETIMEDOUT) {
			removeRst(rst);
			rst->unlockAccess("XchgIdhw", "runRst[2]");

		} else if (rst->ixVState == Rst::VecVState::DONE) {
			removeRst(rst);
			rst->unlockAccess("XchgIdhw", "runRst[3]");
			
			success = true;
		};

	} else if (rst->ixVState == Rst::VecVState::DONE) {
		// another reset beat rst to it
		removeRst(rst);
		rst->unlockAccess("XchgIdhw", "runRst[4]");

		success = true;
	};

	Cond::destroy(&cProgress, "cProgress", "XchgIdhw", "runRst");

	return success;
};

bool XchgIdhw::runRst_callback(
			Rst* rst
			, void* _cProgress
		) {
	pthread_cond_t* cProgress = (pthread_cond_t*) _cProgress;

	Cond::signal(cProgress, &(rst->mAccess), "cProgress", "mAccess", "XchgIdhw", "runRst_callback");

	return false;
};

void XchgIdhw::removeRst(
			Rst* rst
		) {
	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeRst");

	auto it2 = rref2sRsts.find(rstref2_t(rst->ixVTarget, rst->uref, rst->rref));
	if (it2 != rref2sRsts.end()) {

		auto it = rsts.find(it2->second);
		if (it != rsts.end()) {
			rst->lockAccess("XchgIdhw", "removeRst");

			if (rst->cmd) removeCmd(rst->cmd);

			rsts.erase(it);
			rref2sRsts.erase(it2);

			rst->unlockAccess("XchgIdhw", "removeRst");
		};
	};

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeRst");
};

void XchgIdhw::removeRstsByIxVTarget(
			const uint ixVTarget
		) {
	vector<Rst*> _rsts;

	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeRstsByIxVTarget");

	auto rng = rref2sRsts.equal_range(rstref2_t(ixVTarget, 0, 0));
	for (auto it2=rng.first;it2!=rng.second;it2++) {
		auto it = rsts.find(it2->second);
		if (it != rsts.end()) _rsts.push_back(it->second);
	};

	for (unsigned int i=0;i<_rsts.size();i++) removeRst(_rsts[i]);

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeRstsByIxVTarget");
};

void XchgIdhw::removeRstsByUref(
			const uint ixVTarget
			, const ubigint uref
		) {
	vector<Rst*> _rsts;

	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeRstsByUref");

	auto rng = rref2sRsts.equal_range(rstref2_t(ixVTarget, uref, 0));
	for (auto it2=rng.first;it2!=rng.second;it2++) {
		auto it = rsts.find(it2->second);
		if (it != rsts.end()) _rsts.push_back(it->second);
	};

	for (unsigned int i=0;i<_rsts.size();i++) removeRst(_rsts[i]);

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeRstsByUref");
};

ubigint XchgIdhw::addBufxf(
			Bufxf* bufxf
		) {
	if (bufxf->ixVState == Bufxf::VecVState::VOID) bufxf->ixVState = Bufxf::VecVState::WAITPREP;
	if (bufxf->bref == 0) bufxf->bref = brefseq->getNewRef();

	bufxfref_t bref(bufxf->ixVState, bufxf->tixWBuffer, bufxf->bref);
	if (bufxf->ixVState > Bufxf::VecVState::WAITPREP) bref.rootTixWBuffer = bufxf->rootTixWBuffer;

	bufxfref2_t bref2(bufxf->ixVTarget, bufxf->uref, bufxf->bref);

	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "addBufxf");

	bufxfs.insert(pair<bufxfref_t,Bufxf*>(bref, bufxf));
	bref2sBufxfs.insert(pair<bufxfref2_t,bufxfref_t>(bref2, bref));

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "addBufxf");

	if (bufxf->ixVState == Bufxf::VecVState::WAITPREP) Cond::signal(&cPrepprc, &mcPrepprc, "cPrepprc", "mcPrepprc", "XchgIdhw", "addBufxf");
	else if ((bufxf->ixVState == Bufxf::VecVState::WAITINV) || (bufxf->ixVState == Bufxf::VecVState::WAITXFER)) Cond::signal(&cReqprc, &mcReqprc, "cReqprc", "mcReqprc", "XchgIdhw", "addBufxf");

	return bufxf->bref;
};

void XchgIdhw::changeBufxfState(
			Bufxf* bufxf
			, const uint ixVState
		) {
	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "changeBufxfState");

	auto it2 = bref2sBufxfs.find(bufxfref2_t(bufxf->ixVTarget, bufxf->uref, bufxf->bref));
	if (it2 != bref2sBufxfs.end()) {

		auto it = bufxfs.find(it2->second);
		if (it != bufxfs.end()) {
			bufxf->ixVState = ixVState;

			bufxfs.erase(it);
			bref2sBufxfs.erase(it2);

			addBufxf(bufxf);
		};
	};

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "changeBufxfState");
};

bool XchgIdhw::runBufxf(
			Bufxf* bufxf
			, const unsigned int to
		) {
	bool success = false;
	int res;

	pthread_cond_t cProgress;

	Cond::init(&cProgress, "cProgress", "XchgIdhw", "runBufxf");
	bufxf->setProgressCallback(runBufxf_callback, &cProgress);

	// add and wait for preparation processor
	bufxf->lockAccess("XchgIdhw", "runBufxf");

	addBufxf(bufxf);

	res = Cond::timedwait(&cProgress, &(bufxf->mAccess), to, "cProgress", "XchgIdhw", "runBufxf[1]");

	// at this stage, mAccess is locked again

	if (res == ETIMEDOUT) {
		removeBufxf(bufxf);
		bufxf->unlockAccess("XchgIdhw", "runBufxf[1]");

	} else if (bufxf->ixVState == Bufxf::VecVState::WAITXFER) {
		// progress callback not invoked on WAITPREP -> WAITINV

		res = Cond::timedwait(&cProgress, &(bufxf->mAccess), to, "cProgress", "XchgIdhw", "runBufxf[2]");

		// at this stage, mAccess is locked again

		if (res == ETIMEDOUT) {
			removeBufxf(bufxf);
			bufxf->unlockAccess("XchgIdhw", "runBufxf[2]");

		} else if (bufxf->ixVState == Bufxf::VecVState::DONE) {
			removeBufxf(bufxf);
			bufxf->unlockAccess("XchgIdhw", "runBufxf[3]");
			
			success = true;
		};

	} else if (bufxf->ixVState == Bufxf::VecVState::DONE) {
		// reset happened in the meantime
		removeBufxf(bufxf);
		bufxf->unlockAccess("XchgIdhw", "runBufxf[4]");
		
		success = true;
	};

	Cond::destroy(&cProgress, "cProgress", "XchgIdhw", "runBufxf");

	return success;
};

bool XchgIdhw::runBufxf_callback(
			Bufxf* bufxf
			, void* _cProgress
		) {
	pthread_cond_t* cProgress = (pthread_cond_t*) _cProgress;

	Cond::signal(cProgress, &(bufxf->mAccess), "cProgress", "mAccess", "XchgIdhw", "runBufxf_callback");

	return false;
};

void XchgIdhw::abortBufxf(
			Bufxf* bufxf
			, bool elim
		) {
	// ...
};

void XchgIdhw::removeBufxf(
			Bufxf* bufxf
		) {
	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeBufxf");

	auto it2 = bref2sBufxfs.find(bufxfref2_t(bufxf->ixVTarget, bufxf->uref, bufxf->bref));
	if (it2 != bref2sBufxfs.end()) {

		auto it = bufxfs.find(it2->second);
		if (it != bufxfs.end()) {
			bufxf->lockAccess("XchgIdhw", "removeBufxf");

			for (unsigned int i=0;i<bufxf->cmds.size();i++) removeCmd(bufxf->cmds[i]);

			bufxfs.erase(it);
			bref2sBufxfs.erase(it2);

			bufxf->unlockAccess("XchgIdhw", "removeBufxf");
		};
	};

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeBufxf");
};

void XchgIdhw::removeBufxfsByIxVTarget(
			const uint ixVTarget
		) {
	vector<Bufxf*> _bufxfs;

	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeBufxfsByIxVTarget");

	auto rng = bref2sBufxfs.equal_range(bufxfref2_t(ixVTarget, 0, 0));
	for (auto it2=rng.first;it2!=rng.second;it2++) {
		auto it = bufxfs.find(it2->second);
		if (it != bufxfs.end()) _bufxfs.push_back(it->second);
	};

	for (unsigned int i=0;i<_bufxfs.size();i++) removeBufxf(_bufxfs[i]);

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeBufxfsByIxVTarget");
};

void XchgIdhw::removeBufxfsByUref(
			const uint ixVTarget
			, const ubigint uref
		) {
	vector<Bufxf*> _bufxfs;

	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeBufxfsByUref");

	auto rng = bref2sBufxfs.equal_range(bufxfref2_t(ixVTarget, uref, 0));
	for (auto it2=rng.first;it2!=rng.second;it2++) {
		auto it = bufxfs.find(it2->second);
		if (it != bufxfs.end()) _bufxfs.push_back(it->second);
	};

	for (unsigned int i=0;i<_bufxfs.size();i++) removeBufxf(_bufxfs[i]);

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeBufxfsByUref");
};

uint XchgIdhw::addCmd(
			Cmd* cmd
			, const bool mute
		) {
	if (cmd->ixVState == Cmd::VecVState::VOID) cmd->ixVState = Cmd::VecVState::WAITINV;
	if (cmd->cref == 0) cmd->cref = crefseq->getNewRef();

	cmdref_t cref(cmd->ixVState, cmd->cref);
	cmdref2_t cref2(cmd->ixVTarget, cmd->uref, cmd->cref);

	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "addCmd");

	cmds.insert(pair<cmdref_t,Cmd*>(cref, cmd));
	cref2sCmds.insert(pair<cmdref2_t,cmdref_t>(cref2, cref));

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "addCmd");

	if (!mute && ((cmd->ixVState == Cmd::VecVState::WAITINV) || (cmd->ixVState == Cmd::VecVState::WAITREV)))
				Cond::signal(&cReqprc, &mcReqprc, "cReqprc", "mcReqprc", "XchgIdhw", "addCmd");

	return cmd->cref;
};

void XchgIdhw::addCmds(
			vector<Cmd*>& _cmds
		) {
	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "addCmds");

	for (unsigned int i=0;i<_cmds.size();i++) addCmd(_cmds[i], true);

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "addCmds");

	Cond::signal(&cReqprc, &mcReqprc, "cReqprc", "mcReqprc", "XchgIdhw", "addCmds");
};

void XchgIdhw::changeCmdState(
			Cmd* cmd
			, const uint ixVState
		) {
	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "changeCmdState");

	auto it2 = cref2sCmds.find(cmdref2_t(cmd->ixVTarget, cmd->uref, cmd->cref));
	if (it2 != cref2sCmds.end()) {

		auto it = cmds.find(it2->second);
		if (it != cmds.end()) {
			cmd->lockAccess("XchgIdhw", "changeCmdState");

			cmd->ixVState = ixVState;

			cmds.erase(it);
			cref2sCmds.erase(it2);

			addCmd(cmd);

			cmd->unlockAccess("XchgIdhw", "changeCmdState");
		};
	};

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "changeCmdState");
};

bool XchgIdhw::runCmd(
			Cmd* cmd
			, const unsigned int to
		) {
	bool success = false;
	int res;

	pthread_cond_t cProgress;

	if ((cmd->ixVRettype == Cmd::VecVRettype::VOID) || (cmd->ixVRettype == Cmd::VecVRettype::IMMSNG)) {
		Cond::init(&cProgress, "cProgress", "XchgIdhw", "runCmd");
		cmd->setProgressCallback(runCmd_callback, &cProgress);

		// add and wait for request processor
		cmd->lockAccess("XchgIdhw", "runCmd");

		addCmd(cmd);

		res = Cond::timedwait(&cProgress, &(cmd->mAccess), to, "cProgress", "XchgIdhw", "runCmd[1]");

		// at this stage, mAccess is locked again

		if (res == ETIMEDOUT) {
			removeCmd(cmd);
			cmd->unlockAccess("XchgIdhw", "runCmd[1]");

		} else if (cmd->ixVState == Cmd::VecVState::WAITRET) {
			res = Cond::timedwait(&cProgress, &(cmd->mAccess), to, "cProgress", "XchgIdhw", "runCmd[2]");

			// at this stage, mAccess is locked again

			if (res == ETIMEDOUT) {
				removeCmd(cmd);
				cmd->unlockAccess("XchgIdhw", "runCmd[2]");

			} else if (cmd->ixVState == Cmd::VecVState::DONE) {
				removeCmd(cmd);
				cmd->unlockAccess("XchgIdhw", "runCmd[3]");
				
				success = true;
			};

		} else if (cmd->ixVState == Cmd::VecVState::DONE) {
			// return type VOID
			removeCmd(cmd);
			cmd->unlockAccess("XchgIdhw", "runCmd[4]");
			
			success = true;
		};

		Cond::destroy(&cProgress, "cProgress", "XchgIdhw", "runCmd");
	};

	return success;
};

bool XchgIdhw::runCmd_callback(
			Cmd* cmd
			, void* _cProgress
		) {
	pthread_cond_t* cProgress = (pthread_cond_t*) _cProgress;

	Cond::signal(cProgress, &(cmd->mAccess), "cProgress", "mAccess", "XchgIdhw", "runCmd_callback");

	return false;
};

void XchgIdhw::revokeCmd(
			Cmd* cmd
			, bool elim
		) {
	bool (*_progressCallback)(Cmd* cmd, void* arg);
	void* _argProgressCallback;

	bool (*_doneCallback)(Cmd* cmd, void* arg);
	void* _argDoneCallback;

	pthread_cond_t cProgress;

	Cond::init(&cProgress, "cProgress", "XchgIdhw", "revokeCmd");

	cmd->lockAccess("XchgIdhw", "revokeCmd");

	// backup/replace progress/done callbacks
	_progressCallback = cmd->progressCallback;
	_argProgressCallback = cmd->argProgressCallback;

	_doneCallback = cmd->doneCallback;
	_argDoneCallback = cmd->argDoneCallback;

	cmd->setProgressCallback(revokeCmd_callback, &cProgress);
	cmd->setDoneCallback(NULL, NULL);

	changeCmdState(cmd, Cmd::VecVState::WAITREV);
	if (_progressCallback) _progressCallback(cmd, _argProgressCallback);

	Cond::signal(&cReqprc, &mcReqprc, "cReqprc", "mcReqprc", "XchgIdhw", "revokeCmd");

	while (cmd->ixVState != Cmd::VecVState::DONE) Cond::wait(&cProgress, &(cmd->mAccess), "cProgress", "XchgIdhw", "revokeCmd");
	// at this stage, mAccess is locked again

	// revert to initial callbacks
	cmd->setProgressCallback(_progressCallback, _argProgressCallback);
	cmd->setDoneCallback(_doneCallback, _argDoneCallback);

	if (cmd->progressCallback) cmd->progressCallback(cmd, cmd->argProgressCallback);
	if ((cmd->err.tixDbeVAction != 0x00) && cmd->errorCallback) if (cmd->errorCallback(cmd, cmd->argErrorCallback)) elim = true;
	if ((cmd->ixVState == Cmd::VecVState::DONE) && cmd->doneCallback) if (cmd->doneCallback(cmd, cmd->argDoneCallback)) elim = true;

	cmd->unlockAccess("XchgIdhw", "revokeCmd");

	Cond::destroy(&cProgress, "cProgress", "XchgIdhw", "revokeCmd");

	if (elim) {
		removeCmd(cmd);
		delete cmd;
	};
};

bool XchgIdhw::revokeCmd_callback(
			Cmd* cmd
			, void* _cProgress
		) {
	pthread_cond_t* cProgress = (pthread_cond_t*) _cProgress;

	Cond::signal(cProgress, &(cmd->mAccess), "cProgress", "mAccess", "XchgIdhw", "revokeCmd_callback");

	return false;
};

void XchgIdhw::removeCmd(
			Cmd* cmd
		) {
	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeCmd");

	auto it2 = cref2sCmds.find(cmdref2_t(cmd->ixVTarget, cmd->uref, cmd->cref));
	if (it2 != cref2sCmds.end()) {

		auto it = cmds.find(it2->second);
		if (it != cmds.end()) {
			cmd->lockAccess("XchgIdhw", "removeCmd");

			auto it3 = cicsLock.find(cmdix_t(cmd->ixVTarget, cmd->tixVController, cmd->tixVCommand));
			if (it3 != cicsLock.end()) cicsLock.erase(it3);

			cmds.erase(it);
			cref2sCmds.erase(it2);

			cmd->unlockAccess("XchgIdhw", "removeCmd");
		};
	};

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeCmd");
};

void XchgIdhw::removeCmdsByIxVTarget(
			const uint ixVTarget
		) {
	vector<Cmd*> _cmds;

	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeCmdsByIxVTarget");

	auto rng = cref2sCmds.equal_range(cmdref2_t(ixVTarget, 0, 0));
	for (auto it2=rng.first;it2!=rng.second;it2++) {
		auto it = cmds.find(it2->second);
		if (it != cmds.end()) _cmds.push_back(it->second);
	};

	for (unsigned int i=0;i<_cmds.size();i++) removeCmd(_cmds[i]);

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeCmdsByIxVTarget");
};

void XchgIdhw::removeCmdsByUref(
			const uint ixVTarget
			, const ubigint uref
		) {
	vector<Cmd*> _cmds;

	Mutex::lock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeCmdsByUref");

	auto rng = cref2sCmds.equal_range(cmdref2_t(ixVTarget, uref, 0));
	for (auto it2=rng.first;it2!=rng.second;it2++) {
		auto it = cmds.find(it2->second);
		if (it != cmds.end()) _cmds.push_back(it->second);
	};

	for (unsigned int i=0;i<_cmds.size();i++) removeCmd(_cmds[i]);

	Mutex::unlock(&mRstsBufxfsCmds, "mRstsBufxfsCmds", "XchgIdhw", "removeCmdsByUref");
};

