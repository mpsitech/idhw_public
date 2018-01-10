/**
  * \file SysIdhwBasys3Fwd.cpp
  * SPI command forwarder based on Digilent Basys3 board system (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "SysIdhwBasys3Fwd.h"

#include "SysIdhwBasys3Fwd_vecs.cpp"

/******************************************************************************
 class SysIdhwBasys3Fwd
 ******************************************************************************/

SysIdhwBasys3Fwd::SysIdhwBasys3Fwd(
			unsigned char Nretry
			, unsigned int dtPing
			, XchgIdhw** xchg
		) : SysIdhw(Nretry, dtPing, xchg) {

	rxbuf = NULL;
	txbuf = NULL;

	// IP constructor --- IBEGIN
	initdone = false;

#ifdef chardev
	bps = 0;

	fd = 0;
#endif

#ifdef libftdi
	vid = 0;
	pid = 0;
	bps = 0;

	ftdi = NULL;
#endif
	// IP constructor --- IEND
};

SysIdhwBasys3Fwd::~SysIdhwBasys3Fwd() {
	// IP destructor --- IBEGIN
	term();
	// IP destructor --- IEND
};

void* SysIdhwBasys3Fwd::runPrepprc(
			void* arg
		) {
	SysIdhwBasys3Fwd* inst = (SysIdhwBasys3Fwd*) arg;

	XchgIdhw* xchg = inst->xchg;

	Rst* rst = NULL;
	Bufxf* bufxf = NULL;

	Cmd* cmd = NULL;

	// thread settings
	pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, 0);
	pthread_cleanup_push(&cleanupPrepprc, arg);

	while (true) {
		Mutex::lock(&(xchg->mcPrepprc), "xchg->mcPrepprc", "SysIdhwBasys3Fwd", "runPrepprc");

		rst = inst->getFirstRst(Rst::VecVState::WAITPREP);
		if (!rst) bufxf = inst->getFirstBufxf(Bufxf::VecVState::WAITPREP);

		while (!rst && !bufxf) {
			Cond::wait(&(xchg->cPrepprc), &(xchg->mcPrepprc), "xchg->cPrepprc", "SysIdhwBasys3Fwd", "runPrepprc");

			rst = inst->getFirstRst(Rst::VecVState::WAITPREP);
			if (!rst) bufxf = inst->getFirstBufxf(Bufxf::VecVState::WAITPREP);
		};

		Mutex::unlock(&(xchg->mcPrepprc), "xchg->mcPrepprc", "SysIdhwBasys3Fwd", "runPrepprc");
			
		if (rst) {
			// --- prepare reset

			// at this stage, rst is locked
			rst->root = false;
			rst->cmd = NULL;

			// determine list of units the requests of which need to be reset
			rst->subIcsVTarget.insert(rst->ixVTarget);

			if (rst->ixVTarget == VecVTarget::AXS2_PHI) {
				rst->cmd = inst->getNewCmd(VecVTarget::BSS3, VecVIdhwBss3Controller::PHIIF, VecVIdhwBss3PhiifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::AXS2_THETA) {
				rst->cmd = inst->getNewCmd(VecVTarget::BSS3, VecVIdhwBss3Controller::THETAIF, VecVIdhwBss3ThetaifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::BSS3) {
				rst->root = true;

				insert(rst->subIcsVTarget, VecVTarget::AXS2_PHI);
				insert(rst->subIcsVTarget, VecVTarget::AXS2_THETA);
				insert(rst->subIcsVTarget, VecVTarget::DCX3);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_AXS2_PHI);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_AXS2_THETA);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_ICM2);
				insert(rst->subIcsVTarget, VecVTarget::DCX3_TAU2);
				insert(rst->subIcsVTarget, VecVTarget::ICM2);

			} else if (rst->ixVTarget == VecVTarget::DCX3) {
				rst->cmd = inst->getNewCmd(VecVTarget::BSS3, VecVIdhwBss3Controller::DCXIF, VecVIdhwBss3DcxifCommand::RESET);

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
				rst->cmd = inst->getNewCmd(VecVTarget::BSS3, VecVIdhwBss3Controller::QCDIF, VecVIdhwBss3QcdifCommand::RESET);

	};

			if (rst->cmd) {
				rst->cmd->setProgressCallback(rstCmdProgressCallback, (void*) rst);
				xchg->addCmd(rst->cmd);
			};

			if (rst->cmd) xchg->changeRstState(rst, Rst::VecVState::WAITINV);
			else xchg->changeRstState(rst, Rst::VecVState::WAITRST);
			if (rst->progressCallback) rst->progressCallback(rst, rst->argProgressCallback);

			rst->unlockAccess("SysIdhwBasys3Fwd", "runPrepprc");

		} else if (bufxf) {
			// --- prepare buffer transfer

			// at this stage, bufxf is locked
			bufxf->rootTixWBuffer = bufxf->tixWBuffer;

			if (bufxf->ixVTarget == VecVTarget::AXS2_PHI) {
			} else if (bufxf->ixVTarget == VecVTarget::AXS2_THETA) {
			} else if (bufxf->ixVTarget == VecVTarget::BSS3) {
			} else if (bufxf->ixVTarget == VecVTarget::DCX3) {
				if (bufxf->writeNotRead) {
					bufxf->rootTixWBuffer = VecWIdhwBss3Buffer::HOSTIFTODCXIF;

					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::BSS3, VecVIdhwBss3Controller::DCXIF, VecVIdhwBss3DcxifCommand::WRITE));

					cmd = CtrIdhwBss3Dcxif::getNewCmdWrite(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);

				} else {
					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::BSS3, VecVIdhwBss3Controller::DCXIF, VecVIdhwBss3DcxifCommand::READ));

					bufxf->rootTixWBuffer = VecWIdhwBss3Buffer::DCXIFTOHOSTIF;

					cmd = CtrIdhwBss3Dcxif::getNewCmdRead(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);
				};
			} else if (bufxf->ixVTarget == VecVTarget::DCX3_AXS2_PHI) {
			} else if (bufxf->ixVTarget == VecVTarget::DCX3_AXS2_THETA) {
			} else if (bufxf->ixVTarget == VecVTarget::DCX3_ICM2) {
				if (bufxf->writeNotRead) {
					bufxf->rootTixWBuffer = VecWIdhwBss3Buffer::HOSTIFTODCXIF;

					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::BSS3, VecVIdhwBss3Controller::DCXIF, VecVIdhwBss3DcxifCommand::WRITE));
					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::DCX3, VecVIdhwDcx3Controller::QCDIF, VecVIdhwDcx3QcdifCommand::WRITE));

					cmd = CtrIdhwBss3Dcxif::getNewCmdWrite(VecWIdhwDcx3Buffer::HOSTIFTOQCDIF, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);

					cmd = CtrIdhwDcx3Qcdif::getNewCmdWrite(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);

				} else {
					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::DCX3, VecVIdhwDcx3Controller::QCDIF, VecVIdhwDcx3QcdifCommand::READ));
					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::BSS3, VecVIdhwBss3Controller::DCXIF, VecVIdhwBss3DcxifCommand::READ));

					bufxf->rootTixWBuffer = VecWIdhwBss3Buffer::DCXIFTOHOSTIF;

					cmd = CtrIdhwDcx3Qcdif::getNewCmdRead(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);

					cmd = CtrIdhwBss3Dcxif::getNewCmdRead(VecWIdhwDcx3Buffer::QCDIFTOHOSTIF, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);
				};
			} else if (bufxf->ixVTarget == VecVTarget::DCX3_TAU2) {
			} else if (bufxf->ixVTarget == VecVTarget::ICM2) {
				if (bufxf->writeNotRead) {
					bufxf->rootTixWBuffer = VecWIdhwBss3Buffer::HOSTIFTOQCDIF;

					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::BSS3, VecVIdhwBss3Controller::QCDIF, VecVIdhwBss3QcdifCommand::WRITE));

					cmd = CtrIdhwBss3Qcdif::getNewCmdWrite(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);

				} else {
					bufxf->icsReqcmd.insert(cmdix_t(VecVTarget::BSS3, VecVIdhwBss3Controller::QCDIF, VecVIdhwBss3QcdifCommand::READ));

					bufxf->rootTixWBuffer = VecWIdhwBss3Buffer::QCDIFTOHOSTIF;

					cmd = CtrIdhwBss3Qcdif::getNewCmdRead(bufxf->tixWBuffer, bufxf->reqlen);
					cmd->setProgressCallback(bufxfCmdProgressCallback, (void*) bufxf);
					bufxf->cmds.push_back(cmd);
				};
	};

			if (bufxf->cmds.empty()) xchg->changeBufxfState(bufxf, Bufxf::VecVState::WAITXFER);
			else xchg->changeBufxfState(bufxf, Bufxf::VecVState::WAITINV);

			if (bufxf->progressCallback) bufxf->progressCallback(bufxf, bufxf->argProgressCallback);

			bufxf->unlockAccess("SysIdhwBasys3Fwd", "runPrepprc");
		};
	};
	pthread_cleanup_pop(0);

	return(NULL);
};

