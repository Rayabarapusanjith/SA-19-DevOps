pipeline {
    agent { label 'slave1' }

	environment {	
		DOCKERHUB_CREDENTIALS=credentials('sadockerlogin')
	}
	
    stages {
        stage('SCM_Checkout') {
            steps {
               echo "Perform SCM Checkout"
			   git 'https://github.com/Rayabarapusanjith/SA-19-DevOps/BankingApp.git'			   
            }
        }
        stage('Application Build') {
            steps {
                echo "Perform Application Build"
				sh 'mvn clean package'
            }
        }
        stage('Build Docker Image') {
            steps {
				sh 'docker version'
				sh "docker build -t loksaieta/bankapp-eta-app:${BUILD_NUMBER} ."
				sh 'docker image list'
				sh "docker tag loksaieta/bankapp-eta-app:${BUILD_NUMBER} loksaieta/bankapp-eta-app:latest"
            }
        }
		stage('Login2DockerHub') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}
		stage('Publish_to_Docker_Registry') {
			steps {
				sh "docker push loksaieta/bankapp-eta-app:latest"
			}
		}
        stage('Deploy to Kubernetes Cluster') {
            steps {
                script{
                   sshPublisher(publishers: [sshPublisherDesc(configName: 'SA-Jan09-KMaster', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'kubectl apply -f kubernetesdeploy.yaml', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '.', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '*.yaml')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                }
            }
        }
    }
}
