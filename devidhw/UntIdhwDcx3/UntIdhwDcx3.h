/**
  * \file UntIdhwDcx3.h
  * dspcomplex3 unit (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWDCX3_H
#define UNTIDHWDCX3_H

#include "Idhw.h"

#include "UntIdhwDcx3_vecs.h"

#include "CtrIdhwDcx3Adxl.h"
#include "CtrIdhwDcx3Align.h"
#include "CtrIdhwDcx3Led.h"
#include "CtrIdhwDcx3Lwiracq.h"
#include "CtrIdhwDcx3Lwirif.h"
#include "CtrIdhwDcx3Phiif.h"
#include "CtrIdhwDcx3Pmmu.h"
#include "CtrIdhwDcx3Qcdif.h"
#include "CtrIdhwDcx3Shfbox.h"
#include "CtrIdhwDcx3State.h"
#include "CtrIdhwDcx3Thetaif.h"
#include "CtrIdhwDcx3Tkclksrc.h"
#include "CtrIdhwDcx3Trigger.h"

/**
	* UntIdhwDcx3
	*/
class UntIdhwDcx3 : public UntIdhw {

public:
	UntIdhwDcx3(XchgIdhw* xchg, const uint ixVTarget);
	~UntIdhwDcx3();

public:
	CtrIdhwDcx3Adxl* adxl;
	CtrIdhwDcx3Align* align;
	CtrIdhwDcx3Led* led;
	CtrIdhwDcx3Lwiracq* lwiracq;
	CtrIdhwDcx3Lwirif* lwirif;
	CtrIdhwDcx3Phiif* phiif;
	CtrIdhwDcx3Pmmu* pmmu;
	CtrIdhwDcx3Qcdif* qcdif;
	CtrIdhwDcx3Shfbox* shfbox;
	CtrIdhwDcx3State* state;
	CtrIdhwDcx3Thetaif* thetaif;
	CtrIdhwDcx3Tkclksrc* tkclksrc;
	CtrIdhwDcx3Trigger* trigger;

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

	static Bufxf* getNewBufxfToQcdif(const size_t reqlen);
	void writeBufToQcdif(const unsigned char* data, const size_t datalen);

	static Bufxf* getNewBufxfFromPmmu(const size_t reqlen);
	void readBufFromPmmu(const size_t reqlen, unsigned char*& data, size_t& datalen);

	static Bufxf* getNewBufxfFromQcdif(const size_t reqlen);
	void readBufFromQcdif(const size_t reqlen, unsigned char*& data, size_t& datalen);

};

#endif

