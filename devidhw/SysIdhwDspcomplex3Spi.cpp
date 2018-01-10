/**
  * \file SysIdhwDspcomplex3Spi.cpp
  * production-level dspcomplex3 board connected via SPI system (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "SysIdhwDspcomplex3Spi.h"

#include "SysIdhwDspcomplex3Spi_vecs.cpp"

/******************************************************************************
 class SysIdhwDspcomplex3Spi
 ******************************************************************************/

SysIdhwDspcomplex3Spi::SysIdhwDspcomplex3Spi(
			unsigned char Nretry
			, unsigned int dtPing
			, XchgIdhw** xchg
		) : SysIdhw(Nretry, dtPing, xchg) {

	rxbuf = NULL;
	txbuf = NULL;

	// IP constructor --- IBEGIN
/*
#ifdef __arm__
	res = ioctl(inst->fd, SPI_IOC_WR_MODE, &mode);
	res = ioctl(inst->fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
	res = ioctl(inst->fd, SPI_IOC_WR_MAX_SPEED_HZ, &(inst->bps));

	inst->xfer.speed_hz = inst->bps;
	inst->xfer.delay_usecs = 0;
	inst->xfer.bits_per_word = bits;
	inst->xfer.cs_change = 0;
	inst->xfer.tx_nbits = bits;
	inst->xfer.rx_nbits = bits;
	inst->xfer.pad = 0;
#endif

#ifdef __arm__
	xfer.rx_buf = ((unsigned long) &(rxbuf[ofs]));
	xfer.tx_buf = ((unsigned long) &(txbuf[ofs]));
	xfer.len = len;

	int res = ioctl(fd, SPI_IOC_MESSAGE(1), &xfer);
	retval = (res != -1);
#endif
*/
	// IP constructor --- IEND
};

SysIdhwDspcomplex3Spi::~SysIdhwDspcomplex3Spi() {
	// IP destructor --- INSERT
};

void* SysIdhwDspcomplex3Spi::runPrepprc(
			void* arg
		) {
	SysIdhwDspcomplex3Spi* inst = (SysIdhwDspcomplex3Spi*) arg;

	XchgIdhw* xchg = inst->xchg;

	Rst* rst = NULL;
	Bufxf* bufxf = NULL;

	Cmd* cmd = NULL;

	// thread settings
	pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, 0);
	pthread_cleanup_push(&cleanupPrepprc, arg);

	while (true) {
		Mutex::lock(&(xchg->mcPrepprc), "xchg->mcPrepprc", "SysIdhwDspcomplex3Spi", "runPrepprc");

		rst = inst->getFirstRst(Rst::VecVState::WAITPREP);
		if (!rst) bufxf = inst->getFirstBufxf(Bufxf::VecVState::WAITPREP);

		while (!rst && !bufxf) {
			Cond::wait(&(xchg->cPrepprc), &(xchg->mcPrepprc), "xchg->cPrepprc", "SysIdhwDspcomplex3Spi", "runPrepprc");

			rst = inst->getFirstRst(Rst::VecVState::WAITPREP);
			if (!rst) bufxf = inst->getFirstBufxf(Bufxf::VecVState::WAITPREP);
		};

		Mutex::unlock(&(xchg->mcPrepprc), "xchg->mcPrepprc", "SysIdhwDspcomplex3Spi", "runPrepprc");
			
		if (rst) {
			// --- prepare reset

			// at this stage, rst is locked
			rst->root = false;
			rst->cmd = NULL;

			// determine list of units the requests of which need to be reset
			rst->subIcsVTarget.insert(rst->ixVTarget);

			if (rst->ixVTarget == VecVTarget::AXS2_PHI) {
				rst->cmd = inst->getNewCmd(VecVTarget::DCX3, VecVIdhwDcx3Controller::PHIIF, VecVIdhwDcx3PhiifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::AXS2_THETA) {
				rst->cmd = inst->getNewCmd(VecVTarget::DCX3, VecVIdhwDcx3Controller::THETAIF, VecVIdhwDcx3ThetaifCommand::RESET);

			} else if (rst->ixVTarget == VecVTarget::DCX3) {
				rst->root = true;

				insert(rst->subIcsVTarget, VecVTarget::AXS2_PHI);
				insert(rst->subIcsVTarget, VecVTarget::AXS2_THETA);
				insert(rst->subIcsVTarget, VecVTarget::ICM2);
				insert(rst->subIcsVTarget, VecVTarget::TAU2);

			} else if (rst->ixVTarget == VecVTarget::ICM2) {
				rst->root = true;

			} else if (rst->ixVTarget == VecVTarget::TAU2) {
				rst->cmd = inst->getNewCmd(VecVTarget::DCX3, VecVIdhwDcx3Controller::LWIRIF, VecVIdhwDcx3LwirifCommand::RESET);

	};

			if (rst->cmd) {
				rst->cmd->setProgressCallback(rstCmdProgressCallback, (void*) rst);
				xchg->addCmd(rst->cmd);
			};

			if (rst->cmd) xchg->changeRstState(rst, Rst::VecVState::WAITINV);
			else xchg->changeRstState(rst, Rst::VecVState::WAITRST);
			if (rst->progressCallback) rst->progressCallback(rst, rst->argProgressCallback);

			rst->unlockAccess("SysIdhwDspcomplex3Spi", "runPrepprc");

		} else if (bufxf) {
			// --- prepare buffer transfer

			// at this stage, bufxf is locked
			bufxf->rootTixWBuffer = bufxf->tixWBuffer;

			if (bufxf->ixVTarget == VecVTarget::AXS2_PHI) {
			} else if (bufxf->ixVTarget == VecVTarget::AXS2_THETA) {
			} else if (bufxf->ixVTarget == VecVTarget::DCX3) {
			} else if (bufxf->ixVTarget == VecVTarget::ICM2) {
			} else if (bufxf->ixVTarget == VecVTarget::TAU2) {
	};

			if (bufxf->cmds.empty()) xchg->changeBufxfState(bufxf, Bufxf::VecVState::WAITXFER);
			else xchg->changeBufxfState(bufxf, Bufxf::VecVState::WAITINV);

			if (bufxf->progressCallback) bufxf->progressCallback(bufxf, bufxf->argProgressCallback);

			bufxf->unlockAccess("SysIdhwDspcomplex3Spi", "runPrepprc");
		};
	};
	pthread_cleanup_pop(0);

	return(NULL);
};

