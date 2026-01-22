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
                        .replace('__WORKSPACE__', params.WORKSPACE)
                        .replace('__PROJECT__', params.PROJECT)
                        .replace('__CONFIG_DIR__', params.CONFIG_DIR)
                        .replace('__NAMESPACE__', params.NAMESPACE)
                        .replace('__FRONTEND__', params.FRONTEND.toString())

                    writeFile file: 'Jenkinsfile-test', text: result

                    echo 'Jenkinsfile-test generated successfully'
                }
            }
        }
    }
}
