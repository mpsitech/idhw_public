/**
  * \file SysIdhwBasys3Fwd_vecs.cpp
  * SPI command forwarder based on Digilent Basys3 board system (implementation of vectors)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

/******************************************************************************
 class SysIdhwBasys3Fwd::VecVTarget
 ******************************************************************************/

uint SysIdhwBasys3Fwd::VecVTarget::getIx(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "axs2.phi") return AXS2_PHI;
	else if (s == "axs2.theta") return AXS2_THETA;
	else if (s == "bss3") return BSS3;
	else if (s == "dcx3") return DCX3;
	else if (s == "dcx3.axs2.phi") return DCX3_AXS2_PHI;
	else if (s == "dcx3.axs2.theta") return DCX3_AXS2_THETA;
	else if (s == "dcx3.icm2") return DCX3_ICM2;
	else if (s == "dcx3.tau2") return DCX3_TAU2;
	else if (s == "icm2") return ICM2;

	return(0);
};

string SysIdhwBasys3Fwd::VecVTarget::getSref(
			const uint ix
		) {
	if (ix == AXS2_PHI) return("axs2.phi");
	else if (ix == AXS2_THETA) return("axs2.theta");
	else if (ix == BSS3) return("bss3");
	else if (ix == DCX3) return("dcx3");
	else if (ix == DCX3_AXS2_PHI) return("dcx3.axs2.phi");
	else if (ix == DCX3_AXS2_THETA) return("dcx3.axs2.theta");
	else if (ix == DCX3_ICM2) return("dcx3.icm2");
	else if (ix == DCX3_TAU2) return("dcx3.tau2");
	else if (ix == ICM2) return("icm2");

	return("");
};

void SysIdhwBasys3Fwd::VecVTarget::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<uint> items = {AXS2_PHI,AXS2_THETA,BSS3,DCX3,DCX3_AXS2_PHI,DCX3_AXS2_THETA,DCX3_ICM2,DCX3_TAU2,ICM2};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

