BINDIR = /usr/local/bin

PROG     = tscript.p6
PROGLINK = tscript

## TESTING ##
PERL6     := perl6
LIBPATH   := lib

# set below to 0 for no effect, 1 to die on first failure
EARLYFAIL := PERL6_TEST_DIE_ON_FAIL=0

# set below for 0 for no effect and 1 to run Test::META
TA := TEST_AUTHOR=1

.PHONY:

default: test

TESTS     := t/*.t

test:
	for f in $(TESTS) ; do \
	    $(DEBUG) $(TA) $(EARLYFAIL) PERL6LIB=$(LIBPATH) prove -v --exec=$(PERL6) $$f ; \
	done

install:
	chmod +x $(PROG)
	cp -f $(PROG) $(BINDIR)
	ln -sf $(BINDIR)/$(PROG) $(BINDIR)/$(PROGLINK)

clean:
	-rm *~
