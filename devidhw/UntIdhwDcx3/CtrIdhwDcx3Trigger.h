/**
  * \file CtrIdhwDcx3Trigger.h
  * trigger controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWDCX3TRIGGER_H
#define CTRIDHWDCX3TRIGGER_H

#include "Idhw.h"

#define VecVIdhwDcx3TriggerCommand CtrIdhwDcx3Trigger::VecVCommand

/**
	* CtrIdhwDcx3Trigger
	*/
class CtrIdhwDcx3Trigger : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwDcx3TriggerCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETRNG = 0x00;
		static const utinyint SETTDLYLWIR = 0x01;
		static const utinyint SETTDLYVISR = 0x02;
		static const utinyint SETTFRM = 0x03;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwDcx3Trigger(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x0F;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetRng(const bool rng = false);
	void setRng(const bool rng, const unsigned int to = 0);

	static Cmd* getNewCmdSetTdlyLwir(const usmallint tdlyLwir = 0);
	void setTdlyLwir(const usmallint tdlyLwir, const unsigned int to = 0);

	static Cmd* getNewCmdSetTdlyVisr(const usmallint tdlyVisr = 0);
	void setTdlyVisr(const usmallint tdlyVisr, const unsigned int to = 0);

	static Cmd* getNewCmdSetTfrm(const usmallint Tfrm = 0);
	void setTfrm(const usmallint Tfrm, const unsigned int to = 0);

};

#endif

