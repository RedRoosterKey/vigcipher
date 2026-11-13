# Portable build for vigcipher.
#
#   make                  build ./vigcipher
#   make test             run the test suite against ./vigcipher
#   make install          install to $(PREFIX) (default /usr/local)
#   make uninstall        remove what `make install` put in place
#   make test-asan        build with AddressSanitizer and run memory checks
#   make version          interactively set the version in src/version.h
#
# Honours the usual variables that package managers set: CC, CFLAGS,
# CPPFLAGS, LDFLAGS, LDLIBS, PREFIX, BINDIR, MANDIR and DESTDIR, e.g.
#
#   make install PREFIX=/usr DESTDIR=/tmp/stage

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man
DESTDIR ?=

CC      ?= cc
CFLAGS  ?= -O2 -Wall
INSTALL ?= install

PROG = vigcipher
SRC  = src/vigcipher.c
HDRS = src/version.h
MAN  = man/vigcipher.1

# -std and -D are required by the source, so they are kept apart from
# CFLAGS: a packager overriding CFLAGS should not have to repeat them.
BUILD_CPPFLAGS = -D_GNU_SOURCE $(CPPFLAGS)
BUILD_CFLAGS   = -std=c99 $(CFLAGS)

all: $(PROG)

$(PROG): $(SRC) $(HDRS)
	$(CC) $(BUILD_CPPFLAGS) $(BUILD_CFLAGS) $(LDFLAGS) -o $@ $(SRC) $(LDLIBS)

test: $(PROG)
	VIGCIPHER="$(CURDIR)/$(PROG)" bash scripts/test.sh

test-asan:
	bash scripts/test-asan.sh

version:
	bash scripts/version.sh

install: $(PROG)
	$(INSTALL) -d "$(DESTDIR)$(BINDIR)" "$(DESTDIR)$(MANDIR)/man1"
	$(INSTALL) -m 755 $(PROG) "$(DESTDIR)$(BINDIR)/$(PROG)"
	$(INSTALL) -m 644 $(MAN) "$(DESTDIR)$(MANDIR)/man1/$(PROG).1"

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)/$(PROG)" "$(DESTDIR)$(MANDIR)/man1/$(PROG).1"

clean:
	rm -rf $(PROG) $(PROG).dSYM $(PROG)_asan $(PROG)_asan.dSYM

.PHONY: all test test-asan version install uninstall clean
