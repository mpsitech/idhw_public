/**
  * \file SysIdhwZedboardFwd.cpp
  * SPI command forwarder based on ZedBoard system (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "SysIdhwZedboardFwd.h"

#include "SysIdhwZedboardFwd_vecs.cpp"

/******************************************************************************
 class SysIdhwZedboardFwd
 ******************************************************************************/

SysIdhwZedboardFwd::SysIdhwZedboardFwd(
			unsigned char Nretry
			, unsigned int dtPing
			, XchgIdhw** xchg
		) : SysIdhw(Nretry, dtPing, xchg) {

	rxbuf = NULL;
	txbuf = NULL;

	// IP constructor --- IBEGIN
	initdone = false;

	fd = 0;
	// IP constructor --- IEND
};

SysIdhwZedboardFwd::~SysIdhwZedboardFwd() {
	// IP destructor --- IBEGIN
	term();
	// IP destructor --- IEND
};

void* SysIdhwZedboardFwd::runPrepprc(
			void* arg
		) {
	SysIdhwZedboardFwd* inst = (SysIdhwZedboardFwd*) arg;

	XchgIdhw* xchg = inst->xchg;

	Rst* rst = NULL;
	Bufxf* bufxf = NULL;

	Cmd* cmd = NULL;

	// thread settings
	pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, 0);
	pthread_cleanup_push(&cleanupPrepprc, arg);

	while (true) {
		Mutex::lock(&(xchg->mcPrepprc), "xchg->mcPrepprc", "SysIdhwZedboardFwd", "runPrepprc");

		rst = inst->getFirstRst(Rst::VecVState::WAITPREP);
		if (!rst) bufxf = inst->getFirstBufxf(Bufxf::VecVState::WAITPREP);

		while (!rst && !bufxf) {
			Cond::wait(&(xchg->cPrepprc), &(xchg->mcPrepprc), "xchg->cPrepprc", "SysIdhwZedboardFwd", "runPrepprc");

			rst = inst->getFirstRst(Rst::VecVState::WAITPREP);
			if (!rst) bufxf = inst->getFirstBufxf(Bufxf::VecVState::WAITPREP);
		};

		Mutex::unlock(&(xchg->mcPrepprc), "xchg->mcPrepprc", "SysIdhwZedboardFwd", "runPrepprc");
			
		if (rst) {
			// --- prepare reset

			// at this stage, rst is locked
			rst->root = false;
			rst->cmd = NULL;

			// determine list of units the requests of which need to be reset
			rst->subIcsVTarget.insert(rst->ixVTarget);

			if (rst->ixVTarget == VecVTarget::AXS2_PHI) {
				rst->cmd = inst->getNewCmd(VecVTarget::ZEDB, VecVIdhwZedbController::PHIIF, VecVIdhwZedbPhiifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::AXS2_THETA) {
				rst->cmd = inst->getNewCmd(VecVTarget::ZEDB, VecVIdhwZedbController::THETAIF, VecVIdhwZedbThetaifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::DCX3) {
				rst->cmd = inst->getNewCmd(VecVTarget::ZEDB, VecVIdhwZedbController::DCXIF, VecVIdhwZedbDcxifCommand::RESET);

				insert(rst->subIcsVTarget, VecVTarget::DCX3_AXS2_PHI);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_AXS2_THETA);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_ICM2);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_TAU2);

			} else if (rst->ixVTarget == VecVTarget::DCX3_AXS2_PHI) {
				rst->cmd = inst->getNewCmd(VecVTarget::DCX3, VecVIdhwDcx3Controller::PHIIF, VecVIdhwDcx3PhiifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::DCX3_AXS2_THETA) {
				rst->cmd = inst->getNewCmd(VecVTarget::DCX3, VecVIdhwDcx3Controller::THETAIF, VecVIdhwDcx3ThetaifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::DCX3_ICM2) {
				rst->cmd = inst->getNewCmd(VecVTarget::DCX3, VecVIdhwDcx3Controller::QCDIF, VecVIdhwDcx3QcdifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::DCX3_TAU2) {
				rst->cmd = inst->getNewCmd(VecVTarget::DCX3, VecVIdhwDcx3Controller::LWIRIF, VecVIdhwDcx3LwirifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::ICM2) {
				rst->cmd = inst->getNewCmd(VecVTarget::ZEDB, VecVIdhwZedbController::QCDIF, VecVIdhwZedbQcdifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::ZEDB) {
				rst->root = true;

				insert(rst->subIcsVTarget, VecVTarget::AXS2_PHI);
				insert(rst->subIcsVTarget, VecVTarget::AXS2_THETA);
				insert(rst->subIcsVTarget, VecVTarget::DCX3);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_AXS2_PHI);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_AXS2_THETA);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_ICM2);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_TAU2);
				insert(rst->subIcsVTarget, VecVTarget::ICM2);

	};

			if (rst->cmd) {
				rst->cmd->setProgressCallback(rstCmdProgressCallback, (void*) rst);
				xchg->addCmd(rst->cmd);
			};

			if (rst->cmd) xchg->changeRstState(rst, Rst::VecVState::WAITINV);
			else xchg->changeRstState(rst, Rst::VecVState::WAITRST);
			if (rst->progressCallback) rst->progressCallback(rst, rst->argProgressCallback);

			rst->unlockAccess("SysIdhwZedboardFwd", "runPrepprc");

		} else if (bufxf) {
			// --- prepare buffer transfer

			// at this stage, bufxf is locked
			bufxf->rootTixWBuffer = bufxf->tixWBuffer;

			if (bufxf->ixVTarget == VecVTarget::AXS2_PHI) {
			} else if (bufxf->ixVTarget == VecVTarget::AXS2_THETA) {
			} else if (bufxf->ixVTarget == VecVTarget::DCX3) {
				if (bufxf->writeNotRead) {
					bufxf->rootTixWBuffer = VecWIdhwZedbBuffer::HOSTIFTODCXIF;

					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::ZEDB, VecVIdhwZedbController::DCXIF, VecVIdhwZedbDcxifCommand::WRITE));

					cmd = CtrIdhwZedbDcxif::getNewCmdWrite(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);

				} else {
					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::ZEDB, VecVIdhwZedbController::DCXIF, VecVIdhwZedbDcxifCommand::READ));

					bufxf->rootTixWBuffer = VecWIdhwZedbBuffer::DCXIFTOHOSTIF;

					cmd = CtrIdhwZedbDcxif::getNewCmdRead(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);
				};
			} else if (bufxf->ixVTarget == VecVTarget::DCX3_AXS2_PHI) {
			} else if (bufxf->ixVTarget == VecVTarget::DCX3_AXS2_THETA) {
			} else if (bufxf->ixVTarget == VecVTarget::DCX3_ICM2) {
				if (bufxf->writeNotRead) {
					bufxf->rootTixWBuffer = VecWIdhwZedbBuffer::HOSTIFTODCXIF;

					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::ZEDB, VecVIdhwZedbController::DCXIF, VecVIdhwZedbDcxifCommand::WRITE));
					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::DCX3, VecVIdhwDcx3Controller::QCDIF, VecVIdhwDcx3QcdifCommand::WRITE));

					cmd = CtrIdhwZedbDcxif::getNewCmdWrite(VecWIdhwDcx3Buffer::HOSTIFTOQCDIF, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);

					cmd = CtrIdhwDcx3Qcdif::getNewCmdWrite(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);

				} else {
					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::DCX3, VecVIdhwDcx3Controller::QCDIF, VecVIdhwDcx3QcdifCommand::READ));
					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::ZEDB, VecVIdhwZedbController::DCXIF, VecVIdhwZedbDcxifCommand::READ));

					bufxf->rootTixWBuffer = VecWIdhwZedbBuffer::DCXIFTOHOSTIF;

					cmd = CtrIdhwDcx3Qcdif::getNewCmdRead(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);

					cmd = CtrIdhwZedbDcxif::getNewCmdRead(VecWIdhwDcx3Buffer::QCDIFTOHOSTIF, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);
				};
			} else if (bufxf->ixVTarget == VecVTarget::DCX3_TAU2) {
			} else if (bufxf->ixVTarget == VecVTarget::ICM2) {
				if (bufxf->writeNotRead) {
					bufxf->rootTixWBuffer = VecWIdhwZedbBuffer::HOSTIFTOQCDIF;

					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::ZEDB, VecVIdhwZedbController::QCDIF, VecVIdhwZedbQcdifCommand::WRITE));

					cmd = CtrIdhwZedbQcdif::getNewCmdWrite(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);

				} else {
					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::ZEDB, VecVIdhwZedbController::QCDIF, VecVIdhwZedbQcdifCommand::READ));

					bufxf->rootTixWBuffer = VecWIdhwZedbBuffer::QCDIFTOHOSTIF;

					cmd = CtrIdhwZedbQcdif::getNewCmdRead(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);
				};
			} else if (bufxf->ixVTarget == VecVTarget::ZEDB) {
	};

			if (bufxf->cmds.empty()) xchg->changeBufxfState(bufxf, Bufxf::VecVState::WAITXFER);
			else xchg->changeBufxfState(bufxf, Bufxf::VecVState::WAITINV);

			if (bufxf->progressCallback) bufxf->progressCallback(bufxf, bufxf->argProgressCallback);

			bufxf->unlockAccess("SysIdhwZedboardFwd", "runPrepprc");
		};
	};
	pthread_cleanup_pop(0);

	return(NULL);
};

