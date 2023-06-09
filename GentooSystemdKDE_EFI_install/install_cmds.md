```bash
su -c 'nohup qterminal & '
tmux
mksfs.f2fs -f -l GENTOO -O extra_attr,inode_checksum,sb_checksum,flexible_inline_xattr -w 4096 /dev/disk/by-partlabel/GENTOO
mkdir -p /mnt/{gentoo,install}
chmod 777 /mnt/mnt/{gentoo,install}
mount -t f2fs -o rw,relatime,lazytime,background_gc=on,discard,no_heap,inline_xattr,inline_data,inline_dentry,flush_merge,extent_cache,mode=adaptive,active_logs=6,alloc_mode=default,checkpoint_merge,fsync_mode=posix,discard_unit=block  /dev/disk/by-label/GENTOO /mnt/gentoo
mount -o size=1G -t tmpfs tmpfs /mnt/Install
export MIRROR="http://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/"
export LATEST="latest-stage3-amd64-desktop-systemd-mergedusr.txt"
export STAGE3_URL="${MIRROR}$(curl  --silent $MIRROR$LATEST | tail -n1 |awk '{print $1}')"
mkdir -p /mnt/Install/gentoo-stage3 && cd $_
wget -c "${STAGE3_URL}"
wget -c "${STAGE3_URL}.CONTENTS.gz"
wget -c "${STAGE3_URL}.DIGESTS"
wget -c "${STAGE3_URL}.asc"
wget -c "${STAGE3_URL}.sha256"
wget -O - https://qa-reports.gentoo.org/output/service-keys.gpg | gpg --import
gpg --keyserver hkps://keys.gentoo.org --recv-keys D99EAC7379A850BCE47DA5F29E6438C817072058
gpg --verify "${LATEST}.asc"
gpg --verify stage3-amd64-*.tar.xz.DIGESTS.asc
awk '/SHA512 HASH/{getline;print}' stage3-amd64-*.tar.xz.DIGESTS.asc | sha512sum --check 
tar xpvJf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner --directory /mnt/gentoo
mkdir -p /mnt/gentoo/{Volumes,etc/portage/package.{accept_keywords,license,mask,unmask,use,env},opt/{bin,scripts,local/{bin,scripts,config/rc/bash}}}
chown -R root:100 ./{opt,Volumes}
chmod -R 775 /mnt/gentoo/{opt,Volumes}
mkdir -p /mnt/Install/scripts/superadduser
curl https://gitweb.gentoo.org/repo/gentoo.git/plain/app-admin/superadduser/files/1.15/superadduser -o  /mnt/Install/superadduser.sh 
mkdir -p /mnt/Install/scripts/sourcedir
curl https://raw.githubusercontent.com/hoefkensj/SourceDir/main/sourcedir-latest.sh -o ./sourcedir-latest.sh
cd https://github.com/hoefkensj/GentooGuide.git
```

### 

```bash
echo "*/* $(cpuid2cpuflags)" >> /etc/portage/package.use/00cpuflags
```

