# Introduction

The install described in this tutorial attempts to follow the 'stock' process from the Gentoo Handbook where possible, but differs in a number of important respects. Specifically:

## Goals (Someday)

* Root FileSystem: F2FS (fast) on a 256gb nvme partion.
* SpaceHoggs in Home on btrfs :sata  drive  -> bindmounted in fstab
* The kernel will be configured to self-boot under UEFI
  * no separate bootloader is needed.
  * we will
* Secure boot can be enabled. 
  * The kernel will be signed with our own, generated key    
* Bootstrap (simulating an old-school stage-1)
  * The Gentoo toolchain 
  * The Core system 
* Validate that all bin executables and libs have been rebuilt from source
* Lastly, detailed (optional) instructions for disabling the Intel Management Engine[2] will be provided (for those with Intel-CPU-based PCs who find this out-of-band coprocessor an unacceptable security risk), as will instructions for fully sandboxing the popular firefox web browser, using firejail

## Root  not Sudo

First lets become ROOT , saving us from having to type sudo , doas or su -c before each command. and avoid messing up by missing one. On most distro's you can just use the `su` command to do so ,` su` or SwitchUser defaults to `su root` when no user is specified. However on some distro's the root account has no password set and is therefore not accessible , these distro's require you to use sudo. There is a quick workaround for those distros. For amost everyone:

```bash
su 
```

for those who cant become root that way:

```bash
sudo su 
```

this will ask for your sudo password and then switch to the root account. why this works is when you run a command with sudo you run this command as the root user. and the way most distro's that use this have it set up is that you need your users password in order to run any command as sudo. running `su` , or actually `su root`  wich translates to switch to ROOT , doesnt prompt for the login password since its the 'root' users that runs it (trough sudo) if that makes sense? its a good idea to set a root password just in case you require another shell to login as and what not so once in the root shell: : 

```bash
passwd root
```

for now i suggest choosing a simple one , you can remove it and revert to the original situation later on . 

then in this root shell lets make things easy for ourselfs: start your favorite terminal emulator from that root shell but with some extra considerations , i use KDE's `konsole` , if you like `Terminology` `gnome-terminal` `xterm` or what not just substitute that in into the following command : 

```bash
nohup konsole &
```

what does this meand / do ?

nohup , starts the process , in a way it ignores hangup signals , a hangup signal is oa send when you exit the shell. when you close the terminal window. you probably have done this a couple times by accident. 

`&` is usually  the symbol to start the process in the background , in this case because its a gui application , the gui  will still just show , but it makes the prompt availeble again in the terminal where you started it . in fact  you can close that shell and the konsole window should remain open.

### Screen ,Tmux

if you are familiar with one of those , pick one, if you arent i will be using Tmux, screen is defenetly installed on your distoro (i hope , if its not , its not that big of a program ~ couple 100kb i think), or install tmux wich is easier to use (imho)

```bash
tmux
```

remember to always run this whenever you open a new tab , you will be greatefull that you did later on.



## Formatting

```bash
mksfs.f2fs -f -l GENTOO -O extra_attr,inode_checksum,sb_checksum,flexible_inline_xattr -w 4096 /dev/disk/by-partlabel/GENTOO
```

## Creating Folders

```bash
mkdir -p /mnt/{gentoo,install}
chmod 777 /mnt/mnt/{gentoo,install}
```

## Mounting

### TempFs (~ramdisk) 

its a good idea to  create a tempfs in the installation folder , alets not clutter the fresh filesystem with files that will be deleted or moved later on , creating a gap at the beginning of the partition.  if you have enough free 'Memory'. we don't need much  for this , ~1GB will be enough , if you dont have 1GB free memory (spare), you can just leave the folder as a folder on the current (old) root drive (given that it has 1GB free space ofc)

```bash
#the new root Volume:
mount -t f2fs -o rw,relatime,lazytime,background_gc=on,discard,no_heap,inline_xattr,inline_data,inline_dentry,flush_merge,extent_cache,mode=adaptive,active_logs=6,alloc_mode=default,checkpoint_merge,fsync_mode=posix,discard_unit=block  /dev/disk/by-label/GENTOO /mnt/gentoo
#the Installation Files 
mount -o size=1G -t tmpfs tmpfs /mnt/Install
```

### Mount-Options  Overview

```ini
relatime,
lazytime,
background_gc=on,
discard,
no_heap,
inline_xattr,
inline_data,
inline_dentry,
flush_merge,
extent_cache,
mode=adaptive,
active_logs=6,
alloc_mode=default,
checkpoint_merge,
fsync_mode=posix,
discard_unit=block
```

```bash

```

## Automate the Stage3 Downloads (tarbal and verificationkeys)

```bash
export MIRROR="http://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/"
export LATEST="latest-stage3-amd64-desktop-systemd-mergedusr.txt"
export STAGE3_URL="${MIRROR}$(curl  --silent $MIRROR$LATEST | tail -n1 |awk '{print $1}')"
```

## Downloading the files

```bash
mkdir -p /mnt/Install/gentoo-stage3
cd $_
wget -c "${STAGE3_URL}"
wget -c "${STAGE3_URL}.CONTENTS.gz"
wget -c "${STAGE3_URL}.DIGESTS"
wget -c "${STAGE3_URL}.asc"
wget -c "${STAGE3_URL}.sha256"
```

### GENTOO Signing keys

```bash
wget -O - https://qa-reports.gentoo.org/output/service-keys.gpg | gpg --import
```

or only the release signing key: (automated)

```bash
gpg --keyserver hkps://keys.gentoo.org --recv-keys D99EAC7379A850BCE47DA5F29E6438C817072058
```

### Verifying the Downloads

```bash
gpg --verify "${LATEST}.asc"
gpg --verify stage3-amd64-*.tar.xz.DIGESTS.asc
awk '/SHA512 HASH/{getline;print}' stage3-amd64-*.tar.xz.DIGESTS.asc | sha512sum --check 
```

## Unpack the verified stage 3 archive

```bash
tar xpvJf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner --directory /mnt/gentoo
# x:extract, p:preserve permissions, J:xz-compression f:file

```

### Some Extra Folders

```BASH
cd /mnt/gentoo
mkdir ./{Volumes,}
mkdir -p ./etc/portage/package.{accept_keywords,license,mask,unmask,use,env}
mkdir -p ./opt/{bin,scripts,local}
mkdir -p .opt/local/{bin,scripts,config}
mkdir -p .opt/local/config/rc/bash
chown -R root:100 ./{opt,Volumes}
chmod -R 775 ./{opt,Volumes}
```

## Extra Scripts

##### supperadduser (Slackware)

```bash
mkdir -p /mnt/Install/scripts/superadduser
curl https://gitweb.gentoo.org/repo/gentoo.git/plain/app-admin/superadduser/files/1.15/superadduser -o  $_/superadduser.sh 
```

##### sourcedir

```bash
mkdir -p /mnt/Install/scripts/sourcedir
curl https://raw.githubusercontent.com/hoefkensj/SourceDir/main/sourcedir-latest.sh -o ./sourcedir.sh
cp -v /mnt/Install/scripts/sourcedir/sourcedir.sh /etc/profile.d/sourcedir.sh
```

