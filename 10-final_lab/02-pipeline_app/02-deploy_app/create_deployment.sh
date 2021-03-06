#!/bin/bash
echo $USER
echo $PASSWORD
echo $DATABASE
echo $DEV
echo $PROD 
echo $STAGE
cat <<EOF > 10-final_lab/02-pipeline_app/02-deploy_app/k8s/deployment_prod.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-configmap-prod
data:
  USER: $USER
  PASSWORD: $PASSWORD
  DATABASE_URL: mysql://$PROD:3306/$DATABASE?useTimezone=true&serverTimezone=UTC
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-deployment-prod
spec:
  template:
    metadata:
      name: pod-javadb-prod
      labels:
        app: pod-javadb-prod
    spec:
      containers:
        - name: container-pod-javadb-prod
          image: leandsu/crud-java-login:v1.0.0
          env:
            - name: USER
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap-prod
                  key: USER
            - name: PASSWORD
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap-prod
                  key: PASSWORD
            - name: DATABASE_URL
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap-prod
                  key: DATABASE_URL
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: "512Mi" # 512 MB
              cpu: "0.5" # 1 milicors VCPU # este recurso tira do meu cluster este recurso #https://www.datacenters.com/news/what-is-a-vcpu-and-how-do-you-calculate-vcpu-to-cpu https://www.hyve.com/what-is-a-vmware-vcpu/
            limits: # caso a aplicação precise de mais recurso, ele coloca este limite automático
              memory: "800Mi" # 800 MB
              cpu: "1"
  replicas: 2
  selector:
    matchLabels:
      app: pod-javadb-prod
---
apiVersion: v1
kind: Service
metadata:
  name: nodeport-pod-javadb-prod
spec:
  type: NodePort
  ports:
    - port: 8080
      nodePort: 30001 # 30000 ~ 32767
  selector:
    app: pod-javadb-prod
---
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-pod-javadb-prod
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: java-deployment-prod
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
EOF
cat <<EOF > 10-final_lab/02-pipeline_app/02-deploy_app/k8s/deployment_stage.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-configmap-stage
data:
  USER: $USER
  PASSWORD: $PASSWORD
  DATABASE_URL: mysql://$STAGE:3306/$DATABASE?useTimezone=true&serverTimezone=UTC
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-deployment-stage
spec:
  template:
    metadata:
      name: pod-javadb-stage
      labels:
        app: pod-javadb-stage
    spec:
      containers:
        - name: container-pod-javadb-stage
          image: leandsu/crud-java-login:v1.0.0
          env:
            - name: USER
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap-stage
                  key: USER
            - name: PASSWORD
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap-stage
                  key: PASSWORD
            - name: DATABASE_URL
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap-stage
                  key: DATABASE_URL
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: "512Mi" # 512 MB
              cpu: "0.5" # 1 milicors VCPU # este recurso tira do meu cluster este recurso #https://www.datacenters.com/news/what-is-a-vcpu-and-how-do-you-calculate-vcpu-to-cpu https://www.hyve.com/what-is-a-vmware-vcpu/
            limits: # caso a aplicação precise de mais recurso, ele coloca este limite automático
              memory: "800Mi" # 800 MB
              cpu: "1"
  replicas: 2
  selector:
    matchLabels:
      app: pod-javadb-stage
---
apiVersion: v1
kind: Service
metadata:
  name: nodeport-pod-javadb-stage
spec:
  type: NodePort
  ports:
    - port: 8080
      nodePort: 30002 # 30000 ~ 32767
  selector:
    app: pod-javadb-stage
EOF
cat <<EOF > 10-final_lab/02-pipeline_app/02-deploy_app/k8s/deployment_dev.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-configmap-dev
data:
  USER: $USER
  PASSWORD: $PASSWORD
  DATABASE_URL: mysql://$DEV:3306/$DATABASE?useTimezone=true&serverTimezone=UTC
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: java-deployment-dev
spec:
  template:
    metadata:
      name: pod-javadb-dev
      labels:
        app: pod-javadb-dev
    spec:
      containers:
        - name: container-pod-javadb-dev
          image: leandsu/crud-java-login:v1.0.0
          env:
            - name: USER
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap-dev
                  key: USER
            - name: PASSWORD
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap-dev
                  key: PASSWORD
            - name: DATABASE_URL
              valueFrom:
                configMapKeyRef:
                  name: mysql-configmap-dev
                  key: DATABASE_URL
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: "512Mi" # 512 MB
              cpu: "0.5" # 1 milicors VCPU # este recurso tira do meu cluster este recurso #https://www.datacenters.com/news/what-is-a-vcpu-and-how-do-you-calculate-vcpu-to-cpu https://www.hyve.com/what-is-a-vmware-vcpu/
            limits: # caso a aplicação precise de mais recurso, ele coloca este limite automático
              memory: "800Mi" # 800 MB
              cpu: "1"
  replicas: 2
  selector:
    matchLabels:
      app: pod-javadb-dev
---
apiVersion: v1
kind: Service
metadata:
  name: nodeport-pod-javadb-dev
spec:
  type: NodePort
  ports:
    - port: 8080
      nodePort: 30000 # 30000 ~ 32767
  selector:
    app: pod-javadb-dev
EOF