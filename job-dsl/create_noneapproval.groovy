def workspace = WORKSPACE   // alper
def project   = PROJECT     // genc
def namespace = NAMESPACE   // uat

def rootPath  = "Kuika/Customer-Projects"
def basePath  = "${rootPath}/${workspace}/${project}/${namespace}"

// 0️⃣ Root (mevcutsa sorun yok)
folder("Kuika")
folder(rootPath)

// 1️⃣ Kuika/Customer-Projects/alper
folder("${rootPath}/${workspace}")

// 2️⃣ Kuika/Customer-Projects/alper/genc
folder("${rootPath}/${workspace}/${project}")

// 3️⃣ Kuika/Customer-Projects/alper/genc/uat
folder(basePath) {
    description("Namespace: ${namespace}")
}

// 4️⃣ Job
pipelineJob("${basePath}/deploy") {
    definition {
        cpsScm {
            scm {
                git('https://github.com/gncalper/deneme.git', 'master')
            }
        }
    }
}
