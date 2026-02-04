pipeline {
    agent any

    environment {
        WORKSPACE      = '@WORKSPACE@'
        PROJECT        = '@PROJECT@'
        CONFIG_DIR     = '@CONFIG_DIR@'
        NAMESPACE      = '@WORKSPACE@-@NAMESPACE@'
        CUSTOMER_CODE_DIR = "/home/generated-apps/temp/platform/@WORKSPACE@/@PROJECT@"
    }

    stages {
        stage('Prepare Temporary Workspace') {
            steps {
                script {
                    echo 'Preparing temporary workspace for build...'
                    sh '''
                        mkdir -p frontend-temp backend-temp
                        cp -R ${CUSTOMER_CODE_DIR}/${CONFIG_DIR}/Backend/* backend-temp/
                    '''
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                script {
                    def projectLower   = env.PROJECT.toLowerCase()
                    def workspaceLower = env.WORKSPACE.toLowerCase()
                    def namespaceLower = env.NAMESPACE.toLowerCase()

                    dir('backend-temp') {
                        sh """
                            docker buildx build \
                            --platform linux/amd64 \
                            -t kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-backend:${env.BUILD_NUMBER} \
                            --load .
                        """
                    }
                }
            }
        }

        stage('Push Images to GCP Artifact Registry') {
            steps {
                script {
                    def projectLower   = env.PROJECT.toLowerCase()
                    def workspaceLower = env.WORKSPACE.toLowerCase()
                    def namespaceLower = env.NAMESPACE.toLowerCase()

                    def images = [
                        "kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-backend:${env.BUILD_NUMBER}"
                    ]

                    images.each { image ->
                        sh """
                            gcloud auth configure-docker europe-west4-docker.pkg.dev
                            docker tag ${image} europe-west4-docker.pkg.dev/kuikacloudservers/docker-repository/${image}
                            docker push europe-west4-docker.pkg.dev/kuikacloudservers/docker-repository/${image}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
