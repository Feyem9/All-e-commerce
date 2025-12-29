# 🚀 Guide de Publication sur les App Stores

## Google Play Store (via TWA - Trusted Web Activity)

### Prérequis

1. **Compte développeur Google Play** (25$ une fois)
   - https://play.google.com/console/

2. **Android Studio** installé

3. **Java JDK** 11+ installé

### Étape 1: Vérifier l'éligibilité PWA

Ton app doit passer le test Lighthouse PWA :
```bash
npx lighthouse https://staging-market.vercel.app --only-categories=pwa
```

### Étape 2: Digital Asset Links

Créer le fichier `/public/.well-known/assetlinks.json` :
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.theckmarket.app",
    "sha256_cert_fingerprints": ["YOUR_SHA256_FINGERPRINT"]
  }
}]
```

### Étape 3: Utiliser Bubblewrap

```bash
# Installer Bubblewrap
npm install -g @anthropic-ai/anthropic-sdk/bubblewrap-cli

# Initialiser le projet
bubblewrap init --manifest https://staging-market.vercel.app/manifest.webmanifest

# Répondre aux questions :
# - Package name: com.theckmarket.app
# - App name: Theck Market
# - Launcher name: Theck Market
# - Display mode: standalone
# - Theme color: #3b82f6
# - Background color: #f8fafc

# Générer l'APK
bubblewrap build

# Le fichier app-release-signed.apk sera créé
```

### Étape 4: Publier sur Play Store

1. Aller sur https://play.google.com/console/
2. Créer une nouvelle application
3. Remplir les informations :
   - Titre : Theck Market
   - Description courte : Votre boutique tech premium au Cameroun
   - Description complète : [voir ci-dessous]
4. Uploader les screenshots (téléphone, tablette)
5. Uploader l'APK signé
6. Soumettre pour review

---

## Apple App Store (via PWA ou Capacitor)

### Option 1: PWA native (iOS 16.4+)

Les utilisateurs peuvent ajouter l'app depuis Safari.
Pas de publication sur l'App Store possible pour les PWA pures.

### Option 2: Capacitor (wrapper natif)

```bash
# Installer Capacitor
npm install @capacitor/core @capacitor/cli @capacitor/ios

# Initialiser
npx cap init "Theck Market" com.theckmarket.app

# Ajouter iOS
npx cap add ios

# Synchroniser
npx cap sync ios

# Ouvrir dans Xcode
npx cap open ios
```

Puis publier via Xcode sur l'App Store.

---

## Description complète pour les stores

### Français

```
Theck Market - Votre boutique de smartphones et accessoires tech premium au Cameroun !

🛒 SHOPPING FACILE
• Parcourez notre catalogue de smartphones haut de gamme
• Filtrez par prix, catégorie et marque
• Ajoutez vos favoris pour plus tard

💳 PAIEMENT SÉCURISÉ
• Mobile Money (Orange, MTN)
• Cartes bancaires
• Paiement à la livraison

📦 LIVRAISON RAPIDE
• Suivi en temps réel avec QR code
• Livraison dans tout le Cameroun
• Notifications de progression

🔔 RESTEZ INFORMÉ
• Notifications de nouvelles offres
• Alertes de baisse de prix
• Suivi de vos commandes

Téléchargez Theck Market maintenant et profitez des meilleures offres tech !
```

### English

```
Theck Market - Your premium smartphone and tech accessories store in Cameroon!

🛒 EASY SHOPPING
• Browse our catalog of high-end smartphones
• Filter by price, category, and brand
• Add favorites for later

💳 SECURE PAYMENT
• Mobile Money (Orange, MTN)
• Bank cards
• Cash on delivery

📦 FAST DELIVERY
• Real-time tracking with QR code
• Delivery throughout Cameroon
• Progress notifications

🔔 STAY INFORMED
• New offers notifications
• Price drop alerts
• Order tracking

Download Theck Market now and enjoy the best tech deals!
```

---

## Screenshots requis

### Google Play Store
- Téléphone : 1080x1920 ou 1440x2560 (2-8 images)
- Tablette 7" : 1024x600 (optionnel)
- Tablette 10" : 1280x800 (optionnel)

### Apple App Store
- iPhone 6.5" : 1284x2778 ou 1242x2688
- iPhone 5.5" : 1242x2208
- iPad Pro 12.9" : 2048x2732

---

## Checklist avant publication

- [ ] App fonctionne hors-ligne
- [ ] Icônes de haute qualité (512x512 minimum)
- [ ] Screenshots pour tous les formats
- [ ] Politique de confidentialité URL
- [ ] Conditions d'utilisation URL
- [ ] Compte développeur créé
- [ ] Informations de contact support
- [ ] Catégorie : Shopping
- [ ] Classification : Tout public

---

## URLs importantes

| Élément | URL |
|---------|-----|
| **App (Staging)** | https://staging-market.vercel.app |
| **API Backend** | https://theck-market.onrender.com |
| **Manifest** | https://staging-market.vercel.app/manifest.webmanifest |
| **Politique confidentialité** | https://staging-market.vercel.app/privacy |
| **CGU** | https://staging-market.vercel.app/terms |
