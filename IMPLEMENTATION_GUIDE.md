# Step-by-Step Implementation Guide

## 📋 Complete DevOps Lab Setup

This guide walks through all steps to successfully deploy the e-commerce application using Terraform, Ansible, Docker, and GitHub Actions.

---

## **STEP 1: Prerequisites** ✅

Before starting, ensure you have:

### A. AWS Account Setup
- [ ] AWS Account created
- [ ] IAM user with appropriate permissions
- [ ] AWS Access Key ID & Secret Access Key generated
- [ ] EC2 Key Pair created (`lab-key`) in `us-east-1` region
- [ ] EC2 Key Pair `.pem` file downloaded and saved safely

### B. GitHub Setup
- [ ] GitHub account created
- [ ] Repository created: `ecommerce-devops-lab`
- [ ] Git installed on local machine
- [ ] Git configured with your username and email:
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
  ```

### C. Local Tools (Optional)
- [ ] Terraform >= 1.0 installed
- [ ] Ansible >= 2.9 installed
- [ ] Docker Desktop installed
- [ ] VS Code or preferred editor

---

## **STEP 2: Create GitHub Repository** ✅

```bash
# 1. Create new repo on GitHub (via web interface)
# Name: ecommerce-devops-lab
# Visibility: Public or Private (your choice)

# 2. Clone locally
git clone https://github.com/YOUR_USERNAME/ecommerce-devops-lab.git
cd ecommerce-devops-lab

# 3. Initialize with our project files (if not already cloned)
# Copy all files from this project into the repo
```

**Expected Structure After Clone:**
```
ecommerce-devops-lab/
├── .github/workflows/pipeline.yml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── user_data.sh
├── ansible/
│   ├── deploy.yml
│   ├── inventory.ini
│   └── templates/
├── app/
│   ├── app.js
│   └── package.json
├── Dockerfile
├── docker-compose.yml
├── README.md
└── ...
```

---

## **STEP 3: Configure GitHub Secrets** ✅ (CRITICAL!)

### Navigate to Repository Settings

1. Go to GitHub → Your Repository
2. Click **Settings** (top menu)
3. Click **Secrets and variables** → **Actions** (left sidebar)

### Add Each Secret

#### Secret 1: AWS_ACCESS_KEY_ID
```
Name: AWS_ACCESS_KEY_ID
Value: AKIA... (from AWS IAM)
```

#### Secret 2: AWS_SECRET_ACCESS_KEY
```
Name: AWS_SECRET_ACCESS_KEY
Value: wJalrX... (from AWS IAM)
```

#### Secret 3: AWS_REGION
```
Name: AWS_REGION
Value: us-east-1
```

#### Secret 4: EC2_KEY
```
Name: EC2_KEY
Value: -----BEGIN RSA PRIVATE KEY-----
       ... (entire content of your lab-key.pem file)
       -----END RSA PRIVATE KEY-----
```

**Verification:**
- [ ] All 4 secrets are listed with ✅ checkmarks
- [ ] No typos in secret names
- [ ] Values are correctly copied

⚠️ **IMPORTANT**: If any secret has a typo or wrong value, the pipeline will fail!

---

## **STEP 4: Customize Terraform Variables** ✅ (Optional)

Edit `terraform/variables.tf` to customize:

```hcl
variable "aws_region" {
  default = "us-east-1"  # Change if needed
}

variable "instance_type" {
  default = "t2.micro"   # Free tier eligible
}

variable "key_pair_name" {
  default = "lab-key"    # Must match your EC2 key pair
}
```

**Ensure `key_pair_name` matches your EC2 key pair in AWS!**

---

## **STEP 5: Push Code to GitHub** ✅

```bash
# From project root directory
git add .
git commit -m "Initial DevOps lab commit"
git push origin main
```

**Expected Output:**
```
Enumerating objects: X, done.
Counting objects: 100% (X/X), done.
Delta compression using up to 8 threads
To github.com:YOUR_USERNAME/ecommerce-devops-lab.git
 * [new branch]      main -> main
