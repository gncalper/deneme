pipeline {
    agent any

    environment {
        AUTHOR_NAME = sh(returnStdout: true, script: "git log -1 --pretty=format:'%an'").trim()
        COMMIT_MESSAGE = sh(returnStdout: true, script: "git log -1 --pretty=%B").trim()
        MERGE_COMMIT_MESSAGE = sh(returnStdout: true, script: "git log -1 --merges --pretty=%B").trim()
    }
    parameters {
         gitParameter branchFilter: '^(develop|release|feature-release*)$',
         defaultValue: 'develop',
         name: 'BRANCH',
         type: 'PT_BRANCH',
         description: 'choose your branch',
         selectedValue: 'DEFAULT',
         sortMode: 'DESCENDING_SMART'

      }

    stages {
        stage('Clean') {
            steps {
                echo "GIT_AUTHOR_NAME: ${AUTHOR_NAME}"
                echo "Commit Message: ${COMMIT_MESSAGE}"
                echo "Merge Message: ${MERGE_COMMIT_MESSAGE}"
            }
        }
        stage('Push') {
            steps {
                sh "echo 'Commit : ${COMMIT_MESSAGE} by ${AUTHOR_NAME} '"
            }
        }
    }
}
