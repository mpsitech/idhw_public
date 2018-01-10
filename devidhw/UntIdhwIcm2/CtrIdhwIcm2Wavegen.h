/**
  * \file CtrIdhwIcm2Wavegen.h
  * wavegen controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWICM2WAVEGEN_H
#define CTRIDHWICM2WAVEGEN_H

#include "Idhw.h"

#define VecVIdhwIcm2WavegenCommand CtrIdhwIcm2Wavegen::VecVCommand

/**
	* CtrIdhwIcm2Wavegen
	*/
class CtrIdhwIcm2Wavegen : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwIcm2WavegenCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETRNG = 0x00;
		static const utinyint SETWAVE = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwIcm2Wavegen(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x0C;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetRng(const bool rng = false);
	void setRng(const bool rng, const unsigned int to = 0);

	static Cmd* getNewCmdSetWave(const usmallint tdly = 0, const usmallint Nsmp = 0, const usmallint Tsmp = 0);
	void setWave(const usmallint tdly, const usmallint Nsmp, const usmallint Tsmp, const unsigned int to = 0);

};

#endif

