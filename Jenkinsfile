pipeline {
    agent any

    stages {
        stage('Clean') {
            steps {
                script {
                    // Kısa commit hash değerini al
                    def shortCommit = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
                    echo "Short Commit: ${shortCommit}"

                    // Commit yapan kişinin adını al
                    def authorName = sh(returnStdout: true, script: "git log -1 --pretty=format:'%an'").trim()
                    echo "GIT_AUTHOR_NAME: ${authorName}"

                    // Commit ID'sini al
                    def commitId = sh(returnStdout: true, script: "git rev-parse HEAD").trim()
                    echo "GIT_COMMIT: ${commitId}"
                }
            }
        }
    }
}
