web: s3 iam plan_web
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c web; \
		$(TF_APPLY) -target module.web
	@$(MAKE) web_ips

plan_web: plan_s3 plan_iam init_web
	cd $(BUILD); \
		$(TF_PLAN) -target module.web;

refresh_web: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.web
	@$(MAKE) web_ips

destroy_web: | $(TF_PORVIDER)
	cd $(BUILD); \
	  $(SCRIPTS)/aws-keypair.sh -d web; \
		$(TF_DESTROY) -target module.web.aws_autoscaling_group.web; \
		$(TF_DESTROY) -target module.web.aws_launch_configuration.web; \
		$(TF_DESTROY) -target module.web 

clean_web: destroy_web
	rm -f $(BUILD)/module-web.tf

init_web: init_vpc init_s3 init_iam init_elb
	cp -f $(RESOURCES)/terraforms/module-web.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

web_ips:
	@echo "web public ips: " `$(SCRIPTS)/get-ec2-public-id.sh web`

.PHONY: web destroy_web refresh_web plan_web init_web clean_web web_ips
