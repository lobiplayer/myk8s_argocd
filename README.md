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

## Kubernetes Dashboard

The dashboard is available via an ingress on HTTPS port
There is a service account created to log into the dashboard. You might need to create a JWT token for the SA
```
kubectl create token -n kubernetes-dashboard cluster-admin
```

## Nginx

Nginx will be deployed by Helm.

If you want to expose over HTTPS with a certificate (created by Vault offered through cert-manager), make sure that you describe this propperly in the Ingress. Check the following YAML as example 
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubernetes-dashboard-ingress
  namespace: kubernetes-dashboard
  labels:
  annotations:
    cert-manager.io/cluster-issuer: vault-clusterissuer
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    
    kubernetes.io/ingress.class: "nginx"
spec:
  ingressClassName: nginx
  rules:
  - host: dashboard.myk8s.net
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: kubernetes-dashboard
            port:
              number: 443
  tls:
  - hosts:
    - dashboard.myk8s.net
    secretName: kubernetes-dashboard-cert
```

## GitLab

## Keycloak