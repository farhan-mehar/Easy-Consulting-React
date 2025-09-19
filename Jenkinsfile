pipeline {
    agent any

    environment {
        IMAGE_NAME = 'easy-consulting-react'
        DOCKERHUB_USER = 'muhammadfarhan123'   // Your DockerHub username
        EC2_USER = 'ubuntu'
        EC2_HOST = '3.90.113.90'               // Your EC2 public IP
        APP_PORT = '3000'
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

        stage('Verify Dockerfile') {
            steps {
                sh 'ls -l && cat Dockerfile || echo "Dockerfile not found!"'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $DOCKERHUB_USER/$IMAGE_NAME:latest $WORKSPACE"
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
        success {
            echo '✅ Deployment successful! Your app is running with the latest image.'
        }
        failure {
            echo '❌ Deployment failed. Check logs.'
        }
    }
}