```

---

## **STEP 6: Monitor Pipeline Execution** ✅

### Watch in Real-Time

1. Go to **GitHub → Your Repository**
2. Click **Actions** tab
3. You should see "Full DevOps Pipeline" running
4. Click on it to see detailed logs

### Pipeline Stages

The pipeline automatically runs in this order:

#### Stage 1: Terraform (15-20 minutes)
```
✓ Checkout Code
✓ Configure AWS Credentials
✓ Setup Terraform
✓ Terraform Init
✓ Terraform Validate
✓ Terraform Plan
✓ Terraform Apply
✓ Export Instance IPs
```

**During this stage:**
- VPC, Subnets, NAT Gateway, Internet Gateway created
- Security Groups configured
- 2 EC2 instances launched
- ALB created and configured
- IAM roles created

**Expected Terraform Output:**
```
Outputs:

alb_dns_name = "ecommerce-alb-1234567890.us-east-1.elb.amazonaws.com"
instance_public_ips = [
  "10.0.10.45",
  "10.0.11.78"
]
vpc_id = "vpc-0a1b2c3d4e5f6g7h8"
```

#### Stage 2: Ansible (10-15 minutes)
```
✓ Checkout
✓ Install Ansible & Dependencies
✓ Setup SSH Key
✓ Generate Inventory
✓ Run Ansible Playbook - Deploy
✓ Verify Deployment
```

**During this stage:**
- Ansible connects to EC2 instances via SSH
- Installs Docker and Docker Compose
- Starts services (Nginx, Node.js, MongoDB)
- Verifies health checks

**Expected Ansible Output:**
```
TASK [Create application directory] ***
ok: [10.0.10.45]
ok: [10.0.11.78]

TASK [Start docker-compose services] ***
changed: [10.0.10.45]
changed: [10.0.11.78]

PLAY RECAP ***
10.0.10.45 : ok=10 changed=3 unreachable=0 failed=0
10.0.11.78 : ok=10 changed=3 unreachable=0 failed=0
```

### Troubleshooting Pipeline Failures

#### Common Issue: "AWS Credentials Invalid"
- ✅ Check secrets are correctly set
- ✅ Verify AWS user has EC2, ELB, IAM permissions
- ✅ Check access key is not expired

#### Common Issue: "Terraform Init Failed"
- ✅ Check AWS credentials in secrets
- ✅ Verify region exists and is not restricted
- ✅ Check IAM user has `ec2:*`, `elasticloadbalancing:*` permissions

#### Common Issue: "SSH Connection Timeout"
- ✅ Wait 3-5 minutes for EC2 instances to fully boot
- ✅ Verify EC2_KEY secret is complete (includes BEGIN and END lines)
- ✅ Check key pair name matches in `variables.tf`
- ✅ Ensure NAT Gateway is created (check Terraform output)

---

## **STEP 7: Access Your Application** ✅

### Get ALB DNS Name

1. **From GitHub Actions Output:**
   - View Terraform step output
   - Look for `alb_dns_name` value
   - Example: `ecommerce-alb-1234567890.us-east-1.elb.amazonaws.com`

2. **From AWS Console:**
   - Go to EC2 → Load Balancers
   - Find `ecommerce-alb`
   - Copy DNS name

### Open in Browser

```
http://ecommerce-alb-1234567890.us-east-1.elb.amazonaws.com
```

### Expected Result ✅

You should see:
- **E-Commerce Store** heading with logo
- **Product cards** displaying:
  - 💻 Laptop - $1,200
  - 📱 Phone - $800
  - ⌚ Smartwatch - $300
- **Add to Cart** buttons
- **Styled interface** with gradient background

---

## **STEP 8: Verify Deployment** ✅

### Check AWS Resources

1. **VPC & Networking:**
   ```
   EC2 → VPCs → ecommerce-vpc
   - VPC CIDR: 10.0.0.0/16
   - Subnets: 4 (2 public, 2 private)
   - NAT Gateway: 1
   - Internet Gateway: 1
   ```

2. **EC2 Instances:**
   ```
   EC2 → Instances
   - web-instance-1 (in private subnet AZ1)
   - web-instance-2 (in private subnet AZ2)
   - Status: Running
   - Security Group: ec2-sg
   ```

3. **Load Balancer:**
   ```
   EC2 → Load Balancers → ecommerce-alb
   - Status: Active
   - Target Group: web-tg
   - Targets: 2 (both Healthy)
   ```

4. **Security Groups:**
   ```
   EC2 → Security Groups
   - alb-sg: Port 80, 443 open to 0.0.0.0/0
   - ec2-sg: Port 22, 80, 3000 configured
   ```

### Check Docker Containers

SSH into an instance and verify:

```bash
# SSH into instance (if you have direct access)
ssh -i lab-key.pem ubuntu@instance-ip

