pipeline {
    agent any
    environment {
        gcpCreds = 'gcp_credentials'
        dockerCreds = credentials('dockerhub_login')
        registry = "${dockerCreds_USR}/vatcal"
        registryCredentials = "dockerhub_login"
        dockerImage = ""
        TF_VAR_gcp_project = "qwiklabs-gcp-00-c0c6d8a3cd5b"
        TF_VAR_docker_registry = "${registry}"
    }
    stages {
        stage('Run Tests') {
            steps {
              sh 'npm install'
              sh 'npm test'
            }
        }
        stage('Build Image') {
            steps {
                script {
                  dockerImage = docker.build(registry)
                }
            }
        }
        stage('Push Image') {
            steps {
                script {
                    docker.withRegistry("", registryCredentials) {
                        dockerImage.push("${env.BUILD_NUMBER}")
                        dockerImage.push("latest")
                    }
                }
            }
        }
        stage('Clean Up') {
            steps {
              sh "docker image prune --all --force --filter 'until=48h'"
            }
        }
        stage('Provision Server') {
            steps {
                script {
                    withCredentials([file(credentialsId: gcpCreds, variable:'GCP_CREDENTIALS')]) {
                        sh '''
                        export GOOGLE_APPLICATION_CREDENTIALS=$GCP_CREDENTIALS
                        terraform init
                        terrascan scan -i terraform -t gcp -f main.tf
                        terrascan scan -i terraform -t gcp -p . -f main.tf
                        terraform apply -auto-approve
                        '''
                    }
                }
            }
        }
    }
}