# n8n Self-Hosting on AWS ECS

Self-hosted n8n workflow automation on AWS ECS using AWS Copilot CLI with automated deployments via GitHub Actions.

## Prerequisites

- AWS account with ECS permissions
- AWS CLI installed and configured (`us-east-2` region)
- AWS Copilot CLI installed
- Domain name with DNS management access

## Deployment

Deployments are automated via GitHub Actions. When code is merged to `main`, the workflow automatically:
- Builds the Docker image
- Pushes to ECR
- Deploys to ECS via Copilot

## Upgrading n8n

1. **Update the version in `Dockerfile`:**
   ```dockerfile
   FROM docker.n8n.io/n8nio/n8n:1.123.6
   ```

2. **Create a PR and merge to `main`**

The GitHub Actions workflow will automatically build and deploy the new version. Your workflows, credentials, and data are preserved on EFS.

## Local Development

Run locally with Docker Compose:

1. **Create `.env` file:**
   ```bash
   DOMAIN_NAME=yourdomain.com
   SUBDOMAIN=n8n
   GENERIC_TIMEZONE=Europe/Berlin
   SSL_EMAIL=your-email@yourdomain.com
   ```

2. **Run:**
   ```bash
   docker-compose up -d
   ```

## Useful Commands

```bash
# Check service status
copilot svc status --name n8n --env production

# View logs
copilot svc logs --name n8n --env production --follow

# Execute commands in container
copilot svc exec --name n8n --env production --command "ls -la /home/node/.n8n"
```

## Architecture

```
GitHub Actions → ECR → ECS Fargate (Private Subnet) → EFS (Persistent Storage)
                  ↓
              CloudWatch Logs
```
