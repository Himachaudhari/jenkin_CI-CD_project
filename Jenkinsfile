pipeline {

    agent { label 'agent' } 

    tools {
        maven 'Maven-3'
        
    }

    environment {
        GIT_REPO = 'https://github.com/Himachaudhari/jenkin_CI-CD_project.git'
        DOCKER_IMAGE = 'himanshuchaudhari/java-cicd-app'
        EC2_HOST = 'ubuntu@13.204.238.92'
        SONARQUBE_SERVER = 'sonarqube-server'
    }

    stages {

        stage('Git Clone') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=java-demo \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_AUTH_TOKEN
                    """
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                sh """
                    docker build -t temp-scan .
                    trivy image --exit-code 0 --severity HIGH,CRITICAL temp-scan
                """
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-cred',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-deploy-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} '
                            docker pull ${DOCKER_IMAGE}:latest &&
                            docker rm -f java-app || true &&
                            docker run -d --name java-app -p 8080:8080 ${DOCKER_IMAGE}:latest
                        '
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished 🎉"
        }
    }
}
