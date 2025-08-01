#!/bin/bash
/etc/eks/bootstrap.sh ${cluster_name} --apiserver-endpoint ${cluster_endpoint} --b64-cluster-ca ${cluster_ca_data} --container-runtime containerd --use-max-pod false
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCEID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id)
UNIQUEID=$(openssl rand -hex 2)
INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCEID" "Name=key,Values=Name" --query "Tags[0].Value" --output text)
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')
aws ec2 modify-instance-attribute --instance-id $INSTANCEID --no-source-dest-check --region $REGION
aws ec2 create-tags --resources $INSTANCEID --tags Key=Name,Value="$INSTANCE_NAME-$UNIQUEID" --region $REGION
systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent