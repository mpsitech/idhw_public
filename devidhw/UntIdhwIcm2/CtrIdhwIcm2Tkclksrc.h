/**
  * \file CtrIdhwIcm2Tkclksrc.h
  * tkclksrc controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWICM2TKCLKSRC_H
#define CTRIDHWICM2TKCLKSRC_H

#include "Idhw.h"

#define CmdIdhwIcm2TkclksrcGetTkst CtrIdhwIcm2Tkclksrc::CmdGetTkst

#define VecVIdhwIcm2TkclksrcCommand CtrIdhwIcm2Tkclksrc::VecVCommand

/**
	* CtrIdhwIcm2Tkclksrc
	*/
class CtrIdhwIcm2Tkclksrc : public CtrIdhw {

public:
	/**
		* CmdGetTkst (full: CmdIdhwIcm2TkclksrcGetTkst)
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
		* VecVCommand (full: VecVIdhwIcm2TkclksrcCommand)
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
	CtrIdhwIcm2Tkclksrc(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x09;

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