void SysIdhwBasys3Fwd::cleanupPrepprc(
			void* arg
		) {
	SysIdhwBasys3Fwd* inst = (SysIdhwBasys3Fwd*) arg;

	XchgIdhw* xchg = inst->xchg;

	Mutex::unlock(&(xchg->mcPrepprc), "xchg->mcPrepprc", "SysIdhwBasys3Fwd", "cleanupPrepprc");
};

void* SysIdhwBasys3Fwd::runReqprc(
			void* arg
		) {
	SysIdhwBasys3Fwd* inst = (SysIdhwBasys3Fwd*) arg;

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

	utinyint tknFromCmdret = VecWIdhwBss3Buffer::CMDRETTOHOSTIF;
	utinyint tknFromDcxif = VecWIdhwBss3Buffer::DCXIFTOHOSTIF;
	utinyint tknToCmdinv = VecWIdhwBss3Buffer::HOSTIFTOCMDINV;
	utinyint tknToDcxif = VecWIdhwBss3Buffer::HOSTIFTODCXIF;
	utinyint tknToQcdif = VecWIdhwBss3Buffer::HOSTIFTOQCDIF;
	utinyint tknFromPmmu = VecWIdhwBss3Buffer::PMMUTOHOSTIF;
	utinyint tknFromQcdif = VecWIdhwBss3Buffer::QCDIFTOHOSTIF;

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
			Mutex::lock(&(xchg->mcReqprc), "xchg->mcReqprc", "SysIdhwBasys3Fwd", "runReqprc");
			Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "runReqprc[1]");

			// - check for resets
			rst = inst->getFirstRst(Rst::VecVState::WAITRST);

			// - see if bufxf-related commands are ready to be invoked
			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITINV, 0));
			for (auto it=rngBufxfs.first;it!=rngBufxfs.second;it++) {
				bufxf = it->second;

				bufxf->lockAccess("SysIdhwBasys3Fwd", "runReqprc[1]");

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

				bufxf->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[1]");
			};

			// - determine reqbx
			// always be ready for receiving errors
			reqbx = VecWIdhwBss3Buffer::CMDRETTOHOSTIF;

			// check for command invoke / revoke
			rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITINV, 0));
			if (rngCmds.first != rngCmds.second) {
				reqbx |= VecWIdhwBss3Buffer::HOSTIFTOCMDINV;
			} else {
				rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITREV, 0));
				if (rngCmds.first != rngCmds.second) reqbx |= VecWIdhwBss3Buffer::HOSTIFTOCMDINV;
			};

			// other buffers
			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwBss3Buffer::DCXIFTOHOSTIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwBss3Buffer::DCXIFTOHOSTIF;

			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwBss3Buffer::HOSTIFTODCXIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwBss3Buffer::HOSTIFTODCXIF;

			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwBss3Buffer::HOSTIFTOQCDIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwBss3Buffer::HOSTIFTOQCDIF;

			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwBss3Buffer::PMMUTOHOSTIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwBss3Buffer::PMMUTOHOSTIF;

			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwBss3Buffer::QCDIFTOHOSTIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwBss3Buffer::QCDIFTOHOSTIF;

			Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "runReqprc[1]");

			news = (rst || (reqbx != VecWIdhwBss3Buffer::CMDRETTOHOSTIF) || (arbbx != 0x00));

			if (!news) Cond::timedwait(&(xchg->cReqprc), &(xchg->mcReqprc), inst->dtPing, "xchg->cReqprc", "SysIdhwBasys3Fwd", "runReqprc");

			Mutex::unlock(&(xchg->mcReqprc), "xchg->mcReqprc", "SysIdhwBasys3Fwd", "runReqprc");

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

					if ( ! (((_rxbuf[2] & VecWIdhwBss3Buffer::CMDRETTOHOSTIF) ^ tknFromCmdret) & VecWIdhwBss3Buffer::CMDRETTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwBss3Buffer::CMDRETTOHOSTIF) tknFromCmdret = ~VecWIdhwBss3Buffer::CMDRETTOHOSTIF; else tknFromCmdret = VecWIdhwBss3Buffer::CMDRETTOHOSTIF;

						if (!first) {
							// implies last rdack(success), host -> device was not received at device
							//cout << "tknFromCmdret corrected" << endl;
							if (arbbxRd_last == VecWIdhwBss3Buffer::CMDRETTOHOSTIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwBss3Buffer::HOSTIFTOCMDINV) ^ tknToCmdinv) & VecWIdhwBss3Buffer::HOSTIFTOCMDINV) ) {
						if (_rxbuf[2] & VecWIdhwBss3Buffer::HOSTIFTOCMDINV) tknToCmdinv = ~VecWIdhwBss3Buffer::HOSTIFTOCMDINV; else tknToCmdinv = VecWIdhwBss3Buffer::HOSTIFTOCMDINV;

						if (!first) {
							// implies last wrack(success), device -> host was not received at host
							//cout << "tknToCmdinv corrected" << endl;
							if (arbbxWr_last == VecWIdhwBss3Buffer::HOSTIFTOCMDINV) skipwr = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwBss3Buffer::DCXIFTOHOSTIF) ^ tknFromDcxif) & VecWIdhwBss3Buffer::DCXIFTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwBss3Buffer::DCXIFTOHOSTIF) tknFromDcxif = ~VecWIdhwBss3Buffer::DCXIFTOHOSTIF; else tknFromDcxif = VecWIdhwBss3Buffer::DCXIFTOHOSTIF;
						if (!first) {
							//cout << "tknFromDcxif corrected" << endl;
							if (arbbxRd_last == VecWIdhwBss3Buffer::DCXIFTOHOSTIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwBss3Buffer::HOSTIFTODCXIF) ^ tknToDcxif) & VecWIdhwBss3Buffer::HOSTIFTODCXIF) ) {
						if (_rxbuf[2] & VecWIdhwBss3Buffer::HOSTIFTODCXIF) tknToDcxif = ~VecWIdhwBss3Buffer::HOSTIFTODCXIF; else tknToDcxif = VecWIdhwBss3Buffer::HOSTIFTODCXIF;
						if (!first) {
							//cout << "tknToDcxif corrected" << endl;
							if (arbbxWr_last == VecWIdhwBss3Buffer::HOSTIFTODCXIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwBss3Buffer::HOSTIFTOQCDIF) ^ tknToQcdif) & VecWIdhwBss3Buffer::HOSTIFTOQCDIF) ) {
						if (_rxbuf[2] & VecWIdhwBss3Buffer::HOSTIFTOQCDIF) tknToQcdif = ~VecWIdhwBss3Buffer::HOSTIFTOQCDIF; else tknToQcdif = VecWIdhwBss3Buffer::HOSTIFTOQCDIF;
						if (!first) {
							//cout << "tknToQcdif corrected" << endl;
							if (arbbxWr_last == VecWIdhwBss3Buffer::HOSTIFTOQCDIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwBss3Buffer::PMMUTOHOSTIF) ^ tknFromPmmu) & VecWIdhwBss3Buffer::PMMUTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwBss3Buffer::PMMUTOHOSTIF) tknFromPmmu = ~VecWIdhwBss3Buffer::PMMUTOHOSTIF; else tknFromPmmu = VecWIdhwBss3Buffer::PMMUTOHOSTIF;
						if (!first) {
							//cout << "tknFromPmmu corrected" << endl;
							if (arbbxRd_last == VecWIdhwBss3Buffer::PMMUTOHOSTIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwBss3Buffer::QCDIFTOHOSTIF) ^ tknFromQcdif) & VecWIdhwBss3Buffer::QCDIFTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwBss3Buffer::QCDIFTOHOSTIF) tknFromQcdif = ~VecWIdhwBss3Buffer::QCDIFTOHOSTIF; else tknFromQcdif = VecWIdhwBss3Buffer::QCDIFTOHOSTIF;
						if (!first) {
							//cout << "tknFromQcdif corrected" << endl;
							if (arbbxRd_last == VecWIdhwBss3Buffer::QCDIFTOHOSTIF) skiprd = true;
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

					if ((arbbx == VecWIdhwBss3Buffer::CMDRETTOHOSTIF) || (arbbx == VecWIdhwBss3Buffer::DCXIFTOHOSTIF) || (arbbx == VecWIdhwBss3Buffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwBss3Buffer::QCDIFTOHOSTIF)) arbbxRd_last = arbbx;
					if ((arbbx == VecWIdhwBss3Buffer::HOSTIFTOCMDINV) || (arbbx == VecWIdhwBss3Buffer::HOSTIFTODCXIF) || (arbbx == VecWIdhwBss3Buffer::HOSTIFTOQCDIF)) arbbxWr_last = arbbx;
				};

				if (arbbx) {
					// -- read/write
					retry = true;

					reqlen = 0;

					// -- lock resource for read (bufxf) vs. write (cmd/bufxf) and determine reqlen
					if (arbbx == VecWIdhwBss3Buffer::CMDRETTOHOSTIF) {
						reqlen = 255;

					} else if (arbbx == VecWIdhwBss3Buffer::HOSTIFTOCMDINV) {
						Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "runReqprc[2]");

						cmd = NULL;

						// give revoke priority
						rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITREV, 0));
						if (rngCmds.first != rngCmds.second) {
							cmd = rngCmds.first->second;
						} else {
							rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITINV, 0));
							if (rngCmds.first != rngCmds.second) cmd = rngCmds.first->second;
						};

						Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "runReqprc[2]");

						if (cmd) {
							cmd->lockAccess("SysIdhwBasys3Fwd", "runReqprc[1]");

							ixVTarget = cmd->ixVTarget;

							reqlen = 10; // route(4) + action(1) + cref(4) + tixVCommand(1)
							if (cmd->ixVState == Cmd::VecVState::WAITINV) reqlen += cmd->getInvBuflen(); // invpars(var)

							if (cmd->cref != crefWr_last) skipwr = false;
							crefWr_last = cmd->cref;
						};

					} else if (arbbx != VecWIdhwBss3Buffer::CMDRETTOHOSTIF) {
						Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "runReqprc[3]");

						bufxf = NULL;

						auto rng = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, arbbx, 0));
						if (rng.first != rng.second) bufxf = rng.first->second;

						Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "runReqprc[3]");

						if (bufxf) {
							bufxf->lockAccess("SysIdhwBasys3Fwd", "runReqprc[2]");

							reqlen = bufxf->reqlen - bufxf->ptr;
							if (reqlen > 1024) reqlen = 1024;

							if ((arbbx == VecWIdhwBss3Buffer::DCXIFTOHOSTIF) || (arbbx == VecWIdhwBss3Buffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwBss3Buffer::QCDIFTOHOSTIF)) {
								if (bufxf->bref != brefWr_last) skipwr = false;
								brefWr_last = bufxf->bref;
							};
						};
					};

					if ((arbbx != VecWIdhwBss3Buffer::CMDRETTOHOSTIF) && !cmd && !bufxf) {
						// cmd / bufxf not found: re-do arbitration
						retry = false;
						throw DbeException("no suitable transfer for arbitration result found");

					} else {
						if (!(skipwr && ((arbbx == VecWIdhwBss3Buffer::HOSTIFTOCMDINV) || (arbbx == VecWIdhwBss3Buffer::HOSTIFTODCXIF) || (arbbx == VecWIdhwBss3Buffer::HOSTIFTOQCDIF)))) {
							// -- actual read/write transfer
							if (arbbx == VecWIdhwBss3Buffer::CMDRETTOHOSTIF) tkn = tknFromCmdret;
							else if (arbbx == VecWIdhwBss3Buffer::DCXIFTOHOSTIF) tkn = tknFromDcxif;
							else if (arbbx == VecWIdhwBss3Buffer::HOSTIFTOCMDINV) tkn = tknToCmdinv;
							else if (arbbx == VecWIdhwBss3Buffer::HOSTIFTODCXIF) tkn = tknToDcxif;
							else if (arbbx == VecWIdhwBss3Buffer::HOSTIFTOQCDIF) tkn = tknToQcdif;
							else if (arbbx == VecWIdhwBss3Buffer::PMMUTOHOSTIF) tkn = tknFromPmmu;
							else if (arbbx == VecWIdhwBss3Buffer::QCDIFTOHOSTIF) tkn = tknFromQcdif;

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
								if ((arbbx == VecWIdhwBss3Buffer::CMDRETTOHOSTIF) || (arbbx == VecWIdhwBss3Buffer::DCXIFTOHOSTIF) || (arbbx == VecWIdhwBss3Buffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwBss3Buffer::QCDIFTOHOSTIF)) {
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

								} else if ((arbbx == VecWIdhwBss3Buffer::HOSTIFTOCMDINV) || (arbbx == VecWIdhwBss3Buffer::HOSTIFTODCXIF) || (arbbx == VecWIdhwBss3Buffer::HOSTIFTOQCDIF)) {
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
								if (arbbx == VecWIdhwBss3Buffer::CMDRETTOHOSTIF) tknFromCmdret = invtkn;
								else if (arbbx == VecWIdhwBss3Buffer::DCXIFTOHOSTIF) tknFromDcxif = invtkn;
								else if (arbbx == VecWIdhwBss3Buffer::HOSTIFTOCMDINV) tknToCmdinv = invtkn;
								else if (arbbx == VecWIdhwBss3Buffer::HOSTIFTODCXIF) tknToDcxif = invtkn;
								else if (arbbx == VecWIdhwBss3Buffer::HOSTIFTOQCDIF) tknToQcdif = invtkn;
								else if (arbbx == VecWIdhwBss3Buffer::PMMUTOHOSTIF) tknFromPmmu = invtkn;
								else if (arbbx == VecWIdhwBss3Buffer::QCDIFTOHOSTIF) tknFromQcdif = invtkn;
							};
						};
					};
				};
			};

		} catch (DbeException e) {
			if (inst->dumpexc) cout << "DbeException: " << e.err << endl;

			if (rst) rst->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[1]");
			else if (cmd) cmd->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[1]");
			else if (bufxf) bufxf->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[2]");

			inst->runReqprc_recover();

			if (!retry) continue; // skip post-processing
		};

		if (!retry) {
			// --- post-processing
			Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "runReqprc[4]");

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

						rst2->lockAccess("SysIdhwBasys3Fwd", "runReqprc[1]");

						xchg->changeRstState(rst2, Rst::VecVState::DONE);

						elim = !rst2->progressCallback;
						if (rst2->progressCallback) if (rst2->progressCallback(rst2, rst2->argProgressCallback)) elim = true;

						rst2->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[2]");

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

						bufxf2->lockAccess("SysIdhwBasys3Fwd", "runReqprc[3]");

						bufxf2->success = false;
						xchg->changeBufxfState(bufxf2, Bufxf::VecVState::DONE);

						elim = (!bufxf2->progressCallback && !bufxf2->errorCallback && !bufxf2->doneCallback);
						if (bufxf2->progressCallback) if (bufxf2->progressCallback(bufxf2, bufxf2->argProgressCallback)) elim = true;
						if (bufxf2->errorCallback) if (bufxf2->errorCallback(bufxf2, bufxf2->argErrorCallback)) elim = true;
						if (bufxf2->doneCallback) if (bufxf2->doneCallback(bufxf2, bufxf2->argDoneCallback)) elim = true;

						bufxf2->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[3]");

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

						cmd2->lockAccess("SysIdhwBasys3Fwd", "runReqprc[2]");

						cmd2->err = Err::getNewRsterr();
						xchg->changeCmdState(cmd2, Cmd::VecVState::DONE);

						elim = (!cmd2->progressCallback && !cmd2->errorCallback && !cmd2->doneCallback);
						if (cmd2->progressCallback) if (cmd2->progressCallback(cmd2, cmd2->argProgressCallback)) elim = true;
						if (cmd2->errorCallback) if (cmd2->errorCallback(cmd2, cmd2->argErrorCallback)) elim = true;
						if (cmd2->doneCallback) if (cmd2->doneCallback(cmd2, cmd2->argDoneCallback)) elim = true;

						cmd2->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[2]");

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

				rst->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[3]");

				if (elim) {
					xchg->removeRst(rst);
					delete rst;
				};

			} else if (arbbx) {
				// -- update resource and unlock
				if (arbbx == VecWIdhwBss3Buffer::CMDRETTOHOSTIF) {
					cref = inst->runReqprc_getCref();

					if (!(skiprd && (cref == crefRd_last))) {
						auto it = xchg->cmds.find(cmdref_t(Cmd::VecVState::WAITRET, cref));
						if (it != xchg->cmds.end()) cmd = it->second;
						else {
							it = xchg->cmds.find(cmdref_t(Cmd::VecVState::WAITNEWRET, cref));
							if (it != xchg->cmds.end()) cmd = it->second;
						};

						if (cmd) {
							cmd->lockAccess("SysIdhwBasys3Fwd", "runReqprc[3]");

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

							cmd->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[3]");

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

					cmd->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[4]");

					if (elim) {
						xchg->removeCmd(cmd);
						delete cmd;
					};

				} else if (bufxf) {
					if (!(skiprd && (bufxf->bref == brefRd_last))) {
						if ((arbbx == VecWIdhwBss3Buffer::DCXIFTOHOSTIF) || (arbbx == VecWIdhwBss3Buffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwBss3Buffer::QCDIFTOHOSTIF)) {
							brefRd_last = bufxf->bref;

							bufxf->appendReadData(&(_rxbuf[2]), arblen);

						} else if ((arbbx == VecWIdhwBss3Buffer::HOSTIFTODCXIF) || (arbbx == VecWIdhwBss3Buffer::HOSTIFTOQCDIF)) {
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

						bufxf->unlockAccess("SysIdhwBasys3Fwd", "runReqprc[4]");

						if (elim) {
							xchg->removeBufxf(bufxf);
							delete bufxf;
						};
					};
				};
			};

			Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "runReqprc[4]");
		};
	};

	pthread_cleanup_pop(0);

	return(NULL);
};

