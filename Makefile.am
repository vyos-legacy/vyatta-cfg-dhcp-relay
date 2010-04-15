cfgdir		 = $(datadir)/vyatta-cfg/templates
opdir		 = $(datadir)/vyatta-op/templates

sbin_SCRIPTS =

sbin_SCRIPTS += scripts/system/dhcrelay.init
sbin_SCRIPTS += scripts/system/dhcrelay-starter.pl
sbin_SCRIPTS += scripts/system/dhcv6relay.init
sbin_SCRIPTS += scripts/system/dhcv6relay-starter.pl
sbin_SCRIPTS += scripts/system/dhcv6relay-status.pl

curverdir = $(sysconfdir)/config-migrate/current
curver_DATA = cfg-version/dhcp-relay@1

cpiop = find  . ! -regex '\(.*~\|.*\.bak\|.*\.swp\|.*\#.*\#\)' -print0 | cpio -0pd

all-local:
	./gen-templates.pl

clean-local:
	rm -rf generated-templates

install-exec-hook:
	mkdir -p $(DESTDIR)$(cfgdir)
	cd templates; $(cpiop) $(DESTDIR)$(cfgdir) ; cd ..
	cd generated-templates; $(cpiop) $(DESTDIR)$(cfgdir) ; cd ..
	cd templates-op; $(cpiop) $(DESTDIR)$(opdir) ; cd ..

