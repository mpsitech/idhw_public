/**
  * \file CtrIdhwIcm2Roic.h
  * roic controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWICM2ROIC_H
#define CTRIDHWICM2ROIC_H

#include "Idhw.h"

#define VecVIdhwIcm2RoicBias CtrIdhwIcm2Roic::VecVBias
#define VecVIdhwIcm2RoicCommand CtrIdhwIcm2Roic::VecVCommand

/**
	* CtrIdhwIcm2Roic
	*/
class CtrIdhwIcm2Roic : public CtrIdhw {

public:
	/**
		* VecVBias (full: VecVIdhwIcm2RoicBias)
		*/
	class VecVBias {

	public:
		static const utinyint BASELINE = 0x00;
		static const utinyint DECR16 = 0x01;
		static const utinyint DECR32 = 0x02;
		static const utinyint DECR48 = 0x03;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

	/**
		* VecVCommand (full: VecVIdhwIcm2RoicCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETCMTCLK = 0x00;
		static const utinyint SETMODE = 0x01;
		static const utinyint SETPIXEL = 0x02;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwIcm2Roic(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x05;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetCmtclk(const bool cmtrng = false, const usmallint Tcmtclk = 0, const usmallint tdphi = 0);
	void setCmtclk(const bool cmtrng, const usmallint Tcmtclk, const usmallint tdphi, const unsigned int to = 0);

	static Cmd* getNewCmdSetMode(const bool fullfrmNotSngpix = false, const utinyint tixVBias = 0, const bool acgain300not100 = false, const bool dcgain40not20 = false, const bool ampbwDecr = false);
	void setMode(const bool fullfrmNotSngpix, const utinyint tixVBias, const bool acgain300not100, const bool dcgain40not20, const bool ampbwDecr, const unsigned int to = 0);

	static Cmd* getNewCmdSetPixel(const utinyint row = 0, const utinyint col = 0);
	void setPixel(const utinyint row, const utinyint col, const unsigned int to = 0);

};

#endif

