#!/bin/bash
# ════════════════════════════════════════════════════════════════════════════
# 🔐 Configuration Automatique des Secrets
# Configure le secret ANTHROPIC_API_KEY sur tous vos repositories Java
# ════════════════════════════════════════════════════════════════════════════

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

GITHUB_USER="mtarik"

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🔐 Configuration Automatique des Secrets${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Vérifier gh CLI
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) requis${NC}"
    exit 1
fi

# Demander la clé API
echo -e "${YELLOW}🔑 Entrez votre clé API Anthropic (sera masquée):${NC}"
read -s ANTHROPIC_API_KEY
echo ""

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "${RED}❌ Clé API vide${NC}"
    exit 1
fi

# Vérifier le format de la clé
if [[ ! $ANTHROPIC_API_KEY =~ ^sk-ant- ]]; then
    echo -e "${YELLOW}⚠️  La clé ne commence pas par 'sk-ant-', êtes-vous sûr?${NC}"
    read -p "Continuer quand même? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Récupérer les repos Java
echo -e "${BLUE}📋 Récupération des repositories...${NC}"
REPOS=$(gh repo list $GITHUB_USER --json name,primaryLanguage,isArchived --limit 1000 | \
    jq -r '.[] | select(.primaryLanguage.name == "Java" and .isArchived == false) | .name')

if [ -z "$REPOS" ]; then
    echo -e "${YELLOW}⚠️  Aucun repository Java trouvé${NC}"
    exit 0
fi

echo -e "${GREEN}Repositories Java:${NC}"
echo "$REPOS" | while read repo; do
    echo -e "  • $repo"
done
echo ""

echo -e "${YELLOW}⚠️  Le secret ANTHROPIC_API_KEY sera configuré sur ces repos${NC}"
read -p "Continuer? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi
echo ""

SUCCESS_COUNT=0
ERROR_COUNT=0

# Configurer le secret sur chaque repo
echo "$REPOS" | while read repo; do
    echo -e "${BLUE}🔐 Configuration du secret pour: $repo${NC}"
    
    if gh secret set ANTHROPIC_API_KEY -b "$ANTHROPIC_API_KEY" -R "$GITHUB_USER/$repo" &> /dev/null; then
        echo -e "${GREEN}  ✅ Secret configuré${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}  ❌ Erreur${NC}"
        ((ERROR_COUNT++))
    fi
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Succès: $SUCCESS_COUNT${NC}"
if [ $ERROR_COUNT -gt 0 ]; then
    echo -e "${RED}❌ Erreurs: $ERROR_COUNT${NC}"
fi
echo ""
echo -e "${GREEN}✨ Configuration terminée!${NC}"
