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
```
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_REGION
```

1.1- Directory [here](Infrastructure/eksctl/01-initial-cluster) file cluster.yaml

```eksctl create cluster -f cluster.yaml```

2.1- Configure application LoadBalancer [here](Infrastructure/k8s-tooling/load-balancer-controller) file create.sh

```./create.sh```

```
After creation, there is one more step, attach iam-policy to the nodes that was created by cloudformation via create.sh. I automated the iam policy attachment via create.sh.

Name of IAM Policy: cloudformation -> stacks -> aws-load-balancer-iam-policy -> outputs -> value arn.

Attach policy: cloudformation -> stacks -> eksctl-eks-acg-nodegroup-eks-node-group - resources -> NodeInstanceRole -> PhysicalID (role)

On role: Attach the name of policy.
```

2.2- Test [here](Infrastructure/k8s-tooling/load-balancer-controller/test) file run.sh - Deploy sample app via helm chat and creating loadbacing for the app.

```./run.sh```

I fixed the annotation file templates/ingress.yaml
```  
annotations:
    {{- if semverCompare "<1.18-0" .Capabilities.KubeVersion.GitVersion }}
    # For backwards compatibility with pre-1.18 clusters
    kubernetes.io/ingress.class: alb
    {{- end }}

spec:
  {{- if semverCompare ">=1.18-0" .Capabilities.KubeVersion.GitVersion }}
  ingressClassName: alb
  {{- end }}
```
  
I fixed ALB iam policy [here](Infrastructure/k8s-tooling/load-balancer-controller) file iam-policy.yaml

Add - elasticloadbalancing:DescribeListenerAttributes

2.3- Create SSL certificate [here](Infrastructure/cloudformation/ssl-certificate) file create.sh - Verify domain in route53 and create the ssl certificate in AWS ACM.

```./create.sh```

2.4- Test ssl [here](Infrastructure/k8s-tooling/load-balancer-controller/test) file run-with-ssl.sh - Deploy sample app via helm chart with ssl and update loadbalancer to open port 443 SSL and redirect port 80 to 443.

```./run-with-ssl.sh```

2.5- Install external dns [here](Infrastructure/k8s-tooling/external-dns) file create.sh via helm.

```./create.sh``` 

Add route53fullaccess to this policy cloudformation -> stacks -> eksctl-eks-acg-nodegroup-eks-node-group - resources -> NodeInstanceRole -> PhysicalID (role)

Delete the record to the load balancer.

Delete the pod externaldns
```
kubectl get pods
kubectl delete pod externaldns_name
``` 

After pod recreation automatically externaldns recreate the record on route53.

*Problem*

I create values.yaml to create a aws default region.

2.6- Create dynamodb tables for bookstore app.

2.6.1- clients-api dynamodb [here](clients-api/infra/cloudformation)

```./create-dynamodb-table.sh development```

2.6.2- inventory-api dynamodb [here](inventory-api/infra/cloudformation)

```./create-dynamodb-table.sh development```

2.6.3- renting-api dynamodb [here](renting-api/infra/cloudformation)

```./create-dynamodb-table.sh development```

2.6.4- resource-api dynamodb [here](resource-api/infra/cloudformation)

```./create-dynamodb-table.sh development```

After creation, I need to put dynamodb permission on worker nodes. The tutorial added dynamodb full access, I don't like this, I will change it after.

2.7- dynamodb permission [here](marcos_scripts)

```./dynamodb_permission.sh``` 

Test the bookstore frontend.

```
kubectl get ingress -A

Verify the endpoint with ping.
Verify route53 entry
Verify externaldns - kubectl get pods
Verify logs - kubectl logs external-dns-serviceID
```

2.8- Install helm for bookstore app

2.8.1- clients-api helm [here](clients-api/infra/helm)

```./create.sh``` 

2.8.2- inventory-api helm [here](inventory-api/infra/helm)

```./create.sh``` 

2.8.3- renting-api helm [here](renting-api/infra/helm)

```./create.sh``` 

2.8.4- resource-api helm [here](resource-api/infra/helm)

```./create.sh``` 

2.8.5- front-end helm [here](front-end/infra/helm)

```./create.sh``` 

2.9- Setup second CIDR on VPC using CNI [here](Infrastructure/k8s-tooling/cni)

```./setup.sh```

cd helm

```create.sh```

After that, I need to delete the ec2 instances to get the new configuration:

```
kubectl get nodes
kubectl cordon ip-10-0-125-13.ec2.internal
kubectl drain ip-10-0-125-13.ec2.internal \
  --ignore-daemonsets \
  --force \
  --grace-period=30 \
  --delete-emptydir-data
```

Delete the instance in aws ec2 console.

3.1- Associate OIDC in Kubernetes

```eksctl utils associate-iam-oidc-provider --cluster=eks-acg --approve```

3.2- Create IAM policy

3.2.1- clients-api policy [here](clients-api/infra/cloudformation)

```
./create-iam-policy.sh
cd ../helm-v2
./create.sh

```

3.2.2- inventory-api policy [here](inventory-api/infra/cloudformation)

```
./create-iam-policy.sh
cd ../helm-v2
./create.sh

```

3.2.3- renting-api policy [here](renting-api/infra/cloudformation)

```
./create-iam-policy.sh
cd ../helm-v2
./create.sh

```

3.2.4- resource-api policy [here](resource-api/infra/cloudformation)

```
./create-iam-policy.sh
cd ../helm-v2
./create.sh

```

3.3- IRSA for load balancers/external-dns/CNI
3.3.1- Remove roles from eks nodes
```
Add route53fullaccess to this policy cloudformation -> stacks -> eksctl-eks-acg-nodegroup-eks-node-group - resources -> NodeInstanceRole -> PhysicalID (role)
Remove the policies: load_balancer_iam - Route53FullAccess - EKS_CNI_Policy
```

3.3.2- Creating IRSA for load balancer [here](Infrastructure/k8s-tooling/load-balancer-controller)
```
helm ls -n kube-system
helm delete -n kube-system aws-load-balancer-controller
./create-irsa.sh
Verify the pod
kubectl get pod -n kube-system (Get aws-load-balancer-controller name)
kubectl describe pod -n kube-system aws-load-balancer-controller
```

3.3.3- Creating IRSA for external-dns [here](Infrastructure/k8s-tooling/external-dns)
```
helm ls
helm delete external-dns
./create-irsa.sh
Verify the pod
kubectl get pod (Get external-dns name)
kubectl describe pod external-dns
```

3.3.4- Creating IRSA for CNI [here](Infrastructure/k8s-tooling/cni)
```
./create-irsa.sh
Verify the nodes
kubectl get pod -n kube-system (Get aws-load-balancer-controller name)
kubectl describe pod -n kube-system aws-load-balancer-controller
```

