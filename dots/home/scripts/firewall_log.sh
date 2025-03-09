#!/bin/bash

# Surveiller les logs en temps réel pour IPv4
# ./firewall.sh --logs --live --ipv4

# Voir le filtre pour port il récupére 8080 8081 ... pour 80 entrer dans le filtre ...

# Variables

nftables_dir="/var/log/nftables"
nftables_log="$nftables_dir/nftables.log"
nftables_csv="$nftables_dir/nftables.csv"
backup_dir="${nftables_dir}/backups"
export_to_file=false
max_size_file="100M"

ip_src=""
ip_dst=""
ipv4_filter=""
ipv6_filter=""
port_filter=""
proto_filter=""
output_format=""  # Par défaut, la sortie est en texte
action=""

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fonction pour afficher l'usage avec des couleurs
usage() {
    echo -e "${BLUE}
╔════════════════════════════════════════════════════════╗
║                NFTables Log Manager                    ║
╚════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${GREEN}Usage: $0 [Option principales] [Filtres] [Output]${NC}"
    echo
    echo -e "${YELLOW}Options principales :${NC}"
    echo
    echo "  --live                 Afficher les logs en temps réel"
    echo "  --today                Afficher les logs d'aujourd'hui"
    echo "  --stats                Afficher les statistiques des rejets"
    echo "  --date                 Afficher les logs pour une date et plage horaire"
    echo "  --backup               Créer une sauvegarde du fichier (log|csv)"
    echo "  --delete               Vider le fichier (log|csv)"
    echo
    echo -e "${YELLOW}[Facultatif] Filtres :${NC}"
    echo
    echo "  --src                  Filtrer les logs d'une adresse ip source"
    echo "  --dst                  Filtrer les logs d'une adresse ip source"
    echo "  --ipv4                 Filtrer les logs IPv4"
    echo "  --ipv6                 Filtrer les logs IPv6"
    echo "  --port                 Filtrer par port"
    echo "  --proto                Filtrer par protocole (tcp|udp|icmp ...)"
    echo
    echo -e "${YELLOW}[Facultatif] Output :${NC}"
    echo
    echo "  --output               Exporter les logs dans (csv|log)"
    echo
    echo "Exemples :"
    echo
    echo "  $0 --live --ipv4 --port 80 --proto tcp --output csv"
    echo "  $0 --live --src 192.168.1.243 --dst 192.168.1.134 --output csv"
    echo "  $0 --date 08/02/2025 13h-17h --output log" 
    echo "  $0 --today --ipv6 --port 80 --proto tcp --output csv" 
    echo "  $0 --stats --output log"
    echo "  $0 --delete log"
    echo "  $0 --backup csv"
    exit 1
}

# Fonction pour gérer l'affichage et l'export des logs
log_output() {

    local line="$1"

    if [[ "$output_format" == "log" ]]; then

        echo "$line" | sudo tee -a "$nftables_log" > /dev/null

    elif [[ "$output_format" == "csv" ]]; then
        
        timestamp=$(echo "$line" | awk '{print $1" "$2" "$3}')
        action=$(echo "$line" | grep -oP '\[NFT-DROP\] \K[^[:space:]]+')
        src_ip=$(echo "$line" | grep -oP 'SRC=\K[^[:space:]]+')
        dst_ip=$(echo "$line" | grep -oP 'DST=\K[^[:space:]]+')
        proto=$(echo "$line" | grep -oP 'PROTO=\K[^[:space:]]+')
        dpt=$(echo "$line" | grep -oP 'DPT=\K[^[:space:]]+')

        # Formatage de la ligne CSV
        csv_line="$timestamp,$action,$src_ip,$dst_ip,$proto,$dpt"

        echo "Timestamp,Action,Source IP,Destination IP,Protocol,Destination Port" > "$nftables_csv"
        echo "$csv_line" >> "$nftables_csv"

    else
        echo $line
    fi
}


