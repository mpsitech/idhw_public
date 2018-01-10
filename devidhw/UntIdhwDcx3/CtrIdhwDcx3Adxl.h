/**
  * \file CtrIdhwDcx3Adxl.h
  * adxl controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWDCX3ADXL_H
#define CTRIDHWDCX3ADXL_H

#include "Idhw.h"

#define CmdIdhwDcx3AdxlGetAx CtrIdhwDcx3Adxl::CmdGetAx
#define CmdIdhwDcx3AdxlGetAy CtrIdhwDcx3Adxl::CmdGetAy
#define CmdIdhwDcx3AdxlGetAz CtrIdhwDcx3Adxl::CmdGetAz

#define VecVIdhwDcx3AdxlCommand CtrIdhwDcx3Adxl::VecVCommand

/**
	* CtrIdhwDcx3Adxl
	*/
class CtrIdhwDcx3Adxl : public CtrIdhw {

public:
	/**
		* CmdGetAx (full: CmdIdhwDcx3AdxlGetAx)
		*/
	class CmdGetAx : public Cmd {

	public:
		CmdGetAx();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const smallint ax);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint ax), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetAy (full: CmdIdhwDcx3AdxlGetAy)
		*/
	class CmdGetAy : public Cmd {

	public:
		CmdGetAy();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const smallint ay);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint ay), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetAz (full: CmdIdhwDcx3AdxlGetAz)
		*/
	class CmdGetAz : public Cmd {

	public:
		CmdGetAz();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const smallint az);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint az), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* VecVCommand (full: VecVIdhwDcx3AdxlCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GETAX = 0x00;
		static const utinyint GETAY = 0x01;
		static const utinyint GETAZ = 0x02;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwDcx3Adxl(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x03;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static CmdGetAx* getNewCmdGetAx();
	void getAx(smallint& ax, const unsigned int to = 0);

	static CmdGetAy* getNewCmdGetAy();
	void getAy(smallint& ay, const unsigned int to = 0);

	static CmdGetAz* getNewCmdGetAz();
	void getAz(smallint& az, const unsigned int to = 0);

};

#endif

