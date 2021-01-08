#!/usr/bin/sh

mkdir chroot
debootstrap --no-merged-usr --arch=i386 ondokuz chroot https://19.depo.pardus.org.tr/pardus
for i in dev dev/pts proc sys; do mount -o bind /$i chroot/$i; done
chroot chroot apt-get install gnupg -y

chroot chroot apt-get install grub-pc-bin grub-efi -y
chroot chroot apt-get install live-config live-boot -y

# xorg & desktop pkgs
chroot chroot apt-get install xserver-xorg network-manager-gnome -y

chroot chroot apt-get install pardus-xfce-desktop sudo thunar-archive-plugin pardus-installer-y

chroot chroot apt-get install firmware-amd-graphics firmware-atheros \
    firmware-b43-installer firmware-b43legacy-installer \
    firmware-bnx2 firmware-bnx2x firmware-brcm80211  \
    firmware-cavium firmware-intel-sound firmware-intelwimax \
    firmware-ipw2x00 firmware-ivtv firmware-iwlwifi \
    firmware-libertas firmware-linux firmware-linux-free \
    firmware-linux-nonfree firmware-misc-nonfree firmware-myricom \
    firmware-netxen firmware-qlogic firmware-realtek firmware-samsung \
    firmware-siano firmware-ti-connectivity firmware-zd1211

chroot chroot apt-get clean
rm -f chroot/root/.bash_history
rm -rf chroot/var/lib/apt/lists/*
find chroot/var/log/ -type f | xargs rm -f

mkdir debjaro
umount -lf -R chroot/* 2>/dev/null
mksquashfs chroot filesystem.squashfs -comp gzip -wildcards
mkdir -p debjaro/live
mv filesystem.squashfs debjaro/live/filesystem.squashfs

cp -pf chroot/boot/initrd.img-* debjaro/live/initrd.img
cp -pf chroot/boot/vmlinuz-* debjaro/live/vmlinuz

mkdir -p debjaro/boot/grub/
echo 'menuentry "Start Pardus GNU/Linux XFCE 32-bit (Unofficial)" --class pardus {' > debjaro/boot/grub/grub.cfg
echo '    linux /live/vmlinuz boot=live live-config live-media-path=/live quiet splash --' >> debjaro/boot/grub/grub.cfg
echo '    initrd /live/initrd.img' >> debjaro/boot/grub/grub.cfg
echo '}' >> debjaro/boot/grub/grub.cfg

grub-mkrescue debjaro -o debjaro-gnulinux-$(date +%s).iso