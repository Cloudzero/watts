
TEMPLATE_FILE = template.yaml
PACKAGED_TEMPLATE_FILE = packaged-template.yaml
DEPLOYMENT_BUCKET = cz-sam-deployment-research

TEMPLATES := $(shell find . -name $(TEMPLATE_FILE))
PACKAGED_TEMPLATES := $(subst $(TEMPLATE_FILE),$(PACKAGED_TEMPLATE_FILE),$(TEMPLATES))
STACKS := $(subst /$(TEMPLATE_FILE),,$(TEMPLATES))


init:                                    ## ensures all dev dependencies into the current virtualenv
	@if [[ "$$VIRTUAL_ENV" = "" ]] ; then \
		printf "$(WARN_COLOR)WARN:$(NO_COLOR) No virtualenv found, will not install dependencies globally." ; \
		exit 1 ; \
	fi
	@pip install -r requirements-dev.txt
	@alias sam="$VIRTUAL_ENV/bin/sam"


cfn-deploy:
	@[ -z $${stack_name} ] && { printf "MUST SET stack_name\n" ; exit 1 ; } || exit 0
	@[ -z $${template_file} ] && { printf "MUST SET template_file\n" ; exit 1 ; } || exit 0
	aws cloudformation deploy \
		--template-file $${template_file} \
		--stack-name $${stack_name} \
		--capabilities CAPABILITY_IAM \
		--no-fail-on-empty-changeset \
		--parameter-overrides \
			Namespace=${namespace}


cfn-delete:
	@[ -z $${stack_name} ] && { printf "MUST SET stack_name\n" ; exit 1 ; } || exit 0
	@aws cloudformation delete-stack \
		--stack-name $${stack_name}
	@printf "Deleting stack $${stack_name} "
	@while aws cloudformation describe-stacks --stack-name $${stack_name} 2>/dev/null | grep -q IN_PROGRESS ; do \
		printf "." ; \
		sleep 1 ; \
	done ; \
	echo
	@aws cloudformation list-stacks | \
		jq -re --arg stackName $${stack_name} \
			'.StackSummaries | map(select(.StackName == $$stackName)) | .[0] | [.StackStatus, .StackStatusReason] | join(" ")'


cfn-describe:
	@[ -z $${stack_name} ] && { printf "MUST SET stack_name\n" ; exit 1 ; } || exit 0
	@aws cloudformation describe-stacks \
		--stack-name $${stack_name}


.SECONDEXPANSION:
$(PACKAGED_TEMPLATES): %/$(PACKAGED_TEMPLATE_FILE) : %/$(TEMPLATE_FILE) $$(shell find $$* -name "*.js")
	@aws cloudformation package \
		--template-file $< \
		--output-template-file $@ \
		--s3-bucket $(DEPLOYMENT_BUCKET)


.SECONDEXPANSION:
.PHONY: $(STACKS)
$(STACKS): % : %/$(PACKAGED_TEMPLATE_FILE) $$(shell grep -Eo -e "ImportValue ([A-Za-z-]+)-$${namespace}::" $$*/$$(TEMPLATE_FILE) | cut -f2 -d' ' | sed -e "s/-$${namespace}:://" | sort -u)
	@[ -z $${namespace} ] && { printf "MUST SET namespace\n" ; exit 1 ; } || exit 0
	@make cfn-$${action:-deploy} stack_name=$@-$${namespace} template_file=$<
