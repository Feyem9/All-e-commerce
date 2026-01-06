#!/bin/bash

# 🌟 Script pour réveiller le backend Render

BACKEND_URL="https://theck-market.onrender.com"

echo "🔄 Réveil du backend Render..."
echo "📍 URL: $BACKEND_URL"
echo ""

# Tester plusieurs endpoints pour être sûr
echo "⏳ Envoi de la requête (peut prendre 30-60s)..."

# Utiliser curl avec un timeout de 90s
response=$(curl -s -w "\n%{http_code}" --max-time 90 "$BACKEND_URL/api/health" 2>&1)
http_code=$(echo "$response" | tail -n1)
content=$(echo "$response" | head -n-1)

if [ "$http_code" = "200" ] || [ "$http_code" = "404" ]; then
    echo "✅ Backend réveillé avec succès!"
    echo "📊 Status HTTP: $http_code"
    echo "📄 Réponse: $content"
else
    echo "⚠️  Le backend démarre encore... (Status: $http_code)"
    echo "💡 Réessaye dans 30 secondes"
fi

echo ""
echo "🔗 Ton backend est maintenant disponible à:"
echo "   $BACKEND_URL"
