/**
  * \file UntIdhwBss3.cpp
  * Digilent Basys3 unit (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwBss3.h"

/******************************************************************************
 class UntIdhwBss3
 ******************************************************************************/

UntIdhwBss3::UntIdhwBss3(
			XchgIdhw* xchg
			, const uint ixVTarget
		) : UntIdhw(xchg, ixVTarget) {
	uref = xchg->addUnt(this);

	alua = new CtrIdhwBss3Alua(xchg, ixVTarget, uref);
	alub = new CtrIdhwBss3Alub(xchg, ixVTarget, uref);
	dcxif = new CtrIdhwBss3Dcxif(xchg, ixVTarget, uref);
	lwiracq = new CtrIdhwBss3Lwiracq(xchg, ixVTarget, uref);
	lwiremu = new CtrIdhwBss3Lwiremu(xchg, ixVTarget, uref);
	phiif = new CtrIdhwBss3Phiif(xchg, ixVTarget, uref);
	pmmu = new CtrIdhwBss3Pmmu(xchg, ixVTarget, uref);
	qcdif = new CtrIdhwBss3Qcdif(xchg, ixVTarget, uref);
	thetaif = new CtrIdhwBss3Thetaif(xchg, ixVTarget, uref);
	tkclksrc = new CtrIdhwBss3Tkclksrc(xchg, ixVTarget, uref);
	trigger = new CtrIdhwBss3Trigger(xchg, ixVTarget, uref);
};

UntIdhwBss3::~UntIdhwBss3() {
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

utinyint UntIdhwBss3::getTixVControllerBySref(
			const string& sref
		) {
	return VecVIdhwBss3Controller::getTix(sref);
};

string UntIdhwBss3::getSrefByTixVController(
			const utinyint tixVController
		) {
	return VecVIdhwBss3Controller::getSref(tixVController);
};

void UntIdhwBss3::fillFeedFController(
			Feed& feed
		) {
	VecVIdhwBss3Controller::fillFeed(feed);
};

utinyint UntIdhwBss3::getTixWBufferBySref(
			const string& sref
		) {
	return VecWIdhwBss3Buffer::getTix(sref);
};

string UntIdhwBss3::getSrefByTixWBuffer(
			const utinyint tixWBuffer
		) {
	return VecWIdhwBss3Buffer::getSref(tixWBuffer);
};

void UntIdhwBss3::fillFeedFBuffer(
			Feed& feed
		) {
	VecWIdhwBss3Buffer::fillFeed(feed);
};

utinyint UntIdhwBss3::getTixVCommandBySref(
			const utinyint tixVController
			, const string& sref
		) {
	utinyint tixVCommand = 0;

	if (tixVController == VecVIdhwBss3Controller::ALUA) tixVCommand = VecVIdhwBss3AluaCommand::getTix(sref);
	else if (tixVController == VecVIdhwBss3Controller::ALUB) tixVCommand = VecVIdhwBss3AlubCommand::getTix(sref);
	else if (tixVController == VecVIdhwBss3Controller::DCXIF) tixVCommand = VecVIdhwBss3DcxifCommand::getTix(sref);
	else if (tixVController == VecVIdhwBss3Controller::LWIRACQ) tixVCommand = VecVIdhwBss3LwiracqCommand::getTix(sref);
	else if (tixVController == VecVIdhwBss3Controller::LWIREMU) tixVCommand = VecVIdhwBss3LwiremuCommand::getTix(sref);
	else if (tixVController == VecVIdhwBss3Controller::PHIIF) tixVCommand = VecVIdhwBss3PhiifCommand::getTix(sref);
	else if (tixVController == VecVIdhwBss3Controller::PMMU) tixVCommand = VecVIdhwBss3PmmuCommand::getTix(sref);
	else if (tixVController == VecVIdhwBss3Controller::QCDIF) tixVCommand = VecVIdhwBss3QcdifCommand::getTix(sref);
	else if (tixVController == VecVIdhwBss3Controller::THETAIF) tixVCommand = VecVIdhwBss3ThetaifCommand::getTix(sref);
	else if (tixVController == VecVIdhwBss3Controller::TKCLKSRC) tixVCommand = VecVIdhwBss3TkclksrcCommand::getTix(sref);
	else if (tixVController == VecVIdhwBss3Controller::TRIGGER) tixVCommand = VecVIdhwBss3TriggerCommand::getTix(sref);

	return tixVCommand;
};

string UntIdhwBss3::getSrefByTixVCommand(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	string sref;

	if (tixVController == VecVIdhwBss3Controller::ALUA) sref = VecVIdhwBss3AluaCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::ALUB) sref = VecVIdhwBss3AlubCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::DCXIF) sref = VecVIdhwBss3DcxifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::LWIRACQ) sref = VecVIdhwBss3LwiracqCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::LWIREMU) sref = VecVIdhwBss3LwiremuCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::PHIIF) sref = VecVIdhwBss3PhiifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::PMMU) sref = VecVIdhwBss3PmmuCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::QCDIF) sref = VecVIdhwBss3QcdifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::THETAIF) sref = VecVIdhwBss3ThetaifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::TKCLKSRC) sref = VecVIdhwBss3TkclksrcCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::TRIGGER) sref = VecVIdhwBss3TriggerCommand::getSref(tixVCommand);

	return sref;
};