void SysIdhwZedboardFwd::cleanupPrepprc(
			void* arg
		) {
	SysIdhwZedboardFwd* inst = (SysIdhwZedboardFwd*) arg;

	XchgIdhw* xchg = inst->xchg;

	Mutex::unlock(&(xchg->mcPrepprc), "xchg->mcPrepprc", "SysIdhwZedboardFwd", "cleanupPrepprc");
};

void* SysIdhwZedboardFwd::runReqprc(
			void* arg
		) {
	SysIdhwZedboardFwd* inst = (SysIdhwZedboardFwd*) arg;

	XchgIdhw* xchg = inst->xchg;

	const size_t maxlen = 2+1024+2;

	bool retry;
	bool first;
	bool match;
	bool news;

	Rst* rst = NULL;
	Rst* rst2 = NULL;

	pair<multimap<bufxfref_t,Bufxf*>::iterator,multimap<bufxfref_t,Bufxf*>::iterator> rngBufxfs;
	Bufxf* bufxf = NULL;
	Bufxf* bufxf2 = NULL;

	pair<multimap<cmdref_t,Cmd*>::iterator,multimap<cmdref_t,Cmd*>::iterator> rngCmds;
	Cmd* cmd = NULL;
	Cmd* cmd2 = NULL;

	uint ixVTarget = 0;

	utinyint tkn = 0;
	utinyint invtkn;

	utinyint tknFromCmdret = VecWIdhwZedbBuffer::CMDRETTOHOSTIF;
	utinyint tknFromDcxif = VecWIdhwZedbBuffer::DCXIFTOHOSTIF;
	utinyint tknToCmdinv = VecWIdhwZedbBuffer::HOSTIFTOCMDINV;
	utinyint tknToDcxif = VecWIdhwZedbBuffer::HOSTIFTODCXIF;
	utinyint tknToQcdif = VecWIdhwZedbBuffer::HOSTIFTOQCDIF;
	utinyint tknFromPmmu = VecWIdhwZedbBuffer::PMMUTOHOSTIF;
	utinyint tknFromQcdif = VecWIdhwZedbBuffer::QCDIFTOHOSTIF;

	utinyint reqbx;
	utinyint arbbx;

	size_t reqlen;
	size_t arblen;

	uint cref;

	unsigned char* parbuf = NULL;
	size_t parbuflen;

	unsigned short hostcrc;
	unsigned short crc;

	set<Rst*> rstsElim;
	set<Bufxf*> bufxfsElim;
	set<Cmd*> cmdsElim;

	bool elim;

	// (preliminary) fix for scenarios A and B:

	// A - on read:
	// host sends rdack and thus does invtkn
	// ack doesn't arrive at device
	// device re-sends same content
	// host discards content in case of (a) same buffer and (b) same cref in case of cmdret
	// double read anyway if device picks a different xfer

	// B - on write:
	// device sends wrack and thus does invtkn
	// ack doesn't arrive at host
	// host dummy re-sends same content (post-processing only) in case of (a) same buffer and (b) same cref in case of cmdinv
	// double write anyway if host pre-processing picks a different xfer

	bool skiprd;
	bool skipwr;

	utinyint arbbxRd_last; // set after ping
	ubigint brefRd_last; // set in post-processing
	uint crefRd_last; // set in post-processing

	utinyint arbbxWr_last; // set after ping
	ubigint brefWr_last; // set in communication
	uint crefWr_last; // set in communication

	// thread settings
	pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, 0);
	pthread_cleanup_push(&cleanupReqprc, arg);

	inst->rxbuf = new unsigned char[maxlen];
	inst->txbuf = new unsigned char[maxlen];

	unsigned char* _rxbuf = inst->rxbuf;
	unsigned char* _txbuf = inst->txbuf;

	inst->runReqprc_open();

	// main event loop: wait for requests, ping & communicate with device
	reqbx = 0x00;
	arbbx = 0x00;

	retry = false;
	first = true;

	skiprd = false;
	skipwr = false;

	arbbxRd_last = 0x00;
	brefRd_last = 0;
	crefRd_last = 0;

	arbbxWr_last = 0x00;
	brefWr_last = 0;
	crefWr_last = 0;

	while (true) {
		if (!retry) {
			// --- pre-processing
			rst = NULL;
			bufxf = NULL;
			cmd = NULL;

			// news covered by cReqprc that can trigger action:
			// 1. reset in state WAITRST (but not WAITINV) via rst
			// 2. bufxf in state WAITINV via addCmds
			// 3. bufxf in state WAITXFER via reqbx/read or reqbx/write
			// 4. cmd in states WAITINV or WAITREV via reqbx/write

			// news originating from device: via avlbx/read - only available after ping
			Mutex::lock(&(xchg->mcReqprc), "xchg->mcReqprc", "SysIdhwZedboardFwd", "runReqprc");
			Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "runReqprc[1]");

			// - check for resets
			rst = inst->getFirstRst(Rst::VecVState::WAITRST);

			// - see if bufxf-related commands are ready to be invoked
			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITINV, 0));
			for (auto it=rngBufxfs.first;it!=rngBufxfs.second;it++) {
				bufxf = it->second;

				bufxf->lockAccess("SysIdhwZedboardFwd", "runReqprc[1]");

				match = true;
				
				for (auto it2=bufxf->icsReqcmd.begin();it2!=bufxf->icsReqcmd.end();it2++) {
					if (xchg->cicsLock.find(*it2) != xchg->cicsLock.end()) {
						match = false;
						break;
					};
				};
				
				if (match) {
					// lock all, invoke all
					for (auto it2=bufxf->icsReqcmd.begin();it2!=bufxf->icsReqcmd.end();it2++) xchg->cicsLock.insert(*it2);

					xchg->addCmds(bufxf->cmds);
				};

				bufxf->unlockAccess("SysIdhwZedboardFwd", "runReqprc[1]");
			};

			// - determine reqbx
			// always be ready for receiving errors
			reqbx = VecWIdhwZedbBuffer::CMDRETTOHOSTIF;

			// check for command invoke / revoke
			rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITINV, 0));
			if (rngCmds.first != rngCmds.second) {
				reqbx |= VecWIdhwZedbBuffer::HOSTIFTOCMDINV;
			} else {
				rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITREV, 0));
				if (rngCmds.first != rngCmds.second) reqbx |= VecWIdhwZedbBuffer::HOSTIFTOCMDINV;
			};

			// other buffers
			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwZedbBuffer::DCXIFTOHOSTIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwZedbBuffer::DCXIFTOHOSTIF;

			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwZedbBuffer::HOSTIFTODCXIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwZedbBuffer::HOSTIFTODCXIF;

			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwZedbBuffer::HOSTIFTOQCDIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwZedbBuffer::HOSTIFTOQCDIF;

			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwZedbBuffer::PMMUTOHOSTIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwZedbBuffer::PMMUTOHOSTIF;

			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwZedbBuffer::QCDIFTOHOSTIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwZedbBuffer::QCDIFTOHOSTIF;

			Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "runReqprc[1]");

			news = (rst || (reqbx != VecWIdhwZedbBuffer::CMDRETTOHOSTIF) || (arbbx != 0x00));

			if (!news) Cond::timedwait(&(xchg->cReqprc), &(xchg->mcReqprc), inst->dtPing, "xchg->cReqprc", "SysIdhwZedboardFwd", "runReqprc");

			Mutex::unlock(&(xchg->mcReqprc), "xchg->mcReqprc", "SysIdhwZedboardFwd", "runReqprc");

		};

		// --- communication
		try {
			if (rst) {
				if (rst->root) {
					// -- reset

					// -> xferTkn
					_txbuf[0] = VecDbeVXfer::TKN;
					_txbuf[1] = tknReset;

					if (!inst->runReqprc_tx(2)) throw DbeException("error transferring data (reset/tkn)");

					first = true;

					skiprd = false;
					skipwr = false;

					arbbxRd_last = 0x00;
					brefRd_last = 0;
					crefRd_last = 0;

					arbbxWr_last = 0x00;
					brefWr_last = 0;
					crefWr_last = 0;

				} else {
					// non-root requires post-processing only
				};

			} else {
				if (!retry) {
					// -- ping
					arbbx = 0x00;

					skiprd = false;
					skipwr = false;

					tkn = tknPing;
					_txbuf[1] = tkn;

					// -> xferTkn
					_txbuf[0] = VecDbeVXfer::TKN;

					if (!inst->runReqprc_tx(2)) throw DbeException("error transferring data (ping/tkn)");

					// <- xferTknste
					if (!inst->runReqprc_rx(3)) throw DbeException("error transferring data (ping/tknste)");
					if ( (_rxbuf[0] != VecDbeVXfer::TKNSTE) || (_rxbuf[1] != tkn) )
								throw DbeException("transfer/token error (ping/tknste): 0x" + Dbe::bufToHex(_rxbuf, 2) + " instead of 0x" + Dbe::binToHex(VecDbeVXfer::TKNSTE) + Dbe::binToHex(tkn));

					if ( ! (((_rxbuf[2] & VecWIdhwZedbBuffer::CMDRETTOHOSTIF) ^ tknFromCmdret) & VecWIdhwZedbBuffer::CMDRETTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwZedbBuffer::CMDRETTOHOSTIF) tknFromCmdret = ~VecWIdhwZedbBuffer::CMDRETTOHOSTIF; else tknFromCmdret = VecWIdhwZedbBuffer::CMDRETTOHOSTIF;

						if (!first) {
							// implies last rdack(success), host -> device was not received at device
							//cout << "tknFromCmdret corrected" << endl;
							if (arbbxRd_last == VecWIdhwZedbBuffer::CMDRETTOHOSTIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwZedbBuffer::HOSTIFTOCMDINV) ^ tknToCmdinv) & VecWIdhwZedbBuffer::HOSTIFTOCMDINV) ) {
						if (_rxbuf[2] & VecWIdhwZedbBuffer::HOSTIFTOCMDINV) tknToCmdinv = ~VecWIdhwZedbBuffer::HOSTIFTOCMDINV; else tknToCmdinv = VecWIdhwZedbBuffer::HOSTIFTOCMDINV;

						if (!first) {
							// implies last wrack(success), device -> host was not received at host
							//cout << "tknToCmdinv corrected" << endl;
							if (arbbxWr_last == VecWIdhwZedbBuffer::HOSTIFTOCMDINV) skipwr = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwZedbBuffer::DCXIFTOHOSTIF) ^ tknFromDcxif) & VecWIdhwZedbBuffer::DCXIFTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwZedbBuffer::DCXIFTOHOSTIF) tknFromDcxif = ~VecWIdhwZedbBuffer::DCXIFTOHOSTIF; else tknFromDcxif = VecWIdhwZedbBuffer::DCXIFTOHOSTIF;
						if (!first) {
							//cout << "tknFromDcxif corrected" << endl;
							if (arbbxRd_last == VecWIdhwZedbBuffer::DCXIFTOHOSTIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwZedbBuffer::HOSTIFTODCXIF) ^ tknToDcxif) & VecWIdhwZedbBuffer::HOSTIFTODCXIF) ) {
						if (_rxbuf[2] & VecWIdhwZedbBuffer::HOSTIFTODCXIF) tknToDcxif = ~VecWIdhwZedbBuffer::HOSTIFTODCXIF; else tknToDcxif = VecWIdhwZedbBuffer::HOSTIFTODCXIF;
						if (!first) {
							//cout << "tknToDcxif corrected" << endl;
							if (arbbxWr_last == VecWIdhwZedbBuffer::HOSTIFTODCXIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwZedbBuffer::HOSTIFTOQCDIF) ^ tknToQcdif) & VecWIdhwZedbBuffer::HOSTIFTOQCDIF) ) {
						if (_rxbuf[2] & VecWIdhwZedbBuffer::HOSTIFTOQCDIF) tknToQcdif = ~VecWIdhwZedbBuffer::HOSTIFTOQCDIF; else tknToQcdif = VecWIdhwZedbBuffer::HOSTIFTOQCDIF;
						if (!first) {
							//cout << "tknToQcdif corrected" << endl;
							if (arbbxWr_last == VecWIdhwZedbBuffer::HOSTIFTOQCDIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwZedbBuffer::PMMUTOHOSTIF) ^ tknFromPmmu) & VecWIdhwZedbBuffer::PMMUTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwZedbBuffer::PMMUTOHOSTIF) tknFromPmmu = ~VecWIdhwZedbBuffer::PMMUTOHOSTIF; else tknFromPmmu = VecWIdhwZedbBuffer::PMMUTOHOSTIF;
						if (!first) {
							//cout << "tknFromPmmu corrected" << endl;
							if (arbbxRd_last == VecWIdhwZedbBuffer::PMMUTOHOSTIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwZedbBuffer::QCDIFTOHOSTIF) ^ tknFromQcdif) & VecWIdhwZedbBuffer::QCDIFTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwZedbBuffer::QCDIFTOHOSTIF) tknFromQcdif = ~VecWIdhwZedbBuffer::QCDIFTOHOSTIF; else tknFromQcdif = VecWIdhwZedbBuffer::QCDIFTOHOSTIF;
						if (!first) {
							//cout << "tknFromQcdif corrected" << endl;
							if (arbbxRd_last == VecWIdhwZedbBuffer::QCDIFTOHOSTIF) skiprd = true;
						};
					};

					first = false;

					// <- xferAvlbx
					if (!inst->runReqprc_rx(3)) throw DbeException("error transferring data (ping/avlbx)");
					if ( (_rxbuf[0] != VecDbeVXfer::AVLBX) || (_rxbuf[1] != tkn) )
								throw DbeException("transfer/token error (ping/avlbx): 0x" + Dbe::binToHex(_rxbuf[0]) + Dbe::binToHex(_rxbuf[1]) + " instead of 0x" + Dbe::binToHex(VecDbeVXfer::AVLBX) + Dbe::binToHex(tkn));

					// -> xferReqbx
					_txbuf[0] = VecDbeVXfer::REQBX;
					_txbuf[2] = reqbx;

					if (!inst->runReqprc_tx(3)) throw DbeException("error transferring data (ping/reqbx)");

					// <- xferArbbx
					if (!inst->runReqprc_rx(3)) throw DbeException("error transferring data (ping/arbbx)");
					if ( (_rxbuf[0] != VecDbeVXfer::ARBBX) || (_rxbuf[1] != tkn) )
								throw DbeException("transfer/token error (ping/arbbx): 0x" + Dbe::binToHex(_rxbuf[0]) + Dbe::binToHex(_rxbuf[1]) + " instead of 0x" + Dbe::binToHex(VecDbeVXfer::ARBBX) + Dbe::binToHex(tkn));

					arbbx = _rxbuf[2];
					arbbx = (reqbx & arbbx); // just a precaution

					if ((arbbx == VecWIdhwZedbBuffer::CMDRETTOHOSTIF) || (arbbx == VecWIdhwZedbBuffer::DCXIFTOHOSTIF) || (arbbx == VecWIdhwZedbBuffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwZedbBuffer::QCDIFTOHOSTIF)) arbbxRd_last = arbbx;
					if ((arbbx == VecWIdhwZedbBuffer::HOSTIFTOCMDINV) || (arbbx == VecWIdhwZedbBuffer::HOSTIFTODCXIF) || (arbbx == VecWIdhwZedbBuffer::HOSTIFTOQCDIF)) arbbxWr_last = arbbx;
				};

				if (arbbx) {
					// -- read/write
					retry = true;

					reqlen = 0;

					// -- lock resource for read (bufxf) vs. write (cmd/bufxf) and determine reqlen
					if (arbbx == VecWIdhwZedbBuffer::CMDRETTOHOSTIF) {
						reqlen = 255;

					} else if (arbbx == VecWIdhwZedbBuffer::HOSTIFTOCMDINV) {
						Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "runReqprc[2]");

						cmd = NULL;

						// give revoke priority
						rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITREV, 0));
						if (rngCmds.first != rngCmds.second) {
							cmd = rngCmds.first->second;
						} else {
							rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITINV, 0));
							if (rngCmds.first != rngCmds.second) cmd = rngCmds.first->second;
						};

						Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "runReqprc[2]");

						if (cmd) {
							cmd->lockAccess("SysIdhwZedboardFwd", "runReqprc[1]");

							ixVTarget = cmd->ixVTarget;

							reqlen = 10; // route(4) + action(1) + cref(4) + tixVCommand(1)
							if (cmd->ixVState == Cmd::VecVState::WAITINV) reqlen += cmd->getInvBuflen(); // invpars(var)

							if (cmd->cref != crefWr_last) skipwr = false;
							crefWr_last = cmd->cref;
						};

					} else if (arbbx != VecWIdhwZedbBuffer::CMDRETTOHOSTIF) {
						Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "runReqprc[3]");

						bufxf = NULL;

						auto rng = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, arbbx, 0));
						if (rng.first != rng.second) bufxf = rng.first->second;

						Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "runReqprc[3]");

						if (bufxf) {
							bufxf->lockAccess("SysIdhwZedboardFwd", "runReqprc[2]");

							reqlen = bufxf->reqlen - bufxf->ptr;
							if (reqlen > 1024) reqlen = 1024;

							if ((arbbx == VecWIdhwZedbBuffer::DCXIFTOHOSTIF) || (arbbx == VecWIdhwZedbBuffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwZedbBuffer::QCDIFTOHOSTIF)) {
								if (bufxf->bref != brefWr_last) skipwr = false;
								brefWr_last = bufxf->bref;
							};
						};
					};

					if ((arbbx != VecWIdhwZedbBuffer::CMDRETTOHOSTIF) && !cmd && !bufxf) {
						// cmd / bufxf not found: re-do arbitration
						retry = false;
						throw DbeException("no suitable transfer for arbitration result found");

					} else {
						if (!(skipwr && ((arbbx == VecWIdhwZedbBuffer::HOSTIFTOCMDINV) || (arbbx == VecWIdhwZedbBuffer::HOSTIFTODCXIF) || (arbbx == VecWIdhwZedbBuffer::HOSTIFTOQCDIF)))) {
							// -- actual read/write transfer
							if (arbbx == VecWIdhwZedbBuffer::CMDRETTOHOSTIF) tkn = tknFromCmdret;
							else if (arbbx == VecWIdhwZedbBuffer::DCXIFTOHOSTIF) tkn = tknFromDcxif;
							else if (arbbx == VecWIdhwZedbBuffer::HOSTIFTOCMDINV) tkn = tknToCmdinv;
							else if (arbbx == VecWIdhwZedbBuffer::HOSTIFTODCXIF) tkn = tknToDcxif;
							else if (arbbx == VecWIdhwZedbBuffer::HOSTIFTOQCDIF) tkn = tknToQcdif;
							else if (arbbx == VecWIdhwZedbBuffer::PMMUTOHOSTIF) tkn = tknFromPmmu;
							else if (arbbx == VecWIdhwZedbBuffer::QCDIFTOHOSTIF) tkn = tknFromQcdif;

							invtkn = ~tkn;

							_txbuf[1] = tkn;

							// -> xferTkn
							_txbuf[0] = VecDbeVXfer::TKN;

							if (!inst->runReqprc_tx(2)) throw DbeException("error transferring data (rw/tkn)");

							// <- xferAvllen
							if (!inst->runReqprc_rx(6)) {
								retry = false; // a problem at this stage may imply that the last tkn = ~tkn failed
								throw DbeException("error transferring data (rw/avllen)");
							};
							if ( (_rxbuf[0] != VecDbeVXfer::AVLLEN) || (_rxbuf[1] != tkn) )
										throw DbeException("transfer/token error (rw/avllen): 0x" + Dbe::bufToHex(_rxbuf, 2) + " instead of 0x" + Dbe::binToHex(VecDbeVXfer::AVLLEN) + Dbe::binToHex(tkn));

							// -> xferReqlen
							_txbuf[0] = VecDbeVXfer::REQLEN;

							inst->runReqprc_setReqlen(reqlen);

							if (!inst->runReqprc_tx(6)) throw DbeException("error transferring data (rw/reqlen)");

							// <- xferArblen
							if (!inst->runReqprc_rx(6)) throw DbeException("error transferring data (rw/arblen)");
							if ( (_rxbuf[0] != VecDbeVXfer::ARBLEN) || (_rxbuf[1] != tkn) )
										throw DbeException("transfer/token error (rw/arblen): 0x" + Dbe::bufToHex(_rxbuf, 2) + " instead of 0x" + Dbe::binToHex(VecDbeVXfer::ARBLEN) + Dbe::binToHex(tkn));

							arblen = inst->runReqprc_getArblen();

							if (arblen > reqlen) throw DbeException("length arbitration error (rw/arblen): reqlen is " + to_string(reqlen) + " and arblen is " + to_string(arblen));

							if (arblen == 0) {
								// arbitrated length zero: re-do arbitration
								retry = false;
								throw DbeException("arbitrated length is zero");

							} else {
								if ((arbbx == VecWIdhwZedbBuffer::CMDRETTOHOSTIF) || (arbbx == VecWIdhwZedbBuffer::DCXIFTOHOSTIF) || (arbbx == VecWIdhwZedbBuffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwZedbBuffer::QCDIFTOHOSTIF)) {
									// - read

									// <- xferRd
									if (!inst->runReqprc_rx(arblen+4)) throw DbeException("error transferring data (read/rd)");
									if ( (_rxbuf[0] != VecDbeVXfer::RD) || (_rxbuf[1] != tkn) )
												throw DbeException("transfer/token error (read/rd): 0x" + Dbe::bufToHex(_rxbuf, 2) + " instead of 0x" + Dbe::binToHex(VecDbeVXfer::RD) + Dbe::binToHex(tkn));

									crc = inst->runReqprc_getCrc(2+arblen);
									hostcrc = inst->runReqprc_calcCrc(false, 2, arblen);

									// -> xferRdack
									_txbuf[0] = VecDbeVXfer::RDACK;

									if (crc == hostcrc) _txbuf[1] = invtkn;
									else _txbuf[1] = tkn;

									if (!inst->runReqprc_tx(2)) throw DbeException("error transferring data (read/rdack)");

									if (crc == hostcrc) retry = false; // read success

								} else if ((arbbx == VecWIdhwZedbBuffer::HOSTIFTOCMDINV) || (arbbx == VecWIdhwZedbBuffer::HOSTIFTODCXIF) || (arbbx == VecWIdhwZedbBuffer::HOSTIFTOQCDIF)) {
									// - write

									// -> xferWr
									_txbuf[0] = VecDbeVXfer::WR;

									if (cmd) {
										inst->runReqprc_setRoute(ixVTarget, cmd->tixVController);

										if (cmd->ixVState == Cmd::VecVState::WAITINV) _txbuf[2+4] = VecDbeVAction::INV;
										else if (cmd->ixVState == Cmd::VecVState::WAITREV) _txbuf[2+4] = VecDbeVAction::REV;

										inst->runReqprc_setCref(cmd->cref);

										if (cmd->ixVState == Cmd::VecVState::WAITINV) {
											_txbuf[2+9] = cmd->tixVCommand;

											cmd->parsInvToBuf(&parbuf, parbuflen);
											if (parbuf) {
												memcpy(&(_txbuf[2+10]), parbuf, parbuflen);
												delete[] parbuf;
											};

										} else if (cmd->ixVState == Cmd::VecVState::WAITREV) {
											_txbuf[2+9] = cmd->tixVCommand;
										};

									} else if (bufxf) {
										memcpy(&(_txbuf[2]), &(bufxf->data[bufxf->ptr]), arblen);
									};

									hostcrc = inst->runReqprc_calcCrc(true, 2, arblen);
									inst->runReqprc_setCrc(2+arblen, hostcrc);

									if (!inst->runReqprc_tx(arblen+4)) throw DbeException("error transferring data (write/wr)");

									// <- xferWrack
									if (!inst->runReqprc_rx(2)) {
										retry = false;
										throw DbeException("error transferring data (write/wrack)");
									};
									if ( (_rxbuf[0] != VecDbeVXfer::WRACK) || ((_rxbuf[1] != tkn) && (_rxbuf[1] != invtkn)) )
												throw DbeException("transfer/token error (write/wrack): 0x" + Dbe::bufToHex(_rxbuf, 2) + " instead of 0x" + Dbe::binToHex(VecDbeVXfer::WRACK) + Dbe::binToHex(tkn) + " or 0x"  + Dbe::binToHex(VecDbeVXfer::WRACK) + Dbe::binToHex(invtkn));

									if (_rxbuf[1] == invtkn) retry = false; // write success
								};
							};

							if (!retry) {
								if (arbbx == VecWIdhwZedbBuffer::CMDRETTOHOSTIF) tknFromCmdret = invtkn;
								else if (arbbx == VecWIdhwZedbBuffer::DCXIFTOHOSTIF) tknFromDcxif = invtkn;
								else if (arbbx == VecWIdhwZedbBuffer::HOSTIFTOCMDINV) tknToCmdinv = invtkn;
								else if (arbbx == VecWIdhwZedbBuffer::HOSTIFTODCXIF) tknToDcxif = invtkn;
								else if (arbbx == VecWIdhwZedbBuffer::HOSTIFTOQCDIF) tknToQcdif = invtkn;
								else if (arbbx == VecWIdhwZedbBuffer::PMMUTOHOSTIF) tknFromPmmu = invtkn;
								else if (arbbx == VecWIdhwZedbBuffer::QCDIFTOHOSTIF) tknFromQcdif = invtkn;
							};
						};
					};
				};
			};

		} catch (DbeException e) {
			if (inst->dumpexc) cout << "DbeException: " << e.err << endl;

			if (rst) rst->unlockAccess("SysIdhwZedboardFwd", "runReqprc[1]");
			else if (cmd) cmd->unlockAccess("SysIdhwZedboardFwd", "runReqprc[1]");
			else if (bufxf) bufxf->unlockAccess("SysIdhwZedboardFwd", "runReqprc[2]");

			inst->runReqprc_recover();

			if (!retry) continue; // skip post-processing
		};

		if (!retry) {
			// --- post-processing
			Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "runReqprc[4]");

			if (rst) {
				for (auto it=rst->subIcsVTarget.begin();it!=rst->subIcsVTarget.end();it++) {
					ixVTarget = *it;

					// all rsts of any of the subIcsVTarget become obsolete
					auto rngRsts = xchg->rref2sRsts.equal_range(rstref2_t(ixVTarget));

					for (auto it2=rngRsts.first;it2!=rngRsts.second;it2++) {
						auto it3 = xchg->rsts.find(it2->second);
						if (it3 != xchg->rsts.end()) rstsElim.insert(it3->second);
					};

					for (auto it2=rstsElim.begin();it2!=rstsElim.end();it2++) {
						rst2 = *it2;

						rst2->lockAccess("SysIdhwZedboardFwd", "runReqprc[1]");

						xchg->changeRstState(rst2, Rst::VecVState::DONE);

						elim = !rst2->progressCallback;
						if (rst2->progressCallback) if (rst2->progressCallback(rst2, rst2->argProgressCallback)) elim = true;

						rst2->unlockAccess("SysIdhwZedboardFwd", "runReqprc[2]");

						if (elim) {
							xchg->removeRst(rst2);
							delete rst2;
						};
					};

					rstsElim.clear();

					// all bufxfs that are for any of the subIcsVTarget become obsolete
					auto rngBufxfs2 = xchg->bref2sBufxfs.equal_range(bufxfref2_t(ixVTarget));

					for (auto it2=rngBufxfs2.first;it2!=rngBufxfs2.second;it2++) {
						auto it3 = xchg->bufxfs.find(it2->second);
						if (it3 != xchg->bufxfs.end()) bufxfsElim.insert(it3->second);
					};

					for (auto it2=bufxfsElim.begin();it2!=bufxfsElim.end();it2++) {
						bufxf2 = *it2;

						bufxf2->lockAccess("SysIdhwZedboardFwd", "runReqprc[3]");

						bufxf2->success = false;
						xchg->changeBufxfState(bufxf2, Bufxf::VecVState::DONE);

						elim = (!bufxf2->progressCallback && !bufxf2->errorCallback && !bufxf2->doneCallback);
						if (bufxf2->progressCallback) if (bufxf2->progressCallback(bufxf2, bufxf2->argProgressCallback)) elim = true;
						if (bufxf2->errorCallback) if (bufxf2->errorCallback(bufxf2, bufxf2->argErrorCallback)) elim = true;
						if (bufxf2->doneCallback) if (bufxf2->doneCallback(bufxf2, bufxf2->argDoneCallback)) elim = true;

						bufxf2->unlockAccess("SysIdhwZedboardFwd", "runReqprc[3]");

						if (elim) {
							xchg->removeBufxf(bufxf2);
							delete bufxf2;
						};
					};

					bufxfsElim.clear();

					// all cmds that are for any of the subIcsVTarget become obsolete
					auto rngCmds2 = xchg->cref2sCmds.equal_range(cmdref2_t(ixVTarget));

					for (auto it2=rngCmds2.first;it2!=rngCmds2.second;it2++) {
						auto it3 = xchg->cmds.find(it2->second);
						if (it3 != xchg->cmds.end()) cmdsElim.insert(it3->second);
					};

					for (auto it2=cmdsElim.begin();it2!=cmdsElim.end();it2++) {
						cmd2 = *it2;

						cmd2->lockAccess("SysIdhwZedboardFwd", "runReqprc[2]");

						cmd2->err = Err::getNewRsterr();
						xchg->changeCmdState(cmd2, Cmd::VecVState::DONE);

						elim = (!cmd2->progressCallback && !cmd2->errorCallback && !cmd2->doneCallback);
						if (cmd2->progressCallback) if (cmd2->progressCallback(cmd2, cmd2->argProgressCallback)) elim = true;
						if (cmd2->errorCallback) if (cmd2->errorCallback(cmd2, cmd2->argErrorCallback)) elim = true;
						if (cmd2->doneCallback) if (cmd2->doneCallback(cmd2, cmd2->argDoneCallback)) elim = true;

						cmd2->unlockAccess("SysIdhwZedboardFwd", "runReqprc[2]");

						if (elim) {
							xchg->removeCmd(cmd2);
							delete cmd2;
						};
					};

					cmdsElim.clear();
				};

				xchg->changeRstState(rst, Rst::VecVState::DONE);

				elim = !rst->progressCallback;
				if (rst->progressCallback) if (rst->progressCallback(rst, rst->argProgressCallback)) elim = true;

				rst->unlockAccess("SysIdhwZedboardFwd", "runReqprc[3]");

				if (elim) {
					xchg->removeRst(rst);
					delete rst;
				};

			} else if (arbbx) {
				// -- update resource and unlock
				if (arbbx == VecWIdhwZedbBuffer::CMDRETTOHOSTIF) {
					cref = inst->runReqprc_getCref();

					if (!(skiprd && (cref == crefRd_last))) {
						auto it = xchg->cmds.find(cmdref_t(Cmd::VecVState::WAITRET, cref));
						if (it != xchg->cmds.end()) cmd = it->second;
						else {
							it = xchg->cmds.find(cmdref_t(Cmd::VecVState::WAITNEWRET, cref));
							if (it != xchg->cmds.end()) cmd = it->second;
						};

						if (cmd) {
							cmd->lockAccess("SysIdhwZedboardFwd", "runReqprc[3]");

							crefRd_last = cmd->cref;

							if ((_rxbuf[2+4] == VecDbeVAction::RET) || (_rxbuf[2+4] == VecDbeVAction::NEWRET)) {
								cmd->err = Err(0x00);

								cmd->bufToParsRet(&(_rxbuf[2+4+1+4]), arblen-4-1-4);

								if (cmd->ixVRettype == Cmd::VecVRettype::MULT) cmd->Nret++;
								else xchg->changeCmdState(cmd, Cmd::VecVState::DONE);

								cmd->returnToCallback();

							} else {
								cmd->err = Err();

								if (_rxbuf[2+4] == VecDbeVAction::ERR) cmd->err = inst->getNewErr(cmd->ixVTarget, cmd->tixVController, _rxbuf[2+4+1+4]);
								else if (_rxbuf[2+4] == VecDbeVAction::RTEERR) cmd->err = Err::getNewRteerr();
								else if (_rxbuf[2+4] == VecDbeVAction::CREFERR) cmd->err = Err::getNewCreferr();
								else if (_rxbuf[2+4] == VecDbeVAction::FWDERR) cmd->err = Err::getNewFwderr();
								else if (_rxbuf[2+4] == VecDbeVAction::CMDERR) cmd->err = Err::getNewCmderr();

								cmd->err.bufToPars(&(_rxbuf[2+4+1+4+1]), arblen-4-1-4-1);

								xchg->changeCmdState(cmd, Cmd::VecVState::DONE);
							};

							elim = false;

							if (cmd->ixVState == Cmd::VecVState::DONE) {
								if (cmd->err.tixDbeVAction == 0x00) elim = (!cmd->progressCallback && !cmd->doneCallback);
								else elim = (!cmd->progressCallback && !cmd->errorCallback && !cmd->doneCallback);

								if (cmd->progressCallback) if (cmd->progressCallback(cmd, cmd->argProgressCallback)) elim = true;
								if ((cmd->err.tixDbeVAction != 0x00) && cmd->errorCallback) if (cmd->errorCallback(cmd, cmd->argErrorCallback)) elim = true;
								if (cmd->doneCallback) if (cmd->doneCallback(cmd, cmd->argDoneCallback)) elim = true;
							};

							cmd->unlockAccess("SysIdhwZedboardFwd", "runReqprc[3]");

							if (elim) {
								xchg->removeCmd(cmd);
								delete cmd;
							};
						};
					};

				} else if (cmd) {
					if ((cmd->ixVState == Cmd::VecVState::WAITREV) || (cmd->ixVRettype == Cmd::VecVRettype::VOID)) {
						cmd->err = Err(0x00);

						xchg->changeCmdState(cmd, Cmd::VecVState::DONE);

					} else if ((cmd->ixVRettype == Cmd::VecVRettype::IMMSNG) || (cmd->ixVRettype == Cmd::VecVRettype::DFRSNG)) xchg->changeCmdState(cmd, Cmd::VecVState::WAITRET);
					else if (cmd->ixVRettype == Cmd::VecVRettype::MULT) xchg->changeCmdState(cmd, Cmd::VecVState::WAITNEWRET);

					elim = false;

					if (cmd->progressCallback) if (cmd->progressCallback(cmd, cmd->argProgressCallback) && (cmd->ixVState == Cmd::VecVState::DONE)) elim = true; // left-to-right order in second if matters

					if (cmd->ixVState == Cmd::VecVState::DONE) {
						if (!cmd->progressCallback && !cmd->doneCallback) elim = true;
						if (cmd->doneCallback) if (cmd->doneCallback(cmd, cmd->argDoneCallback)) elim = true;
					};

					cmd->unlockAccess("SysIdhwZedboardFwd", "runReqprc[4]");

					if (elim) {
						xchg->removeCmd(cmd);
						delete cmd;
					};

				} else if (bufxf) {
					if (!(skiprd && (bufxf->bref == brefRd_last))) {
						if ((arbbx == VecWIdhwZedbBuffer::DCXIFTOHOSTIF) || (arbbx == VecWIdhwZedbBuffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwZedbBuffer::QCDIFTOHOSTIF)) {
							brefRd_last = bufxf->bref;

							bufxf->appendReadData(&(_rxbuf[2]), arblen);

						} else if ((arbbx == VecWIdhwZedbBuffer::HOSTIFTODCXIF) || (arbbx == VecWIdhwZedbBuffer::HOSTIFTOQCDIF)) {
							bufxf->ptr += arblen;
						};

						elim = false;

						if (bufxf->ptr == bufxf->reqlen) {
							if (bufxf->cmds.empty()) {
								bufxf->success = true;
								xchg->changeBufxfState(bufxf, Bufxf::VecVState::DONE);
							} else xchg->changeBufxfState(bufxf, Bufxf::VecVState::WAITRET);

							if (bufxf->progressCallback) if (bufxf->progressCallback(bufxf, bufxf->argProgressCallback) && (bufxf->ixVState == Bufxf::VecVState::DONE)) elim = true;

							if (bufxf->ixVState == Bufxf::VecVState::DONE) {
								if (!bufxf->progressCallback && !bufxf->doneCallback) elim = true;
								if (bufxf->doneCallback) if (bufxf->doneCallback(bufxf, bufxf->argDoneCallback)) elim = true;
							};

						} else {
							if (bufxf->progressCallback) bufxf->progressCallback(bufxf, bufxf->argProgressCallback);
						};

						bufxf->unlockAccess("SysIdhwZedboardFwd", "runReqprc[4]");

						if (elim) {
							xchg->removeBufxf(bufxf);
							delete bufxf;
						};
					};
				};
			};

			Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "runReqprc[4]");
		};
	};

	pthread_cleanup_pop(0);

	return(NULL);
};

