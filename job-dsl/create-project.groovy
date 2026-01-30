import jenkins.model.Jenkins
import com.cloudbees.hudson.plugins.folder.Folder

def workspace = WORKSPACE
def namespace = NAMESPACE
def project   = PROJECT

def basePath = "${workspace}/${namespace}/${project}"

// Workspace
if (!Jenkins.instance.getItem(workspace)) {
    folder(workspace)
}

// Namespace
if (!Jenkins.instance.getItemByFullName("${workspace}/${namespace}")) {
    folder("${workspace}/${namespace}")
}

// Project
folder(basePath) {
    description("Project folder: ${project}")
}

// Örnek pipeline job
pipelineJob("${basePath}/deploy") {
    definition {
        cps {
            script("""
                pipeline {
                    agent any
                    stages {
                        stage('Hello') {
                            steps {
                                echo 'Hello ${project}'
                            }
                        }
                    }
                }
            """)
        }
    }
}
