## Stage 3

### Downloading the files

```bash
cd /mnt/install/stage3
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

### Unpack the verified stage 3 archive

```bash
tar xpvJf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner --directory /mnt/gentoo
# x:extract, p:preserve permissions, J:xz-compression f:file

```

## Some Extra Folders

```BASH
install -m 775 -d /mnt/gentoo/Volumes
install -m 775 -d /mnt/gentoo/etc/portage/package.{accept_keywords,license,mask,unmask,use,env}
install -m 775 -d /mnt/gentoo/etc/portage/repos.conf
install -m 775 -d /mnt/gentoo/opt/{bin,sh,scripts}
install -m 775 -d /mnt/gentoo/opt/local/{bin,sh,scripts}
install -m 775 -d /mnt/gentoo/opt/local/config/rc/bash
chown -Rv root:100 /mnt/gentoo/{opt,Volumes}

mkdir -pv /mnt/install/{git,scripts}
```

## Extra Scripts

### superadduser (Slackware)

```bash
curl https://gitweb.gentoo.org/repo/gentoo.git/plain/app-admin/superadduser/files/1.15/superadduser -o  /mnt/install/scripts/superadduser/superadduser.sh
chmod +x /mnt/install/scripts/superadduser/superadduser.sh
install -D /mnt/install/scripts/superadduser/* /mnt/gentoo/opt/local/scripts/
ln -sv /opt/local/scripts/superadduser.sh /opt/local/sh/superadduser


```

### sourcedir (HoefkensJ)

```bash
curl https://raw.githubusercontent.com/hoefkensj/SourceDir/main/sourcedir-latest.sh -o /mnt/install/scripts/sourcedir/sourcedir-latest.sh
install -D scripts/sourcedir/* /mnt/gentoo/etc/bash/bashrc.d/

```

### local system bashrc (HoefkensJ)

```bash
git -C /mnt/install/git clone https://github.com/hoefkensj/GentooGuide.git
```

### Gentoolkit (Gentoo)

````bash
git -C /mnt/install/git clone https://github.com/gentoo/gentoolkit.git
````

### Psgrep (3rdParty)

```bash
git -C /mnt/install/git clone https://github.com/jvz/psgrep
```



	x11-misc/lndir