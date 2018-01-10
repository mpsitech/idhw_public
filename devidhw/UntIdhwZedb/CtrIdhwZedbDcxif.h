/**
  * \file CtrIdhwZedbDcxif.h
  * dcxif controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWZEDBDCXIF_H
#define CTRIDHWZEDBDCXIF_H

#include "Idhw.h"

#include "UntIdhwDcx3_vecs.h"

#define VecVIdhwZedbDcxifCommand CtrIdhwZedbDcxif::VecVCommand
#define VecVIdhwZedbDcxifError CtrIdhwZedbDcxif::VecVError

/**
	* CtrIdhwZedbDcxif
	*/
class CtrIdhwZedbDcxif : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwZedbDcxifCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint RESET = 0x01;
		static const utinyint READ = 0x02;
		static const utinyint WRITE = 0x03;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

	/**
		* VecVError (full: VecVIdhwZedbDcxifError)
		*/
	class VecVError {

	public:
		static const utinyint BUFXFER = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);
	};

public:
	CtrIdhwZedbDcxif(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x05;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdReset();
	void reset(const unsigned int to = 0);

	static Cmd* getNewCmdRead(const utinyint tixWDcx3Buffer = 0, const uint reqLen = 0);

	static Cmd* getNewCmdWrite(const utinyint tixWDcx3Buffer = 0, const uint reqLen = 0);

	static string getSrefByTixVError(const utinyint tixVError);
	static string getTitleByTixVError(const utinyint tixVError);

	static Err getNewErr(const utinyint tixVError);

	static Err getNewErrBufxfer();
};

#endif

