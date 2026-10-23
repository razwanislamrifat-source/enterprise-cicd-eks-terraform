# Purging the Hardcoded DockerHub Secret from Git History

The file `k8s/secret.yaml` previously contained a base64-encoded DockerHub credential (`razwanff` / `godoffreefiremax.`). You must rotate that token immediately.

## Step 1: Rotate the Exposed Credential
Log in to DockerHub and regenerate or revoke the access token / password that was exposed.

## Step 2: Purge from Git History

Using `git-filter-repo` (recommended):
```bash
# Install git-filter-repo first (https://github.com/newren/git-filter-repo)
git filter-repo --path k8s/secret.yaml --invert-paths
```

Using BFG Repo-Cleaner:
```bash
# Download bfg.jar
java -jar bfg.jar --delete-files k8s/secret.yaml .
java -jar bfg.jar --replace-text expressions.txt .
```

## Step 3: Rewrite and Force-Push
```bash
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force --all
git push --force --tags
```

## Step 4: Verify
```bash
git log --all --full-history -- k8s/secret.yaml
# Should return nothing.
```
After rewriting history, all collaborators must re-clone the repository. Never commit secrets again; use ExternalSecrets or SealedSecrets (see `k8s/secret.yaml`).
