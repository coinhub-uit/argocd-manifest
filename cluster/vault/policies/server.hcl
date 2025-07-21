path "secret/server/*" {
  capabilities = ["read"]
}

path "secret/supabase/config" {
  capabilities = ["read"]
}

path "secret/supabase/database" {
  capabilities = ["read"]
}

path "secret/web/*" {
  capabilities = ["read"]
}
