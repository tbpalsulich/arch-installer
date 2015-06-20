#!/bin/sh

pacman -Qqn > official-packages
pacman -Qqm | egrep -v "(package-query|yaourt)" > aur-packages
