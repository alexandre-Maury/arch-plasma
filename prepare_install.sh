#!/usr/bin/env bash

set -e  # Quitte immédiatement en cas d'erreur.

# Variables
REPO_URL="https://github.com/alexandre-Maury/arch-plasma.git"
export TARGET_DIR="/opt/build"

# Définition du répertoire du script pour le clean system
export SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Vérification si le script est exécuté en tant que root
if [ "$EUID" -eq 0 ]; then
  echo "Ce script ne doit pas être exécuté en tant qu'utilisateur root."
  exit 1
fi

# Vérification si git est installé
if ! command -v git &> /dev/null; then
  echo "Erreur : git n'est pas installé. Installez-le et réessayez."
  exit 1
fi

# Création du répertoire cible
echo "Création du répertoire cible : $TARGET_DIR/arch-plasma"
sudo mkdir -p "$(dirname "$TARGET_DIR/arch-plasma")"

# Mise à jour ou clonage du dépôt
if [ -d "$TARGET_DIR/arch-plasma/.git" ]; then
  echo "Mise à jour du dépôt existant..."
  sudo git -C "$TARGET_DIR/arch-plasma" pull
else
  echo "Clonage du dépôt dans $TARGET_DIR/arch-plasma..."
  sudo git clone "$REPO_URL" "$TARGET_DIR/arch-plasma"
fi

# Ajustement des permissions
echo "Ajustement des permissions..."
sudo chown -R $(id -u):$(id -g) "$TARGET_DIR"

# Définition du chemin du script d'installation
INSTALL_SCRIPT="$TARGET_DIR/arch-plasma/setup/install.sh"

# Vérification de l'existence du script d'installation
if [ ! -f "$INSTALL_SCRIPT" ]; then
  echo "Erreur : Le script d'installation n'a pas été trouvé à l'emplacement attendu ($INSTALL_SCRIPT)."
  exit 1
fi

# Exécution du script d'installation
chmod +x "$INSTALL_SCRIPT"
"$INSTALL_SCRIPT" --install

echo "=== FIN DE L'INSTALLATION - REDÉMARREZ VOTRE SYSTÈME ==="


# 1. Thèmes de bureau (Plasma) => ~/.local/share/plasma/desktoptheme/
# 2. Thèmes d'icônes => ~/.local/share/icons
# 3. Thèmes de fenêtres et de bordures => ~/.local/share/kdecoration/
# 4. Thèmes de curseur => ~/.local/share/icons
# 5. Thèmes de couleurs => ~/.local/share/color-schemes/