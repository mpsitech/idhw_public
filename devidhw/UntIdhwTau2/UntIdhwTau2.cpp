/**
  * \file UntIdhwTau2.cpp
  * FLIR Tau2 unit (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwTau2.h"

/******************************************************************************
 class UntIdhwTau2::CmdSerialNumber
 ******************************************************************************/

UntIdhwTau2::CmdSerialNumber::CmdSerialNumber() : Cmd(VecVIdhwTau2Command::SERIALNUMBER, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdSerialNumber::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint csn, const uint ssn)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdSerialNumber::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["csn"].getUint(), parsRet["ssn"].getUint());
};

/******************************************************************************
 class UntIdhwTau2::CmdGetRevision
 ******************************************************************************/

UntIdhwTau2::CmdGetRevision::CmdGetRevision() : Cmd(VecVIdhwTau2Command::GETREVISION, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdGetRevision::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint swmaj, const usmallint swmin, const usmallint fwmaj, const usmallint fwmin)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdGetRevision::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["swmaj"].getUsmallint(), parsRet["swmin"].getUsmallint(), parsRet["fwmaj"].getUsmallint(), parsRet["fwmin"].getUsmallint());
};

/******************************************************************************
 class UntIdhwTau2::CmdBaudRate
 ******************************************************************************/

