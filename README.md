# GitOps on Amazon EKS

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.61.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_build"></a> [build](#module\_build) | ./modules/build | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |
| <a name="module_delivery"></a> [delivery](#module\_delivery) | ./modules/delivery | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_admin_password"></a> [argocd\_admin\_password](#input\_argocd\_admin\_password) | ArgoCD Admin password | `string` | n/a | yes |
| <a name="input_codestar_connection_arn"></a> [codestar\_connection\_arn](#input\_codestar\_connection\_arn) | CodeStar Connection ARN | `string` | n/a | yes |
| <a name="input_my_cidr_range"></a> [my\_cidr\_range](#input\_my\_cidr\_range) | Network range for cluster administration | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for resources | `string` | `"EKS-GitOps"` | no |
| <a name="input_repository_branch"></a> [repository\_branch](#input\_repository\_branch) | Repository branch to build and deploy | `string` | n/a | yes |
| <a name="input_repository_key"></a> [repository\_key](#input\_repository\_key) | Repository SSH key file path | `string` | n/a | yes |
| <a name="input_repository_url"></a> [repository\_url](#input\_repository\_url) | Repository URl to build and deploy | `string` | n/a | yes |
| <a name="input_secrets_key"></a> [secrets\_key](#input\_secrets\_key) | AWS KMS key for encrypting Kubernetes secrets | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca"></a> [cluster\_ca](#output\_cluster\_ca) | n/a |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
