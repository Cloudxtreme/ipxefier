#!/bin/sh

rm /var/cache/pkg/All/*.txz 2>&1 > /dev/null
pkg update -qf 2>&1 > /dev/null
pkg install -qfy bash 2>&1 > /dev/null

if [ "$SHELL" == "/bin/csh" ]; then (export SHELL=bash; bash $0); fi
if [ "$SHELL" == "/bin/csh" ]; then exit; fi
(
## Update the system
sed -i '' '/sleep/d' `which freebsd-update` # Removing the random sleep
freebsd-update cron && freebsd-update install # Fetch doesn't run non-interactively, so we use cron.
pkg upgrade -fy
pkg install -fy git pigz gmake gcc # gmake and gcc just for ipxe
if [ `sysctl vm.kmem_size | cut -d ' ' -f 2` -gt 8004781312 ]; then
	mkdir /root/mfsbsd
	mount -t tmpfs tmpfs /root/mfsbsd
	mount -t tmpfs tmpfs /usr/src
	mount -t tmpfs tmpfs /usr/obj
	mount -t tmpfs tmpfs /usr/ports
else
	rm -r /usr/src/*
	rm -r /usr/obj/*
fi
rm /var/cache/pkg/All/*.txz
cp `which pigz` `which gzip`

pkg install -fy git gmake gcc
ln -s /usr/local/bin/gcc4* /usr/local/bin/gcc # This will need to be fixed if gcc is updated past 4.x.
git clone --depth 1 git://git.ipxe.org/ipxe.git
cd ipxe/src
cp config/*.h config/local/
cp ~/.baker/config.ipxe .
gmake
gmake bin/undionly.kpxe EMBED=config.ipxe

cd

git clone -b stable/10 --depth 1 'http://github.com/freebsd/freebsd.git' /usr/src
git clone --depth 1 'http://github.com/mmatuska/mfsbsd.git' /root/mfsbsd

cd /usr/src
sed -I '' -e '/hyperv/d' -e '/gdb/d' -e '/KDB/d' -e '/CTF/d' -e '/OFFLOAD/d' /usr/src/sys/amd64/conf/GENERIC # Smaller kernel
NCPU=`sysctl kern.smp.cpus | cut -d ' ' -f 2`
make buildworld -j $NCPU
make installworld

cd /root/mfsbsd
sed -I '' '/man/d' tools/prunelist # Yay, man pages!
cp `which pkg-static` tools/
yes | pkg fetch -d dnsmasq
ln -s /var/cache/pkg/All/ packages
mkdir -p customfiles/usr/local/etc/
sed -I '' 's@/packages/$${FILE};@/packages/$${FILE} || true;@' Makefile 

cp ~/.baker/dnsmasq.conf customfiles/usr/local/etc/

mkdir -p customfiles/var/ftpd
cp /root/ipxe/src/bin/undionly.kpxe customfiles/var/ftpd/

cp ~/.baker/rc.conf conf/
cp ~/.baker/resolv.conf conf/
cp ~/.baker/loader.conf conf/

make ROOTHACK=1 PKGNG=1 BUILDWORLD=1 BUILDKERNEL=1 CUSTOM=1 MAKEJOBS=$NCPU
) &> /dev/null #2>&1 | gzip -1c > /tmp/bakerlog.gz
cat /root/mfsbsd/*.img
