pipeline {
    agent any

    parameters {
        string(name: 'WORKSPACE')
        string(name: 'PROJECT')
        string(name: 'CONFIG_DIR')
        string(name: 'NAMESPACE')
        booleanParam(name: 'FRONTEND', defaultValue: true)
    }

    stages {
        stage('Generate Jenkinsfile') {
            steps {
                script {
                    def template = readFile 'templates/Jenkinsfile.template'

                    def result = template
                        .replace('${WORKSPACE}', params.WORKSPACE)
                        .replace('${PROJECT}', params.PROJECT)
                        .replace('${CONFIG_DIR}', params.CONFIG_DIR)
                        .replace('${NAMESPACE}', params.NAMESPACE)
                        .replace('${FRONTEND}', params.FRONTEND.toString())

                    writeFile file: 'Jenkinsfile-test', text: result

                    echo 'Jenkinsfile-test generated successfully'
                }
            }
        }
    }
}
