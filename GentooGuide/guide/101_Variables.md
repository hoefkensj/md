```bash
export MIRROR="http://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds/"
export LATEST="latest-stage3-amd64-desktop-systemd-mergedusr.txt"
export STAGE3_URL="${MIRROR}$(curl  --silent $MIRROR$LATEST | tail -n1 |awk '{print $1}')"
```