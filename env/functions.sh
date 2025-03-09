#!/usr/bin/env bash

# script functions.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
LIGHT_CYAN='\033[0;96m'
RESET='\033[0m'


##############################################################################
## Vérification de la connexion Internet                                           
##############################################################################
check_internet() {
  echo "Vérification de la connexion Internet..."
  if ! curl -s --head https://archlinux.org | head -n 1 | grep "200 OK" > /dev/null; then
    echo "⚠️ Avertissement : Pas de connexion Internet ! Certaines fonctionnalités peuvent ne pas fonctionner."
  fi
}


##############################################################################
## Formatage du prompt                                          
##############################################################################
log_prompt() {
    local log_level="$1" # INFO - WARNING - ERROR - SUCCESS
    local log_date="$(date +"%Y-%m-%d %H:%M:%S")"

    case "${log_level}" in

        "SUCCESS")
            log_color="${GREEN}"
            log_status='SUCCESS'
            ;;
        "WARNING")
            log_color="${YELLOW}"
            log_status='WARNING'
            ;;
        "ERROR")
            log_color="${RED}"
            log_status='ERROR'
            ;;
        "INFO")
            log_color="${LIGHT_CYAN}"
            log_status='INFO'
            ;;
        *)
            log_color="${RESET}" # Au cas où un niveau inconnu est utilisé
            log_status='UNKNOWN'
            ;;
    esac

    echo -ne "${log_color} [ ${log_status} ] "${log_date}" ==> ${RESET}"

}

##############################################################################
## Installation avec yay                                         
##############################################################################
install_with_yay() {

    local package="$1"

    # Vérifier si le paquet est déjà installé
    if yay -Qi "$package" > /dev/null 2>&1; then
        echo "Le paquet $package est déjà installé..." | tee -a "${LOG_FILES_INSTALL:-/tmp/install_log.txt}"
        return 0
    else
        echo "Installation du paquet $package..." | tee -a "${LOG_FILES_INSTALL:-/tmp/install_log.txt}"
        if yay -S --needed --noconfirm --ask=4 "$package" 2>&1 | tee -a "${LOG_FILES_INSTALL:-/tmp/install_log.txt}"; then
            echo "Installation réussie pour $package..." | tee -a "${LOG_FILES_INSTALL:-/tmp/install_log.txt}"
        else
            echo "Erreur d'installation pour $package..." | tee -a "${LOG_FILES_INSTALL:-/tmp/install_log.txt}"
            return 1
        fi
    fi
}


##############################################################################
## Installation avec pacman                                         
##############################################################################
install_with_pac() {
    local package="$1"

    # Vérifier si le paquet est déjà installé
    if pacman -Qi "$package" > /dev/null 2>&1; then
        echo "Le paquet $package est déjà installé..." | tee -a "${LOG_FILES_INSTALL:-/tmp/install_log.txt}"
        return 0
    else
        echo "Installation du paquet $package..." | tee -a "${LOG_FILES_INSTALL:-/tmp/install_log.txt}"
        if sudo pacman -S --needed --noconfirm --ask=4 "$package" 2>&1 | tee -a "${LOG_FILES_INSTALL:-/tmp/install_log.txt}"; then
            echo "Installation réussie pour $package..." | tee -a "${LOG_FILES_INSTALL:-/tmp/install_log.txt}"
        else
            echo "Erreur d'installation pour $package..." | tee -a "${LOG_FILES_INSTALL:-/tmp/install_log.txt}"
            return 1
        fi
    fi
}


##############################################################################
## clean_system - nettoyage de l'installation                                             
##############################################################################
clean_system() {

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== DEBUT DU NETTOYAGE DE L'INSTALLATION ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

    sudo rm -rf $SCRIPT_DIR
    sudo rm -rf $TARGET_DIR/tmp

    echo "" | tee -a "$LOG_FILES_INSTALL"
    echo "=== FIN DU NETTOYAGE DE L'INSTALLATION ===" | tee -a "$LOG_FILES_INSTALL"
    echo "" | tee -a "$LOG_FILES_INSTALL"

}















