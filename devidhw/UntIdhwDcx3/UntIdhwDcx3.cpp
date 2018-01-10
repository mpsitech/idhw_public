/**
  * \file UntIdhwDcx3.cpp
  * dspcomplex3 unit (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwDcx3.h"

/******************************************************************************
 class UntIdhwDcx3
 ******************************************************************************/

UntIdhwDcx3::UntIdhwDcx3(
			XchgIdhw* xchg
			, const uint ixVTarget
		) : UntIdhw(xchg, ixVTarget) {
	uref = xchg->addUnt(this);

	adxl = new CtrIdhwDcx3Adxl(xchg, ixVTarget, uref);
	align = new CtrIdhwDcx3Align(xchg, ixVTarget, uref);
	led = new CtrIdhwDcx3Led(xchg, ixVTarget, uref);
	lwiracq = new CtrIdhwDcx3Lwiracq(xchg, ixVTarget, uref);
	lwirif = new CtrIdhwDcx3Lwirif(xchg, ixVTarget, uref);
	phiif = new CtrIdhwDcx3Phiif(xchg, ixVTarget, uref);
	pmmu = new CtrIdhwDcx3Pmmu(xchg, ixVTarget, uref);
	qcdif = new CtrIdhwDcx3Qcdif(xchg, ixVTarget, uref);
	shfbox = new CtrIdhwDcx3Shfbox(xchg, ixVTarget, uref);
	state = new CtrIdhwDcx3State(xchg, ixVTarget, uref);
	thetaif = new CtrIdhwDcx3Thetaif(xchg, ixVTarget, uref);
	tkclksrc = new CtrIdhwDcx3Tkclksrc(xchg, ixVTarget, uref);
	trigger = new CtrIdhwDcx3Trigger(xchg, ixVTarget, uref);
};

UntIdhwDcx3::~UntIdhwDcx3() {
	delete adxl;
	delete align;
	delete led;
	delete lwiracq;
	delete lwirif;
	delete phiif;
	delete pmmu;
	delete qcdif;
	delete shfbox;
	delete state;
	delete thetaif;
	delete tkclksrc;
	delete trigger;

	xchg->removeUntByUref(uref);
};

utinyint UntIdhwDcx3::getTixVControllerBySref(
			const string& sref
		) {
	return VecVIdhwDcx3Controller::getTix(sref);
};

string UntIdhwDcx3::getSrefByTixVController(
			const utinyint tixVController
		) {
	return VecVIdhwDcx3Controller::getSref(tixVController);
};

void UntIdhwDcx3::fillFeedFController(
			Feed& feed
		) {
	VecVIdhwDcx3Controller::fillFeed(feed);
};

utinyint UntIdhwDcx3::getTixWBufferBySref(
			const string& sref
		) {
	return VecWIdhwDcx3Buffer::getTix(sref);
};

string UntIdhwDcx3::getSrefByTixWBuffer(
			const utinyint tixWBuffer
		) {
	return VecWIdhwDcx3Buffer::getSref(tixWBuffer);
};

void UntIdhwDcx3::fillFeedFBuffer(
			Feed& feed
		) {
	VecWIdhwDcx3Buffer::fillFeed(feed);
};

utinyint UntIdhwDcx3::getTixVCommandBySref(
			const utinyint tixVController
			, const string& sref
		) {
	utinyint tixVCommand = 0;

	if (tixVController == VecVIdhwDcx3Controller::ADXL) tixVCommand = VecVIdhwDcx3AdxlCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::ALIGN) tixVCommand = VecVIdhwDcx3AlignCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::LED) tixVCommand = VecVIdhwDcx3LedCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::LWIRACQ) tixVCommand = VecVIdhwDcx3LwiracqCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::LWIRIF) tixVCommand = VecVIdhwDcx3LwirifCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::PHIIF) tixVCommand = VecVIdhwDcx3PhiifCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::PMMU) tixVCommand = VecVIdhwDcx3PmmuCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::QCDIF) tixVCommand = VecVIdhwDcx3QcdifCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::SHFBOX) tixVCommand = VecVIdhwDcx3ShfboxCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::STATE) tixVCommand = VecVIdhwDcx3StateCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::THETAIF) tixVCommand = VecVIdhwDcx3ThetaifCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::TKCLKSRC) tixVCommand = VecVIdhwDcx3TkclksrcCommand::getTix(sref);
	else if (tixVController == VecVIdhwDcx3Controller::TRIGGER) tixVCommand = VecVIdhwDcx3TriggerCommand::getTix(sref);

	return tixVCommand;
};

