pipeline {
    agent any

    stages {
        stage('Clean') {
            steps {
                sh "echo ${env.GIT_COMMITTER_NAME}"
                sh "echo ${env.GIT_AUTHOR_NAME}"
            }
        }
    }
}