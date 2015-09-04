
# AWS linux cluster provisioning with [Terraform](https://www.terraform.io/intro/index.html)
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

## Table of Contents##

- [Overview](#overview)
- [Setup AWS credentials](#setup-aws-credentials)
- [Install tools](#install-tools)
- [Quick start](#quick-start)
- [Customization](#customization)
- [Build multi-node cluster](#build-multi-node-cluster)
- [Manage individual platform resources](#manage-individual-platform-resources)
- [Technical notes](#technical-notes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Overview

This is a practical implementation of multi-node Linux cluster in a vpc built on AWS. 
The Terraform code is based on [aws-coreos-terraform] (https://github.com/xuwang/aws-terraform), but not CoreOS specific. 
The cluster follows 3-tier architecture that contains web tier, apps tier, and database tier.

AWS compoments includes: VPC, IAM, S3, Autoscaling, ELB, Route53, RDS etc. 

The entire infrastructure is managed by [Terraform](https://www.terraform.io/intro/index.html).

## Setup AWS credentials

Go to [AWS Console](https://console.aws.amazon.com/)

1. Create a group `mycluster` with `AdministratorAccess` policy.
2. Create a user `mycluster` and __Download__ the user credentials.
3. Add user `mycluster` to group `mycluster`.

## Install tools

If you use [Vagrant](https://www.vagrantup.com/), you can skip this section and go to 
[Quick Start](#quick-start) section.

Instructions for install tools on MacOS:

1. Install [Terraform](http://www.terraform.io/downloads.html)

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

1. Install [AWS CLI](https://github.com/aws/aws-cli)
    ```
    $ brew install awscli
    ```
    or

    ```
    $ sudo easy_install pip
    $ sudo pip install --upgrade awscli
    ```

For other platforms, follow the tool links and instructions on tool sites.

## Quick start

#### Clone the repo:
```
$ git clone git@github.com:xuwang/aws-linux-cluster.git
$ cd aws-lunix-cluster
```

#### Run Vagrant ubuntu box with terraform installed (Optional)
If you use Vagrant, instead of install tools on your host machine,
there is Vagranetfile for a Ubuntu box with all the necessary tools installed:
```
$ vagrant up
$ vagrant ssh
$ cd aws-lunix-cluster
```

#### Configure AWS profile with `mycluster` credentials

```
$ aws configure --profile mycluster
```
Use the [downloaded aws user credentials](#setup-aws-credentials)
when prompted.


#### To build:

This default build will create one web node and app node cluster in a VPC, 
with application buckets for data, necessary iam roles, polices, keypairs and keys. 
The instance type for the nodes is t2.micro. 
The default image is he default image is Red Hat Enterprise Linux 7. 
You can review the configuration and make changes if needed. 
See [Customization](#customization) for details.


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

#### Destroy all resources

```
$ make destroy_all
```
This will destroy ALL resources created by this project.

## Customization

* The default values for VPC, ec2 instance profile, policies, keys, autoscaling group, lanuch configurations etc., 
can be override in resources/terraform/module-<resource>.tf` files.

* AWS profile and cluster name are defined at the top of  _Makefile_:

  ```
  AWS_PROFILE := mycluster
  CLUSTER_NAME := mycluster
  ```
  
  These can also be customized to match your AWS profile and cluster name.


* The defualt AMI is Red Hat Enterprise Linux 7.1. The AMI ID is generated with parameters defined in Makefile:

  ```
  # For get-ami.sh
  AMI_NAME_PREFIX := RHEL-7.1
  VM_TYPE := hvm
  ```
  It can also be overriden in module-web.tf and module-app.tf.

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

## Manage individual platform resources

You can create individual resources and the automated-scripts will create resources automatically based on dependencies. 
```
$ make help

Usage: make (<resource> | destroy_<resource> | plan_<resource> | refresh_<resource> | show | graph )
Available resources: vpc s3 route53 web app rds
For example: make plan_app  # to show what resources are planned for app
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

To build the cluster step by step:

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

## Technical notes
* AWS resources are defined in resources and modules directories. 
The build process will copy all resource files from _resources_ to a _build_ directory. 
The terraform actions are performed under _build_, which is ignored in .gitignore,
keeping the original Terraform files in the repo intact.
* Makefiles and shell scripts are used to give us more flexibilities on tasks Terraform 
leftover. This provides stream-lined build automation. 
* All nodes can have a customized cloud-config file for post-boot provisioning.
* Terraform auto-generated launch configuration name and CBD feature is used 
to allow launch configuration update on a live autoscaling group, 
however, running ec2 instances in the autoscaling group has to be recycled outside of Terraform management to pick up new LC.
* For a production system, the security groups defined in web and app module 
should be carefully reviewed and tightened.

