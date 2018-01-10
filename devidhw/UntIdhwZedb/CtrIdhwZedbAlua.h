/**
  * \file CtrIdhwZedbAlua.h
  * alua controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWZEDBALUA_H
#define CTRIDHWZEDBALUA_H

#include "Idhw.h"

#define CmdIdhwZedbAluaValget CtrIdhwZedbAlua::CmdValget

#define VecVIdhwZedbAluaCommand CtrIdhwZedbAlua::VecVCommand
#define VecVIdhwZedbAluaError CtrIdhwZedbAlua::VecVError
#define VecVIdhwZedbAluaReg CtrIdhwZedbAlua::VecVReg

/**
	* CtrIdhwZedbAlua
	*/
class CtrIdhwZedbAlua : public CtrIdhw {

public:
	/**
		* CmdValget (full: CmdIdhwZedbAluaValget)
		*/
	class CmdValget : public Cmd {

	public:
		CmdValget();

	public:
		void (*returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* r1Val, const size_t r1Vallen, const unsigned char* r2Val, const size_t r2Vallen, const unsigned char* r3Val, const size_t r3Vallen, const unsigned char* r4Val, const size_t r4Vallen);
		void* argReturnSpeccallback;

	public:
		void setReturnSpeccallback(void (*_returnSpeccallback)(Cmd* cmd, void* arg, const unsigned char* r1Val, const size_t r1Vallen, const unsigned char* r2Val, const size_t r2Vallen, const unsigned char* r3Val, const size_t r3Vallen, const unsigned char* r4Val, const size_t r4Vallen), void* _argReturnSpeccallback);
		void returnToCallback();
	};

	/**
		* VecVCommand (full: VecVIdhwZedbAluaCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint ADD = 0x00;
		static const utinyint SUB = 0x01;
		static const utinyint MULT = 0x02;
		static const utinyint DIV = 0x03;
		static const utinyint POW = 0x04;
		static const utinyint LGCAND = 0x05;
		static const utinyint LGCOR = 0x06;
		static const utinyint LGCXOR = 0x07;
		static const utinyint LGCNOT = 0x08;
		static const utinyint VALSET = 0x09;
		static const utinyint VALGET = 0x0A;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

	/**
		* VecVError (full: VecVIdhwZedbAluaError)
		*/
	class VecVError {

	public:
		static const utinyint INVALID = 0x00;
		static const utinyint MISMATCH = 0x01;
		static const utinyint SIZE = 0x02;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);
	};

	/**
		* VecVReg (full: VecVIdhwZedbAluaReg)
		*/
	class VecVReg {

	public:
		static const utinyint VOID = 0x00;
		static const utinyint R0 = 0x01;
		static const utinyint R1 = 0x02;
		static const utinyint S0 = 0x03;
		static const utinyint S1 = 0x04;
		static const utinyint S2 = 0x05;
		static const utinyint S3 = 0x06;
		static const utinyint T0 = 0x07;
		static const utinyint T1 = 0x08;
		static const utinyint T2 = 0x09;
		static const utinyint T3 = 0x0A;
		static const utinyint T4 = 0x0B;
		static const utinyint T5 = 0x0C;
		static const utinyint T6 = 0x0D;
		static const utinyint T7 = 0x0E;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwZedbAlua(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x03;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdAdd(const utinyint aTixVReg = 0, const utinyint bTixVReg = 0, const utinyint cTixVReg = 0);
	void add(const utinyint aTixVReg, const utinyint bTixVReg, const utinyint cTixVReg, const unsigned int to = 0);

	static Cmd* getNewCmdSub(const utinyint aTixVReg = 0, const utinyint bTixVReg = 0, const utinyint cTixVReg = 0);
	void sub(const utinyint aTixVReg, const utinyint bTixVReg, const utinyint cTixVReg, const unsigned int to = 0);

	static Cmd* getNewCmdMult(const utinyint aTixVReg = 0, const utinyint bTixVReg = 0, const utinyint cTixVReg = 0);
	void mult(const utinyint aTixVReg, const utinyint bTixVReg, const utinyint cTixVReg, const unsigned int to = 0);

	static Cmd* getNewCmdDiv(const utinyint aTixVReg = 0, const utinyint bTixVReg = 0, const utinyint cTixVReg = 0);
	void div(const utinyint aTixVReg, const utinyint bTixVReg, const utinyint cTixVReg, const unsigned int to = 0);

	static Cmd* getNewCmdPow(const utinyint aTixVReg = 0, const utinyint exp = 0, const utinyint cTixVReg = 0);
	void pow(const utinyint aTixVReg, const utinyint exp, const utinyint cTixVReg, const unsigned int to = 0);

	static Cmd* getNewCmdLgcand(const utinyint aTixVReg = 0, const utinyint bTixVReg = 0, const utinyint cTixVReg = 0);
	void lgcand(const utinyint aTixVReg, const utinyint bTixVReg, const utinyint cTixVReg, const unsigned int to = 0);

	static Cmd* getNewCmdLgcor(const utinyint aTixVReg = 0, const utinyint bTixVReg = 0, const utinyint cTixVReg = 0);
	void lgcor(const utinyint aTixVReg, const utinyint bTixVReg, const utinyint cTixVReg, const unsigned int to = 0);

	static Cmd* getNewCmdLgcxor(const utinyint aTixVReg = 0, const utinyint bTixVReg = 0, const utinyint cTixVReg = 0);
	void lgcxor(const utinyint aTixVReg, const utinyint bTixVReg, const utinyint cTixVReg, const unsigned int to = 0);

	static Cmd* getNewCmdLgcnot(const utinyint aTixVReg = 0, const utinyint cTixVReg = 0);
	void lgcnot(const utinyint aTixVReg, const utinyint cTixVReg, const unsigned int to = 0);

	static Cmd* getNewCmdValset(const utinyint r1TixVReg = 0, const unsigned char* r1Val = NULL, const size_t r1Vallen = 0, const utinyint r2TixVReg = 0, const unsigned char* r2Val = NULL, const size_t r2Vallen = 0, const utinyint r3TixVReg = 0, const unsigned char* r3Val = NULL, const size_t r3Vallen = 0, const utinyint r4TixVReg = 0, const unsigned char* r4Val = NULL, const size_t r4Vallen = 0);
	void valset(const utinyint r1TixVReg, const unsigned char* r1Val, const size_t r1Vallen, const utinyint r2TixVReg, const unsigned char* r2Val, const size_t r2Vallen, const utinyint r3TixVReg, const unsigned char* r3Val, const size_t r3Vallen, const utinyint r4TixVReg, const unsigned char* r4Val, const size_t r4Vallen, const unsigned int to = 0);

	static CmdValget* getNewCmdValget(const utinyint r1TixVReg = 0, const utinyint r2TixVReg = 0, const utinyint r3TixVReg = 0, const utinyint r4TixVReg = 0);
	void valget(const utinyint r1TixVReg, const utinyint r2TixVReg, const utinyint r3TixVReg, const utinyint r4TixVReg, unsigned char*& r1Val, size_t& r1Vallen, unsigned char*& r2Val, size_t& r2Vallen, unsigned char*& r3Val, size_t& r3Vallen, unsigned char*& r4Val, size_t& r4Vallen, const unsigned int to = 0);

	static string getSrefByTixVError(const utinyint tixVError);
	static string getTitleByTixVError(const utinyint tixVError);

	static Err getNewErr(const utinyint tixVError);

	static Err getNewErrInvalid();
	static Err getNewErrMismatch();
	static Err getNewErrSize();
};

#endif

