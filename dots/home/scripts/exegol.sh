#!/bin/bash

# https://github.com/jasonxtn/Lucille

set -e  # Arrêt du script en cas d'erreur

echo "Installation de l'outils de pentest Exegol V2 :"

pipx install exegol
pipx ensurepath

echo "" >> ~/.zshrc
echo "# Exegol" >> ~/.zshrc
echo "alias exegol='sudo -E $(which exegol)'" >> ~/.zshrc
pipx install argcomplete
# autoload -U compinit
# compinit
eval "$(register-python-argcomplete --no-defaults exegol)"

echo "Installation terminée : redémarrez votre poste ou exécutez la commande => source $HOME/.zshrc"