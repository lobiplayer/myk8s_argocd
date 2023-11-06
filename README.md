# myk8s_argocd

## Install ArgoCD

When you're cluster is ready, install ArgoCD on the cluster via helm:

```
kubectl create ns argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install my-argo-cd argo/argo-cd --version 5.50.1 -n argocd

```

## Configure GIT repo

We want argocd to look into this repo in the /cluster folder to know what to apply.
We do this by adding root.yaml in the argocd namespace.

```
kubectl apply /cluster/root.yaml
```

## Vault and Cert-Manager

Vault and Cert-Manger will be installed via helm. All the necessary configurations for Cert-Manager are covered in the yamls.
For configuring the PKI in the vault. Exec into the pod and execute the commands in the pki_script.sh file.
```
kubectl exec --stdin=true --tty=true vault-0 -n vault -- /bin/sh
```

