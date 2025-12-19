# 📊 Tests de Charge K6 - Guide Complet

## 🎯 Objectif

Tester les performances et la résilience de votre application e-commerce sous différentes charges.

## 📋 Prérequis

### Installation de K6 (Linux)

```bash
# Méthode 1: Via apt (Ubuntu/Debian)
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

# Méthode 2: Via snap (plus simple)
sudo snap install k6

# Vérifier l'installation
k6 version
```

## 🚀 Scripts Disponibles

### 1. **frontend-load-test.js** - Test de Charge Frontend
**Description**: Test progressif du frontend Angular  
**Durée**: ~7 minutes  
**Utilisateurs**: 0 → 20 → 50 → 100 → 50 → 0

```bash
# Test local
k6 run frontend-load-test.js

# Test sur environnement de production
k6 run --env BASE_URL=https://your-app.vercel.app frontend-load-test.js
```

**Métriques testées**:
- ✅ Page d'accueil
- ✅ Page produits
- ✅ Page de connexion
- ✅ Temps de réponse < 500ms
- ✅ Taux d'erreur < 10%

---

### 2. **backend-api-load-test.js** - Test de Charge Backend API
**Description**: Test complet des endpoints API  
**Durée**: ~3 minutes  
**Utilisateurs**: 0 → 10 → 30 → 50 → 0

```bash
# Test local
k6 run backend-api-load-test.js

# Test sur API de production
k6 run --env API_BASE_URL=https://your-backend.onrender.com/api/v1 backend-api-load-test.js
```

**Endpoints testés**:
- ✅ POST /auth/register
- ✅ POST /auth/login
- ✅ GET /products
- ✅ Temps de réponse login < 1000ms
- ✅ Temps de réponse register < 3000ms

---

### 3. **stress-test.js** - Test de Stress
**Description**: Pousse le système à ses limites  
**Durée**: ~8 minutes  
**Utilisateurs**: 0 → 50 → 100 → 200 → 300 → 0

```bash
# ⚠️ ATTENTION: Test intensif!
k6 run stress-test.js
```

**Objectif**: Trouver le point de rupture de votre application

---

### 4. **spike-test.js** - Test de Pic (Black Friday)
**Description**: Simule un pic soudain de trafic  
**Durée**: ~3 minutes  
**Utilisateurs**: 10 → **200 (en 10s!)** → 10

```bash
k6 run spike-test.js
```

**Objectif**: Vérifier la résilience lors d'événements (Black Friday, promotions)

---

## 📊 Comprendre les Résultats

### Exemple de sortie K6:

```
     data_received..................: 13 MB  2.2 MB/s
     data_sent......................: 1.2 MB 200 kB/s
     http_req_blocked...............: avg=1.2ms    min=0s     med=0s     max=120ms  p(95)=5ms   
     http_req_connecting............: avg=0.5ms    min=0s     med=0s     max=50ms   p(95)=2ms   
     http_req_duration..............: avg=245ms    min=100ms  med=220ms  max=980ms  p(95)=450ms ✅
     http_req_failed................: 2.34%  ✅ (< 10%)
     http_reqs......................: 5420   90/s
     vus............................: 100    min=0      max=100
     vus_max........................: 100    min=100    max=100
```

### 🎯 Métriques Clés:

| Métrique | Bon ✅ | Moyen ⚠️ | Mauvais ❌ |
|----------|--------|----------|-----------|
| **http_req_duration (p95)** | < 500ms | 500-1000ms | > 1000ms |
| **http_req_failed** | < 5% | 5-10% | > 10% |
| **errors** | < 5% | 5-15% | > 15% |

---

## 🎨 Options Avancées

### Générer un rapport HTML

```bash
# Installer extension (si pas déjà fait)
npm install -g k6-html-reporter

# Exécuter avec rapport
k6 run --out json=results.json frontend-load-test.js
k6-html-report results.json
```

### Exporter vers Grafana/InfluxDB

```bash
# Avec InfluxDB
k6 run --out influxdb=http://localhost:8086/k6 frontend-load-test.js

# Avec Cloud K6 (gratuit pour 50 tests/mois)
k6 login cloud
k6 run --out cloud frontend-load-test.js
```

---

## 📈 Scénarios de Test Recommandés

### 🟢 Semaine 1: Tests Basiques
```bash
# Jour 1: Frontend léger
k6 run frontend-load-test.js

# Jour 2: Backend API
k6 run backend-api-load-test.js
```

### 🟡 Semaine 2: Tests Intensifs
```bash
# Jour 3: Stress test
k6 run stress-test.js

# Jour 4: Spike test
k6 run spike-test.js
```

### 🔴 Avant Production:
```bash
# Test complet sur environnement de staging
k6 run --env BASE_URL=https://staging.app frontend-load-test.js
k6 run --env API_BASE_URL=https://staging-api.com/api/v1 backend-api-load-test.js
k6 run --env BASE_URL=https://staging.app spike-test.js
```

---

## 🐛 Troubleshooting

### Problème: "Connection refused"
```bash
# Vérifier que votre app tourne
curl http://localhost:4200
# ou
curl https://your-backend.onrender.com/api/v1/products
```

### Problème: Trop d'erreurs (> 50%)
```bash
# Réduire le nombre d'utilisateurs virtuels
# Modifier le fichier de test:
stages: [
  { duration: '1m', target: 10 },  // Au lieu de 50
]
```

### Problème: "Cannot find module 'k6/http'"
```bash
# K6 n'est pas installé correctement
k6 version
# Si erreur, réinstaller K6
```

---

## 📚 Ressources

- [Documentation K6](https://k6.io/docs/)
- [Exemples K6](https://k6.io/docs/examples/)
- [Best Practices](https://k6.io/docs/testing-guides/test-types/)

---

## ✅ Checklist de Test

Avant d'aller en production, assurez-vous que:

- [ ] Frontend supporte 50+ utilisateurs simultanés
- [ ] Backend API répond en < 1s pour 95% des requêtes
- [ ] Taux d'erreur < 5% sous charge normale
- [ ] L'app survit à un spike soudain (Black Friday)
- [ ] Le stress test identifie le point de rupture
- [ ] Les résultats sont documentés

---

## 🎯 Objectifs de Performance

### Minimum Viable (Beta):
- ✅ 50 utilisateurs simultanés
- ✅ P95 < 1000ms
- ✅ Erreurs < 10%

### Production Robuste:
- ✅ 100+ utilisateurs simultanés
- ✅ P95 < 500ms
- ✅ Erreurs < 5%
- ✅ Résiste aux pics soudains

### Production Professionnelle:
- ✅ 500+ utilisateurs simultanés
- ✅ P95 < 300ms
- ✅ Erreurs < 2%
- ✅ Auto-scaling configuré

---

**Créé le**: 18 Décembre 2025  
**Dernière mise à jour**: 18 Décembre 2025  
**Version**: 1.0.0
