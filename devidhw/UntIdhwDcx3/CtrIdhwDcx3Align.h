/**
  * \file CtrIdhwDcx3Align.h
  * align controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWDCX3ALIGN_H
#define CTRIDHWDCX3ALIGN_H

#include "Idhw.h"

#define VecVIdhwDcx3AlignCommand CtrIdhwDcx3Align::VecVCommand

/**
	* CtrIdhwDcx3Align
	*/
class CtrIdhwDcx3Align : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwDcx3AlignCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETSEQ = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwDcx3Align(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x04;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetSeq(const unsigned char* seq = NULL, const size_t seqlen = 0);
	void setSeq(const unsigned char* seq, const size_t seqlen, const unsigned int to = 0);

};

#endif

