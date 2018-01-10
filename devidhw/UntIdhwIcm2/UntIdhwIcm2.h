/**
  * \file UntIdhwIcm2.h
  * icacam2 unit (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWICM2_H
#define UNTIDHWICM2_H

#include "Idhw.h"

#include "UntIdhwIcm2_vecs.h"

#include "CtrIdhwIcm2Acq.h"
#include "CtrIdhwIcm2Fan.h"
#include "CtrIdhwIcm2Roic.h"
#include "CtrIdhwIcm2State.h"
#include "CtrIdhwIcm2Sync.h"
#include "CtrIdhwIcm2Temp.h"
#include "CtrIdhwIcm2Tkclksrc.h"
#include "CtrIdhwIcm2Vmon.h"
#include "CtrIdhwIcm2Vset.h"
#include "CtrIdhwIcm2Wavegen.h"

/**
	* UntIdhwIcm2
	*/
class UntIdhwIcm2 : public UntIdhw {

public:
	UntIdhwIcm2(XchgIdhw* xchg, const uint ixVTarget);
	~UntIdhwIcm2();

public:
	CtrIdhwIcm2Acq* acq;
	CtrIdhwIcm2Fan* fan;
	CtrIdhwIcm2Roic* roic;
	CtrIdhwIcm2State* state;
	CtrIdhwIcm2Sync* sync;
	CtrIdhwIcm2Temp* temp;
	CtrIdhwIcm2Tkclksrc* tkclksrc;
	CtrIdhwIcm2Vmon* vmon;
	CtrIdhwIcm2Vset* vset;
	CtrIdhwIcm2Wavegen* wavegen;

public:
	static utinyint getTixVControllerBySref(const string& sref);
	static string getSrefByTixVController(const utinyint tixVController);
	static void fillFeedFController(Feed& feed);

	static utinyint getTixWBufferBySref(const string& sref);
	static string getSrefByTixWBuffer(const utinyint tixWBuffer);
	static void fillFeedFBuffer(Feed& feed);

	static utinyint getTixVCommandBySref(const utinyint tixVController, const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVController, const utinyint tixVCommand);
	static void fillFeedFCommand(const utinyint tixVController, Feed& feed);

	static string getSrefByTixVError(const utinyint tixVController, const utinyint tixVError);
	static string getTitleByTixVError(const utinyint tixVController, const utinyint tixVError);

	static Bufxf* getNewBufxf(const utinyint tixWBuffer, const size_t reqlen);
	static Cmd* getNewCmd(const utinyint tixVController, const utinyint tixVCommand);
	static Err getNewErr(const utinyint tixVController, const utinyint tixVError);

	static Bufxf* getNewBufxfFromAcq(const size_t reqlen);
	void readBufFromAcq(const size_t reqlen, unsigned char*& data, size_t& datalen);

	static Bufxf* getNewBufxfToWavegen(const size_t reqlen);
	void writeBufToWavegen(const unsigned char* data, const size_t datalen);

};

#endif

