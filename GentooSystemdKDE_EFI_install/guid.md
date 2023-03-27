[User:Sakaki/Sakaki's EFI Install Guide - Gentoo Wiki](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide)

> # User:Sakaki/Sakaki's EFI Install Guide
> 
> From Gentoo Wiki
> 
> < [User:Sakaki](https://wiki.gentoo.org/wiki/User:Sakaki)
> 
> [Jump to:navigation](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#mw-head) [Jump to:search](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#searchInput)
> 
> If you have a Windows 10 (or 8) machine that you'd like to dual-boot with Gentoo Linux and GNOME 3, you've come to the right place!
> 
> [![img](https://wiki.gentoo.org/images/thumb/9/9c/Dual_boot_cfax3_2.jpg/400px-Dual_boot_cfax3_2.jpg)](https://wiki.gentoo.org/wiki/File:Dual_boot_cfax3_2.jpg)
> 
> CF-AX3 Ultrabook, Running Windows 10 / Gentoo Linux
> 
> **Warning**
> 31 Oct 2020: sadly, due to legal obligations arising from a recent change in my 'real world' job, I must announce I am **standing down as maintainer of this guide with immediate effect** (for more background, please see my post [here](https://forums.gentoo.org/viewtopic-p-8522963.html#8522963)).
> 
> While I will be leaving this guide up for now (for historical interest, and because it may still be of use to others), I can no longer recommend that you install a new Gentoo system using it. Instead, please follow the standard [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) flow.
> 
> Similarly, if you are already running a system installed via these instructions, while it *should* continue to work for some time, you should now take steps to migrate to a standard, Handbook-based approach, since the underlying sakaki-tools repo, and provided tools such as buildkernel, will also no longer be actively supported.
> 
> With sincere apologies, sakaki ><
> 
> This detailed (and tested) tutorial shows how to set up just such a dual-boot system, where the Gentoo component:
> 
> - is fully encrypted on disk (LVM over LUKS, with dual-factor protection);
> - uses UEFI secure boot;
> - OpenRC & GNOME 3 (on Wayland);
>   - *or* runs systemd & GNOME 3 (ditto);
> - can properly suspend and hibernate;
> - has working drivers for touchscreen, webcam etc.;
> - has (where appropriate) the Intel Management Engine disabled;[[1\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#cite_note-1)
> - and even has a graphical boot splash!
> 
> To keep things concrete, I'll be walking line-by-line through the setup of a particular machine, namely the Panasonic CF-AX3 [Ultrabook](https://en.wikipedia.org/wiki/Ultrabook); however, these instructions should be usable (with minor alterations) for many modern PCs (including desktops) which have a [UEFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface) BIOS.
> 
> All commands that you'll need to type in are listed, and an ebuild repository (aka 'overlay') with some useful installation utilities is also provided.
> 
> While best read in tandem with the official [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:Main_Page), this manual can also be used standalone.
> 
> These instructions may also be easily adapted for those wishing to use Gentoo Linux as their sole OS, rather than dual booting.
> 
> ## Contents
> 
> - [1 Introduction](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Introduction)
> - [2 Chapters](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Chapters)
> - [3 Let's Get Started!](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Let.27s_Get_Started.21)
> - [4 Notes](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Notes)
> 
> ## Introduction
> 
> The install described in this tutorial attempts to follow the 'stock' process from the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) where possible, but differs in a number of important respects. Specifically:
> 
> - The kernel will be configured to self-boot under UEFI; no separate bootloader is needed.
> 
> - For security, we will boot the kernel off of an external USB key (which can be removed once the boot has completed). If the USB key is absent on power-up, Windows will start automatically instead.
> 
> - Secure boot will be enabled. The kernel will be signed with our own, generated key (and the original Windows keys will be retained too).
> 
> - Gentoo's root, swap and home partitions will reside on LVM logical volumes, which themselves will live on a single LUKS (encrypted) partition on the GPT-formatted hard drive of the machine. We'll shrink the Windows C: NTFS partition to provide space for this.
> 
> - The LUKS partition will be unlocked by a keyfile at boot. The keyfile will be stored on the USB key together with the Gentoo kernel, and will *itself* be GPG-encrypted, so that both the file *and* its passphrase will be needed to access the (Gentoo) data on the hard drive. This provides a degree of dual-factor security against e.g., having the machine stolen with the USB key still in it, or even the existence of a keylogger on the PC itself (although not both at the same time!). (Using a provided utility, you can subsequently migrate the kernel onto the Windows EFI system partition on the main drive if desired, and also relax the security to use just a typed-in passphrase, so once installed you won't need to use a USB key at all if you don't want to.)
> 
> - We will create an initramfs to allow the GPG / LUKS / LVM stuff to happen in early userspace, and this RAM disk will be stored inside the kernel itself, so it will work under EFI with secure boot (we'll also, for reasons that will become clear later, build a custom version of gpg to use in this step).
> 
> - For all you source-code paranoiacs, the Gentoo toolchain and core system will be bootstrapped during the install (simulating an old-school stage-1) and we'll validate that all binary executables and libraries have indeed been rebuilt from source when done. The licence model will be set to accept free software only (and although I don't deblob the kernel, instructions for how to do so are provided - assuming your hardware will actually work without uploaded firmware!).
> 
> - All Gentoo repository syncs (including the initial emerge-webrsync) will be performed with gpg signature authentication. Unauthenticated protocols will *not* be used.
> 
> - The latest (3.30+) 
>   
>   stable
>   
>    version of GNOME will be installed, using 
>   
>   OpenRC
>   
>    for init (as GNOME is now officially supported under this init system, and no longer requires Dantrell B.'s patchset for this).
>   
>   - An alternative track is also provided, for those wishing to install GNOME 3 under [systemd](https://wiki.gentoo.org/wiki/Systemd). Most of this tutorial is common to both tracks, and a short guide is provided at the appropriate point in the text, to help you choose which route is better for you.
>   - GNOME will be deployed on the modern [Wayland](https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)) platform (including [XWayland](https://wayland.freedesktop.org/xserver.html) support for legacy applications) — this is [more secure](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Sandboxing_the_Firefox_Browser_with_Firejail#x11_vulnerability) than deploying over X11, as it enforces application isolation at the GUI level.
> 
> - I'll provide simple scripts to automate the EFI kernel creation process and keep your system up-to-date. The first of these (buildkernel) handles conforming the kernel config for EFI encrypted boot (including setting the kernel command line correctly), creating the initramfs, building and signing the kernel, and installing it on the EFI system partition. The second (genup) automates the process of updating your system software via emerge and associated tools. The scripts are shipped in an ebuild repository (aka 'overlay'), for easy deployment.
> 
> - Lastly, detailed (optional) instructions for disabling the Intel Management Engine[[2\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#cite_note-2) will be provided (for those with Intel-CPU-based PCs who find this out-of-band coprocessor an unacceptable security risk), as will instructions for fully sandboxing the popular firefox web browser, using firejail.
> 
> **Note**
> Tutorials covering various elements of the above can be found in one or more places online, but it's difficult to get an end-to-end overview - hence the reason this guide was created.
> 
> As mentioned, although this tutorial follows the format of the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) in places (particularly at the beginning), it's structured so as to be self-contained - you should be able to walk though this process and, using only these instructions, end up with a fully functional, relatively secure dual-boot Windows 10 (or 8) + Gentoo / GNOME 3 machine when you're done.
> 
> **Warning**
> Backup **all** of your data before doing anything else, particularly if you have a lot of work stored on Windows already. The install process described here has been tested end-to-end, *but* is provided 'as is' and without warranty. Proceed at your own risk.
> 
> **Warning**
> Tools like parted, dd and cryptsetup, which we'll be using, can vaporize data easily if misused. Please always double check that you are *applying operations to the correct device / partition*. We've all been there...
> 
> **Warning**
> We will be using strong cryptography to protect your system. If you lose the LUKS keyfile, or forget the passphrase to unlock it, **all your data will be gone**, and even the NSA (probably!) won't be able to get it back.[[3\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#cite_note-3) So keep backups of these critical elements too (in a safe place, of course)!
> 
> ## Chapters
> 
> The chapters of this tutorial are listed below, together with a brief summary of each.
> 
> You need to work though the chapters sequentially, in order to complete the install successfully.
> 
> **Note**
> Don't worry if you don't immediately understand everything in the chapter summaries below: the concepts involved will be described in detail in the main body of the text.
> 
> 1. **[Installation Prerequisites](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites)**. First, we'll briefly review the things you'll need in order to carry out the install.
> 2. **[Preparing Windows for Dual-Booting](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting)**. Next, we'll reduce the amount of space Windows takes up on the target machine's hard drive, so there is room for our Gentoo system (and user data). We'll use tools already present in Windows to do this.
> 3. **[Creating and Booting the Minimal-Install Image on USB](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB)**. Then, per [Chapter 2](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media) of the Gentoo handbook, we'll download a minimal Gentoo image onto a USB key, and boot into it on our target PC (in EFI / OpenRC mode, with secure boot temporarily turned off).
> 4. **[Setting Up Networking and Connecting via ssh](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh)**. Next, per [Chapter 3](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking) of the handbook, we'll setup network access for our minimal system, and connect in to it from a second, 'helper' PC via ssh (to ease installation).
> 5. **[Preparing the LUKS-LVM Filesystem and Boot USB Key](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key)**. After that, we'll create a GPG-protected keyfile on a second USB key, create a LUKS (encrypted) partition on the machine's hard drive protected with this key, and then create an LVM structure (root, home and swap) on top of this (achieving the goals of [Chapter 4](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks) of the handbook).
> 6. **[Installing the Gentoo Stage 3 Files](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files)**. Then, per [Chapter 5](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage) of the handbook, we'll download a Gentoo 'stage 3' minimal filesystem, and install it into the LVM root. We'll also set up your Portage build configuration.
> 7. **[Building the Gentoo Base System Minus Kernel](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Building_the_Gentoo_Base_System_Minus_Kernel)**. Next, per [Chapter 6](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base) of the handbook, we'll complete some final preparations, then chroot into the stage 3 filesystem, update our Portage tree, and set a base profile, timezone and locale. We'll setup the sakaki-tools ebuild repository (which contains utilities to assist with the build), and install the first of these, showem (a program to monitor parallel emerges). Then, we'll bootstrap the toolchain (simulating an old-school stage 1 install), rebuild everything in the @world set, and verify that all libraries and executables have, in fact, been rebuilt. (Instructions are also provided for those who wish to skip bootstrapping). We'll then set the 'real' GNOME profile, and then update the @world set to reflect this.
> 8. **[Configuring and Building the Kernel](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_and_Building_the_Kernel)**. Next, (loosely following [Chapter 7](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel) of the handbook), we'll setup necessary licenses, then download the Linux kernel sources and firmware. We'll then install (from the sakaki-tools ebuild repository) the buildkernel utility, configure it, and then use *this* to automatically build our (EFI-stub) kernel (buildkernel ensures our kernel command line is filled out properly, the initramfs contains a static version of gpg, that the kernel has all necessary options set for systemd, etc.).
> 9. **[Final Preparations and Reboot into EFI](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Final_Preparations_and_Reboot_into_EFI)**. Then, following [Chapter 8](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System) of the handbook, we'll set up /etc/fstab, install a few other packages, set up a root password, then dismount the chroot and reboot (in EFI / OpenRC mode, or EFI / systemd mode, depending on the track) into our new system (secure boot will still be off at this stage). Users on the OpenRC track will [branch off](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#alternative_track) at the conclusion of this chapter.
> 10. **[Completing OpenRC Configuration and Installing Necessary Tools](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Completing_OpenRC_Configuration_and_Installing_Necessary_Tools)**. With the machine restarted, we'll re-establish networking and the ssh connection, then complete the setup of systemd's configuration. Per [Chapter 9](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Tools) of the Gentoo handbook, we'll then install some additional system tools (such as cron). Next, we'll install (from the sakaki-tools ebuild repository) the genup utility, and use it to perform a precautionary update of the @world set. Then, we'll reboot to check our OpenRC configuration. If successful, we'll invoke buildkernel again, to enable the plymouth graphical boot splash, and restart once more to test it.
> 11. **[Configuring Secure Boot under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot_under_OpenRC)**. Next, we'll set up secure boot. First, we'll save off the existing state of the secure boot variables (containing Microsoft's public key-exchange-key, etc.). Then, we'll create our own platform, key-exchange and kernel-signing keypairs, and then reboot, *en route* using the BIOS GUI to enter setup mode (thereby clearing the variables, and enabling us to write to them). We'll then re-upload the saved keys, append our own set, and finally lock the platform with our new platform key. We'll then run buildkernel again, which will now be able to automatically sign our kernel. We'll reboot, enable secure boot in the BIOS, and verify that our signed kernel is allowed to run. Then, we'll reboot into Windows, and check we haven't broken *its* secure boot operation! Finally, we'll reboot back to Linux again (optionally setting a BIOS password as we do so).
> 12. **[Setting up the GNOME 3 Desktop under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_up_the_GNOME_3_Desktop_under_OpenRC)**. Next, we'll setup your graphical desktop environment. We'll begin by creating a regular (non-root) user, per [Chapter 11](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing#Adding_a_user_for_daily_use) of the handbook. Then, we'll activate the wayland USE flag globally, and update your system to reflect this, after which we'll install X11 and a simple window manager (twm) (for test purposes). Using buildkernel, we'll then reconfigure and rebuild the kernel to include an appropriate [DRM](https://en.wikipedia.org/wiki/Direct_Rendering_Manager) graphics driver, and then reboot. Upon restart, we'll verify that the new DRM driver (which wayland requires) has been activated, and then test-run X11 (and a few trivial applicators) under twm. Once working, we'll remove the temporary window manager, install GNOME 3 (and a few key applications), and configure and test it under X11. Then, we'll test it again under wayland, refine a few settings (network, keyboard etc.), and then restart the machine and proceed with the install, working natively within GNOME thereafter.
> 13. **[Final Configuration Steps under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Final_Configuration_Steps_under_OpenRC)**. Next, we'll configure your kernel to properly handle all your target PC's devices. Although this setup will necessarily differ from machine to machine, a general methodology is provided, together with a concrete set of steps required for the Panasonic CF-AX3 (covering setup of its integrated WiFi, Bluetooth, touchscreen, audio and SD card reader). Thereafter, we'll cover some final setup points - namely, how to: prune your kernel configuration (and initramfs firmware) to remove bloat; get suspend and hibernate working properly; and disable sshd (as the helper PC is no longer needed from this point).
> 14. **[Using Your New Gentoo System under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Using_Your_New_Gentoo_System_under_OpenRC)**. Now your dual-boot system is up and running, in this last chapter we'll cover a few miscellaneous (but important) topics (and options) regarding day-to-day use. We'll first recap how to boot from Linux to Windows (and vice versa), then discuss how to ensure your machine is kept up to date (using genup). We'll also show how to migrate your kernel to the internal drive (Windows) EFI system partition if desired (and also, how to dispense with the USB key entirely, if single-factor passphrase security is sufficient). In addition, we'll briefly review how to tweak GNOME, and (per [Chapter 11](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing#Where_to_go_from_here) of the handbook) where to go next (should you wish to install other applications, a firewall, etc.). Finally, a number of addendum "mini-guides" are provided, covering how to *e.g.*, [disable the Intel Management Engine](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine) on your target PC, and [fully sandbox the firefox web browser, using firejail](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Sandboxing_the_Firefox_Browser_with_Firejail).
> 
> As mentioned, an 'alternative track' is also provided for chapters 10-14, for those users who wish to use GNOME with systemd, rather than OpenRC:
> 
> 1. **[Alternative Track: Configuring systemd and Installing Necessary Tools (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_systemd_and_Installing_Necessary_Tools)**
> 2. **[Alternative Track: Configuring Secure Boot (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot)**
> 3. **[Alternative Track: Setting up the GNOME 3 Desktop (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_up_the_GNOME_3_Desktop)**
> 4. **[Alternative Track: Final Configuration Steps (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Final_Configuration_Steps)**
> 5. **[Alternative Track: Using Your New Gentoo System (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Using_Your_New_Gentoo_System)**
> 
> **Note**
> The decision about which init system (OpenRC or systemd) to use does not need to be made until Chapter 7 (where a brief summary of the pros and cons of each will be provided, to help you decide).
> 
> ## Let's Get Started!
> 
> Ready? Then [click here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites) to go to the first chapter, "Installation Prerequisites".
> 
> **Note**
> As is hopefully clear from the above, this tutorial covers a detailed, end-to-end installation walkthrough.
> If you are searching for more concise, topic-based EFI, systemd or GNOME installation information, the following Wiki pages may be of use to you instead:
> 
> - [UEFI Gentoo Quick Install Guide](https://wiki.gentoo.org/wiki/UEFI_Gentoo_Quick_Install_Guide)
> - [EFI stub kernel](https://wiki.gentoo.org/wiki/EFI_stub_kernel)
> - [systemd](https://wiki.gentoo.org/wiki/Systemd)
> - [systemd/Installing Gnome3 from scratch](https://wiki.gentoo.org/wiki/Systemd/Installing_Gnome3_from_scratch)
> - [GNOME/GNOME without systemd](https://wiki.gentoo.org/wiki/GNOME/GNOME_without_systemd)
> 
> **Note**
> If you have recently upgraded [dev-libs/libgcrypt](https://packages.gentoo.org/packages/dev-libs/libgcrypt) to version >= 1.6, and found yourself thereby locked out of your (Whirlpool-hashed) LUKS partition, please see [this short guide](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Migrating_from_Whirlpool_Hash_on_LUKS) on how to recover.
> 
> **Note**
> Comments, suggestions and feedback about this guide are welcomed! You can use the "Discussion" tab (of whatever is the most relevant page) for this purpose. On most browsers, you can use ShiftAltt as a shortcut to access this.
> 
> **Tip**
> While the [MediaWiki](https://mediawiki.org/) *source* for individual pages of this guide may most easily be edited or viewed on the Gentoo Wiki directly, for ease of download the full page set is also maintained on GitHub, [here](https://github.com/sakaki-/efi-install-guide-source).
> 
> ## Notes
> 
> - As the ME is disabled via an (optional) system firmware modification, it will remain inactive even when booted into Windows.
> - For avoidance of doubt, in this guide 'disabled' has the same meaning as 'neutralized and disabled' in the Purism Inc. Blog: ["Deep Dive into Intel Management Engine Disablement"](https://puri.sm/posts/deep-dive-into-intel-me-disablement/)
> 
> TechCrunch: ["Encrypting Your Email Works, Says NSA Whistleblower Edward Snowden"](http://techcrunch.com/2013/06/17/encrypting-your-email-works-says-nsa-whistleblower-edward-snowden/)

[User:Sakaki/Sakaki's EFI Install Guide/Installation Prerequisites - Gentoo Wiki](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites)

> # User:Sakaki/Sakaki's EFI Install Guide/Installation Prerequisites
> 
> From Gentoo Wiki
> 
> < [User:Sakaki](https://wiki.gentoo.org/wiki/User:Sakaki)‎ | [Sakaki's EFI Install Guide](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide)
> 
> [Jump to:navigation](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites#mw-head) [Jump to:search](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites#searchInput)
> 
> The installation process described in this manual has a small number of prerequisites, which are listed below.
> 
> Make sure that you have everything before starting out!
> 
> ## What You'll Need
> 
> To work through this install, you will need:
> 
> - A target, UEFI PC with Windows-10 (or 8 or 8.1) pre-installed (for example, an [Ultrabook](https://en.wikipedia.org/wiki/Ultrabook)). I'm going to assume you have already set up Windows, that you have an admin account (the first user on the machine automatically has admin rights), and that you haven't used up all the disk space on C: yet.
>   
>   **Note**
>   Obviously, you can adapt the following instructions to create a single-OS Gentoo system very easily, if you don't have Windows, or want to wipe it. However, I'm only going to deal with the dual-boot scenario in this tutorial, as it is the more complicated case.
>   
>   **Important**
>   At the time of writing, it appears that machines designated as "Designed for Windows 10" do *not* have to provide the option to turn off secure boot, as Windows 8 certified machines did.[[1\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites#cite_note-1)[[2\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites#cite_note-2) It remains to be seen how this will pan out, and whether OEMs will continue to provide the option. However, this option **is** necessary to complete this tutorial (because, although we *will* use secure boot ultimately, to do so we will need to add our own custom keys into the keystore, a process which is done from an unsecured UEFI-booted session), so if you intend using a PC that has the "Designed for Windows 10" mark, please check before proceeding that its BIOS still affords you the option.
> 
> - Two USB keys, one of at least 500MB, and the other of at least 250MB:
>   
>   - the larger one is for the initial Gentoo minimal-install disk image, which we'll use to get the ball rolling; and
>   - the smaller one is where we'll place our compiled, UEFI bootable Gentoo Linux kernel and keyfile (we'll refer to this as the **boot USB key** throughout the rest of the tutorial).
> 
> **Note**
> It is of course possible to boot from a burned CD, DVD etc., but in the modern day USB keys tend to be ubiquitous (and many laptops have no optical drive), so that's the route I'll take here. By the way, it's no problem if your USB keys are bigger, even much bigger, than the minimum sizes stipulated above: and indeed it is probably a good idea for the boot USB key to be 500MB or greater in size, to allow for kernel backups and so on.
> 
> - A working subnet to which the install target machine can be connected. To be concrete, I'm going to assume a 192.168.1.0/24 subnet, but yours may of course be different, in which case modify the instructions accordingly. There must be a gateway on the network providing Internet access, and a [DHCP](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) server. Furthermore, your target PC must have either:
> 1. a wired Ethernet adapter with driver support in the Gentoo minimal-install image (most do). This is the simplest option from an installation perspective, even if you intend going wireless once the system is up and running. WiFi routers usually have ports on the back into which you can plug Ethernet cables directly; or
> 2. a WiFi modem with driver support in the Gentoo minimal-install image (many do). The tutorial covers setting up such a connection over [WPA/WPA2](https://en.wikipedia.org/wiki/Wi-Fi_Protected_Access), since this is the most common modern use case.
> 
> **Note**
> It is of course still possible to perform an install in other network configurations (for example, where you wish to use an open WiFi network, static IP addresses, proxies etc.). Please refer to [Chapter 3 of the Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking#Manual_network_configuration) for more details, where necessary during the tutorial.
> 
> **Note**
> If your machine's WiFi is not operational under the minimal-install image, *and* it has no Ethernet port of its own, you could consider buying an inexpensive USB-to-Ethernet adaptor (for example, I have used [this one](https://www.amazon.co.uk/dp/B00AQM8586) successfully on a number of Gentoo netbook installs).
> 
> - A second, 'helper' PC, running Linux, on the same subnet. Of course, this is not 
>   
>   strictly
>   
>    required - you 
>   
>   can
>   
>    do everything on the target machine itself. However, having a second machine really helps, because:
>   
>   - once the initial, minimal-install image has booted, you can ssh in to it from this second box, and run [screen](https://en.wikipedia.org/wiki/GNU_Screen); this gives you the ability to copy and paste commands and scripts from this tutorial, and to disconnect when lengthy processes are running, reconnecting later; and
>   - creation of the initial USB images etc. is easier from Linux than from Windows; although you *can* create the setup disks using Windows, I won't be covering the necessary steps here.
> 
> **Note**
> You don't have to run Gentoo Linux natively on this second box either. For example, if you are starting from an 'all Windows' configuration, you could create a bootable Ubuntu live USB key[[3\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites#cite_note-3) and boot your helper PC from that (it will allow you to work without damaging anything on the machine's hard drive).
> 
> ## Commencing the Install
> 
> Got everything? Then [click here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting) to go to the next chapter, "Preparing Windows for Dual-Booting".
> 
> ## Notes
> 
> - Ars Techica: ["Windows 10 to make the Secure Boot alt-OS lock out a reality"](http://arstechnica.com/information-technology/2015/03/windows-10-to-make-the-secure-boot-alt-os-lock-out-a-reality/)
> - PCWorld: ["Microsoft tightens Windows 10's Secure Boot screws: Where does that leave Linux?"](http://www.pcworld.com/article/2901262/microsoft-tightens-windows-10s-secure-boot-screws-where-does-that-leave-linux.html)
> 
> Ubuntu: ["How to create a bootable USB stick on Windows"](http://www.ubuntu.com/download/desktop/create-a-usb-stick-on-windows)

[User:Sakaki/Sakaki's EFI Install Guide/Preparing Windows for Dual-Booting - Gentoo Wiki](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting)

> # User:Sakaki/Sakaki's EFI Install Guide/Preparing Windows for Dual-Booting
> 
> From Gentoo Wiki
> 
> < [User:Sakaki](https://wiki.gentoo.org/wiki/User:Sakaki)‎ | [Sakaki's EFI Install Guide](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide)
> 
> [Jump to:navigation](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#mw-head) [Jump to:search](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#searchInput)
> 
> As shipped, a typical Windows 10 (or Windows 8) installation spans its host machine's entire drive.
> 
> Accordingly, our first order of business is to shrink the size of the Windows C: partition, thereby freeing up some space on which to install our new Gentoo system.
> 
> The good news is that Windows already contains the necessary tools to shrink partitions. The not-so-good news is that Windows also sprinkles various files around the drive (for hibernation, paging and system restore), such that even if you have just started using the machine, without some additional work you can only reclaim about half of your C: drive for Linux.
> 
> But, fear not: the instructions below will show you how to get around this restriction.[[1\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#cite_note-1)
> 
> **Note**
> A similar process may be used to free up space in a Windows 7 system too.[[2\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#cite_note-2)
> 
> ## Shrinking Windows' Disk Footprint
> 
> Boot your target machine into Windows as normal, and login to your account (which must have administrator rights - the first user created on a new Windows install has these by default). Next, perform the following steps (I have noted where things differ between Windows 10, 8.1 and 8):
> 
> **Note**
> For Windows 10 users, the following assumes you are logged in with a local account and have options like "Search online and include web results" and Cortana turned off.[[3\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#cite_note-3) If you are running Windows 10 with more permissive settings, be sure to choose the correct item from those returned when directed to perform a search in the following instructions. The correct items will generally be tagged as "Control panel" or "Desktop app".
> 
> 1. Ensure you have **backups** of everything important. Last chance ^-^
> 
> 2. Done that? OK then, to begin with, we'll turn off system protection (restore points).[[4\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#cite_note-4) Hit the Windows Key, which will bring up the start menu in Windows 10 (or the "start screen" in Windows 8.1 and 8), and type `restore point`. Then click on the 'Create a restore point' item which appears (in Windows 10 and 8.1; Windows 8 users will need to click the 'Settings' icon to see this result). You will now be presented with a dialog box with 'System Protection' as the selected tab. Choose the relevant drive (generally, C:). Click the 'Configure...' button. Another dialog pops up - click on the 'Disable system protection' radio button, and click 'OK'. When asked if you are sure, click 'Yes'. (N.B., this will remove existing restore points from the drive, if any; if they are important to you, do not perform this step.) Close out the other dialogs by clicking on 'OK'.
> 
> 3. Next, we'll turn off the virtual memory paging file. Hit the Windows Key, which will bring up the start menu in Windows 10 (or the "start screen" in Windows 8.1 and 8), and type `adjust the appearance`. Then click on the 'Adjust the appearance and performance of Windows' item that appears (in Windows 10 and 8.1; Windows 8 users will again need to click the 'Settings' icon to see this result). You will now be presented with a 'Performance Options' dialog; select the 'Advanced' tab in it. In the virtual memory area, click on 'Change...', and, in the dialog that next appears, untick 'Automatically manage paging file size for all drives', then choose the relevant drive (generally, C:), select the 'No paging file' radio button and click 'Set'. You'll get warnings about the problems this can cause; if happy to proceed select 'Yes', then choose 'OK' again to close out the Virtual Memory dialog itself. If you get a warning about needing to reboot, accept this (but don't reboot yet). Then close out any remaining dialogs.
> 
> 4. Now to turn off hibernation. This is most easily done from the Windows command line. Hit the Windows Key , which will bring up the start menu in Windows 10 (or the "start screen" in Windows 8.1 and 8), and type `command`. Now *right-click* on the 'Command Prompt' icon that appears, then click on 'Run as administrator' item in the context menu (in Windows 10 and 8.1; it appears at the bottom of the screen in Windows 8). If asked whether you wish to proceed, click 'Yes'. You will be presented with an open command window. Now enter `powercfg /H off`. After this, hit CtrlAltDelete, then click on the power icon at the bottom right of the screen, and choose 'Restart' from the pop-up menu.
> 
> 5. Allow the machine to reboot back into Windows, and log in again.
> 
> 6. Now we will defragment the drive. Hit the Windows Key, which will bring up the start menu in Windows 10 (or the "start screen" in Windows 8.1 and 8), and type `defragment`. Then click on the 'Defragment and Optimize Drives' item that appears (in Windows 10; in Windows 8.1 and 8 the required item is named 'Defragment and optimize your drives'). Select the C: drive in the dialog box that appears, and select 'Optimize' (this will defragment the drive). When it has completed, click the 'Close' button to dismiss the dialog.
> 
> 7. Follow the process described earlier to reboot and log in again to Windows. (Without this reboot, the shrink step below may fail.)
> 
> 8. Finally, we are ready to shrink the Windows partition.[[5\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#cite_note-5) Hit Windows Key, which will bring up the start menu in Windows 10 (or the "start screen" in Windows 8.1 and 8), and type `partitions`. Then click on the 'Create and format hard disk partitions' item that appears (in Windows 10 and 8.1; Windows 8 users will again need to click the 'Settings' icon to see this result). *Right click* on the C: partition in the display for Disk0 at the bottom of the 'Disk Management' dialog that appears, and select 'Shrink Volume...' from the context menu. Another dialog entitled 'Shrink C:' appears. If all has gone according to plan with the changes above, you should now be able to enter quite a large amount of shrink space: enter (as you wish) anything up to the maximum amount allowed as shown on the dialog:
> 
> 9. Shrinking the C: Partition in Windows
>    
>    To proceed, click on 'Shrink'. When the process completes, you should now see an additional 'Unallocated' partition at the end of Disk 0 on the 'Disk Management' dialog, and it should be a meaningful percentage of the drive (note that the partition graphical display is not proportional). Note: as an indication, I was able to create a 195.86GB unallocated partition using this method (on a 238.35GB drive, with the C: partition shrunk to 42.10GB from 237.96GB). [YMMV](https://en.wiktionary.org/wiki/your_mileage_may_vary).
>    
>    **Note**
>    If you encounter a problem during the shrink operation, for example Windows informing you that there is not enough disk space available to complete the operation, then try performing a shrink of *half* of the claimed 'available shrink space', and then immediately repeating if successful.
>    
>    **Note**
>    With certain versions of Windows, you may find that the very end of the disk contains a recovery partition (and possibly a number of additional "OEM" partitions). That's nothing to worry about, just shrink the C: partition as described — you'll still be able to install Gentoo onto the space you have freed up, even if it does not span completely to the end of the drive.
>    
>    **Note**
>    How much space to free up for Gentoo / leave for Windows will obviously depend upon your particular usage pattern. You should probably aim to free up a *minimum* of 20GB or so for Gentoo, however. If you are running Windows 8 or 8.1, and planning to upgrade to Windows 10 in the future, you should ensure that your Windows C: partition has a *minimum* of 5GB free space after the shrink.[[6\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#cite_note-6) (Incidentally, even once Gentoo is co-installed, you *can* safely upgrade to Windows 10 without harming the Linux side of things; in this author's experience anyhow.)
> 
> 10. For safety, follow the process described earlier to reboot and log in *again* to Windows. This ensures that all system processes take note of the new partition boundaries.
> 
> 11. Now we'll revert the changes we made to Windows (other than the partition shrink!), prior to installing Gentoo Linux on our newly reclaimed disk space. First, we'll turn on hibernation again. Hit the Windows Key , which will bring up the start menu in Windows 10 (or the "start screen" in Windows 8.1 and 8), and type `command`. Now *right-click* on the 'Command Prompt' icon that appears, then click on 'Run as administrator' item in the context menu (in Windows 10 and 8.1; it appears at the bottom of the screen in Windows 8). If asked whether you wish to proceed, click 'Yes'. You will be presented with an open command window. Now enter `powercfg /H on`. Note that although this enables hibernation, the option to trigger it may still be hidden in the power menu, even after you reboot. We'll fix this shortly.
> 
> 12. Next, let's activate the virtual memory paging file again. Hit the Windows Key, which will bring up the start menu in Windows 10 (or the "start screen" in Windows 8.1 and 8), and type `adjust the appearance`. Then click on the 'Adjust the appearance and performance of Windows' item that appears (in Windows 10 and 8.1; Windows 8 users will again need to click the 'Settings' icon to see this result). You will now be presented with a 'Performance Options' dialog; select the 'Advanced' tab in it. In the virtual memory area, click on 'Change...', and, in the dialog that next appears, tick 'Automatically manage paging file size for all drives', then choose 'OK' to close out the Virtual Memory dialog. If you get a warning about needing to reboot, accept this (but don't reboot yet). Close out all the remaining dialogs.
> 
> 13. Now we'll turn on system protection (restore points) again. Hit the Windows Key, which will bring up the start menu in Windows 10 (or the "start screen" in Windows 8.1 and 8), and type `restore point`. Then click on the 'Create a restore point' item which appears (in Windows 10 and 8.1; Windows 8 users will again need to click the 'Settings' icon to see this result). You will now be presented with a dialog box with 'System Protection' as the selected tab. Choose the relevant drive (generally, C:). Click the 'Configure...' button. Another dialog pops up - click on the 'Turn on system protection' radio button, and click 'OK'. Close out the other dialogs by clicking on 'OK'.
> 
> 14. Follow the process described earlier to reboot and log in one last time to Windows. Check that everything still works as expected.
> 
> 15. The final step is to ensure that hibernation shows up on the Windows power menu.[[7\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#cite_note-7)[[8\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#cite_note-8) Hit the Windows Key, which will bring up the start menu in Windows 10 (or the "start screen" in Windows 8.1 and 8). What you need to do next depends on your Windows version. In Windows 10, type `power options`, and click on the 'Power Options' item which appears (in newer versions of Windows 10, the item has been renamed; you should click on 'Power & sleep settings' instead); then, click 'Choose what the power button does' in the presented dialog box (in newer versions of Windows 10 you will need to click on 'Additional power settings' to see this dialog; the item you want inside it has been renamed also, to 'Choose what the power buttons do'). In Windows 8.1 or 8, type `power buttons`, then click on the 'Change what the power buttons do' item that appears (Windows 8 users will again need to click the 'Settings' icon to see this result). For all version of Windows, next click on the 'Change settings that are currently unavailable' link in the 'System Settings' dialog. In response, the dialog will display some 'Shut-down settings' (Windows 10) or 'Power options settings' (Windows 8.1 and 8). Ensure 'Hibernate' (in Windows 10) or 'Show Hibernate' (in Windows 8.1 and 8) is checked. You should also ensure that the entry 'Turn on fast startup (recommended)' is *unchecked* (this entry might be called 'Hybrid Boot', depending on your system version),[[9\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#cite_note-9) and then click the 'Save Changes' button (if you had to make any modifications). Hibernation should now be an option on the power menu. Hit CtrlAltDelete, then click on the power icon at the bottom right of the screen, to make sure. *Don't* actually hibernate the machine though, simply cancel back out to the main screen, once you've verified that the item is now present.
> 
> ## Next Steps
> 
> Although we're done with our Windows prep work for now, leave the target machine running Windows for the moment. [Click here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB) to go to the next chapter, "Creating and Booting the Minimal-Install Image on USB".
> 
> ## Notes
> 
> - Download 3K: ["How to shrink a disk volume beyond the point where any unmovable files are located"](http://www.download3k.com/articles/How-to-shrink-a-disk-volume-beyond-the-point-where-any-unmovable-files-are-located-00432)
> - SuperUser Forum: ["How to shrink Windows 7 boot partition with unmovable files"](http://superuser.com/questions/88131/how-to-shrink-windows-7-boot-partition-with-unmovable-files)
> - Gizmodo UK: ["Windows 10 Privacy Settings: What You Need to Know"](http://www.gizmodo.co.uk/2015/11/windows-10-privacy-settings-what-you-need-to-know/)
> - Ubuntu Forums: ["shrinking Windows 8 partition for dual boot"](http://ubuntuforums.org/showthread.php?t=2087466#post_message_12372055)
> - Liberian Geek: ["Shrink / Resize Partitions in Windows 8"](http://www.liberiangeek.net/2012/11/shrink-resize-partitions-in-windows-8/)
> - WindowsCentral: ["How to prepare your PC for the Windows 10 upgrade"](http://www.windowscentral.com/how-prepare-your-pc-windows-10-upgrade) (see section "Making space for the upgrade")
> - AddictiveTips: ["How To Enable Windows 8 Hibernate Option"](http://www.addictivetips.com/windows-tips/how-to-enable-windows-8-hibernate-option/)
> - Winaero: ["Add Hibernate to the Start Menu in Windows 10"](http://winaero.com/blog/add-hibernate-to-the-start-menu-in-windows-10/)
> 
> ArchLinux Wiki:["Windows and Arch Dual Boot: Fast Start-Up"](https://wiki.archlinux.org/index.php/Windows_and_Arch_Dual_Boot#Fast_Start-Up)

[User:Sakaki/Sakaki's EFI Install Guide/Creating and Booting the Minimal-Install Image on USB - Gentoo Wiki](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB)

> # User:Sakaki/Sakaki's EFI Install Guide/Creating and Booting the Minimal-Install Image on USB
> 
> From Gentoo Wiki
> 
> < [User:Sakaki](https://wiki.gentoo.org/wiki/User:Sakaki)‎ | [Sakaki's EFI Install Guide](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide)
> 
> [Jump to:navigation](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#mw-head) [Jump to:search](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#searchInput)
> 
> We can now proceed to download, verify and use the Gentoo minimal install image. This is a bootable, self-contained Linux system [ISO disk image](https://en.wikipedia.org/wiki/ISO_image), updated regularly by Gentoo Release Engineering. As the name suggests, you can boot your target PC with it and, assuming you have internet access, parlay from there to a full Gentoo installation.
> 
> This section shadows [Chapter 2](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media) of the Gentoo handbook.
> 
> **Note**
> For simplicity, I'll assume you're doing this on your secondary, *helper* PC, which is running Linux. I'll denote that machine as pc2 in the command prompts.
> 
> ## Contents
> 
> - [1 Downloading and Verifying the ISO Image](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#Downloading_and_Verifying_the_ISO_Image)
> - [2 Copying the ISO Image to USB](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#Copying_the_ISO_Image_to_USB)
> - [3 Booting the ISO Image](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#Booting_the_ISO_Image)
> - [4 Setting the Date and Time](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#Setting_the_Date_and_Time)
> - [5 Next Steps](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#Next_Steps)
> - [6 Notes](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#Notes)
> 
> ## Downloading and Verifying the ISO Image
> 
> Firstly, identify the name of the current release of the minimal install ISO (we'll refer to it using the generic form install-amd64-minimal-YYYYMMDDThhmmssZ.iso below). New versions come out multiple times per year. Open the link http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-iso.txt in a browser to determine the current name.
> 
> **Important**
> Be sure to use an up-to-date version of this image: those issued *prior* to August 2018 only support booting in legacy, not EFI, mode,[[1\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#cite_note-min_install_no_efi-1)[[2\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#cite_note-2) and so are unsuitable for use with this tutorial.[[3\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#cite_note-adapt_legacy_images-3)
> 
> **Note**
> The variant part of the name is a *timestamp* — the first component of which is a date, then a 'T' separator, then a time, then finally a 'Z' (to denote UTC, or 'zero hours offset'). So for example, a real filename might be install-amd64-minimal-20180107T214502Z.iso, indicating that it was written at 9:45pm (and 2 seconds), on the 7th of January 2018.
> 
> **Note**
> We'll be using the amd64 architecture (processor family) in what follows. The reference to 'amd' is an [historical artifact](https://wiki.gentoo.org/wiki/AMD64/FAQ); *all* modern 64-bit x86 CPUs (including those from Intel) should use this architecture in Gentoo.
> 
> Open a terminal window on the helper PC, and download the necessary files (the ISO, a contents list for that ISO, and a signed digest list):
> 
> ```
> user@pc2 $``cd /tmp
> user@pc2 $``wget -c http://distfiles.gentoo.org/releases/amd64/autobuilds/YYYYMMDDThhmmssZ/install-amd64-minimal-YYYYMMDDThhmmssZ.iso
> user@pc2 $``wget -c http://distfiles.gentoo.org/releases/amd64/autobuilds/YYYYMMDDThhmmssZ/install-amd64-minimal-YYYYMMDDThhmmssZ.iso.CONTENTS
> user@pc2 $``wget -c http://distfiles.gentoo.org/releases/amd64/autobuilds/YYYYMMDDThhmmssZ/install-amd64-minimal-YYYYMMDDThhmmssZ.iso.DIGESTS.asc
> ```
> 
> **Note**
> Of course, substitute the correct release timestamp (which you just looked up) for `YYYYMMDDThhmmssZ` in the above commands.
> 
> This may take a little time to complete, depending on the speed of your Internet link.
> 
> We next need to check the integrity of the ISO, before using it. The install-amd64-minimal-YYYYMMDDThhmmssZ.iso.DIGESTS.asc file contains cryptographically signed digests (using various hash algorithms) for two other files you have downloaded.
> 
> As such, to verify the ISO we must:
> 
> 1. download the public key used for Gentoo automated weekly releases (if you don't already have this on your helper PC);
> 2. check the signature of the install-amd64-minimal-YYYYMMDDThhmmssZ.iso.DIGESTS.asc file using this key; and then
> 3. check that the hashes (digests) contained in that file agree with values that we compute independently.
> 
> **Note**
> For a brief primer on digital signatures, see the ["Configuring Secure Boot"](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot#digital_signatures_primer) chapter of this tutorial.
> 
> The fingerprint of the automated weekly release public key may be found on the [Gentoo Release Engineering](https://wiki.gentoo.org/wiki/Project:RelEng) page. When requesting the key from a keyserver, you don't need to cite the whole fingerprint, just enough of it to be unambiguous. For example, at the time of writing, the automated release key fingerprint was 13EB BDBE DE7A 1277 5DFD B1BA BB57 2E0E 2D18 2910, so to download it (step 1 in the above list), issue:
> 
> ```
> user@pc2 $``gpg --keyserver pool.sks-keyservers.net --recv-key 2D182910
> ```
> 
> **Note**
> If this command fails, ensure you have enabled outbound access on your firewall for port 11371/tcp to allow [HKP](https://en.wikipedia.org/wiki/Key_server_(cryptographic)) communication, along with the usual state-tracking input rule.
> Alternatively, you can use the following command, to fetch the key over port 80 (which should be open on most firewalls):
> 
> ```
> user@pc2 $``gpg --keyserver hkp://pool.sks-keyservers.net:80 --recv-key 2D182910
> ```
> 
> **Note**
> If the above keyserver is unavailable for some reason, you should be able to use any other one, such as pgp.mit.edu for example.
> 
> **Note**
> If the fingerprint has changed, substitute the correct value for `2D182910` in the above.
> 
> You should next verify that the key's *full* fingerprint matches that listed on the [Release Engineering](https://wiki.gentoo.org/wiki/Project:RelEng#Keys) page:
> 
> ```
> user@pc2 $``gpg --fingerprint 2D182910
> ```
> 
> pub rsa4096 2009-08-25 [SC] [expires: 2020-07-01] 13EB BDBE DE7A 1277 5DFD B1BA BB57 2E0E 2D18 2910 uid [ unknown] Gentoo Linux Release Engineering (Automated Weekly Release Key) [releng@gentoo.org](mailto:releng@gentoo.org) sub rsa2048 2019-02-23 [S] [expires: 2020-07-01]
> 
> **Note**
> Although correct at the time of writing, the key ID you need to enter in the above command may differ from `2D182910`, as may the fingerprint data shown. Always use the [Release Engineering](https://wiki.gentoo.org/wiki/Project:RelEng#Keys) page data as your primary reference.
> 
> If all looks good, use the gpg program to verify the digest file (step 2):
> 
> ```
> user@pc2 $``gpg --verify install-amd64-minimal-YYYYMMDDThhmmssZ.iso.DIGESTS.asc
> ```
> 
> **Note**
> Substitute the correct release timestamp for `YYYYMMDDThhmmssZ` in the above command.
> 
> **Note**
> You can ignore gpg output such as:
> 
> ```
> gpg: WARNING: This key is not certified with a trusted signature! gpg: There is no indication that the signature belongs to the owner.
> ```
> 
> This is normal since you have just imported the public key, and not yet 'trusted' it.[[4\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#cite_note-4)
> 
> Assuming that worked (the output reports 'Good signature'), next check the digests themselves (step 3); we'll use the SHA512 variants here:
> 
> ```
> user@pc2 $``awk '/SHA512 HASH/{getline;print}' install-amd64-minimal-YYYYMMDDThhmmssZ.iso.DIGESTS.asc | sha512sum --check
> ```
> 
> **Note**
> Substitute the correct release timestamp for `YYYYMMDDThhmmssZ` in the above command.
> 
> If this outputs:
> 
> ```
> install-amd64-minimal-YYYYMMDDThhmmssZ.iso: OK install-amd64-minimal-YYYYMMDDThhmmssZ.iso.CONTENTS: OK
> ```
> 
> then continue, all is well.
> 
> ## Copying the ISO Image to USB
> 
> Next, we need to copy the ISO onto a USB key (the image is already hybrid[[5\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#cite_note-5)).
> 
> Just before inserting the USB key (the [larger one](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites#two_usb_keys)) into the helper pc, issue:
> 
> ```
> user@pc2 $``lsblk
> ```
> 
> Note the output, then insert the USB key, and issue:
> 
> ```
> user@pc2 $``lsblk
> ```
> 
> again. The change in output will show you the key's device path (note that the initial /dev/ prefix is not shown in the lsblk output). We will refer to this path in these instructions as **/dev/sdX**, but in reality on your system it will be something like /dev/sdb, /dev/sdc etc.
> 
> **Important**
> If the device has automounted, and lsblk shows that the device has a non-blank mountpoint for one or more of its partitions, you must unmount these, using umount, before proceeding.
> 
> For example, suppose the USB key showed up as /dev/sdb on your system, and its first partition /dev/sdb1 automounted (at /var/run/media/user/myusbkey or some similar path). Then you would issue:
> 
> ```
> user@pc2 $``umount --verbose /dev/sdb1
> ```
> 
> to unmount it.
> 
> If you have problems, you may need to run the umount as the root user.
> 
> Next, we will write the ISO image to the USB key. This will require root access, so issue:
> 
> ```
> user@pc2 $``su --login root
> ```
> 
> Password: <enter root password (on helper PC)>
> 
> Now you can write the ISO image to the USB key (note, we use a larger than default block size here, for efficiency). Issue:
> 
> ```
> root@pc2 #``dd if=/tmp/install-amd64-minimal-YYYYMMDDThhmmssZ.iso of=/dev/sdX bs=8192k status=progress && sync
> ```
> 
> Wait for the process to complete before continuing.
> 
> **Warning**
> This will wipe everything on the USB key. Double check that there is nothing on there you want before proceeding. Make **sure** you have the correct device path! Note also that we need to target the device itself, and not a partition within it, so for /dev/sdX in the above command, use e.g. /dev/sdb and *not* /dev/sdb1; /dev/sdc and *not* /dev/sdc1, etc.
> 
> **Note**
> Substitute the correct release timestamp for `YYYYMMDDThhmmssZ` in the above command.
> 
> **Note**
> You can safely omit the `status=progress` option, if it not supported in your version of dd.
> 
> ## Booting the ISO Image
> 
> Modern Gentoo minimal install images *can* be booted under EFI (as well as 'legacy' / [CSM](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface#CSM_booting) mode), but do *not* support secure boot. As such, we'll need to bring up your target PC — using the USB key you just set up — under UEFI but with secure boot temporarily disabled (of course, the kernel we'll ultimately create *will* secure boot under EFI).
> 
> So, to proceed, take the USB key from the helper PC (where we just dd'd it) and insert it into the target PC. The latter is still running Windows, and you need to reboot it into the BIOS setup GUI. There are two ways to do this; choose the one that suits you:
> 
> *Either:* Use Windows boot options menu.
> 
> This is the easier method (particularly if your target machine is using the 'fast boot' option with Windows).[[6\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#cite_note-6) In Windows, hit CtrlAltDelete, then click on the power icon at the bottom right of the screen, and then *while holding down* Shift, click 'Restart' from the pop-up menu. This will pass you into the Windows boot options menu. Once this comes up (and asks you to 'Choose an option'), click on the 'Troubleshoot' tile, which brings up the 'Advanced options' panel (in Windows 10, you have to click on the 'Advanced options' tile to show this): from this, click on 'UEFI Firmware Settings', and confirm if prompted. Your machine will then restart into the BIOS GUI directly (no hotkeys required) and you can proceed.
> 
> *Or:* Use the BIOS hotkey.
> 
> This is a less reliable method, since you are racing the OS loading process. To use it, hit CtrlAltDelete from within Windows, then click on the power icon at the bottom right of the screen, and choose 'Restart' from the pop-up menu to perform a regular restart. Then, *immediately* the target PC starts to come back up, press the appropriate hotkey to enter the BIOS setup GUI. Unfortunately, the required hotkey varies greatly from machine to machine (as does the BIOS user interface itself). On the Panasonic CF-AX3, press F2 during startup (you may need to press it repeatedly).
> 
> Once you have the BIOS configuration GUI up, you need to perform the following steps:
> 
> 1. disable legacy / CSM boot mode (if available and currently the active default);
> 2. enable EFI boot mode (if not already the active default);
> 3. ensure any 'fast boot' / 'ultra fast boot' options (if present) are disabled (as these may cause USB to be disabled until the operating system comes up);
> 4. turn off secure boot (for the reason noted [above](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB#image_restrictions));
> 5. select the Gentoo minimal install USB key as the highest priority UEFI boot device; and
> 6. restart your machine (saving changes).
> 
> It's impossible to be precise about the GUI actions required to achieve the above, as they will vary from BIOS to BIOS. However, to give you an idea, here's how you would go about it on the Panasonic CF-AX3 (which has an AMT BIOS).
> 
> Use the arrow keys to move to the 'Boot' tab. Then, navigate down to the 'UEFI Boot' item, and press Enter. In the popup that appears, select 'Enabled' using the arrow keys, and press Enter. This switches the system out of legacy / CSM boot and into standard UEFI mode (steps 1 and 2 in the list above):
> 
> Ensuring UEFI Boot Mode Selected
> 
> **Note**
> If your target system was already *in* UEFI mode (quite likely for a modern system running Windows), then you will have nothing to do here. Similarly, some PCs (for example, ultra-compacts) do not support legacy boot at all (in which case you can, of course, safely skip the above step).
> 
> Next, if you have a 'Fast Boot' / 'Ultra Fast Boot' option in your BIOS, you should turn it off at this point (step 3 in the list); as this *may* cause USB devices to be disabled at boot time. The Panasonic has the choice of 'Normal' (as here) or 'Compatible' boot modes; 'Normal' does allow boot from USB and works with the USB keys I used, but if you have problems (and the same BIOS), you could try switching this to 'Compatible' instead).
> 
> Then (step 4), we'll turn off [secure boot](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface#Secure_boot), since the Gentoo minimal install image isn't signed with a Microsoft-sanctioned key (don't worry, we'll set up our own secure-boot keystore later in the tutorial). On the CF-AX3, use the arrow keys to select the 'Security' tab, then navigate down to the 'Secure Boot' item, and select it by pressing Enter. This enters a 'Security' sub-page; navigate to the 'Secure Boot control' item, and press Enter. In the popup that appears, select 'Disabled' using the arrow keys, and press Enter:
> 
> (Temporarily) Disabling Secure Boot
> 
> Next, on the CF-AX3, *if* your machine was *originally* in CSM / legacy boot mode during step 1 above, it is necessary to restart the machine at this point (as it will not pick up valid UEFI boot devices immediately upon switching into UEFI boot mode). Again, the method to achieve this varies from machine to machine; on the Panasonic's BIOS, hit F10 to restart, and confirm if prompted.
> 
> **Note**
> If your machine was *already* in UEFI boot mode during step 1 (likely for modern Windows machines) you may safely skip the above restart.
> 
> **Tip**
> Many BIOSes behave in this manner, and must be restarted when changing from CSM/legacy to UEFI boot (and *vice versa*), before all BIOS boot options relevant to that new mode can be specified.
> 
> When the machine restarts, hit F2 again, to re-enter BIOS setup.
> 
> Now we can select a boot device (step 5) — if you don't do this, you'll simply be dumped back into Windows when you restart. Using the arrow keys, navigate to the 'Boot' tab, and then down to the 'UEFI Priorities' item. Press Enter, and a sub-page is displayed. Ensure the item 'UEFI Boot from USB' is enabled (if it isn't, enable it now, and then press F10 to restart (confirming if prompted), and come back to this point). Navigate down to 'Boot Option #1' and press Enter. In the pop-up menu that appears, select your (Gentoo minimal install) USB key, and press Enter to select it:
> 
> Making Our Minimal Install USB Key the First Boot Option
> 
> **Note**
> The item that *you* need to select from this menu will of course depend the make and model of your minimal install USB key.
> 
> **Note**
> With *some* BIOSes you will also have to specify which *file* on the chosen USB device to boot - if so, you should enter (or select) /EFI/Boot/bootx64.efi (most BIOSes however will *not* require this, as this path is the EFI default).
> 
> That's it! Now press F10 to restart (step 6; the required method varies from BIOS to BIOS), and confirm if prompted.
> 
> Hopefully, after a short delay you'll be presented with a [GRUB](https://en.wikipedia.org/wiki/GNU_GRUB) boot screen. Unless you want to enter custom options — which most users will not — simply press Enter to proceed. After a few seconds (and before you are provided with a command prompt), you'll be asked to choose a keymap. It's important, particularly on a machine with non-standard keyboard layout such as the CF-AX3, to get this right, otherwise you may have problems with passwords and so forth. Again, the correct map to choose will obviously depend on your machine but, on the Panasonic CF-AX3, press 22Enter to select the Japanese keymap.
> 
> A few seconds later, you should have a Gentoo Linux root command prompt! Now, we'll set-up a root password (this is only for use during the install, it will not persist across into the final system).
> 
> ```
> livecd ~ #``passwd root
> ```
> 
> New password:  Retype new password:  passwd: password updated successfully
> 
> Make a note of the password, as you will require it shortly.
> 
> ## Setting the Date and Time
> 
> It's important to ensure that you have the correct time and date on your target machine. Check it with:
> 
> ```
> livecd ~ #``date
> ```
> 
> Per the handbook, you should stick with [UTC](https://en.wikipedia.org/wiki/UTC) for now (the real timezone specification will come later in the install). If necessary, set the date and time, in MMDDhhmmYYYY format (**M**onth, **D**ay, **h**our, **m**inute, **y**ear):
> 
> ```
> livecd ~ #``date MMDDhhmmYYYY
> ```
> 
> **Note**
> Substitute `MMDDhhmmYYYY` in the above with the correct date/time string. For example, to set the UTC date/time to 5:12pm on February 9th 2017, you would issue
> 
> ```
> livecd ~ #``date 020917122017
> ```
> 
> ## Next Steps
> 
> Next, we'll setup the network and get an SSH daemon running. [Click here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh) to go to the next chapter, "Setting Up Networking and Connecting via ssh".
> 
> ## Notes
> 
> - Gentoo Forums: ["The Gentoo minimal installation CD doesn't boot in UEFI"](https://forums.gentoo.org/viewtopic-t-1041178.html)
> - Gentoo Forums: ["Gentoo Minimal ISO EFI Boot?"](http://forums.gentoo.org/viewtopic-t-967098-start-0.html#7377910)
> - Advanced users: it *is* possible to *adapt* legacy images so they will boot on EFI, as I describe [here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Booting_Legacy_Images_on_EFI_using_kexec).
> - Information Security Stack Exchange: ["Ways to sign gpg public key so it is trusted?"](http://security.stackexchange.com/questions/6841/ways-to-sign-gpg-public-key-so-it-is-trusted)
> - SuperUser Forum: ["How do I determine if an ISO is a hybrid?"](http://superuser.com/questions/683210/how-do-i-determine-if-an-iso-is-a-hybrid#683232)
> 
> Hoffman, Chris. ["How To Access The BIOS On A Windows 8 Computer"](http://www.makeuseof.com/tag/how-to-access-the-bios-on-a-windows-8-computer/)

[User:Sakaki/Sakaki's EFI Install Guide/Setting Up Networking and Connecting via ssh - Gentoo Wiki](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh)

> # User:Sakaki/Sakaki's EFI Install Guide/Setting Up Networking and Connecting via ssh
> 
> From Gentoo Wiki
> 
> < [User:Sakaki](https://wiki.gentoo.org/wiki/User:Sakaki)‎ | [Sakaki's EFI Install Guide](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide)
> 
> [Jump to:navigation](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#mw-head) [Jump to:search](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#searchInput)
> 
> Having successfully booted our target PC with the Gentoo minimal install image, our next task is to establish network connectivity for it.
> 
> Once that is done, we'll connect in remotely to the target, from the helper PC, via ssh. This will make subsequent installation steps (such as the copy/paste of lengthy commands) much easier.
> 
> This section shadows [Chapter 3](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking) of the Gentoo handbook.
> 
> ## Contents
> 
> - 1 Getting Networking Running
>   - [1.1 Connecting via Wired Ethernet](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#Connecting_via_Wired_Ethernet)
>   - [1.2 Connecting via WiFi (WPA/WPA2)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#Connecting_via_WiFi_.28WPA.2FWPA2.29)
> - [2 Connecting via ssh and Using screen](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#Connecting_via_ssh_and_Using_screen)
> - [3 Next Steps](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#Next_Steps)
> - [4 Notes](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#Notes)
> 
> ## Getting Networking Running
> 
> Decide whether you wish to perform the install using a wired Ethernet connection, or over WiFi (using [WPA/WPA2](https://en.wikipedia.org/wiki/Wi-Fi_Protected_Access)), and follow the appropriate instructions below. In both cases, the presence of a [DHCP](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) server on the subnet will be assumed.
> 
> **Note**
> If you need to use a fixed IP address, a proxy, IPv6, or an unencrypted WiFi connection, please see [Chapter 3](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking) of the Gentoo handbook for more details.
> 
> ### Connecting via Wired Ethernet
> 
> This is the easier option, if your machine physically supports it. To proceed, plug an ethernet cable into the target machine now, and hook it up to your network (into the back of your cable or ADSL router etc.). Wait for a minute or so (for DHCP to allocate you an address), then (at the keyboard of your target PC) enter:
> 
> ```
> livecd ~ #``ifconfig
> ```
> 
> enp0s25: flags=4163<UP,BROADCAST,RUNNING,MULTICAST> mtu 1500 inet 192.168.1.106 netmask 255.255.255.0 broadcast 192.168.1.255 ... etc ...
> 
> Hopefully, it will have autoconfigured an interface, as above. In the old days, you'd be looking for eth0 in the output of this command, but things have now changed [[1\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#cite_note-predictable_names-1) (to ensure device naming stability across reboots), so your wired ethernet interface name will probably be something a bit stranger-sounding, such as enp0s25 (as is the case here). You are looking for the 'inet' (assuming IPv4) entry; in this case 192.168.1.106 (yours will almost certainly differ).
> 
> If that was successful, then try:
> 
> ```
> livecd ~ #``ping -c 3 www.gentoo.org
> ```
> 
> If this works, it demonstrates that you have a functioning network connection, with working DNS name resolution.
> 
> When ready, [click here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#setup_ssh_server) to jump to the next section of the tutorial.
> 
> ### Connecting via WiFi (WPA/WPA2)
> 
> If your PC has no Ethernet port, you'll have to perform the installation over WiFi. First, check that your PC's adaptor has driver support in the minimal-install image. Issue:
> 
> ```
> livecd ~ #``iwconfig
> ```
> 
> wlp2s0 IEEE 802.11abgn ESSID:off/any Mode:Managed Access Point: Not-Associated Tx-Power=0 dBm Retry long limit:7 RTS thr:off Fragment thr:off Encryption key:off Power Management: on
> 
> lo no wireless extensions.
> 
> Your results will differ from the above, but you're looking for a record starting with **wl**, as this is a wireless adaptor. In this example, the predictable network interface name[[1\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#cite_note-predictable_names-1) of the WiFi adaptor is wlp2s0; take a note of the particular name reported in your case.
> 
> **Note**
> If you see no records beginning with wl, then you will not be able to install the system wirelessly. Use a wired adaptor if your machine has one, or purchase a supported USB to Ethernet (or WiFi) adaptor, and use that.
> Most machines do have driver support in the minimal install image, however.
> 
> Next, we'll need to create a configuration file, to allow the wpa_supplicant program to handle the encrypted network connection. You'll need to know your WiFi access point's [ESSID](https://en.wikipedia.org/wiki/Service_set_(802.11_network)) (the name you'd see when connecting to it via your phone etc.) and its WPA (or WPA2) passphrase. Issue:[[2\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#cite_note-2)
> 
> ```
> livecd ~ #``wpa_passphrase "ESSID" > /etc/wpa.conf
> ```
> 
> <then type your WiFi access point passphrase (without quotes) and press Enter>
> 
> **Note**
> Substitute the correct name for `"ESSID"` in the above (`"MyWiFi"`, or whatever it happens to be in your case).
> 
> Lock down the file's access permissions (to root only) and check that its contents look sane. Issue:
> 
> ```
> livecd ~ #``chmod -v 600 /etc/wpa.conf
> livecd ~ #``cat /etc/wpa.conf
> ```
> 
> Assuming that looks OK, we can connect. Issue:
> 
> ```
> livecd ~ #``wpa_supplicant -Dnl80211,wext -iwlp2s0 -c/etc/wpa.conf -B
> ```
> 
> Successfully initialized wpa_supplicant
> 
> **Note**
> Substitute the wireless network interface name you wrote down [a minute ago](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#note_wifi_if_name) for `wlp2s0` in the above command.
> 
> In this command:
> 
> | Option | Description                                                                                                                                                                                                               |
> | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
> | -D     | Specifies the wireless driver name to use. wext is the 'catch all' and will work in most cases; nl80211 is the more modern version that will ultimately replace it. It's fine to specify multiple drivers here, so we do. |
> | -i     | Specifies the interface name (from iwconfig [above](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#note_wifi_if_name)).                                 |
> | -c     | Specifies the configuration file path (as created by wpa_passphrase [above](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#create_wpa_config)).         |
> | -B     | Instructs wpa_supplicant to run in the background.                                                                                                                                                                        |
> 
> Now wait a moment or two, then issue:
> 
> ```
> livecd ~ #``ifconfig wlp2s0
> ```
> 
> wlp2s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST> mtu 1500 inet 192.168.1.106 netmask 255.255.255.0 broadcast 192.168.1.255 ... etc ...
> 
> **Note**
> Substitute the wireless network interface name you wrote down [a minute ago](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#note_wifi_if_name) for `wlp2s0` in the above command.
> 
> Hopefully, it will have connected successfully. You are looking for the 'inet' (assuming IPv4) entry; in this case 192.168.1.106 (yours will almost certainly differ).
> 
> If that was successful, then try:
> 
> ```
> livecd ~ #``ping -c 3 www.gentoo.org
> ```
> 
> If this works, it demonstrates that you have a functioning network connection, with working DNS name resolution.
> 
> ## Connecting via ssh and Using screen
> 
> Our next step is to setup ssh so we can remotely connect and run the install from our helper PC. Still on the target machine console, enter:
> 
> ```
> livecd ~ #``sed -i 's/^#PermitRootLogin.*$/PermitRootLogin yes/' /etc/ssh/sshd_config
> livecd ~ #``/etc/init.d/sshd start
> ```
> 
> **Note**
> From release 7.0 of OpenSSH, the defaults have changed to prohibit password-based login as root, hence the reason we edit the /etc/ssh/sshd_config file above.[[3\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#cite_note-3) (More recent versions of the minimal install image have fixed this issue, but it does not hurt to apply the edit even when using them.)
> 
> Now take note of the RSA and ED25519 fingerprints for the host (which one is used when you try to connect, will depend upon the settings and recency of the system in your helper PC):
> 
> ```
> livecd ~ #``for K in /etc/ssh/ssh_host_*key.pub; do ssh-keygen -l -f "${K}"; done
> ```
> 
> **Note**
> At the time of writing, sshd from the minimal install image does not set up ECDSA keys.
> 
> **Note**
> By default, the above command will now display [SHA-256](https://en.wikipedia.org/wiki/SHA256) fingerprints in [Base64](https://en.wikipedia.org/wiki/Base64) format (as used by more modern versions of the ssh client program); however, if your ssh client still uses [MD5](https://en.wikipedia.org/wiki/MD5) fingerprints, you can display these using the following command instead:
> 
> ```
> livecd ~ #``for K in /etc/ssh/ssh_host_*key.pub; do ssh-keygen -l -E "md5" -f "${K}"; done
> ```
> 
> Next, move back onto the second, helper PC (on the same subnet), and enter:
> 
> ```
> user@pc2 $``sed -i '/^[^[:digit:]]*192.168.1.106[^[:digit:]]/d' ~/.ssh/known_hosts
> user@pc2 $``ssh root@192.168.1.106
> ```
> 
> (The sed command simply removes any record of fingerprints for previous connections to other sshd servers at that IP address, since ssh will refuse to connect if it finds a conflicting one.)
> 
> **Note**
> Of course, substitute whatever IP address you got back from ifconfig for `192.168.1.106` in the above commands.
> 
> **Tip**
> If you have a large number of existing keys in your ~/.ssh directory, you may get a `Too many authentication failures` error when attempting to connect. In this case (which will not affect most users), simply add the `-o PubkeyAuthentication=no` option to your ssh command.[[4\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#cite_note-4)
> 
> Check the reported key fingerprint and then, if it matches one you noted earlier, continue as below:
> 
> ```
> ... additional output suppressed ... Are you sure you want to continue connecting (yes/no)? <type 'yes', then Enter> ... additional output suppressed ... Password: <enter root password you just set> ... additional output suppressed ...
> ```
> 
> You should find that you can continue configuring remotely, which is much more convenient (as you will have a full windowing environment with graphical web browser, copy and paste, and so on).
> 
> **Note**
> Assuming you are using DHCP, if you have to reboot your machine during the following process, bear in mind that it may not come back up with the same address (although with many DHCP setups, it will).
> 
> Now, still via this remote login ssh connection (i.e., at the helper PC's keyboard), issue:
> 
> ```
> livecd ~ #``screen
> ```
> 
> to start a new [screen](https://en.wikipedia.org/wiki/GNU_Screen) session - this is useful as it allows you to multiplex several virtual consoles, disconnect while lengthy compiles are running and then reconnect later, and so on.
> 
> **Note**
> With some (helper-PC-side) terminals, you may get an error issued when trying to run screen, of the form `Cannot find terminfo entry for 'xxx'`.[[5\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh#cite_note-5)
> If this happens, simply try again with:
> 
> ```
> livecd ~ #``TERM=xterm-color screen
> ```
> 
> **Note**
> See [this brief discussion](https://library.linode.com/linux-tools/utilities/screen) of how to use screen. And here is an even briefer overview of some commands you may find useful to get you started: Ctrla is the *escape character* for screen, which you type and then follow up with the rest of the command if necessary; so for example Ctrla *then* ? to get help, Ctrla *then* d to detach the current session (disconnect from it from your ssh console, leaving any active commands to run in the background), Ctrla *then* c to create a new 'window', Ctrla *then* " (that's a double quote) to list the current windows, Ctrla *then* n to go to the next window and Ctrla *then* p to go to the previous window. If you disconnect, you can reconnect to your session from a console (either when logged in via ssh, or directly on the machine's console itself) using
> 
> ```
> root #``screen -D -R
> ```
> 
> You can also use this command to reconnect to a screen session if e.g. your ssh connection gets dropped for some reason.
> 
> ## Next Steps
> 
> Next, we'll prepare the storage on the target machine. [Click here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key) to go to the next chapter, "Preparing the LUKS-LVM Filesystem and Boot USB Key".
> 
> ## Notes
> 
> - freedesktop.org: [Predictable Network Interface Names](http://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames)
> - Linux.icydog.net Blog: ["Command line WPA"](http://linux.icydog.net/wpa.php)
> - OpenSSH Unix Announce: [OpenSSH 7.0 released](http://lists.mindrot.org/pipermail/openssh-unix-announce/2015-August/000122.html)
> - Server Fault: ["How to recover from 'Too many Authentication Failures for user root'"](https://serverfault.com/questions/36291/how-to-recover-from-too-many-authentication-failures-for-user-root/540613#540613)
> 
> Stack Overflow: ["Unix screen utility error: Cannot find termcap entry for 'xterm-256color'"](http://stackoverflow.com/questions/10823994/unix-screen-utility-error-cannot-find-termcap-entry-for-xterm-256color)

[User:Sakaki/Sakaki's EFI Install Guide/Preparing the LUKS-LVM Filesystem and Boot USB Key - Gentoo Wiki](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key)

> # User:Sakaki/Sakaki's EFI Install Guide/Preparing the LUKS-LVM Filesystem and Boot USB Key
> 
> From Gentoo Wiki
> 
> < [User:Sakaki](https://wiki.gentoo.org/wiki/User:Sakaki)‎ | [Sakaki's EFI Install Guide](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide)
> 
> [Jump to:navigation](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#mw-head) [Jump to:search](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#searchInput)
> 
> In this section, we'll be shadowing [Chapter 4](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks) of the Gentoo handbook (and, although we're going to start to diverge considerably, you may want to read that chapter before proceeding, as it has some useful background information).
> 
> The process we'll be following here is:
> 
> 1. First, we'll format the smaller USB key ([discussed earlier](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites#two_usb_keys)) so that it can support booting under UEFI (although there'll be no bootable kernel on it, yet). We'll then mount it.
> 2. Next, we'll create a pseudo-random binary blob of key data that will be used to secure the main computer drive, encrypt this with a passphrase using GPG, and store the result on the USB key.
> 3. Then, we will create a new [GPT](https://en.wikipedia.org/wiki/GUID_Partition_Table) (GUID partition table) partition on the target machine's main drive, using the space we [freed up from Windows](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#shrink_windows_partition) earlier in the tutorial.
> 4. We'll then (optionally) overwrite that partition with pseudo-random data.
> 5. Next, we'll format the partition using LUKS (secured with the key data created in step 2).
> 6. We'll then (optionally) add a fallback passphrase to the LUKS container.
> 7. Then, we'll create an LVM physical volume (PV) on the LUKS partition, create an LVM volume group (VG) with just that one physical volume in it, and then create three logical volumes (LVs) (for the Gentoo root, swap and home partitions) utilizing that physical volume.
> 8. Finally, we'll format the logical volumes appropriately, and mount them so that they can be used in the rest of the installation.
> 
> Let's go!
> 
> ## Contents
> 
> - [1 Formatting and Mounting the UEFI-Bootable USB Key](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#Formatting_and_Mounting_the_UEFI-Bootable_USB_Key)
> - [2 Creating a Password-Protected Keyfile for LUKS](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#Creating_a_Password-Protected_Keyfile_for_LUKS)
> - [3 Creating a New GPT Partition on the PC's Main Drive](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#Creating_a_New_GPT_Partition_on_the_PC.27s_Main_Drive)
> - [4 Overwriting the New Partition with Pseudo-Random Data (Optional Step)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#Overwriting_the_New_Partition_with_Pseudo-Random_Data_.28Optional_Step.29)
> - [5 Formatting the New Partition with LUKS](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#Formatting_the_New_Partition_with_LUKS)
> - [6 Adding a Fallback Passphrase (Optional Step)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#Adding_a_Fallback_Passphrase_.28Optional_Step.29)
> - [7 Creating the LVM Structure (PV->VG<-LVs) on Top of LUKS](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#Creating_the_LVM_Structure_.28PV-.3EVG.3C-LVs.29_on_Top_of_LUKS)
> - [8 Formatting and Mounting the LVM Logical Volumes (LVs)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#Formatting_and_Mounting_the_LVM_Logical_Volumes_.28LVs.29)
> - [9 Next Steps](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#Next_Steps)
> - [10 Notes](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#Notes)
> 
> ## Formatting and Mounting the UEFI-Bootable USB Key
> 
> We are going to use our smaller (>= 250 MB) USB key as the boot device for Gentoo Linux. Since we want it to work under UEFI, we must format it using [GPT](https://en.wikipedia.org/wiki/GUID_Partition_Table) with a single fat32 EFI system partition.
> 
> **Warning**
> This process will wipe everything on the USB key, so be sure to back it up if necessary.
> 
> Issue (using of course the ssh / screen terminal we have just established):
> 
> ```
> livecd ~ #``lsblk
> ```
> 
> And note the output. Then, insert the smaller capacity USB key into one of the remaining free USB slots on the target machine, and determine its device path. We will refer to its path in these instructions as /dev/sdY, but in reality on your system it will be something like /dev/sdc, /dev/sdd etc. You can find what it is, by issuing lsblk again, and noting what has changed:
> 
> ```
> livecd ~ #``lsblk
> ```
> 
> (note that the initial /dev/ prefix is not shown in the lsblk output)
> 
> The minimal-install image shouldn't auto-mount the USB key, even if it has any existing partitions, but double-check to make sure (no mountpoints for the device should be shown in the output of the above command).
> 
> Now, using parted, we will create a single primary partition, sized so as to fill the USB key completely (you can of course use a more modest extent if your drive is much larger than the minimum required size), and set its [somewhat confusingly named](http://forums.fedoraforum.org/archive/index.php/t-271111.html) 'boot' flag (i.e., mark the partition as a GPT system partition). Issue:
> 
> ```
> livecd ~ #``parted -a optimal /dev/sdY
> ```
> 
> GNU Parted 3.2 ... additional output suppressed ... (parted) mklabel gpt Warning: The existing disk label on /dev/sdY will be destroyed and all data on this disk will be lost. Do you want to continue? Yes/No? yes (parted) mkpart primary fat32 0% 100% (parted) set 1 BOOT on (parted) quit
> 
> **Note**
> Replace /dev/sdY in the above command with the path of the USB key you found above, such as /dev/sdc or /dev/sdd etc.
> 
> Next, we need to format the partition fat32:
> 
> ```
> livecd ~ #``mkfs.vfat -F32 /dev/sdY1
> ```
> 
> **Note**
> Replace /dev/sdY1 in the above command with the path of first partition on the USB key, such as /dev/sdc1 or /dev/sdd1 etc.
> 
> **Tip**
> On some machines, a *new* drive letter will be assigned to the USB key after it has been edited by parted in this fashion. For example, if the drive was /dev/sdc prior to editing, it may become /dev/sdd afterwards. For avoidance of doubt, this issue will **not** affect most users; but, it is simple to check, by using lsblk.
> 
> Now we create a temporary mountpoint and mount the partition:
> 
> ```
> livecd ~ #``mkdir -v /tmp/efiboot
> livecd ~ #``mount -v -t vfat /dev/sdY1 /tmp/efiboot
> ```
> 
> **Note**
> As before, remember to subsitute for /dev/sdY1 in the above.
> 
> ## Creating a Password-Protected Keyfile for LUKS
> 
> We will next create a (pseudo) random keyfile (for use with LUKS). This keyfile will be encrypted with [GPG](https://en.wikipedia.org/wiki/Gnu_Privacy_Guard) (using a typed-in passphrase) and then stored on the USB key.
> 
> The point of this is to establish dual-factor security - both the (encrypted) keyfile, *and* your passphrase (to decrypt it) will be required to access the LUKS data stored on the target machine's hard drive. This means that even if a keylogger is present, should the machine be stolen - powered down but without the USB key - the LUKS data will still be safe (as the thief will not have your encrypted keyfile). Similarly, (assuming no keylogger!) if your machine were to be stolen powered down but with the USB key still in it, it will also not be possible to access your LUKS data (as in this case the thief will not know your passphrase).
> 
> Note that we are going to create a (one byte short of) 8192[KiB](https://en.wikipedia.org/wiki/Kibibyte) underlying (i.e., binary plaintext) keyfile, even though, for the symmetric LUKS cipher we'll be using ([Serpent](https://en.wikipedia.org/wiki/Serpent_(cipher))), the maximum supported key size is 256 bits (32 bytes) (or two 256 bit keys = 512 bits = 64 bytes in XTS mode, as explained later). This works because LUKS / cryptsetup uses the [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2) key derivation function to map the keyfile into the actual (user) key material internally (which in turn is used to unlock the master key actually used for sector encryption / decryption), so we are free, within limits, to choose whatever size keyfile we want. As such, we elect to use the largest legal size, so as to make it (very slightly) harder for any data capture malware (in low-level drivers, for example) to intercept the file and squirrel it away, or transmit it over the network surreptitiously. In theory, the cryptsetup system can support keyfiles up to and including 8192KiB (execute `cryptsetup --help` to verify this); in practice, due to a off-by-one bug, it supports only keyfiles strictly less than 8[MiB](https://en.wikipedia.org/wiki/Mebibyte). We therefore create a keyfile of length (1024 * 8192) - 1 = 8388607 bytes.
> 
> Note that we'll use the [/dev/urandom](https://en.wikipedia.org/wiki//dev/random) source to create the underlying (binary plaintext) pseudo-random keyfile, and then pipe it to gpg to encrypt (using a passphrase of your choosing). The resulting binary ciphertext is saved to the USB key. This avoids ever having the binary plaintext keyfile stored on disk anywhere (and indeed not even you need ever see the unencrypted contents). Enter:
> 
> ```
> livecd ~ #``export GPG_TTY=$(tty)
> livecd ~ #``dd if=/dev/urandom bs=8388607 count=1 | gpg --symmetric --cipher-algo AES256 --output /tmp/efiboot/luks-key.gpg
> ```
> 
> Enter passphrase Passphrase  Please re-enter this passhprase Passphrase  ... further output suppressed ...
> 
> **Note**
> We need to set the GPG_TTY variable here, otherwise gpg's pinentry password system may misbehave. If you are connecting over ssh, and your helper system has locale settings not available within the minimal install environment, you may get complaints about `no LC_CTYPE known` printed by pinentry; these can generally be ignored, and result from sshd on the target machine attempting to use the helper machine's environment.[[1\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-1)
> 
> **Note**
> We are using the symmetric [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard) cipher here with a 256 bit key (derived from your passphrase) to protect the *keyfile*. We'll use a different cipher ([Serpent](https://en.wikipedia.org/wiki/Serpent_(cipher))) in LUKS to protect the hard drive partition. Note also that the /tmp/efiboot/luks_key.gpg file will be larger than 8388607 bytes, due to the GPG 'wrapper'.
> 
> **Warning**
> If you lose the (encrypted) keyfile, or forget the passphrase, it's game over for your LUKS data. Therefore, be sure to backup both keyfile and passphrase (to separate, secure locations).
> 
> What passphrase you choose to protect your LUKS keyfile is, of course, entirely up to you, but do consider the approach of using a longer list of everyday words, rather than the more traditional cryptic str1ng5 @f characters. Advantages include:[[2\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-2)
> 
> - it's easier to hit a reasonable level of entropy;
> - you are less likely to forget the resulting passphrase; and
> - your passphrase will be more robust in the face of keymapping snafus at boot time.
> 
> ## Creating a New GPT Partition on the PC's Main Drive
> 
> Our next task is to create a new GPT partition on the target PC's hard drive (which we [freed up space for earlier](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting#shrink_windows_partition)).
> 
> We will use the parted tool, instruct it to use sectors for units, and then display the free space on the current drive. We'll then create a new primary partition on that drive using all the available space indicated.
> 
> **Warning**
> Please take particular care with this step. parted can cause **catastrophic data loss** if misused and, unlike fdisk, writes changes immediately.
> 
> We must first find the device path of the main hard drive on the target machine. We will refer to this as /dev/sdZ in the following text, but it will be something like /dev/sda, /dev/sdb etc. on your machine. Check the actual path with:
> 
> ```
> livecd ~ #``lsblk
> ```
> 
> If you are dual booting with Windows, you'll probably see that the desired drive has between four and six existing partitions, depending on your version of Windows (note that the initial /dev/ prefix is not shown in the lsblk output). None of these should be mounted (all should have blank mountpoints in the output of lsblk).
> 
> Now we will create the partition:
> 
> ```
> livecd ~ #``parted -a optimal /dev/sdZ
> ```
> 
> GNU Parted 3.1 ... additional output suppressed ... (parted) unit s (parted) print free ... additional output suppressed ... Number Start End Size File system Name Flags ... additional output suppressed ... AAAs BBBs CCCs Free Space (parted) mkpart primary AAAs BBBs (parted) quit
> 
> **Note**
> Replace /dev/sdZ in the above command with the path of the target machine's main drive (the one on which Windows is installed), such as /dev/sda. Note also that we need to target the device itself, and not a partition within it, so for /dev/sdZ in the above command, use e.g. /dev/sda and *not* /dev/sda1; /dev/sdb and *not* /dev/sdb1, etc.
> 
> **Note**
> You should of course also substitute for `AAA` and `BBB`, whatever output is displayed for the boundaries of the free space when you issue the print free. For example, if you got back
> 
> ```
>     89362432s  500118158s  410755727s  Free Space
> ```
> 
> you would issue
> 
> (parted) mkpart primary 89362432s 500118158s
> 
> You can make the partition smaller, if you do not wish to use all of the remaining space for the Gentoo install. It can be useful to reserve some space (<=1[GiB](https://en.wikipedia.org/wiki/Gibibyte), say) for e.g. an emergency recovery partition, but whether to do so is entirely up to you.
> 
> **Note**
> You may see multiple blocks of free space listed (particularly with modern versions of Windows 10; in this case, just use the largest one.
> 
> **Note**
> The suffix 's' in the dimensions passed above tells parted that you are using 'sector' units. Do not omit it!
> 
> **Note**
> If parted complains that your new partition is **not properly aligned for best performance**, you may wish to cancel the mkpart, then try again with modified values: rounding the start address *up* to the nearest 2048, and the end address *down* to the nearest 2048 sectors. For example, if the largest free block prior to creation of the new partition was reported as
> 
> 224107278s 469868543s 245761266s Free Space
> 
> you could do the following on your helper PC to calculate optimal values:
> 
> ```
> user@pc2 $``echo "$((((224107278 + 2047) / 2048) * 2048))s $((469868543 - (469868543 % 2048)))s"
> ```
> 
> 224108544s 469866496s
> 
> so you would issue:
> 
> (parted) mkpart primary 224108544s 469866496s
> 
> Obviously, adapt using the sector start and end addresses for the free space block on your drive! Incidentally, the 'magic number' 2048 is a safe choice for most drives; but you can easily calculate the actual optimal value for your own device, if desired.[[3\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-optimal_partitions-3)
> 
> **Note**
> If the drive you are using has *not* yet been partitioned, the print free command will not output data as above. In such a case, you will need to issue a `mklabel gpt` command within parted first. However, do **not** do this (i.e., issue `mklabel gpt`) on an already-partitioned drive; you will lose all the data on there if you do!
> Users who are targeting a fresh disk in this way may also find it easier to create the partition itself with the parted command `mkpart primary 0% 100%`, as this will deal with all sector alignment issues etc. (Users with existing data on their drives should **not** do this however, but instead follow the commands given in the main text.)
> 
> **Note**
> Additionally, users who are *not* co-installing with Windows may find it useful to create two partitions on /dev/sdZ: the main one as specified above, and a second EFI system partition. This will allow e.g. subsequent migration of the kernel from the boot USB key to the main drive later if desired. Users who *do* intend to dual-boot with Windows should ignore this point: your hard drive already contains an EFI system partition.
> 
> Now check that the partition has been created correctly. We'll issue an lsblk command again:
> 
> ```
> livecd ~ #``lsblk
> ```
> 
> Take note of the new sector device path (note that the initial /dev/ prefix is not shown in the lsblk output). We will refer to this as /dev/sdZn in the below, but it will actually be something like /dev/sda7, /dev/sdb7 etc. If you have a non-standard Windows setup, the number of the new partition may also be something other than 7 (for example, on older Windows 10 and most Windows 8 systems it is more likely to be 5), so do please double check.
> 
> ## Overwriting the New Partition with Pseudo-Random Data (Optional Step)
> 
> You can [skip this step](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#format_luks_partition) if you like. The main reasons to perform an overwrite are:
> 
> - to purge any old, unencrypted data that may still be present in the partition (from prior use); and
> - to make it somewhat harder for an attacker to determine how much data is on your drive if the machine is compromised.
> 
> However, it may make things slower on a solid-state drive, by forcing any new writes to first delete a sector (once any overcapacity has been exceeded), rather than simply writing to a fresh, unused one (and furthermore, it cannot completely be guaranteed that old data *has* been wiped, when using such devices).
> 
> This command may take a number of hours to complete.
> 
> **Warning**
> The step below will **destroy** existing data on the partition; please double check to ensure you have the correct device path (e.g., /dev/sda7 etc.) before continuing.
> 
> ```
> livecd ~ #``dd if=/dev/urandom of=/dev/sdZn bs=1M status=progress && sync
> ```
> 
> **Note**
> Replace /dev/sdZn in the above command with the device path for the partition we just created, e.g., /dev/sda7.
> 
> You will be able to see dd slowly progressing. Wait for it to complete before proceeding to the next step.
> 
> ## Formatting the New Partition with LUKS
> 
> The next step is to format the partition using [LUKS](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup). LUKS, which stands for Linux Unified Key Setup, is as the name suggests primarily a way to manage the encryption keys for whole-partition (or drive) encryption. It does this by first generating a high-entropy, secret, *master key*, which is then encrypted using between one and eight *user keys* (themselves first pre-processed by [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2)).
> 
> The target partition itself begins with a LUKS metadata header, followed by the encrypted master key material corresponding to each of the 8 possible user 'slots', and finally the bulk, encrypted (payload) data itself (the encrypted sector data for the partition).
> 
> The LUKS master key itself is *never* stored in unencrypted form on the partition, nor (unless you explicitly request it) even made visible to you, the user.
> 
> LUKS uses a cryptographic splitting and chaining technique to artificially inflate the size of the key material for each slot into a number of interdependent 'stripes'. This is done to increase the likelihood that, when a slot is modified (a user key is revoked, or changed, for example), that the old key material is, indeed, irrecoverable (necessary, since under LUKS the partition master key is *never* changed once created). Be warned though, that with solid-state drives no guarantees can be given, if you change a user key, that the old key material is not retained on the drive somewhere (due to wear-levelling etc.).[[4\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-4)
> 
> LUKS functions are accessed via the cryptsetup program, and use [dm-crypt](https://wiki.gentoo.org/wiki/Dm-crypt) for the back-end processing. Note that LUKS is agnostic as to the actual symmetric encryption method used, provided it is supported by dm-crypt. You can get a list of the (currently loaded) encryption and hash algorithms by issuing:
> 
> ```
> livecd ~ #``cat /proc/crypto
> ```
> 
> (You may have others available as kernel modules, which will be loaded when required).
> 
> What we need to do is tell cryptsetup:
> 
> - the underlying block cipher we want to use (block ciphers work on fixed-size units, or blocks, of data to encrypt or decrypt at a time),
> - the key length to use with this cipher,
> - the way we'll *tweak* it to en/decrypt amounts of data larger than one cipher block (many ciphers use a 16-byte block, and sectors, the indexing unit, are larger than this),
> - what processing, if any, should be applied to the sector index number during [IV](https://en.wikipedia.org/wiki/Initialization_vector) computation, and
> - the hash algorithm used for key derivation (under the [PBKDF2](https://en.wikipedia.org/wiki/PBKDF2) algorithm within LUKS)
> 
> This isn't a cryptography primer ([see this article](https://en.wikipedia.org/wiki/Disk_encryption_theory) for further reading), but here's a thumbnail justification for the choices made:
> 
> - we will use [Serpent](https://en.wikipedia.org/wiki/Serpent_(cipher)) as the block cipher; this came second in the AES competition [mainly for reasons of speed](http://www.100tb.com/blog/2013/05/security-performance-serpent-cipher-rijndael/), but has a more conservative design (32 rounds as opposed to 14) and scored a higher safety factor when compared to the [Rijndael](https://en.wikipedia.org/wiki/Rijndael) algorithm that won the competition (and which, accordingly, is now commonly referred to as 'AES');
> - for security, we'll use the longest supported key length for Serpent, which is 256 bits (see the following point, however);
> - we will use [XTS](https://en.wikipedia.org/wiki/XEX-TCB-CTS#XEX-based_tweaked-codebook_mode_with_ciphertext_stealing_.28XTS.29) mode to both extend the cipher over multiple blocks within a sector, and perform the by-sector-index 'tweaking'; this approach overcomes the security weakness in the more conventional [CBC](https://en.wikipedia.org/wiki/Cipher_block_chaining#Cipher-block_chaining_.28CBC.29) / [ESSIV](https://en.wikipedia.org/wiki/ESSIV) methodology, whereby an attacker, although unable to read the encrypted material, can yet, if they know the cleartext for that sector (possible for some system files), arbitrarily modify alternating blocks to inject shellcode[[5\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-5); this is a non-trivial concern for a dual-boot machine where the Windows side of things is untrusted (and has access to the encrypted contents of the LUKS partition when running). Note that since XTS mode actually requires *two* keys, we must pass an effective key length of 512 (= 2 x 256) bits to cryptsetup;
> - as XTS is a (modified) *counter* mode, we will simply pass the untransformed ("plain") 64-bit sector index to it (using a 64-bit index will allow for disks > 2TiB);[[6\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-6)
> - we will use [Whirlpool](https://en.wikipedia.org/wiki/Whirlpool_(cryptography)) as the user key hashing function for LUKS' PBKDF2 processing; it is a 512 bit hash that has been recommended by the [NESSIE](https://en.wikipedia.org/wiki/NESSIE) project. Note that Whirlpool hash will appear in the output from /proc/crypto as wp512 (if loaded).
> 
> We decrypt our keyfile from the USB key (using gpg) and pipe it to cryptsetup, to avoid the unencrypted keyfile having to be saved to disk. The `--cipher` and `--hash` strings instruct cryptsetup to use the settings just discussed.
> 
> **Warning**
> The step below will **destroy** existing data on the partition; please double check to ensure you have the correct device path (e.g., /dev/sda7 etc.) before continuing. When you pipe the keyfile in this way, cryptsetup will *not* ask you if you are sure prior to formatting.
> 
> ```
> livecd ~ #``gpg --decrypt /tmp/efiboot/luks-key.gpg | cryptsetup --cipher serpent-xts-plain64 --key-size 512 --hash whirlpool --key-file - luksFormat /dev/sdZn
> ```
> 
> <when prompted, type the passphrase for the gpg keyfile you setup earlier> ... additional output suppressed ...
> 
> **Note**
> Replace /dev/sdZn in the above command with the device path for the partition we just created, e.g., /dev/sda7.
> Also, you *may* see some errors of the form `device-mapper: remove ioctl on XXX failed: Device or resource busy`; these can generally be ignored, provided the luksDump command (described below) works.
> 
> **Note**
> Depending on how soon after first creating the gpg keyfile you issue the above command, you may find that you are not prompted for a passphrase at all. That's because your passphrase has been (temporarily) cached behind the scenes, for convenience, by gpg-agent. If you *want* to force the passphrase prompt (for example to double-check you have the passphrase written down correctly!), you can do so by issuing the following prior to the luksFormat command above:
> 
> ```
> livecd ~ #``echo RELOADAGENT | gpg-connect-agent
> ```
> 
> **Note**
> By default, cryptsetup uses /dev/random as its random number generator (RNG); this *may* run out of entropy when formatting the partition and print a warning; if this happens, just run your finger over the touchpad of the target machine (or move its mouse, if attached) until the process completes.
> 
> **Note**
> If you use the Whirlpool hash (as we have done), be aware that you will not be able to open the LUKS container using [dev-libs/libgcrypt](https://packages.gentoo.org/packages/dev-libs/libgcrypt) < v1.6.0, because of a bug in those earlier versions when writing data to the Whirlpool hash function in chunks.[[7\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-7)
> 
> **Note**
> If you'd rather use a vanilla approach, omit the `--cipher` and `--hash` arguments; cryptsetup will then revert to its compiled-in defaults (which you can see using)
> 
> ```
> livecd ~ #``cryptsetup --help
> ```
> 
> At the time of writing, this implies `aes-xts-plain64`, so [Rijndael](https://en.wikipedia.org/wiki/Rijndael) (AES) rather than [Serpent](https://en.wikipedia.org/wiki/Serpent_(cipher)), with a 256bit key (which really means 2 x 128bit keys, given XTS mode, so less secure than our 512bit (= 2 x 256bit) variant), and SHA1 for the LUKS password hashing, which again is arguably less good than Whirlpool. Ultimately, the choice is yours of course.
> 
> **Note**
> Although you *can* specify an additional hash postfix in the `--cipher` string (e.g. `serpent-xts-plain64:whirlpool` rather than simply `serpent-xts-plain64`), it will be *ignored* by the kernel in plain64 mode.[[8\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-8) As such, you should omit it (as we have done). Remember, this postfix is *only* used to specify the hash function for [IV](https://en.wikipedia.org/wiki/Initialization_vector) processing (if any), and so is relevant in [ESSIV](https://en.wikipedia.org/wiki/ESSIV) mode, for example. It has *nothing* to do with the hash used in the LUKS header, which is specified by the `--hash` argument, as above.
> 
> Check that the formatting worked, with:
> 
> ```
> livecd ~ #``cryptsetup luksDump /dev/sdZn
> ```
> 
> **Note**
> Replace /dev/sdZn in the above command with the device path for the LUKS partition, e.g., /dev/sda7.
> 
> This should print out information about the LUKS setup on the sector, and show that one of the 8 keyslots (slot 0) is now in use (incidentally, pointing out that LUKS does not provide any plausible deniability about the use of encryption! You *can* [detach the header](https://www.kernel.org/pub/linux/utils/cryptsetup/v1.4/v1.4.0-ReleaseNotes) and store it on a separate device, but we won't do that here as it isn't supported in the standard genkernel init scripts that we'll rely on later.).
> 
> **Important**
> If the LUKS header gets damaged, your encrypted data will be lost forever, even if you have a backup of the GPG key and passphrase. Therefore, you may wish to consider backing up this header to a separate device, and storing it securely. See the [LUKS FAQ](https://gitlab.com/cryptsetup/cryptsetup/wikis/FrequentlyAskedQuestions#6-backup-and-data-recovery) for more details on how to do this.
> For example, to save a copy of the current LUKS header to your boot USB key (doing so is optional), you could now issue, per the FAQ:
> 
> ```
> livecd ~ #``cryptsetup luksHeaderBackup /dev/sdZn --header-backup-file /tmp/efiboot/luks-header.img
> ```
> 
> Replace /dev/sdZn in the above command with the device path for the LUKS partition, e.g., /dev/sda7.
> **Be aware** that if you do keep a LUKS header backup in this fashion, and subsequently revoke any of the keyslots, that the old keys will *still* be usable to unlock the LUKS partition, to those with access to that header backup file.
> 
> ## Adding a Fallback Passphrase (Optional Step)
> 
> Since LUKS supports up to 8 user key 'slots', you can, if you wish, add an additional (traditional) passphrase to your LUKS container now. This is not intended for use day-to-day, but simply as a last-resort fallback, should you lose the USB key with the GPG keyfile on it, for example.
> 
> **Warning**
> If you are concerned that your machine might already contain a keylogger, **do not** perform this step; [click here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#create_lvm_structure) to jump to the next task instead.
> 
> **Important**
> If, at the conclusion of the tutorial, you wish to be able to switch to booting *without* using the GPG keyfile, then you *should* setup a fallback passphrase now.
> 
> Unfortunately, the necessary cryptsetup command requires that we provide an existing valid user key in addition to the new one we want to add. If we pipe this in directly from gpg (as we did earlier), then cryptsetup will not prompt correctly for a new passphrase. To get around this issue, without writing the existing GPG key out in binary plaintext form to a disk file, we'll use a [named pipe](http://www.linuxjournal.com/article/2156).
> 
> Assuming you're using screen, hit Ctrla followed by c to start a new virtual console. Then type:
> 
> ```
> livecd ~ #``mkfifo /tmp/gpgpipe
> livecd ~ #``echo RELOADAGENT | gpg-connect-agent
> livecd ~ #``gpg --decrypt /tmp/efiboot/luks-key.gpg | cat - >/tmp/gpgpipe
> ```
> 
> <when prompted, type the passphrase for the gpg keyfile you setup earlier> ... additional output suppressed ...
> 
> (The slightly odd approach of piping via cat is intentional.) This will block once you type in your passphrase, as nothing is connected to the other end our the named pipe (yet). Now switch back to the original virtual console with Ctrla followed by p, and enter:
> 
> ```
> livecd ~ #``cryptsetup --key-file /tmp/gpgpipe luksAddKey /dev/sdZn
> ```
> 
> Enter new passphrase for key slot:  Verify passphrase: 
> 
> **Note**
> Replace /dev/sdZn in the above command with the device path for the LUKS partition, e.g., /dev/sda7.
> 
> Verify that this worked by issuing:
> 
> ```
> livecd ~ #``cryptsetup luksDump /dev/sdZn
> ```
> 
> **Note**
> Replace /dev/sdZn in the above command with the device path for the LUKS partition, e.g., /dev/sda7.
> 
> You should now see slot 1 is enabled, as well as slot 0. Now, remove the named pipe, since we no longer need it:
> 
> ```
> livecd ~ #``rm -vf /tmp/gpgpipe
> ```
> 
> Lastly, switch back to the second virtual console with Ctrla followed by n, and then hit Ctrld to close it out and return to the original console again.
> 
> ## Creating the LVM Structure (PV->VG<-LVs) on Top of LUKS
> 
> Our next step is to set up an LVM structure within the LUKS container we just created. LVM stands for Logical Volume Manager: a useful overview may be found [here](https://wiki.archlinux.org/index.php/LVM), and a handy command cheatsheet [here](http://www.datadisk.co.uk/html_docs/redhat/rh_lvm.htm). It is a highly flexible virtual partition system. Some important LVM terminology is as follows:
> 
> - A physical volume (PV) is an underlying storage device (for example, an actual disk partition or loopback file), which is managed by LVM. PVs have a special header, and are divided into physical extents.
> - A physical extent (PE) is the smallest allocatable unit of a PV. We will use the default PE size of 4MiB in this tutorial.
> - A logical volume (LV) is LVM's equivalent of a partition. It contains *logical extents*, which are mapped one-to-one onto the PEs of contributing physical volumes. Note - unlike a conventional partition, because of this architecture an LV can span multiple underlying physical volumes, and a physical volume can host multiple logical volumes, if desired. The LV appears as a standard block device, and so can be formatted with any normal Linux filesystem (e.g. [ext4](https://wiki.gentoo.org/wiki/Ext4)). We will create LVs for the root directory, the user home directory and swap in this tutorial.
> - A volume group (VG) is an administrative unit gathering together a collection of LVs and PVs. We will create a single VG containing a single PV, and (as just mentioned) three LVs.
> 
> The main reason we're using LVM here is to provide a simple way to get three 'logical' partitions on top of a single underlying LUKS container (partition). LVM also provides a number of additional advantages when resizing, backing up, or moving partitions, in exchange for a little initial configuration overhead.[[9\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-9)
> 
> To proceed with LVM, the first thing we need to do is *open* the LUKS volume we just created, as it will host our single PV. Issue:
> 
> ```
> livecd ~ #``gpg --decrypt /tmp/efiboot/luks-key.gpg | cryptsetup --key-file - luksOpen /dev/sdZn gentoo
> ```
> 
> Enter passphrase ... additional output suppressed ...
> 
> **Note**
> Replace /dev/sdZn in the above command with the device path for the LUKS partition, e.g., /dev/sda7.
> 
> **Note**
> Depending on how soon after last decrypting the gpg keyfile you issue the above command, you may find that you are not prompted for a passphrase at all. That's because your passphrase has been (temporarily) cached behind the scenes, for convenience, by gpg-agent. If you *want* to force the passphrase prompt (for example to double-check you have the passphrase written down correctly!), you can do so by issuing the following prior to the luksOpen command above:
> 
> ```
> livecd ~ #``echo RELOADAGENT | gpg-connect-agent
> ```
> 
> Check that this worked:
> 
> ```
> livecd ~ #``ls /dev/mapper
> ```
> 
> control gentoo
> 
> You should see the device 'gentoo' in the device mapper list, as above. This is our unlocked LUKS partition.
> 
> Next, we'll create an LVM physical volume (PV) on this partition:
> 
> ```
> livecd ~ #``pvcreate /dev/mapper/gentoo
> ```
> 
> **Note**
> If you see a warning such as:
> 
> ```
> /run/lvm/lvmetad.socket: connect failed: No such file or directory WARNING: Failed to connect to lvmetad. Falling back to internal scanning.
> ```
> 
> when running this or subsequent LVM commands, it may generally safely be ignored.
> 
> Then, we create a volume group (VG) hosting this PV. We'll call the new VG "vg1". Note that since we're using lvm2 format here, there's no need to set a larger physical extent size - the default of 4MiB per PE will be fine [[10\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-10):
> 
> ```
> livecd ~ #``vgcreate vg1 /dev/mapper/gentoo
> ```
> 
> **Important**
> Please use the suggested VG name (vg1), since this is assumed by the buildkernel utility later. If you do need to change it, you'll need to override CMDLINE_REAL_ROOT and CMDLINE_REAL_RESUME variables appropriately in /etc/buildkernel.conf [later in the tutorial](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_and_Building_the_Kernel#deal_with_different_vg_name).
> 
> Now, we'll create three logical volumes (LVs) in this volume group. The first is for swap. To allow the use of suspend to disk (which we'll setup [later](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Final_Configuration_Steps#suspend_hibernate)) we'll want a swap slightly larger than the size of our RAM. So first, find the size of RAM on your system with:
> 
> ```
> livecd ~ #``grep MemTotal /proc/meminfo
> ```
> 
> In the case of the CF-AX3, this shows just under 8[GiB](https://en.wikipedia.org/wiki/Gibibyte), hence we'll allocate 10GiB. Adjust this for your system and preferences. If you don't want to use suspend to disk, a much smaller swap would work just as well.
> 
> ```
> livecd ~ #``lvcreate --size 10G --name swap vg1
> ```
> 
> **Note**
> LVM uses base-2 units, so this is 10GiB. Adjust the size to suit your system, as described above.
> 
> **Note**
> If lvcreate complains about not being able to wipe the start of the LV, try adding the `-Z n` parameter to the previous command. Supposedly it is dangerous to mount an LV whose first few kilobytes haven't been wiped, but then again, you'll be formatting your LV with a filesystem.
> 
> Next, we'll create a relatively large LV to hold our root partition. This will eventually hold everything apart from the user home directories, and, since this is Gentoo, we'll need a fair amount of room for portage files and so on. We'll allow 50GiB here - if you wish you can make this smaller or larger of course:
> 
> ```
> livecd ~ #``lvcreate --size 50G --name root vg1
> ```
> 
> **Note**
> LVM uses base-2 units, so this is 50GiB. Adjust the size to suit your needs, as described above.
> 
> Finally, let's create a third LV to hold the user home directories. We'll instruct LVM to use almost all the remaining space on the LUKS container for this, leaving 5% of the (so far unused space) free (this additional room will come in useful if you want to take a snapshot[[11\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#cite_note-11) later, for example).
> 
> ```
> livecd ~ #``lvcreate --extents 95%FREE --name home vg1
> ```
> 
> You should now be able to look at the status of the physical volume (PV), volume group (VG) and logical volumes (LVs), as follows:
> 
> ```
> livecd ~ #``pvdisplay
> livecd ~ #``vgdisplay
> livecd ~ #``lvdisplay
> ```
> 
> The final task in this step is to 'activate' the new volume group (vg1) so that it's logical volumes become available as block devices via the device mapper. Issue:
> 
> ```
> livecd ~ #``vgchange --available y
> ```
> 
> This should inform you that three LVs in the vg1 volume group have been activated. Check that they are visible via the device mapper:
> 
> ```
> livecd ~ #``ls /dev/mapper
> ```
> 
> control gentoo vg1-home vg1-root vg1-swap
> 
> If your output looks similar to the above, then all is well. The new logical volumes (/dev/mapper/vg1-home, /dev/mapper/vg1-root and /dev/mapper/vg1-swap) can be treated exactly like physical disk partitions (i.e., just like /dev/sda1 etc.).
> 
> ## Formatting and Mounting the LVM Logical Volumes (LVs)
> 
> Now we have our virtual partitions, we need to set up their filesystems and then mount them.
> 
> First, create the swap:
> 
> ```
> livecd ~ #``mkswap -L "swap" /dev/mapper/vg1-swap
> ```
> 
> Next, the root filesystem. We'll create this as [ext4](https://wiki.gentoo.org/wiki/Ext4) (you can of course modify this if you wish):
> 
> ```
> livecd ~ #``mkfs.ext4 -L "root" /dev/mapper/vg1-root
> ```
> 
> Finally, the user home filesystem, also ext4. Note that we use the -m 0 option here, since ext4 will, by default, reserve 5% of the filesystem for the superuser, and we don't need that in this location, only on the root partition:
> 
> ```
> livecd ~ #``mkfs.ext4 -m 0 -L "home" /dev/mapper/vg1-home
> ```
> 
> Now, we activate the swap:
> 
> ```
> livecd ~ #``swapon -v /dev/mapper/vg1-swap
> ```
> 
> And, per the handbook, mount the root directory at the pre-existing /mnt/gentoo mountpoint:
> 
> ```
> livecd ~ #``mount -v -t ext4 /dev/mapper/vg1-root /mnt/gentoo
> ```
> 
> Next, we create the /mnt/gentoo/home mountpoint, a /mnt/gentoo/boot directory, and a /mnt/gentoo/boot/efi mountpoint. The purpose of these is as follows:
> 
> - /mnt/gentoo/home will be the mountpoint for our home directory LV.
> - /mnt/gentoo/boot will be the equivalent of the /boot directory in the Gentoo handbook. We will build our [kernel](https://wiki.gentoo.org/wiki/Kernel) and [initramfs](https://wiki.gentoo.org/wiki/Initramfs) targeting this directory as usual, although, since we are booting from an UEFI USB key, this directory will *not* be used when booting the system itself. Instead, the buildkernel utility, supplied as part of this tutorial, will be used to copy the final, signed and bootable kernel image onto the USB key (at /mnt/gentoo/efiboot) as part of the kernel build process. For that reason, we've converted /mnt/gentoo/boot from a mountpoint to a regular directory in this tutorial.
> - /mnt/gentoo/boot/efi will be the mountpoint for our USB boot key when inserted in the machine (when installing a new kernel, etc.). We currently have the key mounted at /tmp/efiboot and will need to unmount it.
> 
> Create the directories:
> 
> ```
> livecd ~ #``mkdir -v /mnt/gentoo/{home,boot,boot/efi}
> ```
> 
> Now mount the "home" LVM logical volume from the "vg1" volume group on the /mnt/gentoo/home mountpoint:
> 
> ```
> livecd ~ #``mount -v -t ext4 /dev/mapper/vg1-home /mnt/gentoo/home
> ```
> 
> Next, we need to unmount the USB boot key's EFI partition from its current temporary mountpoint (we'll remount it later, when we build the kernel):
> 
> ```
> livecd ~ #``umount -v /tmp/efiboot
> ```
> 
> Finally, issue:
> 
> ```
> livecd ~ #``blkid /dev/sdY1 /dev/sdZn
> ```
> 
> **Note**
> Replace /dev/sdY1 in the above with the actual path of your USB boot key's first partition, which we found [earlier](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key#making_boot_usb_key) (e.g., /dev/sdc1 etc.), and /dev/sdZn with the actual device path for the LUKS partition (e.g., /dev/sda7 etc.).
> 
> Take note of the PARTUUIDs (unique partition identifiers) for these two partitions; we'll make use of them later (in the fstab and the kernel build script's configuration file), rather than relying on the /dev/sd?? paths (which can change depending on which devices are plugged in, and the order in which they are recognized).
> 
> ## Next Steps
> 
> We're now ready to fetch the additional installation files and setup the build options. [Click here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files) to go to the next chapter, "Installing the Gentoo Stage 3 Files".
> 
> ## Notes
> 
> - ServerFault Q&A Site: ["Setting locale failed: force certain locale when connecting through ssh"](http://serverfault.com/questions/304469/setting-locale-failed-force-certain-locale-when-connecting-through-ssh)
> - Information Security Stack Exchange: ["XKCD #936: Short complex password, or long dictionary passphrase?"](http://security.stackexchange.com/questions/6095/xkcd-936-short-complex-password-or-long-dictionary-passphrase)
> - Rainbow Chard Blog: [*How to align partitions for best performance using parted*](http://rainbow.chard.org/2013/01/30/how-to-align-partitions-for-best-performance-using-parted/)
> - cryptsetup: ["Frequently Asked Questions"](https://gitlab.com/cryptsetup/cryptsetup/wikis/FrequentlyAskedQuestions); section 5.19/
> - Lell, Jakob. ["Practical malleability attack against CBC-encrypted LUKS partitions"](http://www.jakoblell.com/blog/2013/12/22/practical-malleability-attack-against-cbc-encrypted-luks-partitions/)
> - dm-crypt Mailing List: ["Using plain64/plain IV (initialisation vector) in dm-crypt"](http://www.saout.de/pipermail/dm-crypt/2010-July/001039.html)
> - dm-crypt Mailing List: ["Whirlpool in gcrypt <= 1.5.3 broken (if writes in chunks)?"](http://www.saout.de/pipermail/dm-crypt/2014-January/003813.html)
> - dm-crypt Mailing List: ["Re: Non-standard cipher mode"](http://www.spinics.net/lists/dm-crypt/msg05521.html)
> - Arch Linux Wiki: ["LVM: Advantages"](https://wiki.archlinux.org/index.php/LVM#Advantages)
> - Fedora Forum: ["LVM PE size - is it important?"](http://forums.fedoraforum.org/showthread.php?t=281745)
> 
> Arch Linux Wiki: ["Create root filesystem snapshots with LVM"](https://wiki.archlinux.org/index.php/Create_root_filesystem_snapshots_with_LVM)