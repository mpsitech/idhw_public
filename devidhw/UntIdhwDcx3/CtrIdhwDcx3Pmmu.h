/**
  * \file CtrIdhwDcx3Pmmu.h
  * pmmu controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWDCX3PMMU_H
#define CTRIDHWDCX3PMMU_H

#include "Idhw.h"

#define CmdIdhwDcx3PmmuAlloc CtrIdhwDcx3Pmmu::CmdAlloc

#define VecVIdhwDcx3PmmuCommand CtrIdhwDcx3Pmmu::VecVCommand
#define VecVIdhwDcx3PmmuError CtrIdhwDcx3Pmmu::VecVError
#define VecVIdhwDcx3PmmuSlot CtrIdhwDcx3Pmmu::VecVSlot

/**
	* CtrIdhwDcx3Pmmu
	*/
class CtrIdhwDcx3Pmmu : public CtrIdhw {

public:
	/**
		* CmdAlloc (full: CmdIdhwDcx3PmmuAlloc)
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
		* VecVCommand (full: VecVIdhwDcx3PmmuCommand)
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
		* VecVError (full: VecVIdhwDcx3PmmuError)
		*/
	class VecVError {

	public:
		static const utinyint INVALID = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);
	};

	/**
		* VecVSlot (full: VecVIdhwDcx3PmmuSlot)
		*/
	class VecVSlot {

	public:
		static const utinyint VOID = 0x00;
		static const utinyint S0 = 0x01;
		static const utinyint S1 = 0x02;
		static const utinyint S2 = 0x03;
		static const utinyint S3 = 0x04;
		static const utinyint S4 = 0x05;
		static const utinyint S5 = 0x06;
		static const utinyint S6 = 0x07;
		static const utinyint S7 = 0x08;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwDcx3Pmmu(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

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

