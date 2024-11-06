pipeline {
    agent any

    stages {
        stage('Clean') {
            steps {
                shortCommit = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
                sh "echo ${env.GIT_COMMITTER_NAME}"
                sh "echo ${env.GIT_AUTHOR_NAME}"
                sh "echo ${env.GIT_COMMIT}"
            }
        }
    }
}