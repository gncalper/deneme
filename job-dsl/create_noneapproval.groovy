def workspace = WORKSPACE
def project   = PROJECT
def namespace = NAMESPACE

def basePath = "${workspace}/${project}/${namespace}"

// Workspace folder
folder(workspace)

// Namespace folder
folder("${workspace}/${namespace}")

// Eğer  folder varsa Job DSL otomatik fail eder
folder(basePath) {
    description("Namespace: ${namespace}")
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