void SysIdhwBasys3Fwd::cleanupReqprc(
			void* arg
		) {
	SysIdhwBasys3Fwd* inst = (SysIdhwBasys3Fwd*) arg;

	XchgIdhw* xchg = inst->xchg;

	Mutex::unlock(&(xchg->mcReqprc), "xchg->mcReqprc", "SysIdhwBasys3Fwd", "cleanupReqprc");

	inst->runReqprc_close();

	if (inst->rxbuf) delete[](inst->rxbuf);
	if (inst->txbuf) delete[](inst->txbuf);
};

void SysIdhwBasys3Fwd::runReqprc_open() {
	// IP runReqprc_open --- IBEGIN
#ifdef chardev
	// open character device
	fd = open(path.c_str(), O_RDWR | O_NOCTTY);
	if (fd == -1) {
		fd = 0;
		throw DbeException("error opening device " + path + "");
	};

#ifdef __linux__
	termios term;
	serial_struct ss;

	memset(&term, 0, sizeof(term));
	if (tcgetattr(fd, &term) != 0) throw DbeException("error getting terminal attributes");

	// 38400 8N1, no flow control, read blocking with 100ms timeout
	cfmakeraw(&term);

	cfsetispeed(&term, B38400);
	cfsetospeed(&term, B38400);

	term.c_iflag = 0;
	term.c_oflag = 0;

	term.c_cflag &= ~(CRTSCTS | CSIZE | CSTOPB);
	term.c_cflag |= (CLOCAL | CREAD | CS8);

	//term.c_lflag = 0;

	term.c_cc[VMIN] = 1;
	term.c_cc[VTIME] = 1;

	tcflush(fd, TCIOFLUSH);
	if (tcsetattr(fd, TCSANOW, &term) != 0) throw DbeException("error setting terminal attributes");

	if (ioctl(fd, TIOCGSERIAL, &ss) == -1) throw DbeException("error getting serial struct");

	//cout << "ss.baud_base=" << ss.baud_base << endl; // should be 60'000'000

	ss.flags &= ~ASYNC_SPD_MASK;
	ss.flags |= ASYNC_SPD_CUST;

	int div = ss.baud_base/bps; // down to 12 or up to 5MHz works
	ss.custom_divisor = div; // set to 10Mbps or 1MByte/s ; for 640*480*14/8=537.6kByte/s FLIR => more than 1 image per second

	if (ioctl(fd, TIOCSSERIAL, &ss) == -1) throw DbeException("error setting serial struct");
#endif
#endif

#ifdef libftdi
	int res;

	ftdi = ftdi_new();
	ftdi->usb_read_timeout = 100; // in ms
	ftdi->usb_write_timeout = 100;
	ftdi_set_latency_timer(ftdi, 1);

	res = ftdi_set_interface(ftdi, INTERFACE_B);
	if (res < 0) {
		cout << "error setting interface: " << string(ftdi_get_error_string(ftdi))  << endl;
	};

	res = ftdi_usb_open(ftdi, vid, pid);
	if (res < 0) {
		cout << "error opening device: " << string(ftdi_get_error_string(ftdi))  << endl;
	};

	ftdi_set_baudrate(ftdi, bps);
	if (res < 0) {
		cout << "error setting baud rate: " << string(ftdi_get_error_string(ftdi))  << endl;
	};

	ftdi_set_line_property(ftdi, BITS_8, STOP_BIT_1, NONE);
	if (res < 0) {
		cout << "error setting UART parameters: " << string(ftdi_get_error_string(ftdi))  << endl;
	};
#endif
	// IP runReqprc_open --- IEND
};

