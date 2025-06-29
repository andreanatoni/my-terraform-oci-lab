# 🧪 Esercitazione 8 – Traffic Management & Load Balancer
Traffic Management & Load Balancer  
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
