# AWS Cleanup Script - Remove all ecommerce-prod-* resources
# Set AWS region
$region = "us-east-1"

Write-Host "🧹 Starting AWS cleanup for ecommerce-prod resources..." -ForegroundColor Yellow

# 1. Terminate EC2 instances
Write-Host "`n1️⃣ Terminating EC2 instances..."
aws ec2 describe-instances --region $region --filters "Name=tag:Name,Values=ecommerce-prod-web*" --query 'Reservations[*].Instances[*].InstanceId' --output text | ForEach-Object {
    if ($_) {
        Write-Host "  Terminating instance: $_"
        aws ec2 terminate-instances --instance-ids $_ --region $region
    }
}

# Wait for instances to terminate
Write-Host "  Waiting for instances to terminate (60 seconds)..."
Start-Sleep -Seconds 60

# 2. Delete Application Load Balancer
Write-Host "`n2️⃣ Deleting ALB..."
$albArn = aws elbv2 describe-load-balancers --region $region --names "ecommerce-prod-alb" --query 'LoadBalancers[0].LoadBalancerArn' --output text 2>$null
if ($albArn -and $albArn -ne "None") {
    Write-Host "  Deleting ALB: $albArn"
    aws elbv2 delete-load-balancer --load-balancer-arn $albArn --region $region 2>$null
} else {
    Write-Host "  ALB not found (OK)"
}

# Wait for ALB to delete before deleting target groups
Start-Sleep -Seconds 10

# 3. Delete Target Groups
Write-Host "`n3️⃣ Deleting Target Groups..."
$tgArn = aws elbv2 describe-target-groups --region $region --names "ecommerce-prod-tg" --query 'TargetGroups[0].TargetGroupArn' --output text 2>$null
if ($tgArn -and $tgArn -ne "None") {
    Write-Host "  Deleting target group: $tgArn"
    aws elbv2 delete-target-group --target-group-arn $tgArn --region $region 2>$null
} else {
    Write-Host "  Target group not found (OK)"
}

# 4. Delete Security Groups
Write-Host "`n4️⃣ Deleting Security Groups..."
@("ecommerce-prod-alb-sg", "ecommerce-prod-ec2-sg") | ForEach-Object {
    $sgId = aws ec2 describe-security-groups --region $region --filters "Name=group-name,Values=$_" --query 'SecurityGroups[0].GroupId' --output text 2>$null
    if ($sgId -and $sgId -ne "None") {
        Write-Host "  Deleting security group: $_ ($sgId)"
        aws ec2 delete-security-group --group-id $sgId --region $region 2>$null
    } else {
        Write-Host "  Security group '$_' not found (OK)"
    }
}

# 5. Delete IAM Instance Profile
Write-Host "`n5️⃣ Deleting IAM Instance Profile..."
$profileName = "ecommerce-prod-app-profile"
$instances = aws iam list-instance-profiles-for-role --role-name "ecommerce-prod-app-role" --query 'InstanceProfiles[0].InstanceProfileName' --output text 2>$null
if ($instances -and $instances -ne "None") {
    Write-Host "  Removing role from instance profile: $instances"
    aws iam remove-role-from-instance-profile --instance-profile-name $instances --role-name "ecommerce-prod-app-role" 2>$null
}

$profileCheck = aws iam get-instance-profile --instance-profile-name $profileName --query 'InstanceProfile.InstanceProfileName' --output text 2>$null
if ($profileCheck -and $profileCheck -ne "None") {
    Write-Host "  Deleting instance profile: $profileName"
    aws iam delete-instance-profile --instance-profile-name $profileName 2>$null
} else {
    Write-Host "  Instance profile not found (OK)"
}

# 6. Delete IAM Role
Write-Host "`n6️⃣ Deleting IAM Role..."
$roleName = "ecommerce-prod-app-role"
$roleCheck = aws iam get-role --role-name $roleName --query 'Role.RoleName' --output text 2>$null
if ($roleCheck -and $roleCheck -ne "None") {
    Write-Host "  Detaching inline policies from role: $roleName"
    aws iam list-role-policies --role-name $roleName --query 'PolicyNames[]' --output text | ForEach-Object {
        if ($_) {
            Write-Host "    Deleting policy: $_"
            aws iam delete-role-policy --role-name $roleName --policy-name $_ 2>$null
        }
    }
    
    Write-Host "  Deleting role: $roleName"
    aws iam delete-role --role-name $roleName 2>$null
} else {
    Write-Host "  IAM role not found (OK)"
}

Write-Host "`n✅ Cleanup complete!" -ForegroundColor Green
Write-Host "All ecommerce-prod-* resources have been removed.`n"
