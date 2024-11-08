pipeline {
    agent any

    environment {
        AUTHOR_NAME = sh(returnStdout: true, script: "git log -1 --pretty=format:'%an'").trim()
        COMMIT_MESSAGE = sh(returnStdout: true, script: "git log -1 --pretty=%B").trim()
    }

    stages {
        stage('Clean') {
            steps {
                echo "GIT_AUTHOR_NAME: ${AUTHOR_NAME}"
                echo "Commit Message: ${COMMIT_MESSAGE}"
            }
        }
        stage('Push') {
            steps {
                sh "echo 'Commit : ${COMMIT_MESSAGE} by ${AUTHOR_NAME} '"
            }
        }
    }
}