void SysIdhwZedboardFwd::cleanupReqprc(
			void* arg
		) {
	SysIdhwZedboardFwd* inst = (SysIdhwZedboardFwd*) arg;

	XchgIdhw* xchg = inst->xchg;

	Mutex::unlock(&(xchg->mcReqprc), "xchg->mcReqprc", "SysIdhwZedboardFwd", "cleanupReqprc");

	inst->runReqprc_close();

	if (inst->rxbuf) delete[](inst->rxbuf);
	if (inst->txbuf) delete[](inst->txbuf);
};

void SysIdhwZedboardFwd::runReqprc_open() {
	// IP runReqprc_open --- IBEGIN
	// open character device
	fd = open(path.c_str(), O_RDWR);
	if (fd == -1) {
		fd = 0;
		throw DbeException("error opening device " + path + "");
	};
	// IP runReqprc_open --- IEND
};

bool SysIdhwZedboardFwd::runReqprc_rx(
			const size_t rxlen
		) {
	bool retval = (rxlen == 0);

	// IP runReqprc_rx --- IBEGIN
	if (rxlen != 0) {
		size_t nleft;
		int n;

		if (dumprxtx) cout << "rx ";

		nleft = rxlen;
		n = 0;

		while (nleft > 0) {
			n = read(fd, &(rxbuf[rxlen-nleft]), nleft);

			if (n >= 0) nleft -= n;
			else break;
		};

		retval = (nleft == 0);

		if (dumprxtx) {
			if (nleft == 0) cout << "0x" << Dbe::bufToHex(rxbuf, rxlen, true) << endl;
			else cout << string(strerror(n)) << endl;
		};
	};
	// IP runReqprc_rx --- IEND

	return retval;
};

