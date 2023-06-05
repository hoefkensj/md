-  #### /etc/profile.d/local.sh

```bash
#!/usr/bin/env bash
# ############################################################################
# # PATH: /etc/profile.d						   AUTHOR:Hoefkens.j@gmail.com
# # FILE: local_opt.sh
# ############################################################################
#
# LOCAL Variables : required for loading the LOCAL(this system & system wide) bash (running-)config (rc)
_HOME='/opt/local';_CONFIG='config';_RC="rc"
export LOCAL="${_HOME}"
export LOCAL_CONFIG="${_HOME}/${_CONFIG}"
export LOCAL_CONFIG_RC="${_HOME}/${_CONFIG}/${_RC}"
export USER_CONFIG="${HOME}/.${_CONFIG}}"
export USER_CONFIG="${HOME}/.${_CONFIG}}/${_RC}"
# Check $PATH for /opt/bin , /opt/local/scripts/ and /opt/local/bin, if missing add, and export if needed
[[ ":$PATH:" != *":/opt/bin:"* ]]  && export PATH="/opt/bin:${PATH}"
[[ ":$PATH:" != *":/opt/local/bin:"* ]]  && export PATH="/opt/local/bin:${PATH}"
```

#### 

- #### /etc/portage/make.conf

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

CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"

COMMON_FLAGS="-march=native -O2 -pipe"
# gcc -march=native -E -v - </dev/null 2>&1 | sed  -n 's/.* -v - //p'
#COMMON_FLAGS="${COMMOM_FLAGS} -march=skylake -mmmx -mpopcnt -msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -mavx2 -mno-sse4a -mno-fma4 -mno-xop -mfma -mno-avx512f -mbmi -mbmi2 -maes -mpclmul -mno-avx512vl -mno-avx512bw -mno-avx512dq -mno-avx512cd -mno-avx512er -mno-avx512pf -mno-avx512vbmi -mno-avx512ifma -mno-avx5124vnniw -mno-avx5124fmaps -mno-avx512vpopcntdq -mno-avx512vbmi2 -mno-gfni -mno-vpclmulqdq -mno-avx512vnni -mno-avx512bitalg -mno-avx512bf16 -mno-avx512vp2intersect -mno-3dnow -madx -mabm -mno-cldemote -mclflushopt -mno-clwb -mno-clzero -mcx16 -mno-enqcmd -mf16c -mfsgsbase -mfxsr -mno-hle -msahf -mno-lwp-mlzcnt -mmovbe -mno-movdir64b -mno-movdiri -mno-mwaitx -mno-pconfig -mno-pku -mno-prefetchwt1 -mprfchw -mno-ptwrite -mno-rdpid -mrdrnd -mrdseed -mno-rtm -mno-serialize -msgx -mno-sha -mno-shstk -mno-tbm -mno-tsxldtrk -mno-vaes -mno-waitpkg -mno-wbnoinvd -mxsave -mxsavec -mxsaveopt -mxsaves -mno-amx-tile -mno-amx-int8 -mno-amx-bf16 -mno-uintr -mno-hreset -mno-kl -mno-widekl -mno-avxvnni -mtune=skylake"

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

#MAKEOPTS="-j1"
MAKEOPTS="-j6 -l6"

# -v --verbose      # -b --buildpkg 	# -D --deep 	# -g --getbinpkg        # -k --usepkg           # -u update
# -N --newuse       # -l load-average   # -t --tree 	# -G --getbinpkgonly    # -k --uspkgonly        # -U changed-use
# -o --fetchonly    # -a ask            # -f --fuzzy-search						
# --binpkg-respect-use=[y/n]			# --with-bdeps=y  

# --list-sets		# --alphabetical    # --color=y    # --verbose-conflicts
# --backtrack=COUNT # --emptytree 		# --complete-graph=y 

# --autounmask=y    # --autounmask-write=y  # --autounmask-continue=y  --autounmask-backtrack=y
# --usepkg-exclude 'sys-kernel/gentoo-sources virtual/*'

# EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=9 -b -v -D" --tree, -t--verbose-conflicts

AUTOUNMASK=""
AUTOUNMASK="${AUTOUNMASK} --autounmask=y  --autounmask-continue=y --autounmask-write=y"
AUTOUNMASK="${AUTOUNMASK} --autounmask-unrestricted-atoms=y --autounmask-license=y"
AUTOUNMASK="${AUTOUNMASK} --autounmask-use=y --autounmask-write=y"


EMERGE_DEFAULT_OPTS="-v"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=4 --load-average=4"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --with-bdeps=y "
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} ${AUTOUNMASK}"
#MERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --buildpkg=y"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --color=y --alphabetical"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --usepkg-exclude 'sys-kernel/gentoo-sources virtual/*'"
#EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --binpkg-respect-use=n"


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
BINPKG_FORMAT="gpkg"
BINPKG_COMPRESS="lz4"

#PORTAGE_BINHOST="https://gentoo.osuosl.org/experimental/amd64/binpkg/default/linux/17.1/x86-64/"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} http://packages.gentooexperimental.org/packages/amd64-stable/"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} http://packages.gentooexperimental.org/packages/amd64-stable/"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} https://packages.gentooexperimental.org"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} ftp://packages.gentooexperimental.org"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} ftps//packages.gentooexperimental.org"
#PORTAGE_BINHOST="${PORTAGE_BINHOST} rsync://packages.gentooexperimental.org"

GRUB_PLATFORM="efi-64"
# RUBY_TARGETS="ruby31 ruby30 ruby26 ruby27"
#PYTHON_TARGETS="python3_9 python3_10 python2_7 pip3"
#PYTHON_SINGLE_TARGET="python3_10"
ALSA_CARDS="hda-intel usb-audio emu10k1 emu10k1x emu20k1x emu20k1 intel8x0 intel8x0m bt87x hdsp hdspm ice1712 mixart rme32 rme96 sb16 sbawe sscape usb-usx2y vx222"
VIDEO_CARDS="nvidia d3d12 vmware"
INPUT_DEVICES="evdev libinput"
INPUT_DRIVERS="evdev"

# Turn on logging - see http://gentoo-en.vfose.ru/wiki/Gentoo_maintenance.
PORTAGE_ELOG_CLASSES="info warn error log qa"
# Echo messages after emerge, also save to /var/log/portage/elog
PORTAGE_ELOG_SYSTEM="echo save"

# local overlay
#PORTDIR_OVERLAY="${PORTDIR_OVERLAY} /usr/local/portage"




USE="pipewire iwd jack nvenc nvidia wayland gles2 git plasma opencl tools \
persistenced thunderbolt opengl egl usb wifi python X \
libsamplerate opencv rtaudio 7zip custom-cflags grub network otf \
ttf kde systemd dbus dri nvme uefi semantic-desktop vulkan \
modplug modules lm-sensors hddtemp bluetooth qt5 alsa designer \
multimedia sensors cuda bzip2 aac aalib acpi ao appindicator \
audiofile bash-completion branding cairo cdb cdda cddb cdr cgi \
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
tk truetype udev udisks upnp upnp-av upower v4l vaapi vcd \
videos vim-syntax vnc vorbis wavpack webkit webp wmf wxwidgets \
x265 xattr xcomposite xine xinerama xinetd xml xmp xmpp xosd \
xpm xv xvid zeroconf zip zlib zsh-completion zstd source \
quicktime script openexr echo-cancel extra gstreamer jack-sdk lv2 \
pipewire-alsa sound-server system-service v4l2 zimg \
rubberband pulseaudio libmpv gamepad drm cplugins archive screencast \
gbm mysql rar examples nftables midi numpy"
```





