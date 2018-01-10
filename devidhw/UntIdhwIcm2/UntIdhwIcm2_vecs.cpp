/**
  * \file UntIdhwIcm2_vecs.cpp
  * icacam2 unit vectors (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwIcm2_vecs.h"

/******************************************************************************
 namespace VecVIdhwIcm2Controller
 ******************************************************************************/

utinyint VecVIdhwIcm2Controller::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "cmdinv") return CMDINV;
	else if (s == "cmdret") return CMDRET;
	else if (s == "acq") return ACQ;
	else if (s == "fan") return FAN;
	else if (s == "roic") return ROIC;
	else if (s == "state") return STATE;
	else if (s == "sync") return SYNC;
	else if (s == "temp") return TEMP;
	else if (s == "tkclksrc") return TKCLKSRC;
	else if (s == "vmon") return VMON;
	else if (s == "vset") return VSET;
	else if (s == "wavegen") return WAVEGEN;

	return(0);
};

string VecVIdhwIcm2Controller::getSref(
			const utinyint tix
		) {
	if (tix == CMDINV) return("cmdinv");
	else if (tix == CMDRET) return("cmdret");
	else if (tix == ACQ) return("acq");
	else if (tix == FAN) return("fan");
	else if (tix == ROIC) return("roic");
	else if (tix == STATE) return("state");
	else if (tix == SYNC) return("sync");
	else if (tix == TEMP) return("temp");
	else if (tix == TKCLKSRC) return("tkclksrc");
	else if (tix == VMON) return("vmon");
	else if (tix == VSET) return("vset");
	else if (tix == WAVEGEN) return("wavegen");

	return("");
};

void VecVIdhwIcm2Controller::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {CMDINV,CMDRET,ACQ,FAN,ROIC,STATE,SYNC,TEMP,TKCLKSRC,VMON,VSET,WAVEGEN};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 namespace VecVIdhwIcm2State
 ******************************************************************************/

utinyint VecVIdhwIcm2State::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "nc") return NC;
	else if (s == "cool") return COOL;
	else if (s == "ready") return READY;
	else if (s == "active") return ACTIVE;

	return(0);
};

string VecVIdhwIcm2State::getSref(
			const utinyint tix
		) {
	if (tix == NC) return("nc");
	else if (tix == COOL) return("cool");
	else if (tix == READY) return("ready");
	else if (tix == ACTIVE) return("active");

	return("");
};

string VecVIdhwIcm2State::getTitle(
			const utinyint tix
		) {
	if (tix == NC) return("offline");
	else if (tix == COOL) return("cooling");
	else if (tix == READY) return("ready");
	else if (tix == ACTIVE) return("acquisition running");

	return("");
};

void VecVIdhwIcm2State::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {NC,COOL,READY,ACTIVE};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 namespace VecWIdhwIcm2Buffer
 ******************************************************************************/

utinyint VecWIdhwIcm2Buffer::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "cmdrettohostif") return CMDRETTOHOSTIF;
	else if (s == "hostiftocmdinv") return HOSTIFTOCMDINV;
	else if (s == "acqtohostif") return ACQTOHOSTIF;
	else if (s == "hostiftowavegen") return HOSTIFTOWAVEGEN;

	return(0);
};

string VecWIdhwIcm2Buffer::getSref(
			const utinyint tix
		) {
	if (tix == CMDRETTOHOSTIF) return("cmdretToHostif");
	else if (tix == HOSTIFTOCMDINV) return("hostifToCmdinv");
	else if (tix == ACQTOHOSTIF) return("acqToHostif");
	else if (tix == HOSTIFTOWAVEGEN) return("hostifToWavegen");

	return("");
};

void VecWIdhwIcm2Buffer::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {CMDRETTOHOSTIF,HOSTIFTOCMDINV,ACQTOHOSTIF,HOSTIFTOWAVEGEN};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

