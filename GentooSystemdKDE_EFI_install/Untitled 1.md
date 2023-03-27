## Introduction

- **The kernel will be configured to self-boot under UEFI; no separate bootloader is needed.**

- **For security,:**
  - we will boot the kernel off of an external USB key (which can be removed once the boot has completed).
  - If the USB key is absent on power-up,
    - (opt 1.) Windows will start automatically instead.
    - (opt 2.) Or System will silently Fail and PowerOff
      >  There will be no SPI Access,(BIOS) No Bootmenu No Unsigned Efi loaders or binaries can run (see next point*)
  - Secure boot will be enabled. : The kernel will be signed with our own, generated key
    - the original Windows keys can be retained
    - Only Personal keys
      > Platform key (PK) + KeyExchange Key KEK )

- **Gentoo's root, swap and home partitions will reside on LVM logical volumes, which themselves will live on a single LUKS (encrypted) partition on the GPT-formatted hard drive of the machine.**
  > - Allone or next to a (shrunken) Windows System.*
- **The LUKS partition will be unlocked by a keyfile at boot.**
  - The keyfile will be stored on the USB key together with the Gentoo kernel, and will *itself* be GPG-encrypted, so that both the file *and* its passphrase will be needed to access the (Gentoo) data on the hard drive.
  - This provides a degree of dual-factor security against e.g., having the machine stolen with the USB key still in it,
  - The existence of a keylogger on the PC itself
  - Using a provided utility, you can subsequently migrate the kernel onto the Windows EFI system partition on the main drive if desired, and also relax the security to use just a typed-in passphrase, so once installed you won't need to use a USB key at all if you don't want to.)

- **We will create an initramfs to allow the GPG / LUKS / LVM stuff to happen in early userspace,**
  - this RAM disk will be stored inside the kernel itself, so it will work under EFI with secure boot
  - we'll also, for reasons that will become clear later, build a custom version of **gpg** to use in this step.
- **For all you source-code paranoiacs:**
  - Will be bootstrapped during the install (simulating an old-school stage-1) :
    - Gentoo toolchain (C and other compilers)
    - Core system
    - we'll validate that **all binary executables and libraries** have indeed been rebuilt from source when done.
    - De-blob the kernel, instructions for how to do so are provided , but is optional
    ​                  ***NOTE :\*** *assuming your hardware will actually work without uploaded firmware.|*
- **Gentoo repository syncs will be performed with gpg signature authentication. Unauthenticated protocols will \*not\* be used.**

  *GNOME 3 under systemd.:**
  > GNOME will be deployed on the modern Wayland platform as it enforces application isolation at the GUI level.
> - XWayland support for legacy applications
> - This is [more secure](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Sandboxing_the_Firefox_Browser_with_Firejail#x11_vulnerability) than deploying over X11,

- **Scripts are provided to automate**
  - the EFI kernel creation process:
    > **buildkernel**:
    > - handles conforming the kernel config for EFI encrypted boot (including setting the kernel command line correctly),
    > - creating the initramfs
    > - building and signing the kernel,
    > - installing on the EFI system partition
  - keep your system up-to-date.
    > **genup**: automates the process of updating your system software via **emerge** and associated tools.
- The scripts are shipped in an ebuild repository (aka 'overlay'), for easy deployment.

- **Disabling the Intel Management Engine** [[2\]](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide#cite_note-2) :
  - Detailed (optional) instructions for will be provided for those with Intel-CPU-based PCs who find this out-of-band coprocessor an unacceptable security risk,
  - as will instructions for fully sandboxing the popular **firefox** web browser, using **firejail**.

**Note** Tutorials covering various elements of the above can be found in one or more places online, but it's difficult to get an end-to-end overview - hence the reason this guide was created.

As mentioned, although this tutorial follows the format of the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) in places (particularly at the beginning), it's structured so as to be self-contained - you should be able to walk though this process and, using only these instructions, end up with a fully functional, relatively secure dual-boot Windows 10 (or 8) + Gentoo / GNOME 3 machine when you're done.