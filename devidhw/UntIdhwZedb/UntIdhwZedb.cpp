/**
  * \file UntIdhwZedb.cpp
  * ZedBoard unit (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwZedb.h"

/******************************************************************************
 class UntIdhwZedb
 ******************************************************************************/

UntIdhwZedb::UntIdhwZedb(
			XchgIdhw* xchg
			, const uint ixVTarget
		) : UntIdhw(xchg, ixVTarget) {
	uref = xchg->addUnt(this);

	alua = new CtrIdhwZedbAlua(xchg, ixVTarget, uref);
	alub = new CtrIdhwZedbAlub(xchg, ixVTarget, uref);
	dcxif = new CtrIdhwZedbDcxif(xchg, ixVTarget, uref);
	lwiracq = new CtrIdhwZedbLwiracq(xchg, ixVTarget, uref);
	lwiremu = new CtrIdhwZedbLwiremu(xchg, ixVTarget, uref);
	phiif = new CtrIdhwZedbPhiif(xchg, ixVTarget, uref);
	pmmu = new CtrIdhwZedbPmmu(xchg, ixVTarget, uref);
	qcdif = new CtrIdhwZedbQcdif(xchg, ixVTarget, uref);
	thetaif = new CtrIdhwZedbThetaif(xchg, ixVTarget, uref);
	tkclksrc = new CtrIdhwZedbTkclksrc(xchg, ixVTarget, uref);
	trigger = new CtrIdhwZedbTrigger(xchg, ixVTarget, uref);
};

UntIdhwZedb::~UntIdhwZedb() {
	delete alua;
	delete alub;
	delete dcxif;
	delete lwiracq;
	delete lwiremu;
	delete phiif;
	delete pmmu;
	delete qcdif;
	delete thetaif;
	delete tkclksrc;
	delete trigger;

	xchg->removeUntByUref(uref);
};

utinyint UntIdhwZedb::getTixVControllerBySref(
			const string& sref
		) {
	return VecVIdhwZedbController::getTix(sref);
};

string UntIdhwZedb::getSrefByTixVController(
			const utinyint tixVController
		) {
	return VecVIdhwZedbController::getSref(tixVController);
};

void UntIdhwZedb::fillFeedFController(
			Feed& feed
		) {
	VecVIdhwZedbController::fillFeed(feed);
};

utinyint UntIdhwZedb::getTixWBufferBySref(
			const string& sref
		) {
	return VecWIdhwZedbBuffer::getTix(sref);
};

string UntIdhwZedb::getSrefByTixWBuffer(
			const utinyint tixWBuffer
		) {
	return VecWIdhwZedbBuffer::getSref(tixWBuffer);
};

void UntIdhwZedb::fillFeedFBuffer(
			Feed& feed
		) {
	VecWIdhwZedbBuffer::fillFeed(feed);
};

utinyint UntIdhwZedb::getTixVCommandBySref(
			const utinyint tixVController
			, const string& sref
		) {
	utinyint tixVCommand = 0;

	if (tixVController == VecVIdhwZedbController::ALUA) tixVCommand = VecVIdhwZedbAluaCommand::getTix(sref);
	else if (tixVController == VecVIdhwZedbController::ALUB) tixVCommand = VecVIdhwZedbAlubCommand::getTix(sref);
	else if (tixVController == VecVIdhwZedbController::DCXIF) tixVCommand = VecVIdhwZedbDcxifCommand::getTix(sref);
	else if (tixVController == VecVIdhwZedbController::LWIRACQ) tixVCommand = VecVIdhwZedbLwiracqCommand::getTix(sref);
	else if (tixVController == VecVIdhwZedbController::LWIREMU) tixVCommand = VecVIdhwZedbLwiremuCommand::getTix(sref);
	else if (tixVController == VecVIdhwZedbController::PHIIF) tixVCommand = VecVIdhwZedbPhiifCommand::getTix(sref);
	else if (tixVController == VecVIdhwZedbController::PMMU) tixVCommand = VecVIdhwZedbPmmuCommand::getTix(sref);
	else if (tixVController == VecVIdhwZedbController::QCDIF) tixVCommand = VecVIdhwZedbQcdifCommand::getTix(sref);
	else if (tixVController == VecVIdhwZedbController::THETAIF) tixVCommand = VecVIdhwZedbThetaifCommand::getTix(sref);
	else if (tixVController == VecVIdhwZedbController::TKCLKSRC) tixVCommand = VecVIdhwZedbTkclksrcCommand::getTix(sref);
	else if (tixVController == VecVIdhwZedbController::TRIGGER) tixVCommand = VecVIdhwZedbTriggerCommand::getTix(sref);

	return tixVCommand;
};

