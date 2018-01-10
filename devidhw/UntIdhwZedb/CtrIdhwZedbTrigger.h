/**
  * \file CtrIdhwZedbTrigger.h
  * trigger controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWZEDBTRIGGER_H
#define CTRIDHWZEDBTRIGGER_H

#include "Idhw.h"

#define VecVIdhwZedbTriggerCommand CtrIdhwZedbTrigger::VecVCommand

/**
	* CtrIdhwZedbTrigger
	*/
class CtrIdhwZedbTrigger : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwZedbTriggerCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETRNG = 0x00;
		static const utinyint SETTDLYLWIR = 0x01;
		static const utinyint SETTFRM = 0x02;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwZedbTrigger(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x0D;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetRng(const bool rng = false, const bool btnNotTfrm = false);
	void setRng(const bool rng, const bool btnNotTfrm, const unsigned int to = 0);

	static Cmd* getNewCmdSetTdlyLwir(const usmallint tdlyLwir = 0);
	void setTdlyLwir(const usmallint tdlyLwir, const unsigned int to = 0);

	static Cmd* getNewCmdSetTfrm(const usmallint Tfrm = 0);
	void setTfrm(const usmallint Tfrm, const unsigned int to = 0);

};

#endif