void SysIdhwDspcomplex3Spi::cleanupPrepprc(
			void* arg
		) {
	SysIdhwDspcomplex3Spi* inst = (SysIdhwDspcomplex3Spi*) arg;

	XchgIdhw* xchg = inst->xchg;

	Mutex::unlock(&(xchg->mcPrepprc), "xchg->mcPrepprc", "SysIdhwDspcomplex3Spi", "cleanupPrepprc");
};

void* SysIdhwDspcomplex3Spi::runReqprc(
			void* arg
		) {
	SysIdhwDspcomplex3Spi* inst = (SysIdhwDspcomplex3Spi*) arg;

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

	utinyint tknFromCmdret = VecWIdhwDcx3Buffer::CMDRETTOHOSTIF;
	utinyint tknToCmdinv = VecWIdhwDcx3Buffer::HOSTIFTOCMDINV;
	utinyint tknToQcdif = VecWIdhwDcx3Buffer::HOSTIFTOQCDIF;
	utinyint tknFromPmmu = VecWIdhwDcx3Buffer::PMMUTOHOSTIF;
	utinyint tknFromQcdif = VecWIdhwDcx3Buffer::QCDIFTOHOSTIF;

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
			Mutex::lock(&(xchg->mcReqprc), "xchg->mcReqprc", "SysIdhwDspcomplex3Spi", "runReqprc");
			Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "runReqprc[1]");

			// - check for resets
			rst = inst->getFirstRst(Rst::VecVState::WAITRST);

			// - see if bufxf-related commands are ready to be invoked
			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITINV, 0));
			for (auto it=rngBufxfs.first;it!=rngBufxfs.second;it++) {
				bufxf = it->second;

				bufxf->lockAccess("SysIdhwDspcomplex3Spi", "runReqprc[1]");

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

				bufxf->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[1]");
			};

			// - determine reqbx
			// always be ready for receiving errors
			reqbx = VecWIdhwDcx3Buffer::CMDRETTOHOSTIF;

			// check for command invoke / revoke
			rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITINV, 0));
			if (rngCmds.first != rngCmds.second) {
				reqbx |= VecWIdhwDcx3Buffer::HOSTIFTOCMDINV;
			} else {
				rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITREV, 0));
				if (rngCmds.first != rngCmds.second) reqbx |= VecWIdhwDcx3Buffer::HOSTIFTOCMDINV;
			};

			// other buffers
			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwDcx3Buffer::HOSTIFTOQCDIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwDcx3Buffer::HOSTIFTOQCDIF;

			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwDcx3Buffer::PMMUTOHOSTIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwDcx3Buffer::PMMUTOHOSTIF;

			rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, VecWIdhwDcx3Buffer::QCDIFTOHOSTIF, 0));
			if (rngBufxfs.first != rngBufxfs.second) reqbx |= VecWIdhwDcx3Buffer::QCDIFTOHOSTIF;

			Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "runReqprc[1]");

			news = (rst || (reqbx != VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) || (arbbx != 0x00));

			if (!news) Cond::timedwait(&(xchg->cReqprc), &(xchg->mcReqprc), inst->dtPing, "xchg->cReqprc", "SysIdhwDspcomplex3Spi", "runReqprc");

			Mutex::unlock(&(xchg->mcReqprc), "xchg->mcReqprc", "SysIdhwDspcomplex3Spi", "runReqprc");

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

					if ( ! (((_rxbuf[2] & VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) ^ tknFromCmdret) & VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) tknFromCmdret = ~VecWIdhwDcx3Buffer::CMDRETTOHOSTIF; else tknFromCmdret = VecWIdhwDcx3Buffer::CMDRETTOHOSTIF;

						if (!first) {
							// implies last rdack(success), host -> device was not received at device
							//cout << "tknFromCmdret corrected" << endl;
							if (arbbxRd_last == VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwDcx3Buffer::HOSTIFTOCMDINV) ^ tknToCmdinv) & VecWIdhwDcx3Buffer::HOSTIFTOCMDINV) ) {
						if (_rxbuf[2] & VecWIdhwDcx3Buffer::HOSTIFTOCMDINV) tknToCmdinv = ~VecWIdhwDcx3Buffer::HOSTIFTOCMDINV; else tknToCmdinv = VecWIdhwDcx3Buffer::HOSTIFTOCMDINV;

						if (!first) {
							// implies last wrack(success), device -> host was not received at host
							//cout << "tknToCmdinv corrected" << endl;
							if (arbbxWr_last == VecWIdhwDcx3Buffer::HOSTIFTOCMDINV) skipwr = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwDcx3Buffer::HOSTIFTOQCDIF) ^ tknToQcdif) & VecWIdhwDcx3Buffer::HOSTIFTOQCDIF) ) {
						if (_rxbuf[2] & VecWIdhwDcx3Buffer::HOSTIFTOQCDIF) tknToQcdif = ~VecWIdhwDcx3Buffer::HOSTIFTOQCDIF; else tknToQcdif = VecWIdhwDcx3Buffer::HOSTIFTOQCDIF;
						if (!first) {
							//cout << "tknToQcdif corrected" << endl;
							if (arbbxWr_last == VecWIdhwDcx3Buffer::HOSTIFTOQCDIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwDcx3Buffer::PMMUTOHOSTIF) ^ tknFromPmmu) & VecWIdhwDcx3Buffer::PMMUTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwDcx3Buffer::PMMUTOHOSTIF) tknFromPmmu = ~VecWIdhwDcx3Buffer::PMMUTOHOSTIF; else tknFromPmmu = VecWIdhwDcx3Buffer::PMMUTOHOSTIF;
						if (!first) {
							//cout << "tknFromPmmu corrected" << endl;
							if (arbbxRd_last == VecWIdhwDcx3Buffer::PMMUTOHOSTIF) skiprd = true;
						};
					};
					if ( ! (((_rxbuf[2] & VecWIdhwDcx3Buffer::QCDIFTOHOSTIF) ^ tknFromQcdif) & VecWIdhwDcx3Buffer::QCDIFTOHOSTIF) ) {
						if (_rxbuf[2] & VecWIdhwDcx3Buffer::QCDIFTOHOSTIF) tknFromQcdif = ~VecWIdhwDcx3Buffer::QCDIFTOHOSTIF; else tknFromQcdif = VecWIdhwDcx3Buffer::QCDIFTOHOSTIF;
						if (!first) {
							//cout << "tknFromQcdif corrected" << endl;
							if (arbbxRd_last == VecWIdhwDcx3Buffer::QCDIFTOHOSTIF) skiprd = true;
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

					if ((arbbx == VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) || (arbbx == VecWIdhwDcx3Buffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwDcx3Buffer::QCDIFTOHOSTIF)) arbbxRd_last = arbbx;
					if ((arbbx == VecWIdhwDcx3Buffer::HOSTIFTOCMDINV) || (arbbx == VecWIdhwDcx3Buffer::HOSTIFTOQCDIF)) arbbxWr_last = arbbx;
				};

				if (arbbx) {
					// -- read/write
					retry = true;

					reqlen = 0;

					// -- lock resource for read (bufxf) vs. write (cmd/bufxf) and determine reqlen
					if (arbbx == VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) {
						reqlen = 255;

					} else if (arbbx == VecWIdhwDcx3Buffer::HOSTIFTOCMDINV) {
						Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "runReqprc[2]");

						cmd = NULL;

						// give revoke priority
						rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITREV, 0));
						if (rngCmds.first != rngCmds.second) {
							cmd = rngCmds.first->second;
						} else {
							rngCmds = xchg->cmds.equal_range(cmdref_t(Cmd::VecVState::WAITINV, 0));
							if (rngCmds.first != rngCmds.second) cmd = rngCmds.first->second;
						};

						Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "runReqprc[2]");

						if (cmd) {
							cmd->lockAccess("SysIdhwDspcomplex3Spi", "runReqprc[1]");

							ixVTarget = cmd->ixVTarget;

							reqlen = 10; // route(4) + action(1) + cref(4) + tixVCommand(1)
							if (cmd->ixVState == Cmd::VecVState::WAITINV) reqlen += cmd->getInvBuflen(); // invpars(var)

							if (cmd->cref != crefWr_last) skipwr = false;
							crefWr_last = cmd->cref;
						};

					} else if (arbbx != VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) {
						Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "runReqprc[3]");

						bufxf = NULL;

						auto rng = xchg->bufxfs.equal_range(bufxfref_t(Bufxf::VecVState::WAITXFER, arbbx, 0));
						if (rng.first != rng.second) bufxf = rng.first->second;

						Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "runReqprc[3]");

						if (bufxf) {
							bufxf->lockAccess("SysIdhwDspcomplex3Spi", "runReqprc[2]");

							reqlen = bufxf->reqlen - bufxf->ptr;
							if (reqlen > 1024) reqlen = 1024;

							if ((arbbx == VecWIdhwDcx3Buffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwDcx3Buffer::QCDIFTOHOSTIF)) {
								if (bufxf->bref != brefWr_last) skipwr = false;
								brefWr_last = bufxf->bref;
							};
						};
					};

					if ((arbbx != VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) && !cmd && !bufxf) {
						// cmd / bufxf not found: re-do arbitration
						retry = false;
						throw DbeException("no suitable transfer for arbitration result found");

					} else {
						if (!(skipwr && ((arbbx == VecWIdhwDcx3Buffer::HOSTIFTOCMDINV) || (arbbx == VecWIdhwDcx3Buffer::HOSTIFTOQCDIF)))) {
							// -- actual read/write transfer
							if (arbbx == VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) tkn = tknFromCmdret;
							else if (arbbx == VecWIdhwDcx3Buffer::HOSTIFTOCMDINV) tkn = tknToCmdinv;
							else if (arbbx == VecWIdhwDcx3Buffer::HOSTIFTOQCDIF) tkn = tknToQcdif;
							else if (arbbx == VecWIdhwDcx3Buffer::PMMUTOHOSTIF) tkn = tknFromPmmu;
							else if (arbbx == VecWIdhwDcx3Buffer::QCDIFTOHOSTIF) tkn = tknFromQcdif;

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
								if ((arbbx == VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) || (arbbx == VecWIdhwDcx3Buffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwDcx3Buffer::QCDIFTOHOSTIF)) {
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

								} else if ((arbbx == VecWIdhwDcx3Buffer::HOSTIFTOCMDINV) || (arbbx == VecWIdhwDcx3Buffer::HOSTIFTOQCDIF)) {
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
								if (arbbx == VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) tknFromCmdret = invtkn;
								else if (arbbx == VecWIdhwDcx3Buffer::HOSTIFTOCMDINV) tknToCmdinv = invtkn;
								else if (arbbx == VecWIdhwDcx3Buffer::HOSTIFTOQCDIF) tknToQcdif = invtkn;
								else if (arbbx == VecWIdhwDcx3Buffer::PMMUTOHOSTIF) tknFromPmmu = invtkn;
								else if (arbbx == VecWIdhwDcx3Buffer::QCDIFTOHOSTIF) tknFromQcdif = invtkn;
							};
						};
					};
				};
			};

		} catch (DbeException e) {
			if (inst->dumpexc) cout << "DbeException: " << e.err << endl;

			if (rst) rst->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[1]");
			else if (cmd) cmd->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[1]");
			else if (bufxf) bufxf->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[2]");

			inst->runReqprc_recover();

			if (!retry) continue; // skip post-processing
		};

		if (!retry) {
			// --- post-processing
			Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "runReqprc[4]");

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

						rst2->lockAccess("SysIdhwDspcomplex3Spi", "runReqprc[1]");

						xchg->changeRstState(rst2, Rst::VecVState::DONE);

						elim = !rst2->progressCallback;
						if (rst2->progressCallback) if (rst2->progressCallback(rst2, rst2->argProgressCallback)) elim = true;

						rst2->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[2]");

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

						bufxf2->lockAccess("SysIdhwDspcomplex3Spi", "runReqprc[3]");

						bufxf2->success = false;
						xchg->changeBufxfState(bufxf2, Bufxf::VecVState::DONE);

						elim = (!bufxf2->progressCallback && !bufxf2->errorCallback && !bufxf2->doneCallback);
						if (bufxf2->progressCallback) if (bufxf2->progressCallback(bufxf2, bufxf2->argProgressCallback)) elim = true;
						if (bufxf2->errorCallback) if (bufxf2->errorCallback(bufxf2, bufxf2->argErrorCallback)) elim = true;
						if (bufxf2->doneCallback) if (bufxf2->doneCallback(bufxf2, bufxf2->argDoneCallback)) elim = true;

						bufxf2->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[3]");

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

						cmd2->lockAccess("SysIdhwDspcomplex3Spi", "runReqprc[2]");

						cmd2->err = Err::getNewRsterr();
						xchg->changeCmdState(cmd2, Cmd::VecVState::DONE);

						elim = (!cmd2->progressCallback && !cmd2->errorCallback && !cmd2->doneCallback);
						if (cmd2->progressCallback) if (cmd2->progressCallback(cmd2, cmd2->argProgressCallback)) elim = true;
						if (cmd2->errorCallback) if (cmd2->errorCallback(cmd2, cmd2->argErrorCallback)) elim = true;
						if (cmd2->doneCallback) if (cmd2->doneCallback(cmd2, cmd2->argDoneCallback)) elim = true;

						cmd2->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[2]");

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

				rst->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[3]");

				if (elim) {
					xchg->removeRst(rst);
					delete rst;
				};

			} else if (arbbx) {
				// -- update resource and unlock
				if (arbbx == VecWIdhwDcx3Buffer::CMDRETTOHOSTIF) {
					cref = inst->runReqprc_getCref();

					if (!(skiprd && (cref == crefRd_last))) {
						auto it = xchg->cmds.find(cmdref_t(Cmd::VecVState::WAITRET, cref));
						if (it != xchg->cmds.end()) cmd = it->second;
						else {
							it = xchg->cmds.find(cmdref_t(Cmd::VecVState::WAITNEWRET, cref));
							if (it != xchg->cmds.end()) cmd = it->second;
						};

						if (cmd) {
							cmd->lockAccess("SysIdhwDspcomplex3Spi", "runReqprc[3]");

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

							cmd->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[3]");

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

					cmd->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[4]");

					if (elim) {
						xchg->removeCmd(cmd);
						delete cmd;
					};

				} else if (bufxf) {
					if (!(skiprd && (bufxf->bref == brefRd_last))) {
						if ((arbbx == VecWIdhwDcx3Buffer::PMMUTOHOSTIF) || (arbbx == VecWIdhwDcx3Buffer::QCDIFTOHOSTIF)) {
							brefRd_last = bufxf->bref;

							bufxf->appendReadData(&(_rxbuf[2]), arblen);

						} else if ((arbbx == VecWIdhwDcx3Buffer::HOSTIFTOQCDIF)) {
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

						bufxf->unlockAccess("SysIdhwDspcomplex3Spi", "runReqprc[4]");

						if (elim) {
							xchg->removeBufxf(bufxf);
							delete bufxf;
						};
					};
				};
			};

			Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "runReqprc[4]");
		};
	};

	pthread_cleanup_pop(0);

	return(NULL);
};

