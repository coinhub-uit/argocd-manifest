mod vault "./justfiles/vault.just"

set dotenv-required
set dotenv-load

default:
  @just --list

setup-cluster:
  kubectl kustomize --enable-helm ./cluster/ | kubectl apply -f - --server-side --force-conflicts

setup-argocd-apps:
  kubectl apply -k ./argocd/ --server-side --force-conflicts

port-forward service="services/coinhub-istio" port="443":
  #!/usr/bin/env bash
  kubectl=$(which kubectl)
  kube_config=$(~/.kube/config)
  sudo $kubectl --kubeconfig=$kube_config port-forward -n gateway --address=0.0.0.0 {{service}} {{port}}:{{port}}

