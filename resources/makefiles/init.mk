show: | $(BUILD)
	cd $(BUILD); $(TF_SHOW)

show_state: init
	cat $(BUILD)/terraform.tfstate

graph: | $(BUILD)
	cd $(BUILD); $(TF_GRAPH)

refresh: init
	cd $(BUILD); $(TF_REFRESH)

init: | check-profile $(TF_PROVIDER) $(AMI_VARS)
	cd $(BUILD); $(TF_INIT)

$(BUILD): init_build_dir

$(TF_PROVIDER): update_provider

$(AMI_VARS): update_ami

$(SITE_CERT): gen_certs

.PHONY: check-profile
check-profile: ## validate AWS profile
	@if ! aws --profile ${AWS_PROFILE} sts get-caller-identity --output text --query 'Account'> /dev/null 2>&1 ; then \
                echo "ERROR: AWS profile \"${AWS_PROFILE}\" is not setup!"; \
                exit 1 ; \
        fi

update_provider: | $(BUILD)
	# Generate tf provider
	$(SCRIPTS)/gen-provider.sh > $(TF_PROVIDER)

update_ami:	| $(BUILD)
	# Generate default AMI ids
	$(SCRIPTS)/get-ami.sh > $(AMI_VARS)

init_build_dir:
	@mkdir -p $(BUILD)
	@cp -rf $(RESOURCES)/cloud-config $(BUILD)
	@cp -rf $(RESOURCES)/policies $(BUILD)
	@$(SCRIPTS)/substitute-S3-BUCKET-PREFIX.sh $(POLICIES)/*.json
	@$(SCRIPTS)/substitute-CLUSTER-NAME.sh $(CONFIG)/*.yaml $(POLICIES)/*.json

gen_certs: $(BUILD)
	@cp -rf $(RESOURCES)/certs $(BUILD)
	@if [ ! -f "$(SITE_CERT)" ] ; \
	then \
		$(MAKE) -C $(CERTS) ; \
	fi

clean_certs:
	rm -f $(CERTS)/*.pem
	
.PHONY: init show show_state graph refresh update_provider init_build_dir
.PHONY: gen_certs clean_certs
