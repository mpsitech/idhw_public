/**
  * \file Idhw.h
  * Idhw global functionality and inter-thread exchange object (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef IDHW_H
#define IDHW_H

#include <list>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace std;

#include <sbecore/Mt.h>

#include <dbecore/Bufxf.h>
#include <dbecore/Cmd.h>
#include <dbecore/Crc.h>
#include <dbecore/Rst.h>

class XchgIdhw;
class UntIdhw;

/**
	* SysIdhw
	*/
class SysIdhw {

public:
	static constexpr utinyint tknPing = 0x00;
	static constexpr utinyint tknReset = 0xFF;

public:
	SysIdhw(unsigned char Nretry, unsigned int dtPing, XchgIdhw** xchg);
	virtual ~SysIdhw();

public:
	XchgIdhw* xchg;

	unsigned char Nretry; // max. tries on CRC failure
	unsigned int dtPing; // ping interval in usec

	bool dumpexc;
	bool dumprxtx;

public:
	virtual UntIdhw* connectToTarget(const uint ixVTarget);

	virtual uint getIxVTargetBySref(const string& sref);
	virtual string getSrefByIxVTarget(const uint ixVTarget);
	virtual void fillFeedFTarget(Feed& feed);

	virtual utinyint getTixVControllerBySref(const uint ixVTarget, const string& sref);
	virtual string getSrefByTixVController(const uint ixVTarget, const utinyint tixVController);
	virtual void fillFeedFController(const uint ixVTarget, Feed& feed);

	virtual utinyint getTixWBufferBySref(const uint ixVTarget, const string& sref);
	virtual string getSrefByTixWBuffer(const uint ixVTarget, const utinyint tixWBuffer);
	virtual void fillFeedFBuffer(const uint ixVTarget, Feed& feed);

	virtual utinyint getTixVCommandBySref(const uint ixVTarget, const utinyint tixVController, const string& sref);
	virtual string getSrefByTixVCommand(const uint ixVTarget, const utinyint tixVController, const utinyint tixVCommand);
	virtual void fillFeedFCommand(const uint ixVTarget, const utinyint tixVController, Feed& feed);

	virtual string getSrefByTixVError(const uint ixVTarget, const utinyint tixVController, const utinyint tixVError);
	virtual string getTitleByTixVError(const uint ixVTarget, const utinyint tixVController, const utinyint tixVError);

	virtual Bufxf* getNewBufxf(const uint ixVTarget, const utinyint tixWBuffer, const size_t reqlen);
	virtual Cmd* getNewCmd(const uint ixVTarget, const utinyint tixVController, const uint tixVCommand);

	string getCmdInvTemplate(const uint ixVTarget, const utinyint tixVController, const uint tixVCommand);
	string getCmdErrMessage(Cmd* cmd, const bool cmdNotErronly, const bool titleNotSref);
};

/**
	* UntIdhw
	*/
class UntIdhw {

public:
	UntIdhw(XchgIdhw* xchg, const uint ixVTarget);
	virtual ~UntIdhw();

public:
	XchgIdhw* xchg;

	uint ixVTarget;
	ubigint uref;

	double t0;

public:
	double getDt();

	bool reset();

	bool runBufxf(Bufxf* bufxf, const unsigned int to = 0);
	ubigint startBufxf(Bufxf* bufxf);
	void abortBufxf(Bufxf* bufxf, const bool elim = false);

	bool runCmd(Cmd* cmd, const unsigned int to = 0);
	uint invokeCmd(Cmd* cmd);
	void invokeCmds(vector<Cmd*>& cmds);
	void revokeCmd(Cmd* cmd, const bool elim = false);
};

/**
	* CtrIdhw
	*/
class CtrIdhw {

public:
	CtrIdhw(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);
	virtual ~CtrIdhw();

public:
	XchgIdhw* xchg;

	uint ixVTarget;
	ubigint uref;
};

/**
	* XchgIdhw
	*/
class XchgIdhw {

public:
	XchgIdhw();
	~XchgIdhw();

public:
	// unit connection list
	Refseq* urefseq;
	pthread_mutex_t mUnts;
	map<ubigint,UntIdhw*> unts;

	// condition for preparation processor
	pthread_mutex_t mcPrepprc;
	pthread_cond_t cPrepprc;

	// condition for request processor
	pthread_mutex_t mcReqprc;
	pthread_cond_t cReqprc;

	// request lists protection
	pthread_mutex_t mRstsBufxfsCmds;

	set<cmdix_t> cicsLock;

	// reset list
	Refseq* rrefseq;
	multimap<rstref_t,Rst*> rsts;
	multimap<rstref2_t,rstref_t> rref2sRsts;

	// buffer transfer list
	Refseq* brefseq;
	multimap<bufxfref_t,Bufxf*> bufxfs;
	multimap<bufxfref2_t,bufxfref_t> bref2sBufxfs;

	// command list
	Refseq* crefseq;
	multimap<cmdref_t,Cmd*> cmds;
	multimap<cmdref2_t,cmdref_t> cref2sCmds;

public:
	// unit connection list methods
	ubigint addUnt(UntIdhw* unt);
	UntIdhw* getUntByUref(const ubigint uref);
	void removeUntByUref(const ubigint uref);

	// reset list methods
	ubigint addRst(Rst* rst);
	void changeRstState(Rst* rst, const uint ixVState);

	bool runRst(Rst* rst, const unsigned int to = 0);
	static bool runRst_callback(Rst* rst, void* _cProgress);

	void removeRst(Rst* rst);
	void removeRstsByIxVTarget(const uint ixVTarget);
	void removeRstsByUref(const uint ixVTarget, const ubigint uref);

	// buffer transfer list methods
	ubigint addBufxf(Bufxf* bufxf);
	void changeBufxfState(Bufxf* bufxf, const uint ixVState);

	bool runBufxf(Bufxf* bufxf, const unsigned int to = 0);
	static bool runBufxf_callback(Bufxf* bufxf, void* _cProgress);

	void abortBufxf(Bufxf* bufxf, bool elim = false);

	void removeBufxf(Bufxf* bufxf);
	void removeBufxfsByIxVTarget(const uint ixVTarget);
	void removeBufxfsByUref(const uint ixVTarget, const ubigint uref);

	// command list methods
	uint addCmd(Cmd* cmd, const bool mute = false);
	void addCmds(vector<Cmd*>& _cmds);

	void changeCmdState(Cmd* cmd, const uint ixVState);

	bool runCmd(Cmd* cmd, const unsigned int to = 0);
	static bool runCmd_callback(Cmd* cmd, void* _cond);

	void revokeCmd(Cmd* cmd, bool elim = false);
	static bool revokeCmd_callback(Cmd* cmd, void* _cProgress);

	void removeCmd(Cmd* cmd);

	void removeCmdsByIxVTarget(const uint ixVTarget);
	void removeCmdsByUref(const uint ixVTarget, const ubigint uref);
};

#endif

