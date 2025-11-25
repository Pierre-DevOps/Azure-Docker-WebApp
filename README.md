# Azure-Docker-WebApp

Application web Python conteneurisée avec Docker. Projet réalisé dans le cadre de ma formation DevOps.

## Description

Application Flask simple qui affiche des informations système du conteneur. Le but est de montrer la maîtrise de Docker et de la conteneurisation.

## Technos utilisées

- Python 3.11
- Flask
- Docker
- Docker Compose

## Structure du projet

```
.
├── app/
│   ├── app.py
│   └── requirements.txt
├── scripts/
│   └── deploy-to-azure.sh
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Installation et utilisation

### Prérequis

- Docker Desktop installé
- Git

### Lancer le projet en local

1. Cloner le repo

```bash
git clone https://github.com/Pierre-DevOps/Azure-Docker-WebApp.git
cd Azure-Docker-WebApp
```

2. Build l'image Docker

```bash
docker build -t azure-docker-webapp:latest .
```

3. Lancer le conteneur

```bash
docker-compose up -d
```

4. Accéder à l'application

Ouvrir le navigateur sur http://localhost:8080

### Arrêter le conteneur

```bash
docker-compose down
```

## Commandes Docker utiles

Voir les conteneurs actifs :
```bash
docker ps
```

Voir les logs :
```bash
docker-compose logs -f
```

Entrer dans le conteneur :
```bash
docker exec -it azure-docker-webapp /bin/sh
```

## Points techniques

### Dockerfile

- Image de base : Python 3.11 Alpine (légère)
- Utilisateur non-root pour la sécurité
- Health check intégré
- Multi-stage pour optimiser la taille

### Docker Compose

- Port mapping : 8080 (host) -> 5000 (container)
- Restart automatique
- Limites de ressources définies

## Déploiement Azure

Un script de déploiement est fourni dans le dossier scripts/ pour déployer sur Azure Container Instances.

Pour l'utiliser :

```bash
az login
cd scripts
./deploy-to-azure.sh
```

Le script va :
- Créer un Resource Group
- Créer un Azure Container Registry
- Builder et pusher l'image
- Déployer sur ACI

## Compétences DevOps

Ce projet démontre :
- Conteneurisation avec Docker
- Automatisation du build
- Infrastructure as Code
- Déploiement cloud
- Bonnes pratiques de sécurité

## Auteur

Pierre - Étudiant Bachelor DevOps
Formation : Administrateur Système DevOps (RNCP36061)

## Notes

Projet réalisé dans le cadre du CCP1 (Automatiser le déploiement d'une infrastructure dans le cloud).
