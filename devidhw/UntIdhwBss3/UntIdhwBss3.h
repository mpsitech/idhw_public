/**
  * \file UntIdhwBss3.h
  * Digilent Basys3 unit (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWBSS3_H
#define UNTIDHWBSS3_H

#include "Idhw.h"

#include "UntIdhwBss3_vecs.h"

#include "CtrIdhwBss3Alua.h"
#include "CtrIdhwBss3Alub.h"
#include "CtrIdhwBss3Dcxif.h"
#include "CtrIdhwBss3Lwiracq.h"
#include "CtrIdhwBss3Lwiremu.h"
#include "CtrIdhwBss3Phiif.h"
#include "CtrIdhwBss3Pmmu.h"
#include "CtrIdhwBss3Qcdif.h"
#include "CtrIdhwBss3Thetaif.h"
#include "CtrIdhwBss3Tkclksrc.h"
#include "CtrIdhwBss3Trigger.h"

/**
	* UntIdhwBss3
	*/
class UntIdhwBss3 : public UntIdhw {

public:
	UntIdhwBss3(XchgIdhw* xchg, const uint ixVTarget);
	~UntIdhwBss3();

public:
	CtrIdhwBss3Alua* alua;
	CtrIdhwBss3Alub* alub;
	CtrIdhwBss3Dcxif* dcxif;
	CtrIdhwBss3Lwiracq* lwiracq;
	CtrIdhwBss3Lwiremu* lwiremu;
	CtrIdhwBss3Phiif* phiif;
	CtrIdhwBss3Pmmu* pmmu;
	CtrIdhwBss3Qcdif* qcdif;
	CtrIdhwBss3Thetaif* thetaif;
	CtrIdhwBss3Tkclksrc* tkclksrc;
	CtrIdhwBss3Trigger* trigger;

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

	static Bufxf* getNewBufxfFromDcxif(const size_t reqlen);
	void readBufFromDcxif(const size_t reqlen, unsigned char*& data, size_t& datalen);

	static Bufxf* getNewBufxfToDcxif(const size_t reqlen);
	void writeBufToDcxif(const unsigned char* data, const size_t datalen);

	static Bufxf* getNewBufxfToQcdif(const size_t reqlen);
	void writeBufToQcdif(const unsigned char* data, const size_t datalen);

	static Bufxf* getNewBufxfFromPmmu(const size_t reqlen);
	void readBufFromPmmu(const size_t reqlen, unsigned char*& data, size_t& datalen);

	static Bufxf* getNewBufxfFromQcdif(const size_t reqlen);
	void readBufFromQcdif(const size_t reqlen, unsigned char*& data, size_t& datalen);

};

#endif

