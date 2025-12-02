# 🖼️ Guide: Upload d'Images vers Cloudinary

## Étape 1: Obtenir les credentials Cloudinary

1. Va sur https://cloudinary.com/console
2. Login avec ton compte
3. Clique sur "Settings" (en bas à gauche)
4. Va à l'onglet "API Keys"
5. Copie:
   - **Cloud Name**: `dzqbzqgjw` (c'est bon, tu l'as déjà)
   - **API Key**: `xxxxxxxxxxxxxxxxxxxxxxxx`
   - **API Secret**: `xxxxxxxxxxxxxxxxxxxxxxxx`

## Étape 2: Installer cloudinary-python

```bash
cd backend/E-COMMERCE_APP
pip install cloudinary
```

## Étape 3: Configurer le script

Édite `upload_to_cloudinary.py` et remplace:

```python
API_KEY = "YOUR_API_KEY"        # ← Remplace par ta clé
API_SECRET = "YOUR_API_SECRET"  # ← Remplace par ton secret
```

Par tes vraies credentials de https://cloudinary.com/console/settings/api-keys

## Étape 4: Lancer le script

```bash
cd backend/E-COMMERCE_APP
python3 upload_to_cloudinary.py
```

## Étape 5: Utiliser les URLs générées

Le script va afficher les URLs. Tu les copies et mets à jour `populate_db.py`:

**Avant:**
```python
'picture': 'https://res.cloudinary.com/dzqbzqgjw/image/upload/v1733000000/ecommerce/iphone15pro.jpg'
```

**Après:**
```python
'picture': 'https://res.cloudinary.com/dzqbzqgjw/image/upload/v1234567890/ecommerce/iphone.jpeg'
```

## Étape 6: Relancer populate_db.py

```bash
python3 populate_db.py
```

Les produits auront maintenant les bonnes URLs Cloudinary! 🎉

---

## Alternative: Upload Manual (plus simple)

Si tu ne veux pas utiliser le script:

1. Va sur https://cloudinary.com/console/media_library
2. Crée un dossier `/ecommerce`
3. Upload les images du dossier `frontend/E-COMMERCE_APP/public/`
4. Copie les URLs depuis Cloudinary
5. Mets à jour `populate_db.py` manuellement

---

## ⚠️ Important

- **N'expose jamais** tes API Keys en public (pas de commit sur GitHub)
- Les images seront stockées sur Cloudinary gratuitement (jusqu'à 25GB)
- Le compte Cloudinary `dzqbzqgjw` doit avoir les permissions d'upload

