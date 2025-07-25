mod vault "./justfiles/vault.just"

set dotenv-required
set dotenv-load

default:
  @just --list

setup-cluster:
  kubectl kustomize --enable-helm ./cluster/ | kubectl apply -f - --server-side --force-conflicts
