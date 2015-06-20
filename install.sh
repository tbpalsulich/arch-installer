#!/bin/sh

set -e

# https://wiki.archlinux.org/index.php/Aur.sh
function aursh() {
	d=${BUILDDIR:-$PWD}
	for p in ${@##-*}; do
		cd $d
		curl https://aur.archlinux.org/packages/${p:0:2}/$p/$p.tar.gz |tar xz
		cd $p
		makepkg ${@##[^\-]*}
	done
}

OFFICIAL_PAC=`curl -s https://raw.githubusercontent.com/tpalsulich/arch-installer/master/packages/official-packages`
AUR_PAC=`curl -s https://raw.githubusercontent.com/tpalsulich/arch-installer/master/packages/aur-packages`

echo sudo pacman -S --noconfirm --needed $OFFICIAL_PAC

aursh package-query
aursh yaourt

echo sudo yaourt -S --noconfirm --needed $AUR_PAC

git clone git@github.com:tpalsulich/dotfiles.git ~/.dotfiles
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
~/.dotfiles/install.sh
chsh -s /bin/zsh
