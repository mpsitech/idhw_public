#!/bin/bash
# file checkin.sh
# checkin script for ZedBoard unit of Idhw embedded system code, release idhw_ungenio
# author Alexander Wirthmueller
# date created: 22 Sep 2017
# modified: 22 Sep 2017

export set REPROOT=/Users/mpsitech/srcrep

cp zedb.srcs/constrs_1/imports/zedb/*.xdc $REPROOT/idhw/idhw/zedb/
cp zedb.srcs/sources_1/imports/zedb/*.vhd $REPROOT/idhw/idhw/zedb/

