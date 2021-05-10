# aws-emr-template-repository

## A template repository for building EMR cluster in AWS

This repo contains Makefile and base terraform folders and jinja2 files to fit the standard pattern.
This repo is a base to create new Terraform repos, renaming the template files and adding the githooks submodule, making the repo ready for use.

Running aviator will create the pipeline required on the AWS-Concourse instance, in order pass a mandatory CI ran status check.  this will likely require you to login to Concourse, if you haven't already.

After cloning this repo, please generate `terraform.tf` and `terraform.tfvars` files:  
`make bootstrap`

In addition, you may want to do the following: 

1. Create non-default Terraform workspaces as and if required:  
    `make terraform-workspace-new workspace=<workspace_name>` e.g.  
    ```make terraform-workspace-new workspace=qa```

1. Configure Concourse CI pipeline:
    1. Add/remove jobs in `./ci/jobs` as required 
    1. Create CI pipeline:  
`aviator`

## Networking

Before you are able to deploy your EMR cluster, the new service will need the networking for it configured.   

[An example](https://git.ucd.gpn.gov.uk/dip/aws-internal-compute/blob/master/clive_network.tf) of this can be seen in the `internal-compute` VPC where a lot of our EMR clusters are deployed. 

If you are creating the subnets in a different repository, remember to output the address as seen [here](https://git.ucd.gpn.gov.uk/dip/aws-internal-compute/blob/master/outputs.tf#L47-L53)


## Optional Features

`data.tf.OPTIONAL` can be used if your product requires writing data to the published S3 bucket.
