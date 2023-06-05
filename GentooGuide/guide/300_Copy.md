## 



```bash
#scripts & programs
cd /mnt/install/
mkdir -p /mnt/install/scripts/superadduser
curl https://gitweb.gentoo.org/repo/gentoo.git/plain/app-admin/superadduser/files/1.15/superadduser -o  /mnt/install/scripts/superadduser/superadduser.sh 

mkdir -p /mnt/install/scripts/sourcedir
curhotpantsl https://raw.githubusercontent.com/hoefkensj/SourceDir/main/sourcedir-latest.sh -o /mnt/install/scripts/sourcedir/sourcedir-latest.sh
#install scripts in new installation:
mkdir -m 775 /opt/{sh,bin,scripts,local/{bin,sh,scripts}}

git -c /mnt/install/git clone https://github.com/hoefkensj/bash_scripts.git
git -C /mnt/install/git clone https://github.com/hoefkensj/GentooGuide/
git -C /mnt/install/git clone https://github.com/projg2/cpuid2cpuflags.git
git -C /mnt/install/git clone https://github.com/zyedidia/micro
git -C /mnt/install/git clone https://github.com/jvz/psgrep
git -C /mnt/install/git clone https://github.com/sakaki-/showem.git
git -C /mnt/install/git clone https://github.com/rcaloras/bashhub-client.git
git -C /mnt/install/git clone https://github.com/sharkdp/fd
git -C /mnt/install/git clone https://github.com/BurntSushi/ripgrep
git -C /mnt/install/git clone https://github.com/sharkdp/bat
git -C /mnt/install/git clone https://github.com/ogham/exa
git -C /mnt/install/git clone https://github.com/tldr-pages/tldr
git -C /mnt/install/git clone https://github.com/junegunn/fzf
git -C /mnt/install/git clone https://github.com/ajeetdsouza/zoxide



```

Unpack the verified stage 3 archive

```bash
tar xpvJf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner --directory /mnt/gentoo
# x:extract, p:preserve permissions, J:xz-compression f:file
```





## Some Extra Folders

```bash
mkdir -p "$ROOT_NEW"/{Volumes,etc/portage/{package.{accept_keywords,license,mask,unmask,use,env},repos.conf},opt/{bin,scripts,local/{bin,scripts,config/rc/bash}}}
```

## Repositories

```bash
mkdir -p -v /mnt/gentoo/etc/portage/repos.conf 
cp -v /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf 
nano -w /mnt/gentoo/etc/portage/repos.conf/gentoo.conf 

```

### Setting up repository information for Portage

```ini
#/mnt/gentoo/etc/portage/repos.conf/gentoo.conf
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /var/db/repos/gentoo
sync-type = webrsync
#sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
sync-webrsync-verify-signature = true
auto-sync = yes

sync-rsync-verify-jobs = 1
sync-rsync-verify-metamanifest = yes
sync-rsync-verify-max-age = 24
sync-openpgp-keyserver = hkps://keys.gentoo.org
sync-openpgp-key-path = /usr/share/openpgp-keys/gentoo-release.asc
sync-openpgp-key-refresh-retry-count = 40
sync-openpgp-key-refresh-retry-overall-timeout = 1200
sync-openpgp-key-refresh-retry-delay-exp-base = 2
sync-openpgp-key-refresh-retry-delay-max = 60
sync-openpgp-key-refresh-retry-delay-mult = 4


```



## PRE CHROOT

## CHROOTING  

chroot_prep.sh :


```bash
#!/usr/bin/env bash
# set -o xtrace;
set -o errexit;
set -o nounset;
function chrootprep {
	function mountlog(){
		printf 'mounting %s ...\t' $1
		printf 'mount %s /%s %s/%s\n' "$2" "$1" "$NR" "$1" 
	}
	local NR
	NR=$(realpath "$1" )
	echo $NR	
	echo cp -v --dereference /etc/resolv.conf "${NR}/etc/"
	cp -v -L --dereference /etc/resolv.conf "${NR}/etc/"
	mountlog "proc" "-v -t proc"       && mount -v -t proc       none   "${NR}/proc"       
    mountlog "sys" "-v --rbind"        && mount -v --rbind       /sys   "${NR}/sys"
    mountlog "sys" "-v --make-rslave"  && mount -v --make-rslave        "${NR}/sys"
 	mountlog "dev" "-v --rbind"        && mount -v --rbind       /dev   "${NR}/dev"
    mountlog "dev" "-v --make-rslave"  && mount -v --make-rslave        "${NR}/dev"
	mountlog "run" "-v --bind"         && mount -v --bind        /run   "${NR}/run"
    mountlog "run" "-v --make-slave"   && mount -v --make-slave         "${NR}/run" 
    test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
	mount -t tmpfs -o nosuid,nodev,noexec shm /dev/shm
	chmod 1777 /dev/shm 
}  
chrootprep "$@"
```

  


AFTER CHROOT

