echo "Get cf name"
cf_name=$(aws autoscaling describe-auto-scaling-groups |grep LaunchTemplateName |awk '{print $2}' |tr -d '",' |uniq)
echo "$cf_name"

echo "Get role name"
role_name=$(aws cloudformation describe-stack-resources --stack-name $cf_name --logical-resource-id NodeInstanceRole |grep Physical |awk '{print $2}' |tr -d '",')
echo "$role_name"

#echo "Get Policy arn"
#policy_arn=$(aws cloudformation describe-stack-resources --stack-name aws-load-balancer-iam-policy --logical-resource-id iamPolicy |grep Physical |awk '{print $2}' |tr -d '",')
echo "$policy_arn"

echo "Attach policy to role"
attach_role=$(aws iam detach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess)