#### /opt/local/config/rc/bash/000_bashrc.conf

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
COMMON_FLAGS="${COMMOM_FLAGS} -march=skylake -mmmx -mpopcnt -msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mavx -mavx2 -mno-sse4a -mno-fma4 -mno-xop -mfma -mno-avx512f -mbmi -mbmi2 -maes -mpclmul -mno-avx512vl -mno-avx512bw -mno-avx512dq -mno-avx512cd -mno-avx512er -mno-avx512pf -mno-avx512vbmi -mno-avx512ifma -mno-avx5124vnniw -mno-avx5124fmaps -mno-avx512vpopcntdq -mno-avx512vbmi2 -mno-gfni -mno-vpclmulqdq -mno-avx512vnni -mno-avx512bitalg -mno-avx512bf16 -mno-avx512vp2intersect -mno-3dnow -madx -mabm -mno-cldemote -mclflushopt -mno-clwb -mno-clzero -mcx16 -mno-enqcmd -mf16c -mfsgsbase -mfxsr -mno-hle -msahf -mno-lwp -mlzcnt -mmovbe -mno-movdir64b -mno-movdiri -mno-mwaitx -mno-pconfig -mno-pku -mno-prefetchwt1 -mprfchw -mno-ptwrite -mno-rdpid -mrdrnd -mrdseed -mno-rtm -mno-serialize -msgx -mno-sha -mno-shstk -mno-tbm -mno-tsxldtrk -mno-vaes -mno-waitpkg -mno-wbnoinvd -mxsave -mxsavec -mxsaveopt -mxsaves -mno-amx-tile -mno-amx-int8 -mno-amx-bf16 -mno-uintr -mno-hreset -mno-kl -mno-widekl -mno-avxvnni --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=8192 -mtune=skylake"
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

# Turn on logging - see http://gentoo-en.vfose.ru/wiki/Gentoo_maintenance.
#PORTAGE_ELOG_CLASSES="info warn error log qa"
# Echo messages after emerge, also save to /var/log/portage/elog
#PORTAGE_ELOG_SYSTEM="echo save"

USE="gles2 opencl tools \
persistenced \
libsamplerate opencv custom-cflags grub network  \
dri semantic-desktop \
modplug modules \
multimedia  aac aalib acpi ao appindicator \
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
 sound-server system-service v4l2 zimg \
rubberband pulseaudio libmpv gamepad drm cplugins archive screencast \
gbm mysql  examples nftables "
```

```bash
#Codecs:
a52,aac,aalib,audiofile,cdb,nvenc,libsamplerate,otf,ttf
#Hardware
acpi,ao,bluetooth,cdr,pipewire,jack,nvidia,thunderbolt,usb,jack,rtaudio,systemd,dbus,nvme,uefi,lm-sensors,hddtemp,alsa,sensors,midi,pipewire-alsa
#Filesystem
afs
#Network
apache2,atm,cddb,curl,iwd,wifi,network
#Gui
appindicator,cairo,colord,wayland,plasma,opengl,X,kde,vulkan,qt5
#Development
python,designer,cuda
#tools
bash-completion,crypt,git
# Archiving
7zip,bzip2,rar
```

## Configuring /etc/portage/make.conf

Our first Portage configuration task is to ensure that the download / unpack / prepare / configure / compile / install / merge cycle (aka  'emerging') - which you'll see rather a lot of when running Gentoo - is  as efficient as possible. That primarily means taking advantage of whatever *parallelism* your system can offer.

 **Important**
Remember that we have not yet performed a **chroot**. As such, our vestigial system is still mounted at /mnt/gentoo. Therefore, our new system configuration files are at /mnt/gentoo/etc/portage, not /etc/portage, and so on. Confusingly, since the minimal install system is *also* a Gentoo system, there actually **is** a /etc/portage directory, but the files in there are *not* the ones you need to edit. Make sure you don't get mixed up! In what follows, if you are instructed to *edit* a file, its full path (including mountpoint prefix) will always be given, to avoid any ambiguity.

There are two main dimensions to this - the maximum number of  concurrent Portage jobs that will be run at any one time, and the  maximum number of parallel threads executed by the **make** process invoked by each ebuild itself. 

As has been recommended, we'll set our number of concurrent jobs  and parallel make threads to attempt, to be equal to the number of CPUs  on the system, plus one.[[7\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files#cite_note-7) We'll also prevent new jobs or compilations starting when the system load average hits or exceeds the number of CPUs.

The two variables we'll need to set here are EMERGE_DEFAULT_OPTS (for Portage job control) and [MAKEOPTS](https://wiki.gentoo.org/wiki/MAKEOPTS) (to pass options on to **make**). These are often defined in the make.conf file, but we want to allow the values to be set programmatically. Since Portage doesn't support fancy [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) features like command substitution,[[8\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files#cite_note-8) we'll set and export these variables in root's .bashrc instead (these will then override any conflicting values in the make.conf or profile, as explained [earlier](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files#variable_check_order)).

 **Note**
Generally speaking, **emerge** is launched as the root user (superuser) in Gentoo. **emerge** usually drops its privilege level to run as the "portage" user when compiling.

Start up your favourite editor: in this tutorial we'll be assuming **nano**:

```shell
livecd ~ #``nano -w /mnt/gentoo/root/.bashrc 
```

 **Note**
The **-w** option tells the nano editor *not* to auto-wrap long lines (auto-wrapping can really mess up config files!).

FILE **`/mnt/gentoo/root/.bashrc`****Setting up MAKEOPTS and EMERGE_DEFAULT_OPTS**

```bash
export NUMCPUS=$(nproc)
export NUMCPUSPLUSONE=$(( NUMCPUS + 1 ))
export MAKEOPTS="-j${NUMCPUSPLUSONE} -l${NUMCPUS}"
export EMERGE_DEFAULT_OPTS="--jobs=${NUMCPUSPLUSONE} --load-average=${NUMCPUS}"
```

Save and exit the **nano** editor.

 **Note**
Should you experience problems with parallel **make**, and wish to fall back to a more conservative setting, you can do so globally by setting `MAKEOPTS="-j1"` in the above.

Next, we need to make sure that the .bashrc file is picked up by root's login shell, so copy across the default .bash_profile:

```bash
livecd ~ #``cp -v /mnt/gentoo/etc/skel/.bash_profile /mnt/gentoo/root/ 
```

Next, on to the make.conf configuration file itself. The stage 3 tarball we extracted already  contains a skeleton configuration. We'll open this file with **nano** (feel free to substitute your favourite alternative editor), delete the existing lines (in **nano**, Ctrlk can be used to quickly cut the current line), and enter our alternative configuration instead (see [after](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files#make_conf_summary) for a line-by-line explanation). Issue:

```bash
livecd ~ #``nano -w /mnt/gentoo/etc/portage/make.conf 
```

Edit the file so it reads:

FILE **`/mnt/gentoo/etc/portage/make.conf`****Setting up essential Portage variables**

```bash
# Build setup as of <add current date>

# C, C++ and FORTRAN options for GCC.
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# Note: MAKEOPTS and EMERGE_DEFAULT_OPTS are set in .bashrc

# The following licence is required, in addition to @FREE, for GNOME.
ACCEPT_LICENSE="CC-Sampling-Plus-1.0"

# WARNING: Changing your CHOST is not something that should be done lightly.
# Please consult http://www.gentoo.org/doc/en/change-chost.xml before changing.
CHOST="x86_64-pc-linux-gnu"

