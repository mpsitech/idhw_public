/**
  * \file CtrIdhwDcx3Phiif.h
  * phiif controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWDCX3PHIIF_H
#define CTRIDHWDCX3PHIIF_H

#include "Idhw.h"

#define VecVIdhwDcx3PhiifCommand CtrIdhwDcx3Phiif::VecVCommand

/**
	* CtrIdhwDcx3Phiif
	*/
class CtrIdhwDcx3Phiif : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwDcx3PhiifCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint RESET = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwDcx3Phiif(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x08;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdReset();
	void reset(const unsigned int to = 0);

};

#endif