UntIdhwTau2::CmdBaudRate::CmdBaudRate() : Cmd(VecVIdhwTau2Command::BAUDRATE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdBaudRate::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdBaudRate::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdGainMode
 ******************************************************************************/

UntIdhwTau2::CmdGainMode::CmdGainMode() : Cmd(VecVIdhwTau2Command::GAINMODE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdGainMode::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdGainMode::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdFfcModeSelect
 ******************************************************************************/

UntIdhwTau2::CmdFfcModeSelect::CmdFfcModeSelect() : Cmd(VecVIdhwTau2Command::FFCMODESELECT, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdFfcModeSelect::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdFfcModeSelect::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdFfcPeriod
 ******************************************************************************/

UntIdhwTau2::CmdFfcPeriod::CmdFfcPeriod() : Cmd(VecVIdhwTau2Command::FFCPERIOD, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdFfcPeriod::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdFfcPeriod::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdFfcTempDelta
 ******************************************************************************/

UntIdhwTau2::CmdFfcTempDelta::CmdFfcTempDelta() : Cmd(VecVIdhwTau2Command::FFCTEMPDELTA, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdFfcTempDelta::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdFfcTempDelta::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdVideoMode
 ******************************************************************************/

UntIdhwTau2::CmdVideoMode::CmdVideoMode() : Cmd(VecVIdhwTau2Command::VIDEOMODE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdVideoMode::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdVideoMode::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdVideoPalette
 ******************************************************************************/

UntIdhwTau2::CmdVideoPalette::CmdVideoPalette() : Cmd(VecVIdhwTau2Command::VIDEOPALETTE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdVideoPalette::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdVideoPalette::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdVideoOrientation
 ******************************************************************************/

UntIdhwTau2::CmdVideoOrientation::CmdVideoOrientation() : Cmd(VecVIdhwTau2Command::VIDEOORIENTATION, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdVideoOrientation::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdVideoOrientation::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdDigitalOutputMode
 ******************************************************************************/

UntIdhwTau2::CmdDigitalOutputMode::CmdDigitalOutputMode() : Cmd(VecVIdhwTau2Command::DIGITALOUTPUTMODE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdDigitalOutputMode::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdDigitalOutputMode::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdAgcType
 ******************************************************************************/

UntIdhwTau2::CmdAgcType::CmdAgcType() : Cmd(VecVIdhwTau2Command::AGCTYPE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdAgcType::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdAgcType::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdContrast
 ******************************************************************************/

UntIdhwTau2::CmdContrast::CmdContrast() : Cmd(VecVIdhwTau2Command::CONTRAST, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdContrast::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdContrast::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdBrightness
 ******************************************************************************/

UntIdhwTau2::CmdBrightness::CmdBrightness() : Cmd(VecVIdhwTau2Command::BRIGHTNESS, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdBrightness::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdBrightness::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdBrightnessBias
 ******************************************************************************/

UntIdhwTau2::CmdBrightnessBias::CmdBrightnessBias() : Cmd(VecVIdhwTau2Command::BRIGHTNESSBIAS, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdBrightnessBias::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdBrightnessBias::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdLensNumber
 ******************************************************************************/

UntIdhwTau2::CmdLensNumber::CmdLensNumber() : Cmd(VecVIdhwTau2Command::LENSNUMBER, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdLensNumber::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdLensNumber::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdSpotMeterMode
 ******************************************************************************/

UntIdhwTau2::CmdSpotMeterMode::CmdSpotMeterMode() : Cmd(VecVIdhwTau2Command::SPOTMETERMODE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdSpotMeterMode::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdSpotMeterMode::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdReadSensor
 ******************************************************************************/

UntIdhwTau2::CmdReadSensor::CmdReadSensor() : Cmd(VecVIdhwTau2Command::READSENSOR, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdReadSensor::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdReadSensor::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdExternalSync
 ******************************************************************************/

UntIdhwTau2::CmdExternalSync::CmdExternalSync() : Cmd(VecVIdhwTau2Command::EXTERNALSYNC, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdExternalSync::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdExternalSync::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdIsotherm
 ******************************************************************************/

UntIdhwTau2::CmdIsotherm::CmdIsotherm() : Cmd(VecVIdhwTau2Command::ISOTHERM, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdIsotherm::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdIsotherm::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdIsothermThresholds
 ******************************************************************************/

UntIdhwTau2::CmdIsothermThresholds::CmdIsothermThresholds() : Cmd(VecVIdhwTau2Command::ISOTHERMTHRESHOLDS, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdIsothermThresholds::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdIsothermThresholds::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdTestPattern
 ******************************************************************************/

UntIdhwTau2::CmdTestPattern::CmdTestPattern() : Cmd(VecVIdhwTau2Command::TESTPATTERN, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdTestPattern::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdTestPattern::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdVideoColorMode
 ******************************************************************************/

UntIdhwTau2::CmdVideoColorMode::CmdVideoColorMode() : Cmd(VecVIdhwTau2Command::VIDEOCOLORMODE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdVideoColorMode::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdVideoColorMode::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdGetSpotMeter
 ******************************************************************************/

UntIdhwTau2::CmdGetSpotMeter::CmdGetSpotMeter() : Cmd(VecVIdhwTau2Command::GETSPOTMETER, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdGetSpotMeter::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdGetSpotMeter::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdSpotDisplay
 ******************************************************************************/

UntIdhwTau2::CmdSpotDisplay::CmdSpotDisplay() : Cmd(VecVIdhwTau2Command::SPOTDISPLAY, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdSpotDisplay::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdSpotDisplay::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdDdeGain
 ******************************************************************************/

UntIdhwTau2::CmdDdeGain::CmdDdeGain() : Cmd(VecVIdhwTau2Command::DDEGAIN, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdDdeGain::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdDdeGain::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdSymbolControl
 ******************************************************************************/

UntIdhwTau2::CmdSymbolControl::CmdSymbolControl() : Cmd(VecVIdhwTau2Command::SYMBOLCONTROL, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdSymbolControl::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdSymbolControl::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdSplashControl
 ******************************************************************************/

UntIdhwTau2::CmdSplashControl::CmdSplashControl() : Cmd(VecVIdhwTau2Command::SPLASHCONTROL, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdSplashControl::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdSplashControl::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdEzoomControl
 ******************************************************************************/

UntIdhwTau2::CmdEzoomControl::CmdEzoomControl() : Cmd(VecVIdhwTau2Command::EZOOMCONTROL, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdEzoomControl::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdEzoomControl::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdFfcWarnTime
 ******************************************************************************/

UntIdhwTau2::CmdFfcWarnTime::CmdFfcWarnTime() : Cmd(VecVIdhwTau2Command::FFCWARNTIME, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdFfcWarnTime::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdFfcWarnTime::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdAgcFilter
 ******************************************************************************/

UntIdhwTau2::CmdAgcFilter::CmdAgcFilter() : Cmd(VecVIdhwTau2Command::AGCFILTER, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdAgcFilter::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdAgcFilter::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdPlateauLevel
 ******************************************************************************/

UntIdhwTau2::CmdPlateauLevel::CmdPlateauLevel() : Cmd(VecVIdhwTau2Command::PLATEAULEVEL, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdPlateauLevel::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdPlateauLevel::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdGetSpotMeterData
 ******************************************************************************/

UntIdhwTau2::CmdGetSpotMeterData::CmdGetSpotMeterData() : Cmd(VecVIdhwTau2Command::GETSPOTMETERDATA, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdGetSpotMeterData::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdGetSpotMeterData::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdAgcRoi
 ******************************************************************************/

UntIdhwTau2::CmdAgcRoi::CmdAgcRoi() : Cmd(VecVIdhwTau2Command::AGCROI, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdAgcRoi::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdAgcRoi::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdShutterTemp
 ******************************************************************************/

UntIdhwTau2::CmdShutterTemp::CmdShutterTemp() : Cmd(VecVIdhwTau2Command::SHUTTERTEMP, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdShutterTemp::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdShutterTemp::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdAgcMidpoint
 ******************************************************************************/

UntIdhwTau2::CmdAgcMidpoint::CmdAgcMidpoint() : Cmd(VecVIdhwTau2Command::AGCMIDPOINT, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdAgcMidpoint::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdAgcMidpoint::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdCameraPart
 ******************************************************************************/

UntIdhwTau2::CmdCameraPart::CmdCameraPart() : Cmd(VecVIdhwTau2Command::CAMERAPART, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdCameraPart::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* serno, const size_t sernolen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdCameraPart::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["serno"].getBlob(), parsRet["serno"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdReadArrayAverage
 ******************************************************************************/

UntIdhwTau2::CmdReadArrayAverage::CmdReadArrayAverage() : Cmd(VecVIdhwTau2Command::READARRAYAVERAGE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdReadArrayAverage::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdReadArrayAverage::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdMaxAgcGain
 ******************************************************************************/

UntIdhwTau2::CmdMaxAgcGain::CmdMaxAgcGain() : Cmd(VecVIdhwTau2Command::MAXAGCGAIN, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdMaxAgcGain::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdMaxAgcGain::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdPanAndTilt
 ******************************************************************************/

UntIdhwTau2::CmdPanAndTilt::CmdPanAndTilt() : Cmd(VecVIdhwTau2Command::PANANDTILT, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdPanAndTilt::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdPanAndTilt::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdVideoStandard
 ******************************************************************************/

UntIdhwTau2::CmdVideoStandard::CmdVideoStandard() : Cmd(VecVIdhwTau2Command::VIDEOSTANDARD, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdVideoStandard::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdVideoStandard::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdShutterPosition
 ******************************************************************************/

UntIdhwTau2::CmdShutterPosition::CmdShutterPosition() : Cmd(VecVIdhwTau2Command::SHUTTERPOSITION, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdShutterPosition::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdShutterPosition::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdTransferFrame
 ******************************************************************************/

UntIdhwTau2::CmdTransferFrame::CmdTransferFrame() : Cmd(VecVIdhwTau2Command::TRANSFERFRAME, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdTransferFrame::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdTransferFrame::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdCorrectionMask
 ******************************************************************************/

UntIdhwTau2::CmdCorrectionMask::CmdCorrectionMask() : Cmd(VecVIdhwTau2Command::CORRECTIONMASK, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdCorrectionMask::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdCorrectionMask::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdMemoryStatus
 ******************************************************************************/

UntIdhwTau2::CmdMemoryStatus::CmdMemoryStatus() : Cmd(VecVIdhwTau2Command::MEMORYSTATUS, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdMemoryStatus::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdMemoryStatus::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdReadMemory
 ******************************************************************************/

UntIdhwTau2::CmdReadMemory::CmdReadMemory() : Cmd(VecVIdhwTau2Command::READMEMORY, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdReadMemory::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdReadMemory::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdEraseMemoryBlock
 ******************************************************************************/

UntIdhwTau2::CmdEraseMemoryBlock::CmdEraseMemoryBlock() : Cmd(VecVIdhwTau2Command::ERASEMEMORYBLOCK, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdEraseMemoryBlock::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdEraseMemoryBlock::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdGetNvMemorySize
 ******************************************************************************/

UntIdhwTau2::CmdGetNvMemorySize::CmdGetNvMemorySize() : Cmd(VecVIdhwTau2Command::GETNVMEMORYSIZE, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdGetNvMemorySize::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdGetNvMemorySize::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdGetMemoryAddress
 ******************************************************************************/

UntIdhwTau2::CmdGetMemoryAddress::CmdGetMemoryAddress() : Cmd(VecVIdhwTau2Command::GETMEMORYADDRESS, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdGetMemoryAddress::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdGetMemoryAddress::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdGainSwitchParams
 ******************************************************************************/

UntIdhwTau2::CmdGainSwitchParams::CmdGainSwitchParams() : Cmd(VecVIdhwTau2Command::GAINSWITCHPARAMS, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdGainSwitchParams::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdGainSwitchParams::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdDdeThreshold
 ******************************************************************************/

UntIdhwTau2::CmdDdeThreshold::CmdDdeThreshold() : Cmd(VecVIdhwTau2Command::DDETHRESHOLD, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdDdeThreshold::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdDdeThreshold::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdSpatialThreshold
 ******************************************************************************/

UntIdhwTau2::CmdSpatialThreshold::CmdSpatialThreshold() : Cmd(VecVIdhwTau2Command::SPATIALTHRESHOLD, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdSpatialThreshold::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdSpatialThreshold::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getBlob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2::CmdLensResponseParams
 ******************************************************************************/

UntIdhwTau2::CmdLensResponseParams::CmdLensResponseParams() : Cmd(VecVIdhwTau2Command::LENSRESPONSEPARAMS, Cmd::VecVRettype::IMMSNG) {
	returnSpeccallback = NULL;
	argReturnSpeccallback = NULL;
};

void UntIdhwTau2::CmdLensResponseParams::setReturnSpeccallback(
			void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen)
			, void* _argReturnSpeccallback
		) {
	returnSpeccallback = _returnSpeccallback;
	argReturnSpeccallback = _argReturnSpeccallback;
};

void UntIdhwTau2::CmdLensResponseParams::returnToCallback() {
	if (returnCallback) returnCallback(this, argReturnCallback);
	if (returnSpeccallback) returnSpeccallback(this, argReturnSpeccallback, parsRet["rx"].getVblob(), parsRet["rx"].getLen());
};

/******************************************************************************
 class UntIdhwTau2
 ******************************************************************************/

UntIdhwTau2::UntIdhwTau2(
			XchgIdhw* xchg
			, const uint ixVTarget
		) : UntIdhw(xchg, ixVTarget) {
	uref = xchg->addUnt(this);
};

UntIdhwTau2::~UntIdhwTau2() {
	xchg->removeUntByUref(uref);
};

utinyint UntIdhwTau2::getTixVCommandBySref(
			const string& sref
		) {
	return VecVIdhwTau2Command::getTix(sref);
};

string UntIdhwTau2::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVIdhwTau2Command::getSref(tixVCommand);
};

void UntIdhwTau2::fillFeedFCommand(
			Feed& feed
		) {
	VecVIdhwTau2Command::fillFeed(feed);
};

Cmd* UntIdhwTau2::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVIdhwTau2Command::SETDEFAULTS) cmd = getNewCmdSetDefaults();
	else if (tixVCommand == VecVIdhwTau2Command::CAMERARESET) cmd = getNewCmdCameraReset();
	else if (tixVCommand == VecVIdhwTau2Command::RESTOREFACTORYDEFAULT) cmd = getNewCmdRestoreFactoryDefault();
	else if (tixVCommand == VecVIdhwTau2Command::SERIALNUMBER) cmd = getNewCmdSerialNumber();
	else if (tixVCommand == VecVIdhwTau2Command::GETREVISION) cmd = getNewCmdGetRevision();
	else if (tixVCommand == VecVIdhwTau2Command::BAUDRATE) cmd = getNewCmdBaudRate();
	else if (tixVCommand == VecVIdhwTau2Command::GAINMODE) cmd = getNewCmdGainMode();
	else if (tixVCommand == VecVIdhwTau2Command::FFCMODESELECT) cmd = getNewCmdFfcModeSelect();
	else if (tixVCommand == VecVIdhwTau2Command::DOFFC) cmd = getNewCmdDoFfc();
	else if (tixVCommand == VecVIdhwTau2Command::FFCPERIOD) cmd = getNewCmdFfcPeriod();
	else if (tixVCommand == VecVIdhwTau2Command::FFCTEMPDELTA) cmd = getNewCmdFfcTempDelta();
	else if (tixVCommand == VecVIdhwTau2Command::VIDEOMODE) cmd = getNewCmdVideoMode();
	else if (tixVCommand == VecVIdhwTau2Command::VIDEOPALETTE) cmd = getNewCmdVideoPalette();
	else if (tixVCommand == VecVIdhwTau2Command::VIDEOORIENTATION) cmd = getNewCmdVideoOrientation();
	else if (tixVCommand == VecVIdhwTau2Command::DIGITALOUTPUTMODE) cmd = getNewCmdDigitalOutputMode();
	else if (tixVCommand == VecVIdhwTau2Command::AGCTYPE) cmd = getNewCmdAgcType();
	else if (tixVCommand == VecVIdhwTau2Command::CONTRAST) cmd = getNewCmdContrast();
	else if (tixVCommand == VecVIdhwTau2Command::BRIGHTNESS) cmd = getNewCmdBrightness();
	else if (tixVCommand == VecVIdhwTau2Command::BRIGHTNESSBIAS) cmd = getNewCmdBrightnessBias();
	else if (tixVCommand == VecVIdhwTau2Command::LENSNUMBER) cmd = getNewCmdLensNumber();
	else if (tixVCommand == VecVIdhwTau2Command::SPOTMETERMODE) cmd = getNewCmdSpotMeterMode();
	else if (tixVCommand == VecVIdhwTau2Command::READSENSOR) cmd = getNewCmdReadSensor();
	else if (tixVCommand == VecVIdhwTau2Command::EXTERNALSYNC) cmd = getNewCmdExternalSync();
	else if (tixVCommand == VecVIdhwTau2Command::ISOTHERM) cmd = getNewCmdIsotherm();
	else if (tixVCommand == VecVIdhwTau2Command::ISOTHERMTHRESHOLDS) cmd = getNewCmdIsothermThresholds();
	else if (tixVCommand == VecVIdhwTau2Command::TESTPATTERN) cmd = getNewCmdTestPattern();
	else if (tixVCommand == VecVIdhwTau2Command::VIDEOCOLORMODE) cmd = getNewCmdVideoColorMode();
	else if (tixVCommand == VecVIdhwTau2Command::GETSPOTMETER) cmd = getNewCmdGetSpotMeter();
	else if (tixVCommand == VecVIdhwTau2Command::SPOTDISPLAY) cmd = getNewCmdSpotDisplay();
	else if (tixVCommand == VecVIdhwTau2Command::DDEGAIN) cmd = getNewCmdDdeGain();
	else if (tixVCommand == VecVIdhwTau2Command::SYMBOLCONTROL) cmd = getNewCmdSymbolControl();
	else if (tixVCommand == VecVIdhwTau2Command::SPLASHCONTROL) cmd = getNewCmdSplashControl();
	else if (tixVCommand == VecVIdhwTau2Command::EZOOMCONTROL) cmd = getNewCmdEzoomControl();
	else if (tixVCommand == VecVIdhwTau2Command::FFCWARNTIME) cmd = getNewCmdFfcWarnTime();
	else if (tixVCommand == VecVIdhwTau2Command::AGCFILTER) cmd = getNewCmdAgcFilter();
	else if (tixVCommand == VecVIdhwTau2Command::PLATEAULEVEL) cmd = getNewCmdPlateauLevel();
	else if (tixVCommand == VecVIdhwTau2Command::GETSPOTMETERDATA) cmd = getNewCmdGetSpotMeterData();
	else if (tixVCommand == VecVIdhwTau2Command::AGCROI) cmd = getNewCmdAgcRoi();
	else if (tixVCommand == VecVIdhwTau2Command::SHUTTERTEMP) cmd = getNewCmdShutterTemp();
	else if (tixVCommand == VecVIdhwTau2Command::AGCMIDPOINT) cmd = getNewCmdAgcMidpoint();
	else if (tixVCommand == VecVIdhwTau2Command::CAMERAPART) cmd = getNewCmdCameraPart();
	else if (tixVCommand == VecVIdhwTau2Command::READARRAYAVERAGE) cmd = getNewCmdReadArrayAverage();
	else if (tixVCommand == VecVIdhwTau2Command::MAXAGCGAIN) cmd = getNewCmdMaxAgcGain();
	else if (tixVCommand == VecVIdhwTau2Command::PANANDTILT) cmd = getNewCmdPanAndTilt();
	else if (tixVCommand == VecVIdhwTau2Command::VIDEOSTANDARD) cmd = getNewCmdVideoStandard();
	else if (tixVCommand == VecVIdhwTau2Command::SHUTTERPOSITION) cmd = getNewCmdShutterPosition();
	else if (tixVCommand == VecVIdhwTau2Command::TRANSFERFRAME) cmd = getNewCmdTransferFrame();
	else if (tixVCommand == VecVIdhwTau2Command::CORRECTIONMASK) cmd = getNewCmdCorrectionMask();
	else if (tixVCommand == VecVIdhwTau2Command::MEMORYSTATUS) cmd = getNewCmdMemoryStatus();
	else if (tixVCommand == VecVIdhwTau2Command::WRITENVFFCTABLE) cmd = getNewCmdWriteNvffcTable();
	else if (tixVCommand == VecVIdhwTau2Command::READMEMORY) cmd = getNewCmdReadMemory();
	else if (tixVCommand == VecVIdhwTau2Command::ERASEMEMORYBLOCK) cmd = getNewCmdEraseMemoryBlock();
	else if (tixVCommand == VecVIdhwTau2Command::GETNVMEMORYSIZE) cmd = getNewCmdGetNvMemorySize();
	else if (tixVCommand == VecVIdhwTau2Command::GETMEMORYADDRESS) cmd = getNewCmdGetMemoryAddress();
	else if (tixVCommand == VecVIdhwTau2Command::GAINSWITCHPARAMS) cmd = getNewCmdGainSwitchParams();
	else if (tixVCommand == VecVIdhwTau2Command::DDETHRESHOLD) cmd = getNewCmdDdeThreshold();
	else if (tixVCommand == VecVIdhwTau2Command::SPATIALTHRESHOLD) cmd = getNewCmdSpatialThreshold();
	else if (tixVCommand == VecVIdhwTau2Command::LENSRESPONSEPARAMS) cmd = getNewCmdLensResponseParams();

	return cmd;
};

Cmd* UntIdhwTau2::getNewCmdSetDefaults() {
	Cmd* cmd = new Cmd(VecVIdhwTau2Command::SETDEFAULTS, Cmd::VecVRettype::VOID);

	return cmd;
};

void UntIdhwTau2::setDefaults(
			const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSetDefaults();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "setDefaults", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwTau2::getNewCmdCameraReset() {
	Cmd* cmd = new Cmd(VecVIdhwTau2Command::CAMERARESET, Cmd::VecVRettype::VOID);

	return cmd;
};

void UntIdhwTau2::cameraReset(
			const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdCameraReset();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "cameraReset", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwTau2::getNewCmdRestoreFactoryDefault() {
	Cmd* cmd = new Cmd(VecVIdhwTau2Command::RESTOREFACTORYDEFAULT, Cmd::VecVRettype::VOID);

	return cmd;
};

void UntIdhwTau2::restoreFactoryDefault(
			const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdRestoreFactoryDefault();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "restoreFactoryDefault", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdSerialNumber* UntIdhwTau2::getNewCmdSerialNumber() {
	CmdSerialNumber* cmd = new CmdSerialNumber();

	cmd->addParRet("csn", Par::VecVType::UINT);
	cmd->addParRet("ssn", Par::VecVType::UINT);

	return cmd;
};

void UntIdhwTau2::serialNumber(
			uint& csn
			, uint& ssn
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSerialNumber();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "serialNumber", cmd->cref, "", "", true, true);
	else {
		csn = cmd->parsRet["csn"].getUint();
		ssn = cmd->parsRet["ssn"].getUint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdGetRevision* UntIdhwTau2::getNewCmdGetRevision() {
	CmdGetRevision* cmd = new CmdGetRevision();

	cmd->addParRet("swmaj", Par::VecVType::USMALLINT);
	cmd->addParRet("swmin", Par::VecVType::USMALLINT);
	cmd->addParRet("fwmaj", Par::VecVType::USMALLINT);
	cmd->addParRet("fwmin", Par::VecVType::USMALLINT);

	return cmd;
};

void UntIdhwTau2::getRevision(
			usmallint& swmaj
			, usmallint& swmin
			, usmallint& fwmaj
			, usmallint& fwmin
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetRevision();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getRevision", cmd->cref, "", "", true, true);
	else {
		swmaj = cmd->parsRet["swmaj"].getUsmallint();
		swmin = cmd->parsRet["swmin"].getUsmallint();
		fwmaj = cmd->parsRet["fwmaj"].getUsmallint();
		fwmin = cmd->parsRet["fwmin"].getUsmallint();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdBaudRate* UntIdhwTau2::getNewCmdBaudRate(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdBaudRate* cmd = new CmdBaudRate();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::baudRate(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdBaudRate(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "baudRate", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdGainMode* UntIdhwTau2::getNewCmdGainMode(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdGainMode* cmd = new CmdGainMode();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::gainMode(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGainMode(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "gainMode", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdFfcModeSelect* UntIdhwTau2::getNewCmdFfcModeSelect(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdFfcModeSelect* cmd = new CmdFfcModeSelect();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::ffcModeSelect(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdFfcModeSelect(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "ffcModeSelect", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwTau2::getNewCmdDoFfc() {
	Cmd* cmd = new Cmd(VecVIdhwTau2Command::DOFFC, Cmd::VecVRettype::VOID);

	return cmd;
};

void UntIdhwTau2::doFfc(
			const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdDoFfc();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "doFfc", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdFfcPeriod* UntIdhwTau2::getNewCmdFfcPeriod(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdFfcPeriod* cmd = new CmdFfcPeriod();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 4);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 4);

	return cmd;
};

void UntIdhwTau2::ffcPeriod(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdFfcPeriod(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "ffcPeriod", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdFfcTempDelta* UntIdhwTau2::getNewCmdFfcTempDelta(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdFfcTempDelta* cmd = new CmdFfcTempDelta();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 4);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 4);

	return cmd;
};

void UntIdhwTau2::ffcTempDelta(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdFfcTempDelta(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "ffcTempDelta", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdVideoMode* UntIdhwTau2::getNewCmdVideoMode(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdVideoMode* cmd = new CmdVideoMode();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::videoMode(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdVideoMode(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "videoMode", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdVideoPalette* UntIdhwTau2::getNewCmdVideoPalette(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdVideoPalette* cmd = new CmdVideoPalette();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::videoPalette(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdVideoPalette(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "videoPalette", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdVideoOrientation* UntIdhwTau2::getNewCmdVideoOrientation(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdVideoOrientation* cmd = new CmdVideoOrientation();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::videoOrientation(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdVideoOrientation(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "videoOrientation", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdDigitalOutputMode* UntIdhwTau2::getNewCmdDigitalOutputMode(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdDigitalOutputMode* cmd = new CmdDigitalOutputMode();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::digitalOutputMode(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdDigitalOutputMode(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "digitalOutputMode", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdAgcType* UntIdhwTau2::getNewCmdAgcType(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdAgcType* cmd = new CmdAgcType();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::agcType(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdAgcType(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "agcType", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdContrast* UntIdhwTau2::getNewCmdContrast(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdContrast* cmd = new CmdContrast();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::contrast(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdContrast(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "contrast", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdBrightness* UntIdhwTau2::getNewCmdBrightness(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdBrightness* cmd = new CmdBrightness();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::brightness(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdBrightness(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "brightness", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdBrightnessBias* UntIdhwTau2::getNewCmdBrightnessBias(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdBrightnessBias* cmd = new CmdBrightnessBias();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::brightnessBias(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdBrightnessBias(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "brightnessBias", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdLensNumber* UntIdhwTau2::getNewCmdLensNumber(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdLensNumber* cmd = new CmdLensNumber();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::lensNumber(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdLensNumber(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "lensNumber", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdSpotMeterMode* UntIdhwTau2::getNewCmdSpotMeterMode(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdSpotMeterMode* cmd = new CmdSpotMeterMode();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::spotMeterMode(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSpotMeterMode(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "spotMeterMode", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdReadSensor* UntIdhwTau2::getNewCmdReadSensor(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdReadSensor* cmd = new CmdReadSensor();

	cmd->addParInv("tx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setBlob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);

	return cmd;
};

void UntIdhwTau2::readSensor(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdReadSensor(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "readSensor", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdExternalSync* UntIdhwTau2::getNewCmdExternalSync(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdExternalSync* cmd = new CmdExternalSync();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::externalSync(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdExternalSync(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "externalSync", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdIsotherm* UntIdhwTau2::getNewCmdIsotherm(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdIsotherm* cmd = new CmdIsotherm();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::isotherm(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdIsotherm(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "isotherm", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdIsothermThresholds* UntIdhwTau2::getNewCmdIsothermThresholds(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdIsothermThresholds* cmd = new CmdIsothermThresholds();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 6);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 6);

	return cmd;
};

void UntIdhwTau2::isothermThresholds(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdIsothermThresholds(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "isothermThresholds", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdTestPattern* UntIdhwTau2::getNewCmdTestPattern(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdTestPattern* cmd = new CmdTestPattern();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::testPattern(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdTestPattern(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "testPattern", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdVideoColorMode* UntIdhwTau2::getNewCmdVideoColorMode(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdVideoColorMode* cmd = new CmdVideoColorMode();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::videoColorMode(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdVideoColorMode(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "videoColorMode", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdGetSpotMeter* UntIdhwTau2::getNewCmdGetSpotMeter() {
	CmdGetSpotMeter* cmd = new CmdGetSpotMeter();

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::getSpotMeter(
			unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetSpotMeter();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getSpotMeter", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdSpotDisplay* UntIdhwTau2::getNewCmdSpotDisplay(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdSpotDisplay* cmd = new CmdSpotDisplay();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::spotDisplay(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSpotDisplay(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "spotDisplay", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdDdeGain* UntIdhwTau2::getNewCmdDdeGain(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdDdeGain* cmd = new CmdDdeGain();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::ddeGain(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdDdeGain(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "ddeGain", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdSymbolControl* UntIdhwTau2::getNewCmdSymbolControl(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdSymbolControl* cmd = new CmdSymbolControl();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 46);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::symbolControl(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSymbolControl(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "symbolControl", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdSplashControl* UntIdhwTau2::getNewCmdSplashControl(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdSplashControl* cmd = new CmdSplashControl();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 4);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 4);

	return cmd;
};

void UntIdhwTau2::splashControl(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSplashControl(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "splashControl", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdEzoomControl* UntIdhwTau2::getNewCmdEzoomControl(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdEzoomControl* cmd = new CmdEzoomControl();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 4);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::ezoomControl(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdEzoomControl(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "ezoomControl", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdFfcWarnTime* UntIdhwTau2::getNewCmdFfcWarnTime(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdFfcWarnTime* cmd = new CmdFfcWarnTime();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::ffcWarnTime(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdFfcWarnTime(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "ffcWarnTime", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdAgcFilter* UntIdhwTau2::getNewCmdAgcFilter(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdAgcFilter* cmd = new CmdAgcFilter();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::agcFilter(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdAgcFilter(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "agcFilter", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdPlateauLevel* UntIdhwTau2::getNewCmdPlateauLevel(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdPlateauLevel* cmd = new CmdPlateauLevel();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::plateauLevel(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdPlateauLevel(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "plateauLevel", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdGetSpotMeterData* UntIdhwTau2::getNewCmdGetSpotMeterData(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdGetSpotMeterData* cmd = new CmdGetSpotMeterData();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 16);

	return cmd;
};

void UntIdhwTau2::getSpotMeterData(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetSpotMeterData(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getSpotMeterData", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdAgcRoi* UntIdhwTau2::getNewCmdAgcRoi(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdAgcRoi* cmd = new CmdAgcRoi();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);

	return cmd;
};

void UntIdhwTau2::agcRoi(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdAgcRoi(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "agcRoi", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdShutterTemp* UntIdhwTau2::getNewCmdShutterTemp(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdShutterTemp* cmd = new CmdShutterTemp();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::shutterTemp(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdShutterTemp(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "shutterTemp", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdAgcMidpoint* UntIdhwTau2::getNewCmdAgcMidpoint(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdAgcMidpoint* cmd = new CmdAgcMidpoint();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::agcMidpoint(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdAgcMidpoint(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "agcMidpoint", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdCameraPart* UntIdhwTau2::getNewCmdCameraPart() {
	CmdCameraPart* cmd = new CmdCameraPart();

	cmd->addParRet("serno", Par::VecVType::BLOB, NULL, NULL, NULL, 32);

	return cmd;
};

void UntIdhwTau2::cameraPart(
			unsigned char*& serno
			, size_t& sernolen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdCameraPart();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "cameraPart", cmd->cref, "", "", true, true);
	else {
		serno = cmd->parsRet["serno"].getBlob();
		sernolen = cmd->parsRet["serno"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdReadArrayAverage* UntIdhwTau2::getNewCmdReadArrayAverage() {
	CmdReadArrayAverage* cmd = new CmdReadArrayAverage();

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 4);

	return cmd;
};

void UntIdhwTau2::readArrayAverage(
			unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdReadArrayAverage();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "readArrayAverage", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdMaxAgcGain* UntIdhwTau2::getNewCmdMaxAgcGain(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdMaxAgcGain* cmd = new CmdMaxAgcGain();

	cmd->addParInv("tx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setBlob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::maxAgcGain(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdMaxAgcGain(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "maxAgcGain", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdPanAndTilt* UntIdhwTau2::getNewCmdPanAndTilt(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdPanAndTilt* cmd = new CmdPanAndTilt();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 4);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 4);

	return cmd;
};

void UntIdhwTau2::panAndTilt(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdPanAndTilt(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "panAndTilt", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdVideoStandard* UntIdhwTau2::getNewCmdVideoStandard(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdVideoStandard* cmd = new CmdVideoStandard();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::videoStandard(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdVideoStandard(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "videoStandard", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdShutterPosition* UntIdhwTau2::getNewCmdShutterPosition(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdShutterPosition* cmd = new CmdShutterPosition();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 34);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 34);

	return cmd;
};

void UntIdhwTau2::shutterPosition(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdShutterPosition(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "shutterPosition", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdTransferFrame* UntIdhwTau2::getNewCmdTransferFrame(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdTransferFrame* cmd = new CmdTransferFrame();

	cmd->addParInv("tx", Par::VecVType::BLOB, NULL, NULL, NULL, 4);

	cmd->parsInv["tx"].setBlob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 4);

	return cmd;
};

void UntIdhwTau2::transferFrame(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdTransferFrame(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "transferFrame", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdCorrectionMask* UntIdhwTau2::getNewCmdCorrectionMask(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdCorrectionMask* cmd = new CmdCorrectionMask();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::correctionMask(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdCorrectionMask(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "correctionMask", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdMemoryStatus* UntIdhwTau2::getNewCmdMemoryStatus() {
	CmdMemoryStatus* cmd = new CmdMemoryStatus();

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::memoryStatus(
			unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdMemoryStatus();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "memoryStatus", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

Cmd* UntIdhwTau2::getNewCmdWriteNvffcTable() {
	Cmd* cmd = new Cmd(VecVIdhwTau2Command::WRITENVFFCTABLE, Cmd::VecVRettype::VOID);

	return cmd;
};

void UntIdhwTau2::writeNvffcTable(
			const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdWriteNvffcTable();

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "writeNvffcTable", cmd->cref, "", "", true, true);
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdReadMemory* UntIdhwTau2::getNewCmdReadMemory(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdReadMemory* cmd = new CmdReadMemory();

	cmd->addParInv("tx", Par::VecVType::BLOB, NULL, NULL, NULL, 6);

	cmd->parsInv["tx"].setBlob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 192);

	return cmd;
};

void UntIdhwTau2::readMemory(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdReadMemory(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "readMemory", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdEraseMemoryBlock* UntIdhwTau2::getNewCmdEraseMemoryBlock(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdEraseMemoryBlock* cmd = new CmdEraseMemoryBlock();

	cmd->addParInv("tx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setBlob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::eraseMemoryBlock(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdEraseMemoryBlock(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "eraseMemoryBlock", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdGetNvMemorySize* UntIdhwTau2::getNewCmdGetNvMemorySize(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdGetNvMemorySize* cmd = new CmdGetNvMemorySize();

	cmd->addParInv("tx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setBlob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 8);

	return cmd;
};

void UntIdhwTau2::getNvMemorySize(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetNvMemorySize(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getNvMemorySize", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdGetMemoryAddress* UntIdhwTau2::getNewCmdGetMemoryAddress(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdGetMemoryAddress* cmd = new CmdGetMemoryAddress();

	cmd->addParInv("tx", Par::VecVType::BLOB, NULL, NULL, NULL, 4);

	cmd->parsInv["tx"].setBlob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 8);

	return cmd;
};

void UntIdhwTau2::getMemoryAddress(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGetMemoryAddress(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "getMemoryAddress", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdGainSwitchParams* UntIdhwTau2::getNewCmdGainSwitchParams(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdGainSwitchParams* cmd = new CmdGainSwitchParams();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 8);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 8);

	return cmd;
};

void UntIdhwTau2::gainSwitchParams(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdGainSwitchParams(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "gainSwitchParams", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdDdeThreshold* UntIdhwTau2::getNewCmdDdeThreshold(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdDdeThreshold* cmd = new CmdDdeThreshold();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::ddeThreshold(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdDdeThreshold(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "ddeThreshold", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdSpatialThreshold* UntIdhwTau2::getNewCmdSpatialThreshold(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdSpatialThreshold* cmd = new CmdSpatialThreshold();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 2);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::BLOB, NULL, NULL, NULL, 2);

	return cmd;
};

void UntIdhwTau2::spatialThreshold(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdSpatialThreshold(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "spatialThreshold", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getBlob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

UntIdhwTau2::CmdLensResponseParams* UntIdhwTau2::getNewCmdLensResponseParams(
			const unsigned char* tx
			, const size_t txlen
		) {
	CmdLensResponseParams* cmd = new CmdLensResponseParams();

	cmd->addParInv("tx", Par::VecVType::VBLOB, NULL, NULL, NULL, 6);

	cmd->parsInv["tx"].setVblob(tx, txlen);

	cmd->addParRet("rx", Par::VecVType::VBLOB, NULL, NULL, NULL, 4);

	return cmd;
};

void UntIdhwTau2::lensResponseParams(
			const unsigned char* tx
			, const size_t txlen
			, unsigned char*& rx
			, size_t& rxlen
			, const unsigned int to
		) {
	string msg;

	Cmd* cmd = getNewCmdLensResponseParams(tx, txlen);

	cmd->ixVTarget = ixVTarget;
	cmd->uref = uref;

	xchg->runCmd(cmd, to);

	if (cmd->err.tixDbeVAction != 0x00) msg = cmd->err.getMessage("", "lensResponseParams", cmd->cref, "", "", true, true);
	else {
		rx = cmd->parsRet["rx"].getVblob();
		rxlen = cmd->parsRet["rx"].getLen();
	};
	delete cmd;

	if (msg != "") throw(DbeException(msg));
};

