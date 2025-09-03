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

1- Directory [here](Infrastructure/eksctl/01-initial-cluster) file cluster.yaml

```eksctl create cluster -f cluster.yaml```

2- Configure application LoadBalancer [here](Infrastructure/k8s-tooling/load-balancer-controller) file create.sh

```./create.sh```

```
After creation, there is one more step, attach iam-policy to the nodes that was created by cloudformation via create.sh. I automated the iam policy attachment via create.sh.

Name of IAM Policy: cloudformation -> stacks -> aws-load-balancer-iam-policy -> outputs -> value arn.

Attach policy: cloudformation -> stacks -> eksctl-eks-acg-nodegroup-eks-node-group - resources -> NodeInstanceRole -> PhysicalID (role)

On role: Attach the name of policy.
```

3- Test [here](Infrastructure/k8s-tooling/load-balancer-controller/test) file run.sh - Deploy sample app via helm chat and creating loadbacing for the app.

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

4- Create SSL certificate [here](Infrastructure/cloudformation/ssl-certificate) file create.sh - Verify domain in route53 and create the ssl certificate in AWS ACM.

```./create.sh```

5- Test ssl [here](Infrastructure/k8s-tooling/load-balancer-controller/test) file run-with-ssl.sh - Deploy sample app via helm chart with ssl and update loadbalancer to open port 443 SSL and redirect port 80 to 443.

```./run-with-ssl.sh```

6- Install external dns [here](Infrastructure/k8s-tooling/external-dns) file create.sh via helm.

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

7- Create dynamodb tables for bookstore app.

7.1- clients-api dynamodb [here](clients-api/infra/cloudformation)

```./create-dynamodb-table.sh development```

7.2- inventory-api dynamodb [here](inventory-api/infra/cloudformation)

```./create-dynamodb-table.sh development```

7.3- renting-api dynamodb [here](renting-api/infra/cloudformation)

```./create-dynamodb-table.sh development```

7.4- resource-api dynamodb [here](resource-api/infra/cloudformation)

```./create-dynamodb-table.sh development```

After creation, I need to put dynamodb permission on worker nodes. The tutorial added dynamodb full access, I don't like this, I will change it after.

7.5- dynamodb permission [here](marcos_scripts)

```./dynamodb_permission.sh``` 

8- Install helm for bookstore app

8.1- clients-api helm [here](clients-api/infra/helm)

```./create.sh``` 

8.2- inventory-api helm [here](inventory-api/infra/helm)

```./create.sh``` 

8.3- renting-api helm [here](renting-api/infra/helm)

```./create.sh``` 

8.4- resource-api helm [here](resource-api/infra/helm)

```./create.sh``` 

8.5- front-end helm [here](front-end/infra/helm)

```./create.sh``` 
