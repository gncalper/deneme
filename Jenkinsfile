pipeline {
    agent any

    parameters {
        string(name: 'WORKSPACE')
        string(name: 'PROJECT')
        string(name: 'CONFIG_DIR')
        choice( name: 'NAMESPACE',choices: ['uat', 'prod'], description: 'Is your project for testing or production?')
        choice( name: 'PROJECT_TYPE',choices: ['web', 'mobile','workflow'], description: 'Is your project for mobil, workflow or web?')
        }

    stages {

        stage('Validate Parameters') {
            steps {
                script {

                    if (!params.WORKSPACE?.trim()) {
                        error "WORKSPACE zorunludur ve boş olamaz"
                    }

                    if (!params.PROJECT?.trim()) {
                        error "PROJECT zorunludur ve boş olamaz"
                    }

                    if (!params.CONFIG_DIR?.trim()) {
                        error "CONFIG_DIR zorunludur ve boş olamaz"
                    }
                }
            }
        }

        stage('Validate Target Directory') {
            steps {
                script {
                    env.TARGET_DIR = "jenkins/customer/${params.WORKSPACE}/${params.PROJECT}/${params.NAMESPACE}"

                    if (fileExists(env.TARGET_DIR)) {
                        error "❌ ${env.TARGET_DIR} zaten mevcut. Build durduruldu."
                    }
                }
            }
        }


        stage('Generate Jenkinsfile') {
            steps {
                script {

                    def templateFile = ""

                    if (params.PROJECT_TYPE == 'web') {
                        templateFile = 'templates/Jenkinsfile-frontend.tpl'
                    } else if (params.PROJECT_TYPE in ['mobile', 'workflow']) {
                        templateFile = 'templates/Jenkinsfile-backend.tpl'
                    }

                    echo "Using template: ${templateFile}"

                    def template = readFile templateFile

                    def result = template
                        .replace('@WORKSPACE@', params.WORKSPACE)
                        .replace('@PROJECT@', params.PROJECT)
                        .replace('@CONFIG_DIR@', params.CONFIG_DIR)
                        .replace('@NAMESPACE@', params.NAMESPACE)

                    writeFile file: 'Jenkinsfile', text: result

                    echo 'Jenkinsfile generated successfully'
                }
            }
        }


        stage('Commit Jenkinsfile to Repo') {
            steps {
                script {
                    sh """
                        git checkout master
                        mkdir -p ${env.TARGET_DIR}
                        mv Jenkinsfile ${env.TARGET_DIR}/Jenkinsfile

                        git add ${env.TARGET_DIR}/Jenkinsfile
                        git commit -m "Add Jenkinsfile for ${params.WORKSPACE}/${params.PROJECT}/${params.NAMESPACE}"
                        git push origin master
                    """
                }
            }
        }

        stage('Run Job DSL') {
            steps {
                jobDsl(
                    targets: 'job-dsl/create_noneapproval.groovy',
                    additionalParameters: [
                        WORKSPACE: params.WORKSPACE,
                        PROJECT  : params.PROJECT,
                        NAMESPACE: params.NAMESPACE
                    ]
                )
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}