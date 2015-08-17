show: | $(BUILD)
	cd $(BUILD); $(TF_SHOW)

show_state: init
	cat $(BUILD)/terraform.tfstate

graph: | $(BUILD)
	cd $(BUILD); $(TF_GRAPH)

refresh: init
	cd $(BUILD); $(TF_REFRESH)

init: | $(TF_PORVIDER)

$(BUILD): init_build_dir

$(TF_PORVIDER): update_provider

update_provider: | $(BUILD)
	# Generate tf provider
	$(SCRIPTS)/gen-provider.sh > $(TF_PORVIDER)

init_build_dir:
	@mkdir -p $(BUILD)
	@cp -rf $(RESOURCES)/cloud-config $(BUILD)
	@cp -rf $(RESOURCES)/certs $(BUILD)
	@cp -rf $(RESOURCES)/policies $(BUILD)
	@cp -f $(TF_RESOURCES)/variables.tf $(BUILD)
	@$(SCRIPTS)/substitute-S3-BUCKET-PREFIX.sh $(POLICIES)/*.json
	@$(SCRIPTS)/substitute-CLUSTER-NAME.sh $(CONFIG)/*.yaml $(POLICIES)/*.json

gen_certs:
	@if [ ! -f "$(SITE_CERT)" ] ; \
	then \
		$(MAKE) -C $(CERTS) ; \
	fi

clean_certs:
	rm -f $(CERTS)/*.pem
	
.PHONY: init show show_state graph refresh update_provider init_build_dir
.PHONY: gen_certs clean_certs