bool SysIdhwBasys3Fwd::runReqprc_rx(
			const size_t rxlen
		) {
	bool retval = (rxlen == 0);

	// IP runReqprc_rx --- IBEGIN
#ifdef chardev
	if (rxlen != 0) {
		fd_set fds;
		timeval timeout;
		int s;

		size_t nleft;
		int n;

		int en;

		FD_ZERO(&fds);
		FD_SET(fd, &fds);

		timeout.tv_sec = 0;
		timeout.tv_usec = 1000;

		if (dumprxtx) cout << "rx ";

		nleft = rxlen;
		en = 0;

		if (nleft > 0) {
			s = select(fd+1, &fds, NULL, NULL, &timeout);

			if (s > 0) {
				while (nleft > 0) {
					n = read(fd, &(rxbuf[rxlen-nleft]), nleft);

					if (n >= 0) nleft -= n;
					else {
						en = errno;
						break;
					};
				};

			} else if (s == 0) {
				en = ETIMEDOUT;
			} else {
				en = errno;
			};
		};

		retval = (nleft == 0);

		if (dumprxtx) {
			if (nleft == 0) cout << "0x" << Dbe::bufToHex(rxbuf, rxlen, true) << endl;
			else cout << string(strerror(en)) << endl;
		};
	};
#endif

#ifdef libftdi
	bool tod = false;

	if (rxlen != 0) {
		size_t nleft;
		int n;

		if (dumprxtx) cout << "rx ";

		nleft = rxlen;

		while (nleft > 0) {
			n = ftdi_read_data(ftdi, &(rxbuf[rxlen-nleft]), nleft);

			if (n >= 0) {
				nleft -= n; // often gets stuck on n == 0

			} else if (n == -7) { // LIBUSB_ERROR_TIMEOUT
				tod = true;
				break;
			
			} else break;
		};

		retval = (nleft == 0);

		if (dumprxtx) {
			if (nleft == 0) cout << "0x" << Dbe::bufToHex(rxbuf, rxlen, true) << endl;
			else if (tod) cout << "timeout" << endl;
			else cout << string(ftdi_get_error_string(ftdi)) << endl;
		};
	};
#endif
	// IP runReqprc_rx --- IEND

	return retval;
};