# Fonction pour traiter les logs en temps réel
process_live() {
    clear
    echo
    echo -e "${BLUE}Affichage des logs en temps réel (Ctrl+C pour quitter)${NC}"
    echo
    echo -e "${YELLOW}Filtres actifs :${NC}"
    echo
    [[ -n "$ip_src" ]] && echo -e "- IP SOURCE : ${GREEN}$ip_src${NC}"
    [[ -n "$ip_dst" ]] && echo -e "- IP DESTINATION : ${GREEN}$ip_dst${NC}"
    [[ -n "$ipv4_filter" ]] && echo -e "- Type IP : ${GREEN}IPV4${NC}"
    [[ -n "$ipv6_filter" ]] && echo -e "- Type IP : ${GREEN}IPV6${NC}"
    [[ -n "$proto_filter" ]] && echo -e "- Protocole : ${GREEN}$proto_filter${NC}"
    [[ -n "$port_filter" ]] && echo -e "- Port : ${GREEN}$port_filter${NC}"
    echo
    echo "----------------------------------------"
    echo

    # Construction de la commande de filtrage
    local grep_cmd="grep --color=always \"NFT-DROP\" "

    [[ -n "$ip_src" ]] && grep_cmd+="| grep \"$ip_src\" "
    [[ -n "$ip_dst" ]] && grep_cmd+="| grep \"$ip_dst\" "
    [[ -n "$ipv4_filter" ]] && grep_cmd+="| grep -E \"$ipv4_filter\" "
    [[ -n "$ipv6_filter" ]] && grep_cmd+="| grep -E \"$ipv6_filter\" "
    [[ -n "$proto_filter" ]] && grep_cmd+="| grep \"$proto_filter\" "
    [[ -n "$port_filter" ]] && grep_cmd+="| grep \"$port_filter\" "

    # Gestion de l'interruption (Ctrl+C)
    trap "echo -e '\n${RED}Arrêt de la surveillance en temps réel${NC}'; exit 0" INT

    # Surveillance des logs en temps réel
    while read -r line; do
        log_output "$line"
    done < <(journalctl -f -t kernel | eval "$grep_cmd")
}


# Fonction pour traiter les logs du jour même 
process_today() {

    clear

    local since="$1"

    echo
    echo -e "${BLUE}Affichage des logs depuis : $since ${NC}"
    echo
    [[ -n "$ip_src" ]] && echo -e "- IP SOURCE : ${GREEN}$ip_src${NC}"
    [[ -n "$ip_dst" ]] && echo -e "- IP DESTINATION : ${GREEN}$ip_dst${NC}"
    [[ -n "$ipv4_filter" ]] && echo -e "- Type IP : ${GREEN}IPV4${NC}"
    [[ -n "$ipv6_filter" ]] && echo -e "- Type IP : ${GREEN}IPV6${NC}"
    [[ -n "$proto_filter" ]] && echo -e "- Protocole : ${GREEN}$proto_filter${NC}"
    [[ -n "$port_filter" ]] && echo -e "- Port : ${GREEN}$port_filter${NC}"
    echo
    echo "----------------------------------------"
    echo

    # Construction de la commande de filtrage
    local grep_cmd="grep --color=always \"NFT-DROP\" "

    [[ -n "$ip_src" ]] && grep_cmd+="| grep \"$ip_src\" "
    [[ -n "$ip_dst" ]] && grep_cmd+="| grep \"$ip_dst\" "
    [[ -n "$ipv4_filter" ]] && grep_cmd+="| grep -E \"$ipv4_filter\" "
    [[ -n "$ipv6_filter" ]] && grep_cmd+="| grep -E \"$ipv6_filter\" "
    [[ -n "$proto_filter" ]] && grep_cmd+="| grep \"$proto_filter\" "
    [[ -n "$port_filter" ]] && grep_cmd+="| grep \"$port_filter\" "

    echo "En cours de traitement ..."
    echo

    while read -r line; do
        log_output "$line"  # Utilisation de log_output pour l'affichage et l'export
    done < <(journalctl -t kernel --since "$since" | eval "$grep_cmd")

}

