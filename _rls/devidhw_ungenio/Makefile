# file Makefile
# make file for Idhw device access library, release devidhw_ungenio
# author Alexander Wirthmueller
# date created: 22 Sep 2017
# modified: 22 Sep 2017

SRCROOT = /Users/mpsitech/src
LIBROOT = /Users/mpsitech/lib

CPP = g++
CPPFLAGS = -std=c++11 -g -Wall -Os -pthread

STATLIB = ar
STATLIBFLAGS = rcs

INCPATH = -I$(SRCROOT)
INCPATH = -I/usr/local/include -I/usr/local/include/libxml2

PCHS = DevIdhw.h.gch

OBJS = Idhw.o
OBJS += SysIdhwBasys3Fwd.o SysIdhwDspcomplex3Spi.o SysIdhwZedboardFwd.o
OBJS += UntIdhwAxs2.o UntIdhwAxs2_vecs.o
OBJS += UntIdhwBss3.o UntIdhwBss3_vecs.o CtrIdhwBss3Alua.o CtrIdhwBss3Alub.o CtrIdhwBss3Dcxif.o CtrIdhwBss3Lwiracq.o CtrIdhwBss3Lwiremu.o CtrIdhwBss3Phiif.o CtrIdhwBss3Pmmu.o CtrIdhwBss3Qcdif.o CtrIdhwBss3Thetaif.o CtrIdhwBss3Tkclksrc.o CtrIdhwBss3Trigger.o
OBJS += UntIdhwDcx3.o UntIdhwDcx3_vecs.o CtrIdhwDcx3Adxl.o CtrIdhwDcx3Align.o CtrIdhwDcx3Led.o CtrIdhwDcx3Lwiracq.o CtrIdhwDcx3Lwirif.o CtrIdhwDcx3Phiif.o CtrIdhwDcx3Pmmu.o CtrIdhwDcx3Qcdif.o CtrIdhwDcx3Shfbox.o CtrIdhwDcx3State.o CtrIdhwDcx3Thetaif.o CtrIdhwDcx3Tkclksrc.o CtrIdhwDcx3Trigger.o
OBJS += UntIdhwIcm2.o UntIdhwIcm2_vecs.o CtrIdhwIcm2Acq.o CtrIdhwIcm2Fan.o CtrIdhwIcm2Roic.o CtrIdhwIcm2State.o CtrIdhwIcm2Sync.o CtrIdhwIcm2Temp.o CtrIdhwIcm2Tkclksrc.o CtrIdhwIcm2Vmon.o CtrIdhwIcm2Vset.o CtrIdhwIcm2Wavegen.o
OBJS += UntIdhwTau2.o UntIdhwTau2_vecs.o
OBJS += UntIdhwZedb.o UntIdhwZedb_vecs.o CtrIdhwZedbAlua.o CtrIdhwZedbAlub.o CtrIdhwZedbDcxif.o CtrIdhwZedbLwiracq.o CtrIdhwZedbLwiremu.o CtrIdhwZedbPhiif.o CtrIdhwZedbPmmu.o CtrIdhwZedbQcdif.o CtrIdhwZedbThetaif.o CtrIdhwZedbTkclksrc.o CtrIdhwZedbTrigger.o

LIB = libdevidhw

.SUFFIXES: .h .h.gch .cpp

.h.h.gch :
	$(CPP) $(CPPFLAGS) $(INCPATH) -o $@ -c $<

.cpp.o:
	$(CPP) $(CPPFLAGS) $(INCPATH) -o $@ -c $<

all:	$(LIB)

$(LIB):	$(PCHS) $(OBJS)
	$(STATLIB) $(STATLIBFLAGS) $(LIB).a $(OBJS)
	rm -f *.o

install:
	mv $(LIB).a $(LIBROOT)/

clean: 
	rm -f *.gch
	rm -f *.o

