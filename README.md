# 🚀 Enterprise CI/CD Pipeline for React Application on AWS EKS

## Overview

This project demonstrates an enterprise-grade CI/CD pipeline for deploying a React application on Amazon EKS using Jenkins, SonarQube, Trivy, Docker, Amazon ECR, Prometheus, Grafana, Alertmanager, and Blackbox Exporter.

The solution automates the complete software delivery lifecycle:

- Source Code Management using GitHub
- Continuous Integration using Jenkins
- Static Code Analysis using SonarQube
- Security Scanning using Trivy
- Containerization using Docker
- Container Registry using Amazon ECR
- Kubernetes Deployment using Amazon EKS
- Monitoring using Prometheus & Grafana
- Alerting using Alertmanager
- Application Availability Monitoring using Blackbox Exporter

---

# Architecture

```text
Developer
   │
   ▼
GitHub Repository
   │
   ▼
Jenkins Pipeline
   │
   ├── npm install
   ├── Unit Testing
   ├── Trivy Filesystem Scan
   ├── SonarQube Analysis
   ├── Quality Gate Validation
   ├── React Build
   ├── Docker Build
   ├── Trivy Image Scan
   ▼
Amazon ECR
   │
   ▼
Amazon EKS
   │
   ▼
LoadBalancer Service
   │
   ▼
React Application
   │
   ▼
Blackbox Exporter
   │
   ▼
Prometheus
   │
   ▼
Alertmanager
   │
   ▼
Grafana Dashboard
```

---

# Technology Stack

## CI/CD

- GitHub
- Jenkins

## Security & Quality

- SonarQube
- Trivy

## Containerization

- Docker

## Cloud Services

- Amazon ECR
- Amazon EKS

## Monitoring & Alerting

- Prometheus
- Grafana
- Alertmanager
- Blackbox Exporter

---

# Repository

```text
https://github.com/Nalini-0212/react-app.git
```

---

# AWS Infrastructure

| Resource | Name |
|-----------|-----------|
| AWS Region | ap-south-1 |
| EKS Cluster | react-eks-cluster |
| ECR Repository | react-app |
| Namespace | react-app-ns |
| AWS Account | 623740184460 |

---

# Project Structure

```text
react-app/
│
├── Dockerfile
├── package.json
├── Jenkinsfile
│
├── Kubernetes/
│   ├── namespace.yml
│   ├── deployment.yml
│   └── service.yml
│
├── src/
├── public/
└── README.md
```

---

# Jenkins Configuration

## Required Plugins

Install the following Jenkins plugins:

```text
Git

Pipeline

NodeJS

Docker Pipeline

AWS Credentials

Amazon ECR

SonarQube Scanner

Quality Gates

Kubernetes CLI

Workspace Cleanup

Pipeline Utility Steps
```

---

## Global Tool Configuration

Navigate:

```text
Manage Jenkins
→ Global Tool Configuration
```

Configure:

```text
NodeJS
Name: nodejs

JDK
Name: JDK11

SonarScanner
Name: sonar
```

---

## Credentials

Navigate:

```text
Manage Jenkins
→ Credentials
→ Global
```

### AWS Credentials

```text
ID: aws-creds
Type: AWS Credentials
```

---

# SonarQube Configuration

Navigate:

```text
Manage Jenkins
→ System
→ SonarQube Servers
```

Configure:

```text
Name:
sonarserver

Server URL:
http://<SONAR-IP>:9000
```

---

# Docker Configuration

## Dockerfile

```dockerfile
FROM node:18 AS build

WORKDIR /app

COPY package*.json /app/

RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

---

# Kubernetes Deployment

## Namespace

```yaml
apiVersion: v1
kind: Namespace

metadata:
  name: react-app-ns
```

---

## Deployment

```yaml
apiVersion: apps/v1

kind: Deployment

metadata:
  name: react-app-deployment
  namespace: react-app-ns

spec:
  replicas: 2

  selector:
    matchLabels:
      app: react-app

  template:
    metadata:
      labels:
        app: react-app

    spec:
      containers:
      - name: react-app
        image: nginx:latest

        ports:
        - containerPort: 80

        resources:
          requests:
            cpu: "250m"
            memory: "256Mi"

          limits:
            cpu: "500m"
            memory: "500Mi"
```

---

## Service

```yaml
apiVersion: v1

kind: Service

metadata:
  name: react-app-service
  namespace: react-app-ns

spec:
  selector:
    app: react-app

  type: LoadBalancer

  ports:
  - port: 3000
    targetPort: 80
```

---

# Jenkins Pipeline Stages

```text
Checkout Source Code

↓

Install Dependencies

↓

Unit Test

↓

Trivy Filesystem Scan

↓

SonarQube Analysis

↓

Quality Gate

↓

React Build

↓

Docker Build

↓

Trivy Image Scan

↓

Push Image To Amazon ECR

↓

Deploy To Amazon EKS

↓

Update Deployment Image

↓

