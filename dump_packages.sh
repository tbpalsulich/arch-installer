#!/bin/sh

pacman -Qqn > official-packages
pacman -Qqm | grep -v "package-query" | grep -v "yaourt" > aur-packages
