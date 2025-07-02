# ✅ Scenario 3 – Use the OCI CLI to Work with Object Storage from a Compute Instance

> **Obiettivo**: Caricare file in Object Storage da una Compute Instance tramite la OCI CLI e applicare una policy di lifecycle per eliminare file temporanei dopo 30 giorni.

---

## 🧩 Pre-requisiti

- Compute instance con **OCI CLI installata**
- Autenticazione via **Instance Principal**
- Directory con file da caricare: `~/dir_to_upload`
- Accesso tramite **Cloud Shell → Ephemeral Private Network Setup**
- Chiave SSH privata disponibile:  
  [PKey.key](https://objectstorage.us-ashburn-1.oraclecloud.com/n/tenancyname/b/PBT_Storage/o/PKey.key)

---

## 🧠 Obiettivo finale

Creare un bucket chiamato `CloudOpsBucket`, caricare il contenuto della directory `~/dir_to_upload`, e impostare una policy di lifecycle per eliminare automaticamente i file con prefisso `temp/` dopo 30 giorni.

---

## 🔐 Connessione via SSH (da Cloud Shell)

```bash
ssh -i /path/to/PKey.key opc@<private-ip>
```

---

## 🛠️ Task 1 – Creazione del Bucket

```bash
oci os bucket create \
  --compartment-id <OCID_COMPARTIMENTO> \
  --name CloudOpsBucket \
  --auth instance_principal \
  --versioning Enabled
```

📌 Sostituisci `<OCID_COMPARTIMENTO>` con l’OCID reale fornito per l’esame.

---

## 📤 Task 2 – Upload della Directory

```bash
oci os object bulk-upload \
  --bucket-name CloudOpsBucket \
  --src-dir ~/dir_to_upload \
  --auth instance_principal
```

✔️ Questo carica tutti i file dalla directory e sotto-directory in Object Storage.

---

## ♻️ Task 3 – Creazione Lifecycle Policy

### 1. Crea un file `rule.json` con il seguente contenuto:

```json
{
  "rules": [
    {
      "name": "Delete-Rule",
      "action": "DELETE",
      "objectNameFilter": {
        "inclusionPrefixes": ["temp/"]
      },
      "timeAmount": 30,
      "timeUnit": "DAYS",
      "isEnabled": true
    }
  ]
}
```

### 2. Applica la policy:

```bash
oci os object-lifecycle-policy put \
  --bucket-name CloudOpsBucket \
  --namespace $(oci os ns get --query "data" --raw-output --auth instance_principal) \
  --lifecycle-policy file://rule.json \
  --auth instance_principal
```

---

## ✅ Checklist finale

- [x] Connessione SSH stabilita da Cloud Shell via Ephemeral Private Network
- [x] Bucket `CloudOpsBucket` creato nel compartimento corretto
- [x] Tutti i file caricati tramite `bulk-upload`
- [x] Lifecycle Policy applicata per eliminare `temp/` dopo 30 giorni
- [x] Test visivo del contenuto e policy verificata in Console (facoltativo)

---

**Esercitazione completata con successo! 🚀**
