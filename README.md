markdown
Copy code
# Terraform AWS EKS Cluster Deployment

This Terraform project deploys an AWS EKS (Elastic Kubernetes Service) cluster along with necessary configurations to deploy the Quivr app using a Helm chart.

## Prerequisites

Before you begin, ensure you have:

- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed.
- An [AWS](https://aws.amazon.com/) account and configured AWS CLI.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed.
- [Helm](https://helm.sh/docs/intro/install/) installed.

## Getting Started

1. Clone this repository:

    ```bash
    git clone <repository_url>
    ```

2. Change into the directory:

    ```bash
    cd terraform-eks-quivr
    ```

3. Initialize Terraform:

    ```bash
    terraform init
    ```

4. Review and edit `main.tf` to configure your AWS region and any other settings if needed.

5. Review and edit `values.yaml` to configure the Helm chart values.

## Deployment

1. Run Terraform to create the EKS cluster:

    ```bash
    terraform apply
    ```

    This will create an EKS cluster along with the necessary resources including VPC, subnets, security group, and node group.

2. After the EKS cluster is created, you will see the kubeconfig and AWS authentication ConfigMap in the Terraform output. Save them to `kubeconfig` and `config_map_aws_auth.yaml` files respectively.

3. Configure `kubectl` to use the newly created EKS cluster:

    ```bash
    cp kubeconfig ~/.kube/config
    ```

4. Apply the AWS authentication ConfigMap:

    ```bash
    kubectl apply -f config_map_aws_auth.yaml
    ```

5. Finally, deploy the Quivr app using Helm:

    ```bash
    terraform apply -target=helm_release.quivr
    ```

## Accessing the Quivr App

Once the deployment is complete, you can access the Quivr app by port-forwarding the service to your localhost:

```bash
kubectl port-forward service/quivr 80:80
```

Then access the Quivr app at http://localhost:80.

Clean Up
To destroy the resources created by Terraform, run:
```bash
terraform destroy
```
