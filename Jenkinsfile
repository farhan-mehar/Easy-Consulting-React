pipeline {
    agent any

    environment {
        IMAGE_NAME = 'easy-consulting-react'
        DOCKERHUB_USER = 'your-dockerhub-username'       // Replace with your DockerHub username
        EC2_USER = 'ubuntu'
        EC2_HOST = 'your-ec2-public-ip'                  // Replace with your EC2 public IP
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

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker tag $IMAGE_NAME $USER/$IMAGE_NAME'
                    sh 'docker push $USER/$IMAGE_NAME'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST '
                            docker pull $DOCKERHUB_USER/$IMAGE_NAME &&
                            docker stop $IMAGE_NAME || true &&
                            docker rm $IMAGE_NAME || true &&
                            docker run -d -p $APP_PORT:$APP_PORT --name $IMAGE_NAME $DOCKERHUB_USER/$IMAGE_NAME
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