void SysIdhwDspcomplex3Spi::cleanupReqprc(
			void* arg
		) {
	SysIdhwDspcomplex3Spi* inst = (SysIdhwDspcomplex3Spi*) arg;

	XchgIdhw* xchg = inst->xchg;

	Mutex::unlock(&(xchg->mcReqprc), "xchg->mcReqprc", "SysIdhwDspcomplex3Spi", "cleanupReqprc");

	inst->runReqprc_close();

	if (inst->rxbuf) delete[](inst->rxbuf);
	if (inst->txbuf) delete[](inst->txbuf);
};

void SysIdhwDspcomplex3Spi::runReqprc_open() {
	// IP runReqprc_open --- INSERT
};

bool SysIdhwDspcomplex3Spi::runReqprc_rx(
			const size_t rxlen
		) {
	bool retval = (rxlen == 0);

	// IP runReqprc_rx --- INSERT

	return retval;
};

bool SysIdhwDspcomplex3Spi::runReqprc_tx(
			const size_t txlen
		) {
	bool retval = (txlen == 0);

	// IP runReqprc_tx --- INSERT

	return retval;
};

void SysIdhwDspcomplex3Spi::runReqprc_recover() {
	// IP runReqprc_recover --- INSERT
};

void SysIdhwDspcomplex3Spi::runReqprc_close() {
	// IP runReqprc_close --- INSERT
};

