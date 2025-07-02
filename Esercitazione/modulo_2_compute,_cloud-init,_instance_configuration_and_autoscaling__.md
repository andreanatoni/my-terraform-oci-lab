# ✅ Scenario 2 – Oracle Cloud-init and AutoScaling

> **Obiettivo**: Deploy di un'applicazione web Apache su OCI usando cloud-init, Instance Configuration, Instance Pool e AutoScaling su Oracle Linux 8.

---

## 🧩 Pre-requisiti

- Accesso a OCI Console con permessi su compute/networking/autoscaling
- Compartment assegnato
- VCN: `Cloud-Init Challenge VCN` con subnet pubblica `Cloud-Init Challenge SNT`
- Chiave SSH pubblica:  
  [PublicKey.pub](https://objectstorage.us-ashburn-1.oraclecloud.com/n/tenancyname/b/PBT_Storage/o/PublicKey.pub)

---

## 🔧 Task 1(a) – Creazione Compute VM con Cloud-Init

### ☁️ Cloud-init script (da incollare nella sezione “Paste cloud-init script”):

```
#!/bin/bash
sudo dnf install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
sudo firewall-offline-cmd --add-service=http
sudo systemctl restart firewalld
echo "<html><body><h1>Apache is running on $(hostname)</h1></body></html>" > /var/www/html/index.html
```

### 📋 Istruzioni OCI Console:

1. Vai su **Compute → Instances → Create Instance**
2. Nome: `pbt_cloud_init_vm_01`
3. Image: **Oracle Linux 8**
4. Shape: `VM.Standard.A1.Flex` (1 OCPU, 6 GB RAM)
5. Availability Domain: uno qualsiasi
6. Network:
   - VCN: `Cloud-Init Challenge VCN`
   - Subnet: `Cloud-Init Challenge SNT`
   - Public IP: **Enabled**
7. SSH key: incolla il contenuto di `PublicKey.pub`
8. Incolla lo script cloud-init
9. Crea l’istanza

✔️ Test: accedi a `http://<Public-IP>` e verifica che Apache risponda.

---

## 🛠️ Task 1(b) e Task 2 – Instance Configuration, Pool, Autoscaling

### 🏗️ Step 1 – Create Instance Configuration

1. Vai su **Compute → Instance Configurations → Create**
2. Nome: `pbt_cloud_init_config_01`
3. Source: seleziona l’istanza `pbt_cloud_init_vm_01`
4. Salva

---

### 🌀 Step 2 – Crea Instance Pool

1. Vai su **Compute → Instance Pools → Create**
2. Nome: `pbt_cloud_init_pool_01`
3. Instance Configuration: `pbt_cloud_init_config_01`
4. Initial number of instances: `1`
5. Subnet: `Cloud-Init Challenge SNT`
6. Public IP: **Enabled**
7. Crea

---

### 📈 Step 3 – Crea AutoScaling Configuration

1. Seleziona pool `pbt_cloud_init_pool_01` → Tab **Autoscaling**
2. Click **Create Autoscaling Configuration**
3. Nome: `pbt_cloud_autoscaling_config_01`
4. Tipo: **Metric-based**
5. Metric: **CPU Utilization**
6. Cooldown: `300` seconds
7. Scaling limits:
   - Min: `1`
   - Max: `2`
   - Initial: `1`
8. **Scale-out rule**
   - Operator: `Greater than`
   - Threshold: `75%`
   - Action: `Add 1 instance`
9. **Scale-in rule**
   - Operator: `Less than`
   - Threshold: `25%`
   - Action: `Remove 1 instance`
10. Create

---

## ✅ Verifica finale

- Visualizza `http://<Load Balanced Instance IP>` o IP singolo per test
- Se vuoi testare Autoscaling manualmente, puoi generare carico CPU via SSH:
```
sudo dnf install -y stress
stress --cpu 2 --timeout 300
```

---

## ✅ Checklist

- [x] Compute instance creata con Apache via cloud-init
- [x] Instance Configuration generata
- [x] Instance Pool configurato
- [x] AutoScaling con soglie CPU abilitato
- [x] Firewall HTTP aperto e test completato

---

**Esercitazione completata con successo! 🚀**