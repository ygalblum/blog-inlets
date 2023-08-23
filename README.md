# Expose your podman kube based quadlet with Inlets

## Provision your cloud infrastructure

The example provisions resources for both the server and client on AWS

### Route53 hosted zone

For this demo you will need to have a pre-existing hosted zone on AWS route 53

### Run Terraform

```bash
cd terraform
terraform apply -var route53_zone_name=< The name of your route53 hosted zone >
```

### Terraform outputs
The process will produce two outputs you will need in the next step
1. Inlets server FQDN
    ```bash
    terraform output -raw server_url
    ```
2. `inventory.yml` file for the Ansible deployment

### Troubleshooting your server

As part of the provisioning process, terraform creates a key pair to allow you to connect to your server.
Terraform will then store the private key `inlets.pem` in the terraform directory.
The same key is used by Ansible

## Deploy the Inlets client and server

Once all cloud resources are provisioned use Ansible to deploy inlets.

### Mandatory parameters
The Ansible playbook requires the `inlets_license` variable. Create a `values.yml` file:

```yaml
inlets_license: < Inlets License string>
```

### Run Ansible

```bash
cd ansible
ansible-playbook -i ../terraform/inventory.yml -e @values.yml playbook.yml
```

## Browse to your inlets server
https://< server_url >