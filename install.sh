#!/bin/sh

set -e

# https://wiki.archlinux.org/index.php/Aur.sh
aursh() {
    d=${BUILDDIR:-$PWD}
    for p in ${@##-*}; do
        cd $d
        curl https://aur.archlinux.org/packages/${p:0:2}/$p/$p.tar.gz |tar xz
        cd $p
        makepkg ${@##[^\-]*}
    done
}

install_packages() {
    OFFICIAL_PAC=`curl -s https://raw.githubusercontent.com/tpalsulich/arch-installer/master/packages/official-packages`
    AUR_PAC=`curl -s https://raw.githubusercontent.com/tpalsulich/arch-installer/master/packages/aur-packages`

    echo sudo pacman -S --noconfirm --needed $OFFICIAL_PAC

    aursh package-query
    aursh yaourt

    echo sudo yaourt -S --noconfirm --needed $AUR_PAC
}

echo "Enter a host name:"
read hostname

echo "Enter a user name:"
read username

echo "Enter a new root password (input will be hidden):"
read -s rootPassword
echo

echo "Enter a new user password (input will be hidden):"
read -s userPassword
echo

while [[ -z "$timezone" || ! -f "/usr/share/zoneinfo/$timezone" ]]; do
    echo "Enter a timezone (e.g. America/Los_Angeles):"
    read timezone
done

pacstrap /mnt base base-devel btrfs-progs

# TODO: Allow editing of fstab right here.
genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash -si << EOF
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf
    export LANG=en_US.UTF-8;
    ln -s "/usr/share/zoneinfo/$timezone" /etc/localtime;
    echo "$hostname" > /etc/hostname
    systemctl enable dhcpcd.service
    mkinitcpio -p linux

    install_packages # I assume this installs grub.

    grub-install --target=i386-pc --recheck --debug /dev/sdb
    grub-mkconfig -o /boot/grub/grub.cfg

    echo "root:$rootPassword" | chpasswd
    groupadd sudo
    echo "%sudo ALL=(ALL) ALL" >> /etc/sudoers

    useradd -m -s /bin/zsh "$username"
    systemctl enable sshd.service
    usermod -a -G sudo "$username"
    echo "$username":"$userPassword" | chpasswd
EOF

runuser -l $username << EOF
    git clone git@github.com:tpalsulich/dotfiles.git ~/.dotfiles
    git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    ~/.dotfiles/install.sh
EOF

echo "Configure whatever else you want and fix errors, then reboot."
