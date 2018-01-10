/**
  * \file UntIdhwIcm2.cpp
  * icacam2 unit (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwIcm2.h"

/******************************************************************************
 class UntIdhwIcm2
 ******************************************************************************/

UntIdhwIcm2::UntIdhwIcm2(
			XchgIdhw* xchg
			, const uint ixVTarget
		) : UntIdhw(xchg, ixVTarget) {
	uref = xchg->addUnt(this);

	acq = new CtrIdhwIcm2Acq(xchg, ixVTarget, uref);
	fan = new CtrIdhwIcm2Fan(xchg, ixVTarget, uref);
	roic = new CtrIdhwIcm2Roic(xchg, ixVTarget, uref);
	state = new CtrIdhwIcm2State(xchg, ixVTarget, uref);
	sync = new CtrIdhwIcm2Sync(xchg, ixVTarget, uref);
	temp = new CtrIdhwIcm2Temp(xchg, ixVTarget, uref);
	tkclksrc = new CtrIdhwIcm2Tkclksrc(xchg, ixVTarget, uref);
	vmon = new CtrIdhwIcm2Vmon(xchg, ixVTarget, uref);
	vset = new CtrIdhwIcm2Vset(xchg, ixVTarget, uref);
	wavegen = new CtrIdhwIcm2Wavegen(xchg, ixVTarget, uref);
};

UntIdhwIcm2::~UntIdhwIcm2() {
	delete acq;
	delete fan;
	delete roic;
	delete state;
	delete sync;
	delete temp;
	delete tkclksrc;
	delete vmon;
	delete vset;
	delete wavegen;

	xchg->removeUntByUref(uref);
};

utinyint UntIdhwIcm2::getTixVControllerBySref(
			const string& sref
		) {
	return VecVIdhwIcm2Controller::getTix(sref);
};

string UntIdhwIcm2::getSrefByTixVController(
			const utinyint tixVController
		) {
	return VecVIdhwIcm2Controller::getSref(tixVController);
};

void UntIdhwIcm2::fillFeedFController(
			Feed& feed
		) {
	VecVIdhwIcm2Controller::fillFeed(feed);
};

utinyint UntIdhwIcm2::getTixWBufferBySref(
			const string& sref
		) {
	return VecWIdhwIcm2Buffer::getTix(sref);
};

string UntIdhwIcm2::getSrefByTixWBuffer(
			const utinyint tixWBuffer
		) {
	return VecWIdhwIcm2Buffer::getSref(tixWBuffer);
};

void UntIdhwIcm2::fillFeedFBuffer(
			Feed& feed
		) {
	VecWIdhwIcm2Buffer::fillFeed(feed);
};

utinyint UntIdhwIcm2::getTixVCommandBySref(
			const utinyint tixVController
			, const string& sref
		) {
	utinyint tixVCommand = 0;

	if (tixVController == VecVIdhwIcm2Controller::ACQ) tixVCommand = VecVIdhwIcm2AcqCommand::getTix(sref);
	else if (tixVController == VecVIdhwIcm2Controller::FAN) tixVCommand = VecVIdhwIcm2FanCommand::getTix(sref);
	else if (tixVController == VecVIdhwIcm2Controller::ROIC) tixVCommand = VecVIdhwIcm2RoicCommand::getTix(sref);
	else if (tixVController == VecVIdhwIcm2Controller::STATE) tixVCommand = VecVIdhwIcm2StateCommand::getTix(sref);
	else if (tixVController == VecVIdhwIcm2Controller::SYNC) tixVCommand = VecVIdhwIcm2SyncCommand::getTix(sref);
	else if (tixVController == VecVIdhwIcm2Controller::TEMP) tixVCommand = VecVIdhwIcm2TempCommand::getTix(sref);
	else if (tixVController == VecVIdhwIcm2Controller::TKCLKSRC) tixVCommand = VecVIdhwIcm2TkclksrcCommand::getTix(sref);
	else if (tixVController == VecVIdhwIcm2Controller::VMON) tixVCommand = VecVIdhwIcm2VmonCommand::getTix(sref);
	else if (tixVController == VecVIdhwIcm2Controller::VSET) tixVCommand = VecVIdhwIcm2VsetCommand::getTix(sref);
	else if (tixVController == VecVIdhwIcm2Controller::WAVEGEN) tixVCommand = VecVIdhwIcm2WavegenCommand::getTix(sref);

	return tixVCommand;
};

