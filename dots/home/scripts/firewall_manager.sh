#!/bin/bash

# Configuration des ensembles dynamiques
NFTABLES_TABLE="inet firewall"
WHITELIST_SET="whitelist"
BLACKLIST_SET="blacklist"
WHITELIST_IFACE="WHITELIST_IFACE"

# Couleurs pour le menu
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m" # No Color

# Fonction pour afficher l'usage du script
usage() {
    echo -e "${BLUE}
╔════════════════════════════════════════════════════════╗
║                NFTables Manager                        ║
╚════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${GREEN}Usage: $0${NC}"
    echo
    echo -e "${YELLOW}Options principales :${NC}"
    echo
    echo "  1. Ajouter une IP à un ensemble"
    echo "  2. Supprimer une IP d'un ensemble"
    echo "  3. Lister les IP d'un ensemble"
    echo "  4. Ajouter une interface à la whitelist"
    echo "  5. Supprimer une interface de la whitelist"
    echo "  6. Lister les interfaces de la whitelist"
    echo "  7. Quitter"
    echo
    echo -e "${YELLOW}Ensembles disponibles :${NC}"
    echo
    echo "  - Whitelist"
    echo "  - Blacklist"
    echo
    echo -e "${YELLOW}Exemples :${NC}"
    echo
    echo "  Ajouter une IP à la whitelist :"
    echo "    > Choisissez l'option 1, puis sélectionnez 'Whitelist'."
    echo
    echo "  Supprimer une IP de la blacklist :"
    echo "    > Choisissez l'option 2, puis sélectionnez 'Blacklist'."
    echo
    exit 1
}

# Fonction pour lister les adresses IP d'un ensemble
list_ips() {
    local SET_NAME=$1
    echo ""
    clear
    echo -e "${YELLOW}Adresses IP dans l'ensemble $SET_NAME :${NC}"
    echo
    sudo nft list set $NFTABLES_TABLE $SET_NAME | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
    echo
}

# Fonction pour ajouter une IP
add_ip() {
    local SET_NAME=$1
    echo ""
    clear
    read -p "Entrez l'adresse IP à ajouter : " IP
    manage_ip "add" "$SET_NAME" "$IP"
}

# Fonction pour supprimer une IP
delete_ip() {
    local SET_NAME=$1
    echo ""
    clear
    echo -e "${YELLOW}Liste des adresses IP dans l'ensemble $SET_NAME :${NC}"
    list_ips "$SET_NAME"
    read -p "Entrez l'adresse IP à supprimer : " IP
    manage_ip "delete" "$SET_NAME" "$IP"
}

# Fonction pour ajouter ou supprimer une IP
manage_ip() {
    local ACTION=$1
    local SET_NAME=$2
    local IP=$3

    echo ""
    clear

    # Validation de l'adresse IP
    if ! [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}❌ Adresse IP invalide : $IP.${NC}"
        return 1
    fi

    # Exécution de la commande nftables
    CMD="sudo nft $ACTION element $NFTABLES_TABLE $SET_NAME { $IP }"
    echo -e "${BLUE}Exécution de la commande : $CMD${NC}"
    eval "$CMD"

    # Vérification du succès
    if [ $? -eq 0 ]; then
        echo && clear
        echo -e "${GREEN}✅ Succès : IP $IP $ACTION à l'ensemble $SET_NAME.${NC}"
    else
        echo && clear
        echo -e "${RED}❌ Échec : Impossible de $ACTION l'IP $IP à l'ensemble $SET_NAME.${NC}"
        return 1
    fi

    # Affichage du contenu de l'ensemble après modification
    list_ips "$SET_NAME"
}

# Fonction pour valider une interface
validate_interface() {
    local INTERFACE=$1
    if ! ip link show "$INTERFACE" > /dev/null 2>&1; then
        echo -e "${RED}❌ Interface $INTERFACE introuvable.${NC}"
        return 1
    fi
    return 0
}

# Fonction pour gérer les interfaces
manage_interface() {

    local ACTION=$1
    local INTERFACE=$2

    echo ""
    clear

    # Validation de l'interface
    if ! validate_interface "$INTERFACE"; then
        return 1
    fi

    # Vérifier si l'interface est déjà dans l'ensemble (pour l'ajout)
    if [[ "$ACTION" == "add" ]]; then
        # Récupérer la liste des interfaces existantes
        EXISTING_INTERFACES=$(sudo nft list set $NFTABLES_TABLE $WHITELIST_IFACE 2>/dev/null | \
                            awk '/elements = {/,/}/' | \
                            grep -o '"[^"]*"' | \
                            tr -d '"')

        # Vérifier si l'interface existe déjà
        while read -r existing_interface; do
            if [[ "$existing_interface" == "$INTERFACE" ]]; then
                echo
                echo -e "${YELLOW}⚠️  L'interface $INTERFACE est déjà dans l'ensemble $WHITELIST_IFACE.${NC}"
                return 0
            fi
        done <<< "$EXISTING_INTERFACES"
    fi

    # Exécution de la commande nftables
    CMD="sudo nft $ACTION element $NFTABLES_TABLE $WHITELIST_IFACE { $INTERFACE }"
    echo -e "${BLUE}Exécution de la commande : $CMD${NC}"
    eval "$CMD"

    # Vérification du succès
    if [ $? -eq 0 ]; then
        echo 
        echo -e "${GREEN}✅ Succès : Interface $INTERFACE $ACTION à l'ensemble $WHITELIST_IFACE.${NC}"
    else
        echo && clear
        echo -e "${RED}❌ Échec : Impossible de $ACTION l'interface $INTERFACE à l'ensemble $WHITELIST_IFACE.${NC}"
        return 1
    fi

    # Affichage du contenu de l'ensemble après modification
    list_interfaces
}

