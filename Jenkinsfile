pipeline {
    agent any

    environment {
        IMAGE_NAME    = "ghcr.io/jbaramakram/shelfsense"
        IMAGE_TAG     = "${BUILD_NUMBER}"
        REGISTRY_CRED = "github-registry"
        APP_SERVER    = "13.60.251.87"
        SSH_KEY       = "shelfsense-ssh-key"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Cloning repository..."
                checkout scm
            }
        }

        stage('Test') {
            steps {
                echo "Running tests..."
                sh '''
                    cd app
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt --quiet
                    pip install pytest --quiet
                    python3 -m pytest tests/ -v
                '''
            }
        }

        stage('Build Image') {
            steps {
                echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker build -f docker/Dockerfile -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage('Push to Registry') {
            steps {
                echo "Pushing image to GitHub Container Registry..."
                withCredentials([usernamePassword(
                    credentialsId: "${REGISTRY_CRED}",
                    usernameVariable: 'REG_USER',
                    passwordVariable: 'REG_PASS'
                )]) {
                    sh """
                        echo \$REG_PASS | docker login ghcr.io -u \$REG_USER --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy to AWS') {
            steps {
                echo "Deploying to EC2 via Ansible..."
                withCredentials([sshUserPrivateKey(
                    credentialsId: "${SSH_KEY}",
                    keyFileVariable: 'SSH_KEY_FILE'
                )]) {
                    sh """
                        cd infra/ansible
                        ANSIBLE_HOST_KEY_CHECKING=False \
                        ansible-playbook -i inventory.ini deploy-app.yml \
                          --private-key \$SSH_KEY_FILE \
                          -e "app_image=${IMAGE_NAME}:${IMAGE_TAG}"
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                echo "Verifying deployment on AWS..."
                sh """
                    sleep 10
                    curl -sf http://${APP_SERVER}:5000/health || exit 1
                    echo "App is healthy on AWS"
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline SUCCESS — Build #${BUILD_NUMBER} deployed to http://${APP_SERVER}:5000"
        }
        failure {
            echo "Pipeline FAILED — Check the logs above"
        }
        always {
            sh "docker image prune -f"
        }
    }
}
