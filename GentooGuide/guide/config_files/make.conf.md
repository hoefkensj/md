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
```

```bash
COMMON_FLAGS="-O2 -pipe"
# gcc -march=native -E -v - </dev/null 2>&1 | sed  -n 's/.* -v - //p'
```

```bash
COMMON_FLAGS="${COMMOM_FLAGS} <output gcc -march=native -E -v - </dev/null 2>&1 | sed  -n 's/.* -v - //p' here>"
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
```

```bash
# MAKEOPTS="-j1"
MAKEOPTS="-j1 -l1"


# EMERGE_DEFAULT_OPTS
# -v --verbose      # -b --buildpkg     # -D --deep             # -g --getbinpkg        # -k --usepkg
# -u update         # -N --newuse       # -l --load-average     # -t --tree             # -G --getbinpkgonly
# -k --uspkgonly    # -U changed-use    # -o --fetchonly        # -a ask                # -f --fuzzy-search
# --list-sets       # --alphabetical    # --color=y             # --with-bdeps=y        # --verbose-conflicts
# --complete-graph=y                    # --backtrack=COUNT                             # --binpkg-respect-use=[y/n]
# --autounmask=y                        # --autounmask-continue=y                       # --autounmask-backtrack=y
# --autounmask-write=y                  # --usepkg-exclude 'sys-kernel/gentoo-sources virtual/*'
# EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=9 -b -v -D" --tree, -t--verbose-conflicts

AUTOUNMASK=""
AUTOUNMASK="${AUTOUNMASK} --autounmask=y  --autounmask-continue=y --autounmask-write=y"
AUTOUNMASK="${AUTOUNMASK} --autounmask-unrestricted-atoms=y --autounmask-license=y"
AUTOUNMASK="${AUTOUNMASK} --autounmask-use=y --autounmask-write=y"

EMERGE_DEFAULT_OPTS="--verbose"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=1"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --with-bdeps=y "
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --color=y --verbose-conflicts"
```

```bash
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
```

```bash


ALSA_CARDS="hda-intel usb-audio emu20k1x emu20k2 intel8x0 intel8x0m bt87x hdsp hdspm ice1712 mixart rme32 rme96 sb16 sbawe sscape usb-usx2y vx222"
VIDEO_CARDS="nvidia d3d12 vmware"
INPUT_DEVICES="evdev libinput"
INPUT_DRIVERS="evdev"

USE_BASE="acl amd64 bzip2 cli crypt dri fortran gdbm iconv ipv6 libglvnd libtirpc multilib ncurses nls nptl openmp pam pcre readline seccomp ssl systemd test-rust udev unicode xattr zlib"
USE_DESKTOP="X a52 aac acpi alsa bluetooth branding cairo cdda cdr crypt cups dbus dts dvd dvdr encode exif flac gif gpm gtk gui iconv icu jpeg lcms libnotify mad mng mp3 mp4 mpeg ogg opengl pango pdf png policykit ppds qt5 sdl sound spell startup-notification svg tiff truetype udisks upower usb vorbis wxwidgetsx264 xcb xft xml xv xvid"
USE_PLASMA="activities declarative kde kwallet plasma qml semantic-desktop widgets xattr"
USE="-*"

