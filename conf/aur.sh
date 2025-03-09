#!/bin/bash

# Liste des paquets à installer
PACKAGES_YAY=(
    "git"
    "curl"
    "tar"
    "pacman-contrib"
    "networkmanager"
    "network-manager-applet"
    "nm-connection-editor"
    "networkmanager-openvpn"
    "wpa_supplicant"
    "iwd"
    "iw"
    "bluez"
    "bluez-utils"
    "ntfs-3g"
    "plasma"
    "konsole"
    "dolphin"
    "ark"
    "kwrite"
    "kcalc"
    "spectacle"
    "krunner"
    "partitionmanager"
    "packagekit-qt5"
    "firefox"
    "openssh"
    "qbittorrent"
    "audacious"
    "wget"
    "screen"
    "fastfetch"
    "zsh"
    "zsh-completions"
    "pipewire"
    "wireplumber"
    "pipewire-audio"
    "pipewire-alsa"
    "pipewire-pulse"
    "gst-plugin-pipewire"
    "pipewire-jack"
    "easyeffects"
    "clamav"
    "clamtk"
    "nftables"
    "rsyslog"
    "logrotate"
    "kvantum"
    "cockpit"
    "system-config-printer"
    "cups"
    "foomatic-db"
    "cups-pdf"
    "ghostscript"
    "gsfonts"
    "nushell"
    "ttf-dejavu"
    "ttf-meslo-nerd-font-powerlevel10k"
    "ttf-jetbrains-mono-nerd"
    "macchina"
    "keepass"
    "openvpn"
    "thunderbird"
    "thunderbird-i18n-fr"
    "qt6-svg"
    "qt6-declarative"
    "qt5-quickcontrols2"
    "qt5-svg"
    "qt5-declarative"
    "qt5-graphicaleffects"
    "sddm"
    "python-pipx"
    "power-profiles-daemon"
    "font-manager"
    "spectacle"
    "gwenview"
    "ddcutil"
    "rsync"
    "less"
    "jq"
    "bc"
    "yad"
    "zip"
    "unzip"
    "p7zip"
    "unrar"
    "which"
    "btop"
    "htop"
    "visual-studio-code-bin"
    "cameractrls"
    "obsidian"
    "docker"
    "neovim"
    "vim"
    "jdownloader2"
    "qemu"
    "libvirt"
    "virt-manager"
)