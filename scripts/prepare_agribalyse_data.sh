#!/bin/bash

# Script pour préparer les fichiers CSV d'Agribalyse pour l'application
# Auteur: Claude
# Date: 2023

# Dossiers de travail
RAW_DIR="data_raw"
OUTPUT_DIR="assets/data"

# Créer les dossiers s'ils n'existent pas
mkdir -p "$RAW_DIR"
mkdir -p "$OUTPUT_DIR"

echo "=== Préparation des données Agribalyse ==="
echo ""

# Vérifier la présence des fichiers CSV source
if [ ! -f "$RAW_DIR/agribalyse_products_raw.csv" ] || [ ! -f "$RAW_DIR/agribalyse_carbon_raw.csv" ] || [ ! -f "$RAW_DIR/agribalyse_water_raw.csv" ]; then
    echo "ERREUR: Certains fichiers source manquent dans le dossier $RAW_DIR."
    echo "Veuillez placer vos 3 fichiers CSV Agribalyse dans ce dossier avec les noms suivants:"
    echo "  - agribalyse_products_raw.csv (contenant code, nom, catégorie, sous-catégorie)"
    echo "  - agribalyse_carbon_raw.csv (contenant code, valeur CO2, détails production/transport/emballage/transformation)"
    echo "  - agribalyse_water_raw.csv (contenant code, valeur eau)"
    exit 1
fi

echo "Traitement des fichiers CSV d'Agribalyse..."

# Préparer le fichier des produits
echo "Traitement du fichier de produits..."
echo "code,name,category,subCategory" > "$OUTPUT_DIR/agribalyse_products.csv"
tail -n +2 "$RAW_DIR/agribalyse_products_raw.csv" | awk -F, '{print $1","$2","$3","$4}' >> "$OUTPUT_DIR/agribalyse_products.csv"

# Préparer le fichier des empreintes carbone
echo "Traitement du fichier d'empreinte carbone..."
echo "code,value,production,transport,packaging,processing" > "$OUTPUT_DIR/agribalyse_carbon.csv"
tail -n +2 "$RAW_DIR/agribalyse_carbon_raw.csv" | awk -F, '{print $1","$2","$3","$4","$5","$6}' >> "$OUTPUT_DIR/agribalyse_carbon.csv"

# Préparer le fichier des empreintes eau
echo "Traitement du fichier d'empreinte eau..."
echo "code,value" > "$OUTPUT_DIR/agribalyse_water.csv"
tail -n +2 "$RAW_DIR/agribalyse_water_raw.csv" | awk -F, '{print $1","$2}' >> "$OUTPUT_DIR/agribalyse_water.csv"

echo ""
echo "Traitement terminé. Les fichiers ont été générés dans le dossier $OUTPUT_DIR."
echo "Veuillez exécuter 'flutter pub get' pour mettre à jour les dépendances."
echo ""
echo "Structure recommandée pour vos fichiers CSV source:"
echo "1. agribalyse_products_raw.csv:"
echo "   - Colonne 1: code (identifiant unique du produit)"
echo "   - Colonne 2: nom du produit"
echo "   - Colonne 3: catégorie"
echo "   - Colonne 4: sous-catégorie"
echo ""
echo "2. agribalyse_carbon_raw.csv:"
echo "   - Colonne 1: code (même que dans products)"
echo "   - Colonne 2: valeur totale d'empreinte carbone (kg CO2 eq)"
echo "   - Colonne 3: production (kg CO2 eq)"
echo "   - Colonne 4: transport (kg CO2 eq)"
echo "   - Colonne 5: emballage (kg CO2 eq)"
echo "   - Colonne 6: transformation (kg CO2 eq)"
echo ""
echo "3. agribalyse_water_raw.csv:"
echo "   - Colonne 1: code (même que dans products)"
echo "   - Colonne 2: valeur d'empreinte eau (litres)"
echo ""
echo "=== Fin du traitement ===" 