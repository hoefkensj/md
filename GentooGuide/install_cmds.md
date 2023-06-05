```bash
isu -c 'nohup qterminal & '
tmux

#VARIABLES
export ROOT_NEW="/mnt/gentoo"
export ROOT_OLD="/"
export MIRROR="http://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/"
#export LATEST="latest-stage3-amd64-desktop-systemd-mergedusr.txt"
export LATEST="latest-stage3-amd64-systemd-mergedusr.txt"
export STAGE3_URL="${MIRROR}$(curl  --silent $MIRROR$LATEST | tail -n1 |awk '{print $1}')"
# DIRS
install -m 777 -d "$ROOT_OLD"/mnt/{gentoo/,install/}

# FORMATTING :

mkfs.f2fs -f -l GENTOO -O extra_attr,inode_checksum,sb_checksum,flexible_inline_xattr -w 4096 /dev/disk/by-partlabel/GENTOO

#Mounting: 

#the new root Volume:
mount -t f2fs -o rw,relatime,lazytime,background_gc=on,discard,no_heap,inline_xattr,inline_data,inline_dentry,flush_merge,extent_cache,mode=adaptive,active_logs=6,alloc_mode=default,checkpoint_merge,fsync_mode=posix,discard_unit=block  /dev/disk/by-label/GENTOO /mnt/gentoo
#the Installation Files 
mount -o size=1G -t tmpfs tmpfs /mnt/Install

#creating some intallationfile directories:
install -m 777 -d "$ROOT_OLD"/mnt/install/{git,scripts,gentoo-stage3}
#Gathering The Gentoo Stage tarbal
cd /mnt/install/gentoo-stage3 
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

#scripts & programs
cd /mnt/install/
mkdir -p /mnt/install/scripts/superadduser
curl https://gitweb.gentoo.org/repo/gentoo.git/plain/app-admin/superadduser/files/1.15/superadduser -o  /mnt/install/scripts/superadduser/superadduser.sh 

mkdir -p /mnt/install/scripts/sourcedir
curl https://raw.githubusercontent.com/hoefkensj/SourceDir/main/sourcedir-latest.sh -o /mnt/install/scripts/sourcedir/sourcedir-latest.sh
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

### UNPacking and moving stuff

```bash
tar xpvJf /mnt/install/gentoo-stage3/stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner --directory /mnt/gentoo
# x:extract, p:preserve permissions, J:xz-compression f:file

#portage
mkdir -pv $ROOT_NEW/{Volumes,etc/portage/{package.{accept_keywords,license,mask,unmask,use,env},repos.conf},opt/{bin,scripts,local/{bin,scripts,config/rc/bash}}}
chown -Rv root:100 $ROOT_NEW/{opt,Volumes}
chmod -Rv 775 $ROOT_NEW/{opt,Volumes}
```

## configuring the new /etc/portage/make.conf

```bash
#backup the original :
mkdir -pv $ROOT_NEW/root/backups/etc/
cp -vfr $ROOT_NEW/etc/portage $ROOT_NEW/root/backups/etc/
```

```bash
cd $ROOT_NEW/etc/portage/ 
echo > make.conf <<< echo '''#!/usr/bin/env bash
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.'''
```

```bash
echo >> make.conf <<< echo \
'''
CHOST="x86_64-pc-linux-gnu"
ACCEPT_LICENSE="*"
ACCEPT_KEYWORDS="amd64"
ABI_X86="32 64"
'''

```

```bash
#no need for cpu_flags_x86 here anymore so:
echo "*/* $(cpuid2cpuflags)" >> $ROOT_NEW/etc/portage/package.use/00cpuflags
```



```bash



