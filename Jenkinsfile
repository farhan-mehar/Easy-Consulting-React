pipeline {
    agent any

    environment {
        IMAGE_NAME = 'easy-consulting-react'
        DOCKERHUB_USER = 'muhammadfarhan123'   // Your DockerHub username
        EC2_USER = 'ubuntu'
        EC2_HOST = '3.90.113.90'               // Your EC2 public IP
        APP_PORT = '3000'
        NODE_CACHE = "${JENKINS_HOME}/npm-cache"   // global NPM cache
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/farhan-mehar/Easy-Consulting-React.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Create cache dir if missing
                sh 'mkdir -p $NODE_CACHE'

                // Point npm to cache
                sh 'npm config set cache $NODE_CACHE --global'

                // Install deps
                sh 'npm install'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Verify Dockerfile') {
            steps {
                sh 'ls -l && cat Dockerfile || echo "Dockerfile not found!"'
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("$WORKSPACE") {
                    sh """
                        docker build \
                          --cache-from=$DOCKERHUB_USER/$IMAGE_NAME:latest \
                          -t $DOCKERHUB_USER/$IMAGE_NAME:latest .
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker push $USER/$IMAGE_NAME:latest'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST '
                            docker pull $DOCKERHUB_USER/$IMAGE_NAME:latest &&
                            docker stop $IMAGE_NAME || true &&
                            docker rm $IMAGE_NAME || true &&
                            docker run -d -p $APP_PORT:$APP_PORT --name $IMAGE_NAME $DOCKERHUB_USER/$IMAGE_NAME:latest
                        '
                    """
                }
            }
        }
    }

    post {
        always {
            // ✅ Clean workspace but keep NPM cache
            cleanWs(
                deleteDirs: true,
                notFailBuild: true,
                patterns: [[pattern: 'npm-cache', type: 'EXCLUDE']]
            )
        }
        success {
            echo '✅ Deployment successful! Your app is running with the latest image.'
        }
        failure {
            echo '❌ Deployment failed. Check logs.'
        }
    }
}
