# 🚀 AWS ACADEMY E-COMMERCE DEPLOYMENT GUIDE

## ✅ Infrastructure Created Successfully!

Your AWS Academy resources have been provisioned:

```
AWS Region: us-east-1
ALB DNS: ecommerce-prod-alb-1002360347.us-east-1.elb.amazonaws.com

Instances:
  📍 Instance 1: 54.167.205.206 (i-05a62f88b7cdabcb9)
  📍 Instance 2: 44.213.99.53   (i-029ef4292724c3df4)

Status: RUNNING ✅
Budget Remaining: ~$40
Time Remaining: ~3 hours 50 minutes
```

---

## 🔑 STEP 1: Download the vockey.pem Key

1. Go to **AWS Academy Learner Lab Console**
2. Click **AWS Details** (top-right)
3. Scroll down to **SSH key** section
4. Click **Download PEM** to download `vockey.pem`
5. Save to: `C:\Users\<YourUsername>\Downloads\vockey.pem`

---

## 🖥️ STEP 2: Connect to Instance 1

### Option A: Using AWS EC2 Instance Connect (Web Browser - Easiest)
1. Go to AWS Console → EC2 → Instances
2. Select **web-instance-1** (54.167.205.206)
3. Click **Connect** button
4. Choose **EC2 Instance Connect** tab
5. Click **Connect** to open browser terminal
6. Skip to **Step 3** below

### Option B: Using SSH (Command Line)
```powershell
# Open PowerShell in your Downloads folder where vockey.pem is saved
cd $env:USERPROFILE\Downloads

# Connect to Instance 1
ssh -i vockey.pem ubuntu@54.167.205.206
```

---

## 📦 STEP 3: Deploy Application on Instance 1

Once connected to the instance via browser terminal or SSH, run this command:

```bash
cd /tmp && curl -fsSL https://raw.githubusercontent.com/your-repo/deploy-docker.sh | bash
```

Or if you want to do it manually:

```bash
# Create app directory
sudo mkdir -p /opt/ecommerce
sudo chown -R ubuntu:ubuntu /opt/ecommerce
cd /opt/ecommerce

# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker

# Get the deployment script from your project
# (You'll need to upload the deploy-docker.sh script to the instance)
# Then run: bash deploy-docker.sh
```

---

## 🔄 STEP 4: Repeat for Instance 2

1. Disconnect from Instance 1
2. Connect to Instance 2 (44.213.99.53) using same method as Step 2
3. Run the same deployment commands from Step 3
4. Wait for containers to start

---

## ✨ STEP 5: Test Your Application

### Via ALB (Load Balancer):
```
http://ecommerce-prod-alb-1002360347.us-east-1.elb.amazonaws.com
```

### Direct Instance Access:
```
Instance 1: http://54.167.205.206
Instance 2: http://44.213.99.53
```

You should see:
- 🛍️ E-Commerce Store header
- ✅ "Service is running successfully" green banner
- Product cards: Laptop ($1,200), Phone ($800), Smartwatch ($300), Tablet ($500), Headphones ($150)
- "Open Cart" button (top right)

---

## 🛒 Test Shopping Cart Features

1. Click on any **"Add to Cart"** button
2. Cart panel opens on the right
3. Test these features:
   - ➕ Increase/decrease quantity with +/- buttons
   - ❌ Remove items
   - 🗑️ Clear entire cart
   - 💳 Click "Checkout" for success message
   - 💾 Refresh page - cart persists via localStorage!

---

## 🐳 Verify Docker Containers are Running

After deployment, on each instance run:

```bash
docker ps
```

You should see 3 containers:
```
CONTAINER ID   IMAGE                    STATUS
xxx            ecommerce_app            Up X minutes
xxx            mongo:6.0                Up X minutes
xxx            nginx:latest             Up X minutes
```

---

## 📊 Check Application Logs

```bash
# View nginx logs
docker logs ecommerce_nginx_1

# View app logs
docker logs ecommerce_app_1

# View MongoDB logs
docker logs ecommerce_mongodb_1

# Check all container status
docker-compose ps
```

---

## 🎯 For Jury Demonstration

Present exactly as shown:
1. **Infrastructure**: "2 EC2 t2.micro instances in us-east-1 behind ALB"
2. **Load Balancing**: "Both instances serve identical content - ALB distributes traffic"
3. **Containerization**: "Docker Compose manages: Nginx (reverse proxy), Node.js (app), MongoDB (database)"
4. **Live Demo**:
   - Navigate to ALB DNS
   - Add multiple products to cart
   - Show cart persists after page refresh
   - Click Checkout
