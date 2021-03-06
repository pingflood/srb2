#
# SRB2 for the RetroFW
#
# by pingflood; 2019
#

TARGET = srb2/srb2.dge

CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CC			:= $(CROSS_COMPILE)gcc
LD			:= $(CROSS_COMPILE)gcc
CXX			:= $(CROSS_COMPILE)g++
STRIP		:= $(CROSS_COMPILE)strip
OBJCOPY		:= $(CROSS_COMPILE)objcopy

SYSROOT     := $(shell $(CC) --print-sysroot)
SDL_CFLAGS  := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS    := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

export TARGET CHAINPREFIX CROSS_COMPILE CC LD CXX STRIP OBJCOPY SYSROOT SDL_CFLAGS SDL_LIBS

###############################################

all:
	make -C src $(TARGET)

clean:
	make -C src clean

ipk: all
	@rm -rf /tmp/.srb2-ipk/ && mkdir -p /tmp/.srb2-ipk/root/home/retrofw/games/srb2 /tmp/.srb2-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r ../srb2/drill.dta ../srb2/knux.plr ../srb2/music.dta ../srb2/rings.wpn ../srb2/soar.dta ../srb2/sonic.plr ../srb2/srb2.elf ../srb2/srb2.png ../srb2/srb2.srb ../srb2/tails.plr ../srb2/zones.dta /tmp/.srb2-ipk/root/home/retrofw/games/srb2
	@cp ../srb2/srb2.lnk /tmp/.srb2-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" ../srb2/control > /tmp/.srb2-ipk/control
	@cp ../srb2/conffiles ../srb2/preinst /tmp/.srb2-ipk/
	@chmod +x /tmp/.srb2-ipk/preinst
	@tar --owner=0 --group=0 -czvf /tmp/.srb2-ipk/control.tar.gz -C /tmp/.srb2-ipk/ control conffiles preinst
	@tar --owner=0 --group=0 -czvf /tmp/.srb2-ipk/data.tar.gz -C /tmp/.srb2-ipk/root/ .
	@echo 2.0 > /tmp/.srb2-ipk/debian-binary
	@ar r ../srb2/srb2.ipk /tmp/.srb2-ipk/control.tar.gz /tmp/.srb2-ipk/data.tar.gz /tmp/.srb2-ipk/debian-binary

opk: all
	@mksquashfs \
	srb2/default.retrofw.desktop \
	srb2/srb2.dge \
	srb2/srb2.png \
	srb2/drill.dta \
	srb2/knux.plr \
	srb2/music.dta \
	srb2/rings.wpn \
	srb2/soar.dta \
	srb2/sonic.plr \
	srb2/srb2.srb \
	srb2/tails.plr \
	srb2/zones.dta \
	srb2/srb2.opk \
	-all-root -noappend -no-exports -no-xattrs
