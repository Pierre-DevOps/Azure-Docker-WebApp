# 🐳 Docker Cheat Sheet - Commandes essentielles

Guide rapide des commandes Docker les plus utilisées pour ton projet.

## 📦 Images Docker

### Construire une image
```bash
# Build basique
docker build -t nom-image:tag .

# Build sans cache (force la reconstruction complète)
docker build --no-cache -t nom-image:tag .

# Build avec un Dockerfile spécifique
docker build -f Dockerfile.dev -t nom-image:dev .

# Build avec des arguments
docker build --build-arg VERSION=1.0 -t nom-image:1.0 .
```

### Lister les images
```bash
# Toutes les images
docker images

# Filtrer par nom
docker images | grep devops-webapp

# Afficher les IDs uniquement
docker images -q
```

### Supprimer des images
```bash
# Supprimer une image
docker rmi nom-image:tag

# Supprimer une image par ID
docker rmi abc123def456

# Forcer la suppression
docker rmi -f nom-image:tag

# Supprimer toutes les images non utilisées
docker image prune -a
```

### Inspecter une image
```bash
# Voir les détails d'une image
docker inspect nom-image:tag

# Voir l'historique des layers
docker history nom-image:tag

# Voir la taille de chaque layer
docker history nom-image:tag --no-trunc --human
```

## 🚀 Conteneurs Docker

### Exécuter un conteneur
```bash
# Run basique
docker run nom-image:tag

# Run en mode détaché (background)
docker run -d nom-image:tag

# Run avec nom et mapping de port
docker run -d --name mon-conteneur -p 8080:5000 nom-image:tag

# Run avec variables d'environnement
docker run -d -e ENVIRONMENT=Production nom-image:tag

# Run avec volume monté
docker run -d -v /chemin/local:/chemin/conteneur nom-image:tag

# Run avec toutes les options
docker run -d \
  --name mon-conteneur \
  -p 8080:5000 \
  -e ENVIRONMENT=Production \
  -e DEBUG=false \
  -v $(pwd)/data:/app/data \
  --restart unless-stopped \
  nom-image:tag
```

### Lister les conteneurs
```bash
# Conteneurs actifs
docker ps

# Tous les conteneurs (même arrêtés)
docker ps -a

# Afficher les IDs uniquement
docker ps -q

# Format personnalisé
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
```

### Gérer les conteneurs
```bash
# Arrêter un conteneur
docker stop nom-conteneur

# Arrêter tous les conteneurs
docker stop $(docker ps -q)

# Démarrer un conteneur arrêté
docker start nom-conteneur

# Redémarrer un conteneur
docker restart nom-conteneur

# Mettre en pause un conteneur
docker pause nom-conteneur
docker unpause nom-conteneur

# Tuer un conteneur (arrêt forcé)
docker kill nom-conteneur
```

### Supprimer des conteneurs
```bash
# Supprimer un conteneur arrêté
docker rm nom-conteneur

# Forcer la suppression (même s'il tourne)
docker rm -f nom-conteneur

# Supprimer tous les conteneurs arrêtés
docker container prune

# Supprimer tous les conteneurs (même actifs)
docker rm -f $(docker ps -aq)
```

## 🔍 Debug et inspection

### Logs
```bash
# Voir les logs
docker logs nom-conteneur

# Suivre les logs en temps réel
docker logs -f nom-conteneur

# Dernières 100 lignes
docker logs --tail 100 nom-conteneur

# Logs avec timestamps
docker logs -t nom-conteneur

# Logs depuis les 10 dernières minutes
docker logs --since 10m nom-conteneur
```

### Accéder au conteneur
```bash
# Shell interactif (Bash)
docker exec -it nom-conteneur /bin/bash

# Shell interactif (sh pour Alpine)
docker exec -it nom-conteneur /bin/sh

# Exécuter une commande dans le conteneur
docker exec nom-conteneur ls -la /app

# Exécuter en tant qu'utilisateur root
docker exec -u root -it nom-conteneur /bin/bash
```

### Inspection et statistiques
```bash
# Détails complets du conteneur
docker inspect nom-conteneur

# Processus dans le conteneur
docker top nom-conteneur

# Statistiques en temps réel
docker stats nom-conteneur

# Stats de tous les conteneurs
docker stats

# Voir les changements dans le filesystem
docker diff nom-conteneur
```

## 🐳 Docker Compose

### Commandes de base
```bash
# Démarrer les services (en background)
docker-compose up -d

# Démarrer sans mode détaché (voir les logs)
docker-compose up

# Démarrer et forcer la reconstruction
docker-compose up -d --build

# Démarrer un service spécifique
docker-compose up -d webapp

# Arrêter les services
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v

# Arrêter sans supprimer les conteneurs
docker-compose stop
```

### Gestion des services
```bash
# Voir les services actifs
docker-compose ps

# Voir les logs
docker-compose logs

# Suivre les logs en temps réel
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f webapp

# Redémarrer un service
docker-compose restart webapp

# Exécuter une commande dans un service
docker-compose exec webapp /bin/bash
```

