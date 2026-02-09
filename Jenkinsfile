pipeline {

    agent {
        node {
            label 'platform'

        }
    }
    parameters {
        string(name: 'WORKSPACE')
        string(name: 'PROJECT')
        string(name: 'CONFIG_DIR')
        choice( name: 'NAMESPACE',choices: ['uat', 'prod'], description: 'Is your project for testing or production?')
        choice( name: 'PROJECT_TYPE',choices: ['web', 'mobile','workflow'], description: 'Is your project for mobil, workflow or web?')
        booleanParam(name: 'HOST_PATH',defaultValue: false,description: 'Host path kullanılacak mı?')
        string(name: 'BACKEND_HOSTNAME', description: 'Uygulamanın backend veya workflow url ini girin')
        string(name: 'BACKEND_PATH', defaultValue: '', description: 'Path (Host path checkbox işaretli ise uygulamanın backend pathi var ise değer giriniz yoksa boş bırakınız)' )
        string(name: 'FRONTEND_HOSTNAME', description: 'Uygulamanın frontend url ini girin')
        string(name: 'FRONTEND_PATH', defaultValue: '', description: 'Path (Host path checkbox işaretli ise uygulamanın frontend pathi var ise değer giriniz yoksa boş bırakınız)' )
        string(name: 'DB_NAME', description: 'Db name giriniz')
        }

    stages {

        stage('Validate Parameters') {
            steps {
                script {
                    if (!params.WORKSPACE?.trim()) {
                        error "WORKSPACE zorunludur ve boş olamaz"
                    }

                    if (!params.PROJECT?.trim()) {
                        error "PROJECT zorunludur ve boş olamaz"
                    }

                    if (!params.CONFIG_DIR?.trim()) {
                        error "CONFIG_DIR zorunludur ve boş olamaz"
                    }

                    if (!params.BACKEND_HOSTNAME?.trim()) {
                        error "BACKEND_HOSTNAME zorunludur ve boş olamaz"
                    }

                    if (params.PROJECT_TYPE == 'web') {
                        if (!params.FRONTEND_HOSTNAME?.trim()) {
                            error "PROJECT_TYPE=web iken FRONTEND_HOSTNAME zorunludur"
                        }
                    }

                    if (!params.HOST_PATH && (params.BACKEND_PATH?.trim() || params.FRONTEND_PATH?.trim())) {
                        error "HOST_PATH checkbox işaretliyken BACKEND_PATH / FRONTEND_PATH girilmemelidir"
                    }

                    if (params.HOST_PATH && !params.BACKEND_PATH?.trim()) {
                        error "HOST_PATH checkbox işaretliyken BACKEND_PATH zorunludur"
                    }

                    if (params.HOST_PATH && params.PROJECT_TYPE == 'web' && !params.FRONTEND_PATH?.trim()) {
                        error "HOST_PATH checkbox işaretliyken FRONTEND_PATH zorunludur "
                    }

                }
            }
        }

        stage('Init Vars') {
            steps {
                script {
                    env.WORKSPACE_LC = params.WORKSPACE.toLowerCase()
                    env.NAMESPACE_LC = params.NAMESPACE.toLowerCase()

                    env.TARGET_DIR  = "customers-argo/${params.WORKSPACE}/${params.PROJECT}/${params.WORKSPACE}-${params.NAMESPACE}"
                    env.JENKINS_DIR = "jenkins/customer/${params.WORKSPACE}/${params.PROJECT}/${params.NAMESPACE}"

                    env.GATEWAY_DIR = "gateway-argo/${env.WORKSPACE_LC}-gateway/${env.WORKSPACE_LC}-${env.NAMESPACE_LC}"

                    echo "TARGET_DIR : ${env.TARGET_DIR}"
                    echo "GATEWAY_DIR: ${env.GATEWAY_DIR}"
                    echo "JENKINS_DIR: ${env.JENKINS_DIR}"
                }
            }
        }

        stage('Validate Target Directory') {
            steps {
                script {
                    env.JENKINS_DIR = "jenkins/customer/${params.WORKSPACE}/${params.PROJECT}/${params.NAMESPACE}"
                    env.TARGET_DIR = "customers-argo/${params.WORKSPACE}/${params.PROJECT}/${params.WORKSPACE}-${params.NAMESPACE}"

                    if (fileExists(env.JENKINS_DIR)) {
                        error "❌ ${env.JENKINS_DIR} zaten mevcut. Build durduruldu."
                    }
                    if (fileExists(env.TARGET_DIR)) {
                        error "❌ ${env.TARGET_DIR} zaten mevcut. Build durduruldu."
                    }
                }
            }
        }

        stage('Check NodePool Exists') {
            when {
                    expression { params.NAMESPACE == 'prod' }
                }
            steps {
                script {
                    def workspaceLower = params.WORKSPACE.toLowerCase()

                    def exists = sh(
                        script: """
                          gcloud container node-pools list \
                            --cluster kuika-cloud-cluster \
                            --region europe-west4 \
                            --format="value(name)" | grep -w ${params.WORKSPACE} || true
                        """,
                        returnStdout: true
                    ).trim()

                    if (exists) {
                        env.NODEPOOL_EXISTS = "true"
                        echo "Nodepool ${params.WORKSPACE} zaten mevcut. Create stage atlanacak."
                    } else {
                        env.NODEPOOL_EXISTS = "false"
                        echo "Nodepool bulunamadı. Create edilecek."
                    }
                }
            }
        }

        stage('Create NodePool') {
            when {
                allOf {
                    expression { params.NAMESPACE == 'prod' }
                    expression { env.NODEPOOL_EXISTS == "false" }
                }
            }
            steps {
                script {
                    def workspaceLower = params.WORKSPACE.toLowerCase()

                    sh """
                      gcloud container node-pools create ${params.WORKSPACE} \
                        --cluster kuika-cloud-cluster \
                        --region europe-west4 \
                        --machine-type e2-custom-2-4096 \
                        --disk-type pd-standard \
                        --disk-size 30 \
                        --enable-autoscaling \
                        --min-nodes 0 \
                        --max-nodes 6 \
                        --num-nodes 0 \
                        --node-labels=nodepool=${params.WORKSPACE} \
                        --labels=nodepool=${params.WORKSPACE} \
                        --pod-ipv4-range=k8s-prod-pod-ip-range
                    """
                }
            }
        }


        stage('Create GCP Secrets') {
            steps {
                script {
                    def workspace = params.WORKSPACE.toLowerCase()
                    def project   = params.PROJECT.toLowerCase()

                    withCredentials([
                        string(credentialsId: 'db-user', variable: 'DB_USER'),
                        string(credentialsId: 'db-password', variable: 'DB_PASSWORD')
                    ])
                    {
                      withEnv([
                          "WORKSPACE_LOWER=${workspace}",
                          "PROJECT_LOWER=${project}"
                      ])

                    {
                    sh '''
                    set -e

                    echo " WORKSPACE    : $WORKSPACE"
                    echo " PROJECT      : $PROJECT"
                    echo " PROJECT_TYPE : $PROJECT_TYPE"
                    echo " NAMESPACE    : $NAMESPACE"
                    echo "=============================="

                    # 1️⃣ HANGİ COMPONENT’LER OLUŞACAK?
                    # -------------------------------------------------
                    case "$PROJECT_TYPE:$NAMESPACE" in
                      web:prod)
                        COMPONENTS="frontend backend"
                        ;;
                      web:uat)
                        COMPONENTS="backend"
                        ;;
                      workflow:uat|workflow:prod)
                        COMPONENTS="workflow"
                        ;;
                      mobile:uat|mobile:prod)
                        COMPONENTS="mobile"
                        ;;
                      *)
                        echo "❌ Unsupported PROJECT_TYPE / NAMESPACE combination"
                        exit 1
                        ;;
                    esac

                    echo "Components to create: $COMPONENTS"

                    # -------------------------------------------------
                    # 2️⃣ COMPONENT LOOP
                    # -------------------------------------------------
                    for COMPONENT in $COMPONENTS; do
                        SECRET_NAME="${WORKSPACE_LOWER}-${PROJECT_LOWER}-${COMPONENT}-secret-${NAMESPACE}"
                        TEMPLATE="cred-templates/${COMPONENT}-${NAMESPACE}.json.tpl"
                        OUTPUT_FILE="secret-${COMPONENT}.json"

                        echo "----------------------------------------"
                        echo "Component   : $COMPONENT"
                        echo "Secret Name : $SECRET_NAME"
                        echo "Template    : $TEMPLATE"
                        echo "----------------------------------------"

                        # Secret varsa hata ver
                        if gcloud secrets describe "$SECRET_NAME" >/dev/null 2>&1; then
                            echo "❌ Secret already exists: $SECRET_NAME"
                            exit 1
                        fi

                        # Template yoksa hata ver
                        if [ ! -f "$TEMPLATE" ]; then
                            echo "❌ Template file not found: $TEMPLATE"
                            exit 1
                        fi

                        # JSON oluştur
                        sed \
                          -e "s|\\\${DB_USER}|$DB_USER|g" \
                          -e "s|\\\${DB_PASSWORD}|$DB_PASSWORD|g" \
                          -e "s|\\\${BACKEND_HOSTNAME}|$BACKEND_HOSTNAME|g" \
                          -e "s|\\\${BACKEND_PATH}|$BACKEND_PATH|g" \
                          -e "s|\\\${DB_NAME}|$DB_NAME|g" \
                          "$TEMPLATE" > "$OUTPUT_FILE"

                        # Secret oluştur
                        gcloud secrets create "$SECRET_NAME" \
                          --replication-policy=automatic

                        # Secret version ekle
                        gcloud secrets versions add "$SECRET_NAME" \
                          --data-file="$OUTPUT_FILE"

                        echo "✅ Secret created successfully: $SECRET_NAME"
                    done
                    '''
                        }
                    }
                }
            }
        }

        stage('Generate Jenkinsfile') {
            steps {
                script {

                    def templateFile = ""

                    if (params.PROJECT_TYPE == 'web') {
                        templateFile = 'templates/Jenkinsfile-frontend.tpl'
                    } else if (params.PROJECT_TYPE in ['mobile']) {
                        templateFile = 'templates/Jenkinsfile-backend.tpl'
                    } else if (params.PROJECT_TYPE in ['workflow']) {
                      templateFile = 'templates/Jenkinsfile-workflow.tpl'
                    }

                    echo "Using template: ${templateFile}"

                    def template = readFile templateFile

                    def result = template
                        .replace('@WORKSPACE@', params.WORKSPACE)
                        .replace('@PROJECT@', params.PROJECT)
                        .replace('@CONFIG_DIR@', params.CONFIG_DIR)
                        .replace('@NAMESPACE@', params.NAMESPACE)

                    writeFile file: 'Jenkinsfile', text: result

                    echo 'Jenkinsfile generated successfully'
                }
            }
        }

        stage('Generate Helm Values') {
            steps {
                script {
                    def httpPathValue = params.HOST_PATH ? "true" : "false"
                    def workspace = params.WORKSPACE.toLowerCase()
                    def project   = params.PROJECT.toLowerCase()
                    def backendType = (params.PROJECT_TYPE == 'workflow') ? "workflow" : "backend"
                    def nodepool = "kuika-cloud-uat"
                    def gatewayName = "kuika-uat-gateway"
                    def gatewayNamespace = "kuika-uat"
                    def hpaEnabled = (namespace == 'prod') ? "true" : "false"

                    def backendReqCpu   = "50m"
                    def backendReqMem   = "250Mi"
                    def backendLimitCpu = "200m"
                    def backendLimitMem = "750Mi"

                    def frontendReqCpu   = "20m"
                    def frontendReqMem   = "20Mi"
                    def frontendLimitCpu = "40m"
                    def frontendLimitMem = "40Mi"

                    def workflowReqCpu   = "100m"
                    def workflowReqMem   = "512Mi"
                    def workflowLimitCpu = "200m"
                    def workflowLimitMem = "750Mi"

                    if (namespace == 'prod') {
                        nodepool = workspace
                        gatewayName = "${workspace}-prod-gateway"
                        gatewayNamespace = "${workspace}-prod"

                        backendReqCpu   = "200m"
                        backendReqMem   = "500Mi"
                        backendLimitCpu = "300m"
                        backendLimitMem = "500Mi"

                        frontendReqCpu   = "40m"
                        frontendReqMem   = "40Mi"
                        frontendLimitCpu = "40m"
                        frontendLimitMem = "40Mi"

                        workflowReqCpu   = "200m"
                        workflowReqMem   = "600Mi"
                        workflowLimitCpu = "300m"
                        workflowLimitMem = "600Mi"
                    }

                    def workflowTpl = readFile 'templates/workflow.yaml.tpl'

                    def workflowValues = workflowTpl
                        .replace('@WORKSPACE@', workspace)
                        .replace('@PROJECT@', project)
                        .replace('@NAMESPACE@', params.NAMESPACE)
                        .replace('@HOST_PATH@', httpPathValue)
                        .replace('@BACKEND_TYPE@', backendType)
                        .replace('@BACKEND_HOSTNAME@', params.BACKEND_HOSTNAME)
                        .replace('@BACKEND_PATH@', params.BACKEND_PATH)
                        .replace('@NODEPOOL@', nodepool)
                        .replace('@GATEWAY_NAME@', gatewayName)
                        .replace('@GATEWAY_NAMESPACE@', gatewayNamespace)
                        .replace('@HPA_ENABLED@', hpaEnabled)
                        .replace('@WORKFLOW_REQ_CPU@', frontendReqCpu)
                        .replace('@WORKFLOW_REQ_MEM@', frontendReqMem)
                        .replace('@WORKFLOW_LIMIT_CPU@', frontendLimitCpu)
                        .replace('@WORKFLOW_LIMIT_MEM@', frontendLimitMem)

                    writeFile file: 'values-workflow.yaml', text: workflowValues
                    echo "workflow values.yaml generated"

                    if (params.PROJECT_TYPE == 'mobile') {
                        backendType = "backend"
                    }

                        def backendTpl = readFile 'templates/backend.yaml.tpl'

                        def backendValues = backendTpl
                            .replace('@WORKSPACE@', workspace)
                            .replace('@PROJECT@', project)
                            .replace('@NAMESPACE@', params.NAMESPACE)
                            .replace('@HOST_PATH@', httpPathValue)
                            .replace('@BACKEND_TYPE@', backendType)
                            .replace('@BACKEND_HOSTNAME@', params.BACKEND_HOSTNAME)
                            .replace('@BACKEND_PATH@', params.BACKEND_PATH)
                            .replace('@NODEPOOL@', nodepool)
                            .replace('@GATEWAY_NAME@', gatewayName)
                            .replace('@GATEWAY_NAMESPACE@', gatewayNamespace)
                            .replace('@HPA_ENABLED@', hpaEnabled)
                            .replace('@BACKEND_REQ_CPU@', backendReqCpu)
                            .replace('@BACKEND_REQ_MEM@', backendReqMem)
                            .replace('@BACKEND_LIMIT_CPU@', backendLimitCpu)
                            .replace('@BACKEND_LIMIT_MEM@', backendLimitMem)

                        writeFile file: 'values-backend.yaml', text: backendValues
                        echo "backend values.yaml generated"

                    if (params.PROJECT_TYPE == 'web') {

                        def frontendEnvFromSecret = "false"
                        def frontendExternalSecret = "false"

                        if (params.NAMESPACE == 'prod') {
                            frontendEnvFromSecret = "true"
                            frontendExternalSecret = "true"
                        }

                        def frontendTpl = readFile 'templates/frontend.yaml.tpl'

                        def frontendValues = frontendTpl
                            .replace('@WORKSPACE@', workspace)
                            .replace('@PROJECT@', project)
                            .replace('@NAMESPACE@', params.NAMESPACE)
                            .replace('@HOST_PATH@', httpPathValue)
                            .replace('@FRONTEND_HOSTNAME@', params.FRONTEND_HOSTNAME)
                            .replace('@FRONTEND_PATH@', params.FRONTEND_PATH)
                            .replace('@ENV_FROM_SECRET@', frontendEnvFromSecret)
                            .replace('@EXTERNAL_SECRET_ENABLED@', frontendExternalSecret)
                            .replace('@NODEPOOL@', nodepool)
                            .replace('@GATEWAY_NAME@', gatewayName)
                            .replace('@GATEWAY_NAMESPACE@', gatewayNamespace)
                            .replace('@HPA_ENABLED@', hpaEnabled)
                            .replace('@FRONTEND_REQ_CPU@', frontendReqCpu)
                            .replace('@FRONTEND_REQ_MEM@', frontendReqMem)
                            .replace('@FRONTEND_LIMIT_CPU@', frontendLimitCpu)
                            .replace('@FRONTEND_LIMIT_MEM@', frontendLimitMem)

                        writeFile file: 'values-frontend.yaml', text: frontendValues
                        echo "Frontend values.yaml generated"
                    } else {
                        echo "PROJECT_TYPE web değil → frontend values.yaml oluşturulmadı"
                    }
                }
            }
        }

        stage('Commit All Changes') {
            steps {
                script {

                    sh "git checkout master"

                    if (params.NAMESPACE.toLowerCase() == 'prod' &&
                        !fileExists(env.GATEWAY_DIR)) {

                        echo "Gateway yok oluşturuluyor"

                        def workspace = params.WORKSPACE.toLowerCase()
                        def gatewayTpl = readFile 'templates/gateway.yaml.tpl'

                        def gatewayValues = gatewayTpl
                            .replace('@WORKSPACE@', workspace)

                        writeFile file: 'values-gateway.yaml', text: gatewayValues

                        sh """
                            mkdir -p ${env.GATEWAY_DIR}
                            mv values-gateway.yaml ${env.GATEWAY_DIR}/values.yaml
                            git add ${env.GATEWAY_DIR}/values.yaml
                        """

                    } else {
                        echo "Gateway mevcut veya namespace prod değil "
                    }


                    if (params.PROJECT_TYPE == 'web') {

                        sh """
                            mkdir -p ${env.TARGET_DIR}/backend ${env.TARGET_DIR}/frontend
                            mv values-backend.yaml  ${env.TARGET_DIR}/backend/values.yaml
                            mv values-frontend.yaml ${env.TARGET_DIR}/frontend/values.yaml
                            git add ${env.TARGET_DIR}
                        """

                    } else if (params.PROJECT_TYPE == 'workflow') {

                          sh """
                              mkdir -p ${env.TARGET_DIR}/workflow
                              mv values-workflow.yaml ${env.TARGET_DIR}/workflow/values.yaml
                              git add ${env.TARGET_DIR}/workflow/values.yaml
                          """
                      }

                    else {

                        sh """
                            mkdir -p ${env.TARGET_DIR}/backend
                            mv values-backend.yaml ${env.TARGET_DIR}/backend/values.yaml
                            git add ${env.TARGET_DIR}
                        """
                    }

                    sh """
                            mkdir -p ${env.JENKINS_DIR}
                            mv Jenkinsfile ${env.JENKINS_DIR}/Jenkinsfile
                            git add ${env.JENKINS_DIR}
                       """

                    sh """
                        git commit -m "Jenkinsfile and values yaml added for ${params.PROJECT} and if doesn\'t exist create gateway "

                        if ! git push origin master; then
                            echo "Push başarısız → pull --rebase"
                            git pull --rebase origin master
                            git push origin master
                        fi
                    """
                }
            }
        }

        stage('Run Job DSL') {
            steps {
                jobDsl(
                    targets: 'job-dsl/create_noneapproval.groovy',
                    additionalParameters: [
                        WORKSPACE: params.WORKSPACE,
                        PROJECT  : params.PROJECT,
                        NAMESPACE: params.NAMESPACE
                    ]
                )
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}