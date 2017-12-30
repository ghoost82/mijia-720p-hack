TOOLCHAINDIR = /usr/src/arm-linux-3.3/toolchain_gnueabi-4.4.0_ARMv5TE/usr/bin
PATH := $(TOOLCHAINDIR):$(PATH)
TARGET = arm-unknown-linux-uclibcgnueabi
BUILDENV := \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=${TARGET}-ld \
	NM=$(TARGET)-nm \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip

TOPDIR := $(CURDIR)
SOURCEDIR := src
PREFIXDIR := prefix
BUILDDIR := build
INSTALLDIR := sdcard/mijia-720p-hack/bin
GMLIBDIR := gm_lib/gm_lib
RTSPDDIR := gm_lib/product/GM8136_1MP/samples
GMSAMPLEDIR := $(GMLIBDIR)/samples

BINS = smbpasswd scp dbclient arm-php arm-php-cgi
SBINS = dropbear lighttpd smbd

ZLIBVERSION = 1.2.11
ZLIBARCHIVE = zlib-$(ZLIBVERSION).tar.gz
ZLIBURI = https://www.zlib.net/$(ZLIBARCHIVE)
LIBXML2VERSION = 2.9.7
LIBXML2ARCHIVE = libxml2-$(LIBXML2VERSION).tar.gz
LIBXML2URI = ftp://xmlsoft.org/libxml2/$(LIBXML2ARCHIVE)
LIBJPEGVERSION = 1.5.2
LIBJPEGARCHIVE = libjpeg-turbo-$(LIBJPEGVERSION).tar.gz
LIBJPEGURI = https://prdownloads.sourceforge.net/libjpeg-turbo/$(LIBJPEGARCHIVE)
LIBPNGVERSION = 1.6.34
LIBPNGARCHIVE = libpng-$(LIBPNGVERSION).tar.gz
LIBPNGURI = https://prdownloads.sourceforge.net/libpng/$(LIBPNGARCHIVE)
LIBGDVERSION = 2.2.4
LIBGDARCHIVE = libgd-$(LIBGDVERSION).tar.gz
LIBGDURI = https://github.com/libgd/libgd/releases/download/gd-$(LIBGDVERSION)/$(LIBGDARCHIVE)
PCREVERSION = 8.41
PCREARCHIVE = pcre-$(PCREVERSION).zip
PCREURI = https://ftp.pcre.org/pub/pcre/$(PCREARCHIVE)
DROPBEARVERSION = 2017.75
DROPBEARARCHIVE = dropbear-$(DROPBEARVERSION).tar.bz2
DROPBEARURI = https://matt.ucc.asn.au/dropbear/releases/$(DROPBEARARCHIVE)
LIGHTTPDVERSION = 1.4.48
LIGHTTPDARCHIVE = lighttpd-$(LIGHTTPDVERSION).tar.gz
LIGHTTPDURI = https://download.lighttpd.net/lighttpd/releases-1.4.x/$(LIGHTTPDARCHIVE)
PHPVERSION = 7.2.0
PHPARCHIVE = php-$(PHPVERSION).tar.bz2
PHPURI = http://php.net/get/$(PHPARCHIVE)/from/this/mirror
SAMBAVERSION = 3.6.25
SAMBAARCHIVE = samba-$(SAMBAVERSION).tar.gz
SAMBAURI = https://download.samba.org/pub/samba/$(SAMBAARCHIVE)

SAMPLES := display_with_encode \
           liveview_with_clearwin \
           liveview_with_pip \
           encode_capture_substream \
           encode_with_deinterlace \
           encode_with_osd \
           encode_with_roi \
           encode_force_keyframe \
           encode_with_snapshot \
           encode_with_watermark_and_vui \
           encode_with_capture_motion_detection \
           encode_with_capture_motion_detection2 \
           encode_with_capture_tamper_detection \
           encode_with_capture_tamper_detection2 \
           encode_update_notification \
           encode_with_advance_feature \
           encode_with_getraw \
           encode_with_getraw2 \
           encode_with_eptz \
           encode_with_av_sync \
           audio_record \
           audio_playback \
           audio_livesound

.PHONY: all libs fetch-sources

all: $(BUILDDIR)/dropbear $(BUILDDIR)/lighttpd $(BUILDDIR)/php $(BUILDDIR)/samba sdcard/manufacture.bin gm_lib/rtspd

