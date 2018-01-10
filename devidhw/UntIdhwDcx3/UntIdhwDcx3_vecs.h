/**
  * \file UntIdhwDcx3_vecs.h
  * dspcomplex3 unit vectors (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWDCX3_VECS_H
#define UNTIDHWDCX3_VECS_H

#include <sbecore/Xmlio.h>

using namespace Xmlio;

/**
	* VecVIdhwDcx3Controller
	*/
namespace VecVIdhwDcx3Controller {
	const utinyint CMDINV = 0x01;
	const utinyint CMDRET = 0x02;
	const utinyint ADXL = 0x03;
	const utinyint ALIGN = 0x04;
	const utinyint LED = 0x05;
	const utinyint LWIRACQ = 0x06;
	const utinyint LWIRIF = 0x07;
	const utinyint PHIIF = 0x08;
	const utinyint PMMU = 0x09;
	const utinyint QCDIF = 0x0A;
	const utinyint SHFBOX = 0x0B;
	const utinyint STATE = 0x0C;
	const utinyint THETAIF = 0x0D;
	const utinyint TKCLKSRC = 0x0E;
	const utinyint TRIGGER = 0x0F;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	void fillFeed(Feed& feed);
};

/**
	* VecVIdhwDcx3State
	*/
namespace VecVIdhwDcx3State {
	const utinyint NC = 0x00;
	const utinyint READY = 0x01;
	const utinyint ACTIVE = 0x02;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	string getTitle(const utinyint tix);

	void fillFeed(Feed& feed);
};

/**
	* VecWIdhwDcx3Buffer
	*/
namespace VecWIdhwDcx3Buffer {
	const utinyint CMDRETTOHOSTIF = 0x01;
	const utinyint HOSTIFTOCMDINV = 0x02;
	const utinyint PMMUTOHOSTIF = 0x04;
	const utinyint HOSTIFTOQCDIF = 0x08;
	const utinyint QCDIFTOHOSTIF = 0x10;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	void fillFeed(Feed& feed);
};

#endif

