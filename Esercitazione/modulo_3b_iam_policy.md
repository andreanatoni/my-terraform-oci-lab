# ✅ Scenario 4 – Identity and Access Management: IAM Policy Writing

> **Obiettivo**: Scrivere policy IAM per abilitare l'accesso ai team specifici su compartimenti e regioni all'interno della tenancy OCI, mantenendo una struttura modulare e sicura.

---

## 🧩 Compartimentazione fornita

```
Tenancy (root)
├── Common-Infra
│   ├── Network
│   └── Security
└── Applications
    ├── E-Comm
    ├── SCM
    └── CRM
```

## 👥 Gruppi IAM definiti

- Network-Admins
- Security-Admins
- E-Comm-Admins
- SCM-Admins
- CRM-Admins

---

## 🛠️ Task 1 – Policy per Network-Admins

Consentire al gruppo **Network-Admins** di gestire le risorse di rete nel compartimento `Common-Infra:Network`.

```text
allow Network-Admins to manage virtual-network-family in compartment Common-Infra:Network
```

---

## 🛠️ Task 2 – Policy per E-Comm-Admins

Consentire al gruppo **E-Comm-Admins** di gestire istanze compute nel compartimento `Applications:E-Comm`  
e usare risorse di rete nel compartimento `Common-Infra:Network`.

```text
allow E-Comm-Admins to manage instance-family in compartment Applications:E-Comm
allow E-Comm-Admins to use virtual-network-family in compartment Common-Infra:Network
```

---

## 🛠️ Task 3 – Policy per SCM-Admins con vincolo geografico

Consentire al gruppo **SCM-Admins** di gestire volumi block (`volume-family`) nel compartimento `Applications:SCM` **solo nelle regioni Phoenix e Londra**.

```text
allow SCM-Admins to manage volume-family in compartment Applications:SCM where any{request.region='phx', request.region='lhr'}
```

---

## ✅ Checklist finale

- [x] Uso corretto degli aggregati (`virtual-network-family`, `instance-family`, `volume-family`)
- [x] Policy assegnate al compartimento **root**
- [x] Condizione geografica per regioni applicata tramite `where any{...}`
- [x] Sintassi in linea con la documentazione ufficiale Oracle IAM

---

**Esercizio IAM completato con successo! 🔐**
