echo "Get cf name"
cf_name=$(aws autoscaling describe-auto-scaling-groups |grep LaunchTemplateName |awk '{print $2}' |tr -d '",' |uniq)
echo "$cf_name"

echo "Get role name"
role_name=$(aws cloudformation describe-stack-resources --stack-name $cf_name --logical-resource-id NodeInstanceRole |grep Physical |awk '{print $2}' |tr -d '",')
echo "$role_name"

echo "Get load_balancer)iam role arn"
load_balancer_iam=`aws iam list-attached-role-policies --role-name $role_name |grep Arn | grep load-balancer-iam |awk '{print $2}' |tr -d '"'`

echo "Remove policies from role $role_name"
attach_role=$(aws iam detach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy)
attach_role=$(aws iam detach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess)
attach_role=$(aws iam detach-role-policy --role-name $role_name --policy-arn $load_balancer_iam)