# Use the 'stable' branch - 'testing' no longer required for Gnome 3.
# NB, amd64 is correct for both Intel and AMD 64-bit CPUs
ACCEPT_KEYWORDS="amd64"

# Additional USE flags supplementary to those specified by the current profile.
USE=""
CPU_FLAGS_X86="mmx mmxext sse sse2"

# Important Portage directories.
PORTDIR="/var/db/repos/gentoo"
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C

# Turn on logging - see http://gentoo-en.vfose.ru/wiki/Gentoo_maintenance.
PORTAGE_ELOG_CLASSES="info warn error log qa"
# Echo messages after emerge, also save to /var/log/portage/elog
PORTAGE_ELOG_SYSTEM="echo save"

# Ensure elogs saved in category subdirectories.
# Build binary packages as a byproduct of each emerge, a useful backup.
FEATURES="split-elog buildpkg"

# Settings for X11
VIDEO_CARDS="intel i965"
INPUT_DEVICES="libinput"
```

>  **Note**
> Set VIDEO_CARDS and INPUT_DEVICES to appropriate values for your particular system in /etc/portage/make.conf. See table [below](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files#video_cards_variable) for discussion.

 **Important**
As [discussed below](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files#set_cpu_flags_x86), ensure that you only specify CPU_FLAGS_X86 flags that your CPU supports, otherwise compiled software may crash.

Save the file and exit **nano**.

Here is a brief summary of the shipped ('stage 3') values are, and what our version achieves:

 **Note**
As of 2019, the stage 3's shipped make.conf is rather minimal, since the majority of the important values are instead set by the active [profile's](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files#about_make_conf) **make.defaults** files (including the CHOST). The main instances of these may be viewed — *once* we have installed the Gentoo ebuild repository, in the [next chapter](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Building_the_Gentoo_Base_System_Minus_Kernel#update_portage_tree) — at (/mnt/gentoo)/var/db/repos/gentoo/profiles/default/linux/make.defaults and (/mnt/gentoo)/var/db/repos/gentoo/profiles/arch/amd64/make.defaults. (Gentoo's profile system allows multiple such make.defaults files to be sourced, to allow profiles to be constructed hierarchically.)
For simplicity, the effective value has been shown in the table below.

## Gentoo, Portage, Ebuilds and emerge (Background Reading)

Gentoo is a source-based distribution, the heart of which is a powerful package manager called Portage. Portage itself has two main components:

    the ebuild system, which performs the actual work of fetching, configuring, building and installing packages, and
    the emerge tool, which provides a command line interface to invoke ebuilds, and also allows you to update the Portage tree (discussed below), resolve package dependencies, and other related tasks.

|        |                                                                                                                                                                                                                                                                                                                                                                                                       |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `NOTE` | If you're new to all of this, a useful introduction to Portage may be found in Chapter 1 of Part 2 of the Gentoo Handbook, and in this Wikipedia article. However, don't worry - you don't need to be an adept programmer to use Gentoo on a day-to-day basis! (In fact, if you'd like to skip over this background material now and continue with the next section of the install, just click here). |
| 55     |                                                                                                                                                                                                                                                                                                                                                                                                       |

|        |                                                                                                                                                                                                                                                                                                                                                                                                       |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `NOTE` | If you're new to all of this, a useful introduction to Portage may be found in Chapter 1 of Part 2 of the Gentoo Handbook, and in this Wikipedia article. However, don't worry - you don't need to be an adept programmer to use Gentoo on a day-to-day basis! (In fact, if you'd like to skip over this background material now and continue with the next section of the install, just click here). |

Package ebuilds are Bash shell scripts, or more accurately shell script fragments, that are sourced into a larger build system 'host' script. This host script provides a package management control flow that invokes a set of default 'hook' functions, which a particular package's ebuild may override if it needs to (these are covered in detail in the Gentoo Development Guide). The ebuild also must define a minimum set of variables to allow the whole process to operate successfully (for example, the URI from where a package's source tarball may be downloaded must be assigned to the SRC_URI variable).

Now, when you invoke an ebuild to install a particular (as yet uninstalled) package on your system (via emerge, for example, as described below), it will typically carry out the following tasks (inter alia):

    check that the specified package can be installed (that is, that it isn't masked, or has an incompatible license requirement);
    download the package's tarball (or other format source archive) from an upstream repository (or Gentoo mirror);
    unpack the tarball in a temporary working area;
    patch (and otherwise modify) the unpacked source if need be;
    configure the source to prepare it for compilation on your machine;
    compile / build the source, as a non-privileged user in the temporary work area;
    run tests (if provided and required);
    install the built package to a dummy filesystem root; and
    copy ('merge') the package installation files from the dummy filesystem root to the real filesystem root (keeping a record of what gets done).

Up until the final file copy-over step (the 'merge' in emerge), all operations (even where the package's make install is invoked, for example) take place in a temporary staging area. This enables Portage to keep track of all the files installed by a particular package, limit the damage caused by failed compiles or installs, and facilitate simple removal of installed packages. Furthermore, for most of these tasks, Portage operates in a 'sandbox' mode, where attempts to write directly to the real root filesystem (rather than the temporary work area) are detected, and cause an error to be thrown (NB this is not intended as a security system per se, but it does help prevent accidental filesystem corruption).
Note
Portage will attempt to deal with build and runtime dependencies when emerging packages, and will automatically install such dependencies for you, by invoking their ebuilds.
Note
At this stage in the install, you won't be able to see the files referred to in the text below on your target PC, since the minimal install image has an empty /var/db/repos/gentoo directory, and the system we in the process of creating from the stage 3 tarball (whose root is currently at /mnt/gentoo) has no /var/db/repos/gentoo directory yet. This will be rectified in the next chapter.

Portage stores ebuilds in a hierarchical folder structure - the Portage tree (or repository), which by default is located under /var/db/repos/gentoo. The first tree level is the package category, which is used to organize packages into groups which have broadly similar functionality. So, for example, non-core development utilities are typically placed in the dev-util category (in folder/var/db/repos/gentoo/dev-util). The next tree level is the package name itself. To take a concrete example, the small utility diffstat (which, as its name suggests, displays a histogram of changes implied by a patch file, or other diff output), is located in the folder /var/db/repos/gentoo/dev-util/diffstat. Within that subdirectory we have the actual per-package content, specifically:

    The ebuild files. Each supported version has a file of format <name>-<version>.ebuild. At the time of writing, there are two supported versions (1.60 and 1.61) of diffstat in the Portage tree, so the ebuilds are located at /var/db/repos/gentoo/dev-util/diffstat/diffstat-1.60.ebuild and /var/db/repos/gentoo/dev-util/diffstat/diffstat-1.61.ebuild. Portage supports a complex version numbering taxonomy which, for the most part, reflects upstream versioning (discussed further below), and most packages, like diffstat, will have multiple ebuild versions available at any given time.
    Package metadata. This is stored in an xml-format text file (one per package), named metadata.xml. Its contents are described here, and can contain detailed package descriptions, email addresses for upstream maintainers, documentation about USE flags etc. diffstat's metadata file is at /var/db/repos/gentoo/dev-util/diffstat/metadata.xml.
    A manifest file, which contains digests (BLAKE2B and SHA512) and file sizes for the contents of the package directory and any referenced tarballs (and patches, if present). It is used to detect corruption and possible tampering during package download / installation. This manifest, which may optionally be digitally signed, is stored in the Manifest file; diffstat's therefore resides at /var/db/repos/gentoo/dev-util/diffstat/Manifest.
    An optional files directory. This is used to hold patches and other small files that are supplementary to the main source tarball but referenced by one or more of the package's ebuilds. The directory may be absent if unused. As (at the time of writing) diffstat does not require patches, it has no files subdirectory either.

Note
Since the Portage tree, or repository, is nothing other than a set of files, it can easily be kept up to date with Gentoo's mirrored 'master copy' (and indeed by default this is done using rsync, whenever you issue an emerge --sync, for example).
A Simple ebuild (diffstat)

So what does an ebuild file actually look like, then? diffstat happens to be a good minimal example; here (at the time of writing) is what /var/db/repos/gentoo/dev-util/diffstat/diffstat-1.61.ebuild contains:
FILE /var/db/repos/gentoo/dev-util/diffstat/diffstat-1.61.ebuildA fairly minimal ebuild, relying on the default 'hook' functions and control flow

```bash
# Copyright 1999-2016 Gentoo Foundation

# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Display a histogram of diff changes"
HOMEPAGE="http://invisible-island.net/diffstat/"
SRC_URI="ftp://invisible-island.net/diffstat/${P}.tgz"

LICENSE="HPND"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""
```

Not a lot to see, is there? That's because diffstat uses a standard 'Autotools'-style build, without patches, so the default ebuild control flow (and invoked 'hook' functions) can do almost everything for us. Therefore, all that has to be done is:

    to specify (via the EAPI variable) that the ebuild makes use of the most modern package manager functionality, including built-in default behaviours (version 6, at the time of writing).
    to specify a brief DESCRIPTION, HOMEPAGE (both self-explanatory) and most importantly, SRC_URI; this last variable tells Portage the location from whence to download the package tarball, if it cannot find it in the Portage mirrors (the ${P} expands out to be the package name and version; a handy list of these special variables may be found here);
    to specify the LICENSE (the relevant text may be found at /usr/src/portage/licenses/${LICENSE});
    to specify that SLOTTING is not used by this ebuild (this is an advanced feature; see below for a brief overview); and
    finally to list the architectures (KEYWORDS) for which this ebuild applies. Here, we can see that (at the time of writing) it is in testing (has a tilde) for all the architectures listed (alpha, amd64 etc.).

Note
At the time of writing, diffstat had no USE flags, hence IUSE="".

That's all that is needed in this case, because the default ebuild functions will automatically pull down the tarball, unpack it, issue a ./configure, issue a make, followed by a make install (to a dummy root), after which, the program file (plus manpage etc.) will be copied over ('merged') to the real filesystem (and any prior version's files safely unmerged immediately thereafter).
Note
In fact, the default ebuild flow will handle not just 'Autotools' packages, but also any package provided with a Makefile that can accept make and make install invocations, and respects the DESTDIR variable. By default, the ./configure step will be omitted if no configure file is found in the top-level source directory of the tarball after unpacking.

There are then two main ways to invoke the diffstat ebuild. The first (and more common way) is via emerge: typically, you would issue:
root #emerge --ask --verbose dev-util/diffstat
Note
This is just an example, this command is not part of the installation tutorial and you should not actually issue it at this point.
Note
It is also possible to tell emerge which specific version you want, for example, you could issue instead:
root #emerge --ask --verbose =dev-util/diffstat-1.60

This is an example of a qualified version atom, discussed below.

On the other side of the coin, it is possible to leave off the category qualifier when using emerge, but that's not recommended due to occasional ambiguities, where the same name occurs in multiple categories.

The second (lower level) way is invoke the ebuild directly; for example, you could issue:
root #cd /var/db/repos/gentoo/dev-util/diffstat/
root #ebuild diffstat-1.60.ebuild clean merge
Note
This is also just an example, these commands are not part of the installation tutorial and you should not actually issue them at this point.

which will clean Portage's temporary build directories, and then perform all the steps of the ebuild workflow, providing detailed output as it does so (you can also use the ebuild command to perform only certain steps, if you wish, and it can also create Manifest files; see the ebuild manpage for details).
Note
Unlike the emerge invocation, this will not add dev-util/diffstat to the @world set (see below for an explanation of what this means).
A More Complex ebuild (sign)

The diffstat example above is about as simple as a real-world ebuild gets!

However, one common additional requirement is the need to apply patches. To do this, an ebuild will typically override the default src_prepare ebuild 'hook' function (invoked by the standard ebuild flow after the source tarball has been successfully unpacked), and in the overridden version use the epatch utility function to apply patches held in the files directory.
Note
However, from EAPI 6 the default src_prepare function is no-longer a no-op, it will automatically apply any patches listed in the PATCHES array variable (and call eapply_user, to apply user patches)[2]. The ebuild we're about to look at however uses EAPI 5, so has to apply its required patches using epatch directly.

For example, consider the sign package, which provides a file signing and signature verification utility. It lives in the app-crypt category. Looking in its corresponding directory (/var/db/repos/gentoo/app-crypt/sign) we notice immediately that unlike diffstat, there is a files subdirectory, containing two patches (1.0.7-as-needed.patch and 1.0.7-openssl-0.9.8.patch).

Let's examine version 1.0.7 of the ebuild:
FILE /var/db/repos/gentoo/app-crypt/sign/sign-1.0.7.ebuildA slightly more complex ebuild, illustrating patching and conditional dependencies

```bash
# Copyright 1999-2017 Gentoo Foundation

# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit toolchain-funcs eutils

DESCRIPTION="File signing and signature verification utility"
HOMEPAGE="http://swapped.cc/sign/"
SRC_URI="http://swapped.cc/${PN}/files/${P}.tar.gz"

LICENSE="BZIP2"
SLOT="0"
KEYWORDS="amd64 ppc x86 ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="libressl"

RDEPEND="
    !libressl? ( dev-libs/openssl:0= )
    libressl? ( dev-libs/libressl:0= )"
DEPEND="${RDEPEND}"

src_prepare() {
    epatch "${FILESDIR}"/${PV}-openssl-0.9.8.patch
    epatch "${FILESDIR}"/${PV}-as-needed.patch
    # remove -g from CFLAGS, it happens to break the build on ppc-macos
    sed -i -e 's/-g//' src/Makefile || die
}

src_compile() {
    emake CC="$(tc-getCC)"
}

