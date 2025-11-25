# 📚 Concepts Docker - Guide pour le DP

Ce document explique les concepts Docker utilisés dans le projet et pourquoi ils sont importants pour le CCP1.

## 🎯 Qu'est-ce que Docker ?

Docker est une plateforme de **conteneurisation** qui permet d'empaqueter une application avec toutes ses dépendances dans un conteneur isolé.

**Avantages :**
- ✅ **Portabilité** : "Ça marche sur ma machine" → "Ça marche partout"
- ✅ **Isolation** : Chaque conteneur est isolé des autres
- ✅ **Légèreté** : Plus léger qu'une machine virtuelle
- ✅ **Rapidité** : Démarrage en quelques secondes
- ✅ **Reproductibilité** : Environnement identique en dev et prod

## 🏗️ Concepts clés

### 1. Image Docker

Une **image** est un modèle immuable qui contient :
- Le système d'exploitation de base (ex: Ubuntu, Alpine)
- L'application
- Les dépendances
- La configuration

**Analogie :** C'est comme un "moule à gâteau" - on peut créer plusieurs gâteaux (conteneurs) à partir du même moule (image).

```bash
# Voir les images locales
docker images

# Notre image dans ce projet
devops-webapp:latest
```

### 2. Conteneur Docker

Un **conteneur** est une instance en cours d'exécution d'une image.

**Analogie :** Si l'image est un programme (.exe), le conteneur est le programme en cours d'exécution.

```bash
# Voir les conteneurs actifs
docker ps

# Voir tous les conteneurs (même arrêtés)
docker ps -a
```

### 3. Dockerfile

Le **Dockerfile** est un fichier texte qui contient les instructions pour construire une image.

**Instructions principales :**

| Instruction | Description | Exemple |
|------------|-------------|---------|
| `FROM` | Image de base | `FROM python:3.11-slim` |
| `WORKDIR` | Répertoire de travail | `WORKDIR /app` |
| `COPY` | Copier des fichiers | `COPY app/ .` |
| `RUN` | Exécuter une commande (build) | `RUN pip install -r requirements.txt` |
| `CMD` | Commande par défaut (runtime) | `CMD ["python", "app.py"]` |
| `EXPOSE` | Port exposé (documentation) | `EXPOSE 5000` |
| `ENV` | Variable d'environnement | `ENV ENVIRONMENT=Production` |

### 4. Docker Compose

**Docker Compose** est un outil pour orchestrer plusieurs conteneurs.

**Pourquoi l'utiliser ?**
- Simplifie le démarrage de l'application
- Une seule commande au lieu de plusieurs
- Configuration centralisée dans `docker-compose.yml`

```bash
# Au lieu de :
docker build -t devops-webapp .
docker run -d -p 8080:5000 --name webapp devops-webapp

# On fait simplement :
docker-compose up -d
```

## 🔧 Optimisations implémentées

### 1. Multi-stage Build

**Concept :** Utiliser plusieurs étapes de build pour créer une image finale optimisée.