size_t SysIdhwDspcomplex3Spi::runReqprc_getAvllen() {
	// rxbuf bytes 2..5
	uint _len;

	const size_t ofs = 2;

	_len = (rxbuf[ofs] << 24) + (rxbuf[ofs+1] << 16) + (rxbuf[ofs+2] << 8) + rxbuf[ofs+3];

	return _len;
};

void SysIdhwDspcomplex3Spi::runReqprc_setReqlen(
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

size_t SysIdhwDspcomplex3Spi::runReqprc_getArblen() {
	// rxbuf bytes 2..5
	uint _len;

	const size_t ofs = 2;

	_len = (rxbuf[ofs] << 24) + (rxbuf[ofs+1] << 16) + (rxbuf[ofs+2] << 8) + rxbuf[ofs+3];

	return _len;
};

void SysIdhwDspcomplex3Spi::runReqprc_setRoute(
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
		txbuf[ofs] = VecVIdhwDcx3Controller::PHIIF;
		txbuf[ofs+1] = tixVController;
	} else if (ixVTarget == VecVTarget::AXS2_THETA) {
		txbuf[ofs] = VecVIdhwDcx3Controller::THETAIF;
		txbuf[ofs+1] = tixVController;
	} else if (ixVTarget == VecVTarget::DCX3) {
		txbuf[ofs] = tixVController;
	} else if (ixVTarget == VecVTarget::ICM2) {
		txbuf[ofs] = tixVController;
	} else if (ixVTarget == VecVTarget::TAU2) {
		txbuf[ofs] = VecVIdhwDcx3Controller::LWIRIF;
		txbuf[ofs+1] = tixVController;
	};
};

