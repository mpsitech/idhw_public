/**
  * \file CtrIdhwDcx3Qcdif.h
  * qcdif controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWDCX3QCDIF_H
#define CTRIDHWDCX3QCDIF_H

#include "Idhw.h"

#include "UntIdhwIcm2_vecs.h"

#define VecVIdhwDcx3QcdifCommand CtrIdhwDcx3Qcdif::VecVCommand
#define VecVIdhwDcx3QcdifError CtrIdhwDcx3Qcdif::VecVError

/**
	* CtrIdhwDcx3Qcdif
	*/
class CtrIdhwDcx3Qcdif : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwDcx3QcdifCommand)
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
		* VecVError (full: VecVIdhwDcx3QcdifError)
		*/
	class VecVError {

	public:
		static const utinyint BUFXFER = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);
	};

public:
	CtrIdhwDcx3Qcdif(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x0A;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdReset();
	void reset(const unsigned int to = 0);

	static Cmd* getNewCmdRead(const utinyint tixWIcm2Buffer = 0, const uint reqLen = 0);

	static Cmd* getNewCmdWrite(const utinyint tixWIcm2Buffer = 0, const uint reqLen = 0);

	static string getSrefByTixVError(const utinyint tixVError);
	static string getTitleByTixVError(const utinyint tixVError);

	static Err getNewErr(const utinyint tixVError);

	static Err getNewErrBufxfer();
};

#endif

