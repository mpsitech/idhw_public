/**
  * \file CtrIdhwDcx3State.h
  * state controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWDCX3STATE_H
#define CTRIDHWDCX3STATE_H

#include "Idhw.h"

#include "UntIdhwDcx3_vecs.h"

#define CmdIdhwDcx3StateGet CtrIdhwDcx3State::CmdGet

#define VecVIdhwDcx3StateCommand CtrIdhwDcx3State::VecVCommand

/**
	* CtrIdhwDcx3State
	*/
class CtrIdhwDcx3State : public CtrIdhw {

public:
	/**
		* CmdGet (full: CmdIdhwDcx3StateGet)
		*/
	class CmdGet : public Cmd {

	public:
		CmdGet();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVDcx3State);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVDcx3State), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* VecVCommand (full: VecVIdhwDcx3StateCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GET = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwDcx3State(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x0C;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static CmdGet* getNewCmdGet();
	void get(utinyint& tixVDcx3State, const unsigned int to = 0);

};

#endif