# Fonction pour traiter les logs d'une date et d'une plage horaire spécifiques
process_date() {

    clear
    
    local date="$1"
    local range="$2"
    local start_time end_time
    local filter=""

    # Convertir la date de JJ/MM/AAAA en AAAA-MM-JJ
    local formatted_date=$(echo "$date" | awk -F '/' '{print $3 "-" $2 "-" $1}')

    # Extraire l'heure de début et de fin en s'assurant qu'elles sont bien au format HH:MM
    start_time=$(echo "$range" | cut -d '-' -f 1 | sed -E 's/h([0-9]*)?$/:\1/')
    end_time=$(echo "$range" | cut -d '-' -f 2 | sed -E 's/h([0-9]*)?$/:\1/')

    # Corriger les cas où il n'y a pas de minutes (ex: "18h" → "18:")
    if [[ "$start_time" =~ ^[0-9]{1,2}:$ ]]; then
        start_time="${start_time}00"
    fi
    if [[ "$end_time" =~ ^[0-9]{1,2}:$ ]]; then
        end_time="${end_time}00"
    fi

    # Construire les arguments pour journalctl
    local since="${formatted_date} ${start_time}:00"
    local until="${formatted_date} ${end_time}:00"

    echo
    echo -e "${BLUE}Affichage des logs du $date entre $start_time et $end_time : ${NC}"
    echo
    echo -e "${YELLOW}Filtres actifs :${NC}"
    echo
    [[ -n "$ip_src" ]] && echo -e "- IP SOURCE : ${GREEN}$ip_src${NC}"
    [[ -n "$ip_dst" ]] && echo -e "- IP DESTINATION : ${GREEN}$ip_dst${NC}"
    [[ -n "$ipv4_filter" ]] && echo -e "- Type IP : ${GREEN}IPV4${NC}"
    [[ -n "$ipv6_filter" ]] && echo -e "- Type IP : ${GREEN}IPV6${NC}"
    [[ -n "$proto_filter" ]] && echo -e "- Protocole : ${GREEN}$proto_filter${NC}"
    [[ -n "$port_filter" ]] && echo -e "- Port : ${GREEN}$port_filter${NC}"
    [[ -n "$since" ]] && echo -e "- Heure de debut : ${GREEN}$since${NC}"
    [[ -n "$until" ]] && echo -e "- Heure de fin : ${GREEN}$until${NC}"
    echo
    echo "----------------------------------------"
    echo

    # Construction de la commande de filtrage
    local grep_cmd="grep --color=always \"NFT-DROP\" "

    [[ -n "$ip_src" ]] && grep_cmd+="| grep \"$ip_src\" "
    [[ -n "$ip_dst" ]] && grep_cmd+="| grep \"$ip_dst\" "
    [[ -n "$ipv4_filter" ]] && grep_cmd+="| grep -E \"$ipv4_filter\" "
    [[ -n "$ipv6_filter" ]] && grep_cmd+="| grep -E \"$ipv6_filter\" "
    [[ -n "$proto_filter" ]] && grep_cmd+="| grep \"$proto_filter\" "
    [[ -n "$port_filter" ]] && grep_cmd+="| grep \"$port_filter\" "

    while read -r line; do
        log_output "$line"
    done < <(journalctl -t kernel --since "$since" --until "$until" | eval "$grep_cmd")
}

# Fonction pour sauvegarder les logs
process_backup() {

    local file="$1"

    local backup_date=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/nftables_backup_$backup_date.tar.gz"
    
    sudo mkdir -p "$backup_dir"
    sudo tar -czf "$backup_file" -C "$(dirname "$file")" "$(basename "$file")"

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Sauvegarde créée : $backup_file${NC}"
    else
        echo -e "${RED}Erreur lors de la création de la sauvegarde${NC}"
        exit 1
    fi
}

process_delete() {

    local file="$1"
    echo "fichier : $file"
    sudo truncate -s 0 "$file"
}

