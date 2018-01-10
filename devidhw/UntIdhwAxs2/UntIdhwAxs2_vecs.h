/**
  * \file UntIdhwAxs2_vecs.h
  * axis2 unit vectors (declarations)
  * \author Alexander Wirthmueller
  * \date created: 22 Sep 2017
  * \date modified: 22 Sep 2017
  */

#ifndef UNTIDHWAXS2_VECS_H
#define UNTIDHWAXS2_VECS_H

#include <sbecore/Xmlio.h>

using namespace Xmlio;

/**
	* VecVIdhwAxs2Command
	*/
namespace VecVIdhwAxs2Command {
	const utinyint GETSTATE = 0x00;
	const utinyint SETVMOT = 0x01;
	const utinyint SETMOTDIR = 0x02;
	const utinyint SETSINCOSCOEFF = 0x03;
	const utinyint SETPIDCOEFF = 0x04;
	const utinyint GETADCCP = 0x05;
	const utinyint GETADCCN = 0x06;
	const utinyint GETADCSP = 0x07;
	const utinyint GETADCSN = 0x08;
	const utinyint GETADCVGMR = 0x09;
	const utinyint GETTICKVAL = 0x0A;
	const utinyint SETTICKVAL = 0x0B;
	const utinyint SETTICKVALMIN = 0x0C;
	const utinyint SETTICKVALMAX = 0x0D;
	const utinyint SETTICKVALTRG = 0x0E;
	const utinyint GETTPI = 0x0F;
	const utinyint GETANGLE = 0x10;
	const utinyint SETANGLEMIN = 0x11;
	const utinyint SETANGLEMAX = 0x12;
	const utinyint SETANGLETRG = 0x13;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	void fillFeed(Feed& feed);
};

/**
	* VecVIdhwAxs2Motdir
	*/
namespace VecVIdhwAxs2Motdir {
	const utinyint OFF = 0x00;
	const utinyint CW = 0x01;
	const utinyint CCW = 0x02;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	string getTitle(const utinyint tix);

	void fillFeed(Feed& feed);
};

/**
	* VecVIdhwAxs2State
	*/
namespace VecVIdhwAxs2State {
	const utinyint NC = 0x00;
	const utinyint UNCAL = 0x01;
	const utinyint ACTUC = 0x02;
	const utinyint READY = 0x03;
	const utinyint ACTIVE = 0x04;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	string getTitle(const utinyint tix);

	void fillFeed(Feed& feed);
};

#endif

