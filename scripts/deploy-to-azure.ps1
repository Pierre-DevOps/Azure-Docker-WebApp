# ========================================
# Script de déploiement sur Azure Container Instances (PowerShell)
# ========================================
# Ce script automatise le déploiement de notre application Docker sur Azure
# Prérequis : Azure PowerShell installé (Install-Module -Name Az -AllowClobber -Scope CurrentUser)

# Arrêter le script en cas d'erreur
$ErrorActionPreference = "Stop"

# ========================================
# VARIABLES DE CONFIGURATION
# ========================================
# À personnaliser selon ton environnement Azure

$ResourceGroup = "rg-docker-webapp"
$Location = "francecentral"
$ContainerName = "devops-webapp"
$ImageName = "devops-webapp:latest"
$AcrName = "acr$(Get-Random -Maximum 99999)"  # Nom unique pour Azure Container Registry
$DnsName = "devops-webapp-$(Get-Random -Maximum 99999)"  # Nom DNS unique

# ========================================
# FONCTIONS
# ========================================

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-CustomError {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

# ========================================
# DÉPLOIEMENT
# ========================================

Write-Host "=========================================" -ForegroundColor White
Write-Host "Déploiement Docker sur Azure" -ForegroundColor White
Write-Host "=========================================" -ForegroundColor White
Write-Host ""

try {
    # Vérifier la connexion Azure
    Write-Step "Vérification de la connexion Azure..."
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Vous n'êtes pas connecté à Azure. Connexion en cours..." -ForegroundColor Yellow
        Connect-AzAccount
    }
    Write-Success "Connecté à Azure : $($context.Account.Id)"

    # Étape 1 : Créer le groupe de ressources
    Write-Step "Création du groupe de ressources..."
    $rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
    if (-not $rg) {
        New-AzResourceGroup -Name $ResourceGroup -Location $Location | Out-Null
        Write-Success "Groupe de ressources créé : $ResourceGroup"
    } else {
        Write-Success "Groupe de ressources existe déjà : $ResourceGroup"
    }

    # Étape 2 : Créer Azure Container Registry (ACR)
    Write-Step "Création d'Azure Container Registry..."
    $acr = Get-AzContainerRegistry -ResourceGroupName $ResourceGroup -Name $AcrName -ErrorAction SilentlyContinue
    if (-not $acr) {
        New-AzContainerRegistry `
            -ResourceGroupName $ResourceGroup `
            -Name $AcrName `
            -Sku Basic `
            -EnableAdminUser | Out-Null
        Write-Success "ACR créé : $AcrName"
    } else {
        Write-Success "ACR existe déjà : $AcrName"
    }

    # Étape 3 : Build et push de l'image vers ACR (via Azure CLI car plus simple)
    Write-Step "Construction et envoi de l'image Docker vers ACR..."
    Write-Host "Note: Utilisation d'Azure CLI pour le build (plus simple que PowerShell pour cette tâche)" -ForegroundColor Yellow
    
    # Vérifier que Docker est installé localement
    $dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
    if ($dockerInstalled) {
        # Build local puis push vers ACR
        Write-Host "Build de l'image Docker en local..." -ForegroundColor Cyan
        docker build -t "${ImageName}" .
        
        # Login vers ACR
        $acrCreds = Get-AzContainerRegistryCredential -ResourceGroupName $ResourceGroup -Name $AcrName
        $acrServer = "${AcrName}.azurecr.io"
        
        Write-Host "Connexion à ACR..." -ForegroundColor Cyan
        $acrCreds.Password | docker login $acrServer -u $acrCreds.Username --password-stdin
        
        # Tag et push
        Write-Host "Push de l'image vers ACR..." -ForegroundColor Cyan
        docker tag $ImageName "${acrServer}/${ImageName}"
        docker push "${acrServer}/${ImageName}"
        
        Write-Success "Image Docker pushée vers ACR"
    } else {
        # Fallback : utiliser az acr build si Docker n'est pas installé
        Write-Host "Docker non trouvé. Utilisation d'az acr build..." -ForegroundColor Yellow
        az acr build --registry $AcrName --image $ImageName --file Dockerfile .
        Write-Success "Image Docker buildée et pushée via Azure"
    }

    # Étape 4 : Récupérer les credentials ACR
    Write-Step "Récupération des identifiants ACR..."
    $acrCreds = Get-AzContainerRegistryCredential -ResourceGroupName $ResourceGroup -Name $AcrName
    $acrServer = "${AcrName}.azurecr.io"

    # Étape 5 : Déployer sur Azure Container Instances
    Write-Step "Déploiement sur Azure Container Instances..."
    
    # Créer un objet de credentials sécurisé
    $securePassword = ConvertTo-SecureString $acrCreds.Password -AsPlainText -Force
    $acrCredential = New-Object System.Management.Automation.PSCredential($acrCreds.Username, $securePassword)

    # Créer le conteneur
    New-AzContainerGroup `
        -ResourceGroupName $ResourceGroup `
        -Name $ContainerName `
        -Image "${acrServer}/${ImageName}" `
        -RegistryCredential $acrCredential `
        -DnsNameLabel $DnsName `
        -Port 5000 `
        -Cpu 1 `
        -MemoryInGB 1 `
        -OsType Linux `
        -RestartPolicy Always `
        -EnvironmentVariable @{"ENVIRONMENT"="Production"} | Out-Null

    Write-Success "Conteneur déployé sur Azure Container Instances"

    # Étape 6 : Récupérer l'URL publique
    Write-Step "Récupération de l'URL publique..."
    $containerGroup = Get-AzContainerGroup -ResourceGroupName $ResourceGroup -Name $ContainerName
    $fqdn = $containerGroup.IpAddressFqdn

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "✓ DÉPLOIEMENT RÉUSSI !" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "URL de l'application : http://${fqdn}:5000" -ForegroundColor Cyan
    Write-Host "Groupe de ressources : $ResourceGroup" -ForegroundColor White
    Write-Host "Container Registry   : $AcrName" -ForegroundColor White
    Write-Host ""
    Write-Host "Pour voir les logs :" -ForegroundColor Yellow
    Write-Host "  Get-AzContainerInstanceLog -ResourceGroupName $ResourceGroup -ContainerGroupName $ContainerName" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Pour supprimer les ressources :" -ForegroundColor Yellow
    Write-Host "  Remove-AzResourceGroup -Name $ResourceGroup -Force" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-CustomError "Erreur lors du déploiement : $_"
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