5. **Infrastructure as Code**:
   - "Terraform provisions all AWS resources"
   - "Ansible configures servers"
   - "GitHub Actions runs full CI/CD pipeline"

---

## 🚨 Troubleshooting

### Application not accessible on port 80
```bash
# Check if containers are running
docker ps

# Check nginx config
docker exec ecommerce_nginx_1 nginx -t

# Restart containers
docker-compose restart nginx
```

### MongoDB connection error
```bash
# Check MongoDB is running
docker exec ecommerce_mongodb_1 mongo --version

# Verify network
docker network ls
docker network inspect ecommerce-net
```

### npm packages missing
```bash
# Rebuild containers
docker-compose build --no-cache

# Restart all
docker-compose down && docker-compose up -d
```

### Container keeps restarting
```bash
# Check logs
docker logs <container-name>

# Check resource usage
docker stats

# Free up space if needed
docker system prune -a
```

---

## ⏰ Time Management

- **Terraform**: ✅ Complete (15 min)
- **Deploy Instance 1**: ~5-10 min
- **Deploy Instance 2**: ~5-10 min
- **Testing**: ~5 min
- **Buffer**: ~20 min

**Total Remaining**: ~3 hours 50 minutes (plenty of time!)

---

## 📝 Files in This Project

```
Ansible Project/
├── terraform/
│   ├── main.tf              (AWS resources)
│   ├── variables.tf         (Configuration)
│   ├── outputs.tf           (Instance IPs, ALB DNS)
│   └── .terraform/          (Terraform state)
│
├── app/
│   ├── app.js              (Express backend + HTML)
│   ├── package.json        (Dependencies)
│   └── Dockerfile          (Container image)
│
├── ansible/
│   ├── deploy.yml          (Deployment playbook)
│   ├── nginx.conf          (Reverse proxy config)
│   └── templates/          (Config templates)
│
├── docker-compose.yml      (Multi-container setup)
├── inventory.ini           (Ansible hosts - UPDATED)
└── deploy-docker.sh        (Manual deployment script)
```

---

## 🎓 Architecture Summary

```
┌─────────────────────────────────────────────────────┐
│                    INTERNET (80/443)                 │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│  AWS Application Load Balancer (ALB)                │
│  DNS: ecommerce-prod-alb-1002360347...             │
└────────────┬──────────────────────────┬─────────────┘
             │                          │
    ┌────────▼──────────┐      ┌────────▼──────────┐
    │  EC2 Instance 1   │      │  EC2 Instance 2   │
    │ 54.167.205.206    │      │ 44.213.99.53      │
    │  Security Group   │      │  Security Group   │
    │  Port: 80,22      │      │  Port: 80,22      │
    │                   │      │                   │
    │  Docker Compose:  │      │  Docker Compose:  │
    │ ┌─────────────┐   │      │ ┌─────────────┐   │
    │ │ Nginx:80    │   │      │ │ Nginx:80    │   │
    │ │ ↓           │   │      │ │ ↓           │   │
    │ │ App:3000    │   │      │ │ App:3000    │   │
    │ │ ↓           │   │      │ │ ↓           │   │
    │ │ MongoDB     │   │      │ │ MongoDB     │   │
    │ └─────────────┘   │      │ └─────────────┘   │
    └───────────────────┘      └───────────────────┘
```

---

## ✅ Checklist Before Jury Demo

- [ ] Both instances deployed and running
- [ ] ALB DNS resolves and shows app (green banner visible)
- [ ] Products display with prices
- [ ] "Add to Cart" buttons work
- [ ] Cart panel opens/closes properly
- [ ] Quantity +/- controls work
- [ ] Remove item button works
- [ ] Clear cart button works
- [ ] Checkout shows success message
- [ ] Cart persists after page refresh (check localStorage)
- [ ] Both instances show IDENTICAL display
- [ ] Terraform files documented
- [ ] SSH keys secured
- [ ] AWS Academy time/budget monitored

---

## 📞 Support Commands

```bash
# SSH into Instance 1
ssh -i ~/Downloads/vockey.pem ubuntu@54.167.205.206

# SSH into Instance 2
ssh -i ~/Downloads/vockey.pem ubuntu@44.213.99.53

# View all AWS Academy instances
aws ec2 describe-instances --region us-east-1 --query "Reservations[*].Instances[*].[InstanceId,PublicIpAddress,State.Name]" --output table

# Check ALB health
aws elbv2 describe-target-health --target-group-arn <TARGETGROUP-ARN> --region us-east-1

# Monitor AWS Academy budget/time
# Use AWS Academy Learner Lab Dashboard console
```

---

**Status**: ✅ Infrastructure Ready | ⏳ Awaiting Manual Deployment Script Execution

**Good luck with your jury demonstration! 🎉**
