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
