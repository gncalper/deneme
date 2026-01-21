pipeline {
    agent any

    parameters {
        string(name: 'WORKSPACE', description: 'Workspace adı')
        string(name: 'PROJECT', description: 'Project adı ')
        string(name: 'CONFIG_DIR', description: 'Config klasörü ')
        string(name: 'NAMESPACE', description: 'Kubernetes namespace ')
        choice(
            name: 'HAS_FRONTEND',
            choices: ['true', 'false'],
            description: 'Frontend var mı?'
        )
    }

    stages {
        stage('Generate Jenkinsfile') {
            steps {
                script {
                    def tpl = readFile('templates/Jenkinsfile.tpl')

                    def result = tpl
                        .replace('{{WORKSPACE}}', params.WORKSPACE)
                        .replace('{{PROJECT}}', params.PROJECT)
                        .replace('{{CONFIG_DIR}}', params.CONFIG_DIR)
                        .replace('{{NAMESPACE}}', params.NAMESPACE)

                    if (params.HAS_FRONTEND) {
                        result = result
                            .replace('{{#FRONTEND}}', '')
                            .replace('{{/FRONTEND}}', '')
                    } else {
                        result = result.replaceAll(
                            /(?s)\{\{#FRONTEND\}\}.*?\{\{\/FRONTEND\}\}/,
                            ''
                        )
                    }

                    writeFile file: 'Jenkinsfile.generated', text: result
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'Jenkinsfile.generated'
        }
    }
}