uint SysIdhwDspcomplex3Spi::runReqprc_getCref() {
	// rxbuf bytes 7..10
	uint cref;

	const size_t ofs = 7;

	cref = (rxbuf[ofs] << 24) + (rxbuf[ofs+1] << 16) + (rxbuf[ofs+2] << 8) + rxbuf[ofs+3];

	return cref;
};

void SysIdhwDspcomplex3Spi::runReqprc_setCref(
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

unsigned short SysIdhwDspcomplex3Spi::runReqprc_calcCrc(
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

unsigned short SysIdhwDspcomplex3Spi::runReqprc_getCrc(
			const size_t ofs
		) {
	// rxbuf[ofs] bytes 0..1
	unsigned short crc;
	
	crc = (rxbuf[ofs] << 8) + rxbuf[ofs+1];

	return crc;
};

void SysIdhwDspcomplex3Spi::runReqprc_setCrc(
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

bool SysIdhwDspcomplex3Spi::rstCmdProgressCallback(
			Cmd* cmd
			, void* _arg
		) {
	RstCmdProgressCallback_arg* arg = (RstCmdProgressCallback_arg*) _arg;

	SysIdhwDspcomplex3Spi* inst = arg->inst;
	XchgIdhw* xchg = inst->xchg;

	Rst* rst = arg->rst;

	bool elim = false;

	// assume rst is in state WAITINV

	rst->lockAccess("SysIdhwDspcomplex3Spi", "rstCmdProgressCallback");

	if (cmd->ixVState == Cmd::VecVState::DONE) {
		//rst->success = (cmd->err.tixVError == 0x00);

		rst->cmd = NULL;
		elim = true;

		xchg->changeRstState(rst, Rst::VecVState::WAITRST);
		if (rst->progressCallback) rst->progressCallback(rst, rst->argProgressCallback);
	};

	rst->unlockAccess("SysIdhwDspcomplex3Spi", "rstCmdProgressCallback");

	return elim;
};

bool SysIdhwDspcomplex3Spi::bufxfCmdProgressCallback(
			Cmd* cmd
			, void* _arg
		) {
	BufxfCmdProgressCallback_arg* arg = (BufxfCmdProgressCallback_arg*) _arg;

	SysIdhwDspcomplex3Spi* inst = arg->inst;
	XchgIdhw* xchg = inst->xchg;

	Bufxf* bufxf = arg->bufxf;

	Cmd* cmd2 = NULL;

	bool waitrev;

	bool elim = false;

	bool step = false;

	bool bufxfelim;

	bufxf->lockAccess("SysIdhwDspcomplex3Spi", "bufxfCmdProgressCallback");

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

	bufxf->unlockAccess("SysIdhwDspcomplex3Spi", "bufxfCmdProgressCallback");

	if (bufxfelim) {
		xchg->removeBufxf(bufxf);
		delete bufxf;
	};

	return elim;
};

Rst* SysIdhwDspcomplex3Spi::getFirstRst(
			const uint ixVState
		) {
	Rst* rst = NULL;
	pair<multimap<rstref_t,Rst*>::iterator,multimap<rstref_t,Rst*>::iterator> rngRsts;

	Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "getFirstRst");

	rngRsts = xchg->rsts.equal_range(rstref_t(ixVState, 0));
	if (rngRsts.first != rngRsts.second) {
		rst = rngRsts.first->second;
		rst->lockAccess("SysIdhwDspcomplex3Spi", "getFirstRst");
	};

	Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "getFirstRst");

	return rst;
};

Bufxf* SysIdhwDspcomplex3Spi::getFirstBufxf(
			const uint ixVState
		) {
	Bufxf* bufxf = NULL;
	pair<multimap<bufxfref_t,Bufxf*>::iterator,multimap<bufxfref_t,Bufxf*>::iterator> rngBufxfs;

	Mutex::lock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "getFirstBufxf");

	rngBufxfs = xchg->bufxfs.equal_range(bufxfref_t(ixVState, 0));
	if (rngBufxfs.first != rngBufxfs.second) {
		bufxf = rngBufxfs.first->second;
		bufxf->lockAccess("SysIdhwDspcomplex3Spi", "getFirstBufxf");
	};

	Mutex::unlock(&(xchg->mRstsBufxfsCmds), "mRstsBufxfsCmds", "SysIdhwDspcomplex3Spi", "getFirstBufxf");

	return bufxf;
};

