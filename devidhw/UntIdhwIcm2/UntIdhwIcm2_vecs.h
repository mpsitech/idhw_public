/**
  * \file UntIdhwIcm2_vecs.h
  * icacam2 unit vectors (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWICM2_VECS_H
#define UNTIDHWICM2_VECS_H

#include <sbecore/Xmlio.h>

using namespace Xmlio;

/**
	* VecVIdhwIcm2Controller
	*/
namespace VecVIdhwIcm2Controller {
	const utinyint CMDINV = 0x01;
	const utinyint CMDRET = 0x02;
	const utinyint ACQ = 0x03;
	const utinyint FAN = 0x04;
	const utinyint ROIC = 0x05;
	const utinyint STATE = 0x06;
	const utinyint SYNC = 0x07;
	const utinyint TEMP = 0x08;
	const utinyint TKCLKSRC = 0x09;
	const utinyint VMON = 0x0A;
	const utinyint VSET = 0x0B;
	const utinyint WAVEGEN = 0x0C;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	void fillFeed(Feed& feed);
};

/**
	* VecVIdhwIcm2State
	*/
namespace VecVIdhwIcm2State {
	const utinyint NC = 0x00;
	const utinyint COOL = 0x01;
	const utinyint READY = 0x02;
	const utinyint ACTIVE = 0x03;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	string getTitle(const utinyint tix);

	void fillFeed(Feed& feed);
};

/**
	* VecWIdhwIcm2Buffer
	*/
namespace VecWIdhwIcm2Buffer {
	const utinyint CMDRETTOHOSTIF = 0x01;
	const utinyint HOSTIFTOCMDINV = 0x02;
	const utinyint ACQTOHOSTIF = 0x04;
	const utinyint HOSTIFTOWAVEGEN = 0x08;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	void fillFeed(Feed& feed);
};

#endif

