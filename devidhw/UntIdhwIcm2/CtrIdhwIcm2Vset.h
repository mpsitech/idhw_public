/**
  * \file CtrIdhwIcm2Vset.h
  * vset controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef CTRIDHWICM2VSET_H
#define CTRIDHWICM2VSET_H

#include "Idhw.h"

#define VecVIdhwIcm2VsetCommand CtrIdhwIcm2Vset::VecVCommand

/**
	* CtrIdhwIcm2Vset
	*/
class CtrIdhwIcm2Vset : public CtrIdhw {

public:
	/**
		* VecVCommand (full: VecVIdhwIcm2VsetCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETVDD = 0x00;
		static const utinyint SETVREF = 0x01;
		static const utinyint SETVTEC = 0x02;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrIdhwIcm2Vset(XchgIdhw* xchg, const uint ixVTarget, const ubigint uref);

public:
	static const utinyint tixVController = 0x0B;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetVdd(const usmallint Vdd = 0);
	void setVdd(const usmallint Vdd, const unsigned int to = 0);

	static Cmd* getNewCmdSetVref(const usmallint Vref = 0);
	void setVref(const usmallint Vref, const unsigned int to = 0);

	static Cmd* getNewCmdSetVtec(const usmallint Vtec = 0);
	void setVtec(const usmallint Vtec, const unsigned int to = 0);

};

#endif

