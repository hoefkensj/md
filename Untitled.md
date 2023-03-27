> 1. [User:Sakaki/Sakaki's EFI Install Guide - Gentoo Wiki](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide)
>
>    
>
>    > # User:Sakaki/Sakaki's EFI Install Guide 					
>    >
>    > From Gentoo Wiki
>    >
>    > ​								< [User:Sakaki](https://wiki.gentoo.org/wiki/User:Sakaki)							
>    >
>    > [Jump to:navigation](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#mw-head)[Jump to:search](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#searchInput)
>    >
>    > If you have a Windows 10 (or 8) machine that you'd like to dual-boot with Gentoo Linux and GNOME 3, you've come to the right place! 
>    >
>    > [![img](https://wiki.gentoo.org/images/thumb/9/9c/Dual_boot_cfax3_2.jpg/400px-Dual_boot_cfax3_2.jpg)](https://wiki.gentoo.org/wiki/File:Dual_boot_cfax3_2.jpg)
>    >
>    > CF-AX3 Ultrabook, Running Windows 10 / Gentoo Linux
>    >
>    >  **Warning**
>    > 31 Oct 2020: sadly, due to legal obligations arising from a recent change in my 'real world' job, I must announce I am **standing down as maintainer of this guide with immediate effect** (for more background, please see my post [here](https://forums.gentoo.org/viewtopic-p-8522963.html#8522963)).
>    >
>    > 
>    >  While I will be leaving this guide up for now (for historical interest, and because it may still be of use to others), I can no longer recommend that you install a new Gentoo system using it. Instead, please follow the standard [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) flow.
>    >
>    > 
>    >  Similarly, if you are already running a system installed via these instructions, while it *should* continue to work for some time, you should now take steps to migrate to a standard, Handbook-based approach, since the underlying **sakaki-tools** repo, and provided tools such as **buildkernel**, will also no longer be actively supported.
>    >
>    > 
>    >
>    > With sincere apologies, sakaki ><
>    >
>    > This detailed (and tested) tutorial shows how to set up just such a dual-boot system, where the Gentoo component:
>    >
>    > - is fully encrypted on disk (LVM over LUKS, with dual-factor protection);
>    > - uses UEFI secure boot;
>    > - OpenRC & GNOME 3 (on Wayland);
>    >   - *or* runs systemd & GNOME 3 (ditto);
>    > - can properly suspend and hibernate;
>    > - has working drivers for touchscreen, webcam etc.;
>    > - has (where appropriate) the Intel Management Engine disabled;[[1\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#cite_note-1)
>    > - and even has a graphical boot splash!
>    >
>    > To keep things concrete, I'll be walking line-by-line through the setup of a particular machine, namely the Panasonic CF-AX3 [Ultrabook](https://en.wikipedia.org/wiki/Ultrabook); however, these instructions should be usable (with minor alterations) for many modern PCs (including desktops) which have a [UEFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface) BIOS.
>    >
>    > All commands that you'll need to type in are listed, and an ebuild repository (aka 'overlay') with some useful installation utilities is also provided.
>    >
>    > While best read in tandem with the official [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:Main_Page), this manual can also be used standalone.
>    >
>    > These instructions may also be easily adapted for those wishing to use Gentoo Linux as their sole OS, rather than dual booting.
>    >
>    > ## Contents
>    >
>    > 
>    >
>    > - [1 Introduction](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Introduction)
>    > - [2 Chapters](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Chapters)
>    > - [3 Let's Get Started!](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Let.27s_Get_Started.21)
>    > - [4 Notes](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#Notes)
>    >
>    > ## Introduction
>    >
>    > The install described in this tutorial attempts to follow the 'stock' process from the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) where possible, but differs in a number of important respects. Specifically:
>    >
>    > - The kernel will be configured to self-boot under UEFI; no separate bootloader is needed.
>    >
>    > - For security, we will boot the kernel off of an external USB key (which can be removed once the boot has completed). If the USB key is absent on power-up, Windows will start automatically instead.
>    >
>    > - Secure boot will be enabled. The kernel will be signed with our own, generated key (and the original Windows keys will be retained too).
>    >
>    > - Gentoo's root, swap and home partitions will reside on LVM logical volumes, which themselves will live on a single LUKS (encrypted) partition on the GPT-formatted hard drive of the machine. We'll shrink the Windows C: NTFS partition to provide space for this.
>    >
>    > - The LUKS partition will be unlocked by a keyfile at boot. The keyfile will be stored on the USB key together with the Gentoo kernel, and will *itself* be GPG-encrypted, so that both the file *and* its passphrase will be needed to access the (Gentoo) data on the hard drive. This provides a degree of dual-factor security against e.g., having the machine stolen with the USB key still in it, or even the existence of a keylogger on the PC itself (although not both at the same time!). (Using a provided utility, you can subsequently migrate the kernel onto the Windows EFI system partition on the main drive if desired, and also relax the security to use just a typed-in passphrase, so once installed you won't need to use a USB key at all if you don't want to.)
>    >
>    > - We will create an initramfs to allow the GPG / LUKS / LVM stuff to happen in early userspace, and this RAM disk will be stored inside the kernel itself, so it will work under EFI with secure boot (we'll also, for reasons that will become clear later, build a custom version of **gpg** to use in this step).
>    >
>    > - For all you source-code paranoiacs, the Gentoo toolchain and core system will be bootstrapped during the install (simulating an old-school stage-1) and we'll validate that all binary executables and libraries have indeed been rebuilt from source when done. The licence model will be set to accept free software only (and although I don't deblob the kernel, instructions for how to do so are provided - assuming your hardware will actually work without uploaded firmware!).
>    >
>    > - All Gentoo repository syncs (including the initial **emerge-webrsync**) will be performed with **gpg** signature authentication. Unauthenticated protocols will *not* be used.
>    >
>    > - The 
>    >
>    >   latest (3.30+) *stable* version of GNOME
>    >
>    >    will be installed, using 
>    >
>    >   OpenRC
>    >
>    >    for init (as GNOME is now officially supported under this init system, and no longer requires Dantrell B.'s patchset for this).
>    >
>    >   - An alternative track is also provided, for those wishing to install GNOME 3 under [systemd](https://wiki.gentoo.org/wiki/Systemd). Most of this tutorial is common to both tracks, and a short guide is provided at the appropriate point in the text, to help you choose which route is better for you.
>    >   - GNOME will be deployed on the modern [Wayland](https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)) platform (including [XWayland](https://wayland.freedesktop.org/xserver.html) support for legacy applications) — this is [more secure](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Sandboxing_the_Firefox_Browser_with_Firejail#x11_vulnerability) than deploying over X11, as it enforces application isolation at the GUI level.
>    >
>    > - I'll provide simple scripts to automate the EFI kernel creation process and keep your system up-to-date. The first of these (**buildkernel**) handles conforming the kernel config for EFI encrypted boot (including setting the kernel command line correctly), creating the initramfs, building and signing the kernel, and installing it on the EFI system partition. The second (**genup**) automates the process of updating your system software via **emerge** and associated tools. The scripts are shipped in an ebuild repository (aka 'overlay'), for easy deployment.
>    >
>    > - Lastly, detailed (optional) instructions for disabling the Intel Management Engine[[2\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#cite_note-2) will be provided (for those with Intel-CPU-based PCs who find this out-of-band coprocessor an unacceptable security risk), as will instructions for fully sandboxing the popular **firefox** web browser, using **firejail**.
>    >
>    >  **Note**
>    > Tutorials covering various elements of the above can be found in one or more places online, but it's difficult to get an end-to-end overview - hence the reason this guide was created.
>    >
>    > As mentioned, although this tutorial follows the format of the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) in places (particularly at the beginning), it's structured so as to be self-contained - you should be able to walk though this process and, using only these instructions, end up with a fully functional, relatively secure dual-boot Windows 10 (or 8) + Gentoo / GNOME 3 machine when you're done.
>    >
>    >  **Warning**
>    > Backup **all** of your data before doing anything else, particularly if you have a lot of work stored on Windows already. The install process described here has been tested end-to-end, *but* is provided 'as is' and without warranty. Proceed at your own risk.
>    >
>    >  **Warning**
>    > Tools like **parted**, **dd** and **cryptsetup**, which we'll be using, can vaporize data easily if misused. Please always double check that you are *applying operations to the correct device / partition*. We've all been there...
>    >
>    >  **Warning**
>    > We will be using strong cryptography to protect your system. If you lose the LUKS keyfile, or forget the passphrase to unlock it, **all your data will be gone**, and even the NSA (probably!) won't be able to get it back.[[3\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#cite_note-3) So keep backups of these critical elements too (in a safe place, of course)!
>    >
>    > ## Chapters
>    >
>    > The chapters of this tutorial are listed below, together with a brief summary of each.
>    >
>    > You need to work though the chapters sequentially, in order to complete the install successfully.
>    >
>    >  **Note**
>    >  Don't worry if you don't immediately understand everything in the chapter summaries below: the concepts involved will be described in detail in the main body of the text.
>    >
>    > 1. **[Installation Prerequisites](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites)**. First, we'll briefly review the things you'll need in order to carry out the install.
>    > 2. **[Preparing Windows for Dual-Booting](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_Windows_for_Dual-Booting)**. Next, we'll reduce the amount of space Windows takes up on the target machine's hard drive, so there is room for our Gentoo system (and user data). We'll use tools already present in Windows to do this.
>    > 3. **[Creating and Booting the Minimal-Install Image on USB](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Creating_and_Booting_the_Minimal-Install_Image_on_USB)**. Then, per [Chapter 2](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media) of the Gentoo handbook, we'll download a minimal Gentoo image onto a USB key, and boot into it on our target PC (in EFI / **OpenRC** mode, with secure boot temporarily turned off).
>    > 4. **[Setting Up Networking and Connecting via ssh](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_Up_Networking_and_Connecting_via_ssh)**. Next, per [Chapter 3](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking) of the handbook, we'll setup network access for our minimal system, and connect in to it from a second, 'helper' PC via **ssh** (to ease installation).
>    > 5. **[Preparing the LUKS-LVM Filesystem and Boot USB Key](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key)**. After that, we'll create a GPG-protected keyfile on a second USB key, create a LUKS (encrypted) partition on the machine's hard drive protected with this key, and then create an LVM structure (root, home and swap) on top of this (achieving the goals of [Chapter 4](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks) of the handbook).
>    > 6. **[Installing the Gentoo Stage 3 Files](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files)**. Then, per [Chapter 5](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage) of the handbook, we'll download a Gentoo 'stage 3' minimal filesystem, and install it into the LVM root. We'll also set up your Portage build configuration.
>    > 7. **[Building the Gentoo Base System Minus Kernel](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Building_the_Gentoo_Base_System_Minus_Kernel)**. Next, per [Chapter 6](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base) of the handbook, we'll complete some final preparations, then **chroot** into the stage 3 filesystem, update our Portage tree, and set a base profile, timezone and locale. We'll setup the **sakaki-tools** ebuild repository (which contains utilities to assist with the build), and install the first of these, **showem** (a program to monitor parallel **emerge**s). Then, we'll bootstrap the toolchain (simulating an old-school stage 1 install), rebuild everything in the **@world** set, and verify that all libraries and executables have, in fact, been rebuilt. (Instructions are also provided for those who wish to skip bootstrapping). We'll then set the 'real' GNOME profile, and then update the **@world** set to reflect this.
>    > 8. **[Configuring and Building the Kernel](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_and_Building_the_Kernel)**. Next, (loosely following [Chapter 7](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel) of the handbook), we'll setup necessary licenses, then download the Linux kernel sources and firmware. We'll then install (from the **sakaki-tools** ebuild repository) the **buildkernel** utility, configure it, and then use *this* to automatically build our (EFI-stub) kernel (**buildkernel** ensures our kernel command line is filled out properly, the initramfs contains a static version of **gpg**, that the kernel has all necessary options set for **systemd**, etc.).
>    > 9. **[Final Preparations and Reboot into EFI](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Final_Preparations_and_Reboot_into_EFI)**. Then, following [Chapter 8](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System) of the handbook, we'll set up /etc/fstab, install a few other packages, set up a root password, then dismount the **chroot** and reboot (in EFI / **OpenRC** mode, or EFI / **systemd** mode, depending on the track) into our new system (secure boot will still be off at this stage). Users on the OpenRC track will [branch off](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#alternative_track) at the conclusion of this chapter.
>    > 10. **[Completing OpenRC Configuration and Installing Necessary Tools](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Completing_OpenRC_Configuration_and_Installing_Necessary_Tools)**. With the machine restarted, we'll re-establish networking and the **ssh** connection, then complete the setup of **systemd**'s configuration. Per [Chapter 9](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Tools) of the Gentoo handbook, we'll then install some additional system tools (such as **cron**). Next, we'll install (from the **sakaki-tools** ebuild repository) the **genup** utility, and use it to perform a precautionary update of the **@world** set. Then, we'll reboot to check our **OpenRC** configuration. If successful, we'll invoke **buildkernel** again, to enable the **plymouth** graphical boot splash, and restart once more to test it.
>    > 11. **[Configuring Secure Boot under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot_under_OpenRC)**. Next, we'll set up secure boot. First, we'll save off the existing state of the secure boot variables (containing Microsoft's public key-exchange-key, etc.). Then, we'll create our own platform, key-exchange and kernel-signing keypairs, and then reboot, *en route* using the BIOS GUI to enter setup mode (thereby clearing the variables, and enabling us to write to them). We'll then re-upload the saved keys, append our own set, and finally lock the platform with our new platform key. We'll then run **buildkernel** again, which will now be able to automatically sign our kernel. We'll reboot, enable secure boot in the BIOS, and verify that our signed kernel is allowed to run. Then, we'll reboot into Windows, and check we haven't broken *its* secure boot operation! Finally, we'll reboot back to Linux again (optionally setting a BIOS password as we do so).
>    > 12. **[Setting up the GNOME 3 Desktop under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_up_the_GNOME_3_Desktop_under_OpenRC)**. Next, we'll setup your graphical desktop environment. We'll begin by creating a regular (non-root) user, per [Chapter 11](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing#Adding_a_user_for_daily_use) of the handbook. Then, we'll activate the **wayland** USE flag globally, and update your system to reflect this, after which we'll install X11 and a simple window manager (**twm**) (for test purposes). Using **buildkernel**, we'll then reconfigure and rebuild the kernel to include an appropriate [DRM](https://en.wikipedia.org/wiki/Direct_Rendering_Manager) graphics driver, and then reboot. Upon restart, we'll verify that the new DRM driver (which **wayland** requires) has been activated, and then test-run X11 (and a few trivial applicators) under **twm**. Once working, we'll remove the temporary window manager, install GNOME 3 (and a few key applications), and configure and test it under X11. Then, we'll test it again under **wayland**, refine a few settings (network, keyboard etc.), and then restart the machine and proceed with the install, working natively within GNOME thereafter.
>    > 13. **[Final Configuration Steps under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Final_Configuration_Steps_under_OpenRC)**. Next, we'll configure your kernel to properly handle all your target PC's devices. Although this setup will necessarily differ from machine to machine, a general methodology is provided, together with a concrete set of steps required for the Panasonic CF-AX3 (covering setup of its integrated WiFi, Bluetooth, touchscreen, audio and SD card reader). Thereafter, we'll cover some final setup points - namely, how to: prune your kernel configuration (and initramfs firmware) to remove bloat; get suspend and hibernate working properly; and disable **sshd** (as the helper PC is no longer needed from this point).
>    > 14. **[Using Your New Gentoo System under OpenRC](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Using_Your_New_Gentoo_System_under_OpenRC)**. Now your dual-boot system is up and running, in this last chapter we'll cover a few miscellaneous (but important) topics (and options) regarding day-to-day use. We'll first recap how to boot from Linux to Windows (and vice versa), then discuss how to ensure your machine is kept up to date (using **genup**). We'll also show how to migrate your kernel to the internal drive (Windows) EFI system partition if desired (and also, how to dispense with the USB key entirely, if single-factor passphrase security is sufficient). In addition, we'll briefly review how to tweak GNOME, and (per [Chapter 11](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing#Where_to_go_from_here) of the handbook) where to go next (should you wish to install other applications, a firewall, etc.). Finally, a number of addendum "mini-guides" are provided, covering how to *e.g.*, [disable the Intel Management Engine](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Disabling_the_Intel_Management_Engine) on your target PC, and [fully sandbox the **firefox** web browser, using **firejail**](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Sandboxing_the_Firefox_Browser_with_Firejail).
>    >
>    > 
>    >  As mentioned, an 'alternative track' is also provided for chapters 10-14, for those users who wish to use GNOME with **systemd**, rather than **OpenRC**:
>    >
>    > 1. **[Alternative Track: Configuring systemd and Installing Necessary Tools (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_systemd_and_Installing_Necessary_Tools)**
>    > 2. **[Alternative Track: Configuring Secure Boot (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Configuring_Secure_Boot)**
>    > 3. **[Alternative Track: Setting up the GNOME 3 Desktop (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Setting_up_the_GNOME_3_Desktop)**
>    > 4. **[Alternative Track: Final Configuration Steps (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Final_Configuration_Steps)**
>    > 5. **[Alternative Track: Using Your New Gentoo System (under systemd)](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Using_Your_New_Gentoo_System)**
>    >
>    >  **Note**
>    > The decision about which init system (**OpenRC** or **systemd**) to use does not need to be made until Chapter 7 (where a brief summary of the pros and cons of each will be provided, to help you decide).
>    >
>    > ## Let's Get Started!
>    >
>    > Ready? Then [click here](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Installation_Prerequisites) to go to the first chapter, "Installation Prerequisites".
>    >
>    >  **Note**
>    > As is hopefully clear from the above, this tutorial covers a detailed, end-to-end installation walkthrough.
>    > If you are searching for more concise, topic-based **EFI**, **systemd** or **GNOME** installation information, the following Wiki pages may be of use to you instead:
>    >
>    > - [UEFI Gentoo Quick Install Guide](https://wiki.gentoo.org/wiki/UEFI_Gentoo_Quick_Install_Guide)
>    > - [EFI stub kernel](https://wiki.gentoo.org/wiki/EFI_stub_kernel)
>    > - [systemd](https://wiki.gentoo.org/wiki/Systemd)
>    > - [systemd/Installing Gnome3 from scratch](https://wiki.gentoo.org/wiki/Systemd/Installing_Gnome3_from_scratch)
>    > - [GNOME/GNOME without systemd](https://wiki.gentoo.org/wiki/GNOME/GNOME_without_systemd)
>    >
>    >  **Note**
>    > If you have recently upgraded [dev-libs/libgcrypt](https://packages.gentoo.org/packages/dev-libs/libgcrypt) to version >= 1.6, and found yourself thereby locked out of your (Whirlpool-hashed) LUKS partition, please see [this short guide](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Migrating_from_Whirlpool_Hash_on_LUKS) on how to recover.
>    >
>    >  **Note**
>    > Comments, suggestions and feedback about this guide are welcomed! You can use the "Discussion" tab (of whatever is the most relevant page) for this purpose. On most browsers, you can use ShiftAltt as a shortcut to access this.
>    >
>    >  **Tip**
>    > While the [MediaWiki](https://mediawiki.org/) *source* for individual pages of this guide may most easily be edited or viewed on the Gentoo Wiki directly, for ease of download the full page set is also maintained on GitHub, [here](https://github.com/sakaki-/efi-install-guide-source). 
>    >
>    > ## Notes
>    >
>    > 1. 
>    >
>    >  As the ME is disabled via an (optional) system firmware modification, it will remain inactive even when booted into Windows.
>    >
>    > 
>    >
>    >  For avoidance of doubt, in this guide 'disabled' has the same meaning as 'neutralized and disabled' in the Purism Inc. Blog: ["Deep Dive into Intel Management Engine Disablement"](https://puri.sm/posts/deep-dive-into-intel-me-disablement/)
>    >
>    > 
>    >
>    > TechCrunch: ["Encrypting Your Email Works, Says NSA Whistleblower Edward Snowden"](http://techcrunch.com/2013/06/17/encrypting-your-email-works-says-nsa-whistleblower-edward-snowden/)