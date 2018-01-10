/**
  * \file UntIdhwTau2_vecs.h
  * FLIR Tau2 unit vectors (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWTAU2_VECS_H
#define UNTIDHWTAU2_VECS_H

#include <sbecore/Xmlio.h>

using namespace Xmlio;

/**
	* VecVIdhwTau2Command
	*/
namespace VecVIdhwTau2Command {
	const utinyint SETDEFAULTS = 0x01;
	const utinyint CAMERARESET = 0x02;
	const utinyint RESTOREFACTORYDEFAULT = 0x03;
	const utinyint SERIALNUMBER = 0x04;
	const utinyint GETREVISION = 0x05;
	const utinyint BAUDRATE = 0x07;
	const utinyint GAINMODE = 0x0A;
	const utinyint FFCMODESELECT = 0x0B;
	const utinyint DOFFC = 0x0C;
	const utinyint FFCPERIOD = 0x0D;
	const utinyint FFCTEMPDELTA = 0x0E;
	const utinyint VIDEOMODE = 0x0F;
	const utinyint VIDEOPALETTE = 0x10;
	const utinyint VIDEOORIENTATION = 0x11;
	const utinyint DIGITALOUTPUTMODE = 0x12;
	const utinyint AGCTYPE = 0x13;
	const utinyint CONTRAST = 0x14;
	const utinyint BRIGHTNESS = 0x15;
	const utinyint BRIGHTNESSBIAS = 0x18;
	const utinyint LENSNUMBER = 0x1E;
	const utinyint SPOTMETERMODE = 0x1F;
	const utinyint READSENSOR = 0x20;
	const utinyint EXTERNALSYNC = 0x21;
	const utinyint ISOTHERM = 0x22;
	const utinyint ISOTHERMTHRESHOLDS = 0x23;
	const utinyint TESTPATTERN = 0x25;
	const utinyint VIDEOCOLORMODE = 0x26;
	const utinyint GETSPOTMETER = 0x2A;
	const utinyint SPOTDISPLAY = 0x2B;
	const utinyint DDEGAIN = 0x2C;
	const utinyint SYMBOLCONTROL = 0x2F;
	const utinyint SPLASHCONTROL = 0x31;
	const utinyint EZOOMCONTROL = 0x32;
	const utinyint FFCWARNTIME = 0x3C;
	const utinyint AGCFILTER = 0x3E;
	const utinyint PLATEAULEVEL = 0x3F;
	const utinyint GETSPOTMETERDATA = 0x43;
	const utinyint AGCROI = 0x4C;
	const utinyint SHUTTERTEMP = 0x4D;
	const utinyint AGCMIDPOINT = 0x55;
	const utinyint CAMERAPART = 0x66;
	const utinyint READARRAYAVERAGE = 0x68;
	const utinyint MAXAGCGAIN = 0x6A;
	const utinyint PANANDTILT = 0x70;
	const utinyint VIDEOSTANDARD = 0x72;
	const utinyint SHUTTERPOSITION = 0x79;
	const utinyint TRANSFERFRAME = 0x82;
	const utinyint CORRECTIONMASK = 0xB1;
	const utinyint MEMORYSTATUS = 0xC4;
	const utinyint WRITENVFFCTABLE = 0xC6;
	const utinyint READMEMORY = 0xD2;
	const utinyint ERASEMEMORYBLOCK = 0xD4;
	const utinyint GETNVMEMORYSIZE = 0xD5;
	const utinyint GETMEMORYADDRESS = 0xD6;
	const utinyint GAINSWITCHPARAMS = 0xDB;
	const utinyint DDETHRESHOLD = 0xE2;
	const utinyint SPATIALTHRESHOLD = 0xE3;
	const utinyint LENSRESPONSEPARAMS = 0xE5;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	void fillFeed(Feed& feed);
};

#endif

