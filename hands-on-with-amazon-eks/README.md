# Hands-on with Amazon EKS!

In this repository you will find all the assets required for the course `Hands On With Amazon EKS`, by A Cloud Guru, a Pluralsight Company.


## Bookstore application

This solution has been built for for explaining all the concepts in this course. It is complete enough for covering a real case of microservices running on EKS and integrating with other AWS Services.

> You can find in [here](_docs/api.md) the documentation of the APIs.


## Terraform

I started to use terraform as IAC for my environments. Enjoy!! :)

> You can find in [here](terraform) terraform directory files.

Change bootstrap-terraform directory

Change terraform files

Initializing kubectl on EKS:

aws eks update-kubeconfig --name cluster-name --region us-east-1

kubectl -n kube-system get configmap aws-auth -o yaml
