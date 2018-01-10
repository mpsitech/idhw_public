/**
  * \file CtrIdhwDcx3Led.h
  * led controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWDCX3LED_H
#define CTRIDHWDCX3LED_H

#include "Idhw.h"

#define VecVIdhwDcx3LedCommand CtrIdhwDcx3Led::VecVCommand

/**
	* CtrIdhwDcx3Led
	*/
class CtrIdhwDcx3Led : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwDcx3LedCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETTON15 = 0x00;
		static const utinyint SETTON60 = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwDcx3Led(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x05;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetTon15(const utinyint ton15 = 0);
	void setTon15(const utinyint ton15, const unsigned int to = 0);

	static Cmd* getNewCmdSetTon60(const utinyint ton60 = 0);
	void setTon60(const utinyint ton60, const unsigned int to = 0);

};

#endif

