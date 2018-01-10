/**
  * \file CtrIdhwZedbPhiif.h
  * phiif controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWZEDBPHIIF_H
#define CTRIDHWZEDBPHIIF_H

#include "Idhw.h"

#define VecVIdhwZedbPhiifCommand CtrIdhwZedbPhiif::VecVCommand

/**
	* CtrIdhwZedbPhiif
	*/
class CtrIdhwZedbPhiif : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwZedbPhiifCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint RESET = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwZedbPhiif(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

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

