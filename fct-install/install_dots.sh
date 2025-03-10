#!/bin/bash

# script install_dotfiles.sh

##############################################################################
## install_all_dotfiles - Configuration du systeme avec dotfiles                                               
##############################################################################
install_dotfiles() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DE L'INSTALLATION DES FICHIER DE CONFIGURATION ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    cp -rf $TARGET_DIR/arch-plasma/dots/config/Kvantum $HOME/.config/Kvantum
    cp -rf $TARGET_DIR/arch-plasma/dots/config/nvim $HOME/.config/nvim
    cp -rf $TARGET_DIR/arch-plasma/dots/config/pentest $HOME/.config/pentest

    cp -rf $TARGET_DIR/arch-plasma/dots/home/scripts $HOME/scripts
    cp -rf $TARGET_DIR/arch-plasma/dots/home/vimrc $HOME/.vimrc

    tar -xzvf $TARGET_DIR/arch-plasma/dots/local/share/aurorae/themes/Shadows-Aurorae.tar.gz -C $HOME/.local/share/aurorae/themes
    tar -xzvf $TARGET_DIR/arch-plasma/dots/local/share/aurorae/themes/Shadows-Blur-Aurorae.tar.gz -C $HOME/.local/share/aurorae/themes

    tar -xJvf $TARGET_DIR/arch-plasma/dots/local/share/icons/candy-icons.tar.xz -C $HOME/.local/share/icons
    tar -xzvf $TARGET_DIR/arch-plasma/dots/local/share/icons/Shadows-Dark-Icons.tar.gz -C $HOME/.local/share/icons

    cp -rf $TARGET_DIR/arch-plasma/dots/local/share/color-schemes/ShadowsDarkColorscheme.colors $HOME/.local/share/color-schemes/ShadowsDarkColorscheme.colors
    cp -rf $TARGET_DIR/arch-plasma/dots/local/share/Konsole/Shadows-Konsole.colorscheme $HOME/.local/share/Konsole/Shadows-Konsole.colorscheme

    tar -xzvf $TARGET_DIR/arch-plasma/dots/local/share/plasma/desktoptheme/Shadows-Plasma.tar.gz -C $HOME/.local/share/plasma/desktoptheme
    tar -xzvf $TARGET_DIR/arch-plasma/dots/local/share/plasma/look-and-feel/Shadows-Global.tar.gz -C $HOME/.local/share/plasma/look-and-feel
    tar -xzvf $TARGET_DIR/arch-plasma/dots/local/share/plasma/plasmoids/Shadows-Global.tar.gz -C $HOME/.local/share/plasma/plasmoids

    tar -xzvf $TARGET_DIR/arch-plasma/dots/local/share/themes/Shadows-GTK.tar.gz -C $HOME/.local/share/themes

    sudo cp -rf $TARGET_DIR/arch-plasma/dots/etc/sddm/Shades-of-purple-plasma-6 /usr/share/sddm/themes

    sudo cp -rf $TARGET_DIR/arch-plasma/dots/etc/sddm/sddm.conf.d/kde_settings.conf /etc/sddm.conf.d/kde_settings.conf

    chmod +x $HOME/scripts/*

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'INSTALLATION DES FICHIER DE CONFIGURATION ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}