bool SysIdhwZedboardFwd::runReqprc_tx(
			const size_t txlen
		) {
	bool retval = (txlen == 0);

	// IP runReqprc_tx --- IBEGIN
	if (txlen != 0) {
		size_t nleft;
		int n;

		if (dumprxtx) cout << "tx ";

		nleft = txlen;
		n = 0;

		while (nleft > 0) {
			n = write(fd, &(txbuf[txlen-nleft]), nleft);

			if (n >= 0) nleft -= n;
			else break;
		};

		retval = (nleft == 0);

		if (dumprxtx) {
			if (nleft == 0) cout << "0x" << Dbe::bufToHex(txbuf, txlen, true) << endl;
			else cout << string(strerror(n)) << endl;
		};
	};
	// IP runReqprc_tx --- IEND

	return retval;
};

void SysIdhwZedboardFwd::runReqprc_recover() {
	// IP runReqprc_recover --- INSERT
};

void SysIdhwZedboardFwd::runReqprc_close() {
	// IP runReqprc_close --- IBEGIN
	if (fd) {
		close(fd);
		fd = 0;
	};
	// IP runReqprc_close --- IEND
};

size_t SysIdhwZedboardFwd::runReqprc_getAvllen() {
	// rxbuf bytes 2..5
	uint _len;

	const size_t ofs = 2;

	_len = (rxbuf[ofs] << 24) + (rxbuf[ofs+1] << 16) + (rxbuf[ofs+2] << 8) + rxbuf[ofs+3];

	return _len;
};

