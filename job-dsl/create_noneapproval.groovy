def workspace = WORKSPACE   // alper
def project   = PROJECT     // genc
def namespace = NAMESPACE   // uat

def basePath = "${workspace}/${project}/${namespace}"

// 1️⃣ alper
folder(workspace)

// 2️⃣ alper/genc
folder("${workspace}/${project}")

// 3️⃣ alper/genc/uat
folder(basePath) {
    description("Namespace: ${namespace}")
}

// 4️⃣ alper/genc/uat/deploy
pipelineJob("${basePath}/deploy") {
    definition {
        cpsScm {
            scm {
                git('https://github.com/gncalper/deneme.git', 'master')
            }
        }
    }
}
