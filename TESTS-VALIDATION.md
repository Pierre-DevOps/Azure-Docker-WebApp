# ✅ Guide de Test et Validation

Ce document contient toutes les étapes pour tester et valider le projet Docker localement et sur Azure.

## 📋 Checklist de validation

- [ ] Le projet build correctement
- [ ] L'application démarre en local
- [ ] L'application est accessible dans le navigateur
- [ ] Le healthcheck fonctionne
- [ ] L'image Docker est optimisée (< 200 MB)
- [ ] Le déploiement Azure réussit
- [ ] L'application est accessible publiquement sur Azure

## 🧪 Tests locaux

### 1. Vérifier la structure du projet

```bash
cd Azure-Docker-WebApp
tree -L 2
```

**Résultat attendu :**
```
.
├── app
│   ├── app.py
│   └── requirements.txt
├── scripts
│   └── deploy-to-azure.sh
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── .gitignore
├── README.md
└── CONCEPTS-DOCKER.md
```

### 2. Build de l'image Docker

```bash
# Construction de l'image
docker build -t devops-webapp:latest .
```

**Ce que tu dois voir :**
- Chaque étape du Dockerfile s'exécute
- `CACHED` pour les layers déjà buildés
- `Successfully tagged devops-webapp:latest` à la fin

**Vérifier l'image créée :**
```bash
docker images | grep devops-webapp
```

**Résultat attendu :**
```
devops-webapp    latest    abc123def456    2 minutes ago    150MB
```

### 3. Tester avec Docker Compose

```bash
# Démarrer l'application
docker-compose up -d

# Vérifier que le conteneur tourne
docker-compose ps
```

**Résultat attendu :**
```
NAME                IMAGE                  STATUS
devops-webapp       devops-webapp:latest   Up 5 seconds (healthy)
```

### 4. Vérifier les logs

```bash
# Voir les logs
docker-compose logs

# Ou en mode temps réel
docker-compose logs -f
```

**Résultat attendu :**
```
devops-webapp | * Running on all addresses (0.0.0.0)
devops-webapp | * Running on http://127.0.0.1:5000
devops-webapp | * Running on http://172.18.0.2:5000
```

### 5. Tester l'application dans le navigateur

**Ouvrir :** http://localhost:8080

**Tu dois voir :**
- Une page web avec le titre "Application Docker DevOps"
- Le hostname du conteneur
- L'environnement (Development)
- Un badge vert "Application Conteneurisée"

### 6. Tester le healthcheck

```bash
# Via curl
curl http://localhost:8080/health

# Ou dans le navigateur
# http://localhost:8080/health
```

**Résultat attendu :**
```json
{
  "status": "healthy",
  "service": "docker-webapp"
}
```

### 7. Vérifier le statut du healthcheck

```bash
docker inspect devops-webapp | grep -A 5 Health
```

**Résultat attendu :**
```json
"Health": {
    "Status": "healthy",
    "FailingStreak": 0,
    ...
}
```

### 8. Tester les commandes Docker manuelles

```bash
# Arrêter et supprimer le conteneur Docker Compose
docker-compose down

# Build manuel
docker build -t devops-webapp:test .

# Run manuel avec options
docker run -d \
  --name webapp-test \
  -p 9090:5000 \
  -e ENVIRONMENT=Test \
  devops-webapp:test

# Vérifier
docker ps

# Accéder à l'app sur http://localhost:9090

# Nettoyer
docker stop webapp-test
docker rm webapp-test
docker rmi devops-webapp:test
```

### 9. Inspecter le conteneur

```bash
# Redémarrer avec Docker Compose
docker-compose up -d

# Accéder au shell du conteneur
docker exec -it devops-webapp /bin/bash

# Une fois dedans, vérifier :
whoami              # Doit afficher "appuser" (pas root !)
pwd                 # Doit afficher /app
ls -la              # Voir les fichiers de l'app
python --version    # Vérifier la version Python
exit                # Sortir du conteneur
```

### 10. Vérifier la taille de l'image

```bash
docker images devops-webapp
```

**Résultat attendu :**
- Taille < 200 MB (grâce au multi-stage build)

**Comparer avec une image non-optimisée :**
```bash
# Build sans multi-stage (pour comparaison)
docker build -f- -t devops-webapp:unoptimized . << 'EOF'
FROM python:3.11
WORKDIR /app
COPY app/requirements.txt .
RUN pip install -r requirements.txt
COPY app/ .
CMD ["python", "app.py"]
EOF

# Comparer les tailles
docker images | grep devops-webapp
```

### 11. Tester les variables d'environnement

```bash
# Arrêter l'application
docker-compose down

# Modifier docker-compose.yml pour changer ENVIRONMENT=Staging

# Redémarrer
docker-compose up -d

# Vérifier dans le navigateur que "Environnement: Staging" s'affiche
```

### 12. Test de charge (optionnel)

```bash
# Installer Apache Bench (si pas déjà installé)
# sudo apt install apache2-utils

# Envoyer 1000 requêtes avec 10 connexions concurrentes
ab -n 1000 -c 10 http://localhost:8080/

# Voir les statistiques pendant le test
docker stats devops-webapp
```

## ☁️ Tests sur Azure

### 1. Vérifier les prérequis Azure

```bash
# Vérifier que Azure CLI est installé
az --version

# Se connecter à Azure
az login

# Vérifier l'abonnement actif
az account show --output table
```

