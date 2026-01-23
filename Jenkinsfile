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
        stage('Generate Jenkinsfile') {
            steps {
                script {
                    def template = readFile 'templates/Jenkinsfile.template'

                    def result = template
                        .replace('_WORKSPACE_', params.WORKSPACE)
                        .replace('_PROJECT_', params.PROJECT)
                        .replace('_CONFIG_DIR_', params.CONFIG_DIR)
                        .replace('_NAMESPACE_', params.NAMESPACE)
                        .replace('_PROJECT-TYPE_', params.PROJECT_TYPE)

                    writeFile file: 'Jenkinsfile-test', text: result

                    echo 'Jenkinsfile-test generated successfully'
                }
            }
        }
    }
}
