# 🧪 Esercitazione 2 – Compute, Cloud-init, Instance Configuration & AutoScaling
Compute, Cloud-init, Instance Configuration & AutoScaling  
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
