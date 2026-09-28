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
  -key-shares=5 -key-threshold=3 -format=json > init.json


cat vault-init.json
{
  "unseal_keys_b64": [
    "g6iNr4+81wSrKm87kuzHFc3zVdFbkpWSz+HwpTlRgeN4",
    "XkqJt6K71NQvoMhCZByjY1NOblgLBD5qto800uVaVhzZ",
    "/TtUV8ELQNCPJStgmxhOVpT17+gTrQB325vvcleuccRP",
    "PLi+Rpv/3ua9tZmFhw132NUKY2eSRRZv7PKf5FoJtLzQ",
    "1x5MhBkKqbXRsDO0bNq51WuuTssb6W9I3K5uVMQSdZ7U"
  ],
  "unseal_keys_hex": [
    "83a88daf8fbcd704ab2a6f3b92ecc715cdf355d15b929592cfe1f0a5395181e378",
    "5e4a89b7a2bbd4d42fa0c842641ca363534e6e580b043e6ab68f34d2e55a561cd9",
    "fd3b5457c10b40d08f252b609b184e5694f5efe813ad0077db9bef7257ae71c44f",
    "3cb8be469bffdee6bdb59985870d77d8d50a63679245166fecf29fe45a09b4bcd0",
    "d71e4c84190aa9b5d1b033b46cdab9d56bae4ecb1be96f48dcae6e54c412759ed4"
  ],
  "unseal_shares": 5,
  "unseal_threshold": 3,
  "recovery_keys_b64": [],
  "recovery_keys_hex": [],
  "recovery_keys_shares": 0,
  "recovery_keys_threshold": 0,
  "root_token": "hvs.LefUDJnDjOTmbHM4BQvuBeqO"
}
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


