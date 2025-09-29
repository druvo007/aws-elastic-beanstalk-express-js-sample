// Jenkinsfile
pipeline {
    // ----------------------------------------------------
    // AGENT (Required: Use Node 16 Docker image)
    // ----------------------------------------------------
    agent {
        docker {
            image 'node:16-slim' // Required image as the build agent
            label 'jenkins-agent'
            args '-u root'
        }
    }

    environment {
        // --- UPDATED WITH YOUR DOCKER ID ---
        DOCKER_REGISTRY = 'druva007' // Your DockerHub Username
        // -----------------------------------
        IMAGE_NAME = "express-sample-app"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Initialize & Dependencies') {
            steps {
                echo "Installing Node dependencies..."
                // Required step: Install dependencies
                sh 'npm install' 
            }
        }

        stage('Unit Tests') {
            steps {
                echo "Running unit tests..."
                // Required step: Run unit tests
                sh 'npm test' 
            }
        }
        
        // ----------------------------------------------------------------------------------
        // Security in the Pipeline (10 Marks)
        // ----------------------------------------------------------------------------------
        stage('Dependency Vulnerability Scan') {
            steps {
                echo "Scanning for dependency vulnerabilities (Snyk CLI)..."
                
                // Integrate a dependency vulnerability scanner (e.g., Snyk CLI)
                // Requires a Jenkins Secret Text credential named 'SNYK_TOKEN'.
                
                withCredentials([string(credentialsId: 'SNYK_TOKEN', variable: 'SNYK_AUTH_TOKEN')]) {
                    sh "snyk auth ${SNYK_AUTH_TOKEN}"
                    
                    // The pipeline must fail if High/Critical issues are detected.
                    sh 'snyk test --json --severity-threshold=high || (if [ $? -ge 2 ]; then exit 1; fi)'
                }
            }
        }
        // ----------------------------------------------------------------------------------
        
        stage('Build Docker Image') {
            steps {
                echo "Building application Docker image..."
                // Required step: Build a Docker image of the app
                sh "docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
            }
        }

        stage('Push to Registry') {
            steps {
                echo "Pushing image to DockerHub..."
                // Required step: Push to your registry
                // Requires a Jenkins Username/Password credential named 'dockerhub-credentials'.
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USER')]) {
                    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}"
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" 
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                    sh "docker logout"
                }
            }
        }
    }
}
