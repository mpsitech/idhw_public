/**
  * \file CtrIdhwBss3Pmmu.h
  * pmmu controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWBSS3PMMU_H
#define CTRIDHWBSS3PMMU_H

#include "Idhw.h"

#define CmdIdhwBss3PmmuAlloc CtrIdhwBss3Pmmu::CmdAlloc

#define VecVIdhwBss3PmmuCommand CtrIdhwBss3Pmmu::VecVCommand
#define VecVIdhwBss3PmmuError CtrIdhwBss3Pmmu::VecVError
#define VecVIdhwBss3PmmuSlot CtrIdhwBss3Pmmu::VecVSlot

/**
	* CtrIdhwBss3Pmmu
	*/
class CtrIdhwBss3Pmmu : public CtrIdhw {

public:
	/**
		* CmdAlloc (full: CmdIdhwBss3PmmuAlloc)
		*/
	class CmdAlloc : public Cmd {

	public:
		CmdAlloc();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVSlot);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVSlot), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* VecVCommand (full: VecVIdhwBss3PmmuCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint ALLOC = 0x00;
		static const utinyint FREE = 0x01;
		static const utinyint READOUTBUF0 = 0x02;
		static const utinyint WRITEINBUF0 = 0x03;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

	/**
		* VecVError (full: VecVIdhwBss3PmmuError)
		*/
	class VecVError {

	public:
		static const utinyint INVALID = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);
	};

	/**
		* VecVSlot (full: VecVIdhwBss3PmmuSlot)
		*/
	class VecVSlot {

	public:
		static const utinyint VOID = 0x00;
		static const utinyint S0 = 0x01;
		static const utinyint S1 = 0x02;
		static const utinyint S2 = 0x03;
		static const utinyint S3 = 0x04;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwBss3Pmmu(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x09;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static CmdAlloc* getNewCmdAlloc(const bool dynNotStat = false, const utinyint reqPglen = 0);
	void alloc(const bool dynNotStat, const utinyint reqPglen, utinyint& tixVSlot, const unsigned int to = 0);

	static Cmd* getNewCmdFree(const utinyint tixVSlot = 0);
	void free(const utinyint tixVSlot, const unsigned int to = 0);

	static Cmd* getNewCmdReadOutbuf0(const utinyint tixVSlot = 0, const bool freeNotKeep = false);

	static Cmd* getNewCmdWriteInbuf0(const utinyint tixVSlot = 0);

	static string getSrefByTixVError(const utinyint tixVError);
	static string getTitleByTixVError(const utinyint tixVError);

	static Err getNewErr(const utinyint tixVError);

	static Err getNewErrInvalid();
};

#endif

