# Kubernetes Cheat Sheet for Java/Spring Boot

## 🌐 Cluster Management

| Command                                | Description            |
|----------------------------------------|------------------------|
| `kubectl cluster-info`                 | Show cluster details   |
| `kubectl config use-context <context>` | Switch clusters        |
| `kubectl get nodes`                    | List nodes with status |

## 📦 Pods & Deployments

| Command                                    | Description          | Java-Specific Use            |
|--------------------------------------------|----------------------|------------------------------|
| `kubectl get pods`                         | List pods            | Check Spring Boot app status |
| `kubectl describe pod <pod>`               | Inspect pod details  | Debug startup crashes        |
| `kubectl logs -f <pod>`                    | Stream logs          | View Spring Boot logs        |
| `kubectl exec -it <pod> -- sh`             | Enter container      | Debug running app            |
| `kubectl apply -f deployment.yaml`         | Apply deployment     | Deploy Spring Boot app       |
| `kubectl rollout status deployment/<name>` | Check rollout        | Verify zero-downtime deploy  |
| `kubectl rollout undo deployment/<name>`   | Rollback             | Revert broken release        |
| `kubectl delete deploy <name>`             | Remove deployment    |                              |
| `kubectl delete svc <name>`                | Delete service       |                              |
| `kubectl delete -f .`                      | Delete all in folder |                              |

## 🔌 Services & Networking

| Command                                     | Description        | Microservices Use           |
|---------------------------------------------|--------------------|-----------------------------|
| `kubectl get svc`                           | List services      | Check service exposure      |
| `kubectl port-forward svc/<name> 8080:8080` | Port forwarding    | Local access to Spring Boot |
| `kubectl get ingress`                       | List ingress rules | Check API gateway routes    |

## 📊 Scaling & Health

| Command                                                            | Description        |
|--------------------------------------------------------------------|--------------------|
| `kubectl scale deploy <name> --replicas=3`                         | Scale horizontally |
| `kubectl autoscale deploy <name> --min=2 --max=5 --cpu-percent=80` | Auto-scale         |
| `kubectl get hpa`                                                  | Check autoscaling  |

## 🛠️ ConfigMaps & Secrets (for Spring Boot)

| Command                                                               | Description      |
|-----------------------------------------------------------------------|------------------|
| `kubectl create configmap app-config --from-file=application.yml`     | Create ConfigMap |
| `kubectl create secret generic db-secret --from-literal=DB_PASS=1234` | Create Secret    |
| `kubectl get configmap,secret`                                        | View configs     |

## 💾 Persistent Volumes (For Databases)

| Command                           | Description   |
|-----------------------------------|---------------|
| `kubectl get pv,pvc`              | Check storage |
| `kubectl apply -f mysql-pvc.yaml` | Claim storage |

## 🚨 Debugging Java Apps

```bash
# Get OOMKilled reasons
kubectl describe pod <pod> | grep -A 10 "State"

# Enable remote debugging
kubectl port-forward <pod> 5005:5005
```

# Kubernetes Terminology Guide for Backend Developers

## Core Kubernetes Concepts

### ** API Server**

The main interface for communicating with the Kubernetes cluster. Manages the cluster state and enforces the desired
state. It is Central access point that handles all kubernetes requests.

### **Cluster**

A set of machines (nodes) that run containerized applications managed by Kubernetes. In AWS, this is typically an EKS (
Elastic Kubernetes Service) cluster. Group of machines running kubernetes to host applications.

### **Node**

A worker machine in Kubernetes that runs your applications. Can be physical or virtual machines (EC2 instances in AWS).

### **Pod**

The smallest deployable unit in Kubernetes. Usually contains one container (your Spring Boot app), but can contain
multiple tightly coupled containers that share storage and network.

### **Container**

Your packaged Spring Boot application with its runtime environment, created from a Docker image.

### **Namespace**

Virtual clusters within a physical cluster. Used to organize resources and provide isolation (e.g., `dev`, `staging`,
`prod` namespaces).

## Workload Resources

### **Deployment**

Manages the desired state of your application. Defines how many replicas of your Spring Boot microservice should run and
handles rolling updates.

```yaml
# Example: Spring Boot microservice deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    spec:
      containers:
        - name: user-service
          image: your-registry/user-service:1.0.0
          ports:
            - containerPort: 8080
```

### **ReplicaSet**

Ensures a specified number of pod replicas are running at any time. Usually managed automatically by Deployments.

### **StatefulSet**

Used for stateful applications that require stable network identities and persistent storage (databases, message queues
like Kafka).

### **DaemonSet**

Ensures a copy of a pod runs on all or specific nodes (useful for logging agents, monitoring tools).

### **Job**

Runs pods to completion for batch processing or one-time tasks.

### **CronJob**

Runs jobs on a schedule (like cron jobs in Linux).

## Networking

### **Service**

An abstract way to expose your Spring Boot application. Provides stable networking for your microservices.

**Types:**

- **ClusterIP**: Internal access only (default)
- **NodePort**: Exposes service on each node's IP
- **LoadBalancer**: Creates cloud load balancer (ALB/NLB in AWS)
- **ExternalName**: Maps service to external DNS

### **Ingress**

Manages external access to services, typically HTTP/HTTPS. Acts as a reverse proxy and load balancer (often uses AWS ALB
or NGINX).

### **Ingress Controller**

The actual component that implements Ingress rules (AWS Load Balancer Controller, NGINX, Traefik).

