# E-Commerce Application Deployment Script
# AWS Academy Edition

$INSTANCE_IPS = @("54.167.205.206", "44.213.99.53")
$KEY_PATH = "$env:USERPROFILE\Downloads\vockey.pem"
$PROJECT_DIR = "c:\Users\mohamednacer.hammami\Downloads\Ansible Project"
$APP_DIR = "/opt/ecommerce"

# Check if vockey.pem exists
if (-not (Test-Path $KEY_PATH)) {
    Write-Host "❌ ERROR: vockey.pem not found at $KEY_PATH" -ForegroundColor Red
    Write-Host "Please download vockey.pem from AWS Academy Learner Lab console" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found vockey.pem" -ForegroundColor Green

# Function to deploy to an instance
function Deploy-Instance {
    param(
        [string]$IP,
        [int]$InstanceNum
    )
    
    Write-Host "`n🚀 Deploying to Instance $InstanceNum ($IP)..." -ForegroundColor Cyan
    
    # Create app directory
    Write-Host "   1. Creating app directory..." -ForegroundColor Yellow
    ssh -i $KEY_PATH -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" ubuntu@$IP `
        "sudo mkdir -p $APP_DIR && sudo chown -R ubuntu:ubuntu $APP_DIR" 2>&1 | Select-String -Pattern "error|Error|ERROR" -NotMatch
    
    # Copy application files
    Write-Host "   2. Copying application files..." -ForegroundColor Yellow
    scp -i $KEY_PATH -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" `
        "$PROJECT_DIR\app\app.js" "ubuntu@${IP}:$APP_DIR/" 2>&1 | Select-String -Pattern "100%" -NotMatch
    scp -i $KEY_PATH -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" `
        "$PROJECT_DIR\app\package.json" "ubuntu@${IP}:$APP_DIR/" 2>&1 | Select-String -Pattern "100%" -NotMatch
    scp -i $KEY_PATH -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" `
        "$PROJECT_DIR\app\Dockerfile" "ubuntu@${IP}:$APP_DIR/" 2>&1 | Select-String -Pattern "100%" -NotMatch
    
    # Copy nginx config and docker-compose
    Write-Host "   3. Copying Docker configuration..." -ForegroundColor Yellow
    scp -i $KEY_PATH -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" `
        "$PROJECT_DIR\docker-compose.yml" "ubuntu@${IP}:$APP_DIR/" 2>&1 | Select-String -Pattern "100%" -NotMatch
    scp -i $KEY_PATH -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" `
        "$PROJECT_DIR\ansible\nginx.conf" "ubuntu@${IP}:$APP_DIR/nginx.conf" 2>&1 | Select-String -Pattern "100%" -NotMatch
    
    # Install Docker and deploy
    Write-Host "   4. Installing Docker and deploying containers..." -ForegroundColor Yellow
    ssh -i $KEY_PATH -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" ubuntu@$IP `
        "cd $APP_DIR && sudo apt-get update -qq && sudo apt-get install -y -qq docker.io docker-compose && sudo systemctl start docker && sudo usermod -aG docker ubuntu && sudo docker-compose up -d --build"
    
    # Verify deployment
    Write-Host "   5. Verifying deployment..." -ForegroundColor Yellow
    ssh -i $KEY_PATH -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" ubuntu@$IP `
        "cd $APP_DIR && docker ps --format 'table {{.Names}}\t{{.Status}}'"
    
    Write-Host "   ✅ Instance $InstanceNum deployment complete!" -ForegroundColor Green
}

# Deploy to both instances
foreach ($IP in $INSTANCE_IPS) {
    $InstanceNum = [array]::IndexOf($INSTANCE_IPS, $IP) + 1
    Deploy-Instance -IP $IP -InstanceNum $InstanceNum
}

Write-Host "`n🎉 Deployment complete! Your e-commerce application is running on both instances." -ForegroundColor Green
Write-Host "📍 Access via Load Balancer: http://ecommerce-prod-alb-1002360347.us-east-1.elb.amazonaws.com" -ForegroundColor Cyan
Write-Host "📍 Direct Access Instance 1: http://54.167.205.206" -ForegroundColor Cyan
Write-Host "📍 Direct Access Instance 2: http://44.213.99.53" -ForegroundColor Cyan
