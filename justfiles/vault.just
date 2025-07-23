k := "kubectl --namespace=vault"
secret_vault_json := "../secrets/vault.json"

default:
  @just --list

@wait-ready:
  {{k}} wait --for=condition=Ready --timeout=1m pod/vault-0 &>/dev/null

init:
  #!/usr/bin/env bash
  if {{k}} exec vault-0 -- vault status -format=json | jq '.initialized'; then
    {{k}} exec vault-0 -- vault operator init -format=json > {{secret_vault_json}}
  fi

login: wait-ready
  {{k}} exec vault-0 -- vault login $(jq -r '.root_token' {{secret_vault_json}})

unseal:
  #!/usr/bin/env bash
  set -euo pipefail

  if ! $({{k}} exec vault-0 -- vault status -format=json 2>/dev/null | jq '.sealed'); then
    echo 'Vault is unsealed already'
    exit
  fi

  for key in $(jq -r '.unseal_keys_b64[:3][]' {{secret_vault_json}}); do
    {{k}} exec vault-0 -- vault operator unseal "$key"
  done

set-userpass username password policies="supabase,server,web": wait-ready
  #!/usr/bin/env bash
  set -euo pipefail

  if ! kubectl exec vault-0 -- vault auth list -format=json | jq -e '."userpass/"' > /dev/null; then
    {{k}} exec vault-0 -- vault auth enable userpass
  fi

  {{k}} exec vault-0 -- vault write auth/userpass/users/{{username}} \
    password={{password}} \
    policies={{policies}}

create-resources: wait-ready
  #!/usr/bin/env bash
  set -euo pipefail

  {{k}} exec vault-0 -- sh -c '
    set -euo pipefail

    vault secrets enable -path=secret kv-v2

    vault auth enable kubernetes
    vault write auth/kubernetes/config \
      kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
  '

  for file in ../cluster/vault/policies/*.hcl; do
    policy_name=$(basename "$file" .hcl)
    cat "$file" | {{k}} exec --stdin=true vault-0 -- vault policy write "$policy_name" -
  done

  {{k}} exec vault-0 -- sh -c '
    set -euo pipefail

    vault write auth/kubernetes/role/supabase \
      bound_service_account_names=service-account \
      bound_service_account_namespaces=supabase \
      policies=supabase \
      audience=vault \
      ttl=24h

    vault write auth/kubernetes/role/server \
      bound_service_account_names=service-account \
      bound_service_account_namespaces=server \
      policies=server \
      audience=vault \
      ttl=24h

    vault write auth/kubernetes/role/web \
      bound_service_account_names=service-account \
      bound_service_account_namespaces=web \
      policies=web \
      audience=vault \
      ttl=24h
  '

write-secrets: wait-ready
  #!/usr/bin/env bash
  set -euo pipefail

  supabase_anon_payload='{"iss":"supabase-demo","role":"anon","exp":1983812996}'
  supabase_service_payload='{"iss":"supabase-demo","role":"service_role","exp":1983812996}'
  supabase_secret=$(openssl rand -base64 64)
  supabase_anon_key=$(jwt encode -S "${supabase_secret}" "${supabase_anon_payload}")
  supabase_service_key=$(jwt encode -S "${supabase_secret}" "${supabase_service_payload}")
  server_admin_jwt_secret=$(openssl rand -base64 64)
  server_admin_jwt_refresh_secret=$(openssl rand -base64 64)
  admin_auth_secret=$(openssl rand -base64 64)

  {{k}} exec vault-0 -- sh -c "
    set -euo pipefail

    vault kv put secret/supabase/config \
      anonKey='${supabase_anon_key}' \
      serviceKey='${supabase_service_key}' \
      secret='${supabase_secret}'

    vault kv put secret/supabase/database \
      username='supabase_admin' \
      password='$SUPABASE_PASSWORD' \
      database='postgres'

    vault kv put secret/supabase/smtp \
      username='$SUPABASE_USERNAME' \
      password='$SUPABASE_PASSWORD'

    vault kv put secret/supabase/dashboard \
      username='$SUPABASE_USERNAME' \
      password='$SUPABASE_PASSWORD'

    vault kv put secret/server/config \
      adminJwtSecret='${server_admin_jwt_secret}' \
      adminJwtRefreshSecret='${server_admin_jwt_refresh_secret}' \
      openaiApiKey='$OPENAI_API_KEY' \
      openaiBaseUrl='$OPENAI_BASE_URL' \
      vnpaySecureSecret='$VNPAY_SECURE_SECRET' \
      vnpayTmnCode='$VNPAY_TMN_CODE'
  "

setup: init unseal login create-resources write-secrets
