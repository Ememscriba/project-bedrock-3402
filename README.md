# Project Bedrock - InnovateMart EKS Deployment

## Architecture
- VPC: project-bedrock-vpc (us-east-1)
- EKS Cluster: project-bedrock-cluster (v1.34)
- RDS MySQL: bedrock-mysql
- RDS PostgreSQL: bedrock-postgres
- DynamoDB: bedrock-carts-table
- S3: bedrock-assets-3402
- Lambda: bedrock-asset-processor

## Store URL
http://k8s-retailap-ui-6039ab69e6-2089655454.us-east-1.elb.amazonaws.com

## How to Trigger the Pipeline
- Push to main branch triggers terraform apply
- Create a Pull Request triggers terraform plan

## Deploy Application
```bash
kubectl apply -f k8s/retail-store.yaml
kubectl apply -f k8s/backends.yaml
```

## Generate Grading Data
```bash
cd terraform && terraform output -json > ../grading.json
```

## Developer Credentials (bedrock-dev-view)
- Access Key ID: AKIATGAQYK222PWUWO4C
- Secret Access Key: (retrieve from terraform output)
- Console Password: (retrieve from terraform output)

## Verify Developer Access
```bash
kubectl get pods -n retail-app  # should work
kubectl delete pod <pod-name> -n retail-app  # should fail
```
