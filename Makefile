
TEMPLATE_FILE = template.yaml
PACKAGED_TEMPLATE_FILE = packaged-template.yaml
DEPLOYMENT_BUCKET = cz-sam-deployment-research


SRC_FILES := $(shell find . -name "*.js")
TEMPLATES := $(shell find . -name $(TEMPLATE_FILE))
PACKAGED_TEMPLATES := $(subst $(TEMPLATE_FILE),$(PACKAGED_TEMPLATE_FILE),$(TEMPLATES))
STACKS := $(subst /$(TEMPLATE_FILE),,$(TEMPLATES))


cfn-deploy:
	@[ -z $${stack_name} ] && { printf "MUST SET stack_name\n" ; exit 1 ; } || exit 0
	@[ -z $${template_file} ] && { printf "MUST SET template_file\n" ; exit 1 ; } || exit 0
	aws cloudformation deploy \
		--template-file $${template_file} \
		--stack-name $${stack_name} \
    --capabilities CAPABILITY_IAM


cfn-delete:
	@[ -z $${stack_name} ] && { printf "MUST SET stack_name\n" ; exit 1 ; } || exit 0
	@aws cloudformation delete-stack \
		--stack-name $${stack_name}
	@printf "Deleting stack $${stack_name} "
	@while aws cloudformation describe-stacks --stack-name $${stack_name} &>/dev/null ; do \
		printf "." ; \
		sleep 1 ; \
	done ; \
	echo


$(PACKAGED_TEMPLATES): %/$(PACKAGED_TEMPLATE_FILE) : %/$(TEMPLATE_FILE)
	@aws cloudformation package \
		--template-file $^ \
    --output-template-file $@ \
		--s3-bucket $(DEPLOYMENT_BUCKET)


.PHONY: $(STACKS)
$(STACKS): % : %/$(PACKAGED_TEMPLATE_FILE)
	@[ -z $${namespace} ] && { printf "MUST SET namespace\n" ; exit 1 ; } || exit 0
	@make cfn-$${action:-deploy} stack_name=$@-$${namespace} template_file=$^





