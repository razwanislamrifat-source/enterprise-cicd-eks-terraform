pipeline {
    agent { label 'maven' }
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }
    parameters {
        string(name: 'APP_VERSION', defaultValue: '2.0.0', description: 'Application version to build and tag')
        string(name: 'APP_NAME', defaultValue: 'advanced-cicd-app', description: 'Application image name')
        string(name: 'DEPLOY_ENV', defaultValue: 'dev', description: 'Deployment environment (dev/prod)')
    }
    environment {
        APP_NAME = "${params.APP_NAME}"
        APP_VERSION = "${params.APP_VERSION}"
        DEPLOY_ENV = "${params.DEPLOY_ENV}"
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
        stage('Integration Test') {
            when {
                expression { return params.RUN_INTEGRATION_TESTS == 'true' }
            }
            steps {
                sh 'cd app && mvn verify -Pintegration-test'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-token') {
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
        stage('Security Scan') {
            steps {
                sh '''
                    # Install Trivy if not present
                    if ! command -v trivy &> /dev/null; then
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
                    fi
                    trivy image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_IMAGE}
                '''
            }
        }
        stage('SBOM Generation') {
            steps {
                sh '''
                    # Install Syft if not present
                    if ! command -v syft &> /dev/null; then
                        curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
                    fi
                    syft ${DOCKER_IMAGE} -o spdx-json > sbom.spdx.json
                '''
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
                sh '''
                    chmod +x deploy.sh
                    ENVIRONMENT=${DEPLOY_ENV} IMAGE_TAG=${APP_VERSION} ./deploy.sh
                '''
            }
        }
    }
    post {
        always {
            echo "Pipeline completed with status: ${currentBuild.currentResult}"
            echo "Built image: ${env.DOCKER_IMAGE} (version: ${params.APP_VERSION})"
            archiveArtifacts artifacts: 'sbom.spdx.json', allowEmptyArchive: true
        }
    }
}
