#!/bin/bash
# Redeploy containers only (quick fix)

set -e

INSTANCE_IPS=("3.236.166.233" "3.87.71.129")
SSH_KEY="$HOME/Downloads/lab-key.pem"

for IP in "${INSTANCE_IPS[@]}"; do
    echo "🔄 Redeploying containers on $IP..."
    
    # Kill and remove containers
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@$IP \
        "docker-compose -f /opt/ecommerce/docker-compose.yml down || true" 2>/dev/null || {
        echo "⚠️ Cannot reach $IP via SSH, trying docker restart instead..."
        ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@$IP \
            "sudo systemctl restart docker && sleep 10 && docker ps" 2>/dev/null || echo "SSH failed for $IP"
        continue
    }
    
    # Start fresh
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@$IP \
        "cd /opt/ecommerce && docker-compose up -d" 2>/dev/null
    
    echo "✅ Containers redeployed on $IP"
done

echo ""
echo "⏳ Waiting 30 seconds for containers to start..."
sleep 30

echo ""
echo "🌐 Testing application..."
for IP in "${INSTANCE_IPS[@]}"; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$IP/" --max-time 10 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" == "200" ]; then
        echo "✅ Application is accessible at http://$IP/"
    else
        echo "⚠️ HTTP $HTTP_CODE for $IP"
    fi
done
