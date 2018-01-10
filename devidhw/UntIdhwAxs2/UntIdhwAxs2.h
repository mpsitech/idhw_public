/**
  * \file UntIdhwAxs2.h
  * axis2 unit (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWAXS2_H
#define UNTIDHWAXS2_H

#include "Idhw.h"

#include "UntIdhwAxs2_vecs.h"

/**
	* UntIdhwAxs2
	*/
class UntIdhwAxs2 : public UntIdhw {

public:
	/**
		* CmdGetState (full: CmdIdhwAxs2GetState)
		*/
	class CmdGetState : public Cmd {

	public:
		CmdGetState();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVState);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const utinyint tixVState), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetAdcCp (full: CmdIdhwAxs2GetAdcCp)
		*/
	class CmdGetAdcCp : public Cmd {

	public:
		CmdGetAdcCp();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Cp);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Cp), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetAdcCn (full: CmdIdhwAxs2GetAdcCn)
		*/
	class CmdGetAdcCn : public Cmd {

	public:
		CmdGetAdcCn();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Cn);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Cn), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetAdcSp (full: CmdIdhwAxs2GetAdcSp)
		*/
	class CmdGetAdcSp : public Cmd {

	public:
		CmdGetAdcSp();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Sp);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Sp), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetAdcSn (full: CmdIdhwAxs2GetAdcSn)
		*/
	class CmdGetAdcSn : public Cmd {

	public:
		CmdGetAdcSn();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Sn);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Sn), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetAdcVgmr (full: CmdIdhwAxs2GetAdcVgmr)
		*/
	class CmdGetAdcVgmr : public Cmd {

	public:
		CmdGetAdcVgmr();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vgmr);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const usmallint Vgmr), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetTickval (full: CmdIdhwAxs2GetTickval)
		*/
	class CmdGetTickval : public Cmd {

	public:
		CmdGetTickval();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const smallint tickval);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint tickval), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetTpi (full: CmdIdhwAxs2GetTpi)
		*/
	class CmdGetTpi : public Cmd {

	public:
		CmdGetTpi();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const smallint tickval);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint tickval), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* CmdGetAngle (full: CmdIdhwAxs2GetAngle)
		*/
	class CmdGetAngle : public Cmd {

	public:
		CmdGetAngle();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const smallint angle);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const smallint angle), void* _argReturnSpeccallback);
		void returnToCallback();
	};

public:
	UntIdhwAxs2(XchgIdhw* xchg, const uint ixVTarget);
	~UntIdhwAxs2();

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static CmdGetState* getNewCmdGetState();
	void getState(utinyint& tixVState, const unsigned int to = 0);

	static Cmd* getNewCmdSetVmot(const utinyint Vmot = 0);
	void setVmot(const utinyint Vmot, const unsigned int to = 0);

	static Cmd* getNewCmdSetMotdir(const utinyint tixVMotdir = 0);
	void setMotdir(const utinyint tixVMotdir, const unsigned int to = 0);

	static Cmd* getNewCmdSetSincosCoeff(const smallint Ox = 0, const smallint Oy = 0, const smallint Axm = 0, const smallint Aym = 0, const smallint phix = 0, const smallint phiy = 0);
	void setSincosCoeff(const smallint Ox, const smallint Oy, const smallint Axm, const smallint Aym, const smallint phix, const smallint phiy, const unsigned int to = 0);

	static Cmd* getNewCmdSetPidCoeff(const smallint Kp = 0, const smallint Ki = 0, const smallint Kd = 0);
	void setPidCoeff(const smallint Kp, const smallint Ki, const smallint Kd, const unsigned int to = 0);

	static CmdGetAdcCp* getNewCmdGetAdcCp();
	void getAdcCp(usmallint& Cp, const unsigned int to = 0);

	static CmdGetAdcCn* getNewCmdGetAdcCn();
	void getAdcCn(usmallint& Cn, const unsigned int to = 0);

	static CmdGetAdcSp* getNewCmdGetAdcSp();
	void getAdcSp(usmallint& Sp, const unsigned int to = 0);

	static CmdGetAdcSn* getNewCmdGetAdcSn();
	void getAdcSn(usmallint& Sn, const unsigned int to = 0);

	static CmdGetAdcVgmr* getNewCmdGetAdcVgmr();
	void getAdcVgmr(usmallint& Vgmr, const unsigned int to = 0);

	static CmdGetTickval* getNewCmdGetTickval();
	void getTickval(smallint& tickval, const unsigned int to = 0);

	static Cmd* getNewCmdSetTickval(const smallint tickval = 0);
	void setTickval(const smallint tickval, const unsigned int to = 0);

	static Cmd* getNewCmdSetTickvalMin(const smallint min = 0);
	void setTickvalMin(const smallint min, const unsigned int to = 0);

	static Cmd* getNewCmdSetTickvalMax(const smallint max = 0);
	void setTickvalMax(const smallint max, const unsigned int to = 0);

	static Cmd* getNewCmdSetTickvalTrg(const smallint trg = 0);
	void setTickvalTrg(const smallint trg, const unsigned int to = 0);

	static CmdGetTpi* getNewCmdGetTpi();
	void getTpi(smallint& tickval, const unsigned int to = 0);

	static CmdGetAngle* getNewCmdGetAngle();
	void getAngle(smallint& angle, const unsigned int to = 0);

	static Cmd* getNewCmdSetAngleMin(const smallint min = 0);
	void setAngleMin(const smallint min, const unsigned int to = 0);

	static Cmd* getNewCmdSetAngleMax(const smallint max = 0);
	void setAngleMax(const smallint max, const unsigned int to = 0);

	static Cmd* getNewCmdSetAngleTrg(const smallint trg = 0);
	void setAngleTrg(const smallint trg, const unsigned int to = 0);

};

#endif

