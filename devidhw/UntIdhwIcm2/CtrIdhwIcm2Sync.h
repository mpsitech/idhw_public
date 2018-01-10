/**
  * \file CtrIdhwIcm2Sync.h
  * sync controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWICM2SYNC_H
#define CTRIDHWICM2SYNC_H

#include "Idhw.h"

#define VecVIdhwIcm2SyncCommand CtrIdhwIcm2Sync::VecVCommand

/**
	* CtrIdhwIcm2Sync
	*/
class CtrIdhwIcm2Sync : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwIcm2SyncCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETPULSE = 0x00;
		static const utinyint SETRNG = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwIcm2Sync(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x07;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetPulse(const usmallint tdly = 0, const usmallint ton = 0);
	void setPulse(const usmallint tdly, const usmallint ton, const unsigned int to = 0);

	static Cmd* getNewCmdSetRng(const bool rng = false);
	void setRng(const bool rng, const unsigned int to = 0);

};

#endif