bool SysIdhwBasys3Fwd::runReqprc_tx(
			const size_t txlen
		) {
	bool retval = (txlen == 0);

	// IP runReqprc_tx --- IBEGIN
#ifdef chardev
	if (txlen != 0) {
//		tcflush(fd, TCOFLUSH);

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
#endif

#ifdef libftdi
	if (txlen != 0) {
		size_t nleft;
		int n;

		if (dumprxtx) cout << "tx ";

		nleft = txlen;
		n = 0;

		while (nleft > 0) {
			n = ftdi_write_data(ftdi, &(txbuf[txlen-nleft]), nleft);

			if (n >= 0) nleft -= n;
			else break;
		};

		retval = (nleft == 0);

		if (dumprxtx) {
			if (nleft == 0) cout << "0x" << Dbe::bufToHex(txbuf, txlen, true) << endl;
			else cout << string(ftdi_get_error_string(ftdi)) << endl;
		};
	};
#endif
	// IP runReqprc_tx --- IEND

	return retval;
};

void SysIdhwBasys3Fwd::runReqprc_recover() {
	// IP runReqprc_recover --- IBEGIN
	timespec to = timespec {
		.tv_sec = 0,
		.tv_nsec = 20000000 // hardware timeout is 10ms
	};

	nanosleep(&to, NULL);

#ifdef chardev
	tcflush(fd, TCIOFLUSH);
#endif

#ifdef libftdi
	ftdi_usb_purge_rx_buffer(ftdi);
	ftdi_usb_purge_tx_buffer(ftdi);
#endif
	// IP runReqprc_recover --- IEND
};

void SysIdhwBasys3Fwd::runReqprc_close() {
	// IP runReqprc_close --- IBEGIN
#ifdef chardev
	if (fd) {
		close(fd);
		fd = 0;
	};
#endif

#ifdef libftdi
	if (ftdi) {
		ftdi_usb_close(ftdi);

		ftdi_free(ftdi);
	};
#endif
	// IP runReqprc_close --- IEND
};

size_t SysIdhwBasys3Fwd::runReqprc_getAvllen() {
	// rxbuf bytes 2..5
	uint _len;

	const size_t ofs = 2;

	_len = (rxbuf[ofs] << 24) + (rxbuf[ofs+1] << 16) + (rxbuf[ofs+2] << 8) + rxbuf[ofs+3];

	return _len;
};

void SysIdhwBasys3Fwd::runReqprc_setReqlen(
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

size_t SysIdhwBasys3Fwd::runReqprc_getArblen() {
	// rxbuf bytes 2..5
	uint _len;

	const size_t ofs = 2;

	_len = (rxbuf[ofs] << 24) + (rxbuf[ofs+1] << 16) + (rxbuf[ofs+2] << 8) + rxbuf[ofs+3];

	return _len;
};

void SysIdhwBasys3Fwd::runReqprc_setRoute(
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
		txbuf[ofs] = VecVIdhwBss3Controller::PHIIF;
		txbuf[ofs+1] = tixVController;
	} else if (ixVTarget == VecVTarget::AXS2_THETA) {
		txbuf[ofs] = VecVIdhwBss3Controller::THETAIF;
		txbuf[ofs+1] = tixVController;
	} else if (ixVTarget == VecVTarget::BSS3) {
		txbuf[ofs] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3) {
		txbuf[ofs] = VecVIdhwBss3Controller::DCXIF;
		txbuf[ofs+1] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) {
		txbuf[ofs] = VecVIdhwBss3Controller::DCXIF;
		txbuf[ofs+1] = VecVIdhwDcx3Controller::PHIIF;
		txbuf[ofs+2] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) {
		txbuf[ofs] = VecVIdhwBss3Controller::DCXIF;
		txbuf[ofs+1] = VecVIdhwDcx3Controller::THETAIF;
		txbuf[ofs+2] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3_ICM2) {
		txbuf[ofs] = VecVIdhwBss3Controller::DCXIF;
		txbuf[ofs+1] = VecVIdhwDcx3Controller::QCDIF;
		txbuf[ofs+2] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3_TAU2) {
		txbuf[ofs] = VecVIdhwBss3Controller::DCXIF;
		txbuf[ofs+1] = VecVIdhwDcx3Controller::LWIRIF;
		txbuf[ofs+2] = tixVController;
	} else if (ixVTarget == VecVTarget::ICM2) {
		txbuf[ofs] = VecVIdhwBss3Controller::QCDIF;
		txbuf[ofs+1] = tixVController;
	};
};

uint SysIdhwBasys3Fwd::runReqprc_getCref() {
	// rxbuf bytes 7..10
	uint cref;

	const size_t ofs = 7;

	cref = (rxbuf[ofs] << 24) + (rxbuf[ofs+1] << 16) + (rxbuf[ofs+2] << 8) + rxbuf[ofs+3];

	return cref;
};

void SysIdhwBasys3Fwd::runReqprc_setCref(
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

unsigned short SysIdhwBasys3Fwd::runReqprc_calcCrc(
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

unsigned short SysIdhwBasys3Fwd::runReqprc_getCrc(
			const size_t ofs
		) {
	// rxbuf[ofs] bytes 0..1
	unsigned short crc;
	
	crc = (rxbuf[ofs] << 8) + rxbuf[ofs+1];

	return crc;
};

void SysIdhwBasys3Fwd::runReqprc_setCrc(
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

bool SysIdhwBasys3Fwd::rstCmdProgressCallback(
			Cmd* cmd
			, void* _arg
		) {
	RstCmdProgressCallback_arg* arg = (RstCmdProgressCallback_arg*) _arg;

	SysIdhwBasys3Fwd* inst = arg->inst;
	XchgIdhw* xchg = inst->xchg;

	Rst* rst = arg->rst;

	bool elim = false;

	// assume rst is in state WAITINV

	rst->lockAccess("SysIdhwBasys3Fwd", "rstCmdProgressCallback");

	if (cmd->ixVState == Cmd::VecVState::DONE) {
		//rst->success = (cmd->err.tixVError == 0x00);

		rst->cmd = NULL;
		elim = true;

		xchg->changeRstState(rst, Rst::VecVState::WAITRST);
		if (rst->progressCallback) rst->progressCallback(rst, rst->argProgressCallback);
	};

	rst->unlockAccess("SysIdhwBasys3Fwd", "rstCmdProgressCallback");

	return elim;
};

bool SysIdhwBasys3Fwd::bufxfCmdProgressCallback(
			Cmd* cmd
			, void* _arg
		) {
	BufxfCmdProgressCallback_arg* arg = (BufxfCmdProgressCallback_arg*) _arg;

	SysIdhwBasys3Fwd* inst = arg->inst;
	XchgIdhw* xchg = inst->xchg;

	Bufxf* bufxf = arg->bufxf;

	Cmd* cmd2 = NULL;

	bool waitrev;

	bool elim = false;

	bool step = false;

	bool bufxfelim;

	bufxf->lockAccess("SysIdhwBasys3Fwd", "bufxfCmdProgressCallback");

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

	bufxf->unlockAccess("SysIdhwBasys3Fwd", "bufxfCmdProgressCallback");

	if (bufxfelim) {
		xchg->removeBufxf(bufxf);
		delete bufxf;
	};

	return elim;
};

Rst* SysIdhwBasys3Fwd::getFirstRst(
			const uint ixVState
		) {
	Rst* rst = NULL;
	pair<multimap<rstref_t,Rst*>::iterator,multimap<rstref_t,Rst*>::iterator> rngRsts;

	Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "getFirstRst");

	rngRsts = xchg->rsts.equal_range(rstref_t(ixVState, 0));
	if (rngRsts.first != rngRsts.second) {
		rst = rngRsts.first->second;
		rst->lockAccess("SysIdhwBasys3Fwd", "getFirstRst");
	};

	Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "getFirstRst");

	return rst;
};

Bufxf* SysIdhwBasys3Fwd::getFirstBufxf(
			const uint ixVState
		) {
	Bufxf* bufxf = NULL;
	pair<multimap<bufxfref_t,Bufxf*>::iterator,multimap<bufxfref_t,Bufxf*>::iterator> rngBufxfs;

	Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "getFirstBufxf");

	rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(ixVState, 0));
	if (rngBufxfs.first != rngBufxfs.second) {
		bufxf = rngBufxfs.first->second;
		bufxf->lockAccess("SysIdhwBasys3Fwd", "getFirstBufxf");
	};

	Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwBasys3Fwd", "getFirstBufxf");

	return bufxf;
};

