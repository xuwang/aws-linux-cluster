
# AWS linux cluster provisioning with [Terraform](http://www.terraform.io/downloads.html)
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

##Table of Contents##

- [Overview](#overview)
- [Setup AWS credentials](#setup-aws-credentials)
- [Install tools](#install-tools)
- [Quick start](#quick-start)
- [Build multi-node cluster](#build-multi-node-cluster)
- [Destroy all resources](#destroy-all-resources)
- [Manage individual platform resources](#manage-individual-platform-resources)
- [Use an existing AWS profile](#use-an-existing-aws-profile)
- [Technical notes](#technical-notes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Overview

This is a practical implementation of multi-nodes linux cluster in a vpc built on AWS. The cluster follows 3-tiers architecture that contains web tier, apps tier, and database tier. 

The entire infrastructure is managed by Terraform. 

AWS compoments includes: VPC, security groups, IAM, S3, ELB, Route53, Autoscaling, RDS etc. 

AWS resources are defined in Terraform resource folders. The build process will copy all resources defined in the repository to a *build* directory. The view, plan, apply, and destroy operations are performed under *build*, keepting the original Terraform files in the repo intact. The *build* directory is ignored in .gitignore so that you don't accidentally checkin sensitive data. 

## Setup AWS credentials

1. Install AWS CLI
    ```
    $ brew install awscli
    ```
    or

    ```
    $ sudo easy_install pip
    $ sudo pip install --upgrade awscli
    ```

1. Setup AWS Credentials at [AWS Console](https://console.aws.amazon.com/)
    1. Create a group `mycluster` with `AdministratorAccess` policy.
    2. Create a user `mycluster` and download user credentials.
    3. Add user `mycluster` to group `mycluster`.

1. Configure AWS profile with `mycluster` credentials
    ```
    $ aws configure --profile mycluster
    ```
## Install tools

If you use Vagrant, skip this and go to [Quick Start](https://github.com/xuwang/aws-linux-cluster/blob/master/README.md#quick-start) section.

1. Install [Terraform](http://www.terraform.io/downloads.html)

    For MacOS,
    ```
    $ brew update
    $ brew install terraform
    ```
    or
    ```
    $ mkdir -p ~/bin/terraform
    $ cd ~/bin/terraform
    $ curl -L -O https://dl.bintray.com/mitchellh/terraform/terraform_0.6.0_darwin_amd64.zip
    $ unzip terraform_0.6.0_darwin_amd64.zip
    ```

1. Install [Jq](http://stedolan.github.io/jq/)
    ```
    $ brew install jq
    ```

## Quick start

This default build will create one web node and one app node cluster in a VPC, with application buckets for data, necessary iam roles, polices, keypairs and keys. The instance type for the nodes is t2.micro, the default image is he default image is Red Hat Enterprise Linux 7. 

Resources are defined under aws-terraform/resources/terraform directory. You should review and make changes there if needed.

Clone the repo:
```
$ git clone git@github.com:xuwang/aws-linux-cluster.git
$ cd aws-lunix-cluster
```
Under aws-lunix-cluster directory, we provide a Vagrant Ubuntu virtual box that has awscli, jq, s3cmd, git, and terraform installed. If you use Vagrant, run the following and continue to 
```
$ vagrant up
$ vagrant ssh
$ cd aws-lunix-cluster
```

Customization parameters:

The default values for VPC, subnets,  servers instance profile, policies, keys, autoscaling group, lanuch configurations etc., are defined under modules directory. To change the default values, go to resources/terraform directory and change the variable values in `module-<resource>.tf` .

To build:
```
$ make
... build steps info ...
... at last, shows the web node's ip:
web public ips: 52.27.156.202
...
```

To see the list of resources created:

```
$ make show
...
module.web.aws_autoscaling_group.web:
  id = web
  availability_zones.# = 3
  availability_zones.2050015877 = us-west-2c
  availability_zones.221770259 = us-west-2b
  availability_zones.2487133097 = us-west-2a
  default_cooldown = 300
  desired_capacity = 1
  force_delete = true
  health_check_grace_period = 0
  health_check_type = EC2
  launch_configuration = terraform-nozcu25oobfixd5nzmrxw3itze
  load_balancers.# = 0
  max_size = 9
  min_size = 1
  name = web
  tag.# = 1
  tags.Name = web
  vpc_id = vpc-987403fd
....
```

Login to the web node:

```
$ ssh -A ec2-user@52.27.156.202


```
## Build multi-node cluster

The number of web and app servers are defined in *resource/terraform/module-web.tf* and *resource/terraform/module-apps.tf*

Change the cluster_desired_capacity in the file to build multi-nodes web/app cluster,
for example, change to 3:

```
    cluster_desired_capacity = 3
```

You should also change the [aws_instance_type](http://aws.amazon.com/ec2/instance-types) 
from `micro` to `medium` or `large` if more powerful machines are desired:

```
    image_type = "t2.medium"
    root_volume_size =  12
    docker_volume_size =  120
```

To build:
```
$ make all
... build steps info ...
... at last, shows the web nodes' ip:
web public ips:  52.26.32.57 52.10.147.7 52.27.156.202
...
```


## Destroy all resources

```
$ make destroy_all
```
This will destroy ALL resources created by this project.

## Manage individual platform resources

You can create individual resources and the automated-scripts will create resources automatically based on dependencies. 
```
$ make help

Usage: make (<resource> | destroy_<resource> | plan_<resource> | refresh_<resource> | show | graph )
Available resources: vpc s3 route53 web app rds
For example: make app
```

Currently defined resources:
  
Resource | Description
--- | ---
*vpc* | VPC, gateway, and subnets
*s3* | S3 buckets
*iam* | Setup a deployment user and deployment keys
*route53* | Setup public and private hosted zones on Route53 DNS service
*elb* | Setup application ELBs
*web* | Setup application docker hosting cluster
*app* | Central service cluster (Jenkins, fleet-ui, monitoring, logging, etc)
*rds* | RDS servers
*cloudtrail* | Setup AWS CloudTrail

To build the cluster step by step by step:

```
$ make init
$ make vpc
$ make app
$ make web
```

Make commands can be re-run. If a resource already exists, it just refreshes the terraform status.

This will create a build/<resource> directory, copy all terraform files to the build dir, 
and execute correspondent terraform cmd to build the resource on AWS.

To destroy a resource:

```
$ make destroy_<resource> 
```

### Use an existing AWS profile
AWS profile, user, and cluster name are defined at the top of  _Makefile_:

```
# Profile/Cluster name
AWS_PROFILE := mycluster
AWS_USER := mycluster
CLUSTER_NAME := mycluster
```
These can be changed to match your AWS profile and cluster name.

## Technical notes
* Makefiles define resource dependencies and use scripts to generate necessart Terraform 
variables and configurations. 
This provides stream-lined build automation. 
* All nodes use a common bootstrap shell script as user-data which can be customized to do post-boot provisioning.
* The defualt AMI is defined in resources/terraform/variables.tf. It can be overriden in module-web.tf and module-app.tf.
*Terraform auto-generated launch configuration name and CBD feature is used 
to allow change of launch configuration on a live autoscaling group, e.g. ami id, image type, cluster size, etc.
However, exisiting ec2 instances in the autoscaling group has to be recycled to pick up new LC, e.g. 
terminate instance to let AWS create a new instance.