// IP cust --- INSERT

UntIdhw* SysIdhwDspcomplex3Spi::connectToTarget(
			const uint ixVTarget
		) {
	UntIdhw* unt = NULL;

	if (ixVTarget == VecVTarget::AXS2_PHI) unt = new UntIdhwAxs2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::AXS2_THETA) unt = new UntIdhwAxs2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::DCX3) unt = new UntIdhwDcx3(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::ICM2) unt = new UntIdhwIcm2(xchg, ixVTarget);
	else if (ixVTarget == VecVTarget::TAU2) unt = new UntIdhwTau2(xchg, ixVTarget);

	return unt;
};

uint SysIdhwDspcomplex3Spi::getIxVTargetBySref(
			const string& sref
		) {
	return VecVTarget::getIx(sref);
};

string SysIdhwDspcomplex3Spi::getSrefByIxVTarget(
			const uint ixVTarget
		) {
	return VecVTarget::getSref(ixVTarget);
};

void SysIdhwDspcomplex3Spi::fillFeedFTarget(
			Feed& feed
		) {
	VecVTarget::fillFeed(feed);
};

utinyint SysIdhwDspcomplex3Spi::getTixVControllerBySref(
			const uint ixVTarget
			, const string& sref
		) {
	utinyint tixVController = 0;

	if (ixVTarget == VecVTarget::DCX3) tixVController = UntIdhwDcx3::getTixVControllerBySref(sref);
	else if (ixVTarget == VecVTarget::ICM2) tixVController = UntIdhwIcm2::getTixVControllerBySref(sref);

	return tixVController;
};

