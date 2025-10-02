// Jenkinsfile (Declarative Pipeline)

pipeline {
    // 1. Define the build agent using the required Node 16 Docker image [cite: 78]
    agent {
        docker {
            image 'node:16'
            // Using -u root often prevents permission issues with npm install
            args '-u root' 
        }
    }

    environment {
        // Define the image name using the student's Docker Hub ID
        IMAGE_NAME = "druva007/node-web-app" // Updated with druva007
        // Assign the BUILD_NUMBER as the image tag
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        FULL_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        // Stage 1: Install Dependencies and Run Tests
        stage('Build & Test') {
            steps {
                echo 'Installing dependencies...'
                // Install dependencies [cite: 79]
                sh 'npm install --save' 
                
                echo 'Running unit tests...'
                // Run unit tests [cite: 80]
                // Requires the application's package.json to have a 'test' script
                sh 'npm test' 
            }
        }
        
        // Stage 2: Security Scan [cite: 81]
        stage('Dependency Scan (Snyk)') {
            steps {
                echo 'Installing Snyk CLI and running vulnerability scan...'
                
                // Install Snyk CLI globally in the agent container
                sh 'npm install -g snyk'
                
                // Integrate a dependency vulnerability scanner (Snyk) [cite: 82]
                withCredentials([string(credentialsId: 'SNYK_API_TOKEN', variable: 'SNYK_TOKEN')]) {
                    sh "snyk auth \$SNYK_TOKEN"
                    // The '--fail-on=high' argument ensures the pipeline fails if High/Critical issues are detected [cite: 83]
                    // We use '|| true' to capture the error, but the exit code must still be non-zero for Jenkins to fail.
                    // Snyk CLI exits with non-zero if issues are found, satisfying the requirement[cite: 83].
                    sh 'snyk test --fail-on=high || (echo "Snyk found high/critical issues, failing build." && exit 1)' 
                }
                echo 'Dependency scan complete. Proceeding only if no High/Critical issues found.'
            }
        }

        // Stage 3: Docker Build and Push
        stage('Docker Build & Push') {
            steps {
                script {
                    // 1. Build a Docker image of the app [cite: 80]
                    echo "Building Docker image: ${env.FULL_IMAGE}"
                    // Assumes a Dockerfile exists in the app root
                    sh "docker build -t ${env.FULL_IMAGE} ." 

                    // 2. Push to your registry (DockerHub) [cite: 80]
                    // Use Jenkins username/password credentials for Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "docker login -u \$USER -p \$PASS"
                        sh "docker push ${env.FULL_IMAGE}"
                        sh "docker logout" // Clean up login session
                    }
                    echo "Pushed Docker image: ${env.FULL_IMAGE}"
                }
            }
        }
    }
}
