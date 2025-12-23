# 🎯 IMPLÉMENTATION QR CODE SÉCURISÉ - Guide Complet

**Date** : 22 Décembre 2025, 20:13  
**Status** : ✅ Backend 30% | Frontend 0% | Tests 0%  
**Estimé** : 30-45 minutes restantes

---

## ✅ **CE QUI A ÉTÉ FAIT (10 min)**

### **1. Modèle Transaction** ✅
```python
# Ajouté 3 colonnes:
delivery_time = db.Column(db.DateTime)  # Date livraison
qr_signature = db.Column(db.String(255))  # Signature HMAC
reference = db.Column(db.String(100))  # Référence commande
```

### **2. Utilitaires QR Security** ✅
**Fichier** : `utils/qr_security.py`

**Fonctions créées** :
- `generate_qr_signature()` - Génère HMAC-SHA256
- `verify_qr_signature()` - Vérifie signature
- `generate_qr_data()` - Crée données complètes QR
- `validate_qr_data()` - Valide QR scanné

---

## 🔧 **CE QU'IL RESTE À FAIRE**

### **BACKEND (20 min)**

#### **1. Migration BDD** (2 min)
Ajouter colonnes via endpoint `/admin/migrate-geoloc-v2` :

```python
# routes/migrate_route.py - AJOUTER
@migrate_bp.route('/admin/migrate-qr', methods=['GET'])
def migrate_qr_columns():
    """Ajoute colonnes QR code"""
    columns_to_add = [
        ('delivery_time', 'DATETIME'),
        ('qr_signature', 'VARCHAR(255)'),
        ('reference', 'VARCHAR(100)')
    ]
    # ... même logique que mi

grate_geoloc
```

#### **2. Modifier initiate_payment()** (5 min)
**Fichier** : `controllers/transaction_controller.py`

```python
from utils.qr_security import generate_qr_data

# Dans initiate_payment(), ligne ~280:
new_transaction = Transactions(...)

# AJOUTER après création:
qr_data, signature, reference = generate_qr_data(new_transaction)

# Mettre à jour transaction
new_transaction.qr_signature = signature
new_transaction.reference = reference

db.session.commit()

# Retourner dans response
response_data = {
    ...
    "qr_data": qr_data  # ✅ NOUVEAU
}
```

#### **3. Modifier validate_transaction()** (8 min)
**Fichier** : `controllers/transaction_controller.py`

```python
from utils.qr_security import validate_qr_data
from datetime import datetime
from utils.email_sender import send_delivery_confirmation  # À créer

@app.route('/transactions/validate', methods=['POST'])
def validate_transaction():
    data = request.get_json()
    qr_string = data.get('qr_code')  # JSON string
    
    # 1. Valider QR code
    is_valid, qr_data, error = validate_qr_data(qr_string)
    
    if not is_valid:
        return jsonify({"error": error}), 400
    
    # 2. Chercher transaction
    transaction = Transactions.query.filter_by(
        transaction_id=qr_data['transaction_id']
    ).first()
    
    if not transaction:
        return jsonify({"error": "Transaction introuvable"}), 404
    
    # 3. Vérifier signature en BDD
    if transaction.qr_signature != qr_data['signature']:
        return jsonify({"error": "Signature ne correspond pas"}), 400
    
    # 4. Vérifier status
    if transaction.status == "success":
        return jsonify({
            "error": "Livraison déjà confirmée",
            "delivery_time": transaction.delivery_time.isoformat()
        }), 400
    
    if transaction.status not in ["pending", "confirmed"]:
        return jsonify({
            "error": f"Status invalide: {transaction.status}"
        }), 400
    
    # 5. VALIDER LA LIVRAISON
    transaction.status = "success"
    transaction.delivery_time = datetime.now()
    
    try:
        db.session.commit()
        
        # 6. Envoyer emails
        send_delivery_confirmation(transaction, "client")
        send_delivery_confirmation(transaction, "driver")
        
        return jsonify({
            "message": "✅ Livraison confirmée avec succès !",
            "transaction_id": transaction.transaction_id,
            "reference": transaction.reference,
            "amount": transaction.total_amount,
            "currency": transaction.currency,
            "delivery_time": transaction.delivery_time.isoformat(),
            "distance": transaction.delivery_distance_km
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": f"Erreur: {str(e)}"}), 500
```

