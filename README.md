# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
Prior to running through the steps, open a Terminal & run: az login
1) Create a resource group (rg) that your Packer Image will be a part of
2) You'll use this rg name & its location within the Packer server.json file
Note - You'll want to make sure that when you get to the point of running the TF code that you are creating
       your resources in the same location as your Packer iamge
3) Next, collect the Client ID, Client Secret & Subscription ID and overwrite the FIXME values in the server.json file. 
Note - These are considered sensitive information & should not be committed to a private/public repo. 
4) Re-open your terminal & run: packer build <location to to your server.json file>
5) If all is successful you will find an image file that will be used later when we build out the rest of your infrastructure.
6) Update the values found in the terraform/values.tfvars file to your needs/requirements or leave the values as is
to test out the code & see what gets created. Additionally, you can review the terraform/variables.tf file which
provide a description for each variable. 
7) Re-open your terminal. (Ensure you are in the directory where the tf code is present)
8) run: terraform init
9) run: terraform validate
10) run: terraform apply -var-file=values.tfvars
11) If the TF validation is successful, TF will prompt you asking if you want to proceed. Type "yes" & [enter]
12) Allow TF to execute the code
13) When TF is finished you should see an "Apply complete!" message

### Output
So the TF code ran successful! WooHoo! Now its time to access your Azure portal via a browswer & check out the
udacity--resources resource group. You should see:
- Network Security Group (NSG) & NGS1 that created specific rules
- A load balancer
- A Public IP for the LB
- A Network & Subnets
- A NIC for the VM(s)
- A VMSS (Virutal Machine Scal Set)

Note - Don't forget to run: terraform destroy -var-file=values.tfvars after you are done reviewing the items
provisioned for you. 

