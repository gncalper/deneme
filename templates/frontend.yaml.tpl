appName: "@WORKSPACE@-@PROJECT@-uat-frontend"
namespace: "@WORKSPACE@-uat"
deploy:
  imageName: "europe-west4-docker.pkg.dev/kuikacloudservers/docker-repository/kuika/@PROJECT@-@WORKSPACE@-@WORKSPACE@-@NAMESPACE@.kuika.com-frontend"
  tag: "1"
labels:
  customer: "@WORKSPACE@"
  env: "@NAMESPACE@"
replicaCount: 1
nodeSelector:
  nodepool: kuika-cloud-uat
tolerations:
  enabled: false
  values:
  - key: "kubernetes.io/arch"
    operator: "Equal"
    value: "amd64"
    effect: "NoSchedule"
service:
  enabled: true
  type: ClusterIP
  port: 80
  targetPort: 3000
envFromSecret: @ENV_FROM_SECRET@
externalSecret:
  enabled: @EXTERNAL_SECRET_ENABLED@
  refreshInterval: 1h0m0s
  target:
    creationPolicy: Owner
  secretStoreRef:
    name: gcp-store
    kind: ClusterSecretStore
  key: @WORKSPACE@-@PROJECT@-front-secret-prod
pvc:
  enabled: false
  storageClassName: "standard-rwo"
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  mountPath: /home/fileserver
hpa:
  enabled: false
  minReplicas: 1
  maxReplicas: 4
  memoryUtilization: 200
  cpuUtilization: 200
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 120
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60

httpRoute:
  enabled: true
  gateway:
    name: kuika-uat-gateway
    namespace: kuika-uat
  hostnames:
  - "@FRONTEND_HOSTNAME@"
  path:
    enabled: @HOST_PATH@
    value: "/@FRONTEND_PATH@/"
resources:
  requests:
    cpu: "20m"
    memory: "20Mi"
  limits:
    cpu: "40m"
    memory: "40Mi"
livenessProbe:
  enabled: true
  path: "/"
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 10
  failureThreshold: 3
readinessProbe:
  enabled: true
  path: "/"
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 10
  failureThreshold: 3
startupProbe:
  enabled: true
  type: tcp
  port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 10
  failureThreshold: 120
