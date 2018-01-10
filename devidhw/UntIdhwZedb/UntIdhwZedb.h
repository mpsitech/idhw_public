/**
  * \file UntIdhwZedb.h
  * ZedBoard unit (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWZEDB_H
#define UNTIDHWZEDB_H

#include "Idhw.h"

#include "UntIdhwZedb_vecs.h"

#include "CtrIdhwZedbAlua.h"
#include "CtrIdhwZedbAlub.h"
#include "CtrIdhwZedbDcxif.h"
#include "CtrIdhwZedbLwiracq.h"
#include "CtrIdhwZedbLwiremu.h"
#include "CtrIdhwZedbPhiif.h"
#include "CtrIdhwZedbPmmu.h"
#include "CtrIdhwZedbQcdif.h"
#include "CtrIdhwZedbThetaif.h"
#include "CtrIdhwZedbTkclksrc.h"
#include "CtrIdhwZedbTrigger.h"

/**
	* UntIdhwZedb
	*/
class UntIdhwZedb : public UntIdhw {

public:
	UntIdhwZedb(XchgIdhw* xchg, const uint ixVTarget);
	~UntIdhwZedb();

public:
	CtrIdhwZedbAlua* alua;
	CtrIdhwZedbAlub* alub;
	CtrIdhwZedbDcxif* dcxif;
	CtrIdhwZedbLwiracq* lwiracq;
	CtrIdhwZedbLwiremu* lwiremu;
	CtrIdhwZedbPhiif* phiif;
	CtrIdhwZedbPmmu* pmmu;
	CtrIdhwZedbQcdif* qcdif;
	CtrIdhwZedbThetaif* thetaif;
	CtrIdhwZedbTkclksrc* tkclksrc;
	CtrIdhwZedbTrigger* trigger;

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

