prefix = ${DESTDIR}

#
# Settings
#

install:
	install -Dm755 "fontviewer.tcl" "${DESTDIR}/usr/bin/fontviewer"

uninstall:
	rm -f ${DESTDIR}/usr/bin/fontviewer
