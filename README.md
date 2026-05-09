# E-Commerce DevOps Lab: Terraform + Ansible + Docker + GitHub Actions

## 📋 Project Overview

This is a comprehensive DevOps CI/CD lab project demonstrating:
- **Infrastructure as Code (IaC)** with Terraform on AWS
- **Configuration Management** with Ansible
- **Container Orchestration** with Docker & Docker Compose
- **CI/CD Automation** with GitHub Actions
- **Cloud Architecture** with AWS ALB, EC2, VPC, and Security Groups

## 🎯 Learning Objectives

By the end of this lab, students will understand:
1. ✅ Provision AWS infrastructure using Terraform
2. ✅ Configure servers using Ansible
3. ✅ Containerize applications with Docker
4. ✅ Deploy multi-container applications
5. ✅ Automate everything via GitHub Actions pipeline

## 📦 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     AWS Region (us-east-1)              │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │              VPC (10.0.0.0/16)                   │  │
│  │                                                  │  │
│  │  ┌──────────────────┐   ┌─────────────────────┐ │  │
│  │  │   Public Subnet  │   │  Private Subnet 1   │ │  │
│  │  │  (10.0.1.0/24)   │   │  (10.0.10.0/24)     │ │  │
│  │  │                  │   │                     │ │  │
│  │  │  ┌────────────┐  │   │  ┌───────────────┐  │ │  │
│  │  │  │ ALB        │  │   │  │ EC2 Instance1 │  │ │  │
│  │  │  │ :80/:443   │  │   │  │ (Docker Apps) │  │ │  │
│  │  │  └────────────┘  │   │  └───────────────┘  │ │  │
│  │  │                  │   │                     │ │  │
│  │  └──────────────────┘   └─────────────────────┘ │  │
│  │           │                                       │  │
│  │  ┌────────┴──────────────┐                       │  │
│  │  │   Internet Gateway     │                       │  │
│  │  │   + NAT Gateway        │                       │  │
│  │  └──────────────────────┘                       │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
ecommerce-devops-lab/
├── .github/
│   └── workflows/
│       └── pipeline.yml           # GitHub Actions CI/CD pipeline
├── terraform/
│   ├── main.tf                    # Main infrastructure code
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output definitions
│   └── user_data.sh               # EC2 initialization script
├── ansible/
│   ├── deploy.yml                 # Deployment playbook
│   └── templates/
│       ├── docker-compose.yml.j2  # Docker Compose template
│       └── nginx.conf.j2          # Nginx configuration template
├── app/
│   ├── app.js                     # Node.js Express application
│   └── package.json               # Node.js dependencies
├── Dockerfile                     # Docker image definition
├── docker-compose.yml             # Local development setup
├── .gitignore                     # Git ignore rules
└── README.md                      # This file
```

## 🚀 Quick Start

### Prerequisites

✅ **Required:**
- AWS Account with appropriate permissions
- GitHub Account
- AWS Access Key ID & Secret Access Key
- EC2 Key Pair created in AWS
- Git installed locally

✅ **Optional:**
- Terraform installed locally (v1.0+)
- Ansible installed locally (v2.9+)
- Docker installed locally

### Step 1: Setup GitHub Repository

1. Create a new GitHub repository named `ecommerce-devops-lab`
2. Clone this project to your local machine:
   ```bash
   git clone https://github.com/yourusername/ecommerce-devops-lab.git
   cd ecommerce-devops-lab
   ```

### Step 2: Configure GitHub Secrets

Navigate to: **GitHub → Settings → Secrets and variables → Actions**

Add the following secrets:

| Secret Name | Description | Example |
|---|---|---|
| `AWS_ACCESS_KEY_ID` | AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | AWS region | `us-east-1` |
| `EC2_KEY` | EC2 private key content | `-----BEGIN RSA PRIVATE KEY-----...` |

### Step 3: Deploy

**Option A: Automatic via GitHub Actions**
```bash
git add .
git commit -m "Initial commit"
git push origin main
```

Then go to: **GitHub → Actions** and watch the pipeline execute!

**Option B: Manual Local Deployment**

```bash
# Initialize Terraform
cd terraform
terraform init
terraform plan
terraform apply

