# OCI Terraform Lab Infrastructure

Questo repository è un laboratorio pratico per la creazione di un'infrastruttura su Oracle Cloud Infrastructure (OCI) utilizzando **Terraform** con un approccio completamente **modulare**. Contiene una configurazione Terraform per la creazione di un'infrastruttura di rete base su **Oracle Cloud Infrastructure (OCI)**.  
È pensata come punto di partenza per progetti più complessi e modulabili, con struttura organizzata e riutilizzabile.

L'obiettivo è:

- Costruire moduli riutilizzabili e componibili.
- Evitare l'uso di variabili hard-coded.
- Facilitare la scalabilità e manutenibilità dell'infrastruttura.
- Fare pratica con le principali risorse OCI.

---

## 📐 Struttura del progetto

```
my-terraform-oci-lab/
├── main.tf
├── variables.tf
├── provider.tf
├── outputs.tf
├── version.tf
└── modules/
    ├── autoscaling/
    ├── compute_instance/
    ├── instance_configuration/
    ├── instance_pool/
    ├── load_balancer/
    └── networking/
```

---

## ⚙️ Moduli disponibili

### 🔌 `networking`
Crea:
- VCN
- 3 subnet (pubblica + 2 private)
- Internet Gateway, NAT Gateway, Service Gateway
- Security List dettagliate
- Route Tables

### 🖥 `compute_instance`
Lancia una singola VM con:
- Shape configurabile (default: A1.Flex)
- SSH key injection
- VNIC pubblica

### 📦 `instance_configuration`
Genera un'istanza configurabile per un pool:
- Basata su immagine Oracle Linux 8
- Supporto a cloud-init (parametrizzabile)

### 👥 `instance_pool`
Crea un pool di istanze:
- Basato su `instance_configuration`
- Multi-AD (Placement config dinamico)
- Hostname e display name personalizzati

### 🚀 `autoscaling`
Applica una policy di scaling:
- Basata su utilizzo CPU
- Threshold configurati (75% scale-out, 25% scale-in)
- Supporta `cool_down_in_seconds`

### 🌐 `load_balancer`
Crea un Load Balancer pubblico:
- Backend dinamici (istanze del pool)
- BackendSet con Health Check HTTP
- Listener configurato sulla porta 80

---

## 🔧 Requisiti

- Terraform ≥ 1.0.0
- Provider OCI ≥ 4.67.3
- OCI CLI configurato o variabili d'ambiente
- SSH key pair disponibile
- Compartment, Tenancy e User OCID

---

## 🚀 Esempio di utilizzo

```bash
# Inizializza terraform
terraform init

# Valida i file
terraform validate

# Esegui il deploy
terraform apply
```

---

## 🎯 Obiettivi didattici

- Familiarizzare con le risorse OCI via Terraform
- Esercitarsi nel design modulare e riutilizzabile
- Simulare ambienti reali (VM, Pool, LB, Autoscaling)
- Applicare best practice di Infrastructure as Code (IaC)

---

## 📚 Note aggiuntive

- Tutti i moduli sono stati progettati per essere **stateless** e **completamente parametrizzabili**.
- Le risorse sono nomate in modo coerente per facilitare l'integrazione.
- L’approccio è pensato per essere **incrementale**: puoi commentare/abilitare singoli moduli per test progressivi.

---

## 📎 TODO (per espansione futura)

- Aggiunta modulo DNS + DNS privato
- Modulo per Object Storage
- Modulo per Database autonomo o VM DB
- Integrazione con CI/CD Terraform (es. GitHub Actions)
- Validazione con `terraform-docs`

---

## 🧑‍💻 Autore

**Andrea Natoni** – [GitHub](https://github.com/) | DevOps, Cloud, IaC enthusiast

---