echo >> make.conf <<< echo \
'''
COMMON_FLAGS="-O2 -pipe"
COMMON_FLAGS="${COMMOM_FLAGS} $(gcc -march=native -E -v - </dev/null 2>&1 | sed  -n 's/.* -v - //p')"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
# NOTE: This stage was built with the bindist Use flag enabled
PORTDIR="/var/db/repos/gentoo"
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C
L10N="en"

# MAKEOPTS="-j1" 
MAKEOPTS="-j6 -l6"


# EMERGE_DEFAULT_OPTS
# -v --verbose      # -b --buildpkg     # -D --deep             # -g --getbinpkg        # -k --usepkg
# -u update            # -N --newuse       # -l load-average        # -t --tree                # -G --getbinpkgonly
# -k --uspkgonly    # -U changed-use    # -o --fetchonly        # -a ask                # -f --fuzzy-search
# --list-sets        # --alphabetical    # --color=y             # --with-bdeps=y        # --verbose-conflicts
# --complete-graph=y                    # --backtrack=COUNT                             # --binpkg-respect-use=[y/n]
# --autounmask=y                        # --autounmask-continue=y                          # --autounmask-backtrack=y
# --autounmask-write=y                     # --usepkg-exclude 'sys-kernel/gentoo-sources virtual/*'
# EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=9 -b -v -D" --tree, -t--verbose-conflicts

AUTOUNMASK=""
AUTOUNMASK="${AUTOUNMASK} --autounmask=y  --autounmask-continue=y --autounmask-write=y"
AUTOUNMASK="${AUTOUNMASK} --autounmask-unrestricted-atoms=y --autounmask-license=y"
AUTOUNMASK="${AUTOUNMASK} --autounmask-use=y --autounmask-write=y"

EMERGE_DEFAULT_OPTS="--verbose"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=4 --load-average=4"
#EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --with-bdeps=y "
#EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} ${AUTOUNMASK}"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --color=y --alphabetical --verbose-conflicts"


#GENTOO_MIRRORS=""
#### BELGIUM | BELNET
GENTOO_MIRRORS="${GENTOO_MIRRORS} http://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/"
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/"
GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/"
GENTOO_MIRRORS="${GENTOO_MIRRORS} rsync://rsync.belnet.be/gentoo/"
#### LUXEMBURG
GENTOO_MIRRORS="${GENTOO_MIRRORS} http://gentoo.mirror.root.lu/"
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://gentoo.mirror.root.lu/"
GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://mirror.root.lu/gentoo/"
##### NETHERLANDS | UNIVERSITY TWENTE
GENTOO_MIRRORS="${GENTOO_MIRRORS} http://ftp.snt.utwente.nl/pub/os/linux/gentoo"
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://ftp.snt.utwente.nl/pub/os/linux/gentoo"
GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://ftp.snt.utwente.nl/pub/os/linux/gentoo"
GENTOO_MIRRORS="${GENTOO_MIRRORS} rsync://ftp.snt.utwente.nl/gentoo/"
#### NETHERLANDS | LEASWEB
GENTOO_MIRRORS="${GENTOO_MIRRORS} http://mirror.leaseweb.com/gentoo/"
GENTOO_MIRRORS="${GENTOO_MIRRORS} https://mirror.leaseweb.com/gentoo/"
GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://mirror.leaseweb.com/gentoo/"
GENTOO_MIRRORS="${GENTOO_MIRRORS} rsync://mirror.leaseweb.com/gentoo/"
###########################


GRUB_PLATFORM="efi-64"
ALSA_CARDS="hda-intel usb-audio emu10k1 emu10k1x emu20k1x emu20k1 intel8x0 intel8x0m bt87x hdsp hdspm ice1712 mixart rme32 rme96 sb16 sbawe sscape usb-usx2y vx222"
VIDEO_CARDS="nvidia d3d12 vmware"
INPUT_DEVICES="evdev libinput"
INPUT_DRIVERS="evdev"

USE=
'''
```

'







'

```bash
echo "*/* $(cpuid2cpuflags)" >> /mnt/gentoo/etc/portage/package.use/00cpuflags
mkdir -p -v $ROOT_NEW/etc/portage/repos.conf 
cp -v $ROOT_NEW/usr/share/portage/config/repos.conf $ROOT_NEW/etc/portage/repos.conf/gentoo.conf 
```

## PORTAGE

### Create Some local Repositories

```
eselect repository create gentoo_legacy
eselect repository create kranklab
eselect repository create kranklab_bump
```

## Configuring /etc/portage/make.conf

```bash
mkdir -p -v /mnt/gentoo/etc/portage/repos.conf 
# Turn on logging - see http://gentoo-en.vfose.ru/wiki/Gentoo_maintenance.
#PORTAGE_ELOG_CLASSES="info warn error log qa"
# Echo messages after emerge, also save to /var/log/portage/elog
#PORTAGE_ELOG_SYSTEM="echo save"

