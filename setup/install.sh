#!/usr/bin/bash

set -e  # Quitte immédiatement en cas d'erreur.

source $TARGET_DIR/arch-plasma/env/system.sh 
source $TARGET_DIR/arch-plasma/env/functions.sh
source $TARGET_DIR/arch-plasma/conf/config.sh
source $TARGET_DIR/arch-plasma/conf/aur.sh

source $TARGET_DIR/arch-plasma/fct-install/install_aur.sh
source $TARGET_DIR/arch-plasma/fct-install/install_services.sh
source $TARGET_DIR/arch-plasma/fct-install/install_repo.sh
source $TARGET_DIR/arch-plasma/fct-install/install_impression.sh
source $TARGET_DIR/arch-plasma/fct-install/install_secure.sh
source $TARGET_DIR/arch-plasma/fct-install/install_dots.sh


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
    install_repo_autocpufreq
    install_repo_ohmyzsh
    install_repo_asdf
    install_cups
    install_firewall
    install_clam
    install_vpn
    install_dotfiles
    activate_services

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