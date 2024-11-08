pipeline {
    agent any

    environment {
        SHORT_COMMIT = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
        AUTHOR_NAME = sh(returnStdout: true, script: "git log -1 --pretty=format:'%an'").trim()
        COMMIT_MESSAGE = sh(returnStdout: true, script: "git log -1 --pretty=%B").trim()
    }

    stages {
        stage('Clean') {
            steps {
                echo "Short Commit: ${SHORT_COMMIT}"
                echo "GIT_AUTHOR_NAME: ${AUTHOR_NAME}"
                echo "Commit Message: ${COMMIT_MESSAGE}"
            }
        }
        stage('Push') {
            steps {
                sh "echo 'Short Commit: ${SHORT_COMMIT}'"
            }
        }
    }
}
