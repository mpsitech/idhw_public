/**
  * \file CtrIdhwIcm2Vmon.h
  * vmon controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWICM2VMON_H
#define CTRIDHWICM2VMON_H

#include "Idhw.h"

#define CmdIdhwIcm2VmonGetVref CtrIdhwIcm2Vmon::CmdGetVref
#define CmdIdhwIcm2VmonGetVdd CtrIdhwIcm2Vmon::CmdGetVdd
#define CmdIdhwIcm2VmonGetVtec CtrIdhwIcm2Vmon::CmdGetVtec
#define CmdIdhwIcm2VmonGetNtc CtrIdhwIcm2Vmon::CmdGetNtc
#define CmdIdhwIcm2VmonGetPt CtrIdhwIcm2Vmon::CmdGetPt

#define VecVIdhwIcm2VmonCommand CtrIdhwIcm2Vmon::VecVCommand

/**
	* CtrIdhwIcm2Vmon
	*/
class CtrIdhwIcm2Vmon : public CtrIdhw {

public:
	/**
		* CmdGetVref (full: CmdIdhwIcm2VmonGetVref)
		*/
	class CmdGetVref : public Cmd {

	public:
		CmdGetVref();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vref);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vref), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetVdd (full: CmdIdhwIcm2VmonGetVdd)
		*/
	class CmdGetVdd : public Cmd {

	public:
		CmdGetVdd();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vdd);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vdd), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetVtec (full: CmdIdhwIcm2VmonGetVtec)
		*/
	class CmdGetVtec : public Cmd {

	public:
		CmdGetVtec();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vtec);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vtec), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetNtc (full: CmdIdhwIcm2VmonGetNtc)
		*/
	class CmdGetNtc : public Cmd {

	public:
		CmdGetNtc();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint ntc);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint ntc), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetPt (full: CmdIdhwIcm2VmonGetPt)
		*/
	class CmdGetPt : public Cmd {

	public:
		CmdGetPt();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint pt);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint pt), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* VecVCommand (full: VecVIdhwIcm2VmonCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GETVREF = 0x00;
		static const utinyint GETVDD = 0x01;
		static const utinyint GETVTEC = 0x02;
		static const utinyint GETNTC = 0x03;
		static const utinyint GETPT = 0x04;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwIcm2Vmon(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x0A;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static CmdGetVref* getNewCmdGetVref();
	void getVref(usmallint& Vref, const unsigned int to = 0);

	static CmdGetVdd* getNewCmdGetVdd();
	void getVdd(usmallint& Vdd, const unsigned int to = 0);

	static CmdGetVtec* getNewCmdGetVtec();
	void getVtec(usmallint& Vtec, const unsigned int to = 0);

	static CmdGetNtc* getNewCmdGetNtc();
	void getNtc(usmallint& ntc, const unsigned int to = 0);

	static CmdGetPt* getNewCmdGetPt();
	void getPt(usmallint& pt, const unsigned int to = 0);

};

#endif

