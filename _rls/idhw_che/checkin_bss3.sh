#!/bin/bash
# file checkin.sh
# checkin script for Digilent Basys3 unit of Idhw embedded system code, release idhw_che
# author Alexander Wirthmueller
# date created: 22 Sep 2017
# modified: 22 Sep 2017

export set REPROOT=/home/mpsitech/srcrep

cp bss3.srcs/constrs_1/imports/bss3/*.xdc $REPROOT/idhw/idhw/bss3/
cp bss3.srcs/sources_1/imports/bss3/*.vhd $REPROOT/idhw/idhw/bss3/