```bash
screen -S GentooINST
chroot /mnt/gentoo /bin/bash 
#source /etc/profile  sould happen automaiic if all went okay
export PS1="(chroot) $PS1" 

emaint sync --auto 
eselect profile list
#useflag lookup
grep -i useflag /var/db/repos/gentoo/profiles/use.desc 



emerge --ask --verbose --oneshot portage 
echo "Europe/Brussels" > /etc/timezone 
emerge -v --config sys-libs/timezone-data 

nano -w /etc/locale.gen
locale-gen 
eselect locale list 
eselect locale set "C" 
env-update && source /etc/profile && export PS1="(chroot) $PS1"

emerge --verbose --oneshot app-portage/cpuid2cpuflags 
echo "*/* $(cpuid2cpuflags)" >> /etc/portage/package.use/00cpuflags

touch /etc/portage/package.use/zzz_via_autounmask 
emerge --ask --verbose dev-vcs/git	


nano -w /etc/portage/repos.conf/sakaki-tools.conf 
```

```ini
[sakaki-tools]

# Various utility ebuilds for Gentoo on EFI
# Maintainer: sakaki (sakaki@deciban.com)

location = /var/db/repos/sakaki-tools
sync-type = git
sync-uri = https://github.com/sakaki-/sakaki-tools.git
priority = 50
auto-sync = yes
```

```bash
emaint sync --repo sakaki-tools 
echo '*/*::sakaki-tools' >> /etc/portage/package.mask/sakaki-tools-repo 
touch /etc/portage/package.unmask/zzz_via_autounmask 
echo "app-portage/showem::sakaki-tools" >> /etc/portage/package.unmask/showem 
echo "sys-kernel/buildkernel::sakaki-tools" >> /etc/portage/package.unmask/buildkernel 
echo "app-portage/genup::sakaki-tools" >> /etc/portage/package.unmask/genup
echo "app-crypt/staticgpg::sakaki-tools" >> /etc/portage/package.unmask/staticgpg
echo "app-crypt/efitools::sakaki-tools" >> /etc/portage/package.unmask/efitools 
echo "sys-kernel/genkernel-next::sakaki-tools" >> /etc/portage/package.unmask/genkernel-next 
touch /etc/portage/package.accept_keywords/zzz_via_autounmask 
echo "*/*::sakaki-tools ~amd64" >> /etc/portage/package.accept_keywords/sakaki-tools-repo 
echo -e "# all versions of efitools currently marked as ~ in Gentoo tree\napp-crypt/efitools ~amd64" >> /etc/portage/package.accept_keywords/efitools 
echo "~sys-apps/busybox-1.32.0 ~amd64" >> /etc/portage/package.accept_keywords/busybox 
#emerge --ask --verbose app-portage/showem 

#open a split Tmux Window and also chroot into systme
export PS1="(chroot:2) $PS1"
```

# BOOTSTRAPPIN THE BASE SYSTEM

Note that here, bootstrapping refers to the process of:

1. building (from source) the standard *toolchain* (GCC  compiler, linker, assembler, C library and a number of other items),  i.e., the components necessary to build the other software and libraries that make up Gentoo's [**@world**](https://wiki.gentoo.org/wiki/World_set_(Portage)) package set; and then

2. using that newly constructed toolchain to rebuild everything in the [**@world**](https://wiki.gentoo.org/wiki/World_set_(Portage)) package set, from source.

   

```bash
cd /var/db/repos/gentoo/scripts 
./bootstrap.sh --pretend 
nano -w bootstrap.sh 
```



```bash
# This stuff should never fail but will if not enough is installed.
[[ -z ${myBASELAYOUT} ]] && myBASELAYOUT=">=$(portageq best_version / sys-apps/baselayout)"
[[ -z ${myPORTAGE}    ]] && myPORTAGE="portage"
[[ -z ${myBINUTILS}   ]] && myBINUTILS="binutils"   
[[ -z ${myGCC}        ]] && myGCC="gcc"
[[ -z ${myGETTEXT}    ]] && myGETTEXT="gettext"
[[ -z ${myLIBC}       ]] ; myLIBC="$(portageq expand_virtual / virtual/libc)"
[[ -z ${myTEXINFO}    ]] && myTEXINFO="sys-apps/texinfo"
[[ -z ${myZLIB}       ]] && myZLIB="zlib"
[[ -z ${myNCURSES}    ]] && myNCURSES="ncurses"
.....
export USE="-* bootstrap ${ALLOWED_USE} ${BOOTSTRAP_USE} openmp"
```

```bash
./bootstrap.sh --pretend 
qfile /etc/locale.gen /etc/conf.d/keymaps
cp -v /etc/locale.gen{,.bak} 


./bootstrap.sh 
#switch to the other tmux window and run :
showem
gcc-config --list-profiles 
./bootstrap.sh #again
gcc-config --list-profiles 
mv -v /etc/locale.gen{.bak,} 
locale-gen 
eselect locale show 
touch /tmp/prebuild_checkpoint 
emerge --ask --verbose --emptytree --with-bdeps=y @world 
emerge --resume 
dispatch-conf 
 



```

## Verify bootstrap

```bash
emerge --depclean
# should produce no output:
find / -type d -path /boot/efi -prune -o -path /proc -prune -o -type f -executable -not -newer /tmp/prebuild_checkpoint -print0 2>/dev/null | xargs -0 file --no-pad --separator="@@@" | grep -iv '@@@.* text' 
# should produce no output!!
find / -type d -path /boot/efi -prune -o -path /proc -prune -o -type f -not -executable -not -newer /tmp/prebuild_checkpoint -print0 2>/dev/null | xargs -0 file --no-pad --separator="@@@" | grep '@@@.*\( ELF\| ar archive\)'
```