### Build et configuration
```bash
# Builder les images
docker-compose build

# Builder sans cache
docker-compose build --no-cache

# Valider le fichier docker-compose.yml
docker-compose config

# Voir la config avec les variables résolues
docker-compose config --resolve-image-digests
```

## 🧹 Nettoyage

### Nettoyage complet
```bash
# Supprimer tout ce qui n'est pas utilisé
docker system prune

# Nettoyage agressif (images, conteneurs, volumes, réseaux)
docker system prune -a --volumes

# Voir l'espace disque utilisé
docker system df

# Détails de l'utilisation
docker system df -v
```

### Nettoyage sélectif
```bash
# Supprimer les conteneurs arrêtés
docker container prune

# Supprimer les images non utilisées
docker image prune

# Supprimer toutes les images non utilisées (même avec tag)
docker image prune -a

# Supprimer les volumes non utilisés
docker volume prune

# Supprimer les réseaux non utilisés
docker network prune
```

## 📊 Réseau Docker

### Gestion des réseaux
```bash
# Lister les réseaux
docker network ls

# Créer un réseau
docker network create mon-reseau

# Inspecter un réseau
docker network inspect mon-reseau

# Connecter un conteneur à un réseau
docker network connect mon-reseau nom-conteneur

# Déconnecter un conteneur d'un réseau
docker network disconnect mon-reseau nom-conteneur

# Supprimer un réseau
docker network rm mon-reseau
```

## 💾 Volumes Docker

### Gestion des volumes
```bash
# Lister les volumes
docker volume ls

# Créer un volume
docker volume create mon-volume

# Inspecter un volume
docker volume inspect mon-volume

# Supprimer un volume
docker volume rm mon-volume

# Supprimer les volumes non utilisés
docker volume prune
```

## 🔄 Registry et images

### Docker Hub / Azure Container Registry
```bash
# Se connecter à Docker Hub
docker login

# Se connecter à Azure Container Registry
docker login nomacr.azurecr.io -u username -p password

# Tagger une image
docker tag mon-image:latest nomacr.azurecr.io/mon-image:v1.0

# Pousser une image
docker push nomacr.azurecr.io/mon-image:v1.0

# Tirer une image
docker pull nomacr.azurecr.io/mon-image:v1.0

# Se déconnecter
docker logout
```

## 🎯 Commandes spécifiques au projet

### Workflow complet local
```bash
# 1. Build de l'image
docker build -t devops-webapp:latest .

# 2. Vérifier l'image
docker images | grep devops-webapp

# 3. Lancer avec Docker Compose
docker-compose up -d

# 4. Vérifier le statut
docker-compose ps

# 5. Voir les logs
docker-compose logs -f

# 6. Tester l'app
curl http://localhost:8080
curl http://localhost:8080/health

# 7. Accéder au shell du conteneur
docker exec -it devops-webapp /bin/bash

# 8. Arrêter proprement
docker-compose down
```

### Quick debug
```bash
# L'app ne démarre pas ?
docker logs devops-webapp

# Port déjà utilisé ?
sudo lsof -i :8080
# Ou changer le port dans docker-compose.yml

# Image trop grosse ?
docker history devops-webapp:latest

# Problème de permissions ?
docker exec -it devops-webapp whoami
# Doit afficher "appuser" pas "root"

# Rebuild complet
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 💡 Astuces et bonnes pratiques

### Aliases utiles (à ajouter dans ~/.bashrc ou ~/.zshrc)
```bash
# Aliases Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm -f'
alias drmi='docker rmi'
alias dlog='docker logs -f'
alias dex='docker exec -it'
alias dprune='docker system prune -a'

# Avec ces aliases :
d build -t mon-image .        # au lieu de docker build
dc up -d                      # au lieu de docker-compose up -d
dlog devops-webapp           # au lieu de docker logs -f devops-webapp
```

### Commandes composées utiles
```bash
# Arrêter et supprimer TOUS les conteneurs
docker stop $(docker ps -aq) && docker rm $(docker ps -aq)

# Supprimer TOUTES les images
docker rmi $(docker images -q)

# Rebuild rapide d'un service Docker Compose
docker-compose build webapp && docker-compose up -d webapp

# Copier un fichier depuis un conteneur
docker cp devops-webapp:/app/logs/app.log ./local-logs/

# Copier un fichier vers un conteneur
docker cp ./local-file.txt devops-webapp:/app/
```

## 📱 Docker sur différentes plateformes

### Windows (PowerShell)
```powershell
# Liste des conteneurs (PowerShell)
docker ps

# Arrêter tous les conteneurs
docker ps -q | ForEach-Object { docker stop $_ }

# Supprimer toutes les images
docker images -q | ForEach-Object { docker rmi -f $_ }
```

### macOS / Linux
```bash
# Mêmes commandes que Linux
# Docker Desktop fournit une interface graphique en plus
```

---

**Ressources complémentaires :**
- [Documentation Docker officielle](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
