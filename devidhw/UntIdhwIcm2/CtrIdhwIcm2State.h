/**
  * \file CtrIdhwIcm2State.h
  * state controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWICM2STATE_H
#define CTRIDHWICM2STATE_H

#include "Idhw.h"

#include "UntIdhwIcm2_vecs.h"

#define CmdIdhwIcm2StateGet CtrIdhwIcm2State::CmdGet

#define VecVIdhwIcm2StateCommand CtrIdhwIcm2State::VecVCommand

/**
	* CtrIdhwIcm2State
	*/
class CtrIdhwIcm2State : public CtrIdhw {

public:
	/**
		* CmdGet (full: CmdIdhwIcm2StateGet)
		*/
	class CmdGet : public Cmd {

	public:
		CmdGet();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVIcm2State);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVIcm2State), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* VecVCommand (full: VecVIdhwIcm2StateCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GET = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwIcm2State(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x06;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static CmdGet* getNewCmdGet();
	void get(utinyint& tixVIcm2State, const unsigned int to = 0);

};

#endif

