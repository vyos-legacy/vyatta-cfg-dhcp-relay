cfgdir		 = $(datadir)/vyatta-cfg/templates

sbin_SCRIPTS =

sbin_SCRIPTS += scripts/system/dhcrelay.init
sbin_SCRIPTS += scripts/system/dhcrelay-starter.pl


cpiop = find  . ! -regex '\(.*~\|.*\.bak\|.*\.swp\|.*\#.*\#\)' -print0 | cpio -0pd

install-exec-hook:
	mkdir -p $(DESTDIR)$(cfgdir)
	cd templates; $(cpiop) $(DESTDIR)$(cfgdir)

