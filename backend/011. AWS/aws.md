# Key AWS Tech

| AWS Service                                   | Key Functionality                                     | Use Case in Java/Spring Boot                                                                               |
|-----------------------------------------------|-------------------------------------------------------|------------------------------------------------------------------------------------------------------------|
| **IAM** (Identity & Access Management)        | Manages users, roles, and permissions securely.       | - Securing AWS API access (e.g., S3, DynamoDB)<br>- Assigning roles to EC2 instances for secure SDK access |
| **VPC** (Virtual Private Cloud)               | Isolated networking environment for AWS resources     | - Deploying Spring Boot apps in private subnets<br>- Configuring security groups (firewall rules)          |
| **EC2** (Elastic Compute Cloud)               | Virtual servers in the cloud (Linux/Windows)          | - Hosting Spring Boot apps on virtual machines<br>- Auto Scaling for high availability                     |
| **S3** (Simple Storage Service)               | Object storage for files (unstructured data)          | - Storing app logs, images, or static content<br>- Backup & restore for Spring Boot apps                   |
| **Lambda** (Serverless Compute)               | Runs event-driven functions without servers           | - Processing S3 uploads, API Gateway requests<br>- Async task execution (e.g., PDF generation)             |
| **ECS** (Elastic Container Service)           | Docker container orchestration (managed by AWS)       | - Running Spring Boot apps in Docker containers<br>- Integrates with Fargate (serverless containers)       |
| **ELB** (Elastic Load Balancer)               | Distributes traffic across multiple EC2/ECS instances | - Load balancing Spring Boot microservices<br>- Supports HTTP(S), TCP, and WebSockets                      |
| **RDS** (Relational Database Service - MySQL) | Managed relational database (MySQL, PostgreSQL, etc.) | - Spring Boot application.yml connects to RDS MySQL<br>- Automated backups & failover                      |
| **CDK** (Cloud Development Kit)               | Infrastructure-as-Code (IaC) using Java/Python        | - Programmatically defining AWS resources (VPC, ECS, etc.)<br>- Deploying stacks via AWS CloudFormation    |
| **EKS** (Elastic Kubernetes Service)          | Managed Kubernetes for container orchestration        | - Deploying Spring Boot microservices in K8s<br>- Auto-scaling with Horizontal Pod Autoscaler (HPA)        |

# AWS ECS vs EKS Cheat Sheet for Java Microservices

## 🔄 Common Workflow

| Step          | ECS Command                       | EKS Command                        |
|---------------|-----------------------------------|------------------------------------|
| **Deploy**    | `aws ecs update-service`          | `kubectl apply -f deployment.yaml` |
| **Rollback**  | `aws ecs deploy --rollback`       | `kubectl rollout undo deployment`  |
| **View Logs** | `aws logs tail /ecs/service-name` | `kubectl logs -f <pod>`            |

## 1️⃣ ECS Essentials (Fargate/EC2)

### Cluster & Tasks

```bash
# List clusters
aws ecs list-clusters

# Describe services
aws ecs describe-services --cluster my-cluster --services my-service

# Run one-off task (e.g., DB migration)
aws ecs run-task --cluster my-cluster \
  --task-definition my-task:1 \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-123],securityGroups=[sg-123]}"

# Update service (zero-downtime deploy)
aws ecs update-service --cluster my-cluster \
  --service my-service \
  --force-new-deployment
```

## 1. How to fetch kafka topic names dynamically from AWS Parameter Store or ConfigMap (Kubernetes) so you don’t have to redeploy when topics change?

- To handle dynamic Kafka topic names without redeploying your Spring Boot app, you can fetch them from external configuration sources like AWS Parameter Store or Kubernetes ConfigMaps.

### **1. AWS Parameter Store (SSM)**

- Store topics in AWS Parameter Store

```swift
/myapp/kafka/topics/order   → order-topic
/myapp/kafka/topics/payment → payment-topic
```

- Add Spring Cloud AWS dependency

```xml
<dependency>
    <groupId>io.awspring.cloud</groupId>
    <artifactId>spring-cloud-starter-aws-parameter-store-config</artifactId>
</dependency>
```

- Enable Parameter Store in application.yml

```yaml
spring:
  config:
    import: aws-parameterstore:
  cloud:
    aws:
      parameterstore:
        enabled: true
        prefix: /myapp/kafka/topics
```

- Now we can inject topics

```java
@Value("${order}")
private String orderTopic;

@Value("${payment}")
private String paymentTopic;
```

- Changing topics in Parameter Store → App picks them on refresh (if Spring Cloud Config is used with @RefreshScope

### **2. Kubernetes ConfigMap**
- Create ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-topics-config
data:
  order: order-topic
  payment: payment-topic
```
- Mount ConfigMap as Environment Variables
```yaml
env:
  - name: KAFKA_TOPIC_ORDER
    valueFrom:
      configMapKeyRef:
        name: kafka-topics-config
        key: order
```
- Use in Spring Boot
```java
@Value("${KAFKA_TOPIC_ORDER}")
private String orderTopic;
```
- Update ConfigMap → Roll out new values → Pods automatically get updated topics (with a rolling restart).
- Kafka does not allow changing topic names at runtime without redeployment unless you implement a mechanism to poll external config and refresh beans dynamically.
- For fully hot-reloadable topics, you'd need:
- @RefreshScope beans.
- Spring Cloud Config or similar dynamic config management.
- Custom topic resolution service that queries AWS/K8s before each send.

# Interview Questions

## How do you deploy a springboot microservice on AWS ECS or EKS?

## When to use SQS vs Kafka in AWS architecture?

## How do you manage secrets and environment variables securely in AWS?