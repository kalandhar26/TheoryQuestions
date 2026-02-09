# 1. Compute & Application Hosting

## Your Spring Boot app works locally but fails on EC2. How do you debug it?

## When would you choose EC2 over Elastic Beanstalk for Spring Boot?

## When is AWS ECS or EKS a better choice than EC2?

## How do you run multiple Spring Boot services on a single EC2 safely?

## How do you handle JVM memory tuning on EC2 vs containers?

## How do you deploy a Spring Boot app using Elastic Beanstalk?

## How do you choose between Fargate and EC2 for Spring Boot workloads?

# 2. Load Balancing & Traffic Routing

## Your Spring Boot app must handle millions of requests. ## How do you design traffic routing?

## Difference between ALB, NLB, and CLB — which one fits Spring Boot APIs?

## How do you configure path-based routing (/users, /orders) in ALB?

## How do health checks work between ALB and Spring Boot?

## How do you handle sticky sessions for web portals?

## How do you route mobile and web traffic differently?

# 3. Auto Scaling & High Availability

## Your app CPU spikes during peak hours. How do you auto-scale?

## Difference between vertical and horizontal scaling in AWS?

## How does Auto Scaling Group decide When to add/remove instances?

## How do you design multi-AZ deployment for Spring Boot?

## What happens ## When an EC2 instance suddenly dies?

## Why scaling sometimes doesn’t trigger even under high load?

# 4. Configuration & Secrets Management

## How do you externalize Spring Boot configuration in AWS?

## When to use AWS Parameter Store vs Secrets Manager?

## How do you rotate DB credentials without restarting the app?

## How do you manage different configs for dev, QA, and prod?

## How do you inject secrets securely into Spring Boot apps?

# 5. Database & Persistence

## How do you choose between RDS, Aurora, and DynamoDB?

## Your DB becomes a bottleneck ## When app scales. ## What do you do?

## How do read replicas help Spring Boot applications?

## How do you handle DB failover in AWS?

## How do you manage DB connections efficiently?

# 6. Messaging & Event-Driven Architecture

## When would you use SQS vs SNS vs EventBridge?

## How do you design async processing with Spring Boot and SQS?

## How do you handle message retries and DLQs?

## How do you guarantee message ordering?

## How do you process high-volume events reliably?

# 7. Caching & Performance

## How do you use ElastiCache (Redis) with Spring Boot?

## Cache stampede problem — How do you prevent it?

## What happens ## When cache goes down?

## How do you choose TTL values correctly?

## How do you handle session management using Redis?

# 8. Security & Identity

## How do you secure Spring Boot APIs using IAM?

## Difference between IAM roles and IAM users?

## How do you allow EC2 to access S3 securely?

## How do you integrate Cognito with Spring Security?

## How do you secure internal service-to-service communication?

# 9. API Management & Gateways

## When should you use API Gateway vs ALB?

## How do you implement JWT authentication at API Gateway?

## How do you do rate limiting per user?

## How do you protect /admin APIs?

## How do you version APIs safely?

# 10. Observability & Monitoring

## How do you monitor Spring Boot apps using CloudWatch?

## What metrics are critical for JVM-based services?

## How do you centralize logs across services?

## How do you trace requests using AWS X-Ray?

## How do you set alarms for failures?

# 11. CI/CD & Deployments

## How do you build CI/CD for Spring Boot on AWS?

## Blue-Green deployment using AWS — How does it work?

## Canary deployment — When is it preferred?

## How do you rollback a bad deployment quickly?

## How do you handle DB migrations in CI/CD?

# 12. Networking & VPC Design

## How do you design a secure VPC for Spring Boot apps?

## Difference between public and private subnets?

## How does NAT Gateway work?

## How do security groups differ from NACLs?

## How do you restrict DB access only to app servers?

# 13. Global & Multi-Region Architecture

## How do you route traffic globally using Route 53?

## How do you handle users from different geographies?

## Active-active vs active-passive setup — When to use?

## How do you replicate data across regions?

## How do you design DR (Disaster Recovery)?

# 14. Cost Optimization

## Your AWS bill spikes unexpectedly. ## How do you debug?

## When should you use Spot instances?

## How do you optimize EC2 costs for Java apps?

## How do you right-size instances?

## What common AWS cost mistakes do Java developers make?

# 15. Compliance, Banking & Enterprise Scenarios

## How do you design AWS architecture for regulated systems?

## How do you ensure audit logging and immutability?

## How do you encrypt data at rest and in transit?

## How do you handle key rotation using KMS?

## How do you restrict production access?

# 16. Failure & Incident Handling

## ALB is healthy but users see 5xx errors. ## What do you check?

## A region goes down. ## What happens to ## Your application?

## How do you simulate failure scenarios?

## How do you perform chaos testing on AWS?

## How do you do post-incident analysis?

# 17. Design & Architecture Thinking

## When should you avoid AWS managed services?

## What AWS service would you never use blindly?

## Common AWS antipatterns in Spring Boot apps?

## How do you explain AWS architecture to non-technical stakeholders?

## How do you future-proof ## Your AWS design?