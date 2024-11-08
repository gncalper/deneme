pipeline {
    agent any

    stages {
        stage('Clean') {
            steps {
                script {
                    def shortCommit = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
                    echo "Short Commit: ${shortCommit}"

                    def authorName = sh(returnStdout: true, script: "git log -1 --pretty=format:'%an'").trim()
                    echo "GIT_AUTHOR_NAME: ${authorName}"

                    def commitMessage = sh(returnStdout: true, script: "git log -1 --pretty=%B").trim()
                    echo "Commit Message: ${commitMessage}"
                }

             stage('Push') {

                steps {
                    sh  " echo 'Short Commit: ${shortCommit}' "
                }
            }
        }
    }
 }
}