# Inside instance:
docker ps -a
# Should show:
# - nginx
# - app (Node.js)
# - mongodb

docker logs nginx   # Check Nginx logs
docker logs app     # Check App logs
```

### Test API Endpoints

```bash
# From your local machine:

# Health check
curl http://your-alb-dns/health

# Get products
curl http://your-alb-dns/api/products

# Expected response (JSON):
# [
#   {"id": 1, "name": "Laptop", "price": 1200, ...},
#   {"id": 2, "name": "Phone", "price": 800, ...},
#   ...
# ]
```

---

## **STEP 9: Cleanup (IMPORTANT!)** 🗑️

### To Avoid AWS Charges

**Option A: GitHub Actions Workflow Dispatch**
```
GitHub → Actions → Full DevOps Pipeline → Run workflow
```

**Option B: Manual Cleanup**
```bash
cd terraform
terraform destroy -auto-approve
```

⚠️ **WARNING**: This deletes ALL resources:
- VPC, Subnets, NAT Gateway, Internet Gateway
- EC2 instances
- ALB and Target Groups
- Security Groups
- IAM Roles and Instance Profiles

**Cost Estimation:**
- t2.micro: ~$0.01/hour (Free tier if <750 hours/month)
- NAT Gateway: ~$0.045/hour
- ALB: ~$0.0225/hour
- Total: ~$0.08/hour (~$2/day if running 24/7)

**Recommendation:** Destroy resources when not in use!

---

## **STEP 10: Learning Outcomes** 🎓

By completing this lab, you've learned:

✅ **Terraform (IaC)**
- Define cloud infrastructure as code
- Manage VPC, Subnets, Security Groups, EC2, ALB
- Output values for automation
- State management

✅ **Ansible (Configuration Management)**
- Write idempotent playbooks
- Manage multiple servers efficiently
- Use templates for dynamic configuration
- Implement health checks

✅ **Docker (Containerization)**
- Create multi-container applications
- Use Docker Compose for orchestration
- Container networking and volumes
- Health checks and logging

✅ **GitHub Actions (CI/CD)**
- Build automated pipelines
- Manage secrets securely
- Chain jobs with dependencies
- Monitor and troubleshoot deployments

✅ **Cloud Architecture**
- Design scalable infrastructure
- Implement load balancing
- Secure network architecture (public/private subnets)
- High availability with multiple AZs

---

## **Additional Resources** 📚

### Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions](https://docs.github.com/en/actions)

### Quick Reference

**Terraform Commands:**
```bash
terraform init       # Initialize working directory
terraform plan      # Review planned changes
terraform apply     # Apply changes
terraform destroy   # Delete resources
terraform output    # Show output values
```

**Ansible Commands:**
```bash
ansible-playbook playbook.yml -i inventory.ini    # Run playbook
ansible-inventory --list -i inventory.ini          # Show inventory
ansible-playbook playbook.yml --check             # Dry-run
ansible-playbook playbook.yml -vvv                # Verbose
```

**Docker Commands:**
```bash
docker-compose up -d          # Start services
docker-compose down           # Stop services
docker ps -a                  # List containers
docker logs container_name    # View logs
docker exec -it container_name bash  # Shell access
```

---

## **Success Checklist** ✅

- [ ] GitHub repository created and secrets configured
- [ ] Pipeline executed successfully
- [ ] ALB DNS obtained
- [ ] Application accessible in browser
- [ ] All 3 products visible (Laptop, Phone, Smartwatch)
- [ ] AWS resources verified in console
- [ ] API endpoints tested
- [ ] Resources destroyed to prevent charges
- [ ] Learned Terraform, Ansible, Docker, and GitHub Actions

---

**Congratulations! You've successfully completed the DevOps CI/CD Lab! 🎉**

For questions or issues, refer to the main README.md or SECRETS_SETUP.md files.
