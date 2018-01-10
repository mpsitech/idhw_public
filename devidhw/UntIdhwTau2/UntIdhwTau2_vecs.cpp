/**
  * \file UntIdhwTau2_vecs.cpp
  * FLIR Tau2 unit vectors (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwTau2_vecs.h"

/******************************************************************************
 namespace VecVIdhwTau2Command
 ******************************************************************************/

utinyint VecVIdhwTau2Command::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setdefaults") return SETDEFAULTS;
	else if (s == "camerareset") return CAMERARESET;
	else if (s == "restorefactorydefault") return RESTOREFACTORYDEFAULT;
	else if (s == "serialnumber") return SERIALNUMBER;
	else if (s == "getrevision") return GETREVISION;
	else if (s == "baudrate") return BAUDRATE;
	else if (s == "gainmode") return GAINMODE;
	else if (s == "ffcmodeselect") return FFCMODESELECT;
	else if (s == "doffc") return DOFFC;
	else if (s == "ffcperiod") return FFCPERIOD;
	else if (s == "ffctempdelta") return FFCTEMPDELTA;
	else if (s == "videomode") return VIDEOMODE;
	else if (s == "videopalette") return VIDEOPALETTE;
	else if (s == "videoorientation") return VIDEOORIENTATION;
	else if (s == "digitaloutputmode") return DIGITALOUTPUTMODE;
	else if (s == "agctype") return AGCTYPE;
	else if (s == "contrast") return CONTRAST;
	else if (s == "brightness") return BRIGHTNESS;
	else if (s == "brightnessbias") return BRIGHTNESSBIAS;
	else if (s == "lensnumber") return LENSNUMBER;
	else if (s == "spotmetermode") return SPOTMETERMODE;
	else if (s == "readsensor") return READSENSOR;
	else if (s == "externalsync") return EXTERNALSYNC;
	else if (s == "isotherm") return ISOTHERM;
	else if (s == "isothermthresholds") return ISOTHERMTHRESHOLDS;
	else if (s == "testpattern") return TESTPATTERN;
	else if (s == "videocolormode") return VIDEOCOLORMODE;
	else if (s == "getspotmeter") return GETSPOTMETER;
	else if (s == "spotdisplay") return SPOTDISPLAY;
	else if (s == "ddegain") return DDEGAIN;
	else if (s == "symbolcontrol") return SYMBOLCONTROL;
	else if (s == "splashcontrol") return SPLASHCONTROL;
	else if (s == "ezoomcontrol") return EZOOMCONTROL;
	else if (s == "ffcwarntime") return FFCWARNTIME;
	else if (s == "agcfilter") return AGCFILTER;
	else if (s == "plateaulevel") return PLATEAULEVEL;
	else if (s == "getspotmeterdata") return GETSPOTMETERDATA;
	else if (s == "agcroi") return AGCROI;
	else if (s == "shuttertemp") return SHUTTERTEMP;
	else if (s == "agcmidpoint") return AGCMIDPOINT;
	else if (s == "camerapart") return CAMERAPART;
	else if (s == "readarrayaverage") return READARRAYAVERAGE;
	else if (s == "maxagcgain") return MAXAGCGAIN;
	else if (s == "panandtilt") return PANANDTILT;
	else if (s == "videostandard") return VIDEOSTANDARD;
	else if (s == "shutterposition") return SHUTTERPOSITION;
	else if (s == "transferframe") return TRANSFERFRAME;
	else if (s == "correctionmask") return CORRECTIONMASK;
	else if (s == "memorystatus") return MEMORYSTATUS;
	else if (s == "writenvffctable") return WRITENVFFCTABLE;
	else if (s == "readmemory") return READMEMORY;
	else if (s == "erasememoryblock") return ERASEMEMORYBLOCK;
	else if (s == "getnvmemorysize") return GETNVMEMORYSIZE;
	else if (s == "getmemoryaddress") return GETMEMORYADDRESS;
	else if (s == "gainswitchparams") return GAINSWITCHPARAMS;
	else if (s == "ddethreshold") return DDETHRESHOLD;
	else if (s == "spatialthreshold") return SPATIALTHRESHOLD;
	else if (s == "lensresponseparams") return LENSRESPONSEPARAMS;

	return(0);
};

