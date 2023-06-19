# kubectl exec --stdin=true --tty=true vault-0 -n vault -- /bin/sh

vault secrets enable pki

vault secrets tune -max-lease-ttl=8760h pki

vault write pki/root/generate/internal \
    common_name=myk8s.net \
    ttl=8760h

vault write pki/config/urls \
    issuing_certificates="http://internal-vault.vault:8200/v1/pki/ca" \
    crl_distribution_points="http://internal-vault.vault:8200/v1/pki/crl"

vault write pki/roles/myk8s-dot-net \
    allowed_domains=myk8s.net \
    allow_subdomains=true \
    max_ttl=72h

vault policy write pki - <<EOF
path "pki*"                        { capabilities = ["read", "list"] }
path "pki/sign/myk8s-dot-net"    { capabilities = ["create", "update"] }
path "pki/issue/myk8s-dot-net"   { capabilities = ["create"] }
EOF
