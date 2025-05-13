#!/bin/bash

# Script pour télécharger les animations Lottie nécessaires
# Exécutez ce script après avoir configuré Flutter

# Créer le dossier d'animations s'il n'existe pas
mkdir -p assets/animations

# Liste des animations à télécharger
declare -A animations=(
  ["scan_animation.json"]="https://assets5.lottiefiles.com/packages/lf20_rqcjx9o8.json"
  ["barcode_scanner_idle.json"]="https://assets2.lottiefiles.com/packages/lf20_in4cufsz.json"
  ["empty_list.json"]="https://assets8.lottiefiles.com/packages/lf20_wnqlfojb.json"
  ["eco_animation.json"]="https://assets9.lottiefiles.com/packages/lf20_v4fdfbwe.json"
  ["success_animation.json"]="https://assets10.lottiefiles.com/packages/lf20_aizlmwn7.json"
)

# Télécharger chaque animation
for anim_name in "${!animations[@]}"; do
  url="${animations[$anim_name]}"
  echo "Téléchargement de $anim_name depuis $url..."
  
  if command -v curl &> /dev/null; then
    curl -o "assets/animations/$anim_name" "$url"
  elif command -v wget &> /dev/null; then
    wget -O "assets/animations/$anim_name" "$url"
  else
    echo "Erreur: curl ou wget est requis pour télécharger les animations."
    exit 1
  fi
  
  if [ $? -eq 0 ]; then
    echo "✓ Animation $anim_name téléchargée avec succès."
  else
    echo "✗ Échec du téléchargement de $anim_name."
  fi
done

echo "Animations téléchargées dans le dossier assets/animations/"
echo "N'oubliez pas d'exécuter 'flutter pub get' pour installer les dépendances nécessaires." 