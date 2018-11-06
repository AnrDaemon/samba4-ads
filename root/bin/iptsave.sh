#!/bin/bash
cp --backup=numbered -aT -- /etc/network/if-up.d/iptables-rules /var/backups/iptables-rules
echo "#!/sbin/iptables-restore" > /etc/network/if-up.d/iptables-rules
iptables-save-ordered -r >> /etc/network/if-up.d/iptables-rules
chmod +x /etc/network/if-up.d/iptables-rules
