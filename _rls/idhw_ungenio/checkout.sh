#!/bin/bash
# file checkout.sh
# checkout script for Idhw embedded system code, release idhw_ungenio
# author Alexander Wirthmueller
# date created: 22 Sep 2017
# modified: 22 Sep 2017

export set FPGAROOT=

if [ $? -ne 0 ]; then
	exit
fi

if [ "$1" = "all" ]; then
	unts=("bss3" "dcx3" "icm2" "zedb")
else
	unts=("$@")
fi;

for var in "${unts[@]}"
do
	cp checkin_"$var".sh $FPGAROOT/"$var"/checkin.sh
	if [ "$var" = "dcx3" ] || [ "$var" = "icm2" ]; then
		cp ../../idhw/"$var"/*.ucf $FPGAROOT/"$var"/
		cp ../../idhw/"$var"/*.vhd $FPGAROOT/"$var"/
	else
		cp ../../idhw/"$var"/*.xdc $FPGAROOT/"$var"/"$var".srcs/constrs_1/imports/"$var"/
		cp ../../idhw/"$var"/*.vhd $FPGAROOT/"$var"/"$var".srcs/sources_1/imports/"$var"/
	fi
done