USE_BASE="acl amd64 bzip2 cli crypt dri fortran gdbm iconv ipv6 libglvnd libtirpc multilib ncurses nls nptl openmp pam pcre readline seccomp ssl systemd test-rust udev unicode xattr zlib"
USE_DESKTOP="X a52 aac acpi alsa bluetooth branding cairo cdda cdr crypt cups dbus dts dvd dvdr encode exif flac gif gpm gtk gui iconv icu jpeg lcms libnotify mad mng mp3 mp4 mpeg ogg opengl pango pdf png policykit ppds qt5 sdl sound spell startup-notification svg tiff truetype udisks upower usb vorbis wxwidgets x264 xcb xft xml xv xvid"
USE_PLASMA="activities declarative kde kwallet plasma qml semantic-desktop widgets xattr"
USE_PLASMA="activities declarative kde plasma qml semantic-desktop widgets xattr"

USE="tools custom-cflags network multimedia  "
"gles2 opencl tools \
persistenced \
libsamplerate opencv custom-cflags grub network  \
dri semantic-desktop \
modplug modules \
multimedia   ao \
audiofile  branding cairo cdb cdda cddb cdr cgi \
colord crypt css curl dbm dga dts dv dvb dvd dvdr encode exif \
fbcon ffmpeg fftw flac fltk fontconfig fortran ftp gd gif \
glut gnuplot gphoto2 graphviz gzip handbook imagemagick imap \
imlib ipv6 java javascript joystick jpeg kerberos ladspa lame \
lcms ldap libcaca libnotify libwww lua lzma lz4 lzo mad magic \
man matroska mikmod mmap mms mono mp3 mp4 mpeg mplayer mtp \
mysqli nas ncurses nsplugin offensive ogg openal opus osc pda \
pdf php plotutils png postscript radius raw rdp rss ruby samba \
sasl savedconfig sdl session smartcard smp sndfile snmp \
sockets socks5 sound sox speex spell sqlite ssl \
startup-notification suid svg symlink szip tcl tcpd theora tidy tiff timidity \
tk  udev udisks  upnp-av upower v4l vaapi vcd \
videos vim-syntax vnc vorbis  webkit webp wmf wxwidgets \
 xattr xcomposite xine xinerama xinetd xml xmp xmpp xosd \
xpm xv   zlib zsh-completion zstd source \
 script openexr echo-cancel extra gstreamer jack-sdk lv2 \
 sound-server system-service v4l2 zimg \
rubberband pulseaudio libmpv gamepad drm cplugins archive screencast \
gbm   examples "
```

```bash
#Database
sqlite,mysql,berkdb,dbi,dbm,
#Codecs:
a52,aac,aalib,audiofile,cdb,nvenc,libsamplerate,otf,ttf,quicktime,xvid,truetype,x265,wavpack,css
#Cli
aalib,bash-completion
#Hardware
acpi,ao,bluetooth,cdr,pipewire,jack,nvidia,thunderbolt,usb,jack,rtaudio,systemd,dbus,nvme,uefi,lm-sensors,hddtemp,alsa,sensors,midi,pipewire-alsa,upnp,coreaudio
#Filesystem
afs
#Network
apache2,atm,cddb,curl,iwd,wifi,network,nftables,,zeroconf ,adns,connman,
#Gui
appindicator,cairo,colord,wayland,plasma,opengl,X,kde,vulkan,qt5,Xaw3d,colord,
#Development
python,designer,cuda
#tools
bash-completion,crypt,git
# Archiving
7zip,bzip2,rar,zip 
# Unknown
accessibility,acl,apparmor,audit,bidi,big-endian,bindist,blas,branding,build,calendar,caps,cdinstall,cgi,cjk,clamav,cracklib,
crypt,cxx,dbus,debug,
```

```bash
mkdir -p -v /mnt/gentoo/etc/portage/repos.conf 
cp -v /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf 
nano -w /mnt/gentoo/etc/portage/repos.conf/gentoo.conf 
```

```ini
/mnt/gentoo/etc/portage/repos.conf/gentoo.confSetting up repository information for Portage

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

