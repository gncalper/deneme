pipeline {
    agent any

    stages {
        stage('Git Push') {
            steps {
                lock(resource: 'git-push-lock') {
                    script {
                        echo "Lock acquired — waiting 10 seconds before push..."
                        sleep 10

                        echo "Performing git push safely."

                        withCredentials([gitUsernamePassword(credentialsId: 'alper',gitToolName: 'git-tool')]) {
                            sh """
                                git config --global user.name "${GIT_USERNAME}"
                                git config --global user.password "${GIT_PASSWORD}"
                                git add .
                                git commit -m "Automated update [ci skip]" || echo "Nothing to commit"
                                git push
                            """
                        }
                    }
                }
            }
        }
    }
}