void UntIdhwBss3::fillFeedFCommand(
			const utinyint tixVController
			, Feed& feed
		) {
	feed.clear();

	if (tixVController == VecVIdhwBss3Controller::ALUA) VecVIdhwBss3AluaCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwBss3Controller::ALUB) VecVIdhwBss3AlubCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwBss3Controller::DCXIF) VecVIdhwBss3DcxifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwBss3Controller::LWIRACQ) VecVIdhwBss3LwiracqCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwBss3Controller::LWIREMU) VecVIdhwBss3LwiremuCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwBss3Controller::PHIIF) VecVIdhwBss3PhiifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwBss3Controller::PMMU) VecVIdhwBss3PmmuCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwBss3Controller::QCDIF) VecVIdhwBss3QcdifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwBss3Controller::THETAIF) VecVIdhwBss3ThetaifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwBss3Controller::TKCLKSRC) VecVIdhwBss3TkclksrcCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwBss3Controller::TRIGGER) VecVIdhwBss3TriggerCommand::fillFeed(feed);
};

Bufxf* UntIdhwBss3::getNewBufxf(
			const utinyint tixWBuffer
			, const size_t reqlen
		) {
	Bufxf* bufxf = NULL;

	if (tixWBuffer == VecWIdhwBss3Buffer::DCXIFTOHOSTIF) bufxf = getNewBufxfFromDcxif(reqlen);
	else if (tixWBuffer == VecWIdhwBss3Buffer::HOSTIFTODCXIF) bufxf = getNewBufxfToDcxif(reqlen);
	else if (tixWBuffer == VecWIdhwBss3Buffer::HOSTIFTOQCDIF) bufxf = getNewBufxfToQcdif(reqlen);
	else if (tixWBuffer == VecWIdhwBss3Buffer::PMMUTOHOSTIF) bufxf = getNewBufxfFromPmmu(reqlen);
	else if (tixWBuffer == VecWIdhwBss3Buffer::QCDIFTOHOSTIF) bufxf = getNewBufxfFromQcdif(reqlen);

	return bufxf;
};

Cmd* UntIdhwBss3::getNewCmd(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVController == VecVIdhwBss3Controller::ALUA) cmd = CtrIdhwBss3Alua::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::ALUB) cmd = CtrIdhwBss3Alub::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::DCXIF) cmd = CtrIdhwBss3Dcxif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::LWIRACQ) cmd = CtrIdhwBss3Lwiracq::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::LWIREMU) cmd = CtrIdhwBss3Lwiremu::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::PHIIF) cmd = CtrIdhwBss3Phiif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::PMMU) cmd = CtrIdhwBss3Pmmu::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::QCDIF) cmd = CtrIdhwBss3Qcdif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::THETAIF) cmd = CtrIdhwBss3Thetaif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::TKCLKSRC) cmd = CtrIdhwBss3Tkclksrc::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwBss3Controller::TRIGGER) cmd = CtrIdhwBss3Trigger::getNewCmd(tixVCommand);

	return cmd;
};

Bufxf* UntIdhwBss3::getNewBufxfFromDcxif(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwBss3Buffer::DCXIFTOHOSTIF, true, reqlen));
};

void UntIdhwBss3::readBufFromDcxif(
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

Bufxf* UntIdhwBss3::getNewBufxfToDcxif(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwBss3Buffer::HOSTIFTODCXIF, false, reqlen));
};

void UntIdhwBss3::writeBufToDcxif(
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

Bufxf* UntIdhwBss3::getNewBufxfToQcdif(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwBss3Buffer::HOSTIFTOQCDIF, false, reqlen));
};

void UntIdhwBss3::writeBufToQcdif(
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

Bufxf* UntIdhwBss3::getNewBufxfFromPmmu(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwBss3Buffer::PMMUTOHOSTIF, true, reqlen));
};

void UntIdhwBss3::readBufFromPmmu(
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

Bufxf* UntIdhwBss3::getNewBufxfFromQcdif(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwBss3Buffer::QCDIFTOHOSTIF, true, reqlen));
};

void UntIdhwBss3::readBufFromQcdif(
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

