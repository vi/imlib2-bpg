include commands.mk

BPGDIR=/home/vi/src/libbpg/

OPTS    := -O2
CFLAGS  := -std=c99 $(OPTS) $(shell pkg-config imlib2 --cflags) -fPIC -Wall -I${BPGDIR}
LDFLAGS := $(shell pkg-config imlib2 --libs) -L${BPGDIR} -lbpg


SRC = $(wildcard *.c)
OBJ = $(foreach obj, $(SRC:.c=.o), $(notdir $(obj)))
DEP = $(SRC:.c=.d)

LIBDIR    ?= $(shell pkg-config --variable=libdir imlib2)
LOADERDIR ?= $(LIBDIR)/imlib2/loaders/

ifndef DISABLE_DEBUG
	CFLAGS += -ggdb
endif

.PHONY: all clean

all: bpg.so

bpg.so: $(OBJ)
	$(CC) -shared -o $@ $^ $(LDFLAGS) 
	cp $@ $@.debug
	strip $@

%.o: %.c
	$(CC) -Wp,-MMD,$*.d -c $(CFLAGS) -o $@ $<

clean:
	$(RM) $(DEP)
	$(RM) $(OBJ)
	$(RM) bpg.so

install:
	$(INSTALL_DIR) $(DESTDIR)$(LOADERDIR)
	$(INSTALL_LIB) bpg.so $(DESTDIR)$(LOADERDIR)

uninstall:
	$(RM) $(PLUGINDIR)/bpg.so

-include $(DEP)

