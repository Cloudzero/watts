
TEMPLATE_FILE = template.yaml
PACKAGED_TEMPLATE_FILE = packaged-template.yaml
DEPLOYMENT_BUCKET = cz-sam-deployment-research


TEMPLATES := $(shell find . -name $(TEMPLATE_FILE))
PACKAGED_TEMPLATES := $(subst $(TEMPLATE_FILE),$(PACKAGED_TEMPLATE_FILE),$(TEMPLATES))
STACKS := $(subst /$(TEMPLATE_FILE),,$(TEMPLATES))


$(PACKAGED_TEMPLATES): %/$(PACKAGED_TEMPLATE_FILE) : %/$(TEMPLATE_FILE)
	@aws cloudformation package \
		--template-file $^ \
    --output-template-file $@ \
		--s3-bucket $(DEPLOYMENT_BUCKET)


.PHONY: $(STACKS)
$(STACKS): % : %/$(PACKAGED_TEMPLATE_FILE)
	@[ -z $${namespace} ] && { printf "MUST SET namespace\n" ; exit 1 ; } || exit 0
	aws cloudformation deploy \
		--template-file $^ \
		--stack-name $@-$${namespace} \
    --capabilities CAPABILITY_IAM


smoke:
	@while true ; do \
		hi=`http --body GET https://oua80j51mb.execute-api.us-east-1.amazonaws.com/Stage/hello` ; \
	  dt=`date "+%Y-%m-%d %H:%M:%S"` ; \
		printf "$${dt}: $${hi} " ; \
		for i in {1..30} ; do \
			printf "." ; \
	    sleep 1 ; \
		done ; \
		echo ; \
	done

