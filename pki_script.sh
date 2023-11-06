# kubectl exec --stdin=true --tty=true vault-0 -n vault -- /bin/sh

# Configure PKI

vault secrets enable pki

vault secrets tune -max-lease-ttl=8760h pki

vault write pki/root/generate/internal \
    common_name=myk8s.net \
    ttl=8760h

vault write pki/config/urls \
    issuing_certificates="http://vault.vault:8200/v1/pki/ca" \
    crl_distribution_points="http://vault.vault:8200/v1/pki/crl"

vault write pki/roles/myk8s-dot-net \
    allowed_domains=myk8s.net \
    allow_subdomains=true \
    max_ttl=72h

vault policy write pki - <<EOF
path "pki*"                        { capabilities = ["read", "list"] }
path "pki/sign/myk8s-dot-net"    { capabilities = ["create", "update"] }
path "pki/issue/myk8s-dot-net"   { capabilities = ["create"] }
EOF

# Configure Kubernetes authentication

vault auth enable kubernetes

vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"



vault write auth/kubernetes/role/clusterissuer \
    bound_service_account_names=clusterissuer \
    bound_service_account_namespaces=cert-manager \
    policies=pki \
    ttl=20m