libs: $(BUILDDIR)/zlib $(BUILDDIR)/libxml2 $(BUILDDIR)/libjpeg-turbo $(BUILDDIR)/libpng $(BUILDDIR)/libgd $(BUILDDIR)/pcre

fetch-sources: $(SOURCEDIR)/$(ZLIBARCHIVE) $(SOURCEDIR)/$(LIBXML2ARCHIVE) $(SOURCEDIR)/$(LIBJPEGARCHIVE) $(SOURCEDIR)/$(LIBPNGARCHIVE) $(SOURCEDIR)/$(LIBGDARCHIVE) $(SOURCEDIR)/$(PCREARCHIVE) $(SOURCEDIR)/$(DROPBEARARCHIVE) $(SOURCEDIR)/$(LIGHTTPDARCHIVE) $(SOURCEDIR)/$(PHPARCHIVE) $(SOURCEDIR)/$(SAMBAARCHIVE)

samples: gm_lib/$(SAMPLES)

$(SOURCEDIR)/$(ZLIBARCHIVE):
	mkdir -p $(TOPDIR)/$(SOURCEDIR) && \
	wget -t 2 -T 10 -c -O $@ $(ZLIBURI)

$(SOURCEDIR)/$(LIBXML2ARCHIVE):
	mkdir -p $(TOPDIR)/$(SOURCEDIR) && \
	wget -t 2 -T 10 -c -O $@ $(LIBXML2URI)

$(SOURCEDIR)/$(LIBJPEGARCHIVE):
	mkdir -p $(TOPDIR)/$(SOURCEDIR) && \
	wget -t 2 -T 10 -c -O $@ $(LIBJPEGURI)

$(SOURCEDIR)/$(LIBPNGARCHIVE):
	mkdir -p $(TOPDIR)/$(SOURCEDIR) && \
	wget -t 2 -T 10 -c -O $@ $(LIBPNGURI)

$(SOURCEDIR)/$(LIBGDARCHIVE):
	mkdir -p $(TOPDIR)/$(SOURCEDIR) && \
	wget -t 2 -T 10 -c -O $@ $(LIBGDURI)

$(SOURCEDIR)/$(PCREARCHIVE):
	mkdir -p $(TOPDIR)/$(SOURCEDIR) && \
	wget -t 2 -T 10 -c -O $@ $(PCREURI)

$(SOURCEDIR)/$(DROPBEARARCHIVE):
	mkdir -p $(TOPDIR)/$(SOURCEDIR) && \
	wget -t 2 -T 10 -c -O $@ $(DROPBEARURI)

$(SOURCEDIR)/$(LIGHTTPDARCHIVE):
	mkdir -p $(TOPDIR)/$(SOURCEDIR) && \
	wget -t 2 -T 10 -c -O $@ $(LIGHTTPDURI)

$(SOURCEDIR)/$(PHPARCHIVE):
	mkdir -p $(TOPDIR)/$(SOURCEDIR) && \
	wget -t 2 -T 10 -c -O $@ $(PHPURI)

$(SOURCEDIR)/$(SAMBAARCHIVE):
	mkdir -p $(TOPDIR)/$(SOURCEDIR) && \
	wget -t 2 -T 10 -c -O $@ $(SAMBAURI)


$(BUILDDIR)/zlib: $(SOURCEDIR)/$(ZLIBARCHIVE)
	mkdir -p $(TOPDIR)/$(BUILDDIR) && rm -rf $@-$(ZLIBVERSION)
	tar -xzf $(TOPDIR)/$(SOURCEDIR)/$(ZLIBARCHIVE) -C $(TOPDIR)/$(BUILDDIR)
	cd $@-$(ZLIBVERSION) && \
		$(BUILDENV) \
		./configure \
			--prefix=$(TOPDIR)/$(PREFIXDIR) \
			--static	&& \
		make && \
		make install
	rm -rf $@-$(ZLIBVERSION)
	touch $@