src_install() {
    dobin ${PN}
    doman man/${PN}.1
    dodoc README
    dosym ${PN} /usr/bin/un${PN}
}
```

Most of this should be familiar enough from the diffstat example, but there are some new elements too. Specifically:

    the inherit command is used to pull in two useful 'eclasses': eutils (which supplies the epatch function discussed shortly) and toolchain-funcs (which supplies tc-getCC, a function to return the name of the toolchain C compiler);
    the SRC_URI makes use of the ${PN} variable, which expands out to the package name, without version (a full list of these convenience variables may be found here);
    the IUSE definition is not blank: there is one optional USE flag here, libressl (which switches to that SSL library, as we shall discuss next; see below for a brief introduction to USE flags);
    the RDEPEND variable specifies a set of runtime dependencies, and the DEPEND a set of build/install time dependencies, for the package. This is used by Portage to ensure that all prerequisites are also installed, when you ask to emerge app-crypt/sign. Notice that this build pulls in dev-libs/openssl by default, unless the libressl USE flag is specified, in which case dev-libs/libressl is pulled in instead;
    the src_prepare 'hook' function (which by default is a no-op at EAPI 5) is overridden to perform two custom tasks:
        to patch the source using the epatch utility, using patch files /var/db/repos/gentoo/app-crypt/sign/files/1.0.7-openssl-0.9.8.patch and /var/db/repos/gentoo/app-crypt/sign/files/1.0.7-as-needed.patch (${PV} expands to the package version, without name or revision tags). As described here, epatch intelligently attempts to apply patches using different -p levels etc.
        to invoke a small sed script to modify the Makefile slightly.
    the src_compile 'hook' function (which by default will simply invoke emake after some pre-preprocessing) is overridden to ensure that the C compiler is set correctly (the upstream Makefile not supporting environment-set CC values in this case);
    the src_install 'hook' function (which by default will invoke emake DESTDIR="${D}" install and then further install any documentation specified via the DOCS array variable) is overridden to perform a manual install using some helper install functions; this is sometimes necessary if the upstream Makefile does not support the use of DESTDIR, or does not support the install target.

Note
Of course, ebuilds can be much more complex than either of the above two examples, but they should give you a basic idea of how the system works. For more details, I'd refer you to the Gentoo Development Guide "Ebuild Writing" section.
Ebuild Repositories (aka Overlays)

What if you want to modify an ebuild yourself, or add a new one? You could of course submit the ebuild to Gentoo using Bugzilla, but that only really applies to completed work you want to share. For work in progress, or private ebuilds, a different approach is required. You can't simply insert new entries into the /var/db/repos/gentoo tree, as they'll get overwritten next time you synchronize the Gentoo repository.

Instead, Portage supports the concept of ebuild repositories (historically known as "overlays") to address just this issue. These are simply additional collections of ebuilds and associated metadata, laid out in a similar filestructure to the main Portage tree, which Portage (by default, and as the historical name suggests) 'overlays' on the /var/db/repos/gentoo file structure. To illustrate, suppose you created a directory at, say, /tmp/myrepo, created the subfolders /tmp/myrepo/dev-util and /tmp/myrepo/dev-util/diffstat, then created an ebuild /tmp/myrepo/dev-util/diffstat/diffstat-1.60.ebuild (and manifest, /tmp/myrepo/dev-util/diffstat/Manifest), and then created the following (in /etc/portage/repos.conf/myrepo.conf, to inform Portage's plug-in sync system of its presence):
FILE /etc/portage/repos.conf/myrepo.confExample ebuild repository configuration file

```bash

