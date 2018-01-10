/**
  * \file UntIdhwBss3_vecs.h
  * Digilent Basys3 unit vectors (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWBSS3_VECS_H
#define UNTIDHWBSS3_VECS_H

#include <sbecore/Xmlio.h>

using namespace Xmlio;

/**
	* VecVIdhwBss3Controller
	*/
namespace VecVIdhwBss3Controller {
	const utinyint CMDINV = 0x01;
	const utinyint CMDRET = 0x02;
	const utinyint ALUA = 0x03;
	const utinyint ALUB = 0x04;
	const utinyint DCXIF = 0x05;
	const utinyint LWIRACQ = 0x06;
	const utinyint LWIREMU = 0x07;
	const utinyint PHIIF = 0x08;
	const utinyint PMMU = 0x09;
	const utinyint QCDIF = 0x0A;
	const utinyint THETAIF = 0x0B;
	const utinyint TKCLKSRC = 0x0C;
	const utinyint TRIGGER = 0x0D;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	void fillFeed(Feed& feed);
};

/**
	* VecWIdhwBss3Buffer
	*/
namespace VecWIdhwBss3Buffer {
	const utinyint CMDRETTOHOSTIF = 0x01;
	const utinyint HOSTIFTOCMDINV = 0x02;
	const utinyint PMMUTOHOSTIF = 0x04;
	const utinyint DCXIFTOHOSTIF = 0x08;
	const utinyint HOSTIFTODCXIF = 0x10;
	const utinyint HOSTIFTOQCDIF = 0x20;
	const utinyint QCDIFTOHOSTIF = 0x40;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	void fillFeed(Feed& feed);
};

#endif

