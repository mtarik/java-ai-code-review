#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════
# 🚀 Script de Déploiement Automatique
# Déploie le workflow de revue de code sur tous vos repositories Java
# ════════════════════════════════════════════════════════════════════════════

set -e

# Couleurs pour le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_USER="mtarik"  # Changez avec votre nom d'utilisateur
WORKFLOW_FILE="workflow-template.yml"

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🤖 Déploiement Automatique - Revue de Code IA${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Vérifier que gh CLI est installé
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) n'est pas installé${NC}"
    echo -e "${YELLOW}Installez-le depuis: https://cli.github.com${NC}"
    exit 1
fi

# Vérifier l'authentification
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}⚠️  Vous devez vous authentifier avec GitHub CLI${NC}"
    echo -e "${YELLOW}Exécutez: gh auth login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ GitHub CLI configuré${NC}"
echo ""

# Récupérer tous les repositories de l'utilisateur
echo -e "${BLUE}📋 Récupération de la liste de vos repositories...${NC}"
REPOS=$(gh repo list $GITHUB_USER --json name,primaryLanguage,isArchived --limit 1000 | \
    jq -r '.[] | select(.primaryLanguage.name == "Java" and .isArchived == false) | .name')

if [ -z "$REPOS" ]; then
    echo -e "${YELLOW}⚠️  Aucun repository Java actif trouvé${NC}"
    exit 0
fi

echo -e "${GREEN}Repositories Java trouvés:${NC}"
echo "$REPOS" | while read repo; do
    echo -e "  • $repo"
done
echo ""

# Confirmation
echo -e "${YELLOW}⚠️  Le workflow sera déployé sur ces repositories${NC}"
read -p "Continuer? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Annulé${NC}"
    exit 0
fi
echo ""

# Lire le contenu du workflow template
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo -e "${RED}❌ Fichier $WORKFLOW_FILE introuvable${NC}"
    exit 1
fi

WORKFLOW_CONTENT=$(cat $WORKFLOW_FILE | base64)
SUCCESS_COUNT=0
SKIP_COUNT=0
ERROR_COUNT=0

# Déployer sur chaque repository
echo "$REPOS" | while read repo; do
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📦 Repository: $repo${NC}"
    
    # Vérifier si le workflow existe déjà
    if gh api "repos/$GITHUB_USER/$repo/contents/.github/workflows/ai-code-review.yml" &> /dev/null; then
        echo -e "${YELLOW}  ⏭️  Workflow déjà présent, ignoré${NC}"
        ((SKIP_COUNT++))
        continue
    fi
    
    # Créer le fichier via l'API GitHub
    echo -e "  📝 Déploiement du workflow..."
    
    RESPONSE=$(gh api \
        --method PUT \
        "repos/$GITHUB_USER/$repo/contents/.github/workflows/ai-code-review.yml" \
        -f message="feat: activation de la revue de code IA automatique

Workflow centralisé depuis java-ai-code-review.
Le bot analysera automatiquement:
- Les Pull Requests avec des modifications Java
- Les commits sur main/develop/feature branches

Configuration requise:
- Ajouter le secret ANTHROPIC_API_KEY dans les settings

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>" \
        -f content="$WORKFLOW_CONTENT" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  ✅ Déployé avec succès${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}  ❌ Erreur lors du déploiement${NC}"
        echo -e "${RED}     $RESPONSE${NC}"
        ((ERROR_COUNT++))
    fi
done

# Résumé final
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 RÉSUMÉ DU DÉPLOIEMENT${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Déployés avec succès: $SUCCESS_COUNT${NC}"
echo -e "${YELLOW}⏭️  Déjà présents (ignorés): $SKIP_COUNT${NC}"
if [ $ERROR_COUNT -gt 0 ]; then
    echo -e "${RED}❌ Erreurs: $ERROR_COUNT${NC}"
fi
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: N'oubliez pas de configurer le secret ANTHROPIC_API_KEY${NC}"
echo -e "${YELLOW}   pour chaque repository:${NC}"
echo -e "${YELLOW}   https://github.com/$GITHUB_USER/REPO_NAME/settings/secrets/actions${NC}"
echo ""
echo -e "${GREEN}✨ Déploiement terminé!${NC}"
