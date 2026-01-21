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
                    // Template dosyasını oku
                    def template = readFile 'templates/Jenkinsfile.template'

                    // Parametreleri replace et
                    def result = template
                        .replace('${WORKSPACE}', params.WORKSPACE)
                        .replace('${PROJECT}', params.PROJECT)
                        .replace('${CONFIG_DIR}', params.CONFIG_DIR)
                        .replace('${NAMESPACE}', params.NAMESPACE)

                    // Jenkinsfile olarak yaz
                    writeFile file: 'Jenkinsfile-test', text: result

                    echo 'Jenkinsfile successfully generated'
                }
            }
        }
    }
}
