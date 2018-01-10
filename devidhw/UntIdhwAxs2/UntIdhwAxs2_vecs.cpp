/**
  * \file UntIdhwAxs2_vecs.cpp
  * axis2 unit vectors (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwAxs2_vecs.h"

/******************************************************************************
 namespace VecVIdhwAxs2Command
 ******************************************************************************/

utinyint VecVIdhwAxs2Command::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "getstate") return GETSTATE;
	else if (s == "setvmot") return SETVMOT;
	else if (s == "setmotdir") return SETMOTDIR;
	else if (s == "setsincoscoeff") return SETSINCOSCOEFF;
	else if (s == "setpidcoeff") return SETPIDCOEFF;
	else if (s == "getadccp") return GETADCCP;
	else if (s == "getadccn") return GETADCCN;
	else if (s == "getadcsp") return GETADCSP;
	else if (s == "getadcsn") return GETADCSN;
	else if (s == "getadcvgmr") return GETADCVGMR;
	else if (s == "gettickval") return GETTICKVAL;
	else if (s == "settickval") return SETTICKVAL;
	else if (s == "settickvalmin") return SETTICKVALMIN;
	else if (s == "settickvalmax") return SETTICKVALMAX;
	else if (s == "settickvaltrg") return SETTICKVALTRG;
	else if (s == "gettpi") return GETTPI;
	else if (s == "getangle") return GETANGLE;
	else if (s == "setanglemin") return SETANGLEMIN;
	else if (s == "setanglemax") return SETANGLEMAX;
	else if (s == "setangletrg") return SETANGLETRG;

	return(0);
};

string VecVIdhwAxs2Command::getSref(
			const utinyint tix
		) {
	if (tix == GETSTATE) return("getState");
	else if (tix == SETVMOT) return("setVmot");
	else if (tix == SETMOTDIR) return("setMotdir");
	else if (tix == SETSINCOSCOEFF) return("setSincosCoeff");
	else if (tix == SETPIDCOEFF) return("setPidCoeff");
	else if (tix == GETADCCP) return("getAdcCp");
	else if (tix == GETADCCN) return("getAdcCn");
	else if (tix == GETADCSP) return("getAdcSp");
	else if (tix == GETADCSN) return("getAdcSn");
	else if (tix == GETADCVGMR) return("getAdcVgmr");
	else if (tix == GETTICKVAL) return("getTickval");
	else if (tix == SETTICKVAL) return("setTickval");
	else if (tix == SETTICKVALMIN) return("setTickvalMin");
	else if (tix == SETTICKVALMAX) return("setTickvalMax");
	else if (tix == SETTICKVALTRG) return("setTickvalTrg");
	else if (tix == GETTPI) return("getTpi");
	else if (tix == GETANGLE) return("getAngle");
	else if (tix == SETANGLEMIN) return("setAngleMin");
	else if (tix == SETANGLEMAX) return("setAngleMax");
	else if (tix == SETANGLETRG) return("setAngleTrg");

	return("");
};

void VecVIdhwAxs2Command::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {GETSTATE,SETVMOT,SETMOTDIR,SETSINCOSCOEFF,SETPIDCOEFF,GETADCCP,GETADCCN,GETADCSP,GETADCSN,GETADCVGMR,GETTICKVAL,SETTICKVAL,SETTICKVALMIN,SETTICKVALMAX,SETTICKVALTRG,GETTPI,GETANGLE,SETANGLEMIN,SETANGLEMAX,SETANGLETRG};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 namespace VecVIdhwAxs2Motdir
 ******************************************************************************/

utinyint VecVIdhwAxs2Motdir::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "off") return OFF;
	else if (s == "cw") return CW;
	else if (s == "ccw") return CCW;

	return(0);
};

string VecVIdhwAxs2Motdir::getSref(
			const utinyint tix
		) {
	if (tix == OFF) return("off");
	else if (tix == CW) return("cw");
	else if (tix == CCW) return("ccw");

	return("");
};

string VecVIdhwAxs2Motdir::getTitle(
			const utinyint tix
		) {
	if (tix == OFF) return("off");
	else if (tix == CW) return("clockwise");
	else if (tix == CCW) return("counter-clockwise");

	return("");
};

void VecVIdhwAxs2Motdir::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {OFF,CW,CCW};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 namespace VecVIdhwAxs2State
 ******************************************************************************/

utinyint VecVIdhwAxs2State::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "nc") return NC;
	else if (s == "uncal") return UNCAL;
	else if (s == "actuc") return ACTUC;
	else if (s == "ready") return READY;
	else if (s == "active") return ACTIVE;

	return(0);
};

string VecVIdhwAxs2State::getSref(
			const utinyint tix
		) {
	if (tix == NC) return("nc");
	else if (tix == UNCAL) return("uncal");
	else if (tix == ACTUC) return("actuc");
	else if (tix == READY) return("ready");
	else if (tix == ACTIVE) return("active");

	return("");
};

string VecVIdhwAxs2State::getTitle(
			const utinyint tix
		) {
	if (tix == NC) return("offline");
	else if (tix == UNCAL) return("uncalibrated");
	else if (tix == ACTUC) return("in motion (uncalibrated)");
	else if (tix == READY) return("ready");
	else if (tix == ACTIVE) return("in motion");

	return("");
};

void VecVIdhwAxs2State::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {NC,UNCAL,ACTUC,READY,ACTIVE};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