Verify Deployment
```

---

# Amazon ECR Deployment

Images are pushed to:

```text
623740184460.dkr.ecr.ap-south-1.amazonaws.com/react-app
```

Image Tag:

```text
BUILD_NUMBER
```

Example:

```text
623740184460.dkr.ecr.ap-south-1.amazonaws.com/react-app:25
```

---

# Monitoring Setup

## Create Monitoring Namespace

```bash
kubectl create namespace monitoring
```

---

## Add Prometheus Repository

```bash
helm repo add prometheus-community \
https://prometheus-community.github.io/helm-charts

helm repo update
```

---

## Install Prometheus Stack

```bash
helm install monitoring \
prometheus-community/kube-prometheus-stack \
-n monitoring
```

This installs:

```text
Prometheus

Grafana

AlertManager

Node Exporter

Kube State Metrics
```

Verify:

```bash
kubectl get pods -n monitoring
```

---

# Install Blackbox Exporter

```bash
helm install blackbox \
prometheus-community/prometheus-blackbox-exporter \
-n monitoring
```

Verify:

```bash
kubectl get svc -n monitoring | grep blackbox
```

---

# Expose Grafana

```bash
kubectl patch svc monitoring-grafana \
-n monitoring \
-p '{"spec":{"type":"LoadBalancer"}}'
```

Get URL:

```bash
kubectl get svc monitoring-grafana -n monitoring
```

---

# Grafana Login

## Username

```text
admin
```

## Password

```bash
kubectl get secret monitoring-grafana \
-n monitoring \
-o jsonpath="{.data.admin-password}" \
| base64 -d
```

---

# Expose Prometheus

```bash
kubectl patch svc monitoring-kube-prometheus-prometheus \
-n monitoring \
-p '{"spec":{"type":"LoadBalancer"}}'
```

Check:

```bash
kubectl get svc monitoring-kube-prometheus-prometheus -n monitoring
```

---

# Application Availability Monitoring

## Create Probe

Replace the URL with your application LoadBalancer URL.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: Probe

metadata:
  name: react-app-probe
  namespace: monitoring

spec:

  interval: 30s

  module: http_2xx

  prober:
    url: blackbox-prometheus-blackbox-exporter.monitoring.svc.cluster.local:9115

  targets:
    staticConfig:
      static:
      - http://<LOADBALANCER-DNS>:3000
```

Apply:

```bash
kubectl apply -f react-app-probe.yaml
```

Verify:

```bash
kubectl get probe -n monitoring
```

---

# Prometheus Alert Rules

## Application Down Alert

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule

metadata:
  name: app-alerts
  namespace: monitoring

spec:

  groups:

  - name: application-alerts

    rules:

    - alert: ApplicationDown

      expr: probe_success == 0

      for: 2m

      labels:
        severity: critical

      annotations:
        summary: "Application Down"

        description: "Application is not responding"
```

Apply:

```bash
kubectl apply -f app-alerts.yaml
```

---

## Deployment Availability Alert

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule

metadata:
  name: deployment-alerts
  namespace: monitoring

spec:
  groups:
  - name: deployment-alerts

    rules:

    - alert: ReactDeploymentDown

      expr: kube_deployment_status_replicas_available{deployment="react-app-deployment",namespace="react-app-ns"} < 1

      for: 1m

      labels:
        severity: critical

      annotations:
        summary: "React Deployment Down"

        description: "No available replicas found"
```

Apply:

```bash
kubectl apply -f deployment-alerts.yaml
```

---

# Verification

## Verify Probe

```bash
kubectl get probe -n monitoring
```

Expected:

```text
react-app-probe
```

---

## Verify Status in Prometheus

Navigate:

```text
Prometheus
→ Status
→ Targets
```

Expected:

```text
react-app-probe
UP
```

---

## Test Probe Metric

Execute:

```promql
probe_success
```

Expected:

```text
1
```

Application healthy.

---

# Alert Testing

Scale application down:

```bash
kubectl scale deployment react-app-deployment \
--replicas=0 \
-n react-app-ns
```

Verify:

```bash
kubectl get deployment -n react-app-ns
```

Expected:

```text
READY       0/0

AVAILABLE   0
```

After 1-2 minutes:

```text
ApplicationDown

ReactDeploymentDown
```

Status:

```text
FIRING
```

---

# Restore Deployment

```bash
kubectl scale deployment react-app-deployment \
--replicas=2 \
-n react-app-ns
```

---

# Monitoring Dashboards

Grafana provides visibility into:

- EKS Cluster Health
- Node Health
- CPU Utilization
- Memory Utilization
- Pod Health
- Deployment Status
- Application Availability
- Network Usage

---

# CI/CD Pipeline Flow

```text
GitHub Push
      ↓
Jenkins Trigger
      ↓
npm install
      ↓
Unit Test
      ↓
Trivy File Scan
      ↓
SonarQube Analysis
      ↓
Quality Gate
      ↓
React Build
      ↓
Docker Build
      ↓
Trivy Image Scan
      ↓
Push To Amazon ECR
      ↓
Deploy To Amazon EKS
      ↓
LoadBalancer Service
      ↓
React Application
      ↓
Blackbox Exporter
      ↓
Prometheus
      ↓
Alertmanager
      ↓
Grafana
      ↓
Email / Slack / Teams Alert
```

---

## Author

**Nalini Selvaraj**

Senior Consultant | DevOps | AWS | Kubernetes | CI/CD