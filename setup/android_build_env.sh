#!/usr/bin/env bash

# Copyright (C) 2018 Harsh 'MSF Jarvis' Shandilya
# Copyright (C) 2018 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only

# Script to setup an AOSP Build environment on Termux

apt update && apt upgrade -y

DEBIAN_FRONTEND=noninteractive \
    apt-get install \
    platform-tools autoconf automake \
    axel bc bison build-essential \
    ccache clang cmake curl flex g++ \
    gawk git git-lfs gnupg gperf \
    htop imagemagick libcap libelf \
    libllvm julia-llvm libgmp \
    libmpc libmpfr pngcrush \              
    libtool libxml2 libxml2-utils lzop \
    maven ncftp ncurses patch patchelf \
    pkg-config android-sdk-build-tools \
    pngquant re2c rsync subversion \
    texinfo unzip w3m xsltproc zip lzip \
    android-partition-tools mkbootimg \
    android-sysprop ext4fs-tools \
    toybox zipalign shc img2sdat sdat2img \
    ${PACKAGES} -y

echo -e "Installing GitHub CLI"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt update
apt install -y gh

echo -e "Setting up udev rules for adb!"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
systemctl restart udev

if [[ "$(command -v make)" ]]; then
    makeversion="$(make -v | head -1 | awk '{print $3}')"
    if [[ ${makeversion} != "${LATEST_MAKE_VERSION}" ]]; then
        echo "Installing make ${LATEST_MAKE_VERSION} instead of ${makeversion}"
        bash "$(dirname "$0")"/make.sh "${LATEST_MAKE_VERSION}"
    fi
fi

echo "Installing repo"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+rx /usr/local/bin/repo

git config --global user.email ty85sr@gmail.com
git config --global user.name ty85sr

apt install figlet fortune byobu mosh -y