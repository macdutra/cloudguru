#!/bin/sh

internal_api=(clients-api inventory-api renting-api resource-api)
front_internal_api=(clients-api inventory-api renting-api resource-api front-end)
aws_export=(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION)
k8s_services=(load-balancer-controller external-dns cni)

for i in "${aws_export[@]}"; do
  echo "Verifying the variables $i..."
  test_export=`declare -p $i`
  if [ -z "$test_export" ]; then
    echo "variable $i is unset - please export the variables $aws_export"
    exit 0
  else
    echo "Variable $i is exported"
  fi
done

echo "Creating the cluster..."
cd Infrastructure/eksctl/01-initial-cluster
eksctl create cluster -f cluster.yaml

echo "Creating certificate..."
cd ../../cloudformation/ssl-certificate
./create.sh

echo "Configuring the load balancer..."
cd ../../k8s-tooling/load-balancer-controller
./create.sh

#echo "Deploy sample app..."
#cd test
#./run.sh

echo "Deploy ssl app..."
cd test
./run-with-ssl.sh

echo "Install external dns..."
cd ../../external-dns
./create.sh

for i in "${internal_api[@]}"; do
  echo "$Creating table $i"
  cd ../../../$i/infra/cloudformation
  ./create-dynamodb-table.sh development
done

echo "Add dynamodb permission to nodes..."
cd ../../../marcos_scripts
./dynamodb_permission.sh
cd ..

for i in "${front_internal_api[@]}"; do
  echo "Creating $i helm..."
  cd $i/infra/helm
  ./create.sh
  cd ../../../
done

echo "Setup second CIDR on VPC..."
cd Infrastructure/k8s-tooling/cni
./setup.sh
cd helm
./create.sh

echo "Removing ec2 from cluster..."
nodes=($(kubectl get nodes |awk '{print $1}' |grep -v NAME))
for i in "${nodes[@]}"; do
  echo "Terminating instance $i..."
  kubectl cordon $i
  kubectl drain $i --ignore-daemonsets --force --grace-period=30 --delete-emptydir-data
  terminate=$(kubectl get node $i -o jsonpath={.spec.providerID}|tr "/" " " |awk '{print $3}')
  aws ec2 terminate-instances --instance-ids $terminate; sleep 200
done

echo "Associate OIDC in kubernetes..."
eksctl utils associate-iam-oidc-provider --cluster=eks-acg --approve

echo "Detach role instance..."
cd ../../../../marcos_scripts
./remove_dynamodb_permission.sh
cd ..
echo "Creating IAM policies..."

for i in "${internal_api[@]}"; do
  echo "$i..."
  cd $i/infra/cloudformation
  ./create-iam-policy.sh
  policy=$(aws cloudformation describe-stack-resources --stack-name development-iam-policy-$i --logical-resource-id IamPolicy|grep Physical |awk '{print $2}' |tr -d '",')
  eksctl create iamserviceaccount --name $i-iam-service-account --namespace development --cluster eks-acg --attach-policy-arn $policy --approve
  cd ../helm-v2
  ./create.sh
  cd ../../../
done
 
#Remove the policies:
#load_balancer_iam - Route53FullAccess - EKS_CNI_Policy
cd marcos_scripts
./remove_node_policies.sh
cd ..

#Creating a Service account(IRSA) for load balancer/external-dns/cni
for i in "${k8s_services[@]}"; do
  cd Infrastructure/k8s-tooling/$i
  if [ "$i" = "external-dns" ]; then
    echo "Verifying and uninstalling helm controller $i"
    helm ls
    helm delete external-dns
  elif [ "$i" = "load-balancer-controller" ]; then
    echo "Verifying and uninstalling helm controller $i"
    helm ls -n kube-system
    helm delete -n kube-system aws-load-balancer-controller
  fi
  echo "Creating $i service"
  ./create-irsa.sh
  cd ../../../
done



