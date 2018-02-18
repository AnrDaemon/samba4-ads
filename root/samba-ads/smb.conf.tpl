# Global parameters
[global]
	workgroup = @WORKGROUP@
	realm = @REALM@
;DC	netbios name = @HOSTNAME@
#	interfaces = lo, eth0
#	bind interfaces only = Yes

#	dedicated keytab file = /etc/krb5.keytab
#	kerberos method = secrets and keytab

#MS	security = ADS
#DC	server role = active directory domain controller
#DC	idmap_ldb:use rfc2307 = Yes

;DC	dns forwarder = @DNS_MASTER@

	load printers = No
	printing = bsd
	printcap name = /dev/null
#	printing = cups
#	printcap name = cups

	winbind use default domain = Yes
	winbind nss info = rfc2307
	winbind enum users = Yes
	winbind enum groups = Yes
	winbind refresh tickets = Yes
	winbind offline logon = Yes

	idmap config * : backend = tdb
#DC	idmap config * : schema_mode = rfc2307
	idmap config * : range = 1024-2047

	idmap config @WORKGROUP@ : backend = ad
	idmap config @WORKGROUP@ : schema_mode = rfc2307
	idmap config @WORKGROUP@ : range = 2048-131071

#	log level = 3 smb:0 auth:0 winbind:10 passdb:0 tdb:0 sam:0 idmap:10
#	log level = 3 smb:5 auth:5 winbind:0 passdb:0 tdb:0 sam:5 idmap:0
#	log level = smb:3 auth:3 winbind:0 passdb:0 tdb:0 sam:3 idmap:0
#	debug uid = yes
	log level = 1

	preload = homes
	vfs objects = acl_xattr
	map acl inherit = Yes
	dos charset = CP866
	store dos attributes = Yes

#DC	template homedir = /home/%U
#DC	template shell = /bin/bash

## Try fixing name browsing
#	domain master = No
#	local master = Yes
#	os level = 255
#MS	browse list = No

	panic action = /usr/share/samba/panic-action %d
	oplocks = No
	level2 oplocks = No

	server min protocol = SMB2
	client min protocol = SMB2
	client ipc min protocol = SMB2
	client ldap sasl wrapping = sign

#DC[netlogon]
#DC	path = /var/lib/samba/sysvol/@FQDN@/scripts
#DC	read only = No
#DC	csc policy = disable

#DC[sysvol]
#DC	path = /var/lib/samba/sysvol
#DC	read only = No
#DC	csc policy = disable

#MS[homes]
#MS	comment = Home Directory
#MS	path = /home/%S
#MS	valid users = %S
#MS	read only = No
#MS	browseable = No
#MS	csc policy = disable
#MS	follow symlinks = No

#MS[printers]
#MS	comment = All Printers
#MS	path = /var/spool/samba
#MS	printable = Yes
#MS	browseable = No
#MS	csc policy = disable

#MS[print$]
#MS	comment = Printer Drivers
#MS	path = /var/lib/samba/printers
