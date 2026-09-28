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

#----------------------------init--------------------------------------
kubectl exec -n vault vault-0 -- vault operator init \
  -key-shares=5 -key-threshold=3 -format=json > init.json

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