string UntIdhwIcm2::getSrefByTixVCommand(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	string sref;

	if (tixVController == VecVIdhwIcm2Controller::ACQ) sref = VecVIdhwIcm2AcqCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::FAN) sref = VecVIdhwIcm2FanCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::ROIC) sref = VecVIdhwIcm2RoicCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::STATE) sref = VecVIdhwIcm2StateCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::SYNC) sref = VecVIdhwIcm2SyncCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::TEMP) sref = VecVIdhwIcm2TempCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::TKCLKSRC) sref = VecVIdhwIcm2TkclksrcCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::VMON) sref = VecVIdhwIcm2VmonCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::VSET) sref = VecVIdhwIcm2VsetCommand::getSref(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::WAVEGEN) sref = VecVIdhwIcm2WavegenCommand::getSref(tixVCommand);

	return sref;
};

void UntIdhwIcm2::fillFeedFCommand(
			const utinyint tixVController
			, Feed& feed
		) {
	feed.clear();

	if (tixVController == VecVIdhwIcm2Controller::ACQ) VecVIdhwIcm2AcqCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwIcm2Controller::FAN) VecVIdhwIcm2FanCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwIcm2Controller::ROIC) VecVIdhwIcm2RoicCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwIcm2Controller::STATE) VecVIdhwIcm2StateCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwIcm2Controller::SYNC) VecVIdhwIcm2SyncCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwIcm2Controller::TEMP) VecVIdhwIcm2TempCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwIcm2Controller::TKCLKSRC) VecVIdhwIcm2TkclksrcCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwIcm2Controller::VMON) VecVIdhwIcm2VmonCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwIcm2Controller::VSET) VecVIdhwIcm2VsetCommand::fillFeed(feed);
	else if (tixVController == VecVIdhwIcm2Controller::WAVEGEN) VecVIdhwIcm2WavegenCommand::fillFeed(feed);
};

Bufxf* UntIdhwIcm2::getNewBufxf(
			const utinyint tixWBuffer
			, const size_t reqlen
		) {
	Bufxf* bufxf = NULL;

	if (tixWBuffer == VecWIdhwIcm2Buffer::ACQTOHOSTIF) bufxf = getNewBufxfFromAcq(reqlen);
	else if (tixWBuffer == VecWIdhwIcm2Buffer::HOSTIFTOWAVEGEN) bufxf = getNewBufxfToWavegen(reqlen);

	return bufxf;
};

Cmd* UntIdhwIcm2::getNewCmd(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVController == VecVIdhwIcm2Controller::ACQ) cmd = CtrIdhwIcm2Acq::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::FAN) cmd = CtrIdhwIcm2Fan::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::ROIC) cmd = CtrIdhwIcm2Roic::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::STATE) cmd = CtrIdhwIcm2State::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::SYNC) cmd = CtrIdhwIcm2Sync::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::TEMP) cmd = CtrIdhwIcm2Temp::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::TKCLKSRC) cmd = CtrIdhwIcm2Tkclksrc::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::VMON) cmd = CtrIdhwIcm2Vmon::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::VSET) cmd = CtrIdhwIcm2Vset::getNewCmd(tixVCommand);
	else if (tixVController == VecVIdhwIcm2Controller::WAVEGEN) cmd = CtrIdhwIcm2Wavegen::getNewCmd(tixVCommand);

	return cmd;
};

Bufxf* UntIdhwIcm2::getNewBufxfFromAcq(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwIcm2Buffer::ACQTOHOSTIF, true, reqlen));
};

void UntIdhwIcm2::readBufFromAcq(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	string msg;

	Bufxf* bufxf = getNewBufxfFromAcq(reqlen);

	bufxf->ixVTarget = ixVTarget;
	bufxf->uref = uref;

	xchg->runBufxf(bufxf);

	if (bufxf->success) {
		data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();
	} else {
		msg = "error reading data from buffer acqToHostif";
	};

	delete bufxf;

	if (msg != "") throw(DbeException(msg));
};

Bufxf* UntIdhwIcm2::getNewBufxfToWavegen(			const size_t reqlen
		) {
	return(new Bufxf(VecWIdhwIcm2Buffer::HOSTIFTOWAVEGEN, false, reqlen));
};

void UntIdhwIcm2::writeBufToWavegen(
			const unsigned char* data
			, const size_t datalen
		) {
	string msg;

	Bufxf* bufxf = getNewBufxfToWavegen(datalen);

	bufxf->ixVTarget = ixVTarget;
	bufxf->uref = uref;

	bufxf->setWriteData(data, datalen);

	xchg->runBufxf(bufxf);

	if (!bufxf->success) msg = "error writing data to buffer hostifToWavegen";

	delete bufxf;

	if (msg != "") throw(DbeException(msg));
};