#### **4. Créer Email Sender** (5 min)
**Fichier** : `utils/email_sender.py`

```python
from flask_mail import Message
from extensions import mail

def send_delivery_confirmation(transaction, recipient_type):
    """
    Envoie email de confirmation de livraison
    
    Args:
        transaction: Objet Transaction
        recipient_type: 'client' ou 'driver'
    """
    if recipient_type == "client":
        subject = f"✅ Livraison Confirmée - Reçu #{transaction.reference}"
        recipients = [transaction.customer_email]  # À ajouter au modèle
        
        body = f"""
Bonjour,

Votre commande a été livrée avec succès !

DÉTAILS DE LIVRAISON:
- N° Transaction: {transaction.transaction_id}
- Référence: {transaction.reference}
- Montant: {transaction.total_amount} {transaction.currency}
- Date livraison: {transaction.delivery_time.strftime('%d/%m/%Y %H:%M')}
- Distance: {transaction.delivery_distance_km} km

Merci pour votre confiance !

Market App
        """
    
    else:  # driver
        subject = f"✅ Livraison Validée - {transaction.reference}"
        recipients = ["livreur@market.com"]  # Email livreur
        
        body = f"""
La livraison a été confirmée avec succès.

DÉTAILS:
- N° Transaction: {transaction.transaction_id}
- Référence: {transaction.reference}
- Montant: {transaction.total_amount} {transaction.currency}
- Distance: {transaction.delivery_distance_km} km

Prochaine livraison disponible dans votre interface.

Market App
        """
    
    msg = Message(
        subject=subject,
        recipients=recipients,
        body=body
    )
    
    try:
        mail.send(msg)
        print(f"✅ Email envoyé à {recipient_type}")
    except Exception as e:
        print(f"❌ Erreur email: {e}")
```

---

### **FRONTEND (15 min)**

#### **1. Modifier payment.component.ts** (3 min)

```typescript
// Ligne ~49, après initiate payment success:
this.qrCodeValue = result.data.transaction_id;  // Avant

// CHANGER EN:
this.qrCodeData = JSON.stringify(result.data.qr_data);  // QR complet
this.qrCodeValue = result.data.qr_data.transaction_id;  // Affichage
```

#### **2. Ajouter Scanner QR à livreur.html** (12 min)

**Ajouter dans `<head>`** :
```html
<script src="https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js"></script>
```

**Ajouter dans styles** :
```css
/* Modal Scanner */
.modal {
    display: none;
    position: fixed;
    z-index: 9999;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.8);
}

.modal-content {
    background: white;
    margin: 10% auto;
    padding: 30px;
    width: 90%;
    max-width: 600px;
    border-radius: 15px;
}

#qr-reader {
    width: 100%;
    border: 2px solid #667eea;
    border-radius: 10px;
}

.scan-button {
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    color: white;
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    margin-left: 10px;
}
```

**Ajouter après header** :
```html
<!-- Header -->
<div class="header">
    <h1><span>🚚</span> Mes Livraisons</h1>
    <div>
        <button class="scan-button" onclick="openScanner()">
            📷 Scanner QR
        </button>
        <button class="refresh-button" onclick="loadDeliveries()">
            🔄 Actualiser
        </button>
    </div>
</div>

<!-- Modal Scanner QR -->
<div id="scanner-modal" class="modal">
    <div class="modal-content">
        <h2>📷 Scanner le QR Code Client</h2>
        <div id="qr-reader"></div>
        <div id="scan-result" style="margin-top: 20px;"></div>
        <button onclick="closeScanner()" class="refresh-button" style="margin-top: 20px;">
            Fermer
        </button>
    </div>
</div>
```