// IP cust --- IBEGIN
#ifdef chardev
void SysIdhwBasys3Fwd::init(
			const string& _path
			, const unsigned int _bps
		) {
	path = _path;
	bps = _bps;

	pthread_attr_t attr;

	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

	pthread_create(&prepprc, &attr, &SysIdhwBasys3Fwd::runPrepprc, (void*) this);
	pthread_create(&reqprc, &attr, &SysIdhwBasys3Fwd::runReqprc, (void*) this);

	initdone = true;
};
#endif

#ifdef libftdi
void SysIdhwBasys3Fwd::init(
			const unsigned short _vid
			, const unsigned short _pid
			, const unsigned int _bps
		) {
	vid = _vid;
	pid = _pid;

	bps = _bps;

	pthread_attr_t attr;

	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

	pthread_create(&prepprc, &attr, &SysIdhwBasys3Fwd::runPrepprc, (void*) this);
	pthread_create(&reqprc, &attr, &SysIdhwBasys3Fwd::runReqprc, (void*) this);

	initdone = true;
};
#endif

void SysIdhwBasys3Fwd::term() {
	if (initdone) {
		pthread_cancel(prepprc);
		pthread_join(prepprc, NULL);

		pthread_cancel(reqprc);
		pthread_join(reqprc, NULL);

		initdone = false;
	};
};
// IP cust --- IEND

