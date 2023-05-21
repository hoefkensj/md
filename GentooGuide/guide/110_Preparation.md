



## Formatting

```bash
mksfs.f2fs -f -l GENTOO -O extra_attr,inode_checksum,sb_checksum,flexible_inline_xattr -w 4096 /dev/disk/by-partlabel/GENTOO
```

## Creating Folders

```bash
install -m 777 -d /mnt/{gentoo,install/{stage3}}

```

## MountingAutomate the Stage3 Downloads (tarbal and verificationkeys)

### TempFs (~ramdisk) 

If we plan to do the installation in 1 session (=without a reboot) its a good idea to  create a tempfs in the installation folder ,however if we choose to span the installation over multiple days or weeks, and reboot the machine in the mean time the tempfs wil be cleard and a more permanent (bind mount or just a regular folder might be in order),splitting off the installaton files in a seperate folder that is not on the target volume keeps that volume clutter free and keeps the first bytes of the volume one piece instead of fragmented with files that will be deleted or moved later on , creating a gap at the beginning of the partition.  if you have enough free 'Memory'. we don't need much  for this , ~1GB will be enough , if you dont have 1GB free memory (spare), you can just leave the folder as a folder on the current (old) root drive (given that it has 1GB free space ofc)

```bash
#the new root Volume:
mount -t f2fs -o rw,relatime,lazytime,background_gc=on,discard,no_heap,inline_xattr,inline_data,inline_dentry,flush_merge,extent_cache,mode=adaptive,active_logs=6,alloc_mode=default,checkpoint_merge,fsync_mode=posix,discard_unit=block  /dev/disk/by-label/GENTOO /mnt/gentoo
#the Installation Files 
mount -o size=1G -t tmpfs tmpfs /mnt/Install
```

### Mount-Options  Overview# x:extract, p:preserve permissions, J:xz-compression f:file

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

