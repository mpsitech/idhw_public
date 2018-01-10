/**
  * \file CtrIdhwBss3Lwiracq.h
  * lwiracq controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWBSS3LWIRACQ_H
#define CTRIDHWBSS3LWIRACQ_H

#include "Idhw.h"

#define CmdIdhwBss3LwiracqGetFrame CtrIdhwBss3Lwiracq::CmdGetFrame

#define VecVIdhwBss3LwiracqCommand CtrIdhwBss3Lwiracq::VecVCommand
#define VecVIdhwBss3LwiracqDepth CtrIdhwBss3Lwiracq::VecVDepth

/**
	* CtrIdhwBss3Lwiracq
	*/
class CtrIdhwBss3Lwiracq : public CtrIdhw {

public:
	/**
		* CmdGetFrame (full: CmdIdhwBss3LwiracqGetFrame)
		*/
	class CmdGetFrame : public Cmd {

	public:
		CmdGetFrame();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst, const utinyint tixVBss3PmmuSlot, const utinyint avlpglen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst, const utinyint tixVBss3PmmuSlot, const utinyint avlpglen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* VecVCommand (full: VecVIdhwBss3LwiracqCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GETFRAME = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

	/**
		* VecVDepth (full: VecVIdhwBss3LwiracqDepth)
		*/
	class VecVDepth {

	public:
		static const utinyint D2 = 0x00;
		static const utinyint D4 = 0x01;
		static const utinyint D8 = 0x02;
		static const utinyint D12 = 0x03;
		static const utinyint D14 = 0x04;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwBss3Lwiracq(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x06;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static CmdGetFrame* getNewCmdGetFrame(const utinyint tixVDepth = 0);

};

#endif