string SysIdhwDspcomplex3Spi::getSrefByTixVController(
			const uint ixVTarget
			, const utinyint tixVController
		) {
	string sref;

	if (ixVTarget == VecVTarget::DCX3) sref = UntIdhwDcx3::getSrefByTixVController(tixVController);
	else if (ixVTarget == VecVTarget::ICM2) sref = UntIdhwIcm2::getSrefByTixVController(tixVController);

	return sref;
};

void SysIdhwDspcomplex3Spi::fillFeedFController(
			const uint ixVTarget
			, Feed& feed
		) {
	feed.clear();

	if (ixVTarget == VecVTarget::DCX3) UntIdhwDcx3::fillFeedFController(feed);
	else if (ixVTarget == VecVTarget::ICM2) UntIdhwIcm2::fillFeedFController(feed);
};

utinyint SysIdhwDspcomplex3Spi::getTixWBufferBySref(
			const uint ixVTarget
			, const string& sref
		) {
	utinyint tixWBuffer = 0;

	if (ixVTarget == VecVTarget::DCX3) tixWBuffer = UntIdhwDcx3::getTixWBufferBySref(sref);
	else if (ixVTarget == VecVTarget::ICM2) tixWBuffer = UntIdhwIcm2::getTixWBufferBySref(sref);

	return tixWBuffer;
};

string SysIdhwDspcomplex3Spi::getSrefByTixWBuffer(
			const uint ixVTarget
			, const utinyint tixWBuffer
		) {
	string sref;

	if (ixVTarget == VecVTarget::DCX3) sref = UntIdhwDcx3::getSrefByTixWBuffer(tixWBuffer);
	else if (ixVTarget == VecVTarget::ICM2) sref = UntIdhwIcm2::getSrefByTixWBuffer(tixWBuffer);

	return sref;
};

