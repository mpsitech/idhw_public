/**
  * \file SysIdhwZedboardFwd.h
  * SPI command forwarder based on ZedBoard system (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef SYSIDHWZEDBOARDFWD_H
#define SYSIDHWZEDBOARDFWD_H

// IP custInclude --- INSERT

#include "Idhw.h"

#include "UntIdhwAxs2.h"
#include "UntIdhwBss3.h"
#include "UntIdhwDcx3.h"
#include "UntIdhwIcm2.h"
#include "UntIdhwTau2.h"
#include "UntIdhwZedb.h"

#define VecVSysIdhwZedboardFwdTarget SysIdhwZedboardFwd::VecVTarget

/**
	* SysIdhwZedboardFwd
	*/
class SysIdhwZedboardFwd : public SysIdhw {

public:
	/**
		* VecVTarget (full: VecVSysIdhwZedboardFwdTarget)
		*/
	class VecVTarget {

	public:
		static const uint AXS2_PHI = 1;
		static const uint AXS2_THETA = 2;
		static const uint DCX3 = 3;
		static const uint DCX3_AXS2_PHI = 4;
		static const uint DCX3_AXS2_THETA = 5;
		static const uint DCX3_ICM2 = 6;
		static const uint DCX3_TAU2 = 7;
		static const uint ICM2 = 8;
		static const uint ZEDB = 9;

		static uint getIx(const string& sref);
		static string getSref(const uint ix);

		static void fillFeed(Feed& feed);
	};

	/**
		* RstCmdProgressCallback_arg
		*/
	struct RstCmdProgressCallback_arg {
		SysIdhwZedboardFwd* inst;
		Rst* rst;
	};

	/**
		* BufxfCmdProgressCallback_arg
		*/
	struct BufxfCmdProgressCallback_arg {
		SysIdhwZedboardFwd* inst;
		Bufxf* bufxf;
	};

public:
	SysIdhwZedboardFwd(unsigned char Nretry, unsigned int dtPing, XchgIdhw** xchg);
	~SysIdhwZedboardFwd();

public:
	pthread_t prepprc;

	pthread_t reqprc;

	unsigned char* rxbuf;
	unsigned char* txbuf;

	// IP custVar --- IBEGIN
	bool initdone;

	string path;

	int fd;
	// IP custVar --- IEND

public:
	static void* runPrepprc(void* arg);
	static void cleanupPrepprc(void* arg);

	static void* runReqprc(void* arg);
	static void cleanupReqprc(void* arg);

	void runReqprc_open();

	bool runReqprc_rx(const size_t _rxlen);
	bool runReqprc_tx(const size_t _txlen);

	void runReqprc_recover();

	void runReqprc_close();

	size_t runReqprc_getAvllen();
	void runReqprc_setReqlen(const size_t len);
	size_t runReqprc_getArblen();

	void runReqprc_setRoute(const uint ixVTarget, const utinyint tixVController);

	uint runReqprc_getCref();
	void runReqprc_setCref(const uint cref);

	unsigned short runReqprc_calcCrc(const bool txbufNotRxbuf, const size_t ofs, const size_t len);

	unsigned short runReqprc_getCrc(const size_t ofs);
	void runReqprc_setCrc(const size_t ofs, unsigned short crc);

	static bool rstCmdProgressCallback(Cmd* cmd, void* _arg);
	static bool bufxfCmdProgressCallback(Cmd* cmd, void* _arg);

	Rst* getFirstRst(const uint ixVState);
	Bufxf* getFirstBufxf(const uint ixVState);

	// IP cust --- IBEGIN
	void init(const string& _path);
	void term();
	// IP cust --- IEND

public:
	UntIdhw* connectToTarget(const uint ixVTarget);

	uint getIxVTargetBySref(const string& sref);
	string getSrefByIxVTarget(const uint ixVTarget);
	void fillFeedFTarget(Feed& feed);

	utinyint getTixVControllerBySref(const uint ixVTarget, const string& sref);
	string getSrefByTixVController(const uint ixVTarget, const utinyint tixVController);
	void fillFeedFController(const uint ixVTarget, Feed& feed);

	utinyint getTixWBufferBySref(const uint ixVTarget, const string& sref);
	string getSrefByTixWBuffer(const uint ixVTarget, const utinyint tixWBuffer);
	void fillFeedFBuffer(const uint ixVTarget, Feed& feed);

	utinyint getTixVCommandBySref(const uint ixVTarget, const utinyint tixVController, const string& sref);
	string getSrefByTixVCommand(const uint ixVTarget, const utinyint tixVController, const utinyint tixVCommand);
	void fillFeedFCommand(const uint ixVTarget, const utinyint tixVController, Feed& feed);

	string getSrefByTixVError(const uint ixVTarget, const utinyint tixVController, const utinyint tixVError);
	string getTitleByTixVError(const uint ixVTarget, const utinyint tixVController, const utinyint tixVError);

	Bufxf* getNewBufxf(const uint ixVTarget, const utinyint tixWBuffer, const size_t reqlen);
	Cmd* getNewCmd(const uint ixVTarget, const utinyint tixVController, const uint tixVCommand);
	Err getNewErr(const uint ixVTarget, const utinyint tixVController, const utinyint tixVError);
};

#endif



