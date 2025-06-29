# 🧪 Esercitazione 1 – Configurazione di una rete VCN con accesso Internet e DNS  
## ✅ MODULO 1 – Networking: VCN, Subnet, Gateway, Sicurezza, DNS  

> **Obiettivo**  
> Creare una Virtual Cloud Network (VCN) completa di subnet pubblica + privata, Internet Gateway, NAT Gateway, regole NSG per SSH/HTTP e una Private DNS Zone con due record **A**.

---

## Checklist passo-passo (Console OCI salvo dove indicato)

| ✔︎ | Passo | Dettagli / Azione |
|---|-------|------------------|
| ☐ | **1. Creare la VCN** | **Console → Networking ▸ Virtual Cloud Networks** → **Create VCN**<br>• **Name:** `vcn-lab`<br>• **CIDR Block:** `10.0.0.0/16`<br>• Deseleziona “Create Internet Gateway” (lo facciamo a parte).<br>• Lascia Default Route Table e Security List creati automaticamente. |
| ☐ | **2. Creare la Subnet Pubblica** | **VCN Detail ▸ Subnets** → **Create Subnet**<br>• **Name:** `pub-subnet`<br>• **CIDR:** `10.0.0.0/24`<br>• **Public Subnet:** **Yes** (checkbox “Enable public IP address”).<br>• Associarsi alla **Route-Table-Default** (la modifichiamo dopo). |
| ☐ | **3. Creare la Subnet Privata** | **Create Subnet** di nuovo:<br>• **Name:** `priv-subnet`<br>• **CIDR:** `10.0.1.0/24`<br>• **Public Subnet:** **No** (non assegnare IP pubblici).<br>• **Route Table:** creare una **nuova** denominata `rt-priv-subnet` (vuota per ora). |
| ☐ | **4. Creare Internet Gateway** | **VCN Detail ▸ Internet Gateways** → **Create Internet Gateway**<br>• **Name:** `igw-lab` → **Create Internet Gateway** (stato: Available). |
| ☐ | **5. Aggiornare la Route Table della subnet pubblica** | **VCN Detail ▸ Route Tables** → seleziona **Default Route Table for vcn-lab** → **Add Route Rule**<br>• **Target Type:** *Internet Gateway*<br>• **Target:** `igw-lab`<br>• **Destination CIDR:** `0.0.0.0/0` |
| ☐ | **6. Creare NAT Gateway** | **VCN Detail ▸ NAT Gateways** → **Create NAT Gateway**<br>• **Name:** `natgw-lab` |
| ☐ | **7. Aggiornare la Route Table della subnet privata** | **VCN Detail ▸ Route Tables** → apri `rt-priv-subnet` → **Add Route Rule**<br>• **Target Type:** *NAT Gateway*<br>• **Target:** `natgw-lab`<br>• **Destination CIDR:** `0.0.0.0/0` |
| ☐ | **8. Creare Network Security Group (NSG)** | **VCN Detail ▸ Network Security Groups** → **Create NSG**<br>• **Name:** `nsg-pub` |
| ☐ | **9. Aggiungere Rules all’NSG (SSH + HTTP)** | All’interno di `nsg-pub` → **Add Ingress Rule** × 2:<br>1. **Description:** SSH<br>   • **Stateless:** No<br>   • **Protocol:** TCP 22<br>   • **Source Type:** CIDR `0.0.0.0/0`<br><br>2. **Description:** HTTP<br>   • **Protocol:** TCP 80<br>   • other fields identici (CIDR `0.0.0.0/0`). |
| ☐ | **10. Collegare l’NSG alla subnet pubblica** | **VCN Detail ▸ Subnets** → `pub-subnet` → **Edit** → **Network Security Groups** → aggiungi `nsg-pub` → **Save Changes**. |
| ☐ | **11. Creare Private DNS Zone** | **Console → Networking ▸ DNS Management ▸ Private Zones** → **Create Zone**<br>• **Name (FQDN):** `internal` (o `internal.example.com`)<br>• **Scope:** *Private*<br>• **VCN:** `vcn-lab` |
| ☐ | **12. Aggiungere i due record A** | Nel dettaglio della zone → **Records** → **Add Record** × 2:<br>1. **Record Name:** `web` (Completes to `web.internal`)<br>   **Type:** A  **TTL:** 300  **Target:** IP privata host web (es. `10.0.0.10`)<br><br>2. **Record Name:** `db` (Completes to `db.internal`)<br>   **Type:** A  **TTL:** 300  **Target:** IP privata host db (es. `10.0.1.10`) |
| ☐ | **13. (Opzionale) Verifica da Compute Instance** | Se avrai un’istanza in `pub-subnet`:<br>```bash
# Resoluzione DNS interna
dig +short web.internal
dig +short db.internal
# Connettività
curl http://web.internal
``` |

