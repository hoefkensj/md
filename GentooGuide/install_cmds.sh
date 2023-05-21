#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o xtrace 
# mkfs.f2fs -f -l GENTOO -O extra_attr,inode_checksum,sb_checksum,flexible_inline_xattr -w 4096 /dev/disk/by-partlabel/GENTOO
# partprobe
mkdir -p /mnt/{gentoo,install}
chmod 777 /mnt/{gentoo,install}
# mount -t f2fs -o rw,relatime,lazytime,background_gc=on,discard,no_heap,inline_xattr,inline_data,inline_dentry,flush_merge,extent_cache,mode=adaptive,active_logs=6,alloc_mode=default,checkpoint_merge,fsync_mode=posix,discard_unit=block  /dev/disk/by-label/GENTOO /mnt/gentoo
# mount -o size=1G -t tmpfs tmpfs /mnt/install
export MIRROR="http://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/"
#export LATEST="latest-stage3-amd64-desktop-systemd-mergedusr.txt"
export LATEST="latest-stage3-amd64-systemd-mergedusr.txt"
export STAGE3_URL="${MIRROR}$(curl  --silent $MIRROR$LATEST | tail -n1 |awk '{print $1}')"
mkdir -p /mnt/install/gentoo-stage3 && cd $_
wget -c "${STAGE3_URL}"
wget -c "${STAGE3_URL}.CONTENTS.gz"
wget -c "${STAGE3_URL}.DIGESTS"
wget -c "${STAGE3_URL}.asc"
wget -c "${STAGE3_URL}.sha256"
wget -O - https://qa-reports.gentoo.org/output/service-keys.gpg | gpg --import
gpg --keyserver hkps://keys.gentoo.org --recv-keys D99EAC7379A850BCE47DA5F29E6438C817072058
# gpg --verify "${LATEST}.asc"
# gpg --verify stage3-amd64-*.tar.xz.DIGESTS
# awk '/SHA512 HASH/{getline;print}' stage3-amd64-*.tar.xz.DIGESTS.asc | sha512sum --check
cp -v  stage3-*.tar.xz /mnt/gentoo
cd /mnt/gentoo
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
#portage
mkdir -p /mnt/gentoo/{Volumes,etc/portage/{package.{accept_keywords,license,mask,unmask,use,env},repos.conf},opt/{bin,scripts,local/{bin,scripts,config/rc/bash}}}
chown -R root:100 ./{opt,Volumes}
chmod -R 775 ./{opt,Volumes}
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

#scripts
mkdir -p /mnt/install/scripts/superadduser
curl https://gitweb.gentoo.org/repo/gentoo.git/plain/app-admin/superadduser/files/1.15/superadduser -o  /mnt/install/scripts/superadduser/superadduser.sh 
mkdir -p /mnt/install/scripts/sourcedir
curl https://raw.githubusercontent.com/hoefkensj/SourceDir/main/sourcedir-latest.sh -o /mnt/install/scripts/sourcedir/sourcedir-latest.sh
mkdir -p /mnt/install/github
cd /mnt/install/github
git clone https://github.com/hoefkensj/GentooGuide/
