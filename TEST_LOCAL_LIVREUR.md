# 🎯 TEST LOCAL - Livreur Interface

## Option 1 : Serveur HTTP Simple

```bash
cd /home/christian/Bureau/CHRISTIAN/FullStackApp/frontend/E-COMMERCE_APP/public

# Python
python3 -m http.server 8080

# Ouvrir : http://localhost:8080/livreur.html
```

**Avantages** :
- Pas de rate limit
- Tests immédiats
- Modifications en temps réel

---

## Option 2 : Modifier API_URL Temporairement

Dans `public/livreur.html`, ligne 432, **changer** :
```javascript
// const API_URL = 'https://theck-market.onrender.com';  // Commenté temporairement
const API_URL = 'http://localhost:5000';  // Backend local
```

**Puis lancer backend local** :
```bash
cd /home/christian/Bureau/CHRISTIAN/FullStackApp/backend/E-COMMERCE_APP
python3 app.py
```

---

## Option 3 : Juste Tester le Scanner

Le scanner QR ne fait qu'**1 requête** lors de la validation.

**Workflow** :
1. Checkout → Génère QR
2. Livreur.html → Ignorer l'erreur de chargement liste
3. Cliquer "📷 Scanner QR"
4. Scanner → **Ça fonctionne !** ✅

Le rate limit n'affecte **pas** le scan QR !

---

## 🕐 Rate Limit Info

**Render Free Tier** :
- Limite : ~100 req/min
- Ban : 1 heure
- Réinitialisation : Automatique

**Actuellement bloqué jusqu'à** : ~06:30 (1h)

---

## ✅ RECOMMANDATION

**MAINTENANT** : Testez le **scanner QR uniquement**

**DANS 1H** : Interface complète fonctionnera

**FUTUR** : Refresh 120s = pas de problème
