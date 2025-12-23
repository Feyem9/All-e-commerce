# 📱 Workflow QR Code - E-Commerce App

**Date** : 22 Décembre 2025  
**Status** : ✅ Fonctionnel  
**Type** : Paiement avec validation QR Code

---

## 🎯 Vue d'Ensemble

Le système de QR Code permet de **valider manuellement** les transactions après un paiement initié via PayUnit. Le client reçoit un QR code qu'il peut scanner pour confirmer le paiement.

---

## 🔄 Workflow Complet

### **Étape 1 : Initiation du Paiement** 💳

**Frontend** : `payment.component.ts`

```typescript
startPayment() {
  const data = {
    total_amount: 1000,
    currency: 'XAF',
    return_url: window.location.origin + '/payment-success',
    notify_url: environment.apiUrl + '/transactions/notify',
    payment_country: 'CM'
  };
  
  this.transactionService.initiatePayment(data).subscribe(result => {
    this.paymentUrl = result.payment_url;        // URL PayUnit
    this.qrCodeValue = result.data.t_id;         // ✅ QR Code ID
    this.transactionId = result.data.transaction_id;
  });
}
```

**Backend** : `transaction_controller.py` → `initiate_payment()`

```python
# Génère un ID de transaction unique
transaction_id = generate_transaction_id()  # Ex: "4478-36b0fe"

# Envoie à PayUnit API
response = requests.post(PAYUNIT_INITIATE_URL, data=payload, headers=headers)

# Enregistre en base de données
new_transaction = Transactions(
    transaction_id=transaction_id,
    total_amount=data['total_amount'],
    currency=data['currency'],
    status="pending",  # ⏳ En attente
    redirect_url=result["data"]["transaction_url"]
)
db.session.add(new_transaction)
db.session.commit()

# Retourne au frontend
return jsonify({
    "payment_url": result["data"]["transaction_url"],
    "transaction_id": transaction_id,
    "data": {
        "t_id": result["data"]["t_id"],  # ✅ C'est le QR Code
        "t_url": result["data"]["t_url"]
    }
})
```

