# ⚡ Quick Reference - Commands & Troubleshooting

## 🔧 Terraform Commands

```bash
# Initialize Terraform (creates .terraform/ directory)
terraform init

# Validate syntax
terraform validate

# Preview changes (dry-run)
terraform plan

# Apply changes (actually creates resources)
terraform apply

# Apply without prompting
terraform apply -auto-approve

# View current outputs
terraform output

# Destroy all resources
terraform destroy -auto-approve

# Format code
terraform fmt -recursive

# Show specific resource
terraform show aws_instance.web1
```

## 🎭 Ansible Commands

```bash
# Run playbook
ansible-playbook -i inventory.ini deploy.yml

# Dry-run (check mode)
ansible-playbook -i inventory.ini deploy.yml --check

# Verbose output
ansible-playbook -i inventory.ini deploy.yml -vvv

# Run specific task
ansible-playbook -i inventory.ini deploy.yml --start-at-task="Install Docker"

# List all hosts in inventory
ansible-inventory -i inventory.ini --list

# Ping all hosts
ansible -i inventory.ini all -m ping

# Run ad-hoc command
ansible -i inventory.ini web -m shell -a "docker ps"
```

## 🐳 Docker Commands

```bash
# Start services (background)
docker-compose up -d

# Stop services
docker-compose down

# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# View logs
docker logs container_name

# Follow logs (live)
docker logs -f container_name

# Execute command in container
docker exec -it container_name bash

# Build image
docker build -t image_name:tag .

# Run container
docker run -d -p 8080:80 image_name:tag

# Remove image
docker rmi image_name:tag

# Clean up (remove unused resources)
docker system prune -a
```

## 📝 Git Commands

```bash
# Initialize repository
git init

# Add all files
git add .

# Commit changes
git commit -m "Your message"

# Push to remote
git push origin main

# Pull from remote
git pull origin main

# View status
git status

# View log
git log --oneline

# Create new branch
git checkout -b feature-name

# Switch branch
git checkout branch-name

# Merge branch
git merge branch-name
```

## 🌐 AWS CLI Commands

```bash
# Configure credentials
aws configure

# List EC2 instances
aws ec2 describe-instances

# List VPCs
aws ec2 describe-vpcs

# List ALBs
aws elbv2 describe-load-balancers

# Get security group
aws ec2 describe-security-groups

# Terminate instance
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# SSH into instance (if accessible)
ssh -i lab-key.pem ubuntu@instance-ip
```

## 🔐 GitHub Secrets Management

```bash
# Via CLI (if GitHub CLI installed)
gh secret set AWS_ACCESS_KEY_ID --body "your-key"
gh secret list
gh secret delete AWS_ACCESS_KEY_ID

# Via Web Interface (recommended):
# 1. Go to Repository Settings
# 2. Secrets and variables → Actions
# 3. New repository secret
```

---

## 🐛 Common Issues & Fixes

### Issue: "AWS credentials not found"
```bash
# Solution 1: Check secrets in GitHub
# Go to: Settings → Secrets and variables → Actions

# Solution 2: Verify credentials format
# AWS_ACCESS_KEY_ID should start with AKIA
# AWS_SECRET_ACCESS_KEY should be long alphanumeric string

# Solution 3: Check IAM user permissions
# Required: ec2:*, elasticloadbalancing:*, iam:*
```

### Issue: "Terraform init fails"
```bash
# Solution 1: Check AWS region
terraform init -var aws_region=us-east-1

# Solution 2: Clear cache
rm -rf .terraform/

# Solution 3: Validate credentials
aws sts get-caller-identity

# Solution 4: Check bucket permissions (if using remote state)
```

### Issue: "Ansible SSH timeout"
```bash
# Solution 1: Wait for EC2 instances to boot (3-5 minutes)
sleep 300

# Solution 2: Check security group allows SSH (port 22)
aws ec2 describe-security-groups --group-ids sg-xxxxx

# Solution 3: Verify EC2_KEY secret is complete
# Should include -----BEGIN RSA PRIVATE KEY-----
# and -----END RSA PRIVATE KEY-----

# Solution 4: Check SSH key permissions
chmod 600 ~/.ssh/ec2_key.pem

# Solution 5: SSH directly to test
ssh -i ec2_key.pem ubuntu@10.0.10.45
```

### Issue: "Docker containers not starting"
```bash
# Solution 1: Check Docker status
docker ps
docker ps -a

# Solution 2: View container logs
docker logs nginx
docker logs app
docker logs mongodb

# Solution 3: Check Docker compose file
docker-compose config

# Solution 4: Restart services
docker-compose restart

# Solution 5: Rebuild images
docker-compose build --no-cache
docker-compose up -d
```

### Issue: "App showing 502 Bad Gateway"
```bash
# Solution 1: Verify upstream is running
docker logs app
curl http://localhost:3000

# Solution 2: Check Nginx configuration
docker exec nginx nginx -t

# Solution 3: Check network connectivity
docker exec app curl http://mongodb:27017
docker exec nginx curl http://app:3000

# Solution 4: Restart services
docker-compose restart
```

### Issue: "MongoDB connection refused"
```bash
# Solution 1: Check MongoDB is running
docker ps | grep mongodb

# Solution 2: View MongoDB logs
docker logs mongodb

# Solution 3: Check connection string
# Should be: mongodb://mongodb:27017/ecommerce

# Solution 4: Verify network
docker network ls
docker network inspect ecommerce-net

# Solution 5: Restart MongoDB
docker restart mongodb
```

