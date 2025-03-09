#!/usr/bin/bash

set -e  # Quitte immédiatement en cas d'erreur.

source $TARGET_DIR/arch-plasma/env/system.sh 
source $TARGET_DIR/arch-plasma/env/functions.sh
source $TARGET_DIR/arch-plasma/conf/pac.sh
source $TARGET_DIR/arch-plasma/conf/yay.sh

source $TARGET_DIR/arch-plasma/fct-install/install_aur.sh


# Gestion des options
case "$1" in

  --install)

    check_internet

    # export PATH=~/.local/bin:$PATH
    export PATH="$HOME/.local/bin:$PATH"

    clear

    # Logging
    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DÉBUT DE L'EXECUTION DU SCRIPT D'INSTALLATION  ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Exécution des fonctions d'installation
    install_aur_yay
    install_full_packages

    sudo systemctl enable bluetooth.service
    sudo systemctl enable sshd.service
    sudo systemctl enable --now cups.service

    chsh -s /usr/bin/zsh # To set Zsh as the default SHELL
    chsh -s /usr/bin/nu  # To set NuShell as the default SHELL

    sudo freshclam
    sudo systemctl enable --now clamav-freshclam.service
    sudo systemctl enable --now clamav-daemon.service

    sudo cp clamtk-kde.desktop /usr/share/kservices5/ServiceMenus/

    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    sudo paccache -rk

    sudo systemctl enable --now cockpit.socket

    read -p "Souhaitez-vous configurer votre compte git ? (Y/n) " git

    if [[ "$git" =~ ^[yY]$ ]]; then
        echo
        clear
        echo "Configuration des identifiants github..." | tee -a "$LOG_FILES_INSTALL"
        echo
        read -p " Entrez votre nom d'utilisateur [git] : " git_name
        read -p " Entrez votre adresse email [git] : " git_email	

        git config --global user.name "${git_name}"
        git config --global user.email "${git_email}"
      
    fi

    ;;

  *)
    usage
    ;;
esac