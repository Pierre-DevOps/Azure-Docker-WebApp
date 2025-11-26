pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'zibluno/azure-docker-webapp'
        DOCKER_TAG = 'latest'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Recuperation du code depuis GitHub...'
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Construction de l image Docker...'
                bat 'docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Test de l image...'
                bat 'docker run --rm %DOCKER_IMAGE%:%DOCKER_TAG% python --version'
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Push vers Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat 'docker login -u %DOCKER_USER% -p %DOCKER_PASS%'
                    bat 'docker push %DOCKER_IMAGE%:%DOCKER_TAG%'
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline termine avec succes!'
        }
        failure {
            echo 'Pipeline en echec!'
        }
    }
}