---

### Comandi CLI (solo se preferisci la CLI)

> **Nota:** sostituisci `<OCID>` con i tuoi OCID effettivi.

```bash
# Esempio - creare la VCN
oci network vcn create --compartment-id <comp_id> --cidr-block 10.0.0.0/16 --display-name vcn-lab

# Esempio - creare Internet Gateway
oci network internet-gateway create --compartment-id <comp_id> --vcn-id <vcn_ocid> --display-name igw-lab --is-enabled true

# Esempio - aggiungere route rule (public RT)
oci network route-table update --rt-id <rt_ocid> \
  --route-rules '[{"cidrBlock":"0.0.0.0/0","networkEntityId":"<igw_ocid>"}]'


# 🧪 Esercitazione 2 – Compute, Cloud-init, Instance Configuration & AutoScaling  
## ✅ MODULO 2 – Istanza Apache con Instance Pool e AutoScaling

> **Obiettivo**  
> Creare un'istanza che installa Apache all'avvio tramite `cloud-init`, salvarne la configurazione come base per un Instance Pool, attivare AutoScaling e testare il comportamento sotto carico.

---

## Checklist passo-passo (Console OCI salvo dove indicato)

| ✔︎ | Passo | Dettagli / Azione |
|---|-------|------------------|
| ☐ | **1. Creare uno script Cloud-init** | Prepara localmente il seguente script (da convertire in base64 o incollare direttamente nella console):  
<pre>
#!/bin/bash
sudo dnf install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd
echo "&lt;!doctype html&gt;&lt;html&gt;&lt;body&gt;&lt;h1&gt;Hostname: $(hostname)&lt;/h1&gt;&lt;/body&gt;&lt;/html&gt;" | sudo tee /var/www/html/index.html
</pre> |

| ☐ | **2. Creare un’istanza di Compute** | **Console → Compute ▸ Instances → Create Instance**  
- **Name:** `web-apache-01`  
- **Image:** Oracle Linux 8  
- **Shape:** `VM.Standard.E2.1.Micro`  
- **Subnet:** `pub-subnet` creata nel modulo 1  
- **Network Security Group:** `nsg-pub` con regole SSH/HTTP  
- **Add SSH Key:** inserisci la tua chiave  
- **Advanced Options → Paste cloud-init script** nel campo **User Data** |

| ☐ | **3. Verifica che Apache sia attivo** | Una volta avviata:  
- Apri browser su `http://<public_ip>` → Deve comparire: `Hostname: web-apache-01`  
- **Console → Compute ▸ Instance → Public IP** |

| ☐ | **4. Creare una Instance Configuration** | **Console → Compute ▸ Instance Configurations → Create**  
- **Name:** `web-apache-config`  
- **Base it on instance:** `web-apache-01`  
- Lascia i parametri di boot e networking invariati (puoi deselezionare il boot volume backup)  
- **Create** |

| ☐ | **5. Creare Instance Pool** | **Console → Compute ▸ Instance Pools → Create Instance Pool**  
- **Name:** `web-apache-pool`  
- **Instance Configuration:** `web-apache-config`  
- **Availability Domain:** seleziona AD1  
- **Number of instances:** `2`  
- **Subnet:** `pub-subnet`  
- **NSG:** seleziona `nsg-pub`  
- **Create** |

| ☐ | **6. Configura AutoScaling** | All’interno del pool → **Autoscaling → Create Autoscaling Configuration**  
- **Name:** `web-autoscale`  
- **Min:** 2  
- **Max:** 5  
- **Metric:** CPUUtilization  
- **Scale-out rule:**  
  - CPU > 60% per 5 min → add 1  
- **Scale-in rule:**  
  - CPU < 30% per 5 min → remove 1  
- **Cooldown period:** 300s  
- **Create** |

| ☐ | **7. Genera carico per test AutoScaling** | **SSH su una delle istanze nel pool**  
- Verifica con:
  ```bash
  top

# 🧪 Esercitazione 3 – Object Storage, Lifecycle, CLI & Instance Principal  
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


# 🧪 Esercitazione 5 – Resource Manager e Terraform  
## ✅ MODULO 5 – Provisioning con Resource Manager

> **Obiettivo**  
> Aprire uno stack pre-caricato in Resource Manager, modificarlo aggiungendo una VCN con subnet e una compute instance, salvare le modifiche, rieseguire `Plan` e `Apply`, e infine distruggere lo stack con `Destroy`.

---

## Checklist passo-passo (tutto via Console OCI)

```bash
# STEP 1: Aprire lo stack esistente
# Console → Developer Services → Resource Manager → Stacks
# → Seleziona stack esistente (es: "terraform-lab-stack")

# STEP 2: Aprire il codice Terraform integrato (Code Editor)
# Tab: Resources → Click su "Code Editor"

