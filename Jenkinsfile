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

                        withCredentials([gitUsernamePassword(credentialsId: 'alper', gitToolName: 'Default')]) {
                            sh """

                                git add .
                                git commit -m "Automated update [ci skip]" || echo "Nothing to commit"
                                git push origin HEAD:master
                            """
                        }
                    }
                }
            }
        }
    }
}
