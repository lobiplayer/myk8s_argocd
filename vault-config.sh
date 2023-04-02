export SA_SECRET_NAME=$(kubectl -n default get secrets --output=json | jq -r '.items[].metadata | select(.name|startswith("issuer-token--")).name')
export SA_JWT_TOKEN=$(kubectl -n default get secret issuer-token-lmzpj --output 'go-template={{ .data.token }}' | base64 --decode)
export SA_CA_CRT=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
export K8S_HOST=$(kubectl config view --raw --minify --flatten --output 'jsonpath={.clusters[].cluster.server}')

vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="$K8S_HOST" kubernetes_ca_cert="$SA_CA_CRT" disable_iss_validation="true" disable_local_ca_jwt="true" issuer="https://kubernetes.default.svc.cluster.local"