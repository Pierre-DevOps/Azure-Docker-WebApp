# ================================
# Étape 1 : Image de base Python légère
# ================================
FROM python:3.11-alpine AS base

# Métadonnées de l'image
LABEL maintainer="pierre@devops-student.com"
LABEL description="Application Flask conteneurisée pour Azure"
LABEL version="1.0"

# Création d'un utilisateur non-root pour la sécurité
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Définition du répertoire de travail
WORKDIR /app

# ================================
# Étape 2 : Installation des dépendances
# ================================
# Copie uniquement requirements.txt d'abord (optimisation du cache Docker)
COPY app/requirements.txt .

# Installation des dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# ================================
# Étape 3 : Copie du code de l'application
# ================================
COPY app/app.py .

# Changement du propriétaire des fichiers vers appuser
RUN chown -R appuser:appgroup /app

# Passage à l'utilisateur non-root
USER appuser

# ================================
# Configuration du conteneur
# ================================
# Port sur lequel l'application écoute
EXPOSE 5000

# Variables d'environnement
ENV FLASK_APP=app.py
ENV PYTHONUNBUFFERED=1
ENV ENVIRONMENT=Production

# Health check (Azure Container Instances peut l'utiliser)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Commande de démarrage de l'application
CMD ["python", "app.py"]