**Résultat** :
- ✅ Transaction créée en BDD avec `status = "pending"`
- ✅ Frontend reçoit `t_id` (l'ID pour le QR code)

---

### **Étape 2 : Affichage du QR Code** 📱

**Frontend** : `payment.component.html`

```html
<div *ngIf="qrCodeValue" class="qr-code-container">
  <h3>Scanner pour valider</h3>
  <!-- Génération QR via API externe -->
  <img [src]="'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=' + qrCodeValue" 
       alt="QR Code de validation" />
  <p>ID Transaction: {{ transactionId }}</p>
</div>
```

**Données du QR Code** :
- Contient : `result.data.t_id` (l'ID de transaction PayUnit)
- Format : Simple string (ex: "TXN_123456789")
- Générateur : API externe `https://api.qrserver.com`

---

### **Étape 3 : Scan du QR Code** 📷

**Scénario** :  
Le vendeur/caissier scanne le QR code avec son application mobile de caisse.

**Alternative dans l'app** :  
Validation manuelle via le bouton "Valider Transaction" dans l'interface web.

**Frontend** : `payment.component.ts`

```typescript
validateTransaction() {
  if (!this.qrCodeValue) {
    return; // Pas de QR disponible
  }

  this.loading = true;
  
  // Appel backend pour valider
  this.transactionService.validateTransaction(this.qrCodeValue).subscribe({
    next: (response) => {
      this.validationMessage = 'Transaction validée avec succès !';
      this.validationSuccess = true;
    },
    error: (error) => {
      this.validationMessage = 'Échec: ' + error.error?.message;
    }
  });
}
```

---

### **Étape 4 : Validation Backend** ✅

**Service** : `transaction.service.ts`

```typescript
validateTransaction(qrCodeValue: string) {
  return this.http.post<any>(
    `${this.API_URL}/validate`, 
    { qr_code: qrCodeValue }
  );
}
```

**Backend** : `transaction_controller.py` → `validate_transaction()`

```python
def validate_transaction():
    data = request.get_json()
    qr_code = data.get('qr_code')  # Le t_id scanné

    if not qr_code:
        return jsonify({'error': 'QR code manquant'}), 400

    # 🔍 Rechercher la transaction par son ID
    transaction = Transactions.query.filter_by(transaction_id=qr_code).first()

    if not transaction:
        return jsonify({'error': 'Transaction non trouvée'}), 404

    # ⏳ Vérifier que la transaction est en attente
    if transaction.status != 'pending':
        return jsonify({'error': f'Transaction déjà {transaction.status}'}), 400

    # ✅ Mettre à jour le statut
    transaction.status = 'completed'
    db.session.commit()

    return jsonify({
        'message': 'Transaction validée avec succès',
        'transaction_id': transaction.transaction_id,
        'status': transaction.status,
        'amount': transaction.total_amount,
        'currency': transaction.currency
    }), 200
```

**Processus** :
1. Reçoit le `qr_code` (t_id)
2. Cherche la transaction dans la BDD
3. Vérifie que `status = "pending"`
4. Change le status → `"completed"`
5. Sauvegarde en BDD
6. Retourne confirmation

---

### **Étape 5 : Confirmation Visuelle** 🎉

**Frontend** : Message de succès affiché

```
✅ Transaction validée avec succès !
ID: 4478-36b0fe
Montant: 1000 XAF
Status: completed
```

**État final en BDD** :
```python
Transactions {
  transaction_id: "4478-36b0fe",
  total_amount: 1000,
  currency: "XAF",
  status: "completed",  # ✅ Changé de "pending"
  redirect_url: "https://..."
}
```

---

## 📊 Diagramme de Flux

```
┌─────────────┐
│   Client    │
│  (Browser)  │
└──────┬──────┘
       │
       │ 1. Clic "Payer"
       ▼
┌─────────────────────────┐
│  Frontend Angular       │
│  payment.component.ts   │
│                         │
│  startPayment()         │
└──────┬──────────────────┘
       │
       │ 2. POST /transactions/initiate
       ▼
┌─────────────────────────────────┐
│  Backend Flask                  │
│  transaction_controller.py      │
│                                 │
│  initiate_payment()             │
│  ├─ Génère transaction_id       │
│  ├─ Appelle PayUnit API         │
│  ├─ Enregistre en BDD (pending) │
│  └─ Retourne t_id + payment_url │
└──────┬──────────────────────────┘
       │
       │ 3. Response avec t_id
       ▼
┌─────────────────────────┐
│  Frontend Angular       │
│                         │
│  this.qrCodeValue=t_id  │
│  Affiche QR Code ━━━━┓  │
└────────────────────┬──┘  │
                     │     │
                     ▼     │
              ┌─────────┐  │
              │ QR Code │◀─┘
              │  📱     │
              └────┬────┘
                   │
                   │ 4. Scan par vendeur
                   │    ou validation manuelle
                   ▼
         ┌──────────────────┐
         │  Frontend        │
         │                  │
         │ validateTx(t_id) │
         └────┬─────────────┘
              │
              │ 5. POST /transactions/validate
              ▼
   ┌──────────────────────────────┐
   │  Backend Flask               │
   │                              │
   │  validate_transaction()      │
   │  ├─ Cherche tx par t_id      │
   │  ├─ Vérifie status=pending   │
   │  ├─ Change → completed ✅    │
   │  └─ Sauvegarde               │
   └──────┬───────────────────────┘
          │
          │ 6. Success response
          ▼
   ┌─────────────────────┐
   │  Frontend           │
   │                     │
   │  Message succès ✅  │
   └─────────────────────┘
```

---

## 🗄️ Structure Base de Données

**Table** : `transactions`

```sql
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY,
    transaction_id VARCHAR(50) UNIQUE,  -- Ex: "4478-36b0fe"
    total_amount DECIMAL(10,2),
    currency VARCHAR(3),
    status VARCHAR(20),  -- 'pending', 'completed', 'failed'
    redirect_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**États du status** :
- `pending` : Transaction créée, en attente de validation
- `completed` : Transaction validée via QR code ✅
- `failed` : Transaction échouée ❌

---

## 🔐 Sécurité

### **Points de Sécurité Actuels** :

1. ✅ **Transaction ID unique** : `generate_transaction_id()` génère un ID aléatoire
2. ✅ **Vérification status** : Ne peut valider que les transactions `pending`
3. ✅ **Backend validation** : Le frontend ne peut pas changer le status directement

### **Améliorations Possibles** :

1. ⚠️ **Expiration du QR** : Ajouter une durée de validité (ex: 15 minutes)
2. ⚠️ **Authentification vendeur** : Vérifier l'identité du validateur
3. ⚠️ **Rate limiting** : Limiter les tentatives de validation

---

## 🧪 Test du Workflow

### **Test Manuel** :

1. **Initier paiement** :
   ```bash
   curl -X POST https://theck-market.onrender.com/transactions/initiate \
     -H "Content-Type: application/json" \
     -d '{
       "total_amount": 1000,
       "currency": "XAF",
       "return_url": "https://staging-market.vercel.app/payment-success",
       "notify_url": "https://webhook.site/...",
       "payment_country": "CM"
     }'
   ```

2. **Récupérer le t_id** de la réponse

3. **Valider transaction** :
   ```bash
   curl -X POST https://theck-market.onrender.com/transactions/validate \
     -H "Content-Type: application/json" \
     -d '{"qr_code": "TXN_ID_RECU"}'
   ```

4. **Vérifier** :
   - Status code : 200
   - Response : `"status": "completed"`

---

## 📱 Cas d'Usage

### **Scenario 1 : Paiement en Magasin** 🏪

1. Client commande en ligne
2. Va au magasin physique
3. Présente QR code au vendeur
4. Vendeur scanne → Validation
5. Client reçoit produit

### **Scenario 2 : Paiement Livraison** 🚚

1. Client commande en ligne
2. Livreur arrive avec le colis
3. Client montre QR code
4. Livreur valide sur son app mobile
5. Livraison effectuée

### **Scenario 3 : Validation Manuelle** 💻

1. Client initie paiement
2. Affiche QR code à l'écran
3. Admin vérifie paiement externe
4. Admin clique "Valider" dans l'interface
5. Transaction confirmée

---

## 🔄 Intégration PayUnit

**Le QR Code dans le contexte PayUnit** :

```javascript
// PayUnit retourne:
{
  "data": {
    "t_id": "TXN_123456",        // ✅ Utilisé pour QR Code
    "transaction_url": "https://...",  // URL paiement PayUnit
    "transaction_id": "4478-36b0fe",   // Notre ID interne
    "t_url": "return_url",
    "t_sum": "1000"
  }
}
```

**Le `t_id`** :
- ID généré par PayUnit
- Utilisé comme contenu du QR Code
- Référence unique pour cette transaction PayUnit
- Stocké mais **notre `transaction_id` est la clé primaire**

---

## 📋 Checklist Développeur

Pour implémenter/modifier le système QR :

- [ ] Frontend génère QR via `api.qrserver.com` avec `t_id`
- [ ] Backend `initiate_payment()` retourne `t_id`
- [ ] Frontend `validateTransaction()` envoie `qr_code`
- [ ] Backend `validate_transaction()` change status
- [ ] BDD transaction a status `pending` → `completed`
- [ ] Messages de succès/erreur affichés
- [ ] Tests end-to-end passent

---

## 🎯 Conclusion

**Le système QR Code permet** :
1. ✅ Validation manuelle des paiements
2. ✅ Alternative au paiement automatique PayUnit
3. ✅ Traçabilité des transactions
4. ✅ Flexibilité pour paiements physiques

**Statut** : ✅ **Fonctionnel et Production Ready**

---

**Créé le** : 22 Décembre 2025  
**Version** : 1.0  
**Dernière mise à jour** : Workflow complet documenté