# Run Ansible
cd ../
ansible-playbook -i inventory.ini ansible/deploy.yml
```

## 📊 Pipeline Workflow

```
GitHub Push
    ↓
1. TERRAFORM JOB
   ├── Checkout code
   ├── Configure AWS credentials
   ├── Terraform init/validate/plan/apply
   └── Export EC2 IPs
    ↓
2. ANSIBLE JOB
   ├── Install Ansible
   ├── Configure SSH
   ├── Generate inventory
   └── Run deployment playbook
    ↓
3. DEPLOYMENT
   ├── Install Docker
   ├── Start Docker Compose
   ├── Launch Nginx
   ├── Launch Node.js App
   └── Launch MongoDB
    ↓
SUCCESS: Application accessible via ALB DNS
```

## 🔍 Expected Outputs

After the pipeline completes successfully:

1. **ALB DNS Name** (from Terraform outputs)
   ```
   Example: ecommerce-alb-1234567890.us-east-1.elb.amazonaws.com
   ```

2. **Open in Browser:**
   ```
   http://ecommerce-alb-1234567890.us-east-1.elb.amazonaws.com
   ```

3. **Expected Result:**
   - E-Commerce store homepage with products
   - Products: Laptop ($1200), Phone ($800), Smartwatch ($300)
   - Fully functional shopping interface

## 🛠️ Key Components

### Terraform (Infrastructure)
- **VPC**: 10.0.0.0/16 with public & private subnets in 2 AZs
- **ALB**: Application Load Balancer for traffic distribution
- **EC2**: 2 instances running Docker containers
- **Security Groups**: Proper ingress/egress rules
- **NAT Gateway**: For private subnet internet access

### Ansible (Configuration)
- Install Docker & Docker Compose
- Pull and start containers
- Configure Nginx as reverse proxy
- Health checks and service verification

### Docker Compose Stack
- **Nginx**: Reverse proxy (port 80)
- **Node.js App**: E-Commerce API (port 3000)
- **MongoDB**: Database (port 27017)

### GitHub Actions Pipeline
- Fully automated infrastructure and application deployment
- Uses Terraform for IaC
- Uses Ansible for configuration management
- Manual destroy capability via workflow dispatch

## 📝 Common Issues & Troubleshooting

| Issue | Solution |
|-------|----------|
| **SSH fails: "Permission denied"** | Check EC2 Key Pair name in variables.tf, ensure .pem is in secrets |
| **Terraform apply fails** | Verify AWS credentials in GitHub secrets |
| **Ansible timeout** | Check NAT Gateway is created, wait 2-3 minutes for instances |
| **App not loading** | Verify Docker containers are running: `docker ps` |
| **MongoDB connection refused** | Ensure MongoDB container started: `docker logs mongodb` |
| **Nginx 502 Bad Gateway** | Check Node.js app is running on port 3000 |

## 🔐 Security Considerations

⚠️ **For Lab Use Only:**
- SSH is open to 0.0.0.0/0 (should be restricted in production)
- Secrets are stored in GitHub (use AWS Secrets Manager in production)
- MongoDB has no authentication (add in production)
- Application is HTTP only (use HTTPS in production)

## 🧹 Cleanup

To destroy all infrastructure and avoid AWS charges:

**Option 1: GitHub Actions Workflow Dispatch**
- Go to **Actions → Full DevOps Pipeline → Run workflow**
- The destroy job will clean up all resources

**Option 2: Manual Cleanup**
```bash
cd terraform
terraform destroy -auto-approve
```

⚠️ **WARNING**: This will delete all AWS resources created by this project!

## 📚 Learning Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 👥 Contributors

ITeam University - DevOps Course 2025-2026

## 📄 License

This project is provided as-is for educational purposes.

---

**Happy DevOps Learning! 🚀**
