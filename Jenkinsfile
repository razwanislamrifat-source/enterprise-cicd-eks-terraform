def dockerImage
pipeline {
    agent any
    parameters {
        string(name: 'APP_VERSION', defaultValue: '2.0.0', description: 'Application version to build and tag')
        string(name: 'APP_NAME', defaultValue: 'advanced-cicd-app', description: 'Application image name')
    }
    environment {
        APP_NAME = "${params.APP_NAME}"
        APP_VERSION = "${params.APP_VERSION}"
        SONARQUBE_URL = 'http://sonarqube:9000'
        DOCKER_IMAGE = "razwanff/${APP_NAME}:${APP_VERSION}"
    }
    stages {
        stage('Build') {
            steps {
                sh 'cd app && mvn clean package'
            }
        }
        stage('Unit Test') {
            steps {
                sh 'cd app && mvn test'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh 'cd app && mvn sonar:sonar -Dsonar.projectKey=advanced-cicd-razwan -Dsonar.projectName=Advanced-CICD-Pipeline'
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    script {
                        def qualityGate = waitForQualityGate()
                        if (qualityGate.status != 'OK') {
                            error "Pipeline aborted: Quality Gate status is ${qualityGate.status}"
                        }
                    }
                }
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    dockerImage = docker.build("${env.DOCKER_IMAGE}")
                }
            }
        }
        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'chmod +x deploy.sh && ./deploy.sh'
            }
        }
    }
    post {
        always {
            echo "Pipeline completed with status: ${currentBuild.currentResult}"
            echo "Built image: ${env.DOCKER_IMAGE} (version: ${params.APP_VERSION})"
        }
    }
}
