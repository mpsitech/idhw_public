/**
  * \file CtrIdhwIcm2Temp.h
  * temp controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWICM2TEMP_H
#define CTRIDHWICM2TEMP_H

#include "Idhw.h"

#define VecVIdhwIcm2TempCommand CtrIdhwIcm2Temp::VecVCommand
#define VecVIdhwIcm2TempFanmode CtrIdhwIcm2Temp::VecVFanmode

/**
	* CtrIdhwIcm2Temp
	*/
class CtrIdhwIcm2Temp : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwIcm2TempCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETFAN = 0x00;
		static const utinyint SETRNG = 0x01;
		static const utinyint SETTRGNTC = 0x02;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

	/**
		* VecVFanmode (full: VecVIdhwIcm2TempFanmode)
		*/
	class VecVFanmode {

	public:
		static const utinyint OFF = 0x00;
		static const utinyint OFFACQ = 0x01;
		static const utinyint ON = 0x02;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwIcm2Temp(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x08;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetFan(const utinyint tixVFanmode = 0, const usmallint ptlow = 0, const usmallint pthigh = 0);
	void setFan(const utinyint tixVFanmode, const usmallint ptlow, const usmallint pthigh, const unsigned int to = 0);

	static Cmd* getNewCmdSetRng(const bool rng = false);
	void setRng(const bool rng, const unsigned int to = 0);

	static Cmd* getNewCmdSetTrgNtc(const usmallint ntc = 0);
	void setTrgNtc(const usmallint ntc, const unsigned int to = 0);

};

#endif

