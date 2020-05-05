# Script taken from
# https://gist.github.com/itskenny0/df20bdb24a2f49b318a91195634ed3c6#file-cleanup-sh

# Crontab entries deleted, check only
crontab -l | grep 'http://'

# sudo crontab -l | sed '/54.36.185.99/d' | sudo crontab -
# sudo crontab -l | sed '/217.8.117.137/d' | sudo crontab -

# Delete and kill malicious processes
kill -9 $(pgrep salt-minions)
kill -9 $(pgrep salt-store)
rm -f /tmp/salt-minions
rm -f /var/tmp/salt-store
kill -9 $(pgrep -f ICEd)
rm -rf /tmp/.ICE*
rm -rf /var/tmp/.ICE*
rm /root/.wget-hsts

# create apparmor profiles to prevent execution
echo 'profile salt-store /var/tmp/salt-store { }' | sudo tee /etc/apparmor.d/salt-store
apparmor_parser -r -W /etc/apparmor.d/salt-store

echo 'profile salt-minions /tmp/salt-minions { }' | sudo tee /etc/apparmor.d/salt-minions
apparmor_parser -r -W /etc/apparmor.d/salt-minions

# reenable nmi watchdog
sysctl kernel.nmi_watchdog=1
echo '1' >/proc/sys/kernel/nmi_watchdog
sed -i '/kernel.nmi_watchdog/d' /etc/sysctl.conf

# disable hugepages
sysctl -w vm.nr_hugepages=0

# enable apparmor
systemctl enable apparmor
systemctl start apparmor

# fix syslog
touch /var/log/syslog
systemctl restart rsyslog
