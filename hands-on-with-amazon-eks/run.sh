#!/bin/sh

echo "Creating the cluster..."
cd Infrastructure/eksctl/01-initial-cluster
eksctl create cluster -f cluster.yaml

echo "Configuring the load balancer..."
cd ../../k8s-tooling/load-balancer-controller
./create.sh

echo "Deploy sample app..."
cd test
./run.sh

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