# STEP 3: Aggiungere risorsa VCN con subnet
# In `main.tf` o in un nuovo file, incolla:

resource "oci_core_vcn" "my_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "rm-vcn"
}

resource "oci_core_subnet" "my_subnet" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.my_vcn.id
  cidr_block          = "10.0.0.0/24"
  display_name        = "rm-subnet"
  prohibit_public_ip_on_vnic = false
}

# STEP 4: Aggiungere Compute Instance
resource "oci_core_instance" "my_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id = oci_core_subnet.my_subnet.id
    assign_public_ip = true
    display_name     = "rm-vnic"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oraclelinux_latest.id
  }

  display_name = "rm-instance"
}

# STEP 5: Assicurati di avere anche:
# Variabili in `variables.tf`:
variable "compartment_ocid" {
  type = string
}

# STEP 6: Salva i file modificati
# Click su "Save All" in alto

# STEP 7: Esegui Plan
# Tab: Job → Create Job → Plan → Avvia
# Verifica che compaia la creazione di `oci_core_vcn`, `oci_core_subnet`, `oci_core_instance`

# STEP 8: Esegui Apply
# Tab: Job → Create Job → Apply → Avvia
# Attendi completamento

# STEP 9: Verifica la creazione risorse
# Console → VCN, Subnet, Compute → le risorse devono comparire nei rispettivi compartimenti

# STEP 10: Esegui Destroy per pulizia finale
# Stack → Create Job → Destroy → Avvia
# Conferma l’eliminazione delle risorse

# (Opzionale) STEP 11: Elimina anche lo Stack
# Stack → Actions → Delete Stack


# 🧪 Esercitazione 6 – Logging, Events, Notification & Monitoring  
## ✅ MODULO 6 – Allarmi e Notifiche

> **Obiettivo**  
> Configurare un sistema di monitoraggio tramite **Alarm**, **Notification Topic** e **sottoscrizione email** per ricevere avvisi quando una Compute Instance supera il 70% di utilizzo CPU.

---

## Checklist passo-passo (Console OCI)

```bash
# STEP 1: Creare una Notification Topic
# Console → Application Integration → Notifications → Topics → Create Topic
# • Name: `cpu-alert-topic`
# • Compartment: quello dove si trova la VM
# → Clicca "Create"

# STEP 2: Creare una sottoscrizione email
# All'interno della Topic → Tab: Subscriptions → Create Subscription
# • Protocol: `EMAIL`
# • Endpoint: tua_email@esempio.com
# → Clicca "Create"
# → Conferma il link ricevuto via email per attivare la sottoscrizione

# STEP 3: Creare un Alarm su CPUUtilization > 70%
# Console → Observability & Management → Alarms → Create Alarm
# • Name: `cpu-usage-alarm`
# • Compartment: stesso della VM
# • Metric: `CPUUtilization`
# • Resource: seleziona la tua Compute Instance
# • Statistic: `Mean`
# • Trigger: `Greater than 70`
# • Trigger Delay: 1 minute
# • Notification Destination: seleziona `cpu-alert-topic`
# → Clicca "Create Alarm"

# STEP 4: Simulare traffico/cpu load sulla VM
# Apri CloudShell → connettiti via SSH alla VM:
ssh -i ~/.ssh/id_rsa opc@<public_ip>

# All'interno della VM, installa stress (o tool equivalente):
sudo dnf install -y epel-release
sudo dnf install -y stress
# Genera carico CPU per 5 minuti:
stress --cpu 2 --timeout 300

# STEP 5: Verifica
# • Console → Alarm → controlla stato: dovrebbe diventare **FIRING**
# • Riceverai una mail dalla Topic con il titolo "Alarm Fired"
# • Dopo fine del carico, lo stato tornerà a **OK**

# (Opzionale) STEP 6: Visualizza metrica della VM
# Console → Compute → Instance → Metrics → CPUUtilization
# → Scegli periodo “Last 1 hour” per confermare i picchi

# 🧪 Esercitazione 6 – Logging, Events, Notification & Monitoring  
## ✅ MODULO 6 – Allarmi e Notifiche

> **Obiettivo**  
> Configurare un sistema di monitoraggio tramite **Alarm**, **Notification Topic** e **sottoscrizione email** per ricevere avvisi quando una Compute Instance supera il 70% di utilizzo CPU.

---

## Checklist passo-passo (Console OCI)

```bash
# STEP 1: Creare una Notification Topic
# Console → Application Integration → Notifications → Topics → Create Topic
# • Name: `cpu-alert-topic`
# • Compartment: quello dove si trova la VM
# → Clicca "Create"

