#!/bin/sh
mkdir /tmp/cachedistr
cd /tmp/cachedistr
iptables -I INPUT 5 -p tcp -m tcp --dport 1972 -j ACCEPT
iptables -I INPUT 6 -p tcp -m tcp --dport 57772 -j ACCEPT
service iptables save
service iptables restart
wget https://mywebsite.com/cache-2015.2.1.705.0-lnxrhx64.tar.gz
wget https://mywebsite.com/sninstaller.xml

tar -zxvf cache-2015.2.1.705.0-lnxrhx64.tar.gz

ISC_PACKAGE_UNICODE="Y" ISC_PACKAGE_INSTANCENAME="CACHE" ISC_PACKAGE_INSTALLDIR="/usr/cache" ISC_INSTALLER_MANIFEST="/tmp/cachedistr/sninstaller.xml" ./cinstall_silent

wget https://mywebsite.com/cache.key
cp cache.key /usr/cache/mgr/cache.key
csession CACHE -UUSER "##class(%SYSTEM.License).Upgrade"
