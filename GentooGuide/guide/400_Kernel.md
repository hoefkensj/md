```bash
mkdir -p -v /etc/portage/package.license
emerge --ask --verbose sys-kernel/gentoo-sources
emerge --ask --verbose sys-kernel/linux-firmware 



```

```
readlink -v /usr/src/linux 
eselect kernel list 

```

```bash
MAKEOPTS="-j1" emerge --ask --verbose app-crypt/efitools 
```

```bash
gpg --version && echo && staticgpg --version
```

```bash
file "$(which staticgpg)"
```



 ` `