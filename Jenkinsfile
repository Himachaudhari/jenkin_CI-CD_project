@Library('my-shared-library') _

pipeline {

    agent { label 'agent' } 

    tools {
        maven 'Maven-3'
    }

    environment {
        GIT_REPO = 'https://github.com/Himachaudhari/jenkin_CI-CD_project.git'
        DOCKER_IMAGE = 'himanshuchaudhari02/java-cicd-app'
        EC2_HOST = 'ubuntu@13.204.238.92'
        SONARQUBE_SERVER = 'sonarqube-server'
    }

    stages {

        stage('Git Clone') {
            steps {
                git branch: 'prod', url: "${GIT_REPO}"
            }
        }

        stage('Maven Build') {
            steps {
                mavenBuild()
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sonarScan("java-demo", SONARQUBE_SERVER)
            }
        }

        stage('Trivy Scan') {
            steps {
                trivyScan()
            }
        }

        stage('Docker Build & Push') {
            steps {
                dockerBuildPush(DOCKER_IMAGE)
            }
        }

        stage('Deploy to EC2') {
            steps {
                deployToEC2(EC2_HOST, DOCKER_IMAGE)
            }
        }
    }

    post {
        always {
            echo "Pipeline finished 🎉"
        }
    }
}
