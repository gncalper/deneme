pipeline {
    agent any

    stages {
        stage('Prepare') {
            steps {
                echo "Preparing build..."
            }
        }

        stage('Git Push') {
            steps {
                lock(resource: 'git-push-lock') {
                    script {
                        echo "Lock acquired — waiting 30 seconds before push..."
                        sleep 30

                        echo "Performing git push safely."
                        sh '''
                            git config --global user.name "${GIT_USERNAME}"
                            git config --global user.password "${GIT_PASSWORD}"
                            git add .
                            git commit -m "Automated update [ci skip]" || echo "Nothing to commit"
                            git push origin HEAD:main
                        '''
                    }
                }
            }
        }
    }
}
