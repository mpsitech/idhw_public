#!/bin/bash
# file makeall.sh
# make script for Idhw device access library, release devidhw_genio
# author Alexander Wirthmueller
# date created: 22 Sep 2017
# modified: 22 Sep 2017

make DevIdhw.h.gch
if [ $? -ne 0 ]; then
	exit
fi

make -j4
if [ $? -ne 0 ]; then
	exit
fi

make install

