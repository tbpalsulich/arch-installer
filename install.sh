#!/bin/sh

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

xargs -a official-packages sudo pacman -S --noconfirm --needed

aursh package-query
aursh yaourt

xargs -a aur-packages sudo yaourt -S --noconfirm --needed

git clone git@github.com:tpalsulich/dotfiles.git ~/.dotfiles
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
~/.dotfiles/install.sh
chsh -s /bin/zsh