### **Endpoint**

The actual IP addresses and ports of pods backing a service.

### **Network Policy**

Rules that control traffic flow between pods (firewall rules at the Kubernetes level).

## Storage

### **Volume**

Storage that persists beyond pod lifecycle. Various types:

- **emptyDir**: Temporary storage
- **hostPath**: Node's filesystem
- **persistentVolumeClaim**: Dynamic storage provisioning

### **Persistent Volume (PV)**

Cluster-wide storage resource (EBS volumes in AWS).

### **Persistent Volume Claim (PVC)**

Request for storage by a pod. Your Spring Boot app uses this to claim persistent storage.

### **Storage Class**

Defines different classes of storage (SSD, HDD, different performance tiers in AWS).

## Configuration and Secrets

### **ConfigMap**

Stores non-sensitive configuration data (application.properties, environment-specific configs).

```yaml
# Spring Boot configuration example
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  application.properties: |
    spring.datasource.url=jdbc:mysql://db-service:3306/mydb
    server.port=8080
```

### **Secret**

Stores sensitive data (passwords, API keys, certificates) in base64 encoding.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
data:
  username: dXNlcm5hbWU=  # base64 encoded
  password: cGFzc3dvcmQ=  # base64 encoded
```

## Resource Management

### **ResourceQuota**

Limits resource consumption in a namespace (CPU, memory, number of pods).

### **LimitRange**

Sets default and maximum resource limits for containers in a namespace.

### **Horizontal Pod Autoscaler (HPA)**

Automatically scales the number of pods based on CPU usage, memory, or custom metrics.

### **Vertical Pod Autoscaler (VPA)**

Automatically adjusts CPU and memory requests/limits for containers.

### **Cluster Autoscaler**

Automatically scales the number of nodes in your cluster based on demand (integrates with AWS Auto Scaling Groups).

## Security and Access Control

### **Service Account**

Identity for processes running in pods. Your Spring Boot app runs under a service account.

### **Role**

Set of permissions within a namespace.

### **ClusterRole**

Set of permissions across the entire cluster.

### **RoleBinding**

Grants permissions defined in a Role to users or service accounts within a namespace.

### **ClusterRoleBinding**

Grants permissions defined in a ClusterRole across the entire cluster.

### **Pod Security Policy/Pod Security Standards**

Defines security constraints for pods (running as non-root, read-only filesystems, etc.).

## Observability and Debugging

### **Label**

Key-value pairs attached to objects for identification and selection.

### **Selector**

Query to select objects based on labels.

### **Annotation**

Non-identifying metadata attached to objects.

### **Event**

Records of what's happening in your cluster (pod scheduling, image pulling, errors).

### **Log**

Container stdout/stderr output, accessible via `kubectl logs`.

### **Probe**

Health checks for your containers:

- **Liveness Probe**: Checks if container is running
- **Readiness Probe**: Checks if container is ready to serve traffic
- **Startup Probe**: Checks if container has started successfully

```yaml
# Spring Boot health check example
livenessProbe:
  httpGet:
    path: /actuator/health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Spring Boot & Microservices Specific

### **Health Checks**

Spring Boot Actuator endpoints (`/actuator/health`) used for Kubernetes probes.

### **Graceful Shutdown**

Proper application termination when pods are being stopped (important for Spring Boot apps).

### **Service Discovery**

Kubernetes DNS automatically provides service discovery for your microservices.

### **Configuration Management**

Using ConfigMaps and Secrets to externalize Spring Boot configuration.

### **Circuit Breaker Pattern**

Implementing resilience patterns (Spring Cloud Circuit Breaker) in your microservices.

## AWS-Specific Kubernetes Terms

### **EKS (Elastic Kubernetes Service)**

AWS managed Kubernetes service.

### **Fargate**

Serverless compute engine for containers (no node management required).

### **ALB (Application Load Balancer)**

Layer 7 load balancer, often used with Ingress controllers.

### **NLB (Network Load Balancer)**

Layer 4 load balancer for high-performance scenarios.

### **EBS CSI Driver**

Container Storage Interface driver for Amazon Elastic Block Store.

### **IAM Roles for Service Accounts (IRSA)**

AWS-specific way to provide IAM permissions to Kubernetes pods.

### **AWS Load Balancer Controller**

Kubernetes controller that manages ALB and NLB creation.

## Command Line Tools

### **kubectl**

Command-line tool for interacting with Kubernetes clusters.

### **helm**

Package manager for Kubernetes applications.

### **kustomize**

Tool for customizing Kubernetes configurations.

### **eksctl**

Command-line tool for creating and managing EKS clusters.

## Common kubectl Commands for Developers

```bash
# View resources
kubectl get pods
kubectl get services
kubectl get deployments

# Describe resources
kubectl describe pod <pod-name>
kubectl describe service <service-name>

# View logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow logs

# Execute commands in containers
kubectl exec -it <pod-name> -- /bin/bash

# Port forwarding for local development
kubectl port-forward service/user-service 8080:8080

# Apply configurations
kubectl apply -f deployment.yaml
kubectl apply -k ./kustomize-configs

# Scale applications
kubectl scale deployment user-service --replicas=5
```

This terminology forms the foundation for working with Kubernetes in a Java/Spring Boot microservices environment on
AWS. Understanding these concepts will help you effectively deploy, manage, and troubleshoot your containerized
applications.