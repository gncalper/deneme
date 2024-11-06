pipeline {
    agent any

    stages {
        stage('Clean') {
            steps {
                script {
                    def shortCommit = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
                    echo "Short Commit: ${shortCommit}"

                    echo "GIT_COMMITTER_NAME: ${env.GIT_COMMITTER_NAME}"
                    echo "GIT_AUTHOR_NAME: ${env.GIT_AUTHOR_NAME}"
                    echo "GIT_COMMIT: ${env.GIT_COMMIT}"
                }
            }
        }
    }
}