$(BUILDDIR)/libxml2: $(SOURCEDIR)/$(LIBXML2ARCHIVE) $(BUILDDIR)/zlib
	mkdir -p $(TOPDIR)/$(BUILDDIR) && rm -rf $@-$(LIBXML2VERSION)
	tar -xzf $(TOPDIR)/$(SOURCEDIR)/$(LIBXML2ARCHIVE) -C $(TOPDIR)/$(BUILDDIR)
	cd $@-$(LIBXML2VERSION) && \
		$(BUILDENV) \
		ARCH=arm \
		Z_CFLAGS="-DHAVE_ZLIB_H=1 -DHAVE_LIBZ=1 -I$(TOPDIR)/$(PREFIXDIR)/include" \
		./configure \
			--prefix=$(TOPDIR)/$(PREFIXDIR) \
			--host=$(TARGET) \
			--disable-shared \
			--enable-static \
			--with-zlib=$(TOPDIR)/$(PREFIXDIR) \
			--without-python \
			--without-iconv \
			--without-lzma && \
		make && \
		make install
	rm -rf $@-$(LIBXML2VERSION)
	touch $@

$(BUILDDIR)/libjpeg-turbo: $(SOURCEDIR)/$(LIBJPEGARCHIVE)
	mkdir -p $(TOPDIR)/$(BUILDDIR) && rm -rf $@-$(LIBJPEGVERSION)
	tar -xzf $(TOPDIR)/$(SOURCEDIR)/$(LIBJPEGARCHIVE) -C $(TOPDIR)/$(BUILDDIR)
	cd $@-$(LIBJPEGVERSION) && \
		$(BUILDENV) \
		./configure \
			--prefix=$(TOPDIR)/$(PREFIXDIR) \
			--host=$(TARGET) \
			--disable-shared \
			--enable-static && \
		make && \
		make install
	rm -rf $@-$(LIBJPEGVERSION)
	touch $@

$(BUILDDIR)/libpng: $(SOURCEDIR)/$(LIBPNGARCHIVE)
	mkdir -p $(TOPDIR)/$(BUILDDIR) && rm -rf $@-$(LIBPNGVERSION)
	tar -xzf $(TOPDIR)/$(SOURCEDIR)/$(LIBPNGARCHIVE) -C $(TOPDIR)/$(BUILDDIR)
	cd $@-$(LIBPNGVERSION) && \
		$(BUILDENV) \
		LDFLAGS="-L$(TOPDIR)/$(PREFIXDIR)/lib" \
		CPPFLAGS="-I$(TOPDIR)/$(PREFIXDIR)/include" \
		./configure \
			--prefix=$(TOPDIR)/$(PREFIXDIR) \
			--host=$(TARGET) \
			--disable-shared \
			--enable-static && \
		make && \
		make install
	rm -rf $@-$(LIBPNGVERSION)
	touch $@

$(BUILDDIR)/libgd: $(SOURCEDIR)/$(LIBGDARCHIVE) $(BUILDDIR)/zlib $(BUILDDIR)/libjpeg-turbo $(BUILDDIR)/libpng
	mkdir -p $(TOPDIR)/$(BUILDDIR) && rm -rf $@-$(LIBGDVERSION)
	tar -xzf $(TOPDIR)/$(SOURCEDIR)/$(LIBGDARCHIVE) -C $(TOPDIR)/$(BUILDDIR)
	cd $@-$(LIBGDVERSION) && \
		$(BUILDENV) \
		ARCH=arm \
		./configure \
			--prefix=$(TOPDIR)/$(PREFIXDIR) \
			--host=$(TARGET) \
			--disable-shared \
			--enable-static \
			--with-jpeg=$(TOPDIR)/$(PREFIXDIR) \
			--with-png=$(TOPDIR)/$(PREFIXDIR) \
			--with-zlib=$(TOPDIR)/$(PREFIXDIR) \
			--without-tiff \
			--without-freetype \
			--without-fontconfig && \
		make && \
		make install
	rm -rf $@-$(LIBGDVERSION)
	touch $@

$(BUILDDIR)/pcre: $(SOURCEDIR)/$(PCREARCHIVE) $(BUILDDIR)/zlib
	mkdir -p $(TOPDIR)/$(BUILDDIR) && rm -rf $@-$(PCREVERSION)
	unzip -q $(TOPDIR)/$(SOURCEDIR)/$(PCREARCHIVE) -d $(TOPDIR)/$(BUILDDIR)
	cd $@-$(PCREVERSION) && \
		$(BUILDENV) \
		./configure \
			--prefix=$(TOPDIR)/$(PREFIXDIR) \
			--host=$(TARGET) \
			--disable-shared \
			--enable-static && \
		make && \
		make install
	rm -rf $@-$(PCREVERSION)
	touch $@

