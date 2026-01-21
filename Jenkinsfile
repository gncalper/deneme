pipeline {

    parameters {
        string(name: 'WORKSPACE', defaultValue: '', description: 'Workspace name')
        string(name: 'PROJECT', defaultValue: '', description: 'Project name')
        string(name: 'CONFIG_DIR', defaultValue: '', description: 'Config directory')
        string(name: 'NAMESPACE', defaultValue: '', description: 'Kubernetes namespace')
        booleanParam(name: 'FRONTEND', defaultValue: true, description: 'Build frontend image')
    }

    environment {
        CUSTOMER_CODE_DIR = "/home/generated-apps/temp/platform/${params.WORKSPACE}/${params.PROJECT}"
    }

    stages {

        stage('Prepare Backend Workspace') {
            steps {
                script {
                    echo 'Preparing backend workspace...'
                    sh '''
                        mkdir -p backend-temp
                        cp -R ${CUSTOMER_CODE_DIR}/${CONFIG_DIR}/Backend/* backend-temp/
                    '''
                }
            }
        }

        stage('Prepare Frontend Workspace') {
            when {
                expression { params.FRONTEND }
            }
            steps {
                script {
                    sh '''
                        mkdir -p frontend-temp
                        cp -R ${CUSTOMER_CODE_DIR}/${CONFIG_DIR}/React/ReactProjectTemplate/* frontend-temp/
                    '''
                }
            }
        }

        stage('Build Frontend Image') {
            when {
                expression { params.FRONTEND }
            }
            steps {
                script {
                    def projectLower   = params.PROJECT.toLowerCase()
                    def workspaceLower = params.WORKSPACE.toLowerCase()
                    def namespaceLower = params.NAMESPACE.toLowerCase()

                    dir('frontend-temp') {
                        sh '''
                            yarn build:prod-mode
                            cp -Rf /home/code-generation/platform/resources/dockerFiles/. ./build
                        '''

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
                    def projectLower   = params.PROJECT.toLowerCase()
                    def workspaceLower = params.WORKSPACE.toLowerCase()
                    def namespaceLower = params.NAMESPACE.toLowerCase()

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
                    def projectLower   = params.PROJECT.toLowerCase()
                    def workspaceLower = params.WORKSPACE.toLowerCase()
                    def namespaceLower = params.NAMESPACE.toLowerCase()

                    def images = [
                        "kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-backend:${env.BUILD_NUMBER}"
                    ]

                    if (params.FRONTEND) {
                        images.add(
                            "kuika/${projectLower}-${workspaceLower}-${namespaceLower}.kuika.com-frontend:${env.BUILD_NUMBER}"
                        )
                    }

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
