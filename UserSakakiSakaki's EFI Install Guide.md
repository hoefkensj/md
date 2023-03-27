# 							User:Sakaki/Sakaki's EFI Install Guide 					

​								< [User:Sakaki](https://wiki.gentoo.org/wiki/User:Sakaki)(Redirected from [Sakaki's EFI Install Guide](https://wiki.gentoo.org/index.php?title=Sakaki's_EFI_Install_Guide&redirect=no))							

[Jump to:navigation](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#mw-head)[Jump to:search](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#searchInput)

If you have a Windows 10 (or 8) machine that you'd like to dual-boot with  Gentoo Linux and GNOME 3, you've come to the right place! 

[![img](https://wiki.gentoo.org/images/thumb/9/9c/Dual_boot_cfax3_2.jpg/400px-Dual_boot_cfax3_2.jpg)](https://wiki.gentoo.org/wiki/File:Dual_boot_cfax3_2.jpg)

CF-AX3 Ultrabook, Running Windows 10 / Gentoo Linux

 **Warning**
31 Oct 2020: sadly, due to legal obligations arising from a recent change in my 'real world' job, I must announce I am **standing down as maintainer of this guide with immediate effect** (for more background, please see my post [here](https://forums.gentoo.org/viewtopic-p-8522963.html#8522963)).


 While I will be leaving this guide up for now (for historical interest,  and because it may still be of use to others), I can no longer recommend that you install a new Gentoo system using it. Instead, please follow  the standard [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) flow.


 Similarly, if you are already running a system installed via these instructions, while it *should* continue to work for some time, you should now take steps to migrate to a standard, Handbook-based approach, since the underlying **sakaki-tools** repo, and provided tools such as **buildkernel**, will also no longer be actively supported.



With sincere apologies, sakaki ><

This detailed (and tested) tutorial shows how to set up just such a dual-boot system, where the Gentoo component:

- is fully encrypted on disk (LVM over LUKS, with dual-factor protection);
- uses UEFI secure boot;
- OpenRC & GNOME 3 (on Wayland);
  - *or* runs systemd & GNOME 3 (ditto);
- can properly suspend and hibernate;
- has working drivers for touchscreen, webcam etc.;
- has (where appropriate) the Intel Management Engine disabled;[[1\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#cite_note-1)
- and even has a graphical boot splash!

To keep things concrete, I'll be walking line-by-line through the setup of a particular machine, namely the Panasonic CF-AX3 [Ultrabook](https://en.wikipedia.org/wiki/Ultrabook); however, these instructions should be usable (with minor alterations) for many modern PCs (including desktops) which have a [UEFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface) BIOS.

All commands that you'll need  to type in are listed, and an ebuild repository (aka 'overlay') with  some useful installation utilities is also provided.

While best read in tandem with the official [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:Main_Page), this manual can also be used standalone.

These instructions may also be easily adapted for those wishing to use Gentoo Linux as their sole OS, rather than dual booting.

## Contents



- [1 Introduction](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Introduction)
- [2 Chapters](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Chapters)
- [3 Let's Get Started!](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Let.27s_Get_Started.21)
- [4 Notes](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Notes)

## Introduction

The install described in this tutorial attempts to follow the 'stock' process from the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) where possible, but differs in a number of important respects. Specifically:

- The kernel will be configured to self-boot under UEFI; no separate bootloader is needed.

- For security, we will boot the kernel off of an external USB key (which can be removed once the boot has completed). If the USB key is  absent on power-up, Windows will start automatically instead.

- Secure boot will be enabled. The kernel will be signed with our own, generated key (and the original Windows keys will be retained too).

- Gentoo's root, swap and home partitions will reside on LVM logical volumes, which themselves will live on a single LUKS (encrypted) partition on the GPT-formatted hard drive of the machine.  We'll shrink the Windows C: NTFS partition to provide space for this.

- The LUKS partition will be unlocked by a keyfile at boot. The keyfile will be stored on the USB key together with the Gentoo kernel, and will *itself* be GPG-encrypted, so that both the file *and* its passphrase will be needed to access the (Gentoo) data on the hard  drive. This provides a degree of dual-factor security against e.g.,  having the machine stolen with the USB key still in it, or even the  existence of a keylogger on the PC itself (although not both at the same time!). (Using a provided utility, you can subsequently migrate the  kernel onto the Windows EFI system partition on the main drive if  desired, and also relax the security to use just a typed-in passphrase,  so once installed you won't need to use a USB key at all if you don't  want to.)

- We will create an initramfs to  allow the GPG / LUKS / LVM stuff to happen in early userspace, and this  RAM disk will be stored inside the kernel itself, so it will work under  EFI with secure boot (we'll also, for reasons that will become clear  later, build a custom version of **gpg** to use in this step).

- For all you source-code paranoiacs, the Gentoo toolchain and core system will be bootstrapped during the install (simulating an old-school stage-1) and we'll  validate that all binary executables and libraries have indeed been  rebuilt from source when done. The licence model will be set to accept free software only (and although I don't deblob the kernel, instructions for how to do so  are provided - assuming your hardware will actually work without  uploaded firmware!).

- All Gentoo repository syncs (including the initial **emerge-webrsync**) will be performed with **gpg** signature authentication. Unauthenticated protocols will *not* be used.

- The 

  latest (3.30+) *stable* version of GNOME

   will be installed, using 

  OpenRC

   for init (as GNOME is now officially supported under this init system, and no longer requires Dantrell B.'s patchset for this).

  - An alternative track is also provided, for those wishing to install GNOME 3 under [systemd](https://wiki.gentoo.org/wiki/Systemd). Most of this tutorial is common to both tracks, and a short guide is  provided at the appropriate point in the text, to help you choose which  route is better for you.
  - GNOME will be deployed on the modern [Wayland](https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)) platform (including [XWayland](https://wayland.freedesktop.org/xserver.html) support for legacy applications) — this is [more secure](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Sandboxing_the_Firefox_Browser_with_Firejail#x11_vulnerability) than deploying over X11, as it enforces application isolation at the GUI level.

- I'll provide simple scripts to automate the EFI kernel creation process and keep your system up-to-date. The first of these (**buildkernel**) handles conforming the kernel config for EFI encrypted boot (including  setting the kernel command line correctly), creating the initramfs,  building and signing the kernel, and installing it on the EFI system  partition. The second (**genup**) automates the process of updating your system software via **emerge** and associated tools. The scripts are shipped in an ebuild repository (aka 'overlay'), for easy deployment.

- Lastly, detailed (optional) instructions for disabling the Intel Management Engine[[2\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#cite_note-2) will be provided (for those with Intel-CPU-based PCs who find this  out-of-band coprocessor an unacceptable security risk), as will  instructions for fully sandboxing the popular **firefox** web browser, using **firejail**.

 **Note**
Tutorials covering various elements of the above can be found in one or more  places online, but it's difficult to get an end-to-end overview - hence  the reason this guide was created.

As mentioned, although this tutorial follows the format of the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) in places (particularly at the beginning), it's structured so as to be  self-contained - you should be able to walk though this process and,  using only these instructions, end up with a fully functional,  relatively secure dual-boot Windows 10 (or 8) + Gentoo / GNOME 3 machine when you're done.

 **Warning**
Backup **all** of your data before doing anything else, particularly if you have a lot of work stored on Windows already. The install process described here  has been tested end-to-end, *but* is provided 'as is' and without warranty. Proceed at your own risk.

 **Warning**
Tools like **parted**, **dd** and **cryptsetup**, which we'll be using, can vaporize data easily if misused. Please always double check that you are *applying operations to the correct device / partition*. We've all been there...

 **Warning**
We will be using strong cryptography to protect your system. If you lose  the LUKS keyfile, or forget the passphrase to unlock it, **all your data will be gone**, and even the NSA (probably!) won't be able to get it back.[[3\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#cite_note-3) So keep backups of these critical elements too (in a safe place, of course)!

## Chapters

The chapters of this tutorial are listed below, together with a brief summary of each.

You need to work though the chapters sequentially, in order to complete the install successfully.

 **Note**
 Don't worry if you don't immediately understand everything in the  chapter summaries below: the concepts involved will be described in  detail in the main body of the text.

1. **[Installation Prerequisites](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites)**. First, we'll briefly review the things you'll need in order to carry out the install.
2. **[Preparing Windows for Dual-Booting](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting)**. Next, we'll reduce the amount of space Windows takes up on the target  machine's hard drive, so there is room for our Gentoo system (and user  data). We'll use tools already present in Windows to do this.
3. **[Creating and Booting the Minimal-Install Image on USB](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB)**. Then, per [Chapter 2](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media) of the Gentoo handbook, we'll download a minimal Gentoo image onto a USB key, and boot into it on our target PC (in EFI / **OpenRC** mode, with secure boot temporarily turned off).
4. **[Setting Up Networking and Connecting via ssh](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh)**. Next, per [Chapter 3](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking) of the handbook, we'll setup network access for our minimal system, and connect in to it from a second, 'helper' PC via **ssh** (to ease installation).
5. **[Preparing the LUKS-LVM Filesystem and Boot USB Key](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key)**. After that, we'll create a GPG-protected keyfile on a second USB key,  create a LUKS (encrypted) partition on the machine's hard drive  protected with this key, and then create an LVM structure (root, home  and swap) on top of this (achieving the goals of [Chapter 4](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks) of the handbook).
6. **[Installing the Gentoo Stage 3 Files](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files)**. Then, per [Chapter 5](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage) of the handbook, we'll download a Gentoo 'stage 3' minimal filesystem,  and install it into the LVM root. We'll also set up your Portage build  configuration.
7. **[Building the Gentoo Base System Minus Kernel](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Building_the_Gentoo_Base_System_Minus_Kernel)**. Next, per [Chapter 6](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base) of the handbook, we'll complete some final preparations, then **chroot** into the stage 3 filesystem, update our Portage tree, and set a base profile, timezone and locale. We'll setup the **sakaki-tools** ebuild repository (which contains utilities to assist with the build), and install the first of these, **showem** (a program to monitor parallel **emerge**s). Then, we'll bootstrap the toolchain (simulating an old-school stage 1 install), rebuild everything in the **@world** set, and verify that all libraries and executables have, in fact, been  rebuilt. (Instructions are also provided for those who wish to skip  bootstrapping). We'll then set the 'real' GNOME profile, and then update the **@world** set to reflect this.
8. **[Configuring and Building the Kernel](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_and_Building_the_Kernel)**. Next, (loosely following [Chapter 7](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel) of the handbook), we'll setup necessary licenses, then download the  Linux kernel sources and firmware. We'll then install (from the **sakaki-tools** ebuild repository) the **buildkernel** utility, configure it, and then use *this* to automatically build our (EFI-stub) kernel (**buildkernel** ensures our kernel command line is filled out properly, the initramfs contains a static version of **gpg**, that the kernel has all necessary options set for **systemd**, etc.).
9. **[Final Preparations and Reboot into EFI](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Final_Preparations_and_Reboot_into_EFI)**. Then, following [Chapter 8](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System) of the handbook, we'll set up /etc/fstab, install a few other packages, set up a root password, then dismount the **chroot** and reboot (in EFI / **OpenRC** mode, or EFI / **systemd** mode, depending on the track) into our new system (secure boot will  still be off at this stage). Users on the OpenRC track will [branch off](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#alternative_track) at the conclusion of this chapter.
10. **[Completing OpenRC Configuration and Installing Necessary Tools](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Completing_OpenRC_Configuration_and_Installing_Necessary_Tools)**. With the machine restarted, we'll re-establish networking and the **ssh** connection, then complete the setup of **systemd**'s configuration. Per [Chapter 9](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Tools) of the Gentoo handbook, we'll then install some additional system tools (such as **cron**). Next, we'll install (from the **sakaki-tools** ebuild repository) the **genup** utility, and use it to perform a precautionary update of the **@world** set. Then, we'll reboot to check our **OpenRC** configuration. If successful, we'll invoke **buildkernel** again, to enable the **plymouth** graphical boot splash, and restart once more to test it.
11. **[Configuring Secure Boot under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot_under_OpenRC)**. Next, we'll set up secure boot. First, we'll save off the existing  state of the secure boot variables (containing Microsoft's public  key-exchange-key, etc.). Then, we'll create our own platform,  key-exchange and kernel-signing keypairs, and then reboot, *en route* using the BIOS GUI to enter setup mode (thereby clearing the variables, and enabling us to write to them). We'll then re-upload the saved keys, append our own set, and finally lock the platform with our new platform key. We'll then run **buildkernel** again, which will now be able to automatically sign our kernel. We'll  reboot, enable secure boot in the BIOS, and verify that our signed  kernel is allowed to run. Then, we'll reboot into Windows, and check we  haven't broken *its* secure boot operation! Finally, we'll reboot back to Linux again (optionally setting a BIOS password as we do so).
12. **[Setting up the GNOME 3 Desktop under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_up_the_GNOME_3_Desktop_under_OpenRC)**. Next, we'll setup your graphical desktop environment. We'll begin by creating a regular (non-root) user, per [Chapter 11](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing#Adding_a_user_for_daily_use) of the handbook. Then, we'll activate the **wayland** USE flag globally, and update your system to reflect this, after which we'll install X11 and a simple window manager (**twm**) (for test purposes). Using **buildkernel**, we'll then reconfigure and rebuild the kernel to include an appropriate [DRM](https://en.wikipedia.org/wiki/Direct_Rendering_Manager) graphics driver, and then reboot. Upon restart, we'll verify that the new DRM driver (which **wayland** requires) has been activated, and then test-run X11 (and a few trivial applicators) under **twm**. Once working, we'll remove the temporary window manager, install GNOME 3 (and a few key applications), and configure and test it under X11.  Then, we'll test it again under **wayland**, refine a few settings (network, keyboard etc.), and then restart the  machine and proceed with the install, working natively within GNOME  thereafter.
13. **[Final Configuration Steps under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Final_Configuration_Steps_under_OpenRC)**. Next, we'll configure your kernel to properly handle all your target  PC's devices. Although this setup will necessarily differ from machine  to machine, a general methodology is provided, together with a concrete  set of steps required for the Panasonic CF-AX3 (covering setup of its  integrated WiFi, Bluetooth, touchscreen, audio and SD card reader).  Thereafter, we'll cover some final setup points - namely, how to: prune  your kernel configuration (and initramfs firmware) to remove bloat; get  suspend and hibernate working properly; and disable **sshd** (as the helper PC is no longer needed from this point).
14. **[Using Your New Gentoo System under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Using_Your_New_Gentoo_System_under_OpenRC)**. Now your dual-boot system is up and running, in this last chapter we'll cover a few miscellaneous (but important) topics (and options)  regarding day-to-day use. We'll first recap how to boot from Linux to  Windows (and vice versa), then discuss how to ensure your machine is  kept up to date (using **genup**). We'll also show how to migrate your kernel to the internal drive  (Windows) EFI system partition if desired (and also, how to dispense  with the USB key entirely, if single-factor passphrase security is  sufficient). In addition, we'll briefly review how to tweak GNOME, and  (per [Chapter 11](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing#Where_to_go_from_here) of the handbook) where to go next (should you wish to install other  applications, a firewall, etc.). Finally, a number of addendum  "mini-guides" are provided, covering how to *e.g.*, [disable the Intel Management Engine](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine) on your target PC, and [fully sandbox the **firefox** web browser, using **firejail**](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Sandboxing_the_Firefox_Browser_with_Firejail).


 As mentioned, an 'alternative track' is also provided for chapters 10-14, for those users who wish to use GNOME with **systemd**, rather than **OpenRC**:

1. **[Alternative Track: Configuring systemd and Installing Necessary Tools (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_systemd_and_Installing_Necessary_Tools)**
2. **[Alternative Track: Configuring Secure Boot (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot)**
3. **[Alternative Track: Setting up the GNOME 3 Desktop (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_up_the_GNOME_3_Desktop)**
4. **[Alternative Track: Final Configuration Steps (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Final_Configuration_Steps)**
5. **[Alternative Track: Using Your New Gentoo System (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Using_Your_New_Gentoo_System)**

 **Note**
The decision about which init system (**OpenRC** or **systemd**) to use does not need to be made until Chapter 7 (where a brief summary  of the pros and cons of each will be provided, to help you decide).

## Let's Get Started!

Ready? Then [click here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites) to go to the first chapter, "Installation Prerequisites".

 **Note**
As is hopefully clear from the above, this tutorial covers a detailed, end-to-end installation walkthrough.
If you are searching for more concise, topic-based **EFI**, **systemd** or **GNOME** installation information, the following Wiki pages may be of use to you instead:

- [UEFI Gentoo Quick Install Guide](https://wiki.gentoo.org/wiki/UEFI_Gentoo_Quick_Install_Guide)
- [EFI stub kernel](https://wiki.gentoo.org/wiki/EFI_stub_kernel)
- [systemd](https://wiki.gentoo.org/wiki/Systemd)
- [systemd/Installing Gnome3 from scratch](https://wiki.gentoo.org/wiki/Systemd/Installing_Gnome3_from_scratch)
- [GNOME/GNOME without systemd](https://wiki.gentoo.org/wiki/GNOME/GNOME_without_systemd)

 **Note**
If you have recently upgraded [dev-libs/libgcrypt](https://packages.gentoo.org/packages/dev-libs/libgcrypt) to version >= 1.6, and found yourself thereby locked out of your (Whirlpool-hashed) LUKS partition, please see [this short guide](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Migrating_from_Whirlpool_Hash_on_LUKS) on how to recover.

 **Note**
Comments, suggestions and feedback about this guide are welcomed! You can use the "Discussion" tab (of whatever is the most relevant page) for this  purpose. On most browsers, you can use ShiftAltt as a shortcut to access this.

 **Tip**
While the [MediaWiki](https://mediawiki.org/) *source* for individual pages of this guide may most easily be edited or viewed  on the Gentoo Wiki directly, for ease of download the full page set is  also maintained on GitHub, [here](https://github.com/sakaki-/efi-install-guide-source). 

## Notes

1. 

 As the ME is disabled via an (optional) system firmware modification, it will remain inactive even when booted into Windows.



 For avoidance of doubt, in this guide 'disabled' has the same meaning as 'neutralized and disabled' in the Purism Inc. Blog: ["Deep Dive into Intel Management Engine Disablement"](https://puri.sm/posts/deep-dive-into-intel-me-disablement/)



1.  TechCrunch: ["Encrypting Your Email Works, Says NSA Whistleblower Edward Snowden"](http://techcrunch.com/2013/06/17/encrypting-your-email-works-says-nsa-whistleblower-edward-snowden/)







# 							User:Sakaki/Sakaki's EFI Install Guide/Disabling the Intel Management Engine 					

​								< [User:Sakaki](https://wiki.gentoo.org/wiki/User:Sakaki)‎ | [Sakaki's EFI Install Guide](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide)							

[Jump to:navigation](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#mw-head)[Jump to:search](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#searchInput)


 The [Intel Management Engine](https://en.wikipedia.org/wiki/Intel_Active_Management_Technology) ('IME' or 'ME') is an **out-of-band co-processor** integrated in all post-2006 Intel-CPU-based PCs. It has **full network and memory access and runs proprietary, signed, closed-source software at ring -3**,[[1\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-1)[[2\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-2)[[3\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-3)[[4\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-zeronights-4) independently of the BIOS, main CPU and platform operating system[[5\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-libreboot_me-5)[[6\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-6) — a fact which many regard as an unacceptable security risk  (particularly given that at least one remotely exploitable security hole has already been reported[[7\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-7)[[8\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-8)[[9\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-9)).

In this mini-guide, I'll run through the process of **disabling** the IME on your target PC.[[10\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-10) To do so, we will use Nicola Corna's [**me_cleaner**](https://github.com/corna/me_cleaner). This software operates on the firmware stored in your PC's BIOS chip  (where the bulk of the ME's code resides), and does two things:

- sets the 'High Assurance Program' bit, an ME 'kill switch' that the US government reportedly[[11\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-11) had incorporated for PCs used in sensitive applications[[12\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-12)[[13\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-13);
- removes the vast majority of the ME's software modules (including  network stack, RTOS and Java VM), leaving only the essential 'bring up'  components (the latter being necessary because, on modern systems, if  the IME fails to initialize, either the machine startup will be  completely halted at that point, or startup will *appear* to complete, only for a watchdog timer to reset the whole PC 30 minutes later[[14\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-14)).

This combined 'belt-and-braces' approach means that the ME *ought* to cleanly enter a self-induced null state (after resetting the  30-minute watchdog timer) but, should that not work, it will  nevertheless enter a failed state shortly thereafter (as the majority of its core software modules have been purged).

 **Note**
You may wonder how this can work at all, given that the ME's code is  signed. The reason (fortunately for us) is that the ME's software is  deployed as *individually signed modules* that are signature checked only when loaded — and they are lazy loaded.[[15\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-15) The very first module, **BUP** (or 'Bring UP'), contains the watchdog timer reset, and is left alone by **me_cleaner**. Once **BUP** has completed, the ME will either enter a 'parked' state (if the  HAP/AltMeDisable bit is respected), or try to load the remaining RTOS  modules (if not). In the former case, the ME is cleanly disabled. In the latter case, the signature check fails and the ME effectively crashes.  Either way, it is out of action from that point.

 **Warning**
The process involved will require re-flashing your system's BIOS-chip  firmware image, and will almost certainly void your system warranty. It  may result in your machine becoming 'bricked'. On some (though not many) PCs, the ME is used to initialize or manage certain system peripherals  and/or provide silicon workarounds — if that is the case on your target  machine, you may lose functionality by disabling it.
Remember: disabling the IME is a completely optional step: proceed entirely at your own risk.

The process we will be following is as follows:

- ensuring you have the necessary components available;
- locating (and identifying) the BIOS flash chip on your target PC;
- setting up a Raspberry Pi 3 Model B (or B+) ('RPi3') or Pi 4 Model B ('RPi4') as an in-system flash programmer;
- reading the original firmware from the BIOS flash chip (and validating this), using the RPi3/4;
- creating a modified copy of this firmware using **me_cleaner**;
- writing the modified copy of the firmware back to your PC's BIOS flash chip, again using the RPi3/4;
- restarting your PC, and verifying that the IME has been disabled.

Although some systems *do* allow the full contents of the BIOS flash chip to be reprogrammed using software tools only (so called ['internal flashing'](https://github.com/corna/me_cleaner/wiki/Internal-flashing-with-OEM-firmware)), on most PCs this facility is either completely unavailable, *or* can only write to the unprotected areas of the flash filesystem (*excluding* the ME area), *or* will only write vendor-signed images. Accordingly, we will describe the approach of using 'external' flashing in this guide, as that is the  most reliable.

 **Warning**
Although the most reliable method, external flashing *does* require you to open the case of your PC, an action that by itself is  likely to void the warranty on non-desktop systems. Always observe [proper ESD protective measures](https://www.computerhope.com/esd.htm) when working with exposed system boards, and ensure that you have all  external power sources and batteries removed. Backup any important files before proceeding. Read all instructions carefully and proceed only if  you are comfortable, and at your own risk.

If you are ready, let's go!

## Contents



- [1 Prerequisites](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#Prerequisites)
- [2 Locating (and Identifying) the Target PC's BIOS Flash Chip](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#Locating_.28and_Identifying.29_the_Target_PC.27s_BIOS_Flash_Chip)
- 3 Setting up the RPi3/4 as an External Flash Programmer
  - [3.1 Software Configuration](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#Software_Configuration)
  - [3.2 Hardware Configuration](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#Hardware_Configuration)
- [4 Reading and Verifying the Original Contents of your BIOS Flash Chip](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#Reading_and_Verifying_the_Original_Contents_of_your_BIOS_Flash_Chip)
- [5 Modifying Firmware using me_cleaner, to Disable the IME](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#Modifying_Firmware_using_me_cleaner.2C_to_Disable_the_IME)
- [6 Writing Back the Modified Firmware](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#Writing_Back_the_Modified_Firmware)
- 7 Restarting your PC and Verifying the IME is Disabled
  - [7.1 Recovery in Case of Error](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#Recovery_in_Case_of_Error)
- [8 Next Steps](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#Next_Steps)
- [9 Notes](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#Notes)

## Prerequisites

To proceed, you will require the following:

- an Intel-CPU-based target PC — that does 

  not

   have 

  Boot Guard

   enabled — on which you wish to disable the IME;

  - the target PC may be running an OEM BIOS (such as AMI, Dell etc.), or [coreboot](https://www.coreboot.org/);

- a [Raspberry Pi 3 Model B or B+, or Pi 4 Model B](https://wiki.gentoo.org/wiki/Raspberry_Pi) single board computer ('RPi3' or 'RPi4'), for use as an external flash programmer;

- a spare >= 8GB microSD card (to hold the 64-bit Gentoo O/S image we will use for the RPi3/4);

- an appropriate IC clip for your target PC's flash chip, e.g.:

  - a Pomona 5250 for SOIC-8 chips;
  - a Pomona 5208 for unsocketed DIP-8 chips, or
  - a Pomona 5252 for SOIC-16 chips;

- 8 female-female connector wires (to attach the appropriate clip to the RPi3/4's GPIO header);

- a maintenance manual for your target PC, where available, to assist in safe disassembly / reassembly; and

  - whatever tools are stipulated in the above.

 **Note**
AMD-CPU-based systems do not have the IME of course, but *do* have a broadly equivalent subsystem, the platform security processor (or 'PSP'),[[16\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-libreboot_psp-16) for which there is no equivalent workaround at the time of writing.

 **Note**
Intel systems that have Boot Guard enabled *cannot* be fully 'cleansed' — this technology stores a public verification key  for the vendor's (signed) firmware images in one-time-programmable fuses in the CPU, and utilises the ME to verify these.[[4\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-zeronights-4) It was introduced in the 4th generation (Haswell) architecture. By definition, Boot Guard *cannot* be active on systems where the motherboard and CPU are purchased  separately, and at the time of writing only a minority of laptop systems have it active. Note however that you should be able to use **me_cleaner**'s `-s/--soft-disable-only` option *even if* Boot Guard is in use on your system.

 **Note**
Note that there are many other [SBCs](https://en.wikipedia.org/wiki/Single-board_computer) that may be used for in-system flash reprogramming, for example the  BeagleBone. You can also use the RPi3/4 in 32-bit mode, and it is also  possible to use earlier versions of the RPi. However, for the sake of  concreteness, I will assume you are using the specified (RPi3 or RPi4)  system in what follows.

 **Note**
Other brands of IC clip are available, but Pomona is arguably the best known, and their model numbers often quoted by 'compatibles'. If you are  unsure which type you need, see the [next step](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#locate_chip).

 **Note**
Desktop users whose motherboard contains a *socketed* DIP-8 chip, may use a [solderless breadboard](https://wiki.analog.com/university/courses/electronics/electronics-lab-breadboards) to hold the flash chip while programming. In such a case, use  female-male connecting wires, or use break-away male headers on the  breadboard, and connect the female-female wires from the RPi3/4 to  those.

In the text, I will run through the process of reflashing the  BIOS-chip firmware on a specific machine, namely the long-suffering **Panasonic CF-AX3 Ultrabook** used in the main body of this guide. This has a SOIC-8 BIOS flash chip, so we will be using a Pomona 5250 clip. Of course, you should adapt the following instructions to match your specific setup, flash chip type  etc.

## Locating (and Identifying) the Target PC's BIOS Flash Chip

To begin — always observing [good ESD practices](https://www.computerhope.com/esd.htm), and following the instructions given in your target system's maintenance manual — *disconnect* any external power sources and removable batteries, and then expose your target PC's motherboard.

For desktop machines, gaining access to the motherboard is  generally easy, but for laptops the disassembly process is often quite  fiddly. However, the Panasonic CF-AX3 is refreshingly straightforward in this regard — after removing the main battery and removing 19 small  screws on the bottom-side, the rear panel of the laptop lifts off  easily. With this done, a second (internal) li-ion battery must be  disconnected, after which the mainboard is ready for inspection.  Obviously, the approach required for your system will be different.

 **Tip**
In addition to your manufacturer's maintenance manual, you can also often  find useful disassembly videos by searching on YouTube.

 **Note**
It is *not* generally necessary to remove the small CMOS button battery found on  most boards, in order to reprogram the BIOS flash, but your system may  differ. Be aware that if you *do* remove this battery, things like the BIOS password will probably be erased, if you set one earlier ([**systemd** track](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot#set_bios_pw), [**OpenRC** track)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot_under_OpenRC#set_bios_pw).

Once you have your target PC's motherboard exposed, locate its BIOS  flash chip. On many machines, the BIOS chip will be marked with a  sticker or paint dot. Laptops will generally have 8-pin or 16-pin [SOIC](https://en.wikipedia.org/wiki/Small_Outline_Integrated_Circuit) packages;on desktop machines, 8-pin socketed (and unsocketed) [DIP](https://en.wikipedia.org/wiki/Dual_in-line_package) packages are also common.

 **Note**
If your BIOS flash chip is in a [PLCC](https://en.wikipedia.org/wiki/Plastic_leaded_chip_carrier) or [WSON](https://en.wikipedia.org/wiki/List_of_integrated_circuit_packaging_types#Small_outline_packages) package, you will need specialized equipment to connect to the chip,  the process for which is not currently covered in this guide.

The CF-AX3 has a SOIC-8 flash IC, as shown:

[![img](https://wiki.gentoo.org/images/thumb/f/f5/Flash_chip_location2.jpg/600px-Flash_chip_location2.jpg)](https://wiki.gentoo.org/wiki/File:Flash_chip_location2.jpg)

Location of the SOIC-8 Flash Chip on a Panasonic CF-AX3 Laptop; Pin 1 on Bottom Left

Once you have located the BIOS flash chip, with the help of a  magnifying glass (good apps for this are available for IOS and Android  phones) or digital camera, read off the maker's name and model number  from the device. Then, use a search engine to locate the device's  datasheet.

For example, as the above photo shows, the CF-AX3 has a Winbond W25Q64FV IC; its datasheet may be found [here](http://www.winbond.com/resource-files/w25q64fv revs 07182017.pdf). This part uses a very commonly seen pinout, as follows (note how the pins are numbered counter-clockwise):

[![img](https://wiki.gentoo.org/images/c/c7/Flash_8_pinout.png)](https://wiki.gentoo.org/wiki/File:Flash_8_pinout.png)

Pinout of a Typical SOIC-8 / DIP-8 BIOS Flash Chip

 **Warning**
You must **always** check the pinout and voltage requirements of your particular device,  and adapt the connections on the IC clip accordingly. While a large  number of 8-pin devices use the layout shown above, not all do.

Note that on DIP packages, the top of the chip will generally be  marked by a semicircular indent; on SOIC packages, a small circle or  indent will mark pin 1 (NB, do not confuse this with any paint blobs the manufacturer may have used to highlight the flash chip, as for example  with the blue paint blob used on the CF-AX3.)

Write down the pinout for your device, if it differs from that shown in the above diagram.

 **Note**
While, following common usage, this guide talks about the 'BIOS chip' and  'reflashing the BIOS firmware' etc., it is important to understand that  the BIOS code proper is only *one* component of the firmware stored on the flash chip. It would be more accurate to talk about it as the  'system firmware flash memory' or similar, containing multiple regions  (for the BIOS, IME, Gigabit Ethernet etc.) each of which can contain  multiple modules. For more details, please see e.g., John Butterworth's ["Introduction to BIOS & SMM" slidesets](http://opensecuritytraining.info/IntroBIOS.html).

## Setting up the RPi3/4 as an External Flash Programmer

Next, we will set up a Raspberry Pi 3 Model B / B+ ('RPi3') or Pi 4  Model B ('RPi4') single board computer as an external flash programmer,  running 64-bit Gentoo Linux as its operating system. For convenience we  will use a pre-built image.

### Software Configuration

Download, write and boot the Gentoo image provided [here](https://github.com/sakaki-/gentoo-on-rpi-64bit) on your RPi3/4 (following the instructions given on that page).

 **Tip**
It is a good idea to write the Gentoo image to a different (spare) microSD card from your main Raspbian system; that way, you can easily revert to using Raspbian when done.

 **Note**
It is of course possible to carry out the flashing procedure described in  this chapter using other RPi OSes; however, for concreteness (and since  it has all the necessary components available) I will assume you *are* using the specified [gentoo-on-rpi-64bit](https://github.com/sakaki-/gentoo-on-rpi-64bit) image, in what follows.

The image starts up directly into an Xfce4 desktop, pre-logged in as the **demouser** account. When the boot has completed, open a terminal window on (or **ssh** in to) the RPi3/4 and become root:

```
demouser@pi64 ~ $``sudo su --login root 
```

If you have not modified the default image settings, no password will be required for this step.

Next, note that if you are using version >=1.2.0 of the **gentoo-on-rpi3-64bit** image, *all* the required software now comes pre-installed for convenience, so you can [skip directly to the "Hardware Configuration" section](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#setup_rpi3_hardware) now. Otherwise, keep reading.

Then, modify the /boot/config.txt file so that the [SPI interface](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus) (used to communicate with the flash chip) is available via the RPi's GPIO pins. As root, issue:

```
pi64 ~ #``nano -w /boot/config.txt 
```

and modify that file, *uncommenting* the following line (if not already done):

FILE **`/boot/config.txt`****Enable the SPI interface on your RPi**

```
dtparam=spi=on
```

Leave the rest of the file as-is. Save, and exit **nano**.

 **Tip**
If you are using the official 7" touchscreen with your RPi3/4, you can also add `lcd_rotate=2` to /boot/config.txt, to efficiently rotate the display (and touch region) to match the  default orientation of the case. For avoidance of doubt, if you are  using a monitor or **ssh** connection you should *not* add this stanza, however.

Next, fetch up-to-date copies of the [**sakaki-tools**](https://github.com/sakaki-/sakaki-tools) and [**genpi64**](https://github.com/sakaki-/genpi64-overlay) ebuild repositories ('overlays') on the RPi3/4. Ensure your RPi has a  valid network connection (you can easily setup a WiFi or Ethernet  connection via the bundled **NetworkManager** applet, just click on the network icon in the status bar), then issue:

```
pi64 ~ #``emaint sync --repo sakaki-tools 
pi64 ~ #``emaint sync --repo genpi64 
```

 **Note**
If you have time, it is better to do a *full* software update of your RPi3/4 before proceeding (the process requires about 2 hours). To do this, *instead* of the above two commands, ensure your RPi has network connectivity, then issue:

```
pi64 ~ #``genup 
```

and wait for this to finish with the message `All done - your system is now up-to-date!`, before proceeding.

Next, we need to install the [sys-apps/flashrom](https://packages.gentoo.org/packages/sys-apps/flashrom) software, which will allow us to read and write the flash chip over the SPI interface. Issue:

```
pi64 ~ #``emerge --ask --verbose sys-apps/flashrom 
... additional output suppressed ...
Would you like to merge these packages? [Yes/No] <press y, then press Enter>
... additional output suppressed ...
```

Because it will fetch and then check the [binhost](https://github.com/sakaki-/gentoo-on-rpi-64bit#binhost) packages metadata file, this command may take 3-4 minutes before  prompting you whether to proceed, so please be patient. The actual  package itself is available as a binary and will install quickly (with  no local compilation required), once confirmed.

 **Note**
If you are *not* using the [specified 64-bit Gentoo image](https://github.com/sakaki-/gentoo-on-rpi-64bit) on your RPi3/4, please note that the **atapromise** USE flag needs to be disabled on **arm64** (on the image, this is done via a [custom profile](https://github.com/sakaki-/gentoo-on-rpi-64bit#profile)).

Then, we need to emerge the **coreboot-utils** package, which provides **ifdtool** (a utility to parse and modify the structure of Intel firmware flash dumps). The package has an ebuild in the [**sakaki-tools**](https://github.com/sakaki-/sakaki-tools) repository (aka 'overlay') used on the image, so issue:

```
pi64 ~ #``emerge --ask --verbose sys-apps/coreboot-utils 
... additional output suppressed ...
Would you like to merge these packages? [Yes/No] <press y, then press Enter>
... additional output suppressed ...
```

 **Note**
If you are *not* using the [specified 64-bit Gentoo image](https://github.com/sakaki-/gentoo-on-rpi-64bit), follow the instructions given [here](https://github.com/corna/me_cleaner/wiki/How-to-apply-me_cleaner) to clone and build the software directly.

 **Note**
For avoidance of doubt, we are *not* going to be overwriting your BIOS with [coreboot](https://coreboot.org/), we just need access to some of its bundled tools. As mentioned [earlier](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#prerequisites), it is fine to use a target PC with an OEM BIOS (such as AMI, Dell etc.).
And, of course, if you *are* running coreboot, that's fine too ^-^

The next step is to install Nicola Corna's **me_cleaner** software itself. This also has an ebuild in the [**sakaki-tools**](https://github.com/sakaki-/sakaki-tools) repo, so issue:

```
pi64 ~ #``emerge --ask --verbose sys-apps/me_cleaner 
... additional output suppressed ...
Would you like to merge these packages? [Yes/No] <press y, then press Enter>
... additional output suppressed ...
```

 **Note**
If you are *not* using the [specified 64-bit Gentoo image](https://github.com/sakaki-/gentoo-on-rpi-64bit), follow the instructions given [here](https://github.com/corna/me_cleaner/wiki/How-to-apply-me_cleaner) to clone the software directly.

**me_cleaner** is a reasonably straightforward Python script. Nevertheless, it is good hygiene to review scripts prior to running them (particularly when they impact such security-critical areas as the IME and BIOS), so do so now. Issue:

```
pi64 ~ #``less /usr/lib/python-exec/python3.6/me_cleaner 
```

Use Page Down and Page Up to navigate within the file, and press q to quit, when done.

Lastly, we'll pull in the **pigpio** library (and accompanying **pigs** utility and **pigpiod** server), which will be used to set the GPIO pins on the header not directly controlled by **flashrom**). This has an ebuild in the [**genpi64**](https://github.com/sakaki-/genpi64-overlay) repo used on the image, so issue:

```
pi64 ~ #``emerge --ask --verbose dev-libs/pigpio 
... additional output suppressed ...
Would you like to merge these packages? [Yes/No] <press y, then press Enter>
... additional output suppressed ...
```

 **Note**
If you are *not* using the [specified 64-bit Gentoo image](https://github.com/sakaki-/gentoo-on-rpi-64bit), you can find links to the underlying source for **pigpio** [here](https://github.com/joan2937/pigpio).

 **Note**
This tutorial originally used the **wiringpi** package for GPIO access, but as this has since been deprecated by its author,[[17\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#cite_note-17) I have switched to using **pigpio** instead.

Once installed, start the **pigpiod** daemon, and ensure that this is automatically started each boot; issue:

```
pi64 ~ #``rc-service pigpiod start 
pi64 ~ #``rc-update add pigpiod default 
```

### Hardware Configuration

With the necessary software prepared, we can proceed to attach the  appropriate IC clip to the RPi's GPIO (general purpose input-output)  header.

Cleanly shutdown your RPi3/4:

```
pi64 ~ #``poweroff 
```

Physically remove the RPi3/4's power connector once the shutdown sequence has completed. 

With your RPi powered off, locate its 40-pin GPIO header, and  connect one end of each of the 8 female-female cables to the appropriate RPi GPIO pin as shown in (the inner, light green section of) the  diagram below:

 **Tip**
This header mapping will also work for the Raspberry Pi 1 model B+ or later.

[![img](https://wiki.gentoo.org/images/thumb/c/c1/Rpi_gpio_header_ic_flash.png/500px-Rpi_gpio_header_ic_flash.png)](https://wiki.gentoo.org/wiki/File:Rpi_gpio_header_ic_flash.png)

Pin mapping from RPi3/4 GPIO Header to Typical 8-Pin Flash Chip

Here is a photo showing these connections in place on an actual RPi3  (in an official 7" touchscreen enclosure; this is of course not  necessary in order to use the board). Disregard the wires on the  left-hand side, they are for the touchscreen. With the RPi oriented as  it is in this picture, pin 1 is at the extreme left position on the  nearer row, and pin 40 at the extreme right position on the farther row. The colours of the jumper wires used match those in the above [pin mapping](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#pin_mapping) and [flash chip pinout](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#flash_8_pinout).

[![img](https://wiki.gentoo.org/images/thumb/8/82/Rpi3_wiring2.jpg/600px-Rpi3_wiring2.jpg)](https://wiki.gentoo.org/wiki/File:Rpi3_wiring2.jpg)

An RPi3 with GPIO/SPI Connected for Flash Programming to a Pomona 5250 IC Clip (Click to Zoom)

 **Warning**
Be **very careful** not to connect pins 2 or 4 on the RPi's GPIO header to any pin of the  IC clip - these are 5v (rather then 3.3v) and are likely to **destroy** your flash chip should you accidentally use them.

The other end of the 8 wires you should connect to an appropriate IC test clip, per the outer (lilac) section of the [above pin mapping diagram](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#pin_mapping). The photo above shows a 5250 clip attached (as is appropriate for the  SOIC-8 flash chip in the Panasonic CF-AX3); obviously, adapt as  required. The important thing is to look at your flash IC's pin names /  functions (as given by its datasheet), and ensure that these are  connected to the appropriate header wire from the RPi3/4. For example,  with the Winbond W25Q64FV chip in a SOIC-8 package, as here, we have:

| IC Pin | IC Name | Wire Colour | RPi3/4 Pin | RPi3/4 Name        | Function                                                     |
| ------ | ------- | ----------- | ---------- | ------------------ | ------------------------------------------------------------ |
| 1      | /CS     | White       | 24         | SPI_CE0_N          | Chip select; drive low to enable device                      |
| 2      | DO      | Grey        | 21         | SPI_MISO           | Standard SPI data output (from chip)                         |
| 3      | /WP     | Blue        | 16         | GPIO23 / GPIO_GEN4 | Write protect; drive high to enable status registers to be written |
| 4      | GND     | Black       | 25         | Ground             | Ground                                                       |
| 5      | DI      | Orange      | 19         | SPI_MOSI           | Standard SPI data input (to chip)                            |
| 6      | CLK     | Yellow      | 23         | SPI_CLK            | SPI clock                                                    |
| 7      | /HOLD   | Green       | 18         | GPIO24 / GPI_GEN5  | Hold; drive low to pause device while actively selected      |
| 8      | VCC     | Red         | 17         | 3.3v               | Power supply (NB do *not* use 5v)                            |

 **Note**
The '/' in front of some IC signal names implies that their logic is *inverted*. So, for example, with **/WP** ("write protect"), we must drive the line *low* to write-protect the status registers on the flash chip, and high to write-enable them.

With the test clip connected, hardware setup of your RPi as a in-circuit flash programmer is complete.

## Reading and Verifying the Original Contents of your BIOS Flash Chip

Power the RPi back up, wait for Gentoo to boot, and then and open a terminal window (or, at your option, log in over **ssh**). As before, become root:

```
demouser@pi64 ~ $``sudo su --login root 
```

Then, as root, ensure that **/WP** and **/HOLD** are both pulled high. Issue:

```
pi64 ~ #``pigs pud 23 u 
pi64 ~ #``pigs pud 24 u 
```

These commands (using the **pigs** client from **pigpio**) activates the RPi3/4's internal pull-up resistors on **GPIO23** (RPi pin 16 → **/WP**) and **GPIO24** (RPi pin 18 → **/HOLD**) respectively.

 **Note**
These two lines are *not* part of the SPI interface managed by **flashrom**, so we must explicitly set them to appropriate values, as here.

 **Note**
If (and only if) these **pigs** commands *fail* with an error message (rather than returning silently), ensure you have an up-to-date version of **pigpio** installed, and have the **pigpiod** daemon running, by issing:

```
pi64 ~ #``emaint sync --repo genpi64 
pi64 ~ #``emerge --verbose dev-libs/pigpio 
pi64 ~ #``rc-service pigpiod start 
pi64 ~ #``rc-update add pigpiod default 
```

Then retry the above **pigs** commands once done.
For avoidance of doubt, most users should *not* have to issue the commands in this note.

Next, observing proper [proper ESD precautions](https://www.computerhope.com/esd.htm) (and after double-checking that you have all external power supplies and batteries removed), **attach the IC clip to your target PC's BIOS flash chip**.

For example, the photo below shows the same RPi3 as shown [earlier](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#wiring_photo) attached to the BIOS chip of the CF-AX3 laptop, using a Pomona 5250 test clip:

[![img](https://wiki.gentoo.org/images/thumb/4/4e/Flash_reprogramming2.jpg/600px-Flash_reprogramming2.jpg)](https://wiki.gentoo.org/wiki/File:Flash_reprogramming2.jpg)

Using an RPi3 for In-Circuit BIOS Chip Reflashing of a CF-AX3 (Click to Zoom)

 **Note**
The wire colours used are the same as in the rest of this guide (but other  than consistency, there is nothing 'magic' about them ^-^).
Pin 1 is on the bottom left of the flash chip in the above (and corresponds to the white wire on the Pomona 5250 IC clip).

With the clip attached, request that **flashrom** 'probe' to see if it can identify your BIOS flash chip:

```
pi64 ~ #``flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=8000 
flashrom v0.9.9-r1955 on Linux 4.10.17-v8-9411792647f6+ (aarch64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found Winbond flash chip "W25Q64.V" (8192 kB, SPI) on linux_spi.
No operations were specified.
```

Obviously the output will reflect your particular version of  flashrom, kernel and flash chip, but if you see something like the  above, you are good to proceed.

 **Note**
You can also specify the actual device using the **-c <chipname>** parameter to **flashrom** if you like; for example, on the Panasonic CF-AX3 you would would use:

```
pi64 ~ #``flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=8000 -c W25Q64.V 
```

With most devices this is unnecessary; however, if **flashrom** complains when you probe that "**Multiple flash chip definitions match... [p]lease specify which chip definition to use**", then you **must** use this option (with all **flashrom** commands in this guide) to disambiguate (obviously, use the appropriate **chipname** for your setup, if you do).

However, if instead you got an output containing `No EEPROM/flash device found`, then you have a problem. Double-check the wiring to your RPi3/4 and the IC clip, and make sure your RPi's [power supply is sufficient](https://www.raspberrypi.org/forums/viewtopic.php?f=63&t=138636). If that all looks good, re-seat the IC clip on your flash chip, and try again. The clips are tricky to get seated properly, so it is not  unusual for a few tries to be required before **flashrom** can successfully connect.

 **Warning**
If **flashrom** reports that it has found a brand or make of chip that doesn't match what you expected, **stop**. Search online and only proceed if you are confident there is no ambiguity.

 **Tip**
You can see all **flashrom**'s supported devices with:

```
pi64 ~ #``flashrom --list-supported 
```

If your device is not shown you may be unable to proceed (**flashrom***will* work correctly with most encountered flash devices though).

Once you have a successful probe, leaving the clip in place, dump a copy of your existing firmware:

```
pi64 ~ #``flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=8000 -r original.rom 
flashrom v0.9.9-r1955 on Linux 4.10.17-v8-9411792647f6+ (aarch64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found Winbond flash chip "W25Q64.V" (8192 kB, SPI) on linux_spi.
Reading flash... done.
```

 **Note**
Again, obviously the output you get will most likely differ, but it should follow the pattern above. Make sure you see the `Reading flash... done.` line in your own output, indicating that the operation has been successful.

Make another copy of the original firmware:

```
pi64 ~ #``flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=8000 -r original2.rom 
```

And check that both copies are identical (this is a useful check to ensure that neither image has been corrupted):

```
pi64 ~ #``diff original{,2}.rom 
```

This should produce no output, indicating that the dumped images are identical.

 **Warning**
If **diff** reports that the two images differ, **stop**. Repeat the read process until you have two identical copies that pass the diff test. Try reducing the **spispeed** parameter, and check your clip is properly seated. It is essential that you have a 'known good' backup copy of your original firmware before  proceeding, so take care with this step and do not skip it!

Next, assuming the **diff** check passes, run **ifdtool** on one of the images, to ensure that it has a valid structure:

```
pi64 ~ #``ifdtool -d original.rom 
```

Your output will obviously be system-specific, but should resemble something like that shown [here](https://gist.github.com/corna/66322fb938dedd93d2aaa1d59b27341d) (at least in broad outline).

 **Warning**
If **ifdtool -d** reports an error, or states that `No Flash Descriptor found in this image`, **stop**. Repeat the read process until you have two identical copies that pass the diff test *and* this **ifdtool -d** check.

Finally, check that the dumped image has a structure that the **me_cleaner** tool understands, and can work with. To do so, issue:

```
pi64 ~ #``me_cleaner --check original.rom 
```

As before, your output will be system-specific, but should pass all checks as for example shown [here](https://gist.github.com/corna/92df16e65248c63a258fdbdac5cb0923).

 **Warning**
If **me_cleaner --check** reports an error, or states that you have an `Unknown image`, **stop**. Given that the other tests passed, please [open an issue](https://github.com/corna/me_cleaner/issues/new) with **me_cleaner**, and report your findings.

## Modifying Firmware using **me_cleaner**, to Disable the IME

With all tests passed, you can now run **me_cleaner** on your firmware image. Issue:

```
pi64 ~ #``me_cleaner --soft-disable original.rom --output modified.rom 
Full image detected
The ME/TXE region goes from 0x3000 to 0x280000
Found FPT header at 0x3010
Found 21 partition(s)
Found FTPR header: FTPR partition spans from 0x4e000 to 0xd4000
ME/TXE firmware version 9.5.3.1520
Removing extra partitions...
Removing extra partition entries in FPT...
Removing EFFS presence flag...
Correcting checksum (0xe3)...
Reading FTPR modules list...
 UPDATE           (LZMA   , 0x0b1e05 - 0x0b1f0f): removed
 ROMP             (Huffman, fragmented data    ): NOT removed, essential
 BUP              (Huffman, fragmented data    ): NOT removed, essential
 KERNEL           (Huffman, fragmented data    ): removed
 POLICY           (Huffman, fragmented data    ): removed
 FTPM             (LZMA   , 0x0b1f0f - 0x0bfbe1): removed
 HOSTCOMM         (LZMA   , 0x0bfbe1 - 0x0c81af): removed
 TDT              (LZMA   , 0x0c81af - 0x0cd4ed): removed
 FPF              (LZMA   , 0x0cd4ed - 0x0ceff8): removed
The ME minimum size should be 430080 bytes (0x69000 bytes)
The ME region can be reduced up to:
 00003000:0006bfff me
Setting the AltMeDisable bit in PCHSTRP10 to disable Intel ME...
Checking the FTPR RSA signature... VALID
Done! Good luck!
```

Your output will obviously differ (and in particular, if you are  using a more modern PC than the CF-AX3 you may see a larger number of  modules listed (and on a server-class machine, many fewer); see the **me_cleaner** [success reports](https://github.com/corna/me_cleaner/issues/3), for examples of the sort of output that may be produced).

 **Note**
We have used the **--soft-disable** flag here to *both* purge unneeded ME firmware *and* set the AltMeDisable/HAP bit (requesting the ME to do a clean self-disable during the bring-up phase) as noted [earlier](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#me_cleaner_ops).

The resulting image is saved to the file **modified.rom**; the original firmware files are left untouched.

## Writing Back the Modified Firmware

We can now write back ('reflash') the system firmware we have just modified. With the IC clip still in place, issue:

```
pi64 ~ #``flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=8000 -w modified.rom 
flashrom v0.9.9-r1955 on Linux 4.10.17-v8-9411792647f6+ (aarch64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found Winbond flash chip "W25Q64.V" (8192 kB, SPI) on linux_spi.
Reading old flash chip contents... done.
Erasing and writing flash chip... Erase/write done.
Verifying flash... VERIFIED.
```

As before, your output will most likely differ somewhat, depending on the specifics of your setup.

 **Warning**
If **flashrom** reports an error here, or does not finish with the output `Verifying flash... VERIFIED`, **stop**. You almost surely have a corrupted flash. Try the write again, using a slower **spispeed** parameter, and if that also fails, try re-seating the IC clip. Ensure you have the **/WP** and **/HOLD** pullups active as was specified [earlier](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#pullup). You can also try specifying the exact model name to **flashrom** using the **-c** parameter, as was discussed [above](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#specify_rom).

Once the flash has been successfully programmed, disconnect the  IC-clip (or, if you are using a socketed chip and have it e.g. mounted  on a solderless breadboard, remove the flash chip and place it back  carefully in its socket on your PC).

## Restarting your PC and Verifying the IME is Disabled

Reassemble your target PC, following instructions given in your  vendor's maintenance manual where available (and as always taking care  to observe proper [proper ESD protective measures](https://www.computerhope.com/esd.htm)). Ensure any batteries or power supplies are reconnected, and then try  booting it up (into Gentoo) using your regular procedure.

If you experience serious problems upon restart — for example, the machine will not [POST](https://en.wikipedia.org/wiki/Power-on_self-test), or you are unable to enter the BIOS setup GUI after boot — then jump [here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#recovery) for instructions on how to recover (by reflashing your original firmware again).

However, in the more likely case that your machine appears to start up correctly into Linux (after you enter your **LUKS** passphrase etc.), you can run the **intelmetool** to check the status of the ME. This is available as part of the **coreboot-utils** package on the **sakaki-tools** ebuild repository (aka 'overlay') which we already set up [earlier in the guide](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Building_the_Gentoo_Base_System_Minus_Kernel#prep_for_parallel_emerge), so, to install it, open a terminal (on your target PC), become root, and issue:

```
koneko ~ #``emaint sync --repo sakaki-tools 
koneko ~ #``mkdir -p -v /etc/portage/package.unmask 
koneko ~ #``echo "sys-apps/coreboot-utils::sakaki-tools" >> /etc/portage/package.unmask/coreboot-utils 
koneko ~ #``emerge --ask --verbose sys-apps/coreboot-utils 
... additional output suppressed ...
Would you like to merge these packages? [Yes/No] <press y, then press Enter>
... additional output suppressed ...
```

 **Note**
The host name you see when running these commands will obviously reflect the settings on your target PC.

 **Note**
If you have *not* installed the **sakaki-tools** ebuild repository (its use was specified [earlier](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Building_the_Gentoo_Base_System_Minus_Kernel#prep_for_parallel_emerge) in the guide), then please follow the instructions given [here](https://github.com/corna/me_cleaner/wiki/How-to-apply-me_cleaner) to clone and build the software directly.

 **Note**
For avoidance of doubt, **intelmetool** is usable *both* on systems with an OEM (e.g. AMI, Dell etc.) BIOS and on those running [coreboot](https://www.coreboot.org/).

Then issue:

```
koneko ~ #``intelmetool --show 
```

Bad news, you have a `8 Series LPC Controller` so you have ME hardware on board and you can't control or disable it, continuing... `MEI was hidden on PCI, now unlocked MEI found: [8086:9c3a] 8 Series HECI #0 ME Status   : 0x1e020191 ME Status 2 : 0x104d0142 ME: FW Partition Table      : OK ME: Bringup Loader Failure  : NO ME: Firmware Init Complete  : NO ME: Manufacturing Mode      : YES ME: Boot Options Present    : NO ME: Update In Progress      : NO ME: Current Working State   : Initializing ME: Current Operation State : Bring up ME: Current Operation Mode  : Debug ME: Error Code              : No Error ME: Progress Phase          : BUP Phase ME: Power Management Event  : Clean Moff->Mx wake ME: Progress Phase State    : 0x4d ME: Extend SHA-256: <hash> ME: failed to become ready ME: failed to become ready ME: GET FW VERSION message failed ME: failed to become ready ME: failed to become ready ME: GET FWCAPS message failed Re-hiding MEI device...done `

Again, the output on your system will probably differ from this. You can safely ignore the ominous sounding Bad news... message, as that actually only indicates that the very low-level status registers of the ME are visible over PCI. The *real* indications that the ME is disabled are that you see (depending on your ME version) one or more of the below:

- `ME: Firmware Init Complete : NO` (as in the above);
- `ME: Error Code : Image Failure`;
- `ME: Current Working State : Initializing` (as in the above);
- `ME: Current Operation Mode : (null)`;
- `ME: Current Operation State : Bring up` (as in the above);
- `ME: Progress Phase : Uncategorized Failure`;
- `ME: Progress Phase : BUP Phase` (as in the above);
- `ME: Progress Phase State : Check to see if straps say ME DISABLED`;
- `ME: Progress Phase State : 0x4d` (as in the above);
- `ME: Progress Phase State : Unknown 0x40`;
- `ME: has a broken implementation on your board with this BIOS`;
- `ME: GET FW VERSION message failed` (as in the above); or
- `ME: GET FWCAPS message failed` (as in the above).



 **Note**
If **intelmetool** reports an error similar to `Could not map MEI PCI device memory`, please see [these notes](https://github.com/corna/me_cleaner/issues/30#issuecomment-301193328) for a solution.

You can also browse through the **me_cleaner** [success reports](https://github.com/corna/me_cleaner/issues/3), to see the sort of output that may be produced on different platforms.

Next, wait for 30 minutes of wall time to elapse, and ensure that your target PC does not reset itself (thereby proving that the watchdog timer has been properly cleared).

 **Note**
If you *don't* see `ME: Current Working State : Platform Disable Wait` in the output from **intelmetool**, you can confident that the watchdog *has* been successfully disabled (and can safely skip the 30 minute check).

If all that worked, congratulations! You have disabled the ME on your PC — click [here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#next_steps) to skip to the next step.

If however you experience a problem booting (and cannot e.g.  start Windows either, assuming you are dual-booting), then continue  reading [immediately below](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#recovery), to restore the original firmware image again.

### Recovery in Case of Error

The **me_cleaner** process just described does not work on all machines. Fortunately, since you [saved a copy](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#backup_firmware) of your original firmware earlier, and have a functional flash  reprogrammer (the RPi3/4) to hand, it is straightforward to roll things  back.

 **Note**
However, *before* rolling back your firmware, is is worth noting that on some systems, the **me_cleaner** process will cause the BIOS' *state* to be erased. As such, you may find e.g., that your target PC has  fallen back to legacy boot mode, that your custom secure boot keys have  been deleted and so on, but that you **can** still enter the BIOS GUI on boot (by pressing the appropriate hotkey).

 If this happens to you, you can recover your Gentoo system straightforwardly (and will probably *not* require a rollback reflash). To do so, enter the BIOS GUI, make sure  UEFI (not legacy) booting is selected, and turn off secure boot, if  enabled. Then, temporarily rename the kernel file /EFI/Boot/gentoo.efi on your boot USB key to /EFI/Boot/bootx64.efi (this can be done on any PC, including a Windows box). Insert the boot  USB key into your target PC, and restart, entering the BIOS GUI once  more. In the BIOS, select the boot USB key as the highest priority boot  device, and exit, saving changes (on a few BIOSes, you may also need to  specify the full /EFI/Boot/bootx64.efi path here). Your Linux system should now start up, with the familiar  LUKS prompt etc. Once back in your Gentoo desktop again, leave the boot  USB key inserted, open a terminal window, and run (without arguments, as root) buildkernel, which should reset your EFI boot order list (and put a fresh copy of (/boot/efi)/EFI/Boot/gentoo.efi on your boot USB key. You can now delete the temporary file (/boot/efi)/EFI/Boot/bootx64.efi if you like. Reboot, and you should find that this new kernel starts up correctly.

Having done this, follow the instructions given in the "Installing New Keys into the Keystore" section (*ff*.) of the "Configuring Secure Boot" chapter (which may be found [here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot#install_new_keys) for **systemd** users, and [here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot_under_OpenRC#install_new_keys) for those using **OpenRC**) to re-install your (existing) secure boot keys, and re-activate and test secure boot.

If the process just described works for you, congratulations, your system  should be functioning normally again! Rejoin the tutorial [above](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#renga_janai), and check that the IME has been successfully disabled on your machine. If, however, it did *not* work, continuing reading [immediately below](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#restore_image), to roll back your firmware.

To restore the original firmware image, simply follow the previous instructions to power down your PC, expose  the system motherboard, and (re)connect the RPi flash programmer's IC  clip. Then on the RPi, working as root, issue:

```
pi64 ~ #``pigs pud 23 u 
pi64 ~ #``pigs pud 24 u 
pi64 ~ #``flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=8000 -w original.rom 
... additional output suppressed ...
Verifying flash... VERIFIED.
```

to write the original firmware image back again. When done (make sure you see the `Verifying flash... VERIFIED` output), follow the earlier procedure to disconnect the IC clip, reassemble your target PC, and boot it up.

In this case, unfortunately it appears that the IME cannot be disabled on your system at this time.

## Next Steps

If you were **successful** restarting your system after running **me_cleaner** (and it passed the [`intelmetool --show` test](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine#imt_check)), please consider posting details of your system [here](https://github.com/corna/me_cleaner/issues/3), to assist others.

However, if you **experienced a problem** during the process, please take the time to post an [new issue](https://github.com/corna/me_cleaner/issues/new) here.

Finally, to rejoin the main guide, please click [here (**systemd**)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Using_Your_New_Gentoo_System#additional_mini_guides) or [here (**OpenRC**)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Using_Your_New_Gentoo_System_under_OpenRC#additional_mini_guides).

## Notes

1. 

 Skochinsky, Igor. [*Rootkit in your Laptop*](http://me.bios.io/images/c/ca/Rootkit_in_your_laptop.pdf). Breakpoint 2012



 Skochinsky, Igor. [*Intel ME Secrets*](https://recon.cx/2014/slides/Recon 2014 Skochinsky.pdf). Recon 2014



 Positive Technologies [*Intel ME: The Way of the Static Analysis*](https://www.troopers.de/downloads/troopers17/TR17_ME11_Static.pdf). TROOPERS17



 Ermolov, Alexander. [*Safeguarding rootkits: Intel BootGuard*](https://2016.zeronights.ru/wp-content/uploads/2017/03/Intel-BootGuard.pdf). ZERONIGHTS 2016



 libreboot FAQ: ["Intel Management Engine"](https://libreboot.org/faq.html#intelme)



 Purism Inc. Blog: ["Intel's Management Engine"](https://puri.sm/learn/intel-me/)



 Demerjian, Charlie. ["Remote security exploit in all 2008+ Intel platforms "](https://semiaccurate.com/2017/05/01/remote-security-exploit-2008-intel-platforms/)



 The Register: ["Red alert! Intel patches remote execution hole that's been hidden in chips since 2010"](https://www.theregister.co.uk/2017/05/01/intel_amt_me_vulnerability/)



 The Register: ["Intel Finds Critical Holes in Secret Management Engine Hidden in Tons of Desktop, Server Chipsets"](https://www.theregister.co.uk/2017/11/20/intel_flags_firmware_flaws/)



 For avoidance of doubt, in this guide 'disabled' has the same meaning as 'neutralized and disabled' in the Purism Inc. Blog: ["Deep Dive into Intel Management Engine Disablement"](https://puri.sm/posts/deep-dive-into-intel-me-disablement/)



 PT Security Blog ["Disabling Intel ME 11 via undocumented mode"](http://blog.ptsecurity.com/2017/08/disabling-intel-me.html#more)



 Corna, Nicola, *me_cleaner wiki*, ["HAP AltMeDisable bit"](https://github.com/corna/me_cleaner/wiki/HAP-AltMeDisable-bit)



 The HAP bit is available for ME version 11 (Skylake) and following. Earlier versions include a similar-function **AltMeDisable** bit (discovered by Igor Skochinsky) which **me_cleaner** will automatically set instead, where appropriate; however, this **AltMeDisable** bit is technically unassociated with the High Assurance Program *per se*.



 Benchoff, Brian. ["Neutralizing Intel's Management Engine"](https://hackaday.com/2016/11/28/neutralizing-intels-management-engine/)



 Corna, Nicola, *me_cleaner wiki*, ["How does it work?"](https://github.com/corna/me_cleaner/wiki/How-does-it-work%3F)



 libreboot FAQ: ["AMD Platform Security Processor (PSP)"](https://libreboot.org/faq.html#amd-platform-security-processor-psp)



Henderson, Gordon, *wiringPi Blog*, ["wiringPi – deprecated…"](http://wiringpi.com/wiringpi-deprecated/)