**Ajouter dans JavaScript** :
```javascript
let html5QrCode = null;

function openScanner() {
    const modal = document.getElementById('scanner-modal');
    modal.style.display = 'block';
    
    html5QrCode = new Html5Qrcode("qr-reader");
    
    html5QrCode.start(
        { facingMode: "environment" },  // Caméra arrière
        { fps: 10, qrbox: 250 },
        onScanSuccess,
        onScanError
    );
}

function closeScanner() {
    if (html5QrCode) {
        html5QrCode.stop();
    }
    document.getElementById('scanner-modal').style.display = 'none';
}

async function onScanSuccess(decodedText) {
    console.log('QR Code scanné:', decodedText);
    
    // Arrêter scanner
    html5QrCode.stop();
    
    // Afficher chargement
    document.getElementById('scan-result').innerHTML = '⏳ Validation...';
    
    try {
        // Appeler API validation
        const response = await fetch(`${API_URL}/transactions/validate`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ qr_code: decodedText })
        });
        
        const result = await response.json();
        
        if (response.ok) {
            document.getElementById('scan-result').innerHTML = `
                <div style="background: #d1fae5; padding: 20px; border-radius: 10px;">
                    <h3 style="color: #065f46;">✅ ${result.message}</h3>
                    <p><strong>Référence:</strong> ${result.reference}</p>
                    <p><strong>Montant:</strong> ${result.amount} ${result.currency}</p>
                    <p><strong>Distance:</strong> ${result.distance} km</p>
                </div>
            `;
            
            // Rafraîchir liste
            setTimeout(() => {
                closeScanner();
                loadDeliveries();
            }, 3000);
        } else {
            document.getElementById('scan-result').innerHTML = `
                <div style="background: #fee2e2; padding: 20px; border-radius: 10px;">
                    <h3 style="color: #991b1b;">❌ Erreur</h3>
                    <p>${result.error}</p>
                </div>
            `;
        }
    } catch (error) {
        document.getElementById('scan-result').innerHTML = `
            <div style="background: #fee2e2; padding: 20px; border-radius: 10px;">
                <h3 style="color: #991b1b;">❌ Erreur réseau</h3>
                <p>${error.message}</p>
            </div>
        `;
    }
}

function onScanError(error) {
    // Ignorer erreurs de scan continues
}
```

---

## 🧪 **TESTS (5 min)**

### **1. Test Backend**

```bash
# 1. Créer transaction
POST /transactions/initiate
# Copier qr_data

# 2. Valider
POST /transactions/validate
Body: {"qr_code": "{\"transaction_id\": ...}"}

# Résultat: 200 OK
```

### **2. Test Frontend**

```
1. Ouvrir https://staging-market.vercel.app/assets/livreur.html
2. Cliquer "📷 Scanner QR"
3. Scanner QR code du client
4. Voir "✅ Livraison confirmée !"
```

---

## 📋 **CHECKLIST IMPLÉMENTATION**

### **Backend**
- [x] Modèle Transaction (colonnes)
- [x] Utils QR Security
- [ ] Migration BDD (endpoint)
- [ ] Modifier initiate_payment()
- [ ] Modifier validate_transaction()
- [ ] Créer email_sender.py
- [ ] Tester avec curl

### **Frontend**
- [ ] Ajouter html5-qrcode CDN
- [ ] Créer modal scanner
- [ ] Ajouter JavaScript scanner
- [ ] Modifier payment.component.ts
- [ ] Tester scan réel

### **Déploiement**
- [ ] Push backend
- [ ] Appeler /admin/migrate-qr
- [ ] Push frontend
- [ ] Test end-to-end

---

## ⏱️ **TEMPS RESTANT**

- Backend : 20 minutes
- Frontend : 15 minutes
- Tests : 5 minutes
- **TOTAL : ~40 minutes**

---

## 🎯 **PROCHAINE ÉTAPE**

**Voulez-vous** :
1. **Continuer maintenant** (je finis l'implémentation)
2. **Pause** (on reprend demain)
3. **Je finis seul** (guide complet fourni ci-dessus)

**Cette session dure déjà 10h !** 😊

**Que préférez-vous ?**