$(BUILDDIR)/dropbear: $(SOURCEDIR)/$(DROPBEARARCHIVE) $(BUILDDIR)/zlib
	mkdir -p $(TOPDIR)/$(BUILDDIR) && rm -rf $@-$(DROPBEARVERSION)
	tar -xjf $(TOPDIR)/$(SOURCEDIR)/$(DROPBEARARCHIVE) -C $(TOPDIR)/$(BUILDDIR)
	sed -i 's|\(#define DROPBEAR_PATH_SSH_PROGRAM\).*|\1 "/tmp/sd/ft/dbclient"|' $@-$(DROPBEARVERSION)/options.h
	sed -i 's|\(#define DEFAULT_PATH\).*|\1 "/bin:/sbin:/usr/bin:/usr/sbin:/tmp/sd/ft:/mnt/data/ft"|' $@-$(DROPBEARVERSION)/options.h
	cd $@-$(DROPBEARVERSION) && \
		$(BUILDENV) \
		./configure \
			--prefix=$(TOPDIR)/$(PREFIXDIR) \
			--host=$(TARGET) \
			--with-zlib=$(TOPDIR)/$(PREFIXDIR) \
			--disable-wtmp \
			--disable-lastlog && \
		make PROGRAMS="dropbear scp dbclient dropbearkey" MULTI=0 STATIC=1 && \
		make PROGRAMS="dropbear scp dbclient dropbearkey" MULTI=0 STATIC=1 install
	rm -rf $@-$(DROPBEARVERSION)
	touch $@

$(BUILDDIR)/lighttpd: $(SOURCEDIR)/$(LIGHTTPDARCHIVE) $(BUILDDIR)/zlib $(BUILDDIR)/pcre
	mkdir -p $(TOPDIR)/$(BUILDDIR) && rm -rf $@-$(LIGHTTPDVERSION)
	tar -xzf $(TOPDIR)/$(SOURCEDIR)/$(LIGHTTPDARCHIVE) -C $(TOPDIR)/$(BUILDDIR)
	for i in access accesslog alias auth authn_file cgi compress deflate dirlisting evasive expire extforward fastcgi flv_streaming indexfile proxy redirect rewrite rrdtool scgi secdownload setenv simple_vhost ssi staticfile status uploadprogress userdir usertrack vhostdb webdav; do \
		echo "PLUGIN_INIT(mod_$$i)" >> $@-$(LIGHTTPDVERSION)/src/plugin-static.h; \
	done
	cd $@-$(LIGHTTPDVERSION) && \
		$(BUILDENV) \
		LIGHTTPD_STATIC=yes \
		CPPFLAGS=-DLIGHTTPD_STATIC \
		./configure \
			--prefix=$(TOPDIR)/$(PREFIXDIR) \
			--host=$(TARGET) \
			--disable-shared \
			--enable-static \
			--with-zlib=$(TOPDIR)/$(PREFIXDIR) \
			--with-pcre=$(TOPDIR)/$(PREFIXDIR) \
			--without-mysql \
			--without-bzip2 && \
		make && \
		make install
	rm -rf $@-$(LIGHTTPDVERSION)
	touch $@

#--target=arm->$(TARGET)

$(BUILDDIR)/php: $(SOURCEDIR)/$(PHPARCHIVE) $(BUILDDIR)/zlib $(BUILDDIR)/libxml2 $(BUILDDIR)/libjpeg-turbo $(BUILDDIR)/libpng $(BUILDDIR)/pcre $(BUILDDIR)/libgd
	mkdir -p $(TOPDIR)/$(BUILDDIR) && rm -rf $@-$(PHPVERSION)
	tar -xjf $(TOPDIR)/$(SOURCEDIR)/$(PHPARCHIVE) -C $(TOPDIR)/$(BUILDDIR)
	sed -i -e '/.*hp_ini_register_extensions.*/d' $@-$(PHPVERSION)/main/main.c
	cd $@-$(PHPVERSION) && \
		$(BUILDENV) \
		LIBS='-ldl' \
		./configure \
			--prefix=$(TOPDIR)/$(PREFIXDIR) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--program-prefix="arm-" \
			--with-config-file-path=$(TOPDIR)/$(TOOLSDIR)/etc \
			--with-libxml-dir=$(TOPDIR)/$(PREFIXDIR) \
			--with-jpeg-dir=$(TOPDIR)/$(PREFIXDIR) \
			--with-png-dir=$(TOPDIR)/$(PREFIXDIR) \
			--enable-pdo \
			--enable-simplexml \
			--enable-json \
			--enable-sockets \
			--enable-fpm \
			--enable-libxml \
			--enable-ftp \
			--enable-mbstring \
			--enable-mbregex \
			--enable-mbregex-backtrack \
			--enable-hash \
			--enable-xml \
			--enable-session \
			--enable-soap \
			--enable-tokenizer \
			--enable-xmlreader \
			--enable-xmlwriter \
			--enable-dom \
			--enable-zip \
			--disable-mbregex \
			--disable-opcache \
			--with-mhash \
			--with-pdo-mysql \
			--with-sqlite3 \
			--with-pdo-sqlite \
			--with-xmlrpc \
			--with-zlib \
			--with-pcre-regex \
			--with-pcre-jit \
			--with-gd \
			--with-xpm-dir=no \
			--without-pear \
			--without-xsl \
			--disable-all && \
		make && \
		make install-binaries
	rm -rf $@-$(PHPVERSION)
	touch $@

