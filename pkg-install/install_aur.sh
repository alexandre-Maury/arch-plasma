#!/usr/bin/bash

# script install_aur.sh


##############################################################################
## install_aur_yay - Installation de YAY                                               
##############################################################################
install_aur_yay() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DU PAQUET YAY ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Vérifier si le paquet est déjà installé
    if pacman -Qi yay 2>&1; then
        echo "Le paquets yay est déjà installé..." | tee -a "$LOG_FILES_INSTALL"
    else
        echo "Installation du paquets yay..." | tee -a "$LOG_FILES_INSTALL"
        git clone https://aur.archlinux.org/yay-bin.git $TARGET_DIR/tmp/yay-bin
        cd $TARGET_DIR/tmp/yay-bin || exit
        makepkg -si --noconfirm && cd .. 
        echo "Installation du paquets yay terminé..." | tee -a "$LOG_FILES_INSTALL"
    fi

    yay -Syu --devel --noconfirm

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DU PAQUET YAY ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}

##############################################################################
## install_full_packages - Installation des utilitaires                                
##############################################################################
install_full_packages() {

    local pkg_utils_pac="$TARGET_DIR/arch-plasma/pkg-files/pkg_utils_pac.txt"
    local pkg_utils_yay="$TARGET_DIR/arch-plasma/pkg-files/pkg_utils_yay.txt"

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DES APPLICATIONS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    echo "Installation des packages avec pacman..." | tee -a "$LOG_FILES_INSTALL"
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        echo "Lancement de la recherche du paquet : $line"
        install_with_yay "$line"
    done < "$pkg_utils_pac"

    echo "Installation des packages avec yay..." | tee -a "$LOG_FILES_INSTALL"
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        install_with_yay "$line"
    done < "$pkg_utils_yay"

    echo "" | tee -a "$LOG_FILES_INSTALL"

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DES APPLICATIONS ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}