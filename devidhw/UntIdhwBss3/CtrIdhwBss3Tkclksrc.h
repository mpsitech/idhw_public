/**
  * \file CtrIdhwBss3Tkclksrc.h
  * tkclksrc controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWBSS3TKCLKSRC_H
#define CTRIDHWBSS3TKCLKSRC_H

#include "Idhw.h"

#define CmdIdhwBss3TkclksrcGetTkst CtrIdhwBss3Tkclksrc::CmdGetTkst

#define VecVIdhwBss3TkclksrcCommand CtrIdhwBss3Tkclksrc::VecVCommand

/**
	* CtrIdhwBss3Tkclksrc
	*/
class CtrIdhwBss3Tkclksrc : public CtrIdhw {

public:
	/**
		* CmdGetTkst (full: CmdIdhwBss3TkclksrcGetTkst)
		*/
	class CmdGetTkst : public Cmd {

	public:
		CmdGetTkst();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* VecVCommand (full: VecVIdhwBss3TkclksrcCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GETTKST = 0x00;
		static const utinyint SETTKST = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwBss3Tkclksrc(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x0C;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static CmdGetTkst* getNewCmdGetTkst();
	void getTkst(uint& tkst, const unsigned int to = 0);

	static Cmd* getNewCmdSetTkst(const uint tkst = 0);
	void setTkst(const uint tkst, const unsigned int to = 0);

};

#endif