```

[myrepo]

# Simple example 'overlaid' ebuild repository

location = /tmp/myrepo
priority = 100
auto-sync = no

Then, when referring to (or installing) diffstat, Portage would use your version, rather than the 'official' ebuild (however, if you had created an ebuild with a lower version number, say 1.57, then by default Portage would still use the higher numbered version, from the official /var/db/repos/gentoo 'underlay').
Note
There are actually a few more files you'd need to create in your overlay to make it functional (and you probably want to place it under source control, and not host the local copy under /tmp in any event!). See these instructions for further details.

We'll exploit this ability shortly, when we add the sakaki-tools ebuild repository (which will contain a number of useful tools used in this installation walk-through).
Portage's Configuration Files

Portage provides you, the user, with a great deal of flexibility. As such, it has many configuration options, specified via a set of files held in the /etc/portage directory (and subdirectories thereof). As our installation process is going to involve using Portage (via the command-line tool emerge) to download, then build and install up-to-date versions of all core system software, we first need to set up these configuration files appropriately.

The most important Portage configuration files you'll need to know about now are as follows (this is not complete - see this list for more information, and also the Portage manpage[3]):
Important
It is possible to have any of the below as subdirectories, rather than files, in which case the contents of the subdirectory will be parsed in alphabetical order.[4] Indeed, the subdirectory-based approach has now become the default on the Gentoo installation media (with the exception of /etc/portage/make.conf), so please bear that in mind when reading the table.
File in /etc/portage/     File Description
repos.conf     Specifies site-specific repository configuration, including the mechanism and URI via which repositories should be synchronized.
make.conf     Contains definitions of various important variables used by Portage. These variables tell the system, amongst other things:

    the default licensing to accept (for example, accept only free software),
    the system architecture to target (for example, the 'amd64' architecture - actually a generic reference to 64-bit processors, whether from AMD or Intel - used here),
    some information about the system video card and input devices
    whether to build the 'stable' versions of packages, or the latest, 'testing' version (happily, Gnome3 is present in the 'stable' branch of Gentoo, so we can use this);
    the default system-wide USE flags (USE flags are Portage 'meta-instructions' to control the build process for packages; they are a core Portage concept and introduced in Chapter 2 of Part 2 of the Gentoo Handbook);
    what URLs to use when syncing the Portage tree (and many source tarballs) (we'll want to point to local mirrors, to keep things fast),
    what logging to perform during builds (we'll switch this on, since its very useful when things go wrong)
    and many others.

To ease the problem of setting things up correctly for your particular use case (e.g., a headless server, or, as in our case, a GNOME desktop with systemd or OpenRC), Portage makes use of profiles. A profile specifies (inter alia) a set of default values for most of the variables in /etc/portage/make.conf, which will be used if the appropriate variable is not defined in the user's environment (checked first) or in the /etc/portage/make.conf file. (NB - so-called incremental variables, such as the one which holds the list of USE flags, are an exception to this masking approach, as they 'cascade' additively, from profile, through /etc/portage/make.conf, to the user's environment.)

It is also possible to specify overrides for certain elements of Portage's operation on a per-package basis, through the use of the following configuration files:
package.mask     Versions of packages specified in package.mask are 'masked' - that is, blocked from installation (think of it as an installation blacklist). This is most commonly used to prevent Portage updating a package when there is some bug or incompatibility with the new release. It is also sometimes used to mask out everything in a large third-party ebuild repository, for security (with only the specific packages that are wanted then being allowed, by explicit citation in the package.unmask file (discussed next).
package.unmask     This file overrides package.mask (think of it as an installation whitelist). It is sometimes used to allow 'activate' specific packages only from a large ebuild repository (which has been otherwise totally masked via package.mask, above).
package.use     package.use contains a list of USE flags for individual packages. It comes in handy when specifying flags that have only localized meaning (e.g., suppressing the installation of Guest Additions in VirtualBox), or which you only want to turn on in very selective situations (such as the test flag, for example). You can also turn off USE flags for particular packages, by prefixing them with a minus sign ('-').
package.license     The package.license file allows you to specify allowed licenses on a per-package basis. It's generally used where you have a restrictive licensing default (such as 'free software only', as we are going to set), but need to add some exceptions for a few cases.
package.accept_keywords     The package.accept_keywords file primarily allows you to specify packages which should use the testing, rather than stable, software branch. It is best to keep the use of this to a minimum, to avoid dependency pollution, but it is sometimes necessary (for example, when using software for which no stabilized version yet exists in the tree).
Note
There are other things you can do with package.accept_keywords too, such as activating so-called 'live' (aka '9999') ebuilds, which track the tip of a branch in a version control system directly, but we will not utilise this in our tutorial.
env     The env directory contains custom environment files that can be used to override default emerge behaviour, when cited for a given package in package.use (see below). For example, you could create a file called /etc/portage/env/no_build_parallelism.conf, and put in it MAKEOPTS="-j1". Then, you could apply this custom environment setting to any package that had a problem with this issue, as described next.
package.env     The package.env file allows you to apply custom environment settings (as defined in /etc/portage/env/..., see above) to particular packages. For example, you could turn off build parallelism for a package by citing no_build_parallelism.conf against it, here.
Atoms, Packages, Categories, Versions, Sets and SLOTs

Finally for this background overview, there are a few Portage package management terms that are worth a brief recap:

    As mentioned, a package refers to a homogeneous block of software which has a single provided ebuild per installable version, whether third-party (e.g., openvpn) or internal to Gentoo itself (e.g., gentoolkit).
    Packages are grouped (as leaves of a tree) into categories, which describe broad classes of functionality. For example, openvpn is in the net-vpn category (along with other similar tools like tor and strongswan); gentoolkit is in the app-portage category (along with other Portage applications, like mirrorselect and elogviewer).
    A package base atom simply refers to the name made up of the full category, followed by the package, without version information or other qualifiers. So for example net-misc/openvpn, app-portage/gentoolkit etc. You can find all the ebuilds in the currently sync'd tree for a given <category>/<packagename> base atom in the directory /var/db/repos/gentoo/<category>/<packagename> (so, for example, /var/db/repos/gentoo/dev-util/diffstat/), and find more information about that base atom online at https://packages.gentoo.org/package/<category>/<packagename> (so, for example, https://packages.gentoo.org/package/app-portage/gentoolkit). While it is often possible to drop the category name and simply use the package itself, it's generally safer to use the base atom, since two different packages of the same name may exist in different categories (e.g. axiom could refer to either dev-python/axiom, an object database over SQLite, or sci-mathematics/axiom, a computer algebra system).
    It is generally possible to specify that a specific repository should be used to supply a package, by appending ::<reponame> to its atom. For example, emerge --ask --verbose dev-util/diffstat::myrepo would force Portage to install the diffstat package from the myrepo repository (and would fail if either that overlay was unknown, or if the dev-util/diffstat package was not present in it).
    Any given package will normally be supported at multiple versions within Portage (one ebuild per version). Not all versions from the upstream tree may be present as ebuilds, only certain selected versions. The online package data referred to above will show what versions are available, on which architectures, and which are marked as 'stable', which are 'testing' (shown with a tilde ('~')), and which are masked (will not be installed by Portage, generally due to known problems or with the ebuild, or incompatibilities with other packages). You can fully qualify an atom by specifying its version as a suffix - generally, you take the base atom, then add a hyphen ('-'), then add a period-separated list of numbers (possibly finishing with a letter, and/or a revision suffix). So, for example, version 2.4.3 of openvpn would be written as net-vpn/openvpn-2.4.3; version 1.19.1 (r1) of wget as net-misc/wget-1.19.1-r1. Revisions are Gentoo ebuild specific, they do not relate to upstream versioning (one implication of which being, that different revisions of a particular version of a package will generally use the same upstream source tarball (although they may of course apply different patch sets etc.)).
    When specifying atoms to Portage in certain places (such as configuration files, like /etc/portage/package.use), you can either specify base atoms (meaning apply the action to all ebuild versions), or a qualified version atom. You can qualify a versioned atom with:
        A prefix ('>', '>=', '=', '<=', '<'], to restrict the action to particular versions relative to the stated variant (for example, if you appended ">=net-vpn/openvpn-2.4.3 inotify" to /etc/portage/package.use, you'd be telling Portage to apply the inotify use flag to any version of openvpn at or above 2.4.3.
        A extended prefix: there are a number of these but the most important is '~', which is used to specify any revision of the base version specified. So, for example, ~app-portage/gentoolkit-0.3.3 would refer to app-portage/gentoolkit-0.3.3, app-portage/gentoolkit-0.3.3-r1, app-portage/gentoolkit-0.3.3-r2 etc. (where they exist, of course!)
        A wildcard suffix ('*'). This can be used to match any version with the same string prefix. So for example, net-vpn/openvpn-2.4* would match (at the time of writing) net-vpn/openvpn-2.4.2-r1, net-vpn/openvpn-2.4.3, net-misc/openvpn-2.4.3-r1 etc.

For more information on atom naming, see the ebuild (5) manpage.[5]

    A number of atoms may be grouped together into a set, so that operations (e.g. reinstallation) can be easily targeted at the whole group. Sets are special names and are prefixed by '@': some of these are pre-defined in Portage (for example, the @system set (containing vital system software packages, the contents of the stage 3 tarball plus other component dictated by your profile), or the dynamically populated @preserved-rebuild set (which holds a list of packages using libraries whose sonames have changed (during an upgrade or downgrade) but whose rebuild has not been triggered automatically). The @world set refers to all packages you explicitly requested be installed, and is contained in a file /var/lib/portage/world (note however that operations on the @world set will include the @system set, by default, not just what is in the /var/lib/portage/world file). You can even define your own sets if you like.
    Portage also allows (subject to certain limitations) different versions of the same package to exist on a machine at the same time: we speak of them being installed in different SLOTs. We won't need to refer to the SLOT technology explicitly in this tutorial, but should you see a versioned atom with a colon ':' followed by some numbers and possibly other characters at the end, that's a SLOT reference. For example, with the x11-libs/gtk+ library, it is possible (at the time of writing) to have version 2.24.31-r1 and 3.22.15 installed in parallel, should you desire it (in SLOTs 2 and 3).[6] You might then see a reference to x11-libs/gtk+:3, which would refer to any version of gtk+ in SLOT 3 (which would, for example, cover version 3.22.16 as well).

That's about it for this sidebar on atoms and versioning, apart from one last point: unlike other Linux distributions, you'll see no reference to 'releases' of Gentoo itself - there's nothing similar to Ubuntu's "Xenial Xerus" or "Artful Aardvark", Debian's "Stretch" or "Buster", Fedora's "Heisenbug" or "v26" etc. That's because, once installed, Gentoo itself is essentially versionless - when you update your system (more on which later), all installed software updates to the latest supported versions (subject to restrictions imposed by the Gentoo developers and you yourself, through settings in /etc/portage/make.conf, /etc/portage/package.mask etc.).

The upside of this is that you can get access to the latest and (often) greatest versions of software as soon as new ebuilds get released into the tree. The downside is that (particularly on the 'testing' (rather than the 'stable') branch), sometimes updates fail to complete successfully, an occurrence that is very rare indeed when using binary distributed, release-based distributions such as Ubuntu.

Time to get back to the install!
Configuring /etc/portage/make.conf

Our first Portage configuration task is to ensure that the download / unpack / prepare / configure / compile / install / merge cycle (aka 'emerging') - which you'll see rather a lot of when running Gentoo - is as efficient as possible. That primarily means taking advantage of whatever parallelism your system can offer.
Important
Remember that we have not yet performed a chroot. As such, our vestigial system is still mounted at /mnt/gentoo. Therefore, our new system configuration files are at /mnt/gentoo/etc/portage, not /etc/portage, and so on. Confusingly, since the minimal install system is also a Gentoo system, there actually is a /etc/portage directory, but the files in there are not the ones you need to edit. Make sure you don't get mixed up! In what follows, if you are instructed to edit a file, its full path (including mountpoint prefix) will always be given, to avoid any ambiguity.

There are two main dimensions to this - the maximum number of concurrent Portage jobs that will be run at any one time, and the maximum number of parallel threads executed by the make process invoked by each ebuild itself.

As has been recommended, we'll set our number of concurrent jobs and parallel make threads to attempt, to be equal to the number of CPUs on the system, plus one.[7] We'll also prevent new jobs or compilations starting when the system load average hits or exceeds the number of CPUs.

The two variables we'll need to set here are EMERGE_DEFAULT_OPTS (for Portage job control) and MAKEOPTS (to pass options on to make). These are often defined in the make.conf file, but we want to allow the values to be set programmatically. Since Portage doesn't support fancy bash features like command substitution,[8] we'll set and export these variables in root's .bashrc instead (these will then override any conflicting values in the make.conf or profile, as explained earlier).
Note
Generally speaking, emerge is launched as the root user (superuser) in Gentoo. emerge usually drops its privilege level to run as the "portage" user when compiling.

Start up your favourite editor: in this tutorial we'll be assuming nano:
livecd ~ #nano -w /mnt/gentoo/root/.bashrc
Note
The -w option tells the nano editor not to auto-wrap long lines (auto-wrapping can really mess up config files!).

nano is a pretty simple editor to use: move around using the arrow keys, type to edit as you would in any text processing program, and exit with Ctrlx when done: you'll be prompted whether to save changes if you have modified the file. At this point, enter y and Enter to exit, saving changes, or n to exit without making changes. For some more information on the nano editor, see this Wiki entry.

Add the following text to the file:
FILE /mnt/gentoo/root/.bashrcSetting up MAKEOPTS and EMERGE_DEFAULT_OPTS

export NUMCPUS=$(nproc)
export NUMCPUSPLUSONE=$(( NUMCPUS + 1 ))
export MAKEOPTS="-j${NUMCPUSPLUSONE} -l${NUMCPUS}"
export EMERGE_DEFAULT_OPTS="--jobs=${NUMCPUSPLUSONE} --load-average=${NUMCPUS}"

Save and exit the nano editor.
Note
Should you experience problems with parallel make, and wish to fall back to a more conservative setting, you can do so globally by setting MAKEOPTS="-j1" in the above.

Next, we need to make sure that the .bashrc file is picked up by root's login shell, so copy across the default .bash_profile:
livecd ~ #cp -v /mnt/gentoo/etc/skel/.bash_profile /mnt/gentoo/root/

Next, on to the make.conf configuration file itself. The stage 3 tarball we extracted already contains a skeleton configuration. We'll open this file with nano (feel free to substitute your favourite alternative editor), delete the existing lines (in nano, Ctrlk can be used to quickly cut the current line), and enter our alternative configuration instead (see after for a line-by-line explanation). Issue:
livecd ~ #nano -w /mnt/gentoo/etc/portage/make.conf

Edit the file so it reads:
FILE /mnt/gentoo/etc/portage/make.confSetting up essential Portage variables

# Build setup as of <add current date>

# C, C++ and FORTRAN options for GCC.

COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# Note: MAKEOPTS and EMERGE_DEFAULT_OPTS are set in .bashrc

# The following licence is required, in addition to @FREE, for GNOME.

ACCEPT_LICENSE="CC-Sampling-Plus-1.0"

# WARNING: Changing your CHOST is not something that should be done lightly.

# Please consult http://www.gentoo.org/doc/en/change-chost.xml before changing.

CHOST="x86_64-pc-linux-gnu"

# Use the 'stable' branch - 'testing' no longer required for Gnome 3.

# NB, amd64 is correct for both Intel and AMD 64-bit CPUs

ACCEPT_KEYWORDS="amd64"

# Additional USE flags supplementary to those specified by the current profile.

USE=""
CPU_FLAGS_X86="mmx mmxext sse sse2"

# Important Portage directories.

PORTDIR="/var/db/repos/gentoo"
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/binpkgs"

# This sets the language of build output to English.

# Please keep this setting intact when reporting bugs.

LC_MESSAGES=C

# Turn on logging - see http://gentoo-en.vfose.ru/wiki/Gentoo_maintenance.

PORTAGE_ELOG_CLASSES="info warn error log qa"

# Echo messages after emerge, also save to /var/log/portage/elog

PORTAGE_ELOG_SYSTEM="echo save"

# Ensure elogs saved in category subdirectories.

# Build binary packages as a byproduct of each emerge, a useful backup.

FEATURES="split-elog buildpkg"

# Settings for X11

VIDEO_CARDS="intel i965"
INPUT_DEVICES="libinput"

Note
Set VIDEO_CARDS and INPUT_DEVICES to appropriate values for your particular system in /etc/portage/make.conf. See table below for discussion.
Important
As discussed below, ensure that you only specify CPU_FLAGS_X86 flags that your CPU supports, otherwise compiled software may crash.

Save the file and exit nano.

Here is a brief summary of the shipped ('stage 3') values are, and what our version achieves:
Note
As of 2019, the stage 3's shipped make.conf is rather minimal, since the majority of the important values are instead set by the active profile's make.defaults files (including the CHOST). The main instances of these may be viewed — once we have installed the Gentoo ebuild repository, in the next chapter — at (/mnt/gentoo)/var/db/repos/gentoo/profiles/default/linux/make.defaults and (/mnt/gentoo)/var/db/repos/gentoo/profiles/arch/amd64/make.defaults. (Gentoo's profile system allows multiple such make.defaults files to be sourced, to allow profiles to be constructed hierarchically.)
For simplicity, the effective value has been shown in the table below.
Variable     Type     Value in Stage 3's make.conf (or profile's make.defaults)     Our Value     Description
COMMON_FLAGS     Standard     -O2 -pipe     -march=native -O2 -pipe     This variable simply defines some common flags, passed to the GNU Compiler Collection (GCC) what switches to use when compiling source code. The defaults specify -O2, which sets the recommended level of optimization (producing smaller, faster code at the expense of a slightly longer compilation), and -pipe, which instructs the compiler to use pipes rather than temporary files where possible (speeding up compilation in exchange for additional memory requirements). We retain these, and add -march=native. This instructs the compiler to detect your CPU type automatically, and then produce code exploiting its idiosyncratic features, special instruction sets and so on. Setting -march=native implies that code produced will very likely not run on other CPUs: don't use it if you intend to compile packages for use on other machines!.
CFLAGS     Standard     ${COMMON_FLAGS}     ${COMMON_FLAGS}     This variable is sets the compiler flags for C code.
CXXFLAGS     Standard     ${COMMON_FLAGS}     ${COMMON_FLAGS}     This is the equivalent of CFLAGS for C++ code. We retain the default behaviour, which is to use the common flags just defined.
FCFLAGS     Standard     ${COMMON_FLAGS}     ${COMMON_FLAGS}     Flags passed to FORTRAN compilers in more modern build systems. Ditto.
FFLAGS     Standard     ${COMMON_FLAGS}     ${COMMON_FLAGS}     Flags passed to the FORTRAN 77 compiler. Ditto.
ACCEPT_LICENSE     Incremental     -* @FREE     CC-Sampling-Plus-1.0     This incremental variable controls which licenses are acceptable for packages used on your system, another nice feature of Portage. As of 23rd May 2019,[9] the default is to reset the variable (with -*) and then enable only the 'free' license metaset (with @FREE; you can review all such sets at /var/db/repos/gentoo/profiles/license_groups). (This is 'free' in the Free Software Foundation sense, so is relatively safe.[10])
Here, we also allow CC-Sampling-Plus-1.0; essentially a free-use license (this adds to the baseline permissions, since the variable is incremental), but one which is not currently included in @FREE; it may be viewed at /var/db/repos/gentoo/licenses/CC-Sampling-Plus-1.0. It is needed for some GNOME components.
CHOST     Standard     x86_64-pc-linux-gnu     x86_64-pc-linux-gnu     The CHOST variable is very important. It is a dash-separated tuple of architecture-vendor-operating_system-C_library and is used to control the build process. The default value here (architecture: x86_64, vendor: pc, operating system: linux, C library: gnu) is fine for our purposes so we will not change it. Although the profile will set this value, we specify it explicitly here, to avoid confusion should you want to setup multiple cross-compilation environments later. If you wish, you can omit it.
ACCEPT_KEYWORDS     Incremental     amd64     amd64     This variable instructs Portage which ebuild keywords it should accept. As Gnome 3 has now been stabilized, there is no need to use the 'testing' branch; (but should you wish to do so, use '~amd64' rather than 'amd64'; please note that a consequence of doing so is that you will receive very up-to-date versions of all the software on your system (good), and occasionally, you may encounter the odd problem when updating (due to conflicts or bugs that have not yet surfaced and been resolved) (not so good)). We copy the value implicitly set by the profile here, for clarity; if you wish, you can omit it (unless electing to use ~amd64, of course).
For avoidance of doubt, amd64 covers both Intel and AMD processors with a 64-bit architecture.
USE     Incremental     various flags set by profile     empty     As discussed above, use flags specify package features to Portage (and often, but not always, map directly to autoconf feature options 'under the cover'[11][12][13]). As we will be building packages for a personal machine, and not for binary redistribution, we omit the bindist flag; omitting it allows certain additional codecs etc. to be enabled. (Note that this is an incremental variable, so leaving it blank here will not 'wipe out' any USE flags the profile has set; you'd have to specify "-*" if you really wanted to do that.)
CPU_FLAGS_X86     USE_EXPAND     mmx mmxext sse sse2     mmx mmxext sse sse2
will set next chapter     This variable instructs Portage which processor-specific flags to use (specifying the availability of particular capabilities such as MMX, for example). It is now recommended to use this separate flag group (which is valid on amd64 also, despite the name), rather than place CPU flags directly into USE. We leave the default settings for now, but will use the app-portage/cpuinfo2cpuflags package to derive the appropriate optimized settings for us automatically (from /proc/cpuinfo), in the next chapter. (Note - these architecture flags should not be mixed up with the compiler-related CFLAGS and CXXFLAGS, although they appear somewhat similar. Generally, architecture use flags will set package-features (for example, in ffmpeg, enabling specific blocks of pre-written assembly code).)
PORTDIR     Standard     /var/db/repos/gentoo     /var/db/repos/gentoo     This variable simply defines the location of the Portage tree. We leave it as-is. NB: this has changed from the prior Gentoo default location (which was /usr/portage).
DISTDIR     Standard     /var/cache/distfiles     /var/cache/distfiles     This variable defines where Portage will store its source code tarballs. We leave it as-is. NB this has also changed from the prior Gentoo default location (which was /usr/portage/distfiles).
PKGDIR     Standard     /var/cache/binpkgs     /var/cache/binpkgs     This variable decides where binary packages will be stored, should you decide to download them (as an alternative to compiling from source), or to create your own (as a side-effect of compiling from source, as we will do in this tutorial). We leave the setting as is. (Note - if you intend to redistribute the binary packages created in ${PKGDIR}, you must set the bindist use flag, and should also set ACCEPT_RESTRICT="* -bindist" in /etc/portage/make.conf in such a case.) NB this location has also changed from the prior Gentoo default (which was /usr/portage/packages).
LC_MESSAGES     Standard     C     C     This variable sets the language used for build system output. We leave it set to "C" here (which implies output in English), as that is required when filing bug reports, but you can change it to a more convenient value for day-to-day use, if you like.
PORTAGE_ELOG_CLASSES     Standard     absent     info warn error log qa     This variable tells Portage what kinds of ebuild messages you want logged. The flags given here switch on all messages; modify to suit your own requirements (see the Gentoo Handbook, part 3 chapter 1 for more details).
PORTAGE_ELOG_SYSTEM     Standard     absent     echo save     This variable instructs Portage what to do with log messages - in this case echo them to the console after the emerge, and also save them (rather than pass them to a user-defined command, etc.) Note that you can also instruct Portage to save your full build logs if you wish: see swift's blog post here.
FEATURES     Incremental     various features set by profile     split-elog buildpkg     As its name suggests, this incremental variable is used to turn on (or off) optional Portage features. In this case, we turn on split-elog, which ensures that the logs just discussed get saved in category subdirectories of /var/log/portage/elog; this makes them easier to navigate, and we also turn on buildpkg, so that when packages are emerged, Portage will automatically create a matching binary package in ${PKGDIR} as a side-effect (which is useful for disaster recovery). If you want to add additional features, just append them to this variable, separated by a space.
VIDEO_CARDS     USE_EXPAND     comprehensive list of video cards set by profile     intel i965     This variable is used to inform various packages which video card you have in your system (it is a USE_EXPAND variable). You can omit it, in which case modular support for all available systems is implied (as such, it's more efficient to specify it). The Panasonic CF-AX3 has modern integrated Intel graphics, as do many laptops, so we specify intel i965 here. If you have an nVidea card, and wish to use open-source drivers, you should specify nouveau instead here, for example; if an old ATI card from way before it was purchased by AMD, ati; if a pre-2015 ATI/AMD Radeon card, radeon; if you run a brand new Radeon R9 390 or RX 480, radeon amdgpu radeonsi, etc. (See these comments on the Gentoo wiki.)
Note that for a simple fallback driver, which should work on most systems (albeit with relatively low resolution and performance), you can also specify vesa here. Another useful fallback value is fbdev, which specifies the simple x11-drivers/xf86-video-fbdev framebuffer device video driver. Those installing to a VirtualBox client — and for avoidance of doubt this won't apply to most readers — should specify fbdev virtualbox vmware here, for the broadest choice of drivers.
INPUT_DEVICES     USE_EXPAND     various input devices set by profile     libinput     This variable instructs the X Window server (which we will be installing shortly) which input devices to support. It is also a USE_EXPAND variable.
Note that whereas older systems might have typically specified "evdev synaptics" here, these are now replaced for most purposes simply by libinput, as above (see also these comments on the Gentoo wiki; libinput is also the default input driver for wayland compositors).
Note
When using incremental variables such as FEATURES, note that the above-mentioned 'auto-cascading' only works between (executed) configuration files, not within them. As such, if you wanted to e.g. add a second FEATURES line to /etc/portage/make.conf, you should use the FEATURES="${FEATURES} <newfeature>" rubric, to avoid discarding the first line's settings. Incidentally, it's always safe to use the above rubric, even the first time you set an incremental variable in a configuration file. Furthermore, it note that it is safe to have multiple flags added line-by-line in non-executed configuration files, such as those in /etc/portage/package.use/<...>, since these are externally parsed

–- 

___

# –––

# 

# 