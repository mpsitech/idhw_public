/**
  * \file UntIdhwDcx3_vecs.cpp
  * dspcomplex3 unit vectors (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwDcx3_vecs.h"

/******************************************************************************
 namespace VecVIdhwDcx3Controller
 ******************************************************************************/

utinyint VecVIdhwDcx3Controller::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "cmdinv") return CMDINV;
	else if (s == "cmdret") return CMDRET;
	else if (s == "adxl") return ADXL;
	else if (s == "align") return ALIGN;
	else if (s == "led") return LED;
	else if (s == "lwiracq") return LWIRACQ;
	else if (s == "lwirif") return LWIRIF;
	else if (s == "phiif") return PHIIF;
	else if (s == "pmmu") return PMMU;
	else if (s == "qcdif") return QCDIF;
	else if (s == "shfbox") return SHFBOX;
	else if (s == "state") return STATE;
	else if (s == "thetaif") return THETAIF;
	else if (s == "tkclksrc") return TKCLKSRC;
	else if (s == "trigger") return TRIGGER;

	return(0);
};

string VecVIdhwDcx3Controller::getSref(
			const utinyint tix
		) {
	if (tix == CMDINV) return("cmdinv");
	else if (tix == CMDRET) return("cmdret");
	else if (tix == ADXL) return("adxl");
	else if (tix == ALIGN) return("align");
	else if (tix == LED) return("led");
	else if (tix == LWIRACQ) return("lwiracq");
	else if (tix == LWIRIF) return("lwirif");
	else if (tix == PHIIF) return("phiif");
	else if (tix == PMMU) return("pmmu");
	else if (tix == QCDIF) return("qcdif");
	else if (tix == SHFBOX) return("shfbox");
	else if (tix == STATE) return("state");
	else if (tix == THETAIF) return("thetaif");
	else if (tix == TKCLKSRC) return("tkclksrc");
	else if (tix == TRIGGER) return("trigger");

	return("");
};

void VecVIdhwDcx3Controller::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {CMDINV,CMDRET,ADXL,ALIGN,LED,LWIRACQ,LWIRIF,PHIIF,PMMU,QCDIF,SHFBOX,STATE,THETAIF,TKCLKSRC,TRIGGER};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 namespace VecVIdhwDcx3State
 ******************************************************************************/

utinyint VecVIdhwDcx3State::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "nc") return NC;
	else if (s == "ready") return READY;
	else if (s == "active") return ACTIVE;

	return(0);
};

string VecVIdhwDcx3State::getSref(
			const utinyint tix
		) {
	if (tix == NC) return("nc");
	else if (tix == READY) return("ready");
	else if (tix == ACTIVE) return("active");

	return("");
};

string VecVIdhwDcx3State::getTitle(
			const utinyint tix
		) {
	if (tix == NC) return("offline");
	else if (tix == READY) return("ready");
	else if (tix == ACTIVE) return("trigger running");

	return("");
};

void VecVIdhwDcx3State::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {NC,READY,ACTIVE};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 namespace VecWIdhwDcx3Buffer
 ******************************************************************************/

utinyint VecWIdhwDcx3Buffer::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "cmdrettohostif") return CMDRETTOHOSTIF;
	else if (s == "hostiftocmdinv") return HOSTIFTOCMDINV;
	else if (s == "pmmutohostif") return PMMUTOHOSTIF;
	else if (s == "hostiftoqcdif") return HOSTIFTOQCDIF;
	else if (s == "qcdiftohostif") return QCDIFTOHOSTIF;

	return(0);
};

string VecWIdhwDcx3Buffer::getSref(
			const utinyint tix
		) {
	if (tix == CMDRETTOHOSTIF) return("cmdretToHostif");
	else if (tix == HOSTIFTOCMDINV) return("hostifToCmdinv");
	else if (tix == PMMUTOHOSTIF) return("pmmuToHostif");
	else if (tix == HOSTIFTOQCDIF) return("hostifToQcdif");
	else if (tix == QCDIFTOHOSTIF) return("qcdifToHostif");

	return("");
};

void VecWIdhwDcx3Buffer::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {CMDRETTOHOSTIF,HOSTIFTOCMDINV,PMMUTOHOSTIF,HOSTIFTOQCDIF,QCDIFTOHOSTIF};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