# STEP 2: Creare una sottoscrizione email
# All'interno della Topic → Tab: Subscriptions → Create Subscription
# • Protocol: `EMAIL`
# • Endpoint: tua_email@esempio.com
# → Clicca "Create"
# → Conferma il link ricevuto via email per attivare la sottoscrizione

# STEP 3: Creare un Alarm su CPUUtilization > 70%
# Console → Observability & Management → Alarms → Create Alarm
# • Name: `cpu-usage-alarm`
# • Compartment: stesso della VM
# • Metric: `CPUUtilization`
# • Resource: seleziona la tua Compute Instance
# • Statistic: `Mean`
# • Trigger: `Greater than 70`
# • Trigger Delay: 1 minute
# • Notification Destination: seleziona `cpu-alert-topic`
# → Clicca "Create Alarm"

# STEP 4: Simulare traffico/cpu load sulla VM
# Apri CloudShell → connettiti via SSH alla VM:
ssh -i ~/.ssh/id_rsa opc@<public_ip>

# All'interno della VM, installa stress (o tool equivalente):
sudo dnf install -y epel-release
sudo dnf install -y stress
# Genera carico CPU per 5 minuti:
stress --cpu 2 --timeout 300

# STEP 5: Verifica
# • Console → Alarm → controlla stato: dovrebbe diventare **FIRING**
# • Riceverai una mail dalla Topic con il titolo "Alarm Fired"
# • Dopo fine del carico, lo stato tornerà a **OK**

# (Opzionale) STEP 6: Visualizza metrica della VM
# Console → Compute → Instance → Metrics → CPUUtilization
# → Scegli periodo “Last 1 hour” per confermare i picchi

# 🧪 Esercitazione 8 – Vault & Cloud Guard  
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

# 🧪 Esercitazione 9 – Traffic Management & Load Balancer  
## ✅ MODULO 9 – Load Balancer e steering

> **Obiettivo**  
> Creare due Compute Instance in AD diverse, bilanciarle tramite Load Balancer pubblico su TCP/80, configurare health check, e opzionalmente aggiungere una DNS Steering Policy.

---

## Checklist passo-passo (Console OCI)

```bash
# STEP 1: Creare due Compute Instance (una per Availability Domain)
# Console → Compute → Instances → Create Instance (due volte)

# • Name: `web-ad1` e `web-ad2`
# • AD: seleziona AD1 per la prima, AD2 per la seconda
# • Shape: `VM.Standard.E2.1.Micro`
# • Image: Oracle Linux
# • Subnet: `pub-subnet`
# • Network Security Group: `nsg-pub` (deve consentire TCP 80)
# • User Data (cloud-init opzionale per Apache):

#!/bin/bash
sudo dnf install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd
echo "<h1>$(hostname)</h1>" | sudo tee /var/www/html/index.html

# STEP 2: Verifica che Apache sia attivo
curl http://<public_ip_ad1>
curl http://<public_ip_ad2>

# STEP 3: Creare un Load Balancer pubblico
# Console → Networking → Load Balancers → Create Load Balancer

# • Name: `lb-web`
# • Shape: `Flexible`
# • Minimum Bandwidth: 10 Mbps
# • Maximum Bandwidth: 100 Mbps
# • Subnet: `pub-subnet`
# • Type: `Public`
# • Network Security Group: crea o riutilizza uno con TCP/80
# → Create

# STEP 4: Configurare Backend Set
# Dentro il LB → Backend Sets → Create Backend Set

# • Name: `web-beset`
# • Policy: `Round Robin`
# • Protocol: `TCP`
# • Port: `80`
# • Health Check:
#   • Protocol: `TCP`
#   • Port: `80`
#   • Interval: 10s, Timeout: 3s, Attempts: 3
# → Create

# STEP 5: Aggiungere Backend Server (le due Compute)
# Dentro Backend Set → Backend Servers → Add Backend Server (2 volte)

# • IP Address: seleziona le private IP delle istanze
# • Port: `80`
# • Backup: No
# • Drain: No

# STEP 6: Configurare Listener
# Listeners → Create Listener

# • Name: `http-listener`
# • Protocol: `TCP`
# • Port: `80`
# • Backend Set: `web-beset`
# → Create

# STEP 7: Verificare funzionamento
# Apri il Public IP del Load Balancer nel browser:
http://<LB_public_ip>
# Deve alternare i due hostname (web-ad1 / web-ad2)

# STEP 8 (Opzionale): DNS Steering Policy
# Console → Networking → Traffic Management Steering Policies → Create Steering Policy

# • Name: `geo-policy`
# • Type: `Geolocation-based`
# • Rule: 
#   • Region: Europe → endpoint `lb-eu.example.com`
#   • Region: North America → endpoint `lb-us.example.com`
# • Attach a DNS Zone (es. `mydomain.com`)
# • Apply policy to record name `web.mydomain.com`

# → Create Policy and Publish
