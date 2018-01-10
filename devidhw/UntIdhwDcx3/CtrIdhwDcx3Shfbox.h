/**
  * \file CtrIdhwDcx3Shfbox.h
  * shfbox controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWDCX3SHFBOX_H
#define CTRIDHWDCX3SHFBOX_H

#include "Idhw.h"

#define VecVIdhwDcx3ShfboxCommand CtrIdhwDcx3Shfbox::VecVCommand
#define VecVIdhwDcx3ShfboxGpiocfg CtrIdhwDcx3Shfbox::VecVGpiocfg
#define VecVIdhwDcx3ShfboxLedcfg CtrIdhwDcx3Shfbox::VecVLedcfg
#define VecVIdhwDcx3ShfboxSpicfg CtrIdhwDcx3Shfbox::VecVSpicfg

/**
	* CtrIdhwDcx3Shfbox
	*/
class CtrIdhwDcx3Shfbox : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwDcx3ShfboxCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETSPICFG = 0x00;
		static const utinyint SETGPIOCFG = 0x01;
		static const utinyint SETLEDCFG = 0x02;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

	/**
		* VecVGpiocfg (full: VecVIdhwDcx3ShfboxGpiocfg)
		*/
	class VecVGpiocfg {

	public:
		static const utinyint VISLVISR = 0x00;
		static const utinyint VISRVISL = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

	/**
		* VecVLedcfg (full: VecVIdhwDcx3ShfboxLedcfg)
		*/
	class VecVLedcfg {

	public:
		static const utinyint LED15LED60 = 0x00;
		static const utinyint LED60LED15 = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

	/**
		* VecVSpicfg (full: VecVIdhwDcx3ShfboxSpicfg)
		*/
	class VecVSpicfg {

	public:
		static const utinyint THETAPHIQCD = 0x00;
		static const utinyint THETAQCDPHI = 0x01;
		static const utinyint PHITHETAQCD = 0x02;
		static const utinyint PHIQCDTHETA = 0x03;
		static const utinyint QCDTHETAPHI = 0x04;
		static const utinyint QCDPHITHETA = 0x05;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static string getTitle(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwDcx3Shfbox(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x0B;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetSpicfg(const utinyint tixVSpicfg = 0);
	void setSpicfg(const utinyint tixVSpicfg, const unsigned int to = 0);

	static Cmd* getNewCmdSetGpiocfg(const utinyint tixVGpiocfg = 0);
	void setGpiocfg(const utinyint tixVGpiocfg, const unsigned int to = 0);

	static Cmd* getNewCmdSetLedcfg(const utinyint tixVLedcfg = 0);
	void setLedcfg(const utinyint tixVLedcfg, const unsigned int to = 0);

};

#endif

