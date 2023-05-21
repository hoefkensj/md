



## PORTAGE

### Create Some local Repositories

```
eselect repository create gentoo_legacy
eselect repository create kranklab
eselect repository create kranklab_bump
```

## Configuring /etc/portage/make.conf

```bash
#!/usr/bin/env bash
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
CHOST="x86_64-pc-linux-gnu"
ACCEPT_LICENSE="*"
ACCEPT_KEYWORDS="amd64"
ABI_X86="32 64"

# REPLACED BY : echo "*/* $(cpuid2cpuflags)" >> /etc/portage/package.use/00cpuflags
#cpuid2cpuflags 
#CPU_FLAGS_X86: aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3
#CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"

COMMON_FLAGS="-O2 -pipe"
# gcc -march=native -E -v - </dev/null 2>&1 | sed  -n 's/.* -v - //p'
COMMON_FLAGS="${COMMOM_FLAGS} -march=skylake -mmmx -mpopcnt -msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -mavx2 -mno-sse4a -mno-fma4 -mno-xop -mfma -mno-avx512f -mbmi -mbmi2 -maes -mpclmul -mno-avx512vl -mno-avx512bw -mno-avx512dq -mno-avx512cd -mno-avx512er -mno-avx512pf -mno-avx512vbmi -mno-avx512ifma -mno-avx5124vnniw -mno-avx5124fmaps -mno-avx512vpopcntdq -mno-avx512vbmi2 -mno-gfni -mno-vpclmulqdq -mno-avx512vnni -mno-avx512bitalg -mno-avx512bf16 -mno-avx512vp2intersect -mno-3dnow -madx -mabm -mno-cldemote -mclflushopt -mno-clwb -mno-clzero -mcx16 -mno-enqcmd -mf16c -mfsgsbase -mfxsr -mno-hle -msahf -mno-lwp -mlzcnt -mmovbe -mno-movdir64b -mno-movdiri -mno-mwaitx -mno-pconfig -mno-pku -mno-prefetchwt1 -mprfchw -mno-ptwrite -mno-rdpid -mrdrnd -mrdseed -mno-rtm -mno-serialize -msgx -mno-sha -mno-shstk -mno-tbm -mno-tsxldtrk -mno-vaes -mno-waitpkg -mno-wbnoinvd -mxsave -mxsavec -mxs aveopt -mxsaves -mno-amx-tile -mno-amx-int8 -mno-amx-bf16 -mno-uintr -mno-hreset -mno-kl -mno-widekl -mno-avxvnni --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=8192 -mtune=skylake"
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
# -v --verbose      # -b --buildpkg     # -D --deep 			# -g --getbinpkg        # -k --usepkg
# -u update			# -N --newuse       # -l load-average		# -t --tree				# -G --getbinpkgonly
# -k --uspkgonly	# -U changed-use	# -o --fetchonly		# -a ask				# -f --fuzzy-search
# --list-sets		# --alphabetical    # --color=y 			# --with-bdeps=y		# --verbose-conflicts
# --complete-graph=y					# --backtrack=COUNT 							# --binpkg-respect-use=[y/n]
# --autounmask=y    					# --autounmask-continue=y  						# --autounmask-backtrack=y
# --autounmask-write=y 					# --usepkg-exclude 'sys-kernel/gentoo-sources virtual/*'
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

### FEATURES
#FEATURES="${FEATURES} fixlafiles"
#FEATURES="${FEATURES} cgroup"
#FEATURES="${FEATURES} xattr split-elog "
#FEATURES="${#FEATURES} sign"
#FEATURES="${FEATURES} buildpkg"
# FEATURES="${FEATURES} ccache"
# FEATURES="${FEATURES} userfetch usersync"
# FEATURES="${FEATURES} distcc"
FEATURES="${FEATURES} parallel-fetch parallel-install"
### FEATURES : CLEANING
# FEATURES="${FEATURES} clean-logs"
### FEATURES : BINHOST
#FEATURES="${FEATURES} getbinpkg"
#FEATURES="${FEATURES} binpkg-multi-instance"
### FEATURES : FAILING
# FEATURES="${FEATURES} keepwork failclean"#
# FEATURES="${FEATURES} merge-sync"
# keeptemp"
# FEATURES="${FEATURES} protect-owned"
# collision-protect"


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

# BINPKG
#BINPKG_FORMAT="gpkg"
#BINPKG_COMPRESS="lz4"
#PORTAGE_BINHOST="https://gentoo.osuosl.org/experimental/amd64/binpkg/default/linux/17.1/x86-64/"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} http://packages.gentooexperimental.org/packages/amd64-stable/"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} http://packages.gentooexperimental.org/packages/amd64-stable/"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} https://packages.gentooexperimental.org"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} ftp://packages.gentooexperimental.org"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} ftps//packages.gentooexperimental.org"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} rsync://packages.gentooexperimental.org"

GRUB_PLATFORM="efi-64"
ALSA_CARDS="hda-intel usb-audio emu10k1 emu10k1x emu20k1x emu20k1 intel8x0 intel8x0m bt87x hdsp hdspm ice1712 mixart rme32 rme96 sb16 sbawe sscape usb-usx2y vx222"
VIDEO_CARDS="nvidia d3d12 vmware"
INPUT_DEVICES="evdev libinput"
INPUT_DRIVERS="evdev"
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

