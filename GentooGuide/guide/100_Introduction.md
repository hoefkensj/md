## Introduction



The install described in this tutorial attempts to follow the 'stock' process from the Gentoo Handbook where possible, but differs in a number of important respects. Specifically:

### Goals (Someday)



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
tmux new -s GentooInstall 
```

remember to always run this whenever you open a new tab , you will be greatefull that you did later on.