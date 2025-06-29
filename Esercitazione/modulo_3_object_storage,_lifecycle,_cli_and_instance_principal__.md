# 🧪 Esercitazione 3 – Object Storage, Lifecycle, CLI & Instance Principal
Object Storage, Lifecycle, CLI & Instance Principal  
## ✅ MODULO 3 – Gestione di bucket via CLI con policy di lifecycle

> **Obiettivo**  
> Usare **OCI CLI da una Compute Instance** con **Instance Principal** per creare un bucket, caricare oggetti, applicare una Object Lifecycle Policy, e verificare i permessi assegnati.

---

## Checklist passo-passo (tutto eseguibile in un’unica istanza Compute via CloudShell + SSH)

```bash
# STEP 1: Connettersi alla Compute Instance via CloudShell usando SSH
# (Console → Compute → Instances → <istanza> → Copy SSH Command)
# Da CloudShell:
ssh -i ~/.ssh/id_rsa opc@<public_ip>

# STEP 2: Verificare che l’istanza usi INSTANCE PRINCIPAL (no config file)
# Questo comando DEVE restituire dati, altrimenti i permessi non sono corretti:
oci os ns get

# Se ricevi "NotAuthorizedOrNotFound", assicurati che:
# - La VM sia parte di una Dynamic Group
# - Sia presente una policy come:
#   allow dynamic-group <nome> to manage object-family in compartment <compartimento>

# STEP 3: Creare un bucket con OCI CLI nel namespace corrente
NAMESPACE=$(oci os ns get --query "data" --raw-output)
BUCKET_NAME="cli-demo-bucket"
oci os bucket create --name $BUCKET_NAME --compartment-id <compartment_ocid> --public-access-type NoPublicAccess

# STEP 4: Creare 3 file di esempio
echo "log 1" > logs1.txt
echo "log 2" > logs2.txt
echo "log 3" > logs3.txt

# STEP 5: Caricare i file nel bucket
oci os object put --bucket-name $BUCKET_NAME --name logs/logs1.txt --file logs1.txt
oci os object put --bucket-name $BUCKET_NAME --name logs/logs2.txt --file logs2.txt
oci os object put --bucket-name $BUCKET_NAME --name logs/logs3.txt --file logs3.txt

# STEP 6: Creare la Lifecycle Policy JSON (es: archive dopo 30 giorni)
cat > lifecycle.json <<EOF
{
  "rules": [
    {
      "name": "archive-logs",
      "action": "ARCHIVE",
      "objectNameFilter": {
        "includePrefixes": ["logs/"]
      },
      "timeAmount": 30,
      "timeUnit": "DAYS",
      "isEnabled": true
    }
  ]
}
EOF

# STEP 7: Applicare la Lifecycle Policy al bucket
oci os object-lifecycle-policy put \
  --bucket-name $BUCKET_NAME \
  --lifecycle-policy file://lifecycle.json

# STEP 8: Verifica della policy applicata
oci os object-lifecycle-policy get --bucket-name $BUCKET_NAME

# STEP 9: Elencare gli oggetti e controllare che siano in stato "Standard"
oci os object list --bucket-name $BUCKET_NAME --prefix logs/

# Ricorda: solo dopo 30 giorni verranno spostati in ARCHIVE.
