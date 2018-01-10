/**
  * \file CtrIdhwBss3Lwiremu.h
  * lwiremu controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWBSS3LWIREMU_H
#define CTRIDHWBSS3LWIREMU_H

#include "Idhw.h"

#define VecVIdhwBss3LwiremuCommand CtrIdhwBss3Lwiremu::VecVCommand

/**
	* CtrIdhwBss3Lwiremu
	*/
class CtrIdhwBss3Lwiremu : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwBss3LwiremuCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETTRIG = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwBss3Lwiremu(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x07;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetTrig(const bool extNotInt = false);
	void setTrig(const bool extNotInt, const unsigned int to = 0);

};

#endif

