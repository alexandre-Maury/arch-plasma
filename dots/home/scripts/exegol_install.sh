#!/bin/bash

set -e  # Arrêt du script en cas d'erreur

echo "Installation de l'outils de pentest Exegol :"

declare -A tools

tools=(
    [exegol]="https://github.com/ThePorgs/Exegol.git"
)

base_dir="$HOME/.config/pentest"
mkdir -p "$base_dir"

for tool in "${!tools[@]}"; do

    script_dir="$base_dir/$tool"
    repo_url="${tools[$tool]}"
    
    echo "Installation de $tool..."
    git clone "$repo_url" "$script_dir"
    cd "$script_dir"
    
    if ! command -v pip &>/dev/null; then
        echo "pip n'est pas installé. Installation de pip..."
        python3 -m ensurepip --upgrade
    fi
    
    echo "Création de l'environnement virtuel dans $script_dir/.venv..."
    python3 -m venv "$script_dir/.venv"
    
    echo "Activation de l'environnement virtuel..."
    source "$script_dir/.venv/bin/activate"
    
    if [ -f "requirements.txt" ]; then
        echo "Installation des paquets Python depuis requirements.txt..."
        pip install -r requirements.txt
    else
        echo "Aucun fichier requirements.txt trouvé pour $tool. Vous pouvez l'ajouter plus tard."
    fi
    
    echo "alias $tool=\"clear && cd $script_dir && source .venv/bin/activate && python3 $tool.py -v\"" | tee -a ~/.zshrc
    deactivate
    echo "Installation de $tool terminée."
    echo
done

clear

echo "alias quit=\"deactivate\" " | tee -a ~/.zshrc
echo "Installation terminée : redémarrez votre poste ou exécutez la commande => source $HOME/.zshrc"