UntIdhw* SysIdhwBasys3Fwd::connectToTarget(
			const uint ixVTarget
		) {
	UntIdhw* unt = NULL;

	if (ixVTarget == VecVTarget::AXS2_PHI) unt = new UntIdhwAxs2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::AXS2_THETA) unt = new UntIdhwAxs2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::BSS3) unt = new UntIdhwBss3(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3) unt = new UntIdhwDcx3(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) unt = new UntIdhwAxs2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) unt = new UntIdhwAxs2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) unt = new UntIdhwIcm2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3_TAU2) unt = new UntIdhwTau2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::ICM2) unt = new UntIdhwIcm2(xchg, ixVTarget);

	return unt;
};

uint SysIdhwBasys3Fwd::getIxVTargetBySref(
			const string& sref
		) {
	return VecVTarget::getIx(sref);
};

string SysIdhwBasys3Fwd::getSrefByIxVTarget(
			const uint ixVTarget
		) {
	return VecVTarget::getSref(ixVTarget);
};

void SysIdhwBasys3Fwd::fillFeedFTarget(
			Feed& feed
		) {
	VecVTarget::fillFeed(feed);
};

utinyint SysIdhwBasys3Fwd::getTixVControllerBySref(
			const uint ixVTarget
			, const string& sref
		) {
	utinyint tixVController = 0;

	if (ixVTarget == VecVTarget::BSS3) tixVController = UntIdhwBss3::getTixVControllerBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3) tixVController = UntIdhwDcx3::getTixVControllerBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) tixVController = UntIdhwIcm2::getTixVControllerBySref(sref);
	else if (ixVTarget == VecVTarget::ICM2) tixVController = UntIdhwIcm2::getTixVControllerBySref(sref);

	return tixVController;
};

string SysIdhwBasys3Fwd::getSrefByTixVController(
			const uint ixVTarget
			, const utinyint tixVController
		) {
	string sref;

	if (ixVTarget == VecVTarget::BSS3) sref = UntIdhwBss3::getSrefByTixVController(tixVController);
	else if (ixVTarget == VecVTarget::DCX3) sref = UntIdhwDcx3::getSrefByTixVController(tixVController);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) sref = UntIdhwIcm2::getSrefByTixVController(tixVController);
	else if (ixVTarget == VecVTarget::ICM2) sref = UntIdhwIcm2::getSrefByTixVController(tixVController);

	return sref;
};

void SysIdhwBasys3Fwd::fillFeedFController(
			const uint ixVTarget
			, Feed& feed
		) {
	feed.clear();

	if (ixVTarget == VecVTarget::BSS3) UntIdhwBss3::fillFeedFController(feed);
	else if (ixVTarget == VecVTarget::DCX3) UntIdhwDcx3::fillFeedFController(feed);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) UntIdhwIcm2::fillFeedFController(feed);
	else if (ixVTarget == VecVTarget::ICM2) UntIdhwIcm2::fillFeedFController(feed);
};

