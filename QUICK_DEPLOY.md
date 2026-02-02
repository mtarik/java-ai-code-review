# ⚡ Déploiement Express - 2 Minutes Chrono

## 🎯 Pour Windows

### Prérequis (Installation Une Seule Fois)

```powershell
# Installer GitHub CLI
winget install GitHub.cli

# Redémarrer le terminal, puis s'authentifier
gh auth login
```

### Déploiement (2 Commandes)

```powershell
# Cloner le repo central
git clone https://github.com/mtarik/java-ai-code-review.git
cd java-ai-code-review

# Option 1: Via Git Bash (recommandé)
bash deploy-to-all-repos.sh
bash setup-secrets.sh

# Option 2: Via les fichiers .bat
deploy-to-all-repos.bat
```

---

## 🐧 Pour Linux/Mac

```bash
# Installer GitHub CLI
# Mac:
brew install gh

# Linux (Ubuntu/Debian):
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# S'authentifier
gh auth login

# Cloner et déployer
git clone https://github.com/mtarik/java-ai-code-review.git
cd java-ai-code-review

chmod +x deploy-to-all-repos.sh setup-secrets.sh
./deploy-to-all-repos.sh
./setup-secrets.sh
```

---

## 📋 Ce Que Font Les Scripts

### Script 1: `deploy-to-all-repos.sh`

1. ✅ Trouve automatiquement tous vos repositories Java sur GitHub
2. ✅ Vérifie si le workflow existe déjà (ne duplique pas)
3. ✅ Déploie un fichier workflow minimal (60 lignes) dans `.github/workflows/`
4. ✅ Crée un commit automatiquement
5. ✅ Affiche un résumé du déploiement

**Durée: ~5 secondes par repository**

### Script 2: `setup-secrets.sh`

1. ✅ Vous demande votre clé API Anthropic (une seule fois)
2. ✅ Configure automatiquement le secret `ANTHROPIC_API_KEY` sur tous les repos Java
3. ✅ Masque la clé pendant la saisie pour la sécurité

**Durée: ~2 secondes par repository**

---

## ✨ Après le Déploiement

Le bot est maintenant actif sur tous vos repositories Java!

Il va automatiquement:
- 🔍 Analyser chaque Pull Request avec des modifications Java
- 💬 Poster des commentaires directement sur les lignes de code
- 📊 Fournir un score de qualité et des suggestions
- ✅ S'améliorer automatiquement quand vous mettez à jour `java-ai-code-review`

---

## 🔧 Personnalisation

Le workflow déployé utilise ces paramètres par défaut:

```yaml
java-version: '17'
build-tool: 'auto'
enable-static-analysis: true
post-pr-comment: true
fail-on-critical: false
```

Pour personnaliser, éditez `.github/workflows/ai-code-review.yml` dans le repo concerné.

---

## 🐛 Dépannage

### "gh: command not found"

GitHub CLI n'est pas installé. Installez-le:
- Windows: `winget install GitHub.cli`
- Mac: `brew install gh`
- Linux: Voir instructions ci-dessus

### "gh auth status: not logged in"

Authentifiez-vous:
```bash
gh auth login
```

### "No Java repositories found"

Aucun de vos repositories n'a Java comme langage principal sur GitHub. 
Vérifiez que vos repos Java ont bien du code Java committé.

### Le workflow ne se déclenche pas

1. Vérifiez que le secret `ANTHROPIC_API_KEY` est bien configuré
2. Vérifiez que des fichiers `.java` sont modifiés dans la PR
3. Consultez l'onglet "Actions" du repository pour voir les logs

---

## 📞 Support

Problème? [Ouvrez une issue](https://github.com/mtarik/java-ai-code-review/issues)

---

🤖 **Propulsé par Claude Sonnet 4.5**
