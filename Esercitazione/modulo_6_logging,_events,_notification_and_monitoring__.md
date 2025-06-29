# 🧪 Esercitazione 6 – Logging, Events, Notification & Monitoring
Logging, Events, Notification & Monitoring  
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