string UntIdhwZedb::getSrefByTixVCommand(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	string sref;

	if (tixVController == VecVIdhwZedbController::ALUA) sref = VecVIdhwZedbAluaCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::ALUB) sref = VecVIdhwZedbAlubCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::DCXIF) sref = VecVIdhwZedbDcxifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::LWIRACQ) sref = VecVIdhwZedbLwiracqCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::LWIREMU) sref = VecVIdhwZedbLwiremuCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::PHIIF) sref = VecVIdhwZedbPhiifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::PMMU) sref = VecVIdhwZedbPmmuCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::QCDIF) sref = VecVIdhwZedbQcdifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::THETAIF) sref = VecVIdhwZedbThetaifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::TKCLKSRC) sref = VecVIdhwZedbTkclksrcCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::TRIGGER) sref = VecVIdhwZedbTriggerCommand::getSref(tixVCommand);

	return sref;
};

void UntIdhwZedb::fillFeedFCommand(
			const utinyint tixVController
			, Feed& feed
		) {
	feed.clear();

	if (tixVController == VecVIdhwZedbController::ALUA) VecVIdhwZedbAluaCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwZedbController::ALUB) VecVIdhwZedbAlubCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwZedbController::DCXIF) VecVIdhwZedbDcxifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwZedbController::LWIRACQ) VecVIdhwZedbLwiracqCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwZedbController::LWIREMU) VecVIdhwZedbLwiremuCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwZedbController::PHIIF) VecVIdhwZedbPhiifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwZedbController::PMMU) VecVIdhwZedbPmmuCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwZedbController::QCDIF) VecVIdhwZedbQcdifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwZedbController::THETAIF) VecVIdhwZedbThetaifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwZedbController::TKCLKSRC) VecVIdhwZedbTkclksrcCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwZedbController::TRIGGER) VecVIdhwZedbTriggerCommand::fillFeed(feed);
};

Bufxf* UntIdhwZedb::getNewBufxf(
			const utinyint tixWBuffer
			, const size_t reqlen
		) {
	Bufxf* bufxf = NULL;

	if (tixWBuffer == VecWIdhwZedbBuffer::DCXIFTOHOSTIF) bufxf = getNewBufxfFromDcxif(reqlen);
	else if (tixWBuffer == VecWIdhwZedbBuffer::HOSTIFTODCXIF) bufxf = getNewBufxfToDcxif(reqlen);
	else if (tixWBuffer == VecWIdhwZedbBuffer::HOSTIFTOQCDIF) bufxf = getNewBufxfToQcdif(reqlen);
	else if (tixWBuffer == VecWIdhwZedbBuffer::PMMUTOHOSTIF) bufxf = getNewBufxfFromPmmu(reqlen);
	else if (tixWBuffer == VecWIdhwZedbBuffer::QCDIFTOHOSTIF) bufxf = getNewBufxfFromQcdif(reqlen);

	return bufxf;
};

