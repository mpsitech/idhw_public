/**
  * \file UntIdhwTau2.h
  * FLIR Tau2 unit (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWTAU2_H
#define UNTIDHWTAU2_H

#include "Idhw.h"

#include "UntIdhwTau2_vecs.h"

/**
	* UntIdhwTau2
	*/
class UntIdhwTau2 : public UntIdhw {

public:
	/**
		* CmdSerialNumber (full: CmdIdhwTau2SerialNumber)
		*/
	class CmdSerialNumber : public Cmd {

	public:
		CmdSerialNumber();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const uint csn, const uint ssn);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint csn, const uint ssn), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetRevision (full: CmdIdhwTau2GetRevision)
		*/
	class CmdGetRevision : public Cmd {

	public:
		CmdGetRevision();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint swmaj, const usmallint swmin, const usmallint fwmaj, const usmallint fwmin);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint swmaj, const usmallint swmin, const usmallint fwmaj, const usmallint fwmin), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdBaudRate (full: CmdIdhwTau2BaudRate)
		*/
	class CmdBaudRate : public Cmd {

	public:
		CmdBaudRate();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGainMode (full: CmdIdhwTau2GainMode)
		*/
	class CmdGainMode : public Cmd {

	public:
		CmdGainMode();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdFfcModeSelect (full: CmdIdhwTau2FfcModeSelect)
		*/
	class CmdFfcModeSelect : public Cmd {

	public:
		CmdFfcModeSelect();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdFfcPeriod (full: CmdIdhwTau2FfcPeriod)
		*/
	class CmdFfcPeriod : public Cmd {

	public:
		CmdFfcPeriod();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdFfcTempDelta (full: CmdIdhwTau2FfcTempDelta)
		*/
	class CmdFfcTempDelta : public Cmd {

	public:
		CmdFfcTempDelta();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdVideoMode (full: CmdIdhwTau2VideoMode)
		*/
	class CmdVideoMode : public Cmd {

	public:
		CmdVideoMode();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdVideoPalette (full: CmdIdhwTau2VideoPalette)
		*/
	class CmdVideoPalette : public Cmd {

	public:
		CmdVideoPalette();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdVideoOrientation (full: CmdIdhwTau2VideoOrientation)
		*/
	class CmdVideoOrientation : public Cmd {

	public:
		CmdVideoOrientation();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdDigitalOutputMode (full: CmdIdhwTau2DigitalOutputMode)
		*/
	class CmdDigitalOutputMode : public Cmd {

	public:
		CmdDigitalOutputMode();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdAgcType (full: CmdIdhwTau2AgcType)
		*/
	class CmdAgcType : public Cmd {

	public:
		CmdAgcType();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdContrast (full: CmdIdhwTau2Contrast)
		*/
	class CmdContrast : public Cmd {

	public:
		CmdContrast();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdBrightness (full: CmdIdhwTau2Brightness)
		*/
	class CmdBrightness : public Cmd {

	public:
		CmdBrightness();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdBrightnessBias (full: CmdIdhwTau2BrightnessBias)
		*/
	class CmdBrightnessBias : public Cmd {

	public:
		CmdBrightnessBias();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdLensNumber (full: CmdIdhwTau2LensNumber)
		*/
	class CmdLensNumber : public Cmd {

	public:
		CmdLensNumber();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdSpotMeterMode (full: CmdIdhwTau2SpotMeterMode)
		*/
	class CmdSpotMeterMode : public Cmd {

	public:
		CmdSpotMeterMode();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdReadSensor (full: CmdIdhwTau2ReadSensor)
		*/
	class CmdReadSensor : public Cmd {

	public:
		CmdReadSensor();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdExternalSync (full: CmdIdhwTau2ExternalSync)
		*/
	class CmdExternalSync : public Cmd {

	public:
		CmdExternalSync();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdIsotherm (full: CmdIdhwTau2Isotherm)
		*/
	class CmdIsotherm : public Cmd {

	public:
		CmdIsotherm();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdIsothermThresholds (full: CmdIdhwTau2IsothermThresholds)
		*/
	class CmdIsothermThresholds : public Cmd {

	public:
		CmdIsothermThresholds();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdTestPattern (full: CmdIdhwTau2TestPattern)
		*/
	class CmdTestPattern : public Cmd {

	public:
		CmdTestPattern();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdVideoColorMode (full: CmdIdhwTau2VideoColorMode)
		*/
	class CmdVideoColorMode : public Cmd {

	public:
		CmdVideoColorMode();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetSpotMeter (full: CmdIdhwTau2GetSpotMeter)
		*/
	class CmdGetSpotMeter : public Cmd {

	public:
		CmdGetSpotMeter();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdSpotDisplay (full: CmdIdhwTau2SpotDisplay)
		*/
	class CmdSpotDisplay : public Cmd {

	public:
		CmdSpotDisplay();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdDdeGain (full: CmdIdhwTau2DdeGain)
		*/
	class CmdDdeGain : public Cmd {

	public:
		CmdDdeGain();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdSymbolControl (full: CmdIdhwTau2SymbolControl)
		*/
	class CmdSymbolControl : public Cmd {

	public:
		CmdSymbolControl();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdSplashControl (full: CmdIdhwTau2SplashControl)
		*/
	class CmdSplashControl : public Cmd {

	public:
		CmdSplashControl();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdEzoomControl (full: CmdIdhwTau2EzoomControl)
		*/
	class CmdEzoomControl : public Cmd {

	public:
		CmdEzoomControl();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdFfcWarnTime (full: CmdIdhwTau2FfcWarnTime)
		*/
	class CmdFfcWarnTime : public Cmd {

	public:
		CmdFfcWarnTime();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdAgcFilter (full: CmdIdhwTau2AgcFilter)
		*/
	class CmdAgcFilter : public Cmd {

	public:
		CmdAgcFilter();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdPlateauLevel (full: CmdIdhwTau2PlateauLevel)
		*/
	class CmdPlateauLevel : public Cmd {

	public:
		CmdPlateauLevel();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetSpotMeterData (full: CmdIdhwTau2GetSpotMeterData)
		*/
	class CmdGetSpotMeterData : public Cmd {

	public:
		CmdGetSpotMeterData();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdAgcRoi (full: CmdIdhwTau2AgcRoi)
		*/
	class CmdAgcRoi : public Cmd {

	public:
		CmdAgcRoi();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdShutterTemp (full: CmdIdhwTau2ShutterTemp)
		*/
	class CmdShutterTemp : public Cmd {

	public:
		CmdShutterTemp();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdAgcMidpoint (full: CmdIdhwTau2AgcMidpoint)
		*/
	class CmdAgcMidpoint : public Cmd {

	public:
		CmdAgcMidpoint();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdCameraPart (full: CmdIdhwTau2CameraPart)
		*/
	class CmdCameraPart : public Cmd {

	public:
		CmdCameraPart();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* serno, const size_t sernolen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* serno, const size_t sernolen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdReadArrayAverage (full: CmdIdhwTau2ReadArrayAverage)
		*/
	class CmdReadArrayAverage : public Cmd {

	public:
		CmdReadArrayAverage();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdMaxAgcGain (full: CmdIdhwTau2MaxAgcGain)
		*/
	class CmdMaxAgcGain : public Cmd {

	public:
		CmdMaxAgcGain();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdPanAndTilt (full: CmdIdhwTau2PanAndTilt)
		*/
	class CmdPanAndTilt : public Cmd {

	public:
		CmdPanAndTilt();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdVideoStandard (full: CmdIdhwTau2VideoStandard)
		*/
	class CmdVideoStandard : public Cmd {

	public:
		CmdVideoStandard();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdShutterPosition (full: CmdIdhwTau2ShutterPosition)
		*/
	class CmdShutterPosition : public Cmd {

	public:
		CmdShutterPosition();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdTransferFrame (full: CmdIdhwTau2TransferFrame)
		*/
	class CmdTransferFrame : public Cmd {

	public:
		CmdTransferFrame();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdCorrectionMask (full: CmdIdhwTau2CorrectionMask)
		*/
	class CmdCorrectionMask : public Cmd {

	public:
		CmdCorrectionMask();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdMemoryStatus (full: CmdIdhwTau2MemoryStatus)
		*/
	class CmdMemoryStatus : public Cmd {

	public:
		CmdMemoryStatus();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdReadMemory (full: CmdIdhwTau2ReadMemory)
		*/
	class CmdReadMemory : public Cmd {

	public:
		CmdReadMemory();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdEraseMemoryBlock (full: CmdIdhwTau2EraseMemoryBlock)
		*/
	class CmdEraseMemoryBlock : public Cmd {

	public:
		CmdEraseMemoryBlock();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetNvMemorySize (full: CmdIdhwTau2GetNvMemorySize)
		*/
	class CmdGetNvMemorySize : public Cmd {

	public:
		CmdGetNvMemorySize();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetMemoryAddress (full: CmdIdhwTau2GetMemoryAddress)
		*/
	class CmdGetMemoryAddress : public Cmd {

	public:
		CmdGetMemoryAddress();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGainSwitchParams (full: CmdIdhwTau2GainSwitchParams)
		*/
	class CmdGainSwitchParams : public Cmd {

	public:
		CmdGainSwitchParams();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdDdeThreshold (full: CmdIdhwTau2DdeThreshold)
		*/
	class CmdDdeThreshold : public Cmd {

	public:
		CmdDdeThreshold();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdSpatialThreshold (full: CmdIdhwTau2SpatialThreshold)
		*/
	class CmdSpatialThreshold : public Cmd {

	public:
		CmdSpatialThreshold();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdLensResponseParams (full: CmdIdhwTau2LensResponseParams)
		*/
	class CmdLensResponseParams : public Cmd {

	public:
		CmdLensResponseParams();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* rx, const size_t rxlen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

public:
	UntIdhwTau2(XchgIdhw* xchg, const uint ixVTarget);
	~UntIdhwTau2();

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetDefaults();
	void setDefaults(const unsigned int to = 0);

	static Cmd* getNewCmdCameraReset();
	void cameraReset(const unsigned int to = 0);

	static Cmd* getNewCmdRestoreFactoryDefault();
	void restoreFactoryDefault(const unsigned int to = 0);

	static CmdSerialNumber* getNewCmdSerialNumber();
	void serialNumber(uint& csn, uint& ssn, const unsigned int to = 0);

	static CmdGetRevision* getNewCmdGetRevision();
	void getRevision(usmallint& swmaj, usmallint& swmin, usmallint& fwmaj, usmallint& fwmin, const unsigned int to = 0);

	static CmdBaudRate* getNewCmdBaudRate(const unsigned char* tx = NULL, const size_t txlen = 0);
	void baudRate(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdGainMode* getNewCmdGainMode(const unsigned char* tx = NULL, const size_t txlen = 0);
	void gainMode(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdFfcModeSelect* getNewCmdFfcModeSelect(const unsigned char* tx = NULL, const size_t txlen = 0);
	void ffcModeSelect(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static Cmd* getNewCmdDoFfc();
	void doFfc(const unsigned int to = 0);

	static CmdFfcPeriod* getNewCmdFfcPeriod(const unsigned char* tx = NULL, const size_t txlen = 0);
	void ffcPeriod(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdFfcTempDelta* getNewCmdFfcTempDelta(const unsigned char* tx = NULL, const size_t txlen = 0);
	void ffcTempDelta(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdVideoMode* getNewCmdVideoMode(const unsigned char* tx = NULL, const size_t txlen = 0);
	void videoMode(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdVideoPalette* getNewCmdVideoPalette(const unsigned char* tx = NULL, const size_t txlen = 0);
	void videoPalette(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdVideoOrientation* getNewCmdVideoOrientation(const unsigned char* tx = NULL, const size_t txlen = 0);
	void videoOrientation(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdDigitalOutputMode* getNewCmdDigitalOutputMode(const unsigned char* tx = NULL, const size_t txlen = 0);
	void digitalOutputMode(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdAgcType* getNewCmdAgcType(const unsigned char* tx = NULL, const size_t txlen = 0);
	void agcType(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdContrast* getNewCmdContrast(const unsigned char* tx = NULL, const size_t txlen = 0);
	void contrast(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdBrightness* getNewCmdBrightness(const unsigned char* tx = NULL, const size_t txlen = 0);
	void brightness(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdBrightnessBias* getNewCmdBrightnessBias(const unsigned char* tx = NULL, const size_t txlen = 0);
	void brightnessBias(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdLensNumber* getNewCmdLensNumber(const unsigned char* tx = NULL, const size_t txlen = 0);
	void lensNumber(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdSpotMeterMode* getNewCmdSpotMeterMode(const unsigned char* tx = NULL, const size_t txlen = 0);
	void spotMeterMode(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdReadSensor* getNewCmdReadSensor(const unsigned char* tx = NULL, const size_t txlen = 0);
	void readSensor(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdExternalSync* getNewCmdExternalSync(const unsigned char* tx = NULL, const size_t txlen = 0);
	void externalSync(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdIsotherm* getNewCmdIsotherm(const unsigned char* tx = NULL, const size_t txlen = 0);
	void isotherm(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdIsothermThresholds* getNewCmdIsothermThresholds(const unsigned char* tx = NULL, const size_t txlen = 0);
	void isothermThresholds(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdTestPattern* getNewCmdTestPattern(const unsigned char* tx = NULL, const size_t txlen = 0);
	void testPattern(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdVideoColorMode* getNewCmdVideoColorMode(const unsigned char* tx = NULL, const size_t txlen = 0);
	void videoColorMode(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdGetSpotMeter* getNewCmdGetSpotMeter();
	void getSpotMeter(unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdSpotDisplay* getNewCmdSpotDisplay(const unsigned char* tx = NULL, const size_t txlen = 0);
	void spotDisplay(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdDdeGain* getNewCmdDdeGain(const unsigned char* tx = NULL, const size_t txlen = 0);
	void ddeGain(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdSymbolControl* getNewCmdSymbolControl(const unsigned char* tx = NULL, const size_t txlen = 0);
	void symbolControl(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdSplashControl* getNewCmdSplashControl(const unsigned char* tx = NULL, const size_t txlen = 0);
	void splashControl(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdEzoomControl* getNewCmdEzoomControl(const unsigned char* tx = NULL, const size_t txlen = 0);
	void ezoomControl(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdFfcWarnTime* getNewCmdFfcWarnTime(const unsigned char* tx = NULL, const size_t txlen = 0);
	void ffcWarnTime(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdAgcFilter* getNewCmdAgcFilter(const unsigned char* tx = NULL, const size_t txlen = 0);
	void agcFilter(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdPlateauLevel* getNewCmdPlateauLevel(const unsigned char* tx = NULL, const size_t txlen = 0);
	void plateauLevel(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdGetSpotMeterData* getNewCmdGetSpotMeterData(const unsigned char* tx = NULL, const size_t txlen = 0);
	void getSpotMeterData(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdAgcRoi* getNewCmdAgcRoi(const unsigned char* tx = NULL, const size_t txlen = 0);
	void agcRoi(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdShutterTemp* getNewCmdShutterTemp(const unsigned char* tx = NULL, const size_t txlen = 0);
	void shutterTemp(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdAgcMidpoint* getNewCmdAgcMidpoint(const unsigned char* tx = NULL, const size_t txlen = 0);
	void agcMidpoint(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdCameraPart* getNewCmdCameraPart();
	void cameraPart(unsigned char*& serno, size_t& sernolen, const unsigned int to = 0);

	static CmdReadArrayAverage* getNewCmdReadArrayAverage();
	void readArrayAverage(unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdMaxAgcGain* getNewCmdMaxAgcGain(const unsigned char* tx = NULL, const size_t txlen = 0);
	void maxAgcGain(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdPanAndTilt* getNewCmdPanAndTilt(const unsigned char* tx = NULL, const size_t txlen = 0);
	void panAndTilt(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdVideoStandard* getNewCmdVideoStandard(const unsigned char* tx = NULL, const size_t txlen = 0);
	void videoStandard(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdShutterPosition* getNewCmdShutterPosition(const unsigned char* tx = NULL, const size_t txlen = 0);
	void shutterPosition(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdTransferFrame* getNewCmdTransferFrame(const unsigned char* tx = NULL, const size_t txlen = 0);
	void transferFrame(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdCorrectionMask* getNewCmdCorrectionMask(const unsigned char* tx = NULL, const size_t txlen = 0);
	void correctionMask(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdMemoryStatus* getNewCmdMemoryStatus();
	void memoryStatus(unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static Cmd* getNewCmdWriteNvffcTable();
	void writeNvffcTable(const unsigned int to = 0);

	static CmdReadMemory* getNewCmdReadMemory(const unsigned char* tx = NULL, const size_t txlen = 0);
	void readMemory(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdEraseMemoryBlock* getNewCmdEraseMemoryBlock(const unsigned char* tx = NULL, const size_t txlen = 0);
	void eraseMemoryBlock(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdGetNvMemorySize* getNewCmdGetNvMemorySize(const unsigned char* tx = NULL, const size_t txlen = 0);
	void getNvMemorySize(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdGetMemoryAddress* getNewCmdGetMemoryAddress(const unsigned char* tx = NULL, const size_t txlen = 0);
	void getMemoryAddress(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdGainSwitchParams* getNewCmdGainSwitchParams(const unsigned char* tx = NULL, const size_t txlen = 0);
	void gainSwitchParams(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdDdeThreshold* getNewCmdDdeThreshold(const unsigned char* tx = NULL, const size_t txlen = 0);
	void ddeThreshold(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdSpatialThreshold* getNewCmdSpatialThreshold(const unsigned char* tx = NULL, const size_t txlen = 0);
	void spatialThreshold(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

	static CmdLensResponseParams* getNewCmdLensResponseParams(const unsigned char* tx = NULL, const size_t txlen = 0);
	void lensResponseParams(const unsigned char* tx, const size_t txlen, unsigned char*& rx, size_t& rxlen, const unsigned int to = 0);

};

#endif

