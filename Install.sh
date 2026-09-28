# add repo
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# 3 replicas, integrated raft storage
kubectl create ns vault
helm install vault hashicorp/vault -n vault \
  --set server.ha.enabled=true \
  --set server.ha.raft.enabled=true \
  --set server.ha.replicas=3

kubectl get pods -n vault
# vault-0  0/1 Running   <- Ready نیست چون Sealed است

kubectl -n vault exec vault-0 -- vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        false
Sealed             true
Total Shares       0
Threshold          0
Unseal Progress    0/0
Unseal Nonce       n/a
Version            2.0.4
Build Date         2026-08-03T16:14:36Z
Storage Type       file
HA Enabled         false
command terminated with exit code 2

#----------------------------init--------------------------------------
kubectl exec -n vault vault-0 -- vault operator init \
  -key-shares=5 -key-threshold=3 -format=json > vault-init.json

chmod 600 vault-init.json
apt-get install -y jq 

jq -r '.unseal_keys_b64[]' vault-init.json
g6iNr4+81wSrKm87kuzHFc3zVdFbkpWSz+HwpTlRgeN4
XkqJt6K71NQvoMhCZByjY1NOblgLBD5qto800uVaVhzZ
/TtUV8ELQNCPJStgmxhOVpT17+gTrQB325vvcleuccRP
PLi+Rpv/3ua9tZmFhw132NUKY2eSRRZv7PKf5FoJtLzQ
1x5MhBkKqbXRsDO0bNq51WuuTssb6W9I3K5uVMQSdZ7U

jq -r '.root_token' vault-init.json
hvs.LefUDJnDjOTmbHM4BQvuBeqO

# init.json contains:
#   unseal_keys_b64: [5 keys]
#   root_token: hvs.xxxxx

#----------------------------unseal--------------------------------------

kubectl exec -n vault vault-0 -- vault operator unseal <KEY_1>
# Sealed: true   Unseal Progress: 1/3
kubectl exec -n vault vault-0 -- vault operator unseal <KEY_2>
# Sealed: true   Unseal Progress: 2/3
kubectl exec -n vault vault-0 -- vault operator unseal <KEY_3>
# Sealed: false  <- باز شد

kubectl exec -n vault vault-0 -- vault status


