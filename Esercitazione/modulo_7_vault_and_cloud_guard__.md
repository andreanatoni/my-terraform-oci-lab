# 🧪 Esercitazione 7 – Vault & Cloud Guard
Vault & Cloud Guard  
## ✅ MODULO 8 – Sicurezza e auditing

> **Obiettivo**  
> Abilitare Cloud Guard in modalità "Reporting", creare un Vault con chiave AES a 24 byte, generare un Secret cifrato, e consultare i log di audit delle attività.

---

## Checklist passo-passo (Console OCI)

```bash
# STEP 1: Abilitare Cloud Guard
# Console → Identity & Security → Cloud Guard → Enable Cloud Guard
# • Mode: `Reporting`
# • Target Compartment: `root` o un compartimento specifico
# • Click "Enable Cloud Guard"

# STEP 2: Creare un Target per Cloud Guard
# Cloud Guard → Targets → Create Target
# • Name: `audit-target`
# • Compartment: uno con attività recenti (es. `dev`)
# • Select Detector Recipes (usa i default)
# • Responder Mode: `Reporting`
# → Create

# STEP 3: Creare un Vault
# Console → Identity & Security → Vault → Create Vault
# • Name: `vault-lab`
# • Vault Type: `Default` (o `Private` se richiesto)
# • Compartment: `dev` (o altro)
# → Create Vault e attendi che sia in stato `ACTIVE`

# STEP 4: Creare una chiave AES a 24 byte (192-bit)
# All'interno del Vault → Keys → Create Key
# • Name: `aes-192-key`
# • Protection Mode: `Software` (per test)
# • Key Shape:
#   • Algorithm: `AES`
#   • Length: `192`
# → Create

# STEP 5: Creare un Secret cifrato con quella chiave
# Vault → Secrets → Create Secret
# • Name: `db-password`
# • Vault: `vault-lab`
# • Encryption Key: `aes-192-key`
# • Secret Content: es. `"MyS3cretP@ss!"`
# • Secret Format: `Base64` o `Plaintext`
# • Compartment: `dev`
# → Create

# STEP 6: Visualizzare i dettagli del Secret
# Secrets → db-password → Dettagli:
# • OCID
# • Creation Time
# • Current Version
# NB: Il valore NON è leggibile via console per sicurezza

# STEP 7: Consultare log di audit
# Console → Observability & Management → Logging → Logs
# • Group: `Audit`
# • Log: `Audit Log`
# • Filtra per compartimento usato (`dev`)
# • Cerca eventi legati a: vault, keys, secrets, IAM

# Esempio: azioni come `POST /secrets`, `GET /keys`