$(BUILDDIR)/samba: $(SOURCEDIR)/$(SAMBAARCHIVE)
	mkdir -p $(TOPDIR)/$(BUILDDIR) && rm -rf $@-$(SAMBAVERSION)
	tar -xzf $(TOPDIR)/$(SOURCEDIR)/$(SAMBAARCHIVE) -C $(TOPDIR)/$(BUILDDIR)
	cd $@-$(SAMBAVERSION)/source3 && \
		$(BUILDENV) \
		./autogen.sh && \
		./configure \
			--prefix=$(TOPDIR)/$(PREFIXDIR) \
			--host=$(TARGET) \
			--target=$(TARGET) \
			--disable-shared \
			--enable-static \
			--enable-swat=no \
			--enable-shared-libs=no \
			--disable-cups \
			--with-configdir=/tmp/sd/mijia-720p-hack/etc \
			--with-nmbdsocketdir=/tmp/sd/mijia-720p-hack/tmp/samba \
			--with-winbind=no \
			--with-sys-quotas=no \
			--without-krb5 \
			--without-ldap \
			--without-ads \
			libreplace_cv_HAVE_GETADDRINFO=no \
			ac_cv_file__proc_sys_kernel_core_pattern=yes \
			samba_cv_USE_SETRESUID=yes \
			samba_cv_CC_NEGATIVE_ENUM_VALUES=yes && \
		for i in smbd nmbd smbpasswd; do \
			make bin/$$i; \
		done && \
		make installservers && \
		make installbin
	rm -rf $@-$(SAMBAVERSION)
	touch $@

sdcard/manufacture.bin:
	tar -cf $(TOPDIR)/sdcard/manufacture.bin manufacture/test_drv


gm_lib/rtspd: 
	$(TARGET)-gcc -Wall -I$(GMLIBDIR)/inc $(RTSPDDIR)/$(@F).c $(RTSPDDIR)/librtsp.a -L$(GMLIBDIR)/lib -lpthread -lm -lrt -lgm -o $@

gm_lib/$(SAMPLES):
	$(TARGET)-gcc -Wall -I$(GMLIBDIR)/inc -L$(GMLIBDIR)/lib -lpthread -lgm $(GMSAMPLEDIR)/$(@F).c -o $@

.PHONY: install uninstall

install: all
	mkdir -p $(TOPDIR)/$(INSTALLDIR)
	cd $(TOPDIR)/$(PREFIXDIR)/bin && cp $(BINS) $(TOPDIR)/$(INSTALLDIR)
	cd $(TOPDIR)/$(PREFIXDIR)/sbin && cp $(SBINS) $(TOPDIR)/$(INSTALLDIR)
	cp gm_lib/rtspd $(TOPDIR)/$(INSTALLDIR)
	$(TARGET)-strip $(TOPDIR)/$(INSTALLDIR)/*

uninstall:
	cd $(TOPDIR)/$(INSTALLDIR) && rm -f $(BINS) $(SBINS) rtspd

.PHONY: sourceclean clean distclean

sourceclean:
	rm -rf $(TOPDIR)/$(SOURCEDIR)

clean:
	rm -rf $(TOPDIR)/$(BUILDDIR)
	rm -rf $(TOPDIR)/$(PREFIXDIR)
	rm -rf gm_lib/rtsp gm_lib/$(SAMPLES)

distclean: clean sourceclean
