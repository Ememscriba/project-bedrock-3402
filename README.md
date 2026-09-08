# Bedrock

A production-style microservices retail platform on AWS EKS — provisioned entirely as code, secured by default, and built to scale automatically.

**Live demo:** [store.saphigen.com](https://store.saphigen.com)

![Architecture Diagram](./docs/architecture.png)

---

## What this is

Bedrock started as a cloud engineering capstone project and was rebuilt into a production-grade platform. It deploys a real microservices retail application (UI, catalog, cart, orders, checkout) onto Amazon EKS, with a managed data layer, zero-downtime autoscaling, encrypted secrets management, HTTPS on a custom domain, and full observability — all defined in Terraform and Helm.

## Highlights

- **Zero plaintext secrets** — database credentials are stored in AWS Secrets Manager and synced into the cluster at runtime via External Secrets Operator. Nothing sensitive is ever committed to source control.
- **Autoscaling at every layer** — Horizontal Pod Autoscaler scales each microservice on CPU load; Cluster Autoscaler scales EKS nodes to match. No manual capacity planning.
- **Real HTTPS, real domain** — TLS terminated at the Application Load Balancer using an AWS Certificate Manager certificate, served on `store.saphigen.com`.
- **Fully packaged with Helm** — the entire application — deployments, services, ingress, autoscalers, and secret sync — installs with a single `helm install`.
- **Infrastructure as Code** — every AWS resource (VPC, EKS, RDS, DynamoDB, IAM roles, ACM certs, CloudWatch alarms) is defined in Terraform with remote state.
- **CI/CD** — GitHub Actions runs `terraform plan` on every PR (posted as a PR comment for review) and `terraform apply` on merge to main, followed by an automated smoke test against the live endpoint.
- **Observability** — CloudWatch captures EKS control-plane and container logs, with a custom dashboard and CPU/memory alarms wired to SNS.
- **Event-driven pipeline** — an S3 bucket triggers a Lambda function on every upload, demonstrating a serverless integration pattern alongside the core platform.
- **Least-privilege security** — a dedicated developer IAM user has read-only console access and scoped Kubernetes RBAC (`view` role) — verified to allow `get` but block `delete`.

## Architecture

The platform runs across two Availability Zones. Public subnets host the ALB; private subnets host the EKS worker nodes and the RDS/DynamoDB data layer. All secrets flow from AWS Secrets Manager into the cluster — nothing is hardcoded. See the diagram above for the full request and data flow.

## Tech stack

| Layer | Technology |
|---|---|
| Compute | Amazon EKS (Kubernetes 1.34), t3.small worker nodes |
| IaC | Terraform (S3 remote state) |
| Packaging | Helm |
| Data | RDS MySQL, RDS PostgreSQL, DynamoDB |
| Secrets | AWS Secrets Manager + External Secrets Operator |
| Ingress | AWS Load Balancer Controller, ALB, ACM (TLS) |
| DNS | Cloudflare |
| Autoscaling | Horizontal Pod Autoscaler, Cluster Autoscaler |
| Observability | Amazon CloudWatch (logs, dashboard, alarms, SNS) |
| Serverless | S3, Lambda (Python) |
| CI/CD | GitHub Actions |

## Repository structure

## Deploying

Requires an AWS account, Terraform, kubectl, and Helm.

```bash
# 1. Provision infrastructure
cd terraform
terraform init
terraform apply

# 2. Connect to the cluster
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1

# 3. Install cluster add-ons
helm repo add eks https://aws.github.io/eks-charts
helm repo add external-secrets https://charts.external-secrets.io
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
  --set clusterName=project-bedrock-cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=<lb-controller-role-arn> \
  --set region=us-east-1 \
  --set vpcId=$(terraform output -raw vpc_id)

helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace \
  --set serviceAccount.create=true \
  --set serviceAccount.name=external-secrets \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=<eso-role-arn>

helm install cluster-autoscaler autoscaler/cluster-autoscaler -n kube-system \
  --set autoDiscovery.clusterName=project-bedrock-cluster \
  --set awsRegion=us-east-1 \
  --set rbac.serviceAccount.name=cluster-autoscaler \
  --set rbac.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=<autoscaler-role-arn>

# 4. Deploy the application
cd ../chart
helm install bedrock bedrock/ --set ingress.certificateArn=<acm-certificate-arn>
```

## Tearing down

```bash
helm uninstall bedrock -n retail-app
terraform destroy
```

## Why this project exists

This is a demonstration of end-to-end platform engineering: not just "does the app run," but does it run securely, scale automatically, recover from node failure, and stay observable — all without a human touching the AWS console. Every piece here — from the IAM trust policies to the autoscaling thresholds — was deliberately chosen and, where things broke, debugged from first principles rather than copy-pasted.

## Author

Built by [Emem John](https://saphigen.com).