Cmd* UntIdhwZedb::getNewCmd(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVController == VecVIdhwZedbController::ALUA) cmd = CtrIdhwZedbAlua::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::ALUB) cmd = CtrIdhwZedbAlub::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::DCXIF) cmd = CtrIdhwZedbDcxif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::LWIRACQ) cmd = CtrIdhwZedbLwiracq::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::LWIREMU) cmd = CtrIdhwZedbLwiremu::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::PHIIF) cmd = CtrIdhwZedbPhiif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::PMMU) cmd = CtrIdhwZedbPmmu::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::QCDIF) cmd = CtrIdhwZedbQcdif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::THETAIF) cmd = CtrIdhwZedbThetaif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::TKCLKSRC) cmd = CtrIdhwZedbTkclksrc::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwZedbController::TRIGGER) cmd = CtrIdhwZedbTrigger::getNewCmd(tixVCommand);

	return cmd;
};

Bufxf* UntIdhwZedb::getNewBufxfFromDcxif(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwZedbBuffer::DCXIFTOHOSTIF, true, reqlen));
};

void UntIdhwZedb::readBufFromDcxif(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	string msg;

	Bufxf* bufxf = getNewBufxfFromDcxif(reqlen);

	bufxf->ixVTarget = ixVTarget;
	bufxf->uref = uref;

	xchg->runBufxf(bufxf);

	if (bufxf->success) {
		data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();
	} else {
		msg = "error reading data from buffer dcxifToHostif";
	};

	delete bufxf;

	if (msg != "") throw(DbeException(msg));
};

Bufxf* UntIdhwZedb::getNewBufxfToDcxif(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwZedbBuffer::HOSTIFTODCXIF, false, reqlen));
};

void UntIdhwZedb::writeBufToDcxif(
			const unsigned char* data
			, const size_t datalen
		) {
	string msg;

	Bufxf* bufxf = getNewBufxfToDcxif(datalen);

	bufxf->ixVTarget = ixVTarget;
	bufxf->uref = uref;

	bufxf->setWriteData(data, datalen);

	xchg->runBufxf(bufxf);

	if (!bufxf->success) msg = "error writing data to buffer hostifToDcxif";

	delete bufxf;

	if (msg != "") throw(DbeException(msg));
};

Bufxf* UntIdhwZedb::getNewBufxfToQcdif(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwZedbBuffer::HOSTIFTOQCDIF, false, reqlen));
};

void UntIdhwZedb::writeBufToQcdif(
			const unsigned char* data
			, const size_t datalen
		) {
	string msg;

	Bufxf* bufxf = getNewBufxfToQcdif(datalen);

	bufxf->ixVTarget = ixVTarget;
	bufxf->uref = uref;

	bufxf->setWriteData(data, datalen);

	xchg->runBufxf(bufxf);

	if (!bufxf->success) msg = "error writing data to buffer hostifToQcdif";

	delete bufxf;

	if (msg != "") throw(DbeException(msg));
};

Bufxf* UntIdhwZedb::getNewBufxfFromPmmu(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwZedbBuffer::PMMUTOHOSTIF, true, reqlen));
};

void UntIdhwZedb::readBufFromPmmu(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	string msg;

	Bufxf* bufxf = getNewBufxfFromPmmu(reqlen);

	bufxf->ixVTarget = ixVTarget;
	bufxf->uref = uref;

	xchg->runBufxf(bufxf);

	if (bufxf->success) {
		data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();
	} else {
		msg = "error reading data from buffer pmmuToHostif";
	};

	delete bufxf;

	if (msg != "") throw(DbeException(msg));
};

Bufxf* UntIdhwZedb::getNewBufxfFromQcdif(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwZedbBuffer::QCDIFTOHOSTIF, true, reqlen));
};

void UntIdhwZedb::readBufFromQcdif(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	string msg;

	Bufxf* bufxf = getNewBufxfFromQcdif(reqlen);

	bufxf->ixVTarget = ixVTarget;
	bufxf->uref = uref;

	xchg->runBufxf(bufxf);

	if (bufxf->success) {
		data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();
	} else {
		msg = "error reading data from buffer qcdifToHostif";
	};

	delete bufxf;

	if (msg != "") throw(DbeException(msg));
};

