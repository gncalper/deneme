def workspace = WORKSPACE
def project   = PROJECT
def namespace = NAMESPACE

def basePath = "${workspace}/${namespace}/${project}"

// Workspace folder
folder(workspace)

// Namespace folder
folder("${workspace}/${namespace}")

// Eğer project folder varsa Job DSL otomatik fail eder
folder(basePath) {
    description("Project: ${project}")
}

// Pipeline job
pipelineJob("${basePath}/deploy") {
    definition {
        cpsScm {
            scm {
                git('https://github.com/gncalper/deneme.git', 'master')
            }
        }
    }
}