string VecVIdhwTau2Command::getSref(
			const utinyint tix
		) {
	if (tix == SETDEFAULTS) return("setDefaults");
	else if (tix == CAMERARESET) return("cameraReset");
	else if (tix == RESTOREFACTORYDEFAULT) return("restoreFactoryDefault");
	else if (tix == SERIALNUMBER) return("serialNumber");
	else if (tix == GETREVISION) return("getRevision");
	else if (tix == BAUDRATE) return("baudRate");
	else if (tix == GAINMODE) return("gainMode");
	else if (tix == FFCMODESELECT) return("ffcModeSelect");
	else if (tix == DOFFC) return("doFfc");
	else if (tix == FFCPERIOD) return("ffcPeriod");
	else if (tix == FFCTEMPDELTA) return("ffcTempDelta");
	else if (tix == VIDEOMODE) return("videoMode");
	else if (tix == VIDEOPALETTE) return("videoPalette");
	else if (tix == VIDEOORIENTATION) return("videoOrientation");
	else if (tix == DIGITALOUTPUTMODE) return("digitalOutputMode");
	else if (tix == AGCTYPE) return("agcType");
	else if (tix == CONTRAST) return("contrast");
	else if (tix == BRIGHTNESS) return("brightness");
	else if (tix == BRIGHTNESSBIAS) return("brightnessBias");
	else if (tix == LENSNUMBER) return("lensNumber");
	else if (tix == SPOTMETERMODE) return("spotMeterMode");
	else if (tix == READSENSOR) return("readSensor");
	else if (tix == EXTERNALSYNC) return("externalSync");
	else if (tix == ISOTHERM) return("isotherm");
	else if (tix == ISOTHERMTHRESHOLDS) return("isothermThresholds");
	else if (tix == TESTPATTERN) return("testPattern");
	else if (tix == VIDEOCOLORMODE) return("videoColorMode");
	else if (tix == GETSPOTMETER) return("getSpotMeter");
	else if (tix == SPOTDISPLAY) return("spotDisplay");
	else if (tix == DDEGAIN) return("ddeGain");
	else if (tix == SYMBOLCONTROL) return("symbolControl");
	else if (tix == SPLASHCONTROL) return("splashControl");
	else if (tix == EZOOMCONTROL) return("ezoomControl");
	else if (tix == FFCWARNTIME) return("ffcWarnTime");
	else if (tix == AGCFILTER) return("agcFilter");
	else if (tix == PLATEAULEVEL) return("plateauLevel");
	else if (tix == GETSPOTMETERDATA) return("getSpotMeterData");
	else if (tix == AGCROI) return("agcRoi");
	else if (tix == SHUTTERTEMP) return("shutterTemp");
	else if (tix == AGCMIDPOINT) return("agcMidpoint");
	else if (tix == CAMERAPART) return("cameraPart");
	else if (tix == READARRAYAVERAGE) return("readArrayAverage");
	else if (tix == MAXAGCGAIN) return("maxAgcGain");
	else if (tix == PANANDTILT) return("panAndTilt");
	else if (tix == VIDEOSTANDARD) return("videoStandard");
	else if (tix == SHUTTERPOSITION) return("shutterPosition");
	else if (tix == TRANSFERFRAME) return("transferFrame");
	else if (tix == CORRECTIONMASK) return("correctionMask");
	else if (tix == MEMORYSTATUS) return("memoryStatus");
	else if (tix == WRITENVFFCTABLE) return("writeNvffcTable");
	else if (tix == READMEMORY) return("readMemory");
	else if (tix == ERASEMEMORYBLOCK) return("eraseMemoryBlock");
	else if (tix == GETNVMEMORYSIZE) return("getNvMemorySize");
	else if (tix == GETMEMORYADDRESS) return("getMemoryAddress");
	else if (tix == GAINSWITCHPARAMS) return("gainSwitchParams");
	else if (tix == DDETHRESHOLD) return("ddeThreshold");
	else if (tix == SPATIALTHRESHOLD) return("spatialThreshold");
	else if (tix == LENSRESPONSEPARAMS) return("lensResponseParams");

	return("");
};

void VecVIdhwTau2Command::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {SETDEFAULTS,CAMERARESET,RESTOREFACTORYDEFAULT,SERIALNUMBER,GETREVISION,BAUDRATE,GAINMODE,FFCMODESELECT,DOFFC,FFCPERIOD,FFCTEMPDELTA,VIDEOMODE,VIDEOPALETTE,VIDEOORIENTATION,DIGITALOUTPUTMODE,AGCTYPE,CONTRAST,BRIGHTNESS,BRIGHTNESSBIAS,LENSNUMBER,SPOTMETERMODE,READSENSOR,EXTERNALSYNC,ISOTHERM,ISOTHERMTHRESHOLDS,TESTPATTERN,VIDEOCOLORMODE,GETSPOTMETER,SPOTDISPLAY,DDEGAIN,SYMBOLCONTROL,SPLASHCONTROL,EZOOMCONTROL,FFCWARNTIME,AGCFILTER,PLATEAULEVEL,GETSPOTMETERDATA,AGCROI,SHUTTERTEMP,AGCMIDPOINT,CAMERAPART,READARRAYAVERAGE,MAXAGCGAIN,PANANDTILT,VIDEOSTANDARD,SHUTTERPOSITION,TRANSFERFRAME,CORRECTIONMASK,MEMORYSTATUS,WRITENVFFCTABLE,READMEMORY,ERASEMEMORYBLOCK,GETNVMEMORYSIZE,GETMEMORYADDRESS,GAINSWITCHPARAMS,DDETHRESHOLD,SPATIALTHRESHOLD,LENSRESPONSEPARAMS};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

