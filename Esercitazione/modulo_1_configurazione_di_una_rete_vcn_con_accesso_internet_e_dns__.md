# 🧪 Esercitazione 1 – Configurazione di una rete VCN con accesso Internet e DNS
Configurazione di una rete VCN con accesso Internet e DNS  
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