string UntIdhwDcx3::getSrefByTixVCommand(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	string sref;

	if (tixVController == VecVIdhwDcx3Controller::ADXL) sref = VecVIdhwDcx3AdxlCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::ALIGN) sref = VecVIdhwDcx3AlignCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::LED) sref = VecVIdhwDcx3LedCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::LWIRACQ) sref = VecVIdhwDcx3LwiracqCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::LWIRIF) sref = VecVIdhwDcx3LwirifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::PHIIF) sref = VecVIdhwDcx3PhiifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::PMMU) sref = VecVIdhwDcx3PmmuCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::QCDIF) sref = VecVIdhwDcx3QcdifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::SHFBOX) sref = VecVIdhwDcx3ShfboxCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::STATE) sref = VecVIdhwDcx3StateCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::THETAIF) sref = VecVIdhwDcx3ThetaifCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::TKCLKSRC) sref = VecVIdhwDcx3TkclksrcCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::TRIGGER) sref = VecVIdhwDcx3TriggerCommand::getSref(tixVCommand);

	return sref;
};

void UntIdhwDcx3::fillFeedFCommand(
			const utinyint tixVController
			, Feed& feed
		) {
	feed.clear();

	if (tixVController == VecVIdhwDcx3Controller::ADXL) VecVIdhwDcx3AdxlCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::ALIGN) VecVIdhwDcx3AlignCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::LED) VecVIdhwDcx3LedCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::LWIRACQ) VecVIdhwDcx3LwiracqCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::LWIRIF) VecVIdhwDcx3LwirifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::PHIIF) VecVIdhwDcx3PhiifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::PMMU) VecVIdhwDcx3PmmuCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::QCDIF) VecVIdhwDcx3QcdifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::SHFBOX) VecVIdhwDcx3ShfboxCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::STATE) VecVIdhwDcx3StateCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::THETAIF) VecVIdhwDcx3ThetaifCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::TKCLKSRC) VecVIdhwDcx3TkclksrcCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwDcx3Controller::TRIGGER) VecVIdhwDcx3TriggerCommand::fillFeed(feed);
};

Bufxf* UntIdhwDcx3::getNewBufxf(
			const utinyint tixWBuffer
			, const size_t reqlen
		) {
	Bufxf* bufxf = NULL;

	if (tixWBuffer == VecWIdhwDcx3Buffer::HOSTIFTOQCDIF) bufxf = getNewBufxfToQcdif(reqlen);
	else if (tixWBuffer == VecWIdhwDcx3Buffer::PMMUTOHOSTIF) bufxf = getNewBufxfFromPmmu(reqlen);
	else if (tixWBuffer == VecWIdhwDcx3Buffer::QCDIFTOHOSTIF) bufxf = getNewBufxfFromQcdif(reqlen);

	return bufxf;
};

Cmd* UntIdhwDcx3::getNewCmd(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVController == VecVIdhwDcx3Controller::ADXL) cmd = CtrIdhwDcx3Adxl::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::ALIGN) cmd = CtrIdhwDcx3Align::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::LED) cmd = CtrIdhwDcx3Led::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::LWIRACQ) cmd = CtrIdhwDcx3Lwiracq::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::LWIRIF) cmd = CtrIdhwDcx3Lwirif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::PHIIF) cmd = CtrIdhwDcx3Phiif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::PMMU) cmd = CtrIdhwDcx3Pmmu::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::QCDIF) cmd = CtrIdhwDcx3Qcdif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::SHFBOX) cmd = CtrIdhwDcx3Shfbox::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::STATE) cmd = CtrIdhwDcx3State::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::THETAIF) cmd = CtrIdhwDcx3Thetaif::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::TKCLKSRC) cmd = CtrIdhwDcx3Tkclksrc::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwDcx3Controller::TRIGGER) cmd = CtrIdhwDcx3Trigger::getNewCmd(tixVCommand);

	return cmd;
};

Bufxf* UntIdhwDcx3::getNewBufxfToQcdif(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwDcx3Buffer::HOSTIFTOQCDIF, false, reqlen));
};

void UntIdhwDcx3::writeBufToQcdif(
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

Bufxf* UntIdhwDcx3::getNewBufxfFromPmmu(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwDcx3Buffer::PMMUTOHOSTIF, true, reqlen));
};

void UntIdhwDcx3::readBufFromPmmu(
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

Bufxf* UntIdhwDcx3::getNewBufxfFromQcdif(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwDcx3Buffer::QCDIFTOHOSTIF, true, reqlen));
};

void UntIdhwDcx3::readBufFromQcdif(
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

