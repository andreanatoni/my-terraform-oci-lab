# OCI Terraform Lab Infrastructure

Questo repository contiene una configurazione Terraform per la creazione di un'infrastruttura di rete base su **Oracle Cloud Infrastructure (OCI)**.  
È pensata come punto di partenza per progetti più complessi e modulabili, con struttura organizzata e riutilizzabile.

## 🧱 Struttura attuale

La configurazione attuale crea:

- Una **Virtual Cloud Network (VCN)** con CIDR `10.0.0.0/16`
- Tre **subnet**:
  - 1 pubblica (`10.0.0.0/24`)
  - 2 private (`10.0.1.0/24`, `10.0.2.0/24`)
- Gateway:
  - **Internet Gateway** (per uscita pubblica)
  - **NAT Gateway** (per uscita privata)
  - **Service Gateway** (per servizi Oracle)
- Route Tables per subnet pubbliche e private
- Security List per traffico HTTP/HTTPS
- Utilizzo della **default security list** associata alla VCN

## 📁 Struttura del repository

```
terraform-oci-lab/
├── main.tf                  # Entry point che richiama i moduli
├── provider.tf              # Provider OCI
├── variables.tf             # Variabili globali
├── terraform.tfvars         # Valori delle variabili
├── outputs.tf               # Output utili post-deploy
├── modules/
│   └── networking/
│       ├── main.tf          # Risorse di rete
│       ├── variables.tf     # Variabili del modulo di rete
│       ├── outputs.tf       # Output del modulo
└── README.md                # Documentazione (questo file)
```

## 🚀 Prerequisiti

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) >= 1.0.0
- [OCI CLI configurata](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) e file `~/.oci/config` settato correttamente
- Un bucket per salvare eventualmente lo **state remoto** (opzionale ma consigliato)

## ⚙️ Utilizzo

```bash
# Inizializza Terraform e scarica i provider
terraform init

# Mostra le modifiche che saranno apportate
terraform plan

# Applica le modifiche
terraform apply
```

## 🔐 Variabili

Variabili definite in `variables.tf` e valorizzate in `terraform.tfvars`:

| Nome             | Descrizione                                         | Default         |
|------------------|-----------------------------------------------------|-----------------|
| `compartment_id` | OCID del compartimento in cui creare le risorse     | Nessuno         |
| `region_id`      | Regione OCI in cui operare (es. `uk-london-1`)      | `uk-london-1`   |

## 📤 Output

Esempi di output disponibili:

- ID della VCN creata
- ID della subnet pubblica
- ID delle subnet private

## 🔜 Prossimi sviluppi

Questa base può essere estesa con:

- Modulo `bastion` con istanza compute pubblica
- Modulo `app_tier` con instance pool + load balancer
- Modulo `database` per Autonomous DB o DB System
- Logging, monitoring, alarm
- IAM roles e policies

## 👨‍💻 Autore

Progetto creato e mantenuto da **Amdrea Natoni**