# Fonction pour initialiser le fichier de log
init_log_file() {
    
    if [[ ! -d "$nftables_dir" ]]; then
        sudo mkdir -p "$nftables_dir"
    fi
    
    if [[ ! -f "$nftables_log" ]]; then
        sudo touch "$nftables_log"
        sudo chown root:nftables "$nftables_log"
        sudo chmod 640 "$nftables_log"
    fi

    if [[ ! -f "$nftables_csv" ]]; then
        sudo touch "$nftables_csv"
        sudo chown root:nftables "$nftables_csv"
        sudo chmod 640 "$nftables_csv"
    fi

    local size_log=$(du -b "$nftables_log" | cut -f1)
    local max_size_bytes_log=$(numfmt --from=iec "$max_size_file")

    local size_csv=$(du -b "$nftables_csv" | cut -f1)
    local max_size_bytes_csv=$(numfmt --from=iec "$max_size_file")

    if [[ $size_log -gt $max_size_bytes_log ]]; then

        clear
        echo
        echo "Votre fichier : $nftables_log à atteint la limitte de la taille fixé"
        echo
        read -p "Procéder à une rotation ? (y/N)" response

        if [[ "$response" == "y" ]]; then
            process_backup "$nftables_log"
            process_delete "$nftables_log"
        fi
    fi

    if [[ $size_csv -gt $max_size_bytes_csv ]]; then

        clear
        echo
        echo "Votre fichier : $nftables_csv à atteint la limitte de la taille fixé"
        echo
        read -p "Procéder à une rotation ? (y/N)" response

        if [[ "$response" == "y" ]]; then
            process_backup "$nftables_csv"
            process_delete "$nftables_csv"
        fi
    fi
}

# Vérification des options principales
case "$1" in

    --live)
        action="live"
        shift  # Supprime --live de la liste des arguments
        ;;

    --today)
        action="today"
        shift  # Supprime --today de la liste des arguments
        ;;

    --date)
        if [[ -z "$2" || -z "$3" ]]; then
            clear
            echo -e "${RED}Erreur: --date nécessite une date et une plage horaire${NC}"
            echo
            usage
        fi
        action="date"
        date="$2"
        time_range="$3"
        shift 3 
        ;;

    --backup)
        action="backup"
        if [[ "${2}" == "log" ]]; then
            file_backup="$nftables_log"

        elif [[ "${2}" == "csv" ]]; then
            file_backup="$nftables_csv"

        fi
        shift 2
        ;;
    
    --delete)
        action="delete"
        if [[ "${2}" == "log" ]]; then
            file_delete="$nftables_log"

        elif [[ "${2}" == "csv" ]]; then
            file_delete="$nftables_csv"

        fi
        shift 2
        ;;

    *)
        clear
        usage
        ;;
esac


# Vérification des filtres et sorties
while [[ $# -gt 0 ]]; do
    case "$1" in

        --output)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erreur: --output nécessite une valeur${NC}"
                usage
            fi
            output_format="$2"  
            shift 2  
            ;;

        --ipv4)
            ipv4_filter="SRC=([0-9]{1,3}\.){3}[0-9]{1,3}"
            shift  
            ;;

        --ipv6) 
            ipv6_filter="SRC=([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}"
            shift  
            ;;

        --src)
            ip_src="SRC=${2}"
            shift 2  
            ;;

        --dst)
            ip_dst="DST=${2}"
            shift 2  
            ;;

        --port)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erreur: --port nécessite une valeur${NC}"
                usage
            fi
            port_filter="DPT=${2}"  
            shift 2  
            ;;

        --proto)
            if [[ -z "$2" ]]; then
                echo -e "${RED}Erreur: --proto nécessite une valeur${NC}"
                usage
            fi
            proto_filter="PROTO=${2}"  
            shift 2  
            ;;
        *)
            echo -e "${RED}Option non reconnue : $1${NC}"
            usage
            ;;
    esac
done




# Start

init_log_file

# Exécution de l'action principale
case "$action" in
    live)
        process_live
        ;;
    today)
        process_today "today"
        ;;
    date)
        process_date "$date" "$time_range"
        ;;
    backup)
        process_backup "$file_backup"
        ;;
    delete)
        process_delete "$file_delete"
        ;;
    *)
        echo -e "${RED}Erreur: Aucune action principale spécifiée${NC}"
        usage
        ;;
esac