**Avantages :**
- Image finale plus petite (150 MB au lieu de 1 GB)
- Meilleure sécurité (pas d'outils de build en prod)
- Plus rapide à déployer

**Dans notre Dockerfile :**
```dockerfile
# STAGE 1 : Installation des dépendances (image complète)
FROM python:3.11-slim as builder
RUN pip install --user -r requirements.txt

# STAGE 2 : Image finale (uniquement ce qui est nécessaire)
FROM python:3.11-slim
COPY --from=builder /root/.local /home/appuser/.local
```

### 2. Utilisateur non-root

**Problème :** Par défaut, les conteneurs s'exécutent en tant que `root`.

**Risque :** Si un attaquant compromet le conteneur, il a les privilèges root.

**Solution :** Créer et utiliser un utilisateur non-privilégié.

```dockerfile
RUN useradd -m -u 1000 appuser
USER appuser
```

### 3. .dockerignore

**Concept :** Comme `.gitignore` mais pour Docker.

**But :** Exclure les fichiers inutiles du contexte de build :
- Réduit la taille du build
- Accélère le build
- Améliore la sécurité

```
.git/
README.md
*.log
__pycache__/
```

### 4. Cache des layers

Docker met en cache chaque instruction du Dockerfile.

**Bonne pratique :** Copier `requirements.txt` avant le code source.

```dockerfile
# ✅ BIEN : requirements.txt est copié en premier
COPY app/requirements.txt .
RUN pip install -r requirements.txt
COPY app/ .

# ❌ MAUVAIS : requirements.txt est copié avec le code
COPY app/ .
RUN pip install -r requirements.txt
```

**Pourquoi ?** Si tu modifies `app.py`, seul le dernier `COPY` est refait. L'installation des packages reste en cache.

### 5. Healthcheck

**Concept :** Vérifier automatiquement que l'application fonctionne.

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"
```

**Utilité :**
- Azure peut redémarrer automatiquement si l'app ne répond plus
- Docker Compose peut attendre que l'app soit "healthy"

## 📊 Commandes Docker essentielles

### Build et Run

```bash
# Construire une image
docker build -t nom-image:tag .

# Exécuter un conteneur
docker run -d -p 8080:5000 nom-image:tag

# Options utiles :
# -d : mode détaché (background)
# -p : mapping de ports (hote:conteneur)
# --name : nom du conteneur
# -e : variable d'environnement
# --rm : supprimer le conteneur à l'arrêt
```

### Inspection et Debug

```bash
# Voir les logs
docker logs nom-conteneur
docker logs -f nom-conteneur  # Mode "follow" (temps réel)

# Accéder au shell du conteneur
docker exec -it nom-conteneur /bin/bash

# Inspecter le conteneur
docker inspect nom-conteneur

# Voir les processus
docker top nom-conteneur

# Statistiques en temps réel
docker stats nom-conteneur
```

### Gestion

```bash
# Arrêter un conteneur
docker stop nom-conteneur

# Démarrer un conteneur arrêté
docker start nom-conteneur

# Supprimer un conteneur
docker rm nom-conteneur

# Supprimer une image
docker rmi nom-image

# Nettoyage complet
docker system prune -a
```

## 🎓 Lien avec les compétences CCP1

### Compétence 1 : Automatisation du déploiement

**Ce qu'on fait :**
- Dockerfile pour automatiser la création de l'environnement
- docker-compose.yml pour automatiser le démarrage
- Script deploy-to-azure.sh pour automatiser le déploiement

**Bénéfice :** Plus besoin d'installer manuellement Python, les dépendances, etc.

### Compétence 2 : Mise en production sur infrastructure cloud

**Ce qu'on fait :**
- Déploiement sur Azure Container Instances
- Utilisation d'Azure Container Registry
- Configuration des healthchecks

**Bénéfice :** Application accessible publiquement, scalable, résiliente.

### Compétence 3 : Sécurisation de l'infrastructure

**Ce qu'on fait :**
- Utilisateur non-root dans le conteneur
- Image minimale (surface d'attaque réduite)
- Secrets gérés par Azure (pas dans le code)

## 💡 Concepts à retenir pour le DP

1. **Conteneurisation ≠ Virtualisation**
   - VM : Émule un ordinateur complet
   - Conteneur : Isole uniquement l'application

2. **Immutabilité des images**
   - Une fois créée, une image ne change pas
   - Pour modifier, on rebuild une nouvelle image

3. **Portabilité**
   - Le même conteneur tourne en local, en dev, en prod
   - "Build once, run anywhere"

4. **Infrastructure as Code**
   - Le Dockerfile est du code versionné dans Git
   - Permet de reproduire l'environnement à l'identique

5. **Orchestration**
   - Docker Compose : pour le développement local
   - Kubernetes : pour la production à grande échelle (AKS)

## 📸 Captures d'écran recommandées pour le DP

1. **Build de l'image**
   ```bash
   docker build -t devops-webapp:latest .
   ```

2. **Conteneur en cours d'exécution**
   ```bash
   docker ps
   ```

3. **Application dans le navigateur**
   - http://localhost:8080

4. **Logs du conteneur**
   ```bash
   docker logs devops-webapp
   ```

5. **Déploiement Azure**
   - Sortie du script deploy-to-azure.sh
   - Application accessible sur Azure

6. **Azure Portal**
   - Container Instances
   - Container Registry

## 🔗 Ressources complémentaires

- [Documentation Docker officielle](https://docs.docker.com/)
- [Docker Cheat Sheet](https://docs.docker.com/get-started/docker_cheatsheet.pdf)
- [Best Practices Dockerfile](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

---

**Ce document est un support pour ton Dossier Professionnel. Il t'aidera à expliquer tes choix techniques lors de la soutenance.**