void SysIdhwZedboardFwd::runReqprc_setReqlen(
			const size_t len
		) {
	// txbuf bytes 2..5
	unsigned int _len = len;

	unsigned char* ptr = (unsigned char*) &_len;

	const size_t ofs = 2;

	if (Dbe::bigendian()) {
		txbuf[ofs] = ptr[0];
		txbuf[ofs+1] = ptr[1];
		txbuf[ofs+2] = ptr[2];
		txbuf[ofs+3] = ptr[3];
	} else {
		txbuf[ofs] = ptr[3];
		txbuf[ofs+1] = ptr[2];
		txbuf[ofs+2] = ptr[1];
		txbuf[ofs+3] = ptr[0];
	};
};

size_t SysIdhwZedboardFwd::runReqprc_getArblen() {
	// rxbuf bytes 2..5
	uint _len;

	const size_t ofs = 2;

	_len = (rxbuf[ofs] << 24) + (rxbuf[ofs+1] << 16) + (rxbuf[ofs+2] << 8) + rxbuf[ofs+3];

	return _len;
};

void SysIdhwZedboardFwd::runReqprc_setRoute(
			const uint ixVTarget
			, const utinyint tixVController
		) {
	// txbuf bytes 2..5
	const size_t ofs = 2;

	txbuf[ofs] = 0x00;
	txbuf[ofs+1] = 0x00;
	txbuf[ofs+2] = 0x00;
	txbuf[ofs+3] = 0x00;

	if (ixVTarget == VecVTarget::AXS2_PHI) {
		txbuf[ofs] = VecVIdhwZedbController::PHIIF;
		txbuf[ofs+1] = tixVController;
	} else if (ixVTarget == VecVTarget::AXS2_THETA) {
		txbuf[ofs] = VecVIdhwZedbController::THETAIF;
		txbuf[ofs+1] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3) {
		txbuf[ofs] = VecVIdhwZedbController::DCXIF;
		txbuf[ofs+1] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) {
		txbuf[ofs] = VecVIdhwZedbController::DCXIF;
		txbuf[ofs+1] = VecVIdhwDcx3Controller::PHIIF;
		txbuf[ofs+2] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) {
		txbuf[ofs] = VecVIdhwZedbController::DCXIF;
		txbuf[ofs+1] = VecVIdhwDcx3Controller::THETAIF;
		txbuf[ofs+2] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3_ICM2) {
		txbuf[ofs] = VecVIdhwZedbController::DCXIF;
		txbuf[ofs+1] = VecVIdhwDcx3Controller::QCDIF;
		txbuf[ofs+2] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3_TAU2) {
		txbuf[ofs] = VecVIdhwZedbController::DCXIF;
		txbuf[ofs+1] = VecVIdhwDcx3Controller::LWIRIF;
		txbuf[ofs+2] = tixVController;
	} else if (ixVTarget == VecVTarget::ICM2) {
		txbuf[ofs] = VecVIdhwZedbController::QCDIF;
		txbuf[ofs+1] = tixVController;
	} else if (ixVTarget == VecVTarget::ZEDB) {
		txbuf[ofs] = tixVController;
	};
};

