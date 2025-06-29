# 🧪 Esercitazione 4 – Resource Manager e Terraform
Resource Manager e Terraform  
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
