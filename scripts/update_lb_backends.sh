#!/bin/bash

# === CONFIGURA QUESTI PARAMETRI PRIMA ===
INSTANCE_POOL_OCID="ocid1.instancepool.oc1.uk-london-1.aaaaaaaaxxxxxxxxxxxxxxxxxxxxxxx"
COMPARTMENT_ID="ocid1.compartment.oc1..aaaaaaaaaxxxxxxxxxxxxxxxxxxxxxx"
LB_OCID="ocid1.loadbalancer.oc1.uk-london-1.aaaaaaaaaxxxxxxxxxxxxxxx"
BACKEND_SET_NAME="lab-backend-set"
PORT=80

# === STEP 1: Elenco delle istanze del pool ===
echo "Recupero istanze dell'instance pool..."
INSTANCE_IDS=$(oci compute-management instance-pool list-instances \
  --instance-pool-id "$INSTANCE_POOL_OCID" \
  --query "data[].\"id\"" --raw-output)

# === STEP 2: Aggiunta backend per ogni istanza ===
for INSTANCE_ID in $INSTANCE_IDS; do
  echo "Processo $INSTANCE_ID..."

  VNIC_ID=$(oci compute vnic-attachment list \
    --compartment-id "$COMPARTMENT_ID" \
    --instance-id "$INSTANCE_ID" \
    --query "data[0].\"vnic-id\"" --raw-output)

  if [ -z "$VNIC_ID" ]; then
    echo "  ⚠️ Nessun VNIC trovato, salto."
    continue
  fi

  IP=$(oci network vnic get --vnic-id "$VNIC_ID" --query "data.\"private-ip\"" --raw-output)

  echo "  ➕ Aggiungo $IP al backend set..."

  oci lb backend create \
    --load-balancer-id "$LB_OCID" \
    --backend-set-name "$BACKEND_SET_NAME" \
    --ip-address "$IP" \
    --port $PORT \
    --wait-for-state SUCCEEDED >/dev/null

  echo "  ✅ Backend $IP:$PORT aggiunto."
done

# === STEP 3: Verifica lo stato del backend set ===
echo "Verifico lo stato del backend set..."
oci lb backend list \
  --load-balancer-id "$LB_OCID" \
  --backend-set-name "$BACKEND_SET_NAME" \
  --query "data[*].{IP: \"ip-address\", Port: port, Status: status}" \
  --output table

if [ $? -eq 0 ]; then
  echo "✅ Stato del backend set verificato con successo."
else
  echo "❌ Errore nella verifica dello stato del backend set."
fi

echo "🏁 Script completato."