uint SysIdhwZedboardFwd::runReqprc_getCref() {
	// rxbuf bytes 7..10
	uint cref;

	const size_t ofs = 7;

	cref = (rxbuf[ofs] << 24) + (rxbuf[ofs+1] << 16) + (rxbuf[ofs+2] << 8) + rxbuf[ofs+3];

	return cref;
};

void SysIdhwZedboardFwd::runReqprc_setCref(
			const uint cref
		) {
	// txbuf bytes 7..10
	unsigned char* ptr = (unsigned char*) &cref;

	const size_t ofs = 7;

	if (Dbe::bigendian()) {
		txbuf[ofs] = ptr[0];
		txbuf[ofs+1] = ptr[1];
		txbuf[ofs+2] = ptr[2];
		txbuf[ofs+3] = ptr[3];
	} else {
		txbuf[ofs] = ptr[3];
		txbuf[ofs+1] = ptr[2];
		txbuf[ofs+2] = ptr[1];
		txbuf[ofs+3] = ptr[0];
	};
};

unsigned short SysIdhwZedboardFwd::runReqprc_calcCrc(
			const bool txbufNotRxbuf
			, const size_t ofs
			, const size_t len
		) {
	Crc crc;
	
	if (txbufNotRxbuf) crc.includeBytes(&(txbuf[ofs]), len);
	else crc.includeBytes(&(rxbuf[ofs]), len);

	crc.finalize();

	return(crc.crc);
};

