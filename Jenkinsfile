pipeline {
    agent any

    environment {
        IMAGE_NAME = 'easy-consulting-react'
        EC2_USER = 'ubuntu'
        EC2_HOST = 'your-ec2-public-ip'
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

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        // Optional: Push to DockerHub here

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST '
                            docker stop $IMAGE_NAME || true &&
                            docker rm $IMAGE_NAME || true &&
                            docker run -d -p $APP_PORT:$APP_PORT --name $IMAGE_NAME $IMAGE_NAME
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
