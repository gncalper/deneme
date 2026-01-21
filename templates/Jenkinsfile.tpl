pipeline {
    agent {
        node {
            label 'platform'
        }
    }

    environment {
        WORKSPACE = "{{WORKSPACE}}"
        PROJECT   = "{{PROJECT}}"
        CONFIG_DIR = "{{CONFIG_DIR}}"
        CUSTOMER_CODE_DIR = "/home/generated-apps/temp/platform/${WORKSPACE}/${PROJECT}"
        NAMESPACE = "{{NAMESPACE}}"
    }

    stages {

        stage('Prepare Temporary Workspace') {
            steps {
                script {
                    echo 'Preparing temporary workspace for build...'
                    sh '''
                        mkdir -p backend-temp
                        cp -R ${CUSTOMER_CODE_DIR}/${CONFIG_DIR}/Backend/* backend-temp/
                    '''
                }
            }
        }

        {{#FRONTEND}}
        stage('Prepare Frontend Workspace') {
            steps {
                script {
                    sh '''
                        mkdir -p frontend-temp
                        cp -R ${CUSTOMER_CODE_DIR}/${CONFIG_DIR}/React/ReactProjectTemplate/* frontend-temp/
                    '''
                }
            }
        }
        {{/FRONTEND}}

        {{#FRONTEND}}
        stage('Build Frontend Image') {
            steps {
                script {
                    def projectLower = PROJECT.toLowerCase()
                    def workspaceLower = WORKSPACE.toLowerCase()
                    def namespaceLower = NAMESPACE.toLowerCase()

                    dir('frontend-temp') {
                        sh '''
                            yarn build:prod-mode
                            cp -Rf /home/code-generation/platform/resources/dockerFiles/. ./build
                        '''

                        dir('build') {
                            sh "docker buildx build --platform linux/amd64 -t kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-frontend:${env.BUILD_NUMBER} --load ."
                        }
                    }
                }
            }
        }
        {{/FRONTEND}}

        stage('Build Backend Image') {
            steps {
                script {
                    def projectLower = PROJECT.toLowerCase()
                    def workspaceLower = WORKSPACE.toLowerCase()
                    def namespaceLower = NAMESPACE.toLowerCase()

                    dir('backend-temp') {
                        sh "docker buildx build --platform linux/amd64 -t kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-backend:${env.BUILD_NUMBER} --load ."
                    }
                }
            }
        }

        stage('Push Images to GCP Artifact Registry') {
            steps {
                script {
                    def projectLower = PROJECT.toLowerCase()
                    def workspaceLower = WORKSPACE.toLowerCase()
                    def namespaceLower = NAMESPACE.toLowerCase()

                    def images = [
                        "kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-backend:${env.BUILD_NUMBER}"
                    ]

                    {{#FRONTEND}}
                    images.add("kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-frontend:${env.BUILD_NUMBER}")
                    {{/FRONTEND}}

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
