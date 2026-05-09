# GitHub Actions Secrets Configuration Guide

This file documents how to set up the necessary secrets in GitHub for the CI/CD pipeline.

## Required Secrets

### 1. AWS Credentials

#### AWS_ACCESS_KEY_ID
- **Description**: Your AWS Access Key ID
- **How to get it**:
  1. Go to AWS Console → IAM → Users
  2. Select your user or create new one
  3. Go to "Access keys" tab
  4. Click "Create access key" (or use existing one)
  5. Copy the Access Key ID
- **Value**: `AKIAIOSFODNN7EXAMPLE` (example format)

#### AWS_SECRET_ACCESS_KEY
- **Description**: Your AWS Secret Access Key
- **How to get it**:
  1. Same as above, but copy the Secret Access Key
  2. ⚠️ **IMPORTANT**: Save this somewhere safe - you can only see it once!
- **Value**: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` (example format)

#### AWS_REGION
- **Description**: AWS region where infrastructure will be deployed
- **Example values**: `us-east-1`, `eu-west-1`, `ap-southeast-1`
- **Default**: `us-east-1`

### 2. EC2 Key Pair

#### EC2_KEY
- **Description**: Private key content for SSH access to EC2 instances
- **How to get it**:
  1. Go to AWS Console → EC2 → Key Pairs
  2. Create a new key pair named `lab-key` (or use existing)
  3. Download the `.pem` file
  4. Open the `.pem` file with a text editor
  5. Copy the entire content (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`)
- **Value**: 
  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEA2Z3c7f...
  [multiple lines of the actual key content]
  ...wJrt0Fy8HhYQKBgQC6IQ==
  -----END RSA PRIVATE KEY-----
  ```

## How to Add Secrets to GitHub

1. **Navigate to Repository Settings**:
   - Go to your GitHub repository
   - Click **Settings** (top right)

2. **Go to Secrets & Variables**:
   - In the left sidebar, click **Secrets and variables**
   - Click **Actions**

3. **Create New Secret**:
   - Click **New repository secret** button
   - Enter the secret name (e.g., `AWS_ACCESS_KEY_ID`)
   - Paste the secret value in the text area
   - Click **Add secret**

4. **Repeat** for all required secrets above

## Verification

After adding all secrets, you should see:
- ✅ AWS_ACCESS_KEY_ID
- ✅ AWS_SECRET_ACCESS_KEY
- ✅ AWS_REGION
- ✅ EC2_KEY

All with a green checkmark indicating they're set correctly.

## Security Best Practices

⚠️ **IMPORTANT**:
1. **Never commit secrets** to the repository
2. **Rotate keys** regularly (every 90 days recommended)
3. **Use IAM roles** instead of access keys when possible
4. **Restrict key permissions** to only what's needed (principle of least privilege)
5. **Delete unused keys** from AWS IAM
6. **Monitor key usage** in CloudTrail

## Troubleshooting

### "Terraform Apply failed - Permission Denied"
- Check AWS credentials are correct and have required permissions
- Required IAM permissions:
  - ec2:*
  - elasticloadbalancing:*
  - logs:*
  - iam:CreateRole
  - iam:PutRolePolicy
  - iam:CreateInstanceProfile

### "SSH Connection Timeout"
- Verify EC2_KEY matches the key pair name in `terraform/variables.tf`
- Check security group allows SSH (port 22)
- Ensure NAT Gateway is created and working

### "Secret not found in Actions"
- Make sure you created the secret with the EXACT name
- Secrets are case-sensitive
- Repository must have Actions enabled

## AWS IAM Permissions (Recommended)

For production use, create an IAM user with these inline policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2Management",
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ALBManagement",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMManagement",
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:PutRolePolicy",
                "iam:CreateInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:PassRole"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CloudWatchLogs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
    ]
}
```

---

**Setup Time**: ~5-10 minutes
**Difficulty**: Easy
