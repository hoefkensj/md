# Preparing The Disk

## Disk Partitioning (GPT):

### Quick summary:

- How MBR worked (tldr of it)
- basic partitioning on disks with a GPT (GUID Partition Table)
- create from scratch (or from from MBR (Master Boot Record))
  - clean slate new/zeroed disk
  - convert the Partitions From MBR to GPT without dataloss* (* when it goes as expected)
- The tldr of :
  - GUID 
    - ESP / SYSTEM EFI/UEFI BIOS(legacy/[***3 LETTER ACRONYM HERE***])
    - Linux Specific
  - PART/FS LABEL
  - 
  - Protected MBR ,
  - LIMITS ,
  - FILESYSTEMS ?
  - SystemD
  - EFI/BOOTLOADER-SPEC



### MBR (how it used to be)

*(this is not 100% technically correct but it should be close enough (usable to think with it) while also simple enough )* 

A BIOS was a fairly Straight Forward thing , hence the name : Basic Input Output System. once loaded , it did a POST ,(Power On Self Test) which tested how much ram there was in the system. later on this included detection and configuration (assigning IRQ,...) of hardware available, as well as Drives / Other media, Then check where to go next and hand off control. where to go next was configured  with a setting inside the bios that allowed selection of one of : [Floppy,Primary Master ,Primary Slave, Secondary Master,Secondary Slave].    

before pc's had harddisks by  default there was the Floppy Drive and later Diskettes. in order to  be usable you had to place a floppy in the pc that had an operating system on it when powering on the pc... this was somewhat hardcoded in the bios , when POST is successfull goto this #ADDRESS ,in the adress space (wich just had been enumerated), and that was it the cpu read whatever was on that adress and executed that as next instruction.

a floppy's first Sector (512Byte in size), named the Master Boot (from bootstrapping onself) Record [MBR] of that drive , Initially holding the kernel of the OS , but when they became larger than 512bytes the code that came in its place was just a pointer for where to find the actual kernel on the drive. since it was nonstarter to account for any possible adress in the bios for where the kernel could be (considering that if the order of hardware changed at all the whole adress space schifts around) . a floppy usually holding 1partition would have a pointer here that points to the start of the first partition, the first 512Bytes of that partiton could have the kernel or could have another MBR, that points directly to the kernel or to a place in the (for FAT) File Allocation Table   for where to find the kernel

In order for a PC to do something after POST (the procedure where the pc tests itself, this later included auto-detection and configuration of connected hardware)

### GPT (the current Situation)

GUID Partition Table is also a 'simple' table holding the information on the locations of the partition, but now with also the partition type , defined by the GUID. and no limit of 4 partitions but much much more. so the size of that table is also larger. there is also no bootflag anymore but the Bios or its newer variant : the SuperIO , capable of understanding  the GPT structure looks for the ESP or Efi System Partition, and (some) even autodetect and list all availeble .efi bootloaders on that disk. other require manually adding them in the system setup.

Our disk should be GPT formatted there should be 1 ESP on the system with size minimally 1024MB  to be comfortable later on. and 1 partition for the system root (installation disk) thats it everything else is optional. in both cases its worth giving the partitions a PARTLABEL, at this stage , this is not the same as the filesytem label. also trake note that for maximum compat its a good idea (unlike any installer for linux out there that ignores this while it does go hand in hand with a nice feature of systemd ), to also set the GUID of the partition correctly this would be (gdisk shorthands):

