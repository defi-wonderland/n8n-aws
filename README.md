# n8n Self-Hosting Setup on AWS ECS

A modern setup for self-hosting n8n workflow automation on AWS ECS using AWS Copilot CLI.

## Prerequisites

- AWS account with ECS permissions
- AWS CLI installed and configured (using `us-east-2` region)
- Docker and Docker Compose installed locally
- AWS Copilot CLI installed
- Domain name with DNS management access

**Note:** This setup is configured for the `us-east-2` (Ohio) region. All resources will be created in this region.

## Quick Start

### Step 1: Install Copilot CLI and Configure AWS

1. **Install AWS Copilot CLI:**
   ```bash
   brew install aws/tap/copilot-cli
   ```

2. **Configure AWS credentials (if not already done):**
   ```bash
   aws configure
   ```
   
   Provide your AWS Access Key ID, Secret Access Key, region (`us-east-2`), and output format (`json`).

3. **Verify configuration:**
   ```bash
   aws sts get-caller-identity
   ```

### Step 2: Initialize Copilot Application

1. **Initialize the application and service:**
   ```bash
   copilot app init n8n-app
   copilot svc init --name n8n --svc-type "Load Balanced Web Service" --image docker.n8n.io/n8nio/n8n --port 5678
   ```

### Step 3: Configure Service

1. **Copy and customize the service manifest:**
   ```bash
   cp copilot/n8n/manifest.yml.template copilot/n8n/manifest.yml
   ```

2. **Edit `copilot/n8n/manifest.yml` and replace:**
   - `n8n.yourdomain.com` with your actual domain
   - `YOUR_ACCOUNT_ID` and `YOUR_CERT_ID` with your AWS account ID and certificate ID

### Step 4: Deploy Environment and Service

1. **Create and deploy the production environment:**
   ```bash
   copilot env init --name production
   cp copilot/environments/production/manifest.yml.template copilot/environments/production/manifest.yml
   ```

2. **Edit `copilot/environments/production/manifest.yml` and update the certificate ARN**

3. **Deploy everything:**
   ```bash
   copilot env deploy --name production
   copilot svc deploy --name n8n --env production
   ```

### Step 5: Configure DNS and SSL

1. **Get your Load Balancer DNS:**
   ```bash
   copilot svc show --name n8n --env production
   ```

2. **Create DNS CNAME record:**
   Point `n8n.yourdomain.com` to your Load Balancer DNS name

3. **Request SSL certificate in AWS Certificate Manager:**
   - Go to [AWS Certificate Manager (us-east-2)](https://us-east-2.console.aws.amazon.com/acm/home)
   - Request a public certificate for `n8n.yourdomain.com`
   - Use DNS validation and add the CNAME record to your DNS
   - Copy the certificate ARN once validated

4. **Update manifests with certificate ARN and redeploy:**
   ```bash
   # Update both manifest files with your certificate ARN
   copilot env deploy --name production
   copilot svc deploy --name n8n --env production
   ```

## Local Development

For local development, you can use Docker Compose:

1. **Create `.env` file:**
   ```bash
   DOMAIN_NAME=yourdomain.com
   SUBDOMAIN=n8n
   GENERIC_TIMEZONE=Europe/Berlin
   SSL_EMAIL=your-email@yourdomain.com
   ```

2. **Run locally:**
   ```bash
   docker-compose up -d
   ```

## Access Your n8n Instance

Once deployed, access n8n at `https://n8n.yourdomain.com` and complete the initial setup to create your admin account.

## Maintenance Commands

```bash
# Check service status
copilot svc show --name n8n --env production

# View logs
copilot svc logs --name n8n --env production --follow

# Update n8n (modify manifest and redeploy)
copilot svc deploy --name n8n --env production

# Execute commands in container
copilot task run --image docker.n8n.io/n8nio/n8n --command "ls -la /home/node/.n8n"
```

## Cleanup

To remove all resources:

```bash
copilot svc delete --name n8n --env production
copilot env delete --name production
copilot app delete
```

Don't forget to clean up:
- SSL certificates from Certificate Manager
- DNS records from your domain provider

## Architecture

```
Internet -> ALB -> ECS Fargate (Private Subnet) -> EFS (Persistent Storage)
                    |
                    -> CloudWatch (Monitoring & Logs)
```