```
emaint sync --auto 
emerge --ask --verbose --oneshot portage 
echo "Europe/Brussels" > /etc/timezone 
emerge -v --config sys-libs/timezone-data 
nano -w /etc/locale.gen
locale-gen 
eselect locale list 
eselect locale set "C" 
env-update && source /etc/profile && export PS1="(chroot) $PS1"
touch /etc/portage/package.use/zzz_via_autounmask 
emerge --ask --verbose dev-vcs/git 
```

```
nano -w /etc/portage/repos.conf/sakaki-tools.conf 
[sakaki-tools]

# Various utility ebuilds for Gentoo on EFI
# Maintainer: sakaki (sakaki@deciban.com)

location = /var/db/repos/sakaki-tools
sync-type = git
sync-uri = https://github.com/sakaki-/sakaki-tools.git
priority = 50
auto-sync = yes
```

```
emaint sync --repo sakaki-tools 
echo '*/*::sakaki-tools' >> /etc/portage/package.mask/sakaki-tools-repo 
touch /etc/portage/package.unmask/zzz_via_autounmask 
echo "app-portage/showem::sakaki-tools" >> /etc/portage/package.unmask/showem

echo "app-portage/genup::sakaki-tools" >> /etc/portage/package.unmask/genup
echo "app-crypt/staticgpg::sakaki-tools" >> /etc/portage/package.unmask/staticgpg
echo "app-crypt/efitools::sakaki-tools" >> /etc/portage/package.unmask/efitools
touch /etc/portage/package.accept_keywords/zzz_via_autounmask 
#echo "*/*::sakaki-tools ~amd64" >> /etc/portage/package.accept_keywords/sakaki-tools-repo 
echo -e "# all versions of efitools currently marked as ~ in Gentoo tree\napp-crypt/efitools ~amd64" >> /etc/portage/package.accept_keywords/efitools 
echo "~sys-apps/busybox-1.32.0 ~amd64" >> /etc/portage/package.accept_keywords/busybox 
```

