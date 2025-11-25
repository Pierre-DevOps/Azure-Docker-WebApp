Application web Python conteneurisée avec Docker. Projet réalisé dans le cadre de ma formation DevOps.
Description
Application Flask simple qui affiche des informations système du conteneur. Le but est de montrer la maîtrise de Docker et de la conteneurisation.
Technos utilisées

Python 3.11
Flask
Docker
Docker Compose

Structure du projet
.
├── app/
│   ├── app.py
│   └── requirements.txt
├── scripts/
│   └── deploy-to-azure.sh
├── Dockerfile
├── docker-compose.yml
└── README.md
Installation et utilisation
Prérequis

Docker Desktop installé
Git

Lancer le projet en local

Cloner le repo

bashgit clone https://github.com/Pierre-DevOps/Azure-Docker-WebApp.git
cd Azure-Docker-WebApp

Build l'image Docker

bashdocker build -t azure-docker-webapp:latest .

Lancer le conteneur

bashdocker-compose up -d

Accéder à l'application

Ouvrir le navigateur sur http://localhost:8080
Arrêter le conteneur
bashdocker-compose down
Commandes Docker utiles
Voir les conteneurs actifs :
bashdocker ps
Voir les logs :
bashdocker-compose logs -f
Entrer dans le conteneur :
bashdocker exec -it azure-docker-webapp /bin/sh
Points techniques
Dockerfile

Image de base : Python 3.11 Alpine (légère)
Utilisateur non-root pour la sécurité
Health check intégré
Multi-stage pour optimiser la taille

Docker Compose

Port mapping : 8080 (host) -> 5000 (container)
Restart automatique
Limites de ressources définies

Déploiement Azure
Un script de déploiement est fourni dans le dossier scripts/ pour déployer sur Azure Container Instances.
Pour l'utiliser :
bashaz login
cd scripts
./deploy-to-azure.sh
Le script va :

Créer un Resource Group
Créer un Azure Container Registry
Builder et pusher l'image
Déployer sur ACI

Compétences DevOps
Ce projet démontre :

Conteneurisation avec Docker
Automatisation du build
Infrastructure as Code
Déploiement cloud
Bonnes pratiques de sécurité

Auteur
Pierre - Étudiant Bachelor DevOps
Formation : Administrateur Système DevOps (RNCP36061)