utinyint SysIdhwBasys3Fwd::getTixWBufferBySref(
			const uint ixVTarget
			, const string& sref
		) {
	utinyint tixWBuffer = 0;

	if (ixVTarget == VecVTarget::BSS3) tixWBuffer = UntIdhwBss3::getTixWBufferBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3) tixWBuffer = UntIdhwDcx3::getTixWBufferBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) tixWBuffer = UntIdhwIcm2::getTixWBufferBySref(sref);
	else if (ixVTarget == VecVTarget::ICM2) tixWBuffer = UntIdhwIcm2::getTixWBufferBySref(sref);

	return tixWBuffer;
};

string SysIdhwBasys3Fwd::getSrefByTixWBuffer(
			const uint ixVTarget
			, const utinyint tixWBuffer
		) {
	string sref;

	if (ixVTarget == VecVTarget::BSS3) sref = UntIdhwBss3::getSrefByTixWBuffer(tixWBuffer);
	else if (ixVTarget == VecVTarget::DCX3) sref = UntIdhwDcx3::getSrefByTixWBuffer(tixWBuffer);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) sref = UntIdhwIcm2::getSrefByTixWBuffer(tixWBuffer);
	else if (ixVTarget == VecVTarget::ICM2) sref = UntIdhwIcm2::getSrefByTixWBuffer(tixWBuffer);

	return sref;
};

void SysIdhwBasys3Fwd::fillFeedFBuffer(
			const uint ixVTarget
			, Feed& feed
		) {
	feed.clear();

	if (ixVTarget == VecVTarget::BSS3) UntIdhwBss3::fillFeedFBuffer(feed);
	else if (ixVTarget == VecVTarget::DCX3) UntIdhwDcx3::fillFeedFBuffer(feed);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) UntIdhwIcm2::fillFeedFBuffer(feed);
	else if (ixVTarget == VecVTarget::ICM2) UntIdhwIcm2::fillFeedFBuffer(feed);
};

utinyint SysIdhwBasys3Fwd::getTixVCommandBySref(
			const uint ixVTarget
			, const utinyint tixVController
			, const string& sref
		) {
	utinyint tixVCommand = 0;

	if (ixVTarget == VecVTarget::AXS2_PHI) tixVCommand = UntIdhwAxs2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::AXS2_THETA) tixVCommand = UntIdhwAxs2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::BSS3) tixVCommand = UntIdhwBss3::getTixVCommandBySref(tixVController, sref);
	else if (ixVTarget == VecVTarget::DCX3) tixVCommand = UntIdhwDcx3::getTixVCommandBySref(tixVController, sref);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) tixVCommand = UntIdhwAxs2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) tixVCommand = UntIdhwAxs2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) tixVCommand = UntIdhwIcm2::getTixVCommandBySref(tixVController, sref);
	else if (ixVTarget == VecVTarget::DCX3_TAU2) tixVCommand = UntIdhwTau2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::ICM2) tixVCommand = UntIdhwIcm2::getTixVCommandBySref(tixVController, sref);

	return tixVCommand;
};

string SysIdhwBasys3Fwd::getSrefByTixVCommand(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVCommand
		) {
	string sref;

	if (ixVTarget == VecVTarget::AXS2_PHI) sref = UntIdhwAxs2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::AXS2_THETA) sref = UntIdhwAxs2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::BSS3) sref = UntIdhwBss3::getSrefByTixVCommand(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3) sref = UntIdhwDcx3::getSrefByTixVCommand(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) sref = UntIdhwAxs2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) sref = UntIdhwAxs2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) sref = UntIdhwIcm2::getSrefByTixVCommand(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_TAU2) sref = UntIdhwTau2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::ICM2) sref = UntIdhwIcm2::getSrefByTixVCommand(tixVController, tixVCommand);

	return sref;
};

void SysIdhwBasys3Fwd::fillFeedFCommand(
			const uint ixVTarget
			, const utinyint tixVController
			, Feed& feed
		) {
	feed.clear();

	if (ixVTarget == VecVTarget::AXS2_PHI) UntIdhwAxs2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::AXS2_THETA) UntIdhwAxs2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::BSS3) UntIdhwBss3::fillFeedFCommand(tixVController, feed);
	else if (ixVTarget == VecVTarget::DCX3) UntIdhwDcx3::fillFeedFCommand(tixVController, feed);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) UntIdhwAxs2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) UntIdhwAxs2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) UntIdhwIcm2::fillFeedFCommand(tixVController, feed);
	else if (ixVTarget == VecVTarget::DCX3_TAU2) UntIdhwTau2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::ICM2) UntIdhwIcm2::fillFeedFCommand(tixVController, feed);
};

string SysIdhwBasys3Fwd::getSrefByTixVError(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	string sref;

	return sref;
};

string SysIdhwBasys3Fwd::getTitleByTixVError(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	string Title;

	return Title;
};

Bufxf* SysIdhwBasys3Fwd::getNewBufxf(
			const uint ixVTarget
			, const utinyint tixWBuffer
			, const size_t reqlen
		) {
	Bufxf* bufxf = NULL;

	if (ixVTarget == VecVTarget::BSS3) bufxf = UntIdhwBss3::getNewBufxf(tixWBuffer, reqlen);
	else if (ixVTarget == VecVTarget::DCX3) bufxf = UntIdhwDcx3::getNewBufxf(tixWBuffer, reqlen);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) bufxf = UntIdhwIcm2::getNewBufxf(tixWBuffer, reqlen);
	else if (ixVTarget == VecVTarget::ICM2) bufxf = UntIdhwIcm2::getNewBufxf(tixWBuffer, reqlen);

	if (bufxf) bufxf->ixVTarget = ixVTarget;

	return bufxf;
};

Cmd* SysIdhwBasys3Fwd::getNewCmd(
			const uint ixVTarget
			, const utinyint tixVController
			, const uint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (ixVTarget == VecVTarget::AXS2_PHI) cmd = UntIdhwAxs2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::AXS2_THETA) cmd = UntIdhwAxs2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::BSS3) cmd = UntIdhwBss3::getNewCmd(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3) cmd = UntIdhwDcx3::getNewCmd(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_PHI) cmd = UntIdhwAxs2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_AXS2_THETA) cmd = UntIdhwAxs2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_ICM2) cmd = UntIdhwIcm2::getNewCmd(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3_TAU2) cmd = UntIdhwTau2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::ICM2) cmd = UntIdhwIcm2::getNewCmd(tixVController, tixVCommand);

	if (cmd) cmd->ixVTarget = ixVTarget;

	return cmd;
};

Err SysIdhwBasys3Fwd::getNewErr(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	Err err;

	return err;
};



