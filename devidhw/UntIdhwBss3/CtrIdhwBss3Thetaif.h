/**
  * \file CtrIdhwBss3Thetaif.h
  * thetaif controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWBSS3THETAIF_H
#define CTRIDHWBSS3THETAIF_H

#include "Idhw.h"

#define VecVIdhwBss3ThetaifCommand CtrIdhwBss3Thetaif::VecVCommand

/**
	* CtrIdhwBss3Thetaif
	*/
class CtrIdhwBss3Thetaif : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwBss3ThetaifCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint RESET = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwBss3Thetaif(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x0B;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdReset();
	void reset(const unsigned int to = 0);

};

#endif