unsigned short SysIdhwZedboardFwd::runReqprc_getCrc(
			const size_t ofs
		) {
	// rxbuf[ofs] bytes 0..1
	unsigned short crc;
	
	crc = (rxbuf[ofs] << 8) + rxbuf[ofs+1];

	return crc;
};

void SysIdhwZedboardFwd::runReqprc_setCrc(
			const size_t ofs
			, unsigned short crc
		) {
	// txbuf[ofs] bytes 0..1
	unsigned char* ptr = (unsigned char*) &crc;

	if (Dbe::bigendian()) {
		txbuf[ofs] = ptr[0];
		txbuf[ofs+1] = ptr[1];
	} else {
		txbuf[ofs] = ptr[1];
		txbuf[ofs+1] = ptr[0];
	};
};

bool SysIdhwZedboardFwd::rstCmdProgressCallback(
			Cmd* cmd
			, void* _arg
		) {
	RstCmdProgressCallback_arg* arg = (RstCmdProgressCallback_arg*) _arg;

	SysIdhwZedboardFwd* inst = arg->inst;
	XchgIdhw* xchg = inst->xchg;

	Rst* rst = arg->rst;

	bool elim = false;

	// assume rst is in state WAITINV

	rst->lockAccess("SysIdhwZedboardFwd", "rstCmdProgressCallback");

	if (cmd->ixVState == Cmd::VecVState::DONE) {
		//rst->success = (cmd->err.tixVError == 0x00);

		rst->cmd = NULL;
		elim = true;

		xchg->changeRstState(rst, Rst::VecVState::WAITRST);
		if (rst->progressCallback) rst->progressCallback(rst, rst->argProgressCallback);
	};

	rst->unlockAccess("SysIdhwZedboardFwd", "rstCmdProgressCallback");

	return elim;
};

bool SysIdhwZedboardFwd::bufxfCmdProgressCallback(
			Cmd* cmd
			, void* _arg
		) {
	BufxfCmdProgressCallback_arg* arg = (BufxfCmdProgressCallback_arg*) _arg;

	SysIdhwZedboardFwd* inst = arg->inst;
	XchgIdhw* xchg = inst->xchg;

	Bufxf* bufxf = arg->bufxf;

	Cmd* cmd2 = NULL;

	bool waitrev;

	bool elim = false;

	bool step = false;

	bool bufxfelim;

	bufxf->lockAccess("SysIdhwZedboardFwd", "bufxfCmdProgressCallback");

	if (cmd->err.tixVError != 0x00) {
		// during any bufxf state, WAITXFER in particular

		waitrev = false;

		for (unsigned int i=0;i<bufxf->cmds.size();i++) {
			cmd2 = bufxf->cmds[i];

			if (cmd2) {
				if (cmd2 == cmd) {
					elim = true;
					bufxf->cmds[i] = NULL;

				} else {
					if (cmd2->ixVState == Cmd::VecVState::WAITRET) {
						xchg->changeCmdState(cmd2, Cmd::VecVState::WAITREV);
						// no need to call progress callback (this method)
						waitrev = true;

					} else {
						xchg->removeCmd(cmd2);
						delete cmd2;
						bufxf->cmds[i] = NULL;
					};
				};
			};
		};

		step = true;

		if (waitrev) xchg->changeBufxfState(bufxf, Bufxf::VecVState::WAITRET);
		else xchg->changeBufxfState(bufxf, Bufxf::VecVState::DONE);

	} else {
		if (bufxf->ixVState == Bufxf::VecVState::WAITINV) {
			step = true;

			for (unsigned int i=0;i<bufxf->cmds.size();i++)
				if (bufxf->cmds[i]->ixVState != Cmd::VecVState::WAITRET) {
					step = false;
					break;
				};

			if (step) xchg->changeBufxfState(bufxf, Bufxf::VecVState::WAITXFER);

		} else if (bufxf->ixVState == Bufxf::VecVState::WAITRET) {
			// at this stage, the data transfer is either complete or a cmd error has occurred previously
			step = true;

			for (unsigned int i=0;i<bufxf->cmds.size();i++) {
				cmd2 = bufxf->cmds[i];

				if (cmd2) {
					if ((cmd2 == cmd) && (cmd2->ixVState == Cmd::VecVState::DONE)) {
						elim = true;
						bufxf->cmds[i] = NULL;
					
					} else if (cmd2->ixVState != Cmd::VecVState::DONE) {
						step = false;
					};
				};
			};

			if (step) {
				bufxf->success = (bufxf->ptr == bufxf->reqlen);
				xchg->changeBufxfState(bufxf, Bufxf::VecVState::DONE);
			};
		};
	};

	bufxfelim = false;

	if (step) {
		if (bufxf->progressCallback) if (bufxf->progressCallback(bufxf, bufxf->argProgressCallback) && (bufxf->ixVState == Bufxf::VecVState::DONE)) bufxfelim = true;

		if (bufxf->ixVState == Bufxf::VecVState::DONE) {
			if (!bufxf->progressCallback && !bufxf->doneCallback) bufxfelim = true;
			if (bufxf->doneCallback) if (bufxf->doneCallback(bufxf, bufxf->argDoneCallback)) bufxfelim = true;
		};
	};

	bufxf->unlockAccess("SysIdhwZedboardFwd", "bufxfCmdProgressCallback");

	if (bufxfelim) {
		xchg->removeBufxf(bufxf);
		delete bufxf;
	};

	return elim;
};

Rst* SysIdhwZedboardFwd::getFirstRst(
			const uint ixVState
		) {
	Rst* rst = NULL;
	pair<multimap<rstref_t,Rst*>::iterator,multimap<rstref_t,Rst*>::iterator> rngRsts;

	Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "getFirstRst");

	rngRsts = xchg->rsts.equal_range(rstref_t(ixVState, 0));
	if (rngRsts.first != rngRsts.second) {
		rst = rngRsts.first->second;
		rst->lockAccess("SysIdhwZedboardFwd", "getFirstRst");
	};

	Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "getFirstRst");

	return rst;
};

Bufxf* SysIdhwZedboardFwd::getFirstBufxf(
			const uint ixVState
		) {
	Bufxf* bufxf = NULL;
	pair<multimap<bufxfref_t,Bufxf*>::iterator,multimap<bufxfref_t,Bufxf*>::iterator> rngBufxfs;

	Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "getFirstBufxf");

	rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(ixVState, 0));
	if (rngBufxfs.first != rngBufxfs.second) {
		bufxf = rngBufxfs.first->second;
		bufxf->lockAccess("SysIdhwZedboardFwd", "getFirstBufxf");
	};

	Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwZedboardFwd", "getFirstBufxf");

	return bufxf;
};

// IP cust --- IBEGIN
void SysIdhwZedboardFwd::init(
			const string& _path
		) {
	path = _path;

	pthread_attr_t attr;

	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

	pthread_create(&prepprc, &attr, &SysIdhwZedboardFwd::runPrepprc, (void*) this);
	pthread_create(&reqprc, &attr, &SysIdhwZedboardFwd::runReqprc, (void*) this);

	initdone = true;
};

void SysIdhwZedboardFwd::term() {
	if (initdone) {
		pthread_cancel(prepprc);
		pthread_join(prepprc, NULL);

		pthread_cancel(reqprc);
		pthread_join(reqprc, NULL);

		initdone = false;
	};
};
// IP cust --- IEND

UntIdhw* SysIdhwZedboardFwd::connectToTarget(
			const uint ixVTarget
		) {
	UntIdhw* unt = NULL;

	if (ixVTarget == VecVTarget::AXS2_PHI) unt = new UntIdhwAxs2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::AXS2_THETA) unt = new UntIdhwAxs2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3) unt = new UntIdhwDcx3(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) unt = new UntIdhwAxs2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) unt = new UntIdhwAxs2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) unt = new UntIdhwIcm2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3_TAU2) unt = new UntIdhwTau2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::ICM2) unt = new UntIdhwIcm2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::ZEDB) unt = new UntIdhwZedb(xchg, ixVTarget);

	return unt;
};