### Issue: "GitHub Actions Secret not found"
```bash
# Solution 1: Check exact secret name (case-sensitive)
# AWS_ACCESS_KEY_ID (not aws_access_key_id)

# Solution 2: Verify secret was saved
# Go to Settings → Secrets → Actions (should see ●●●●●●)

# Solution 3: Clear GitHub Actions cache
# Go to Settings → Actions → General
# Check "Limit workflow run history"

# Solution 4: Check repo has Actions enabled
# Settings → General → Actions permissions: "Allow all actions"
```

---

## 📊 Monitoring & Debugging

### Check Pipeline Progress
```bash
# GitHub Actions logs are in:
# GitHub → Actions → Workflow → Click job → View logs

# Key log sections to check:
# 1. Checkout Code ✓
# 2. Configure AWS Credentials ✓
# 3. Terraform Plan (review planned changes)
# 4. Terraform Apply (watch resource creation)
# 5. Export Instance IPs (check IP format)
# 6. Install Ansible ✓
# 7. Setup SSH Key ✓
# 8. Generate Inventory (verify IPs)
# 9. Run Ansible Playbook (watch task execution)
```

### Check AWS Resources
```bash
# List all resources created
aws resourcegroupstaggingapi get-resources \
  --tag-filter-list "Key=Environment,Values=lab"

# Check specific resources
aws ec2 describe-instances --filters "Name=tag:Name,Values=web-*"
aws elbv2 describe-load-balancers --names ecommerce-alb
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=ecommerce-vpc"
```

### Monitor Docker Containers
```bash
# Real-time monitoring
docker stats

# Check container resource usage
docker ps --format "table {{.Names}}\t{{.CPUs}}\t{{.MemUsage}}"

# View network connections
docker exec container_name netstat -tlnp

# Check container IP
docker inspect container_name | grep IPAddress
```

---

## 📈 Performance Optimization

### Reduce Pipeline Execution Time
```bash
# 1. Use smaller instance types
# t2.micro is fine for lab (2GB RAM)

# 2. Parallelize jobs in GitHub Actions
# Currently: Terraform → Ansible (sequential)
# Could parallel test jobs if needed

# 3. Cache Terraform plugins
# Add: ~/.terraform.d/plugin-cache

# 4. Use latest AMI
# Ubuntu 22.04 LTS is pre-optimized
```

### Improve Resource Efficiency
```bash
# 1. Use VPC endpoint for S3 (if storing state)
# 2. Enable detailed monitoring only when needed
# 3. Use smaller EBS volumes (default 20GB sufficient)
# 4. Delete unused security group rules
```

---

## 📚 File Reference

| File | Purpose |
|------|---------|
| `.github/workflows/pipeline.yml` | CI/CD pipeline definition |
| `terraform/main.tf` | AWS infrastructure code |
| `terraform/variables.tf` | Input variables |
| `terraform/outputs.tf` | Output values |
| `terraform/user_data.sh` | EC2 initialization |
| `ansible/deploy.yml` | Configuration playbook |
| `ansible/inventory.ini` | Server inventory template |
| `ansible/templates/docker-compose.yml.j2` | Docker Compose template |
| `ansible/templates/nginx.conf.j2` | Nginx configuration |
| `app/app.js` | Node.js application |
| `app/package.json` | npm dependencies |
| `Dockerfile` | Docker image definition |
| `docker-compose.yml` | Local development setup |
| `README.md` | Project documentation |
| `ACTION_PLAN.md` | Implementation plan |
| `IMPLEMENTATION_GUIDE.md` | Step-by-step guide |
| `SECRETS_SETUP.md` | GitHub secrets guide |

---

## 🔐 Security Best Practices

```bash
# 1. Never commit secrets
echo "EC2_KEY" >> .gitignore

# 2. Rotate credentials every 90 days
# AWS IAM → Users → Access keys → Rotate

# 3. Use IAM roles instead of access keys when possible
# (Not applicable for GitHub Actions - need keys)

# 4. Restrict security group rules to specific IPs
# Don't use 0.0.0.0/0 for SSH in production

# 5. Use VPN/Bastion host for production access
# Current: Instances in private subnet (good)

# 6. Enable VPC Flow Logs for monitoring
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-xxxxx \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs
```

---

## 💡 Pro Tips

1. **Pipeline slow?**
   - Check GitHub Actions queue (may wait for runner)
   - Usually 30-40 min total (Terraform + Ansible)

2. **Want to debug Ansible locally?**
   ```bash
   ansible-playbook -i inventory.ini ansible/deploy.yml --check -vvv
   ```

3. **Want to test Terraform locally?**
   ```bash
   cd terraform
   terraform validate
   terraform plan -out=tfplan
   # Review plan before applying!
   ```

4. **Want to monitor costs?**
   ```bash
   # AWS Console → Cost Explorer
   # Filter by: Environment=lab
   ```

5. **Need to pause infrastructure?**
   ```bash
   # Stop EC2 instances (pause costs)
   aws ec2 stop-instances --instance-ids i-xxxxx
   
   # Start again when needed
   aws ec2 start-instances --instance-ids i-xxxxx
   ```

---

**Happy DevOps! 🚀**