void SysIdhwDspcomplex3Spi::fillFeedFBuffer(
			const uint ixVTarget
			, Feed& feed
		) {
	feed.clear();

	if (ixVTarget == VecVTarget::DCX3) UntIdhwDcx3::fillFeedFBuffer(feed);
	else if (ixVTarget == VecVTarget::ICM2) UntIdhwIcm2::fillFeedFBuffer(feed);
};

utinyint SysIdhwDspcomplex3Spi::getTixVCommandBySref(
			const uint ixVTarget
			, const utinyint tixVController
			, const string& sref
		) {
	utinyint tixVCommand = 0;

	if (ixVTarget == VecVTarget::AXS2_PHI) tixVCommand = UntIdhwAxs2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::AXS2_THETA) tixVCommand = UntIdhwAxs2::getTixVCommandBySref(sref);
	else if (ixVTarget == VecVTarget::DCX3) tixVCommand = UntIdhwDcx3::getTixVCommandBySref(tixVController, sref);
	else if (ixVTarget == VecVTarget::ICM2) tixVCommand = UntIdhwIcm2::getTixVCommandBySref(tixVController, sref);
	else if (ixVTarget == VecVTarget::TAU2) tixVCommand = UntIdhwTau2::getTixVCommandBySref(sref);

	return tixVCommand;
};

string SysIdhwDspcomplex3Spi::getSrefByTixVCommand(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVCommand
		) {
	string sref;

	if (ixVTarget == VecVTarget::AXS2_PHI) sref = UntIdhwAxs2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::AXS2_THETA) sref = UntIdhwAxs2::getSrefByTixVCommand(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3) sref = UntIdhwDcx3::getSrefByTixVCommand(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::ICM2) sref = UntIdhwIcm2::getSrefByTixVCommand(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::TAU2) sref = UntIdhwTau2::getSrefByTixVCommand(tixVCommand);

	return sref;
};

void SysIdhwDspcomplex3Spi::fillFeedFCommand(
			const uint ixVTarget
			, const utinyint tixVController
			, Feed& feed
		) {
	feed.clear();

	if (ixVTarget == VecVTarget::AXS2_PHI) UntIdhwAxs2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::AXS2_THETA) UntIdhwAxs2::fillFeedFCommand(feed);
	else if (ixVTarget == VecVTarget::DCX3) UntIdhwDcx3::fillFeedFCommand(tixVController, feed);
	else if (ixVTarget == VecVTarget::ICM2) UntIdhwIcm2::fillFeedFCommand(tixVController, feed);
	else if (ixVTarget == VecVTarget::TAU2) UntIdhwTau2::fillFeedFCommand(feed);
};

string SysIdhwDspcomplex3Spi::getSrefByTixVError(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	string sref;

	return sref;
};

string SysIdhwDspcomplex3Spi::getTitleByTixVError(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	string Title;

	return Title;
};

Bufxf* SysIdhwDspcomplex3Spi::getNewBufxf(
			const uint ixVTarget
			, const utinyint tixWBuffer
			, const size_t reqlen
		) {
	Bufxf* bufxf = NULL;

	if (ixVTarget == VecVTarget::DCX3) bufxf = UntIdhwDcx3::getNewBufxf(tixWBuffer, reqlen);
	else if (ixVTarget == VecVTarget::ICM2) bufxf = UntIdhwIcm2::getNewBufxf(tixWBuffer, reqlen);

	if (bufxf) bufxf->ixVTarget = ixVTarget;

	return bufxf;
};

Cmd* SysIdhwDspcomplex3Spi::getNewCmd(
			const uint ixVTarget
			, const utinyint tixVController
			, const uint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (ixVTarget == VecVTarget::AXS2_PHI) cmd = UntIdhwAxs2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::AXS2_THETA) cmd = UntIdhwAxs2::getNewCmd(tixVCommand);
	else if (ixVTarget == VecVTarget::DCX3) cmd = UntIdhwDcx3::getNewCmd(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::ICM2) cmd = UntIdhwIcm2::getNewCmd(tixVController, tixVCommand);
	else if (ixVTarget == VecVTarget::TAU2) cmd = UntIdhwTau2::getNewCmd(tixVCommand);

	if (cmd) cmd->ixVTarget = ixVTarget;

	return cmd;
};

Err SysIdhwDspcomplex3Spi::getNewErr(
			const uint ixVTarget
			, const utinyint tixVController
			, const utinyint tixVError
		) {
	Err err;

	return err;
};



