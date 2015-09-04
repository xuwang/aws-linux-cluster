###################
## Customization ##
###################
# Profile/Cluster name
AWS_PROFILE := mycluster
CLUSTER_NAME := mycluster
# To prevent you mistakenly using a wrong account (and end up destroying live environment),
# a list of allowed AWS account IDs should be defined:
#ALLOWED_ACCOUNT_IDS := "123456789012","012345678901"

# For get-ami.sh
AMI_NAME_PREFIX := RHEL-7.1
VM_TYPE := hvm
AMI_VARS=$(BUILD)/ami.tf

# For substitude-AWS-ACCOUNT.sh. Default to AWS account number.
#S3_BUCKET_PREFIX=

# Working Directories
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SCRIPTS := $(ROOT_DIR)scripts
MODULES := $(ROOT_DIR)modules
RESOURCES := $(ROOT_DIR)resources
TF_RESOURCES := $(RESOURCES)/terraforms
BUILD := $(ROOT_DIR)build
CONFIG := $(BUILD)/cloud-config
CERTS := $(BUILD)/certs
SITE_CERT := $(CERTS)/site.pem
POLICIES := $(BUILD)/policies
TF_VARS=$(BUILD)/variables.tf

# Terraform files
TF_PORVIDER := $(BUILD)/provider.tf
TF_DESTROY_PLAN := $(BUILD)/destroy.tfplan
TF_APPLY_PLAN := $(BUILD)/destroy.tfplan
TF_STATE := $(BUILD)/terraform.tfstate

# Terraform commands
TF_GET := terraform get -update
TF_SHOW := terraform show -module-depth=1
TF_GRAPH := terraform graph -draw-cycles -verbose
TF_PLAN := terraform plan -module-depth=1
TF_APPLY := terraform apply
TF_REFRESH := terraform refresh
TF_DESTROY := terraform destroy -force
##########################
## End of customization ##
##########################

export

all: web

help:
	@echo "Usage: make (<resource> | destroy_<resource> | plan_<resource> | refresh_<resource> | show | graph )"
	@echo "Available resources: vpc s3 route53 iam elb web app rds"
	@echo "For example: make app"

destroy: 
	@echo "Usage: make destroy_<resource>"
	@echo "For example: make destroy_web"
	@echo "Node: destroy may fail because of outstanding dependences"

destroy_all: \
	destroy_app \
	destroy_web \
	destroy_iam \
	destroy_s3 \
	destroy_vpc

clean_all: destroy_all
	rm -f $(BUILD)/*.tf 
	#rm -f $(BUILD)/terraform.tfstate

# TODO: Push/Pull terraform states from a tf state repo
pull_tf_state:
	@mkdir -p $(BUILD)
	@echo pull terraform state from ....

push_tf_state:
	@echo push terraform state to ....

# Load all resouces makefile
include resources/makefiles/*.mk

.PHONY: all destroy destroy_all clean_all help pull_tf_state push_tf_state
