prefix = $(DESTDIR)

#
# Settings
#

install:
	cp fontviewer.tcl $(DESTDIR)/usr/bin/fontviewer
	chmod 755 $(DESTDIR)/usr/bin/fontviewer

uninstall:
	rm -f $(DESTDIR)/usr/bin/fontviewer
