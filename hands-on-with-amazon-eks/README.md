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

## Create Infrastructure with yaml files

This is CloudGuru yaml file 

Don't forget to export AWS variables:
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_REGION

1- Directory [here](Infrastructure/eksctl/01-initial-cluster) file cluster.yaml
eksctl create cluster -f cluster.yaml

2- Configure application LoadBalancer [here](Infrastructure/k8s-tooling/load-balancer-controller) file create.sh
./create.sh

After creation, there is one more step, attach iam-policy to the nodes that was created by cloudformation via create.sh.

Name of IAM Policy: cloudformation -> stacks -> aws-load-balancer-iam-policy -> outputs -> value arn.
Attach policy: cloudformation -> stacks -> eksctl-eks-acg-nodegroup-eks-node-group - resources -> NodeInstanceRole -> PhysicalID (role)
On role: Attach the name of policy.

3- Test [here](Infrastructure/k8s-tooling/load-balancer-controller/test) file run.sh - Create sample app via helm chat and creating loadbacing for the app.
./run.sh

I fixed the annotation file templates/ingress.yaml
  annotations:
    {{- if semverCompare ">=1.18-0" .Capabilities.KubeVersion.GitVersion }}
    # For backwards compatibility with pre-1.18 clusters
    kubernetes.io/ingress.class: alb
    {{- end }}

spec:
  {{- if semverCompare ">=1.18-0" .Capabilities.KubeVersion.GitVersion }}
  ingressClassName: alb
  {{- end }}
  