USE="gpm icu nls nptl openmp pam pcre libglvnd libtirpc  gdbm iconv  cli crypt dri acl amd64 man mmap modplug modules custom-cflags doc examples gnutls libnotify multilib offensive openal portaudio readline  sockets socks5 sound  ssl suid systemd threads unicode  alsa appindicator policykit bash-completion clamav curl imap dri fbcon ncurses sdl opengl vim-syntax python fortran git java javascript lua mono perl php postscript  mysql mysqli samba ftp ipv6 kerberos tcl tcpd cups usb upower upnp udisks udev smartcard scanner radius lm-sensors infiniband ieee1394 hddtemp dbus acpi bluetooth alsa theora vorbis wavpack aac aalib audiofile dts flac raw v4l lz4 lzma lzo szip gzip bzip2  lame libcaca libsamplerate mad mp3 mp4 mpeg musepack nvenc ogg opus inotify  smp ssl xattr  zstd openmp"
```

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

[USE flag index – Gentoo Linux](https://www.gentoo.org/support/use-flags/)



> ## Global USE flags
>
> | Flag                                                         | Description                                                  |       |
> | ------------------------------------------------------------ | ------------------------------------------------------------ | ----- |
> | `X`                                                          | Add support for X11                                          |       |
> |                                                              |                                                              |       |
> | `a52`X``                                                     | Enable support for decoding ATSC A/52 streams used in DVD    |       |
> | `aac`a52`X```                                                | Enable support for MPEG-4 AAC Audio                          | `aac` |||
> | `aalib`aac`a52`X````                                         | Add support for media-libs/aalib (ASCII-Graphics Library)    |       |
> | `accessibility`aalib`aac`a52`X`````                          | Add support for accessibility (eg 'at-spi' library)          |       |
> |                                                              |                                                              |       |
> | `acpi`accessibility`aalib`aac`a52`X``````                    | Add support for Advanced Configuration and Power Interface   |       |
> | `adns`                                                       | Add support for asynchronous DNS resolution                  |       |
> | `afs`                                                        | Add OpenAFS support (distributed file system)                |       |
> | `alsa`acpi`accessibility`aalib`aac`a52`X```````              | Add support for media-libs/alsa-lib (Advanced Linux Sound Architecture) |       |
> | `aox`                                                        | Use libao audio output library for sound playback            |       |
> | `apache2`                                                    | Add Apache2 support                                          |       |
> |                                                              |                                                              |       |
> | `atm`                                                        | Enable Asynchronous Transfer Mode protocol support           |       |
> |                                                              |                                                              |       |
> | `appindicator`alsa`acpi`accessibility`aalib`aac`a52`X```````` | Build in support for notifications using the libindicate or libappindicator plugin |       |
> | `audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X```````` | Add support for libaudiofile where applicable                |       |
> |                                                              |                                                              |       |
> | `bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X````````` | Enable bash-completion support                               |       |
> |                                                              |                                                              |       |
> |                                                              |                                                              |       |
> |                                                              |                                                              |       |
> | `#!/usr/bin/env bashbindist`                                 | Flag to enable or disable options for prebuilt (GRP) packages (eg. due to licensing issues) |       |
> | # These settings were set by the catalyst build script that automatically |                                                              |       |
> | # built this stage.`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X`````````` | Enable Bluetooth Support                                     |       |
> | # Please consult /usr/share/portage/config/make.conf.example for a more |                                                              |       |
> | # detailed example. |                                                              |       |
> | CHOST="x86_64-pc-linux-gnu" | Use the bzlib compression library                            |       |
> | ACCEPT_LICENSE="*"                                           | Enable support for the cairo graphics library                |       |
> | ACCEPT_KEYWORDS="amd64" |                                                              |       |
> | ABI_X86="32 64"                                              | Use Linux capabilities library to control privilege          |       |
> | # REPLACED BY : echo "*/* $(cpuid2cpuflags)" >> /etc/portage/package.use/00cpuflags`cdb` | Add support for the CDB database engine from the author of qmail |       |
> | #cpuid2cpuflags                                             | Add Compact Disk Digital Audio (Standard Audio CD) support   |       |
> | #CPU_FLAGS_X86: aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3 | Access cddb servers to retrieve and submit information about compact disks |       |
> | #CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3" | Copy files from the CD rather than asking the user to copy them, mostly used with games |       |
> | COMMON_FLAGS="-O2 -pipe"                                     | Add support for CD writer hardware                           |       |
> | # gcc -march=native -E -v - </dev/null 2>&1 \|sed  -n 's/.* -v - //p'`cgi` | Add CGI script support                                       |       |
> | COMMON_FLAGS="${COMMOM_FLAGS} -march=skylake -mmmx -mpopcnt -msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -mavx2 -mno-sse4a -mno-fma4 -mno-xop -mfma -mno-avx512f -mbmi -mbmi2 -maes -mpclmul -mno-avx512vl -mno-avx512bw -mno-avx512dq -mno-avx512cd -mno-avx512er -mno-avx512pf -mno-avx512vbmi -mno-avx512ifma -mno-avx5124vnniw -mno-avx5124fmaps -mno-avx512vpopcntdq -mno-avx512vbmi2 -mno-gfni -mno-vpclmulqdq -mno-avx512vnni -mno-avx512bitalg -mno-avx512bf16 -mno-avx512vp2intersect -mno-3dnow -madx -mabm -mno-cldemote -mclflushopt -mno-clwb -mno-clzero -mcx16 -mno-enqcmd -mf16c -mfsgsbase -mfxsr -mno-hle -msahf -mno-lwp -mlzcnt -mmovbe -mno-movdir64b -mno-movdiri -mno-mwaitx -mno-pconfig -mno-pku -mno-prefetchwt1 -mprfchw -mno-ptwrite -mno-rdpid -mrdrnd -mrdseed -mno-rtm -mno-serialize -msgx -mno-sha -mno-shstk -mno-tbm -mno-tsxldtrk -mno-vaes -mno-waitpkg -mno-wbnoinvd -mxsave -mxsavec -mxs aveopt -mxsaves -mno-amx-tile -mno-amx-int8 -mno-amx-bf16 -mno-uintr -mno-hreset -mno-kl -mno-widekl -mno-avxvnni --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=8192 -mtune=skylake" |                                                              |       |
> | CFLAGS="${COMMON_FLAGS}" | Add support for Clam AntiVirus software (usually with a plugin) |       |
> | CXXFLAGS="${COMMON_FLAGS}" | Support color management using x11-misc/colord               |       |
> | FCFLAGS="${COMMON_FLAGS}" |                                                              |       |
> | FFLAGS="${COMMON_FLAGS}" |                                                              |       |
> | # NOTE: This stage was built with the bindist Use flag enabled |                                                              |       |
> | PORTDIR="/var/db/repos/gentoo"                               | Add support for encryption -- using mcrypt or gpg where applicable |       |
> | DISTDIR="/var/cache/distfiles"                               | Enable reading of encrypted DVDs                             |       |
> | PKGDIR="/var/cache/binpkgs" | Add support for CUPS (Common Unix Printing System)           |       |
> | # This sets the language of build output to English.`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X``````````````` | Add support for client-side URL transfer library             |       |
> | # Please keep this setting intact when reporting bugs.`custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X```````````````` | Build with user-specified CFLAGS (unsupported)               |       |
> | LC_MESSAGES=C |                                                              |       |
> | L10N="en"                                                    | Build support for C++ (bindings, extra libraries, code generation, ...) |       |
> | # MAKEOPTS="-j1" |                                                              |       |
> | MAKEOPTS="-j6 -l6" | Add support for generic DBM databases                        |       |
> | # EMERGE_DEFAULT_OPTS`dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X````````````````` | Enable dbus support for anything that needs it (gpsd, gnomemeeting, etc) |       |
> | # -v --verbose      # -b --buildpkg     # -D --deep 			# -g --getbinpkg        # -k --usepkg |                                                              |       |
> | # -u update			# -N --newuse       # -l load-average		# -t --tree				# -G --getbinpkgonly |                                                              |       |
> | # -k --uspkgonly	# -U changed-use	# -o --fetchonly		# -a ask				# -f --fuzzy-search`dga` | Add DGA (Direct Graphic Access) support for X                |       |
> | # --list-sets		# --alphabetical    # --color=y 			# --with-bdeps=y		# --verbose-conflicts |                                                              |       |
> | # --complete-graph=y					# --backtrack=COUNT 							# --binpkg-respect-use=[y/n]`djvu` | Support DjVu, a PDF-like document format esp. suited for scanned documents |       |
> | # --autounmask=y    					# --autounmask-continue=y  						# --autounmask-backtrack=y`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X````````````````` | Add extra documentation (API, Javadoc, etc). It is recommended to enable per package instead of globally |       |
> | # --autounmask-write=y 					# --usepkg-exclude 'sys-kernel/gentoo-sources virtual/*'`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X`````````````````` | Enable direct rendering: used for accelerated 3D and some 2D, like DMA |       |
> | # EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=9 -b -v -D" --tree, -t--verbose-conflicts`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X``````````````````` | Enable DTS Coherent Acoustics decoder support                |       |
> | AUTOUNMASK="" | Enable support for a codec used by many camcorders           |       |
> | AUTOUNMASK="${AUTOUNMASK} --autounmask=y  --autounmask-continue=y --autounmask-write=y" | Add support for DVB (Digital Video Broadcasting)             |       |
> | AUTOUNMASK="${AUTOUNMASK} --autounmask-unrestricted-atoms=y --autounmask-license=y" | Add support for DVDs                                         |       |
> | AUTOUNMASK="${AUTOUNMASK} --autounmask-use=y --autounmask-write=y" | Add support for DVD writer hardware (e.g. in xcdroast)       |       |
> | EMERGE_DEFAULT_OPTS="--verbose" |                                                              |       |
> | EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=4 --load-average=4" | Enable session tracking via sys-auth/elogind                 |       |
> | #EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --with-bdeps=y " |                                                              |       |
> | #EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} ${AUTOUNMASK}" |                                                              |       |
> | EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --color=y --alphabetical --verbose-conflicts" | Add support for encoding of audio or video files             |       |
> | ### FEATURES`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X``````````````````````` | Install examples, usually source code                        |       |
> | #FEATURES="${FEATURES} fixlafiles" | Add support for reading EXIF headers from JPEG and TIFF images |       |
> | #FEATURES="${FEATURES} cgroup" |                                                              |       |
> | #FEATURES="${FEATURES} xattr split-elog "                    | Enable FAM (File Alteration Monitor) support                 |       |
> | #FEATURES="${#FEATURES} sign"                                | Add support for the FastCGI interface                        |       |
> | #FEATURES="${FEATURES} buildpkg" | Add framebuffer support for the console, via the kernel      |       |
> | # FEATURES="${FEATURES} ccache"`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X`````````````````````````` | Enable ffmpeg/libav-based audio/video codec support          |       |
> | # FEATURES="${FEATURES} userfetch usersync"`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X``````````````````````````` | Use FFTW library for computing Fourier transforms            |       |
> | # FEATURES="${FEATURES} distcc"`filecaps`                    | Use Linux file capabilities to control privilege rather than set*id (this is orthogonal to USE=caps which uses capabilities at runtime e.g. libcap) |       |
> | FEATURES="${FEATURES} parallel-fetch parallel-install" | Add support for the Firebird relational database             |       |
> | ### FEATURES : CLEANING`flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X````````````````````````````` | Add support for FLAC: Free Lossless Audio Codec              |       |
> | # FEATURES="${FEATURES} clean-logs"`fltk`                    | Add support for the Fast Light Toolkit gui interface         |       |
> | ### FEATURES : BINHOST`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X````````````````````````````` | Support for configuring and customizing font access via media-libs/fontconfig |       |
> | #FEATURES="${FEATURES} getbinpkg" | Add support for fortran                                      |       |
> | #FEATURES="${FEATURES} binpkg-multi-instance"                | Add support for the TDS protocol to connect to MSSQL/Sybase databases |       |
> | ### FEATURES : FAILING |                                                              |       |
> | # FEATURES="${FEATURES} keepwork failclean"#`ftp`fortran`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X``````````````````````````````` | Add FTP (File Transfer Protocol) support                     |       |
> | # FEATURES="${FEATURES} merge-sync"`gd`                      | Add support for media-libs/gd (to generate graphics on the fly) |       |
> | # keeptemp"`gdbm`ftp`fortran`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X```````````````````````````````` | Add support for sys-libs/gdbm (GNU database libraries)       |       |
> | # FEATURES="${FEATURES} protect-owned"`geoip`gdbm`ftp`fortran`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X````````````````````````````````` | Add geoip support for country and city lookup based on IPs   |       |
> | # collision-protect"`geolocation`geoip`gdbm`ftp`fortran`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X`````````````````````````````````` | Enable physical position determination                       |       |
> | #GENTOO_MIRRORS="" |                                                              |       |
> | #### BELGIUM \|BELNET`gif`geolocation`geoip`gdbm`ftp`fortran`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X``````````````````````````````````` | Add GIF image support                                        |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} http://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/" | Build a plugin for the GIMP                                  |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} https://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/" | Enable git (version control system) support                  |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/" |                                                              |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} rsync://rsync.belnet.be/gentoo/" | Build an OpenGL plugin using the GLUT library                |       |
> | #### LUXEMBURG`gmp`                                          | Add support for dev-libs/gmp (GNU MP library)                |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} http://gentoo.mirror.root.lu/" |                                                              |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} https://gentoo.mirror.root.lu/" |                                                              |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://mirror.root.lu/gentoo/" | Enable support for gnuplot (data and function plotting)      |       |
> | ##### NETHERLANDS \|UNIVERSITY TWENTE`gnutls`gnuplot`git`gimp`gif`geolocation`geoip`gdbm`ftp`fortran`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X``````````````````````````````````````` | Prefer net-libs/gnutls as SSL/TLS provider (ineffective with USE=-ssl) |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} http://ftp.snt.utwente.nl/pub/os/linux/gentoo" | Add digital camera support                                   |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} https://ftp.snt.utwente.nl/pub/os/linux/gentoo" | Add support for sys-libs/gpm (Console-based mouse driver)    |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://ftp.snt.utwente.nl/pub/os/linux/gentoo" | Add support for Global Positioning System                    |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} rsync://ftp.snt.utwente.nl/gentoo/" |                                                              |       |
> | #### NETHERLANDS \|LEASWEB`graphviz`gps`gpm`gphoto2`gnutls`gnuplot`git`gimp`gif`geolocation`geoip`gdbm`ftp`fortran`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X``````````````````````````````````````````` | Add support for the Graphviz library                         |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} http://mirror.leaseweb.com/gentoo/" | Use the GNU scientific library for calculations              |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} https://mirror.leaseweb.com/gentoo/" | Add support for the gsm lossy speech compression codec       |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://mirror.leaseweb.com/gentoo/" | Add support for media-libs/gstreamer (Streaming media)       |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} rsync://mirror.leaseweb.com/gentoo/" |                                                              |       |
> | ########################### |                                                              |       |
> | # BINPKG`gui`gstreamer`gsm`gsl`graphviz`gps`gpm`gphoto2`gnutls`gnuplot`git`gimp`gif`geolocation`geoip`gdbm`ftp`fortran`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X``````````````````````````````````````````````` | Enable support for a graphical user interface                |       |
> | #BINPKG_FORMAT="gpkg" | Add support for the guile Scheme interpreter                 |       |
> | #BINPKG_COMPRESS="lz4" | Compress files with Lempel-Ziv coding (LZ77)                 |       |
> | #PORTAGE_BINHOST="https://gentoo.osuosl.org/experimental/amd64/binpkg/default/linux/17.1/x86-64/" | Enable handbooks generation for packages by KDE              |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} http://packages.gentooexperimental.org/packages/amd64-stable/" |                                                              |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} http://packages.gentooexperimental.org/packages/amd64-stable/" | Enable monitoring of hdd temperature (app-admin/hddtemp)     |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} https://packages.gentooexperimental.org" | Add support for the Hierarchical Data Format v5              |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} ftp://packages.gentooexperimental.org" |                                                              |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} ftps//packages.gentooexperimental.org" | Enable support for ISO/IEC 23008-12:2017 HEIF/HEIC image format |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} rsync://packages.gentooexperimental.org" | Include coloured haskell sources to generated documentation (dev-haskell/hscolour) |       |
> | GRUB_PLATFORM="efi-64" |                                                              |       |
> | ALSA_CARDS="hda-intel usb-audio emu10k1 emu10k1x emu20k1x emu20k1 intel8x0 intel8x0m bt87x hdsp hdspm ice1712 mixart rme32 rme96 sb16 sbawe sscape usb-usx2y vx222" | Enable support for the iconv character set conversion library |       |
> | VIDEO_CARDS="nvidia d3d12 vmware" | Enable ICU (Internationalization Components for Unicode) support, using dev-libs/icu |       |
> | INPUT_DEVICES="evdev libinput"                               | Enable support for Internationalized Domain Names            |       |
> | INPUT_DRIVERS="evdev" | Enable FireWire/iLink IEEE1394 support (dv, camera, ...)     |       |
> | mkdir -p -v /mnt/gentoo/etc/portage/repos.conf | Enable optional support for the ImageMagick or GraphicsMagick image converter |       |
> | # Turn on logging - see http://gentoo-en.vfose.ru/wiki/Gentoo_maintenance.`imap`imlib`infiniband``inotify`introspection`ios`ipod`ipv6`java`javascript``jit`joystick`jpeg`jpeg2k`kde`kerberos`ladspa`lame`lapack`libcaca`libffi`libnotify`libsamplerate`llvm-libunwind`lm-sensors`lua``lz4`lzo``mad`magic``man`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````````lzma``````````````````````````imagemagick`imap`imlib`infiniband``inotify`introspection`ios`ipod`ipv6`java`javascript``jit`joystick`jpeg`jpeg2k`kde`kerberos`ladspa`lame`lapack`libcaca`libffi`libnotify`libsamplerate`llvm-libunwind`lm-sensors`lua``lz4`lzo``mad`magic``man`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````````lzma```````````````````````````ieee1394`imagemagick`imap`imlib`infiniband``inotify`introspection`ios`ipod`ipv6`java`javascript``jit`joystick`jpeg`jpeg2k`kde`kerberos`ladspa`lame`lapack`libcaca`libffi`libnotify`libsamplerate`llvm-libunwind`lm-sensors`lua``lz4`lzo``mad`magic``man`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````````lzma````````````````icu`iconv`heif`hddtemp`handbook`gzip`guile`gui`gstreamer`gsm`gsl`graphviz`gps`gpm`gphoto2`gnutls`gnuplot`git`gimp`gif`geolocation`geoip`gdbm`ftp`fortran`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X`````````````````````````````````````````````````````````````````` | Add support for IMAP (Internet Mail Application Protocol)    |       |
> | #PORTAGE_ELOG_CLASSES="info warn error log qa" | Add support for imlib, an image loading and rendering library |       |
> | # Echo messages after emerge, also save to /var/log/portage/elog`infiniband``inotify`introspection`ios`ipod`ipv6`java`javascript``jit`joystick`jpeg`jpeg2k`kde`kerberos`ladspa`lame`lapack`libcaca`libffi`libnotify`libsamplerate`llvm-libunwind`lm-sensors`lua``lz4`lzo``mad`magic``man`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````````lzma````````````````````````imlib`infiniband``inotify`introspection`ios`ipod`ipv6`java`javascript``jit`joystick`jpeg`jpeg2k`kde`kerberos`ladspa`lame`lapack`libcaca`libffi`libnotify`libsamplerate`llvm-libunwind`lm-sensors`lua``lz4`lzo``mad`magic``man`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````````lzma`````````````````````````imap`imlib`infiniband``inotify`introspection`ios`ipod`ipv6`java`javascript``jit`joystick`jpeg`jpeg2k`kde`kerberos`ladspa`lame`lapack`libcaca`libffi`libnotify`libsamplerate`llvm-libunwind`lm-sensors`lua``lz4`lzo``mad`magic``man`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````````lzma``````````````````````````imagemagick`imap`imlib`infiniband``inotify`introspection`ios`ipod`ipv6`java`javascript``jit`joystick`jpeg`jpeg2k`kde`kerberos`ladspa`lame`lapack`libcaca`libffi`libnotify`libsamplerate`llvm-libunwind`lm-sensors`lua``lz4`lzo``mad`magic``man`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````````lzma```````````````````````````ieee1394`imagemagick`imap`imlib`infiniband``inotify`introspection`ios`ipod`ipv6`java`javascript``jit`joystick`jpeg`jpeg2k`kde`kerberos`ladspa`lame`lapack`libcaca`libffi`libnotify`libsamplerate`llvm-libunwind`lm-sensors`lua``lz4`lzo``mad`magic``man`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````````lzma````````````````icu`iconv`heif`hddtemp`handbook`gzip`guile`gui`gstreamer`gsm`gsl`graphviz`gps`gpm`gphoto2`gnutls`gnuplot`git`gimp`gif`geolocation`geoip`gdbm`ftp`fortran`fontconfig``flac`firebird`fftw`ffmpeg`fbcon`exif`examples`encode`dvdr`dvd``dv`dts`dri`doc``dbus`dbm``custom-cflags`curl`cups`colord`clamav`bzip2`bluetooth`bash-completion`audiofile``appindicator`alsa`acpi`accessibility`aalib`aac`a52`X`````````````````````````````````````````````````````````````````` | Enable Infiniband RDMA transport support                     |       |
> | #PORTAGE_ELOG_SYSTEM="echo save" | Enable inotify filesystem monitoring support                 |       |
> | USE_BASE="acl amd64 bzip2 cli crypt dri fortran gdbm iconv ipv6 libglvnd libtirpc multilib ncurses nls nptl openmp pam pcre readline seccomp ssl systemd test-rust udev unicode xattr zlib" | Add support for GObject based introspection                  |       |
> | USE_DESKTOP="X a52 aac acpi alsa bluetooth branding cairo cdda cdr crypt cups dbus dts dvd dvdr encode exif flac gif gpm gtk gui iconv icu jpeg lcms libnotify mad mng mp3 mp4 mpeg ogg opengl pango pdf png policykit ppds qt5 sdl sound spell startup-notification svg tiff truetype udisks upower usb vorbis wxwidgets x264 xcb xft xml xv xvid" |                                                              |       |
> | USE_PLASMA="activities declarative kde kwallet plasma qml semantic-desktop widgets xattr" | Enable support for Apple's iDevice with iOS operating system (iPad, iPhone, iPod, etc) |       |
> | USE_PLASMA="activities declarative kde plasma qml semantic-desktop widgets xattr" | Enable support for iPod device access                        |       |
> | USE="tools custom-cflags network multimedia  " | Add support for IP version 6                                 |       |
> | "gles2 opencl tools \ |                                                              |       |
> | persistenced \ | Add support for Java                                         |       |
> | libsamplerate opencv custom-cflags grub network  \ | Enable javascript support                                    |       |
> | dri semantic-desktop \                                       | Enable jbig-kit support for tiff, Hylafax, ImageMagick, etc  |       |
> | modplug modules \ |                                                              |       |
> | multimedia   ao \ | Enable just-in-time compilation for improved performance. May prevent use of some PaX memory protection features in Gentoo Hardened. |       |
> | audiofile  branding cairo cdb cdda cddb cdr cgi \ | Add support for joysticks in all packages                    |       |
> | colord crypt css curl dbm dga dts dv dvb dvd dvdr encode exif \ | Add JPEG image support                                       |       |
> | fbcon ffmpeg fftw flac fltk fontconfig fortran ftp gd gif \ | Support for JPEG 2000, a wavelet-based image compression format |       |
> | glut gnuplot gphoto2 graphviz gzip handbook imagemagick imap \ | Add support for software made by KDE, a free software community |       |
> | imlib ipv6 java javascript joystick jpeg kerberos ladspa lame \ | Add kerberos support                                         |       |
> | lcms ldap libcaca libnotify libwww lua lzma lz4 lzo mad magic \ | Enable the ability to support ladspa plugins                 |       |
> | man matroska mikmod mmap mms mono mp3 mp4 mpeg mplayer mtp \ | Prefer using LAME libraries for MP3 encoding support         |       |
> | mysqli nas ncurses nsplugin offensive ogg openal opus osc pda \ | Add support for the virtual/lapack numerical library         |       |
> | pdf php plotutils png postscript radius raw rdp rss ruby samba \ | Add LASH Audio Session Handler support                       |       |
> | sasl savedconfig sdl session smartcard smp sndfile snmp \    | Add support for LaTeX (typesetting package)                  |       |
> | sockets socks5 sound sox speex spell sqlite ssl \            | Add lcms support (color management engine)                   |       |
> | startup-notification suid svg symlink szip tcl tcpd theora tidy tiff timidity \ | Add LDAP support (Lightweight Directory Access Protocol)     |       |
> | tk  udev udisks  upnp-av upower v4l vaapi vcd \              | SRT/SSA/ASS (SubRip / SubStation Alpha) subtitle support     |       |
> | videos vim-syntax vnc vorbis  webkit webp wmf wxwidgets \ | Add support for colored ASCII-art graphics                   |       |
> | xattr xcomposite xine xinerama xinetd xml xmp xmpp xosd \   | Use the libedit library (replacement for readline)           |       |
> | xpm xv   zlib zsh-completion zstd source \ | Enable support for Foreign Function Interface library        |       |
> | script openexr echo-cancel extra gstreamer jack-sdk lv2 \ | Enable desktop notification support                          |       |
> | sound-server system-service v4l2 zimg \ | Build with support for converting sample rates using libsamplerate |       |
> | rubberband pulse#!/usr/bin/env bashaudio libmpv gamepad drm cplugins archive screencast \ | Add libwww support (General purpose WEB API)                 |       |
> | # These settings were set by the catalyst build script that automaticallygbm   examples " | Add support for lirc (Linux's Infra-Red Remote Control)      |       |
> | # built this stage. |                                                              |       |
> | # Please consult /usr/share/portage/config/make.conf.example for a more`llvm-libunwind`lm-sensors`lua``lz4`lzo``mad`magic``man`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````````lzma```` | Use sys-libs/llvm-libunwind instead of sys-libs/libunwind    |       |
> | # detailed example.`lm-sensors`lua``lz4`lzo``mad`magic``man`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````````lzma``` | Add linux lm-sensors (hardware sensors) support              |       |
> | CHOST="x86_64-pc-linux-gnu" | Enable Lua scripting support                                 |       |
> | ACCEPT_LICENSE="*" | Support for LZMA (de)compression algorithm                   |       |
> | ACCEPT_KEYWORDS="amd64" | Enable support for lz4 compression (as implemented in app-arch/lz4) |       |
> | ABI_X86="32 64" | Enable support for lzo compression                           |       |
> | # REPLACED BY : echo "*/* $(cpuid2cpuflags)" >> /etc/portage/package.use/00cpuflags`m17n-lib` | Enable m17n-lib support                                      |       |
> | #cpuid2cpuflags | Add support for mad (high-quality mp3 decoder library and cli frontend) |       |
> | #CPU_FLAGS_X86: aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3 | Add support for file type detection via magic bytes (usually via libmagic from sys-apps/file) |       |
> | #CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3" |                                                              |       |
> | COMMON_FLAGS="-O2 -pipe" | Build and install man pages                                  |       |
> | # gcc -march=native -E -v - </dev/null 2>&1 \|sed  -n 's/.* -v - //p'`matroska`mikmod `mmap`mms``modplug`modules`mono``mp3`mp4`mpeg` `mtp```````` | Add support for the matroska container format (extensions .mkv, .mka and .mks) |       |
> | COMMON_FLAGS="${COMMOM_FLAGS} -march=skylake -mmmx -mpopcnt -msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -mavx2 -mno-sse4a -mno-fma4 -mno-xop -mfma -mno-avx512f -mbmi -mbmi2 -maes -mpclmul -mno-avx512vl -mno-avx512bw -mno-avx512dq -mno-avx512cd -mno-avx512er -mno-avx512pf -mno-avx512vbmi -mno-avx512ifma -mno-avx5124vnniw -mno-avx5124fmaps -mno-avx512vpopcntdq -mno-avx512vbmi2 -mno-gfni -mno-vpclmulqdq -mno-avx512vnni -mno-avx512bitalg -mno-avx512bf16 -mno-avx512vp2intersect -mno-3dnow -madx -mabm -mno-cldemote -mclflushopt -mno-clwb -mno-clzero -mcx16 -mno-enqcmd -mf16c -mfsgsbase -mfxsr -mno-hle -msahf -mno-lwp -mlzcnt -mmovbe -mno-movdir64b -mno-movdiri -mno-mwaitx -mno-pconfig -mno-pku -mno-prefetchwt1 -mprfchw -mno-ptwrite -mno-rdpid -mrdrnd -mrdseed -mno-rtm -mno-serialize -msgx -mno-sha -mno-shstk -mno-tbm -mno-tsxldtrk -mno-vaes -mno-waitpkg -mno-wbnoinvd -mxsave -mxsavec -mxs aveopt -mxsaves -mno-amx-tile -mno-amx-int8 -mno-amx-bf16 -mno-uintr -mno-hreset -mno-kl -mno-widekl -mno-avxvnni --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=8192 -mtune=skylake" |                                                              |       |
> | CFLAGS="${COMMON_FLAGS}"                                     | Add support for memcached                                    |       |
> | CXXFLAGS="${COMMON_FLAGS}"                                   | Add support for the mhash library                            |       |
> | FCFLAGS="${COMMON_FLAGS}" | Add libmikmod support to allow playing of SoundTracker-style music files |       |
> | FFLAGS="${COMMON_FLAGS}" |                                                              |       |
> | # NOTE: This stage was built with the bindist Use flag enabled |                                                              |       |
> | PORTDIR="/var/db/repos/gentoo"    | Add mmap (memory map) support                                |       |
> | DISTDIR="/var/cache/distfiles"          | Support for Microsoft Media Server (MMS) streams             |       |
> | PKGDIR="/var/cache/binpkgs"                                  | Add support for libmng (MNG images)                          |       |
> | # This sets the language of build output to English.`modplug`modules`mono``mp3`mp4`mpeg` `mtp````` | Add libmodplug support for playing SoundTracker-style music files |       |
> | # Please keep this setting intact when reporting bugs.`modules`mono``mp3`mp4`mpeg` `mtp```` | Build the kernel modules                                     |       |
> | LC_MESSAGES=C                                 | Build Mono bindings to support dotnet type stuff             |       |
> | L10N="en"                                                    | Add support for the Motif toolkit                            |       |
> | # MAKEOPTS="-j1" `mp3`mp4`mpeg` `mtp```                      | Add support for reading mp3 files                            |       |
> | MAKEOPTS="-j6 -l6"                                           | Support for MP4 container format                             |       |
> | # EMERGE_DEFAULT_OPTS`mpeg` `mtp`                            | Add libmpeg3 support to various packages                     |       |
> | # -v --verbose      # -b --buildpkg     # -D --deep 			# -g --getbinpkg        # -k --usepkg`mpi` | Add MPI (Message Passing Interface) layer to the apps that support it |       |
> | # -u update			# -N --newuse       # -l load-average		# -t --tree				# -G --getbinpkgonly`mplayer` | Enable mplayer support for playback or encoding              |       |
> | # -k --uspkgonly	# -U changed-use	# -o --fetchonly		# -a ask				# -f --fuzzy-search`mssql` | Add support for Microsoft SQL Server database                |       |
> | # --list-sets		# --alphabetical    # --color=y 			# --with-bdeps=y		# --verbose-conflicts`mtp` | Enable support for Media Transfer Protocol                   |       |
> | # --complete-graph=y					# --backtrack=COUNT 							# --binpkg-respect-use=[y/n]`multilib`musepack`m | On 64bit systems, if you want to be able to compile 32bit and 64bit binaries |       |
> | # --autounmask=y    					# --autounmask-continue=y  						# --autounmask-backtrack=y`musepack`musicbrainz`mysql`mysqli`nas` | Enable support for the musepack audio codec                  |       |
> | # --autounmask-write=y 					# --usepkg-exclude 'sys-kernel/gentoo-sources virtual/*'`musicbrainz`mysql`mysqli`nas`ncurses``nls``ns | Lookup audio metadata using MusicBrainz community service (musicbrainz.org) |       |
> | # EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=9 -b -v -D" --tree, -t--verbose-conflicts`mysql`mysqli`nas`ncurses``nls``nsplugin`nvenc`ocaml`ocamlopt | Add mySQL Database support                                   |       |
> | AUTOUNMASK="" | Add support for the improved mySQL libraries                 |       |
> | AUTOUNMASK="${AUTOUNMASK} --autounmask=y  --autounmask-continue=y --autounmask-write=y" | Add support for network audio sound                          |       |
> | AUTOUNMASK="${AUTOUNMASK} --autounmask-unrestricted-atoms=y --autounmask-license=y" | Add ncurses support (console display library)                |       |
> | AUTOUNMASK="${AUTOUNMASK} --autounmask-use=y --autounmask-write=y" | Enable neXt toolkit                                          |       |
> | EMERGE_DEFAULT_OPTS="--verbose"                              | Enable NetCDF data format support                            |       |
> | EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=4 --load-average=4" |                                                              |       |
> | #EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --with-bdeps=y " | Support for NIS/YP services                                  |       |
> | #EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} ${AUTOUNMASK}"  | Add Native Language Support (using gettext - GNU locale utilities) |       |
> | EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --color=y --alphabetical --verbose-conflicts" | Add support for newsgroups (Network News Transfer Protocol)  |       |
> | ### FEATURES`nocd`                                           | Install all files required to run the application without a CD mounted |       |
> | #FEATURES="${FEATURES} fixlafiles"                           | Build plugin for browsers supporting the Netscape plugin architecture (that is almost any modern browser) |       |
> | #FEATURES="${FEATURES} cgroup"                               | Add support for NVIDIA Encoder/Decoder (NVENC/NVDEC) API for hardware accelerated encoding and decoding on NVIDIA cards (requires x11-drivers/nvidia-drivers) |       |
> | #FEATURES="${FEATURES} xattr split-elog "                    | Add support/bindings for the Ocaml language                  |       |
> | #FEATURES="${#FEATURES} sign"                                | Enable ocamlopt support (ocaml native code compiler) -- Produces faster programs (Warning: you have to disable/enable it at a global scale) |       |
> | #FEATURES="${FEATURES} buildpkg" |                                                              |       |
> | # FEATURES="${FEATURES} ccache" |                                                              |       |
> | # FEATURES="${FEATURES} userfetch usersync"`odbc`            | Add ODBC Support (Open DataBase Connectivity)                |       |
> | # FEATURES="${FEATURES} distcc"`offensive``ogg`openal``opengl` |                                                              |       |
> | FEATURES="${FEATURES} parallel-fetch parallel-install"       | Enable support for importing (and exporting) OFX (Open Financial eXchange) data files |       |
> | ### FEATURES : CLEANING`ogg`openal``opengl`openmp`opentype-compat` | Add support for the Ogg container format (commonly used by Vorbis, Theora and flac) |       |
> | # FEATURES="${FEATURES} clean-logs"`openal``opengl`openmp`opentype-compat`opus``orc`osc``pch`pda`` | Add support for the Open Audio Library                       |       |
> | ### FEATURES : BINHOST`openexr`                              | Support for the OpenEXR graphics file format                 |       |
> | #FEATURES="${FEATURES} getbinpkg"               | Add support for OpenGL (3D graphics)                         |       |
> | #FEATURES="${FEATURES} binpkg-multi-instance"                | Build support for the OpenMP (support parallel computing), requires >=sys-devel/gcc-4.2 built with USE="openmp" |       |
> | ### FEATURES : FAILING`opentype-compat`opus``orc`osc``pch`pda``pdf`perl`php```` | Convert BDF and PCF bitmap fonts to OTB wrapper format       |       |
> | # FEATURES="${FEATURES} keepwork failclean"#`opus``orc`osc``pch`pda``pdf`perl`php``` | Enable Opus audio codec support                              |       |
> | # FEATURES="${FEATURES} merge-sync" |                                                              |       |
> | # keeptemp"`orc`osc``pch`pda``pdf`perl`php```                | Use dev-lang/orc for just-in-time optimization of array operations |       |
> | # FEATURES="${FEATURES} protect-owned"`osc``pch`pda``pdf`perl`php`` | Enable support for Open Sound Control                        |       |
> | # collision-protect"`oss`                                    | Add support for OSS (Open Sound System)                      |       |
> | #GENTOO_MIRRORS=""                                | Add support for PAM (Pluggable Authentication Modules) - DANGEROUS to arbitrarily flip |       |
> | #### BELGIUM \|BELNET`pch`pda``pdf`perl`php``                 | Enable precompiled header support for faster compilation at the expense of disk space and memory (>=sys-devel/gcc-3.4 only) |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} http://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/" |                                                              |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} https://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/" | Add support for Perl Compatible Regular Expressions          |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://ftp.belnet.be/mirror/rsync.gentoo.org/gentoo/" | Add support for portable devices                             |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} rsync://rsync.belnet.be/gentoo/" | Add general support for PDF (Portable Document Format), this replaces the pdflib and cpdflib flags |       |
> | #### LUXEMBURG`perl`php                                      | Add optional support/bindings for the Perl language          |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} http://gentoo.mirror.root.lu/" | Include support for the PHP language                         |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} https://gentoo.mirror.root.lu/" | Build programs as Position Independent Executables (a security hardening technique) |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://mirror.root.lu/gentoo/" | Build optional KDE plasma addons                             |       |
> | ##### NETHERLANDS \|UNIVERSITY TWENTE | Add support for plotutils (library for 2-D vector graphics)  |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} http://ftp.snt.utwente.nl/pub/os/linux/gentoo" |                                                              |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} https://ftp.snt.utwente.nl/pub/os/linux/gentoo" |                                                              |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://ftp.snt.utwente.nl/pub/os/linux/gentoo" | Add support for the crossplatform portaudio audio API        |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} rsync://ftp.snt.utwente.nl/gentoo/" | Add support for POSIX-compatible functions                   |       |
> | #### NETHERLANDS \|LEASWEB`postgres                           |                                                              |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} http://mirror.leaseweb.com/gentoo/" | Enable support for the PostScript language (often with ghostscript-gpl or libspectre) |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} https://mirror.leaseweb.com/gentoo/" | Add support for automatically generated ppd (printing driver) files |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} ftp://mirror.leaseweb.com/gentoo/" |                                                              |       |
> | GENTOO_MIRRORS="${GENTOO_MIRRORS} rsync://mirror.leaseweb.com/gentoo/" |                                                              |       |
> | ########################### |                                                              |       |
> | # BINPKG`python``qt5`qt6`qu                                  | Add optional support/bindings for the Python language        |       |
> | #BINPKG_FORMAT="gpkg"                                        | Add support for the qdbm (Quick Database Manager) library    |       |
> | #BINPKG_COMPRESS="lz4"                                       | Add support for qmail SMTP plugins                           |       |
> | #PORTAGE_BINHOST="https://gentoo.osuosl.org/experimental/amd64/binpkg/default/linux/17.1/x86-64/" | Add support for the Qt 5 application and UI framework        |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} http://packages.gentooexperimental.org/packages/amd64-stable/" | Add support for the Qt 6 application and UI framework        |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} http://packages.gentooexperimental.org/packages/amd64-stable/" | Add support for OpenQuickTime                                |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} https://packages.gentooexperimental.org" |                                                              |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} ftp://packages.gentooexperimental.org" | Add support for raw image formats                            |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} ftps//packages.gentooexperimental.org" |                                                              |       |
> | #PORTAGE_BINHOST="${PORTAGE_BINHOST} rsync://packages.gentooexperimental.org" | Enable support for libreadline, a GNU line-editing library that almost everyone wants |       |
> | GRUB_PLATFORM="efi-64"                                       | Enable support for the GNU recode library                    |       |
> | ALSA_CARDS="hda-intel usb-audio emu10k1 emu10k1x emu20k1x emu20k1 intel8x0 intel8x0m bt87x hdsp hdspm ice1712 mixart rme32 rme96 sb16 sbawe sscape usb-usx2y vx222" | Enable support for RSS feeds                                 |       |
> | VIDEO_CARDS="nvidia d3d12 vmware"                            | Add support/bindings for the Ruby language                   |       |
> | INPUT_DEVICES="evdev libinput"                               | Add support for SAMBA (Windows File and Printer sharing)     |       |
> | INPUT_DRIVERS="evdev"                                        | Add support for the Simple Authentication and Security Layer |       |
> | mkdir -p -v /mnt/gentoo/etc/portage/repos.conf              | Use this to restore your config from /etc/portage/savedconfig ${CATEGORY}/${PN}. Make sure your USE flags allow for appropriate dependencies |       |
> | # Turn on logging - see http://gentoo-en.vfose.ru/wiki/Gentoo_maintenance.notification`suid`svg | Add support for scanner hardware (e.g. build the sane frontend in kdegraphics) |       |
> | #PORTAGE_ELOG_CLASSES="info warn error log qa"               | Enable support for remote desktop and screen cast using PipeWire |       |
> | # Echo messages after emerge, also save to /var/log/portage/elog`sctp` | Support for Stream Control Transmission Protocol             |       |
> | #PORTAGE_ELOG_SYSTEM="echo save"                             | Add support for Simple Direct Layer (media library)          |       |
> | USE_BASE="acl amd64 bzip2 cli crypt dri fortran gdbm iconv ipv6 libglvnd libtirpc multilib ncurses nls nptl openmp pam pcre readline seccomp ssl systemd test-rust udev unicode xattr zlib" |                                                              |       |
> | USE_DESKTOP="X a52 aac acpi alsa bluetooth branding cairo cdda cdr crypt cups dbus dts dvd dvdr encode exif flac gif gpm gtk gui iconv icu jpeg lcms libnotify mad mng mp3 mp4 mpeg ogg opengl pango pdf png policykit ppds qt5 sdl sound spell startup-notification svg tiff truetype udisks upower usb vorbis wxwidgets x264 xcb xft xml xv xvid" |                                                              |       |
> | USE_PLASMA="activities declarative kde kwallet plasma qml semantic-desktop widgets xattr" | Cross-KDE support for semantic search and information retrieval |       |
> | USE_PLASMA="activities declarative kde plasma qml semantic-desktop widgets xattr" | Add persistent session support                               |       |
> | USE="tools custom-cflags network multimedia  "               | Enable S/Key (Single use password) authentication support    |       |
> | "gles2 opencl tools \                                        |                                                              |       |
> | persistenced \                                              |                                                              |       |
> | libsamplerate opencv custom-cflags grub network  \           | Enable support for multiprocessors or multicore systems      |       |
> | dri semantic-desktop \                                       |                                                              |       |
> | modplug modules \                                            | Add support for libsndfile                                   |       |
> | multimedia   ao \                                            | Add support for the Simple Network Management Protocol if available |       |
> | audiofile  branding cairo cdb cdda cddb cdr cgi \            | Add support for SOAP (Simple Object Access Protocol)         |       |
> | colord crypt css curl dbm dga dts dv dvb dvd dvdr encode exif \ |                                                              |       |
> | fbcon ffmpeg fftw flac fltk fontconfig fortran ftp gd gif \  | Add support for the socks5 proxy                             |       |
> | glut gnuplot gphoto2 graphviz gzip handbook imagemagick imap \ | Enable sound support                                         |       |
> | imlib ipv6 java javascript joystick jpeg kerberos ladspa lame \ | Zip the sources and install them                             |       |
> | lcms ldap libcaca libnotify libwww lua lzma lz4 lzo mad magic \ | Add support for Sound eXchange (SoX)                         |       |
> | man matroska mikmod mmap mms mono mp3 mp4 mpeg mplayer mtp \ |                                                              |       |
> | mysqli nas ncurses nsplugin offensive ogg openal opus osc pda \ | Add dictionary support                                       |       |
> | pdf php plotutils png postscript radius raw rdp rss ruby samba \ |                                                              |       |
> | sasl savedconfig sdl session smartcard smp sndfile snmp \ | Add support for sqlite - embedded sql database               |       |
> | sockets socks5 sound sox speex spell sqlite ssl \            | Add support for SSL/TLS connections (Secure Socket Layer / Transport Layer Security) |       |
> | startup-notification suid svg symlink szip tcl tcpd theora tidy tiff timidity \ | Enable application startup event feedback mechanism          |       |
> | tk  udev udisks  upnp-av upower v4l vaapi vcd \ |                                                              |       |
> | videos vim-syntax vnc vorbis  webkit webp wmf wxwidgets \ |                                                              |       |
> | xattr xcomposite xine xinerama xinetd xml xmp xmpp xosd \ |                                                              |       |
> | xpm xv   zlib zsh-completion zstd source \                   | Enable setuid root program(s)                                |       |
> | script openexr echo-cancel extra gstreamer jack-sdk lv2 \   | Add support for SVG (Scalable Vector Graphics)               |       |
> | sound-server system-service v4l2 zimg \                     | Add support for SVGAlib (graphics library)                   |       |
> | rubberband pulseaudio libmpv gamepad drm cplugins archive screencast \ | Force kernel ebuilds to automatically update the /usr/src/linux symlink |       |
> | gbm   examples "                                             | Enable support for syslog                                    |       |
> | `systemd`szip`taglib`tcl``tcpd````                           | Enable use of systemd-specific libraries and features like socket activation or session tracking |       |
> | `szip`taglib`tcl``tcpd```                                    | Use the szip compression library                             |       |
> | `taglib`tcl``tcpd``                                          | Enable tagging support with taglib                           |       |
> | `tcl``tcpd`                                                  | Add support the Tcl language                                 |       |
> | `tcmalloc`                                                   | Use the dev-util/google-perftools libraries to replace the malloc() implementation with a possibly faster one |       |
> | `tcpd`                                                       | Add support for TCP wrappers                                 |       |
> |                                                              |                                                              |       |
> | `test`                                                       | Enable dependencies and/or preparations necessary to run tests (usually controlled by FEATURES=test but can be toggled independently) |       |
> |                                                              |                                                              |       |
> | `theora`threads``tid                                         | Add support for the Theora Video Compression Codec           |       |
> | ``                                                           | Add threads support for various packages. Usually pthreads   |       |
> | `tidy``````````                                              | Add support for HTML Tidy                                    |       |
> | `tiff`timidit                                                | Add support for the TIFF image format                        |       |
> | `timidity`tr`webkit`webp``````````                           | Build with Timidity++ (MIDI sequencer) support               |       |
> | `tk`                                                         | Add support for Tk GUI toolkit                               |       |
> | `truetype`wer`````                                           | Add support for FreeType and/or FreeType2 fonts              |       |
> | `udev`udisks``uni                                            | Enable virtual/udev integration (device discovery, power and storage device support, etc) |       |
> | `udisks``unicode`upnp``uvpack` `wayland`webkit`webp```````   | Enable storage management support (automounting, volume monitoring, etc) |       |
> | `unicode`upnp``u                                             |                                                              |       |
> | `unwind`                                                     | Add support for call stack unwinding and function name resolution |       |
> | `upnp``upower`usb`v4l``v                                     | Enable UPnP port mapping support                             |       |
> | `upnp-av`                                                    | Enable UPnP audio/video streaming support                    |       |
> | ``                                                           | Enable power management support                              |       |
> | `usb`v4l``vim-syntax`vnc`vorbis`                             | Add USB support to applications that have optional USB support (e.g. cups) |       |
> | `v4l``vim-syntax`vnc`vorbiebp````                            | Enable support for video4linux (using linux-headers or userspace libv4l libraries) |       |
> | `vaapi`                                                      | Enable Video Acceleration API for hardware decoding          |       |
> | `vala`                                                       | Enable bindings for dev-lang/vala                            |       |
> |                                                              |                                                              |       |
> | `vcd`                                                        | Video CD support                                             |       |
> | `vdpau`                                                      | Enable the Video Decode and Presentation API for Unix acceleration interface |       |
> |                                                              |                                                              |       |
> |                                                              |                                                              |       |
> | `videos`                                                     | Install optional video files (used in some games)            |       |
> | `vim-synt                                                    | Pulls in related vim syntax scripts                          |       |
> | `vnc`vorbis`wavpack` `wayland`webkit`webp```                 | Enable VNC (remote desktop viewer) support                   |       |
> | `vorbis`wavpack` `wayland`webkit`webp``                      | Add support for the OggVorbis audio codec                    |       |
> | `wavpack` `wayland`webkit`webp`                              | Add support for wavpack audio compression tools              |       |
> | `wayland`webkit`webp`                                        | Enable dev-libs/wayland backend                              |       |
> | `webkit`webp                                                 | Add support for the WebKit HTML rendering/layout engine      |       |
> | `webp`                                                       | Add support for the WebP image format                        |       |
> | `wifi`                                                       | Enable wireless network functions                            |       |
> | `wmf`                                                        | Add support for the Windows Metafile vector image format     |       |
> | `wxwidgets`                                                  | Add support for wxWidgets/wxGTK GUI toolkit                  |       |
> | `x264`                                                       | Enable h264 encoding using x264                              |       |
> | `xattr`                                                      | Add support for extended attributes (filesystem-stored metadata) |       |
> | `xcb`                                                        | Support the X C-language Binding, a replacement for Xlib     |       |
> | `xcomposite`                                                 | Enable support for the Xorg composite extension              |       |
> |                                                              |                                                              |       |
> | `xface`                                                      | Add xface support used to allow a small image of xface format to be included in an email via the header 'X-Face' |       |
> | `xft`                                                        | Build with support for XFT font renderer (x11-libs/libXft)   |       |
> | `xine`                                                       | Add support for the XINE movie libraries                     |       |
> | `xinerama`                                                   | Add support for querying multi-monitor screen geometry through the Xinerama API |       |
> | `xinetd`                                                     | Add support for the xinetd super-server                      |       |
> | `xml`                                                        | Add support for XML files                                    |       |
> | `xmlrpc`                                                     | Support for xml-rpc library                                  |       |
> | `xmp`                                                        | Enable support for Extensible Metadata Platform (Adobe XMP)  |       |
> | `xmpp`                                                       | Enable support for Extensible Messaging and Presence Protocol (XMPP) formerly known as Jabber |       |
> | `xosd`                                                       | Sends display using the X On Screen Display library          |       |
> | `xpm`                                                        | Add support for XPM graphics format                          |       |
> | `xscreensaver`                                               | Add support for XScreenSaver extension                       |       |
> | `xv`                                                         | Add in optional support for the Xvideo extension (an X API for video playback) |       |
> | `xvid`                                                       | Add support for xvid.org's open-source mpeg-4 codec          |       |
> | `zeroconf`                                                   | Support for DNS Service Discovery (DNS-SD)                   |       |
> | `zip`                                                        | Enable support for ZIP archives                              |       |
> | `zlib`                                                       | Add support for zlib (de)compression                         |       |
> |                                                              |                                                              |       |
> | `zstd`                                                       | Enable support for ZSTD compression                          |       |

`zstd``xosd xml`xcomposite``xattr` `x264` `wifi`

`zlib`

`zip``zeroconf`

`xvid`