### 2. Exécuter le script de déploiement

```bash
# Rendre le script exécutable
chmod +x scripts/deploy-to-azure.sh

# Exécuter le déploiement (attention : cela va créer des ressources Azure !)
./scripts/deploy-to-azure.sh
```

**Ce que tu dois voir :**
- Création du groupe de ressources ✓
- Création de l'Azure Container Registry ✓
- Build et push de l'image ✓
- Déploiement sur Azure Container Instances ✓
- URL publique affichée

### 3. Vérifier les ressources Azure

```bash
# Lister les ressources créées
az resource list --resource-group rg-docker-webapp --output table

# Voir les détails du conteneur
az container show \
  --resource-group rg-docker-webapp \
  --name devops-webapp \
  --output table
```

### 4. Tester l'application sur Azure

```bash
# Récupérer l'URL (FQDN)
FQDN=$(az container show \
  --resource-group rg-docker-webapp \
  --name devops-webapp \
  --query ipAddress.fqdn \
  --output tsv)

echo "URL: http://${FQDN}:5000"

# Tester le healthcheck
curl http://${FQDN}:5000/health
```

**Ou ouvre l'URL dans le navigateur**

### 5. Voir les logs Azure

```bash
# Logs en temps réel
az container logs \
  --resource-group rg-docker-webapp \
  --name devops-webapp \
  --follow
```

### 6. Vérifier les images dans ACR

```bash
# Lister les images dans le registry
ACR_NAME=$(az acr list --resource-group rg-docker-webapp --query [0].name -o tsv)

az acr repository list --name $ACR_NAME --output table

# Voir les tags
az acr repository show-tags \
  --name $ACR_NAME \
  --repository devops-webapp \
  --output table
```

### 7. Tester le redémarrage automatique

```bash
# Arrêter le conteneur (Azure va le redémarrer automatiquement)
az container stop \
  --resource-group rg-docker-webapp \
  --name devops-webapp

# Attendre quelques secondes

# Vérifier l'état
az container show \
  --resource-group rg-docker-webapp \
  --name devops-webapp \
  --query instanceView.state \
  --output tsv
```

### 8. Nettoyage Azure

**⚠️ IMPORTANT : Supprimer les ressources pour éviter les frais**

```bash
# Supprimer le groupe de ressources (et toutes les ressources dedans)
az group delete \
  --name rg-docker-webapp \
  --yes \
  --no-wait

# Vérifier que les ressources sont supprimées
az group list --output table | grep rg-docker-webapp
```

## 📸 Captures d'écran pour le DP

Prends des captures d'écran de :

### Local
1. ✅ `docker build` en cours
2. ✅ `docker images` avec ta nouvelle image
3. ✅ `docker-compose ps` avec le conteneur "healthy"
4. ✅ Application dans le navigateur (localhost:8080)
5. ✅ `docker logs` montrant que l'app fonctionne
6. ✅ Healthcheck dans le navigateur (/health)
7. ✅ `docker inspect` montrant l'utilisateur non-root

### Azure
8. ✅ Script de déploiement en cours d'exécution
9. ✅ Azure Portal - Groupe de ressources
10. ✅ Azure Portal - Container Registry avec l'image
11. ✅ Azure Portal - Container Instance en cours d'exécution
12. ✅ Application accessible via l'URL Azure
13. ✅ Logs dans Azure Portal ou via CLI

## 🐛 Dépannage

### Le build échoue

```bash
# Nettoyer le cache Docker
docker builder prune

# Rebuild sans cache
docker build --no-cache -t devops-webapp:latest .
```

### Le conteneur ne démarre pas

```bash
# Voir les logs d'erreur
docker logs devops-webapp

# Vérifier les processus
docker top devops-webapp
```

### Port déjà utilisé

```bash
# Trouver quel processus utilise le port 8080
sudo lsof -i :8080

# Ou changer le port dans docker-compose.yml
ports:
  - "9090:5000"  # Utiliser le port 9090 au lieu de 8080
```

### L'image est trop grosse

```bash
# Vérifier la taille de chaque layer
docker history devops-webapp:latest

# Identifier les layers les plus gros
docker history devops-webapp:latest --human --no-trunc
```

### Problème de permissions sur Azure

```bash
# Vérifier que tu as les bonnes permissions
az role assignment list --assignee $(az account show --query user.name -o tsv) --output table
```

## ✅ Validation finale

**Ton projet est prêt pour GitHub et le DP si :**

✅ L'image build en moins de 2 minutes  
✅ L'image fait moins de 200 MB  
✅ L'application démarre en moins de 5 secondes  
✅ Le healthcheck est "healthy"  
✅ L'application est accessible en local (http://localhost:8080)  
✅ Le déploiement Azure réussit  
✅ L'application est accessible publiquement sur Azure  
✅ Le README est complet  
✅ Toutes les captures d'écran sont prises  
✅ Le code est sur GitHub avec un bon commit message  

## 📝 Commit sur GitHub

```bash
# Initialiser Git
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "🐳 Initial commit: Docker WebApp with Azure deployment"

# Ajouter le remote GitHub
git remote add origin https://github.com/TON-USERNAME/Azure-Docker-WebApp.git

# Pousser sur GitHub
git push -u origin main
```

---

**Félicitations ! Tu as maintenant un projet Docker professionnel pour ton portfolio DevOps ! 🎉**
