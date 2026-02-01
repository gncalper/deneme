def workspace = WORKSPACE
def project   = PROJECT
def namespace = NAMESPACE

def basePath = "${workspace}/${project}/${namespace}"

// 1️⃣ Workspace
folder(workspace)

// 2️⃣ Project
folder("${workspace}/${project}")

// 3️⃣ Namespace
folder(basePath) {
    description("Namespace: ${namespace}")
}

// 4️⃣ Pipeline job
pipelineJob("${basePath}/deploy") {
    definition {
        cpsScm {
            scm {
                git('https://github.com/gncalper/deneme.git', 'master')
            }
        }
    }
}
