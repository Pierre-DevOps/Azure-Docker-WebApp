#!/bin/bash

###############################################################################
# Script de déploiement Azure Container Instances
# Projet : Azure-Docker-WebApp
# Auteur : Pierre - Bachelor DevOps CCP1
###############################################################################

set -e  # Arrête le script en cas d'erreur

# ================================
# CONFIGURATION
# ================================
RESOURCE_GROUP="rg-docker-webapp-dev"
LOCATION="francecentral"
ACR_NAME="acrdockerpierredev"  # Nom unique requis (lettres minuscules et chiffres uniquement)
IMAGE_NAME="azure-docker-webapp"
IMAGE_TAG="latest"
CONTAINER_NAME="webapp-container"
DNS_NAME_LABEL="pierre-docker-webapp"  # Nom unique pour l'URL publique

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ================================
# FONCTIONS
# ================================
print_step() {
    echo -e "${GREEN}[ÉTAPE]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

check_azure_login() {
    print_step "Vérification de la connexion Azure..."
    if ! az account show &> /dev/null; then
        print_error "Vous n'êtes pas connecté à Azure"
        echo "Exécutez : az login"
        exit 1
    fi
    print_info "Connecté à Azure ✓"
}

# ================================
# SCRIPT PRINCIPAL
# ================================
echo "=============================================="
echo "  Déploiement Azure Container Instances"
echo "=============================================="
echo ""

# 1. Vérification de la connexion Azure
check_azure_login

# 2. Création du Resource Group
print_step "Création du Resource Group..."
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --output none

print_info "Resource Group '$RESOURCE_GROUP' créé ✓"

# 3. Création de l'Azure Container Registry (ACR)
print_step "Création de l'Azure Container Registry..."
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Basic \
    --admin-enabled true \
    --output none

print_info "ACR '$ACR_NAME' créé ✓"

# 4. Build et push de l'image Docker vers ACR
print_step "Build et push de l'image Docker..."
az acr build \
    --registry $ACR_NAME \
    --image $IMAGE_NAME:$IMAGE_TAG \
    --file Dockerfile \
    .

print_info "Image Docker buildée et pushée vers ACR ✓"

# 5. Récupération des credentials ACR
print_step "Récupération des credentials ACR..."
ACR_PASSWORD=$(az acr credential show \
    --name $ACR_NAME \
    --query "passwords[0].value" \
    --output tsv)

print_info "Credentials récupérés ✓"

# 6. Déploiement sur Azure Container Instances
print_step "Déploiement sur Azure Container Instances..."
az container create \
    --resource-group $RESOURCE_GROUP \
    --name $CONTAINER_NAME \
    --image $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG \
    --registry-login-server $ACR_NAME.azurecr.io \
    --registry-username $ACR_NAME \
    --registry-password $ACR_PASSWORD \
    --dns-name-label $DNS_NAME_LABEL \
    --ports 5000 \
    --cpu 1 \
    --memory 1 \
    --environment-variables ENVIRONMENT=Production \
    --output none

print_info "Container déployé sur ACI ✓"

# 7. Récupération de l'URL publique
print_step "Récupération de l'URL publique..."
FQDN=$(az container show \
    --resource-group $RESOURCE_GROUP \
    --name $CONTAINER_NAME \
    --query "ipAddress.fqdn" \
    --output tsv)

# ================================
# RÉSUMÉ DU DÉPLOIEMENT
# ================================
echo ""
echo "=============================================="
echo "  ✓ DÉPLOIEMENT RÉUSSI !"
echo "=============================================="
echo ""
echo "Resource Group : $RESOURCE_GROUP"
echo "ACR            : $ACR_NAME.azurecr.io"
echo "Container      : $CONTAINER_NAME"
echo ""
echo "🌐 URL de l'application :"
echo "   http://$FQDN:5000"
echo ""
echo "=============================================="
echo ""
echo "Commandes utiles :"
echo "  - Voir les logs : az container logs -g $RESOURCE_GROUP -n $CONTAINER_NAME"
echo "  - État du container : az container show -g $RESOURCE_GROUP -n $CONTAINER_NAME"
echo "  - Supprimer les ressources : az group delete -g $RESOURCE_GROUP --yes --no-wait"
echo ""
