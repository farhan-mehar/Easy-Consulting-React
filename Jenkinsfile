pipeline {
    agent {
        docker {
            image 'node:18-alpine' // ✅ Ensures Node.js and npm are available
        }
    }

    environment {
        IMAGE_NAME = 'easy-consulting-react'
        DOCKERHUB_USER = 'muhammadfarhan123'
        EC2_USER = 'ubuntu'
        EC2_HOST = '98.88.83.236'
        APP_PORT = '3000'
        NODE_CACHE = "${JENKINS_HOME}/npm-cache"
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/farhan-mehar/Easy-Consulting-React.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    echo "📦 Installing dependencies..."
                    mkdir -p $NODE_CACHE
                    npm config set cache $NODE_CACHE
                    npm install --legacy-peer-deps
                '''
            }
        }

        stage('Build React App') {
            steps {
                sh '''
                    echo "🔧 Building React app..."
                    npm run build
                '''
            }
        }

        stage('Verify Dockerfile') {
            steps {
                sh '''
                    echo "🔍 Checking for Dockerfile..."
                    if [ -f Dockerfile ]; then
                        echo "✅ Dockerfile found:"
                        cat Dockerfile
                    else
                        echo "❌ Dockerfile not found!"
                        exit 1
                    fi
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "🐳 Building Docker image..."
                    docker build \
                      --cache-from=$DOCKERHUB_USER/$IMAGE_NAME:latest \
                      -t $DOCKERHUB_USER/$IMAGE_NAME:latest .
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        echo "🚀 Pushing image to DockerHub..."
                        echo $PASS | docker login -u $USER --password-stdin
                        docker push $USER/$IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        echo "📦 Deploying to EC2..."
                        ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST '
                            docker pull $DOCKERHUB_USER/$IMAGE_NAME:latest &&
                            docker stop $IMAGE_NAME || true &&
                            docker rm $IMAGE_NAME || true &&
                            docker run -d -p $APP_PORT:$APP_PORT --name $IMAGE_NAME $DOCKERHUB_USER/$IMAGE_NAME:latest
                        '
                    '''
                }
            }
        }
    }

    post {
        always {
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
