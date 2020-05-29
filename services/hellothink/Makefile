-include envvars.mk

# This imports the variables from horizon/hzn.json. You can ignore these lines, but do not remove them.
-include horizon/.hzn.json.tmp.mk

# Default ARCH to the architecture of this machines (as horizon/golang describes it). Can be overridden.
export ARCH ?= $(shell hzn architecture)

# Configurable parameters passed to serviceTest.sh in "test" target
export MATCH:='[hellothink] Service was started'
export TIME_OUT:=60

cert_dir:= ~/.docker/certs.d/test

add-docker-reg-cert:
	-@mkdir -p $(cert_dir)
	-@cp ${REGISTRY_CERT} $(cert_dir)
	@echo "Registry cert file was copied to $(cert_dir). Please restart your Docker daemon."

docker-login:
	-@echo $(REGISTRY_TOKEN) | docker login $(REGISTRY_ADDRESS) -u $(REGISTRY_USER) --password-stdin

build:
	-@docker build -t $(DOCKER_IMAGE_BASE):$(SERVICE_VERSION) -f ./Dockerfile .

push:
	-@docker push $(DOCKER_IMAGE_BASE):$(SERVICE_VERSION)

# FOR TESTING
test: build
	hzn dev service start -S
	@echo 'Testing service...'
	../../../tools/serviceTest.sh $(SERVICE_NAME) $(MATCH) $(TIME_OUT) && \
		{ hzn dev service stop; \
		echo "*** Service test succeeded! ***"; } || \
		{ hzn dev service stop; \
		echo "*** Service test failed! ***"; \
		false; }

publish-service:
	-@hzn exchange service publish \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		-O -I -f horizon/service.definition.json
	-@curl -sS -X POST -u "$(HZN_ORG_ID)/$(HORIZON_USER_AUTH)" \
		-H "Content-Type: application/json" \
		-H "Accept: application/json" \
		-d '{"registry": "$(REGISTRY_ADDRESS)","username": "$(REGISTRY_USER)","token": "$(REGISTRY_TOKEN)"}' \
		$(HZN_EXCHANGE_URL)orgs/$(HZN_ORG_ID)/services/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)/dockauths > /dev/null

publish-pattern:
	-@hzn exchange pattern publish \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		-f horizon/pattern.json

publish: publish-service publish-pattern

register-node:
	-@hzn register \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		-n $(HORIZON_NODE_AUTH) \
		-p pattern-${SERVICE_NAME}-$(ARCH) \
		-f ../../node.userinput.json

unregister-node:
	-@hzn unregister -f

gen-service-keys:
	-@hzn key create -f -i "$(HZN_ORG_ID)" "$(HORIZON_USER)"

clean:
	-@docker rmi $(DOCKER_IMAGE_BASE):$(SERVICE_VERSION) 2> /dev/null || :

# This imports the variables from horizon/hzn.cfg. You can ignore these lines, but do not remove them.
horizon/.hzn.json.tmp.mk: horizon/hzn.json
	@ hzn util configconv -f $< > $@
