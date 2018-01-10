/**
  * \file CtrIdhwZedbThetaif.h
  * thetaif controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWZEDBTHETAIF_H
#define CTRIDHWZEDBTHETAIF_H

#include "Idhw.h"

#define VecVIdhwZedbThetaifCommand CtrIdhwZedbThetaif::VecVCommand

/**
	* CtrIdhwZedbThetaif
	*/
class CtrIdhwZedbThetaif : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwZedbThetaifCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint RESET = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwZedbThetaif(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

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

