#!/bin/bash

# script install_services.sh

##############################################################################
## activate_services - Activation des services                                              
##############################################################################
activate_services() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== ACTIVATION DES SERVICES ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    # Fonction pour loguer le succès ou l'échec
    log_status() {
        if [ $? -eq 0 ]; then
            echo "$1 - SUCCÈS" | tee -a "$LOG_FILES_INSTALL"
        else
            echo "$1 - ERREUR" | tee -a "$LOG_FILES_INSTALL"
        fi
    }

    # Activation des services

    systemctl --user enable --now pipewire.service
    log_status "Activation de pipewire.service"

    systemctl --user enable --now pipewire-pulse.service
    log_status "Activation de pipewire-pulse.service"

    systemctl --user enable --now wireplumber.service
    log_status "Activation de wireplumber.service"

    sudo systemctl enable --now cups.service
    log_status "Activation de cups.service"

    sudo systemctl enable bluetooth.service
    log_status "Activation de bluetooth.service"

    sudo usermod -aG libvirt $(whoami)
    sudo systemctl enable --now libvirtd.service
    log_status "Activation de libvirtd.service"

    sudo systemctl enable sshd.service
    log_status "Activation de sshd.service"

    sudo usermod -aG docker $(whoami)
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    log_status "Activation de docker.service"

    sudo systemctl enable --now systemd-journald.service
    log_status "Activation de systemd-journald.service"

    sudo systemctl enable --now nftables.service
    log_status "Activation de nftables.service"

    # Activation optionnelle (commentée dans votre script original)
    # sudo systemctl enable --now logrotate.service
    # log_status "Activation de logrotate.service"

    # sudo systemctl enable --now rsyslog.service
    # log_status "Activation de rsyslog.service"

    sudo systemctl enable --now cronie.service
    log_status "Activation de cronie.service"

    sudo freshclam
    sudo systemctl enable --now clamav-freshclam.service
    sudo systemctl enable --now clamav-daemon.service
    log_status "Activation de clamav-daemon.service"

    sudo systemctl enable --now sddm.service
    log_status "Activation de sddm.service"

    sudo systemctl enable --now cockpit.socket
    log_status "Activation de cockpit.service"

    chsh -s /usr/bin/nu  # To set NuShell as the default SHELL
    chsh -s /usr/bin/zsh # To set Zsh as the default SHELL

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DE L'ACTIVATION DES SERVICES ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"
}