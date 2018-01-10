/**
  * \file CtrIdhwIcm2Acq.h
  * acq controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWICM2ACQ_H
#define CTRIDHWICM2ACQ_H

#include "Idhw.h"

#define CmdIdhwIcm2AcqGetFrame CtrIdhwIcm2Acq::CmdGetFrame
#define CmdIdhwIcm2AcqGetPixel CtrIdhwIcm2Acq::CmdGetPixel

#define VecVIdhwIcm2AcqCommand CtrIdhwIcm2Acq::VecVCommand

/**
	* CtrIdhwIcm2Acq
	*/
class CtrIdhwIcm2Acq : public CtrIdhw {

public:
	/**
		* CmdGetFrame (full: CmdIdhwIcm2AcqGetFrame)
		*/
	class CmdGetFrame : public Cmd {

	public:
		CmdGetFrame();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst, const usmallint ntc);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst, const usmallint ntc), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetPixel (full: CmdIdhwIcm2AcqGetPixel)
		*/
	class CmdGetPixel : public Cmd {

	public:
		CmdGetPixel();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst, const usmallint ntc, const uint pixval);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const uint tkst, const usmallint ntc, const uint pixval), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* VecVCommand (full: VecVIdhwIcm2AcqCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GETFRAME = 0x00;
		static const utinyint GETPIXEL = 0x01;
		static const utinyint GETTRACE = 0x02;
		static const utinyint SETADC = 0x03;
		static const utinyint SETTFRM = 0x04;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwIcm2Acq(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x03;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static CmdGetFrame* getNewCmdGetFrame(const usmallint Nsmp = 0);

	static CmdGetPixel* getNewCmdGetPixel(const usmallint Nsmp = 0);

	static Cmd* getNewCmdGetTrace(const usmallint Nsmp = 0);

	static Cmd* getNewCmdSetAdc(const utinyint cps = 0, const usmallint tdly = 0);
	void setAdc(const utinyint cps, const usmallint tdly, const unsigned int to = 0);

	static Cmd* getNewCmdSetTfrm(const usmallint Tfrm = 0);
	void setTfrm(const usmallint Tfrm, const unsigned int to = 0);

};

#endif

