path "secret/data/server/*" {
  capabilities = ["read", "list"]
}

path "secret/data/supabase/config" {
  capabilities = ["read"]
}

path "secret/data/supabase/database" {
  capabilities = ["read"]
}

path "secret/data/web/config" {
  capabilities = ["read"]
}
