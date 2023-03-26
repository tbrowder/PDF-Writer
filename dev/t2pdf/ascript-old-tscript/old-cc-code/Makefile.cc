# Makefile for assorted utilities

INSTALLDIR = /usr/local

CFLAGS = -c

CC = g++
#DEBUG = -g
DEBUG = -g -Wall -Wno-unused
OPTIMIZE = -O3 -funroll-loops

EXT = cc

LIBS = -ltbrowde2 -lm

INCDIR = $(INSTALLDIR)/include/tbrowde
LIBDIR = $(INSTALLDIR)/lib/tbrowde
BINDIR = $(INSTALLDIR)/bin

PROG = tscript
TNAME = tscript

$(PROG): $(PROG).$(EXT)
	$(CC) $(CFLAGS) $(DEBUG) $(PROG).$(EXT) -I$(INCDIR)
	$(CC) -o $(PROG) $(PROG).o -L$(LIBDIR) $(LIBS)

install:
	touch $(PROG).$(EXT)
	$(CC) $(CFLAGS) $(OPTIMIZE) $(PROG).$(EXT) -I $(INCDIR)
	$(CC) -o $(PROG) $(PROG).o -L$(LIBDIR) $(LIBS)
	strip $(PROG)
	cp $(PROG) $(BINDIR)/$(TNAME)
#	$(foreach HOST, $(HOSTS), rcp $(PROG) $(HOST):$(BINDIR);)
	-rm $(PROG) $(PROG).o

clean:
	-rm *.bak *.sav *.o
