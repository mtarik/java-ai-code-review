# 🚀 Guide de Déploiement - Revue de Code IA Centralisée

Ce guide explique comment activer la revue de code IA automatique sur tous vos repositories Java existants.

## 📋 Prérequis

1. Une clé API Anthropic (Claude)
2. Accès administrateur aux repositories GitHub

## 🎯 Déploiement Rapide

### Étape 1: Configurer le Secret

Pour chaque repository où vous voulez activer la revue de code:

1. Allez sur `https://github.com/VOTRE_USERNAME/VOTRE_REPO/settings/secrets/actions`
2. Cliquez sur **"New repository secret"**
3. **Name**: `ANTHROPIC_API_KEY`
4. **Value**: Votre clé API Anthropic (commence par `sk-ant-`)
5. Cliquez sur **"Add secret"**

### Étape 2: Ajouter le Workflow

Créez le fichier `.github/workflows/ai-code-review.yml` dans votre repository:

```yaml
name: 🤖 AI Code Review

on:
  pull_request:
    types: [opened, synchronize, reopened]
    paths:
      - '**.java'

  push:
    branches:
      - main
      - develop
      - 'feature/**'
    paths:
      - '**.java'

  workflow_dispatch:

jobs:
  call-ai-review:
    name: 📊 Analyse IA du code Java
    uses: mtarik/java-ai-code-review/.github/workflows/reusable-ai-review.yml@main

    with:
      java-version: '17'
      build-tool: 'auto'
      enable-static-analysis: true
      post-pr-comment: true
      fail-on-critical: false

    secrets:
      ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Étape 3: Commit et Push

```bash
git add .github/workflows/ai-code-review.yml
git commit -m "feat: activation de la revue de code IA automatique"
git push
```

## ✅ C'est Tout!

Le bot est maintenant actif et va:
- ✅ Analyser automatiquement chaque Pull Request
- ✅ Poster des commentaires sur les lignes de code problématiques
- ✅ Fournir des suggestions d'amélioration
- ✅ Donner un score de qualité

## 🎨 Personnalisation

Vous pouvez personnaliser le workflow avec ces paramètres:

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `java-version` | Version de Java (8, 11, 17, 21, etc.) | `'17'` |
| `build-tool` | Outil de build (`auto`, `maven`, `gradle`) | `'auto'` |
| `enable-static-analysis` | Activer Checkstyle/PMD | `true` |
| `post-pr-comment` | Poster des commentaires sur les PR | `true` |
| `fail-on-critical` | Échouer si problèmes critiques | `false` |

### Exemple avec Java 11 et Gradle:

```yaml
with:
  java-version: '11'
  build-tool: 'gradle'
  enable-static-analysis: false
```

## 📂 Pour Plusieurs Repositories

Pour déployer sur plusieurs repositories à la fois:

### Option 1: Manuellement

Répétez les étapes 1-3 pour chaque repository.

### Option 2: Script Automatique

```bash
# Liste de vos repositories
REPOS=("repo1" "repo2" "repo3")

for repo in "${REPOS[@]}"; do
  cd "$repo"
  mkdir -p .github/workflows
  cp ../ai-code-review.yml .github/workflows/
  git add .github/workflows/ai-code-review.yml
  git commit -m "feat: activation revue de code IA"
  git push
  cd ..
done
```

## 🔧 Maintenance

### Mise à Jour Automatique

Tous vos repositories utilisent le workflow centralisé `@main`. 
Les améliorations apportées à `java-ai-code-review` sont **automatiquement disponibles** dans tous les repositories!

Aucune maintenance nécessaire dans les repositories individuels.

### Désactivation Temporaire

Pour désactiver temporairement le bot sur un repository:

```yaml
on:
  workflow_dispatch:  # Seulement manuel
```

## 🐛 Dépannage

### Le workflow ne se déclenche pas

- Vérifiez que le secret `ANTHROPIC_API_KEY` est configuré
- Vérifiez que des fichiers `.java` sont modifiés
- Vérifiez que la branche est dans la liste des déclencheurs

### Erreur "invalid x-api-key"

- La clé API est invalide ou expirée
- Mettez à jour le secret avec une nouvelle clé

### Pas de commentaires inline

- C'est normal si aucune ligne modifiée n'a de problème
- Consultez le résumé général du review

## 📞 Support

Pour toute question ou problème:
1. Consultez les logs dans l'onglet Actions du repository
2. Vérifiez les artefacts uploadés pour les rapports détaillés
3. Ouvrez une issue sur `java-ai-code-review`

---

🤖 Propulsé par Claude Sonnet 4.5
