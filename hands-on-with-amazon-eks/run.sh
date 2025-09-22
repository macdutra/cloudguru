#!/bin/sh

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
./run-with-ssl.sh

echo "Install external dns..."
cd ../../external-dns
./create.sh

echo "Creating dynamodb tables..."
cd ../../../clients-api/infra/cloudformation
echo "clients-api table..."
./create-dynamodb-table.sh development
cd ../../../inventory-api/infra/cloudformation
echo "inventory-api table..."
./create-dynamodb-table.sh development
cd ../../../renting-api/infra/cloudformation
echo "renting-api table..."
./create-dynamodb-table.sh development
cd ../../../resource-api/infra/cloudformation
echo "resource-api table..."
./create-dynamodb-table.sh development

echo "Add dynamodb permission to nodes..."
cd ../../../marcos_scripts
./dynamodb_permission.sh

echo "Installing helm..."
cd ../clients-api/infra/helm
echo "clients-api helm..."
./create.sh
cd ../../../inventory-api/infra/helm
echo "inventory-api helm..."
./create.sh
cd ../../../renting-api/infra/helm
echo "renting-api helm..."
./create.sh
cd ../../../resource-api/infra/helm
echo "resource-api helm..."
./create.sh
cd ../../../front-end/infra/helm
echo "front-end helm..."
./create.sh

echo "Setup second CIDR on VPC..."
cd ../../../Infrastructure/k8s-tooling/cni
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

echo "Creating IAM policies..."
echo "clients-api..."
cd ../clients-api/infra/cloudformation
./create-iam-policy.sh
policy=$(aws cloudformation describe-stack-resources --stack-name development-iam-policy-clients-api --logical-resource-id IamPolicy|grep Physical |awk '{print $2}' |tr -d '",')
eksctl create iamserviceaccount --name clients-api-iam-service-account --namespace development --cluster eks-acg --attach-policy-arn $policy --approve
cd ../helm-v2
./create.sh
