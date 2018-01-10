/**
  * \file UntIdhwZedb_vecs.cpp
  * ZedBoard unit vectors (implementation)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#include "UntIdhwZedb_vecs.h"

/******************************************************************************
 namespace VecVIdhwZedbController
 ******************************************************************************/

utinyint VecVIdhwZedbController::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "cmdinv") return CMDINV;
	else if (s == "cmdret") return CMDRET;
	else if (s == "alua") return ALUA;
	else if (s == "alub") return ALUB;
	else if (s == "dcxif") return DCXIF;
	else if (s == "lwiracq") return LWIRACQ;
	else if (s == "lwiremu") return LWIREMU;
	else if (s == "phiif") return PHIIF;
	else if (s == "pmmu") return PMMU;
	else if (s == "qcdif") return QCDIF;
	else if (s == "thetaif") return THETAIF;
	else if (s == "tkclksrc") return TKCLKSRC;
	else if (s == "trigger") return TRIGGER;

	return(0);
};

string VecVIdhwZedbController::getSref(
			const utinyint tix
		) {
	if (tix == CMDINV) return("cmdinv");
	else if (tix == CMDRET) return("cmdret");
	else if (tix == ALUA) return("alua");
	else if (tix == ALUB) return("alub");
	else if (tix == DCXIF) return("dcxif");
	else if (tix == LWIRACQ) return("lwiracq");
	else if (tix == LWIREMU) return("lwiremu");
	else if (tix == PHIIF) return("phiif");
	else if (tix == PMMU) return("pmmu");
	else if (tix == QCDIF) return("qcdif");
	else if (tix == THETAIF) return("thetaif");
	else if (tix == TKCLKSRC) return("tkclksrc");
	else if (tix == TRIGGER) return("trigger");

	return("");
};

void VecVIdhwZedbController::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {CMDINV,CMDRET,ALUA,ALUB,DCXIF,LWIRACQ,LWIREMU,PHIIF,PMMU,QCDIF,THETAIF,TKCLKSRC,TRIGGER};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 namespace VecWIdhwZedbBuffer
 ******************************************************************************/

utinyint VecWIdhwZedbBuffer::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "cmdrettohostif") return CMDRETTOHOSTIF;
	else if (s == "hostiftocmdinv") return HOSTIFTOCMDINV;
	else if (s == "pmmutohostif") return PMMUTOHOSTIF;
	else if (s == "dcxiftohostif") return DCXIFTOHOSTIF;
	else if (s == "hostiftodcxif") return HOSTIFTODCXIF;
	else if (s == "hostiftoqcdif") return HOSTIFTOQCDIF;
	else if (s == "qcdiftohostif") return QCDIFTOHOSTIF;

	return(0);
};

string VecWIdhwZedbBuffer::getSref(
			const utinyint tix
		) {
	if (tix == CMDRETTOHOSTIF) return("cmdretToHostif");
	else if (tix == HOSTIFTOCMDINV) return("hostifToCmdinv");
	else if (tix == PMMUTOHOSTIF) return("pmmuToHostif");
	else if (tix == DCXIFTOHOSTIF) return("dcxifToHostif");
	else if (tix == HOSTIFTODCXIF) return("hostifToDcxif");
	else if (tix == HOSTIFTOQCDIF) return("hostifToQcdif");
	else if (tix == QCDIFTOHOSTIF) return("qcdifToHostif");

	return("");
};

void VecWIdhwZedbBuffer::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<utinyint> items = {CMDRETTOHOSTIF,HOSTIFTOCMDINV,PMMUTOHOSTIF,DCXIFTOHOSTIF,HOSTIFTODCXIF,HOSTIFTOQCDIF,QCDIFTOHOSTIF};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

