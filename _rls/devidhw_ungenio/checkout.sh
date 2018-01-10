# file checkout.sh
# checkout script for Idhw device access library sources, release devidhw_ungenio
# author Alexander Wirthmueller
# date created: 22 Sep 2017
# modified: 22 Sep 2017

export set SRCROOT=/Users/mpsitech/src

mkdir $SRCROOT/devidhw

cp makeall.sh $SRCROOT/devidhw/

cp Makefile $SRCROOT/devidhw/

cp ../../devidhw/*.h $SRCROOT/devidhw/
cp ../../devidhw/*.cpp $SRCROOT/devidhw/

cp ../../devidhw/UntIdhwAxs2/*.h $SRCROOT/devidhw/
cp ../../devidhw/UntIdhwAxs2/*.cpp $SRCROOT/devidhw/

cp ../../devidhw/UntIdhwBss3/*.h $SRCROOT/devidhw/
cp ../../devidhw/UntIdhwBss3/*.cpp $SRCROOT/devidhw/

cp ../../devidhw/UntIdhwDcx3/*.h $SRCROOT/devidhw/
cp ../../devidhw/UntIdhwDcx3/*.cpp $SRCROOT/devidhw/

cp ../../devidhw/UntIdhwIcm2/*.h $SRCROOT/devidhw/
cp ../../devidhw/UntIdhwIcm2/*.cpp $SRCROOT/devidhw/

cp ../../devidhw/UntIdhwTau2/*.h $SRCROOT/devidhw/
cp ../../devidhw/UntIdhwTau2/*.cpp $SRCROOT/devidhw/

cp ../../devidhw/UntIdhwZedb/*.h $SRCROOT/devidhw/
cp ../../devidhw/UntIdhwZedb/*.cpp $SRCROOT/devidhw/

