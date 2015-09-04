app: init_app vpc s3 iam
	cd $(BUILD); \
		$(SCRIPTS)/aws-keypair.sh -c app; \
		$(TF_APPLY) -target module.app
	@$(MAKE) app_ips

plan_app: init_app plan_vpc plan_s3 plan_iam
	cd $(BUILD); \
		$(TF_PLAN) -target module.app;

refresh_app: | $(TF_PORVIDER)
	cd $(BUILD); \
		$(TF_REFRESH) -target module.app
	@$(MAKE) app_ips

destroy_app: | $(TF_PORVIDER)
	cd $(BUILD); \
	  $(SCRIPTS)/aws-keypair.sh -d app; \
		$(TF_DESTROY) -target module.app.aws_autoscaling_group.app; \
		$(TF_DESTROY) -target module.app.aws_launch_configuration.app; \
		$(TF_DESTROY) -target module.app 

clean_app: destroy_app
	rm -f $(BUILD)/module-app.tf

init_app:
	cp -f $(RESOURCES)/terraforms/module-app.tf $(BUILD)
	cd $(BUILD); $(TF_GET);

app_ips:
	@echo "app public ips: " `$(SCRIPTS)/get-ec2-public-id.sh app`

.PHONY: app destroy_app refresh_app plan_app init_app clean_app app_ips