# Fonction pour lister les interfaces dans l'ensemble
list_interfaces() {
    echo ""
    clear
    echo -e "${YELLOW}Interfaces dans l'ensemble $WHITELIST_IFACE :${NC}"

    # Récupérer et formater la liste des interfaces
    INTERFACES=$(sudo nft list set $NFTABLES_TABLE $WHITELIST_IFACE 2>/dev/null | \
                awk '/elements = {/,/}/' | \
                grep -o '"[^"]*"' | \
                tr -d '"')

    if [ -z "$INTERFACES" ]; then
        echo "Aucune interface dans l'ensemble $WHITELIST_IFACE."
    else
        echo
        echo "Interfaces trouvées :"
        echo
        echo "$INTERFACES" | while read -r interface; do
            echo "- $interface"
        done
    fi

    echo
}

# Fonction pour afficher le menu principal
show_menu() {
    clear
    echo -e "${BLUE}
╔════════════════════════════════════════════════════════╗
║                NFTables Manager                        ║
╚════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${YELLOW}Options principales :${NC}"
    echo
    echo "  1. Ajouter une IP à un ensemble"
    echo "  2. Supprimer une IP d'un ensemble"
    echo "  3. Lister les IP d'un ensemble"
    echo "  4. Ajouter une interface à la whitelist"
    echo "  5. Supprimer une interface de la whitelist"
    echo "  6. Lister les interfaces de la whitelist"
    echo "  7. Quitter"
    echo
}

# Fonction pour afficher le menu des ensembles
show_set_menu() {
    echo
    echo -e "${YELLOW}Ensembles disponibles :${NC}"
    echo
    echo "  1. Whitelist"
    echo "  2. Blacklist"
    echo
}

# Fonction pour sélectionner un ensemble
select_set() {
    local CHOICE=$1
    case "$CHOICE" in
        1) echo "$WHITELIST_SET" ;;
        2) echo "$BLACKLIST_SET" ;;
        *) echo "" ;;
    esac
}

# Démarrage de l'interface interactive
while true; do
    show_menu
    read -p "Choisissez une option (1-7) : " MAIN_CHOICE

    case "$MAIN_CHOICE" in
        1)
            # Ajouter une IP
            echo
            show_set_menu
            read -p "Choisissez un ensemble (1-2) : " SET_CHOICE
            SET_NAME=$(select_set "$SET_CHOICE")

            if [ -z "$SET_NAME" ]; then
                echo -e "${RED}❌ Choix d'ensemble invalide.${NC}"
                continue
            fi

            add_ip "$SET_NAME"
            ;;

        2)
            # Supprimer une IP
            echo
            show_set_menu
            read -p "Choisissez un ensemble (1-2) : " SET_CHOICE
            SET_NAME=$(select_set "$SET_CHOICE")

            if [ -z "$SET_NAME" ]; then
                echo -e "${RED}❌ Choix d'ensemble invalide.${NC}"
                continue
            fi

            delete_ip "$SET_NAME"
            ;;

        3)
            # Lister les IP d'un ensemble
            echo
            show_set_menu
            read -p "Choisissez un ensemble (1-2) : " SET_CHOICE
            SET_NAME=$(select_set "$SET_CHOICE")

            if [ -z "$SET_NAME" ]; then
                echo -e "${RED}❌ Choix d'ensemble invalide.${NC}"
                continue
            fi

            list_ips "$SET_NAME"
            ;;

        4)
            # Ajouter une interface à la whitelist
            echo
            read -p "Entrez le nom de l'interface à ajouter : " INTERFACE
            manage_interface "add" "$INTERFACE"
            ;;

        5)
            # Supprimer une interface de la whitelist
            echo
            list_interfaces
            read -p "Entrez le nom de l'interface à supprimer : " INTERFACE
            manage_interface "delete" "$INTERFACE"
            ;;

        6)
            # Lister les interfaces de la whitelist
            echo
            list_interfaces
            ;;

        7)
            # Quitter
            echo
            echo -e "${GREEN}Au revoir !${NC}"
            exit 0
            ;;

        *)
            echo -e "${RED}❌ Option invalide. Veuillez choisir une option entre 1 et 7.${NC}"
            ;;
    esac

    read -p "Appuyez sur Entrée pour continuer..."
done