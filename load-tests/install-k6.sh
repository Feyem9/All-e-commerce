#!/bin/bash

# Script d'installation automatique de K6 pour Linux
# Créé le: 18 Décembre 2025

echo "🚀 Installation de K6 Load Testing Tool"
echo "========================================"
echo ""

# Détection de la distribution Linux
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
fi

echo "📋 Système détecté: $OS $VER"
echo ""

# Fonction pour installer via apt (Ubuntu/Debian)
install_apt() {
    echo "📦 Installation via APT..."
    echo ""
    
    # Ajouter la clé GPG
    echo "1️⃣ Ajout de la clé GPG K6..."
    sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
    
    # Ajouter le repository
    echo "2️⃣ Ajout du repository K6..."
    echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
    
    # Mettre à jour et installer
    echo "3️⃣ Mise à jour des packages..."
    sudo apt-get update
    
    echo "4️⃣ Installation de K6..."
    sudo apt-get install -y k6
}

# Fonction pour installer via snap
install_snap() {
    echo "📦 Installation via SNAP..."
    echo ""
    
    if ! command -v snap &> /dev/null; then
        echo "⚠️  Snap n'est pas installé. Installation de snapd..."
        sudo apt-get update
        sudo apt-get install -y snapd
    fi
    
    echo "📥 Installation de K6 via snap..."
    sudo snap install k6
}

# Menu de sélection
echo "Choisissez une méthode d'installation:"
echo "1) APT (Ubuntu/Debian - Recommandé)"
echo "2) SNAP (Universel)"
echo "3) Annuler"
echo ""
read -p "Votre choix (1-3): " choice

case $choice in
    1)
        install_apt
        ;;
    2)
        install_snap
        ;;
    3)
        echo "❌ Installation annulée."
        exit 0
        ;;
    *)
        echo "❌ Choix invalide. Installation annulée."
        exit 1
        ;;
esac

echo ""
echo "✅ Vérification de l'installation..."
if command -v k6 &> /dev/null; then
    echo ""
    echo "🎉 K6 a été installé avec succès!"
    echo ""
    k6 version
    echo ""
    echo "📚 Prochaines étapes:"
    echo "   1. Lancer un test: k6 run frontend-load-test.js"
    echo "   2. Voir le README: cat README.md"
    echo "   3. Tester votre app: npm run test:frontend"
    echo ""
else
    echo ""
    echo "❌ Erreur: K6 n'a pas pu être installé."
    echo "   Essayez l'autre méthode ou consultez: https://k6.io/docs/getting-started/installation/"
    echo ""
    exit 1
fi
