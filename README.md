<h1 align=center>
  COINHUB ARGOCD MANIFEST
</h1>

<div align=center>
  <a href="https://sonarcloud.io/summary/new_code?id=coinhub-uit_argocd-manifest">
    <img alt="SonarQube Quality Gate" src="https://sonarcloud.io/api/project_badges/measure?project=coinhub-uit_argocd-manifest&metric=alert_status"/>
  </a>
  <a href="https://sonarcloud.io/summary/new_code?id=coinhub-uit_argocd-manifest">
    <img alt="SonarQube Quality Bug" src="https://sonarcloud.io/api/project_badges/measure?project=coinhub-uit_argocd-manifest&metric=bugs"/>
  </a>
  <a href="https://sonarcloud.io/summary/new_code?id=coinhub-uit_argocd-manifest">
    <img alt="SonarQube Quality Code Smells" src="https://sonarcloud.io/api/project_badges/measure?project=coinhub-uit_argocd-manifest&metric=code_smells"/>
  </a>
  <a href="https://sonarcloud.io/summary/new_code?id=coinhub-uit_argocd-manifest">
    <img alt="SonarQube Quality Maintainability Rating" src="https://sonarcloud.io/api/project_badges/measure?project=coinhub-uit_argocd-manifest&metric=sqale_rating"/>
  </a>
  <br />
  <a href="https://wakatime.com/badge/github/coinhub-uit/argocd-manifest">
    <img alt="Wakatime" src="https://wakatime.com/badge/github/coinhub-uit/argocd-manifest.svg"/>
  </a>
</div>

---

## Docs

### Requirements

- Cluster
- `kubectl`
- `helm`
- `argocd` (Optional)

### Setup

1. Setup argocd if not yet:
   ```sh
   kubectl apply -k ./cluster/argocd/
   ```
2. Setup vault if not yet:
   ```sh
   kubectl apply -k ./cluster/vault/
   ```

---

## References

- <https://github.com/hashicorp-education/learn-vault-secrets-operator/blob/main/justfile>