uint SysIdhwZedboardFwd::getIxVTargetBySref(
			const string& sref
		) {
	return VecVTarget::getIx(sref);
};

string SysIdhwZedboardFwd::getSrefByIxVTarget(
			const uint ixVTarget
		) {
	return VecVTarget::getSref(ixVTarget);
};

void SysIdhwZedboardFwd::fillFeedFTarget(
			Feed& feed
		) {
	VecVTarget::fillFeed(feed);
};

utinyint SysIdhwZedboardFwd::getTixVControllerBySref(
			const uint ixVTarget
			, const string& sref
		) {
	utinyint tixVController = 0;

	if (ixVTarget == VecVTarget::DCX3) tixVController = UntIdhwDcx3::getTixVControllerBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) tixVController = UntIdhwIcm2::getTixVControllerBySref(sref);
	else if (ixVTarget == VecVTarget::ICM2) tixVController = UntIdhwIcm2::getTixVControllerBySref(sref);
	else if (ixVTarget == VecVTarget::ZEDB) tixVController = UntIdhwZedb::getTixVControllerBySref(sref);

	return tixVController;
};

string SysIdhwZedboardFwd::getSrefByTixVController(
			const uint ixVTarget
			, const utinyint tixVController
		) {
	string sref;

	if (ixVTarget == VecVTarget::DCX3) sref = UntIdhwDcx3::getSrefByTixVController(tixVController);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) sref = UntIdhwIcm2::getSrefByTixVController(tixVController);
	else if (ixVTarget == VecVTarget::ICM2) sref = UntIdhwIcm2::getSrefByTixVController(tixVController);
	else if (ixVTarget == VecVTarget::ZEDB) sref = UntIdhwZedb::getSrefByTixVController(tixVController);

	return sref;
};

void SysIdhwZedboardFwd::fillFeedFController(
			const uint ixVTarget
			, Feed& feed
		) {
	feed.clear();

	if (ixVTarget == VecVTarget::DCX3) UntIdhwDcx3::fillFeedFController(feed);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) UntIdhwIcm2::fillFeedFController(feed);
	else if (ixVTarget == VecVTarget::ICM2) UntIdhwIcm2::fillFeedFController(feed);
	else if (ixVTarget == VecVTarget::ZEDB) UntIdhwZedb::fillFeedFController(feed);
};

utinyint SysIdhwZedboardFwd::getTixWBufferBySref(
			const uint ixVTarget
			, const string& sref
		) {
	utinyint tixWBuffer = 0;

	if (ixVTarget == VecVTarget::DCX3) tixWBuffer = UntIdhwDcx3::getTixWBufferBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) tixWBuffer = UntIdhwIcm2::getTixWBufferBySref(sref);
	else if (ixVTarget == VecVTarget::ICM2) tixWBuffer = UntIdhwIcm2::getTixWBufferBySref(sref);
	else if (ixVTarget == VecVTarget::ZEDB) tixWBuffer = UntIdhwZedb::getTixWBufferBySref(sref);

	return tixWBuffer;
};

string SysIdhwZedboardFwd::getSrefByTixWBuffer(
			const uint ixVTarget
			, const utinyint tixWBuffer
		) {
	string sref;

	if (ixVTarget == VecVTarget::DCX3) sref = UntIdhwDcx3::getSrefByTixWBuffer(tixWBuffer);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) sref = UntIdhwIcm2::getSrefByTixWBuffer(tixWBuffer);
	else if (ixVTarget == VecVTarget::ICM2) sref = UntIdhwIcm2::getSrefByTixWBuffer(tixWBuffer);
	else if (ixVTarget == VecVTarget::ZEDB) sref = UntIdhwZedb::getSrefByTixWBuffer(tixWBuffer);

	return sref;
};

void SysIdhwZedboardFwd::fillFeedFBuffer(
			const uint ixVTarget
			, Feed& feed
		) {
	feed.clear();

	if (ixVTarget == VecVTarget::DCX3) UntIdhwDcx3::fillFeedFBuffer(feed);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) UntIdhwIcm2::fillFeedFBuffer(feed);
	else if (ixVTarget == VecVTarget::ICM2) UntIdhwIcm2::fillFeedFBuffer(feed);
	else if (ixVTarget == VecVTarget::ZEDB) UntIdhwZedb::fillFeedFBuffer(feed);
};

utinyint SysIdhwZedboardFwd::getTixVCommandBySref(
			const uint ixVTarget
			, const utinyint tixVController
			, const string& sref
		) {
	utinyint tixVCommand = 0;

	if (ixVTarget == VecVTarget::AXS2_PHI) tixVCommand = UntIdhwAxs2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::AXS2_THETA) tixVCommand = UntIdhwAxs2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3) tixVCommand = UntIdhwDcx3::getTixVCommandBySref(tixVController, sref);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) tixVCommand = UntIdhwAxs2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) tixVCommand = UntIdhwAxs2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) tixVCommand = UntIdhwIcm2::getTixVCommandBySref(tixVController, sref);
	else if (ixVTarget == VecVTarget::DCX3_TAU2) tixVCommand = UntIdhwTau2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::ICM2) tixVCommand = UntIdhwIcm2::getTixVCommandBySref(tixVController, sref);
	else if (ixVTarget == VecVTarget::ZEDB) tixVCommand = UntIdhwZedb::getTixVCommandBySref(tixVController, sref);

	return tixVCommand;
};

string SysIdhwZedboardFwd::getSrefByTixVCommand(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVCommand
		) {
	string sref;

	if (ixVTarget == VecVTarget::AXS2_PHI) sref = UntIdhwAxs2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::AXS2_THETA) sref = UntIdhwAxs2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3) sref = UntIdhwDcx3::getSrefByTixVCommand(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) sref = UntIdhwAxs2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) sref = UntIdhwAxs2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) sref = UntIdhwIcm2::getSrefByTixVCommand(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_TAU2) sref = UntIdhwTau2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::ICM2) sref = UntIdhwIcm2::getSrefByTixVCommand(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::ZEDB) sref = UntIdhwZedb::getSrefByTixVCommand(tixVController, tixVCommand);

	return sref;
};

void SysIdhwZedboardFwd::fillFeedFCommand(
			const uint ixVTarget
			, const utinyint tixVController
			, Feed& feed
		) {
	feed.clear();

	if (ixVTarget == VecVTarget::AXS2_PHI) UntIdhwAxs2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::AXS2_THETA) UntIdhwAxs2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::DCX3) UntIdhwDcx3::fillFeedFCommand(tixVController, feed);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) UntIdhwAxs2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) UntIdhwAxs2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) UntIdhwIcm2::fillFeedFCommand(tixVController, feed);
	else if (ixVTarget == VecVTarget::DCX3_TAU2) UntIdhwTau2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::ICM2) UntIdhwIcm2::fillFeedFCommand(tixVController, feed);
	else if (ixVTarget == VecVTarget::ZEDB) UntIdhwZedb::fillFeedFCommand(tixVController, feed);
};

string SysIdhwZedboardFwd::getSrefByTixVError(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	string sref;

	return sref;
};

string SysIdhwZedboardFwd::getTitleByTixVError(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	string Title;

	return Title;
};

Bufxf* SysIdhwZedboardFwd::getNewBufxf(
			const uint ixVTarget
			, const utinyint tixWBuffer
			, const size_t reqlen
		) {
	Bufxf* bufxf = NULL;

	if (ixVTarget == VecVTarget::DCX3) bufxf = UntIdhwDcx3::getNewBufxf(tixWBuffer, reqlen);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) bufxf = UntIdhwIcm2::getNewBufxf(tixWBuffer, reqlen);
	else if (ixVTarget == VecVTarget::ICM2) bufxf = UntIdhwIcm2::getNewBufxf(tixWBuffer, reqlen);
	else if (ixVTarget == VecVTarget::ZEDB) bufxf = UntIdhwZedb::getNewBufxf(tixWBuffer, reqlen);

	if (bufxf) bufxf->ixVTarget = ixVTarget;

	return bufxf;
};

Cmd* SysIdhwZedboardFwd::getNewCmd(
			const uint ixVTarget
			, const utinyint tixVController
			, const uint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (ixVTarget == VecVTarget::AXS2_PHI) cmd = UntIdhwAxs2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::AXS2_THETA) cmd = UntIdhwAxs2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3) cmd = UntIdhwDcx3::getNewCmd(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) cmd = UntIdhwAxs2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) cmd = UntIdhwAxs2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) cmd = UntIdhwIcm2::getNewCmd(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_TAU2) cmd = UntIdhwTau2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::ICM2) cmd = UntIdhwIcm2::getNewCmd(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::ZEDB) cmd = UntIdhwZedb::getNewCmd(tixVController, tixVCommand);

	if (cmd) cmd->ixVTarget = ixVTarget;

	return cmd;
};

Err SysIdhwZedboardFwd::getNewErr(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	Err err;

	return err;
};