```bash
ll
2   export PS1="(chroot) $PS1"
3  ln -sf ../usr/share/zoneinfo/Europe/Brussels /etc/localtime
4  source /etc/profile
5   export PS1="(chroot) $PS1"
6  cd /var/db/repos/gentoo/scripts
7  ./bootstrap.sh --pretend
8  nano -w bootstrap.sh
9  nano -w bootstrap.sh
10  ./bootstrap.sh --pretend
11  qfile /etc/locale.gen /etc/conf.d/keymaps
12  cp -v /etc/locale.gen{,.bak}
13  ./bootstrap.sh
14  ./bootstrap.sh
15  gcc-config --list-profiles
16  mv -v /etc/locale.gen{.bak,}
17  #locale-gen
18  locale-gen
19  eselect locale show
20  touch /tmp/prebuild_checkpoint
21  time emerge --ask --verbose --emptytree --with-bdeps=y @world
22  time emerge --ask --verbose --emptytree --with-bdeps=y @world
23  dispatch-conf
24  emerge --depclean
25  find / -type d -path /boot/efi -prune -o -path /proc -prune -o -type f -executable -not -newer /tmp/prebuild_checkpoint -print0 2>/dev/null | xargs -0 file --no-pad --separator="@@@" | grep -iv '@@@.* text'
26  This command finds all executable files (except beneath the EFI mountpoint at /bo
27  find / -type d -path /boot/efi -prune -o -path /proc -prune -o -type f -not -executable -not -newer /tmp/prebuild_checkpoint -print0 2>/dev/null | xargs -0 file --no-pad --separator="@@@" | grep '@@@.*\( ELF\| ar archive\)'
28  mkdir -p -v /etc/portage/package.license
29  touch /etc/portage/package.license/zzz_via_autounmask
30  echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >> /etc/portage/package.license/linux-firmware
31  emerge --ask --verbose sys-kernel/gentoo-sources
32  emerge --ask --verbose sys-kernel/linux-firmware
33  readlink -v /usr/src/linux
34  eselect kernel list
35  eselect kernel set 1
36  eselect kernel list
37  readlink -v /usr/src/linux
38  eix sys-kernel/gentoo-sources
39  eix =sys-kernel/gentoo-sources-6.3.5
40  ACCEPT_KEYWORDS="~amd64" e =sys-kernel/gentoo-sources-6.3.5
41  emerge --ask --verbose =sys-kernel/gentoo-sources-6.3.5
42  ACCEPT_KEYWORDS="~amd64" emerge --ask --verbose =sys-kernel/gentoo-sources-6.3.5
43  readlink -v /usr/src/linux
44  eselect kernel list
45  eselect kernel set 2
46  emerge --ask --verbose =sys-kernel/linux-firmware-6.3.5
47  eix sys-kernel/linux-firmware
48  cd /usr/src/linux
49  ls
50  ll
51  emerge --ask --verbose =sys-kernel/linux-firmware-6.3.5
52  ACCEPT_KEYWORDS="~amd64" emerge --ask --verbose =sys-kernel/gentoo-sources-6.3.5
53  ll
54  ls
55  ln -s linux-6.0.2-gentoo-HJ0x7E6.2.config .config.old
56  make oldconfig
57  mv .config.old .config
58  make oldconfdig
59  ls
60  ls -l
61  ls -Al
62  make clean
63  make oldconfig'
64  make oldconfig
65  make -j9
66   make modules_install
67  make install
68  mount /dev/disk/by-partlabel/ESP0 /boot
69  ls /boot
70  rm -rf /boot *
71  rm -rf /boot/*
72  ls /boot]
73  ls /boot
74  make nconfig
75  make config
76  make gconfig
77  make menuconfig
78  ll
79  ls
80  cd ..
81  ACCEPT_KEYWORDS="~amd64" emerge --ask --verbose =sys-kernel/gentoo-sources-6.3.5
82  ls linux
83  cd linux
84  make menuconfig
85  make nconfig
86  cp linux-6.0.2-gentoo-HJ0x7E6.2.config .config.old
87  make menuconfig
88  make -j9 && make modules_install
89  make install
90  ll
91  ls
92  make -j9 && make modules_install
93  make && make modules_install
94  cp linux-6.0.2-gentoo-HJ0x7E6.2.config .config
95  make
96  make menuconfig
97  make menuconfig
98  make
99  ls /lib/firmware/
100  find /lib/firmware/ -iname '*regulatory*'
101  find /lib/firmware/ -iname 'regulatory*'
102  find /lib/firmware/ -iname '*db*'
103  eix regulatory
104  make menuconfig
105  cat .config |rg regulatory
106  cat .config |grep regulatory
107  equery
108  eix equery
109  eix gentoolkit
110  emerge gentoolkit
111  equery firmware
112  equery  u firmware
113  eix firmware
114  eix firmware intel
115  eix firmware+intel
116  eix intel
117  eix intel firmware
118  emerge sys-firmware/intel-microcode
119  eix firmware
120  eix -1 firmware
121  eix -# firmware
122  emerge sys-firmware/alsa-firmware sys-firmware/bluez-firmware
123* cat
124  cat .config |grep regulatory
125  cat .config |grep regulatory
126  systemd-analyze
127  emerge net-wireless/wireless-regdb
128  make
129  make modules_install
130  make install
131  eix neovim
132  eix kakoune
133  equery u kakoune
134  emerge  app-editors/kakoune
135  ACCEPT_KEYWORDS="~amd64" emerge --ask --verbose app-editors/kakoune
136  kak
```

