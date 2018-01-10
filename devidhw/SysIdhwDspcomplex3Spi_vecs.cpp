/**
  * \file SysIdhwDspcomplex3Spi_vecs.cpp
  * production-level dspcomplex3 board connected via SPI system (implementation of vectors)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

/******************************************************************************
 class SysIdhwDspcomplex3Spi::VecVTarget
 ******************************************************************************/

uint SysIdhwDspcomplex3Spi::VecVTarget::getIx(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "axs2.phi") return AXS2_PHI;
	else if (s == "axs2.theta") return AXS2_THETA;
	else if (s == "dcx3") return DCX3;
	else if (s == "icm2") return ICM2;
	else if (s == "tau2") return TAU2;

	return(0);
};

string SysIdhwDspcomplex3Spi::VecVTarget::getSref(
			const uint ix
		) {
	if (ix == AXS2_PHI) return("axs2.phi");
	else if (ix == AXS2_THETA) return("axs2.theta");
	else if (ix == DCX3) return("dcx3");
	else if (ix == ICM2) return("icm2");
	else if (ix == TAU2) return("tau2");

	return("");
};

void SysIdhwDspcomplex3Spi::VecVTarget::fillFeed(
			Feed& feed
		) {
	feed.clear();

	set<uint> items = {AXS2_PHI,AXS2_THETA,DCX3,ICM2,TAU2};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

