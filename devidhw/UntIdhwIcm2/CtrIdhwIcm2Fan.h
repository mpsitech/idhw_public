/**
  * \file CtrIdhwIcm2Fan.h
  * fan controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWICM2FAN_H
#define CTRIDHWICM2FAN_H

#include "Idhw.h"

#define CmdIdhwIcm2FanGetTpi CtrIdhwIcm2Fan::CmdGetTpi

#define VecVIdhwIcm2FanCommand CtrIdhwIcm2Fan::VecVCommand

/**
	* CtrIdhwIcm2Fan
	*/
class CtrIdhwIcm2Fan : public CtrIdhw {

public:
	/**
		* CmdGetTpi (full: CmdIdhwIcm2FanGetTpi)
		*/
	class CmdGetTpi : public Cmd {

	public:
		CmdGetTpi();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tpi);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tpi), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* VecVCommand (full: VecVIdhwIcm2FanCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GETTPI = 0x00;
		static const utinyint SETRNG = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwIcm2Fan(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x04;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static CmdGetTpi* getNewCmdGetTpi();
	void getTpi(utinyint& tpi, const unsigned int to = 0);

	static Cmd* getNewCmdSetRng(const bool rng = false);
	void setRng(const bool rng, const unsigned int to = 0);

};

#endif

