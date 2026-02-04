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

        stage('Prepare Backend Workspace') {
            steps {
                sh """
                    mkdir -p backend-temp
                    cp -R ${CUSTOMER_CODE_DIR}/${CONFIG_DIR}/Backend/* backend-temp/
                """
            }
        }

        stage('Prepare Frontend Workspace') {
            steps {
                sh """
                    mkdir -p frontend-temp
                    cp -R ${CUSTOMER_CODE_DIR}/${CONFIG_DIR}/React/ReactProjectTemplate/* frontend-temp/
                """
            }
        }

        stage('Build Frontend Image') {

            steps {
                script {
                    def projectLower   = env.PROJECT.toLowerCase()
                    def workspaceLower = env.WORKSPACE.toLowerCase()
                    def namespaceLower = env.NAMESPACE.toLowerCase()

                    dir('frontend-temp') {
                        sh """
                            yarn build:prod-mode
                            cp -Rf /home/code-generation/platform/resources/dockerFiles/. ./build
                        """

                        dir('build') {
                            sh """
                                docker buildx build \
                                --platform linux/amd64 \
                                -t kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-frontend:${env.BUILD_NUMBER} \
                                --load .
                            """
                        }
                    }
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
                        "kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-frontend:${env.BUILD_NUMBER}",
                        "kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-backend:${env.BUILD_NUMBER}"
                    ]

                    sh 'gcloud auth configure-docker europe-west4-docker.pkg.dev --quiet'

                    images.each { image ->
                        sh """
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
