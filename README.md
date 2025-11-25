# 🐳 Azure Docker WebApp

Application web Python (Flask) conteneurisée et déployée sur Azure Container Instances.

**Projet DevOps - CCP1 Bachelor Administrateur Système DevOps**

---

## 📋 Table des matières

- [Présentation](#-présentation)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation locale](#-installation-locale)
- [Utilisation avec Docker](#-utilisation-avec-docker)
- [Déploiement sur Azure](#-déploiement-sur-azure)
- [Commandes utiles](#-commandes-utiles)
- [Compétences démontrées](#-compétences-démontrées)

---

## 🎯 Présentation

Ce projet démontre la maîtrise de la conteneurisation avec Docker et du déploiement automatisé sur le cloud Azure.

### Fonctionnalités

✅ Application web Flask affichant les informations du conteneur  
✅ Dockerfile optimisé avec image Alpine (légère)  
✅ Sécurité : utilisateur non-root, health check  
✅ Docker Compose pour orchestration locale  
✅ Script de déploiement automatisé vers Azure  
✅ Azure Container Registry pour stockage des images  
✅ Azure Container Instances pour l'exécution  

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   DÉVELOPPEMENT                      │
├─────────────────────────────────────────────────────┤
│  Code Python (Flask)                                │
│         ↓                                           │
│  Dockerfile → Image Docker                          │
│         ↓                                           │
│  Test local avec Docker Compose                     │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                    PRODUCTION                        │
├─────────────────────────────────────────────────────┤
│  Azure Container Registry (ACR)                     │
│         ↓                                           │
│  Azure Container Instances (ACI)                    │
│         ↓                                           │
│  Application accessible via URL publique            │
└─────────────────────────────────────────────────────┘
```

### Structure du projet

```
Azure-Docker-WebApp/
├── app/
│   ├── app.py              # Application Flask
│   └── requirements.txt    # Dépendances Python
├── scripts/
│   └── deploy-to-azure.sh  # Script de déploiement Azure
├── Dockerfile              # Instructions de build Docker
├── docker-compose.yml      # Orchestration locale
├── .dockerignore          # Fichiers exclus du build
└── README.md              # Documentation (ce fichier)
```

---

## 🔧 Prérequis

### Outils nécessaires

- **Docker Desktop** : [Télécharger ici](https://www.docker.com/products/docker-desktop/)
- **Docker Compose** : Inclus avec Docker Desktop
- **Azure CLI** : [Installer ici](https://learn.microsoft.com/cli/azure/install-azure-cli)
- **Compte Azure** : [Créer un compte gratuit](https://azure.microsoft.com/free/)

### Vérification des installations

```bash
# Vérifier Docker
docker --version

# Vérifier Docker Compose
docker-compose --version

# Vérifier Azure CLI
az --version

# Se connecter à Azure
az login
```

---

## 💻 Installation locale

### Méthode 1 : Sans Docker (développement)

```bash
# 1. Cloner le dépôt
git clone https://github.com/VOTRE_USERNAME/Azure-Docker-WebApp.git
cd Azure-Docker-WebApp

# 2. Créer un environnement virtuel Python
python -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate

# 3. Installer les dépendances
pip install -r app/requirements.txt

# 4. Lancer l'application
cd app
python app.py

# 5. Accéder à l'application
# Ouvrir : http://localhost:5000
```

---

## 🐳 Utilisation avec Docker

### Option A : Docker Compose (recommandé)

```bash
# 1. Build et démarrer le conteneur
docker-compose up -d

# 2. Voir les logs
docker-compose logs -f

# 3. Accéder à l'application
# Ouvrir : http://localhost:8080

# 4. Arrêter le conteneur
docker-compose down
```

### Option B : Commandes Docker natives

```bash
# 1. Build de l'image
docker build -t azure-docker-webapp:latest .

# 2. Lancer le conteneur
docker run -d \
  --name webapp \
  -p 8080:5000 \
  -e ENVIRONMENT=Development \
  azure-docker-webapp:latest

# 3. Voir les logs
docker logs -f webapp

# 4. Accéder à l'application
# Ouvrir : http://localhost:8080

# 5. Arrêter et supprimer le conteneur
docker stop webapp
docker rm webapp
```

---

## ☁️ Déploiement sur Azure

### Méthode automatique (script fourni)

```bash
# 1. Se connecter à Azure
az login

# 2. Vérifier votre abonnement actif
az account show

# 3. Lancer le déploiement
cd scripts
./deploy-to-azure.sh
```

Le script va automatiquement :
1. ✅ Créer un Resource Group
2. ✅ Créer un Azure Container Registry (ACR)
3. ✅ Builder et pusher l'image Docker vers ACR
4. ✅ Déployer sur Azure Container Instances (ACI)
5. ✅ Afficher l'URL publique de l'application

### Méthode manuelle (étape par étape)

```bash
# 1. Variables
RESOURCE_GROUP="rg-docker-webapp"
ACR_NAME="acrdockerpierredev"
IMAGE_NAME="azure-docker-webapp"
CONTAINER_NAME="webapp-container"

# 2. Créer le Resource Group
az group create --name $RESOURCE_GROUP --location francecentral

# 3. Créer l'Azure Container Registry
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# 4. Build et push de l'image vers ACR
az acr build \
  --registry $ACR_NAME \
  --image $IMAGE_NAME:latest \
  --file Dockerfile .

# 5. Récupérer le mot de passe ACR
ACR_PASSWORD=$(az acr credential show \
  --name $ACR_NAME \
  --query "passwords[0].value" -o tsv)

# 6. Déployer sur ACI
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME \
  --image $ACR_NAME.azurecr.io/$IMAGE_NAME:latest \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --dns-name-label pierre-docker-webapp \
  --ports 5000 \
  --cpu 1 \
  --memory 1

# 7. Récupérer l'URL
az container show \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME \
  --query "ipAddress.fqdn" -o tsv
```

---

## 📝 Commandes utiles

### Gestion Docker locale

```bash
# Voir les images
docker images

# Voir les conteneurs en cours
docker ps

# Voir tous les conteneurs (y compris arrêtés)
docker ps -a

# Entrer dans un conteneur en cours
docker exec -it webapp /bin/sh

# Supprimer une image
docker rmi azure-docker-webapp:latest

# Nettoyer les ressources inutilisées
docker system prune -a
```

### Gestion Azure

```bash
# Voir les logs du conteneur ACI
az container logs -g rg-docker-webapp -n webapp-container

# État du conteneur
az container show -g rg-docker-webapp -n webapp-container

# Redémarrer le conteneur
az container restart -g rg-docker-webapp -n webapp-container

# Supprimer le conteneur
az container delete -g rg-docker-webapp -n webapp-container --yes

# Supprimer toutes les ressources
az group delete -g rg-docker-webapp --yes --no-wait

# Lister les images dans ACR
az acr repository list --name acrdockerpierredev

# Supprimer une image dans ACR
az acr repository delete \
  --name acrdockerpierredev \
  --image azure-docker-webapp:latest \
  --yes
```

---

## 🎓 Compétences démontrées (CCP1)

Ce projet couvre les compétences du **CCP1 - Automatiser le déploiement d'une infrastructure dans le cloud** :

### 1️⃣ Automatisation du déploiement
- ✅ Dockerfile pour automatiser la création d'images
- ✅ Docker Compose pour orchestration
- ✅ Script Bash pour déploiement Azure automatisé
- ✅ Infrastructure as Code (configuration déclarative)

### 2️⃣ Mise en production dans le cloud
- ✅ Déploiement sur Azure Container Instances
- ✅ Azure Container Registry pour stockage d'images
- ✅ URL publique avec DNS personnalisé
- ✅ Configuration de ressources (CPU, mémoire)

### 3️⃣ Sécurisation de l'infrastructure
- ✅ Utilisateur non-root dans le conteneur
- ✅ Image Alpine légère (surface d'attaque réduite)
- ✅ Health check pour monitoring
- ✅ Credentials sécurisés avec ACR
- ✅ Fichier .dockerignore pour éviter les fuites de données

---

## 📸 Captures d'écran (pour le DP)

### Étapes à documenter

1. **Build Docker local**
   ```bash
   docker build -t azure-docker-webapp:latest .
   ```
   📸 Capture : Sortie de la commande montrant les layers

2. **Test local**
   ```bash
   docker-compose up -d
   ```
   📸 Capture : Page web sur http://localhost:8080

3. **Déploiement Azure**
   ```bash
   ./scripts/deploy-to-azure.sh
   ```
   📸 Capture : Sortie du script avec l'URL finale

4. **Application déployée**
   📸 Capture : Page web sur Azure avec l'URL publique

5. **Portail Azure**
   📸 Capture : Resource Group avec ACR et ACI visibles

---

## 🔗 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Azure Container Instances](https://learn.microsoft.com/azure/container-instances/)
- [Azure Container Registry](https://learn.microsoft.com/azure/container-registry/)
- [Flask Documentation](https://flask.palletsprojects.com/)

---

## 👤 Auteur

**Pierre** - Étudiant DevOps  
Bachelor Administrateur Système DevOps (RNCP36061) - CCP1

📧 Contact : [Votre email professionnel]  
🔗 LinkedIn : [Votre profil LinkedIn]  
💻 GitHub : [Votre GitHub]

---

## 📄 Licence

Ce projet est créé à des fins pédagogiques dans le cadre du Bachelor DevOps.

---

**Dernière mise à jour** : Novembre 2024
