FROM cirrusci/flutter:latest

WORKDIR /app
COPY . .

# Activer Flutter et récupérer les dépendances
RUN flutter pub get

# Exécuter les tests unitaires
CMD ["flutter", "test"]