```ini
0700    :     Microsoft basic data
0701    :     Microsoft Storage Replica
0c01    :     Microsoft reserved
2700    :     Windows RE
4200    :     Windows LDM data
4201    :     Windows LDM metadata
4202    :     Windows Storage Spaces
7f00    :     ChromeOS kernel
7f01    :     ChromeOS root
7f02    :     ChromeOS reserved
7f03    :     ChromeOS firmware
7f04    :     ChromeOS mini-OS
7f05    :     ChromeOS hibernate
8200    :     Linux swap
8300    :     Linux filesystem
8301    :     Linux reserved
8302    :     Linux /home
8303    :     Linux x86 root (/)
8304    :     Linux x86-64 root (/)
8305    :     Linux ARM64 root (/)
8306    :     Linux /srv
8307    :     Linux ARM32 root (/)
8308    :     Linux dm-crypt
8309    :     Linux LUKS
830a    :     Linux IA-64 root (/)
830b    :     Linux x86 root verity
830c    :     Linux x86-64 root verity
830d    :     Linux ARM32 root verity
830e    :     Linux ARM64 root verity
830f    :     Linux IA-64 root verity
8310    :     Linux /var
8311    :     Linux /var/tmp
8312    :     Linux user's home
8313    :     Linux x86 /usr
8314    :     Linux x86-64 /usr
8315    :     Linux ARM32 /usr
8316    :     Linux ARM64 /usr
8317    :     Linux IA-64 /usr
8318    :     Linux x86 /usr verity
8319    :     Linux x86-64 /usr verity
831a    :     Linux ARM32 /usr verity
831b    :     Linux ARM64 /usr verity
831c    :     Linux IA-64 /usr verity
8400    :     Intel Rapid Start
8500    :     Container Linux /usr
8501    :     Container Linux resizable rootfs
8502    :     Container Linux /OEM customization
8503    :     Container Linux root on RAID
8e00    :     Linux LVM
a500    :     FreeBSD disklabel
a501    :     FreeBSD boot
a502    :     FreeBSD swap
a503    :     FreeBSD UFS
a504    :     FreeBSD ZFS
a505    :     FreeBSD Vinum/RAID
a506    :     FreeBSD nandfs
a600    :     OpenBSD disklabel
a800    :     Apple UFS
a901    :     NetBSD swap
a902    :     NetBSD FFS
a903    :     NetBSD LFS
a904    :     NetBSD concatenated
a905    :     NetBSD encrypted
a906    :     NetBSD RAID
ab00    :     Recovery HD
af00    :     Apple HFS/HFS+
af01    :     Apple RAID
af02    :     Apple RAID offline
af03    :     Apple label
af04    :     AppleTV recovery
af05    :     Apple Core Storage
af06    :     Apple SoftRAID Status
af07    :     Apple SoftRAID Scratch
af08    :     Apple SoftRAID Volume
af09    :     Apple SoftRAID Cache
af0a    :     Apple APFS
af0b    :     Apple APFS Pre-Boot
af0c    :     Apple APFS Recovery
b000    :     U-Boot boot loader
bc00    :     Acronis Secure Zone
e900    :     Veracrypt data
ed00    :     Sony system partition
ed01    :     Lenovo system partition
ef00    :     EFI system partition
ef01    :     MBR partition scheme
ef02    :     BIOS boot partition
fb00    :     VMWare VMFS
fb01    :     VMWare reserved
fc00    :     VMWare kcore crash protection
fd00    :     Linux RAID
```

out of these these are the ones most likely to be of use to us:8be4df61-93ca-11d2-aa0d-00e098032b8c-BootOptionSupport

```ini
ef00    :     EFI system partition
8200    :     Linux swap
8302    :     Linux /home
8304    :     Linux x86-64 root (/)
8312    :     Linux user's home
8314    :     Linux x86-64 /usr
8314    :     Linux x86-64 /usr
8306    :     Linux /srv
8310    :     Linux /var
8311    :     Linux /var/tmp

8300    :     Linux filesystem
8301    :     Linux reserved


8308    :     Linux dm-crypt
8309    :     Linux LUKS
830c    :     Linux x86-64 root verity
8319    :     Linux x86-64 /usr verity
```

## Formatting

```bash
mksfs.f2fs -f -l GENTOO -O extra_attr,inode_checksum,sb_checksum,flexible_inline_xattr -w 4096 /dev/disk/by-partlabel/GENTOO
```