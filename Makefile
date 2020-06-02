-include envvars.mk

# This imports the variables from horizon/hzn.json. You can ignore these lines, but do not remove them.
-include services/$(E_SERVICE_NAME)/horizon/.hzn.json.tmp.mk

# Default ARCH to the architecture of this machines (as horizon/golang describes it). Can be overridden.
export ARCH ?= $(shell hzn architecture)

# Configurable parameters passed to serviceTest.sh in "test" target
export MATCH:='[hellothink] Service was started'
export TIME_OUT:=60

# Detect OS
OSFLAG :=
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	OSFLAG = LINUX
else ifeq ($(UNAME_S),Darwin)
	OSFLAG = MACOS
else
	OSFLAG = NOT_SUPPORTED_OS
endif

# Non-supported OS detected
ifeq ($(OSFLAG),NOT_SUPPORTED_OS)
$(error OS platform is not supported.)
endif

NODE_USERINPUT_FILE_TEMPLATE=node.userinput.json.tmpl
NODE_USERINPUT_FILE=node.userinput.json

HORIZON_CFG_FILE_TEMPLATE=horizon.cfg
HORIZON_CFG_FILE=/etc/default/horizon
HORIZON_CFG_FILE_DIR=$(shell dirname $(HORIZON_CFG_FILE))

cert_dir :=
ifeq ($(OSFLAG),MACOS)
	cert_dir = ~/.docker/certs.d/$(REGISTRY_ADDRESS)
endif
ifeq ($(OSFLAG),LINUX)
	cert_dir = /etc/docker/certs.d/$(REGISTRY_ADDRESS)
endif

get-os:
	@echo "$(OSFLAG)"

add-docker-reg-cert:
	-@mkdir -p $(cert_dir)
	-@cp $(REGISTRY_CERT) $(cert_dir)
	@echo "Registry cert file was copied to $(cert_dir).\nOn Mac OS, restart your Docker daemon to take effect."

docker-login:
	-@echo $(REGISTRY_TOKEN) | docker login $(REGISTRY_ADDRESS) -u $(REGISTRY_USER) --password-stdin

copy-server-crt:
	-@make -C services/$(E_SERVICE_NAME) copy-server-crt

build: copy-server-crt
	make -C services/$(E_SERVICE_NAME) build

push:
	-@docker push $(DOCKER_IMAGE_BASE):$(SERVICE_VERSION)

# for testing service without agbots
test: build
	-@hzn dev service start -S
	@echo 'Testing service...'
	./tools/serviceTest.sh $(SERVICE_NAME) $(MATCH) $(TIME_OUT) && \
		{ hzn dev service stop; \
		echo "*** Service test succeeded! ***"; } || \
		{ hzn dev service stop; \
		echo "*** Service test failed! ***"; \
		false; }

create-node:
	-@hzn exchange node create \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		-n $(HORIZON_NODE_AUTH) \
		-a $(ARCH) \
		-m $(HORIZON_NODE)

publish-service:
	-@hzn exchange service publish \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		-O -I -f services/$(E_SERVICE_NAME)/horizon/service.definition.json
	-@curl -sS -X POST -u "$(HZN_ORG_ID)/$(HORIZON_USER_AUTH)" \
		-H "Content-Type: application/json" \
		-H "Accept: application/json" \
		-d '{"registry": "$(REGISTRY_ADDRESS)","username": "$(REGISTRY_USER)","token": "$(REGISTRY_TOKEN)"}' \
		$(HZN_EXCHANGE_URL)orgs/$(HZN_ORG_ID)/services/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)/dockauths > /dev/null

publish-pattern:
	-@hzn exchange pattern publish \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		-f services/$(E_SERVICE_NAME)/horizon/pattern.json

publish: publish-service publish-pattern

get-exchange-service:
	-hzn exchange service list \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)

get-exchange-pattern:
	-hzn exchange pattern list \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		pattern-$(SERVICE_NAME)-$(ARCH)

register-node:
	-@hzn register \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		-n $(HORIZON_NODE_AUTH) \
		-p pattern-$(SERVICE_NAME)-$(ARCH) \
		-f $(NODE_USERINPUT_FILE)

unregister-node:
	-@hzn unregister -f

gen-service-keys:
	-@hzn key create -f -i "$(HZN_ORG_ID)" "$(HORIZON_USER)"

node-userinput:
	-@envsubst < $(NODE_USERINPUT_FILE_TEMPLATE) > $(NODE_USERINPUT_FILE)
	@echo "Horizon node userinput file created: $(NODE_USERINPUT_FILE)"

update-horizon-cfg: verify-horizon-cfg-dir
	-@envsubst < $(HORIZON_CFG_FILE_TEMPLATE) > $(HORIZON_CFG_FILE)
	@echo "Horizon config file updated. Restart Horizon agent to apply new settings."

verify-horizon-cfg-dir:
	-@if [[ ! -d "$(HORIZON_CFG_FILE_DIR)" ]]; then mkdir -p $(HORIZON_CFG_FILE_DIR); fi

clean: clean-docker-img clean-hzn-services clean-hzn-patterns clean-hzn-nodes
	-@echo "Success. Exchange node, services and patterns and local Docker images were removed."

clean-docker-img:
	-@docker rmi $(DOCKER_IMAGE_BASE):$(SERVICE_VERSION) 2> /dev/null || :

clean-hzn-services:
	-@hzn exchange service remove -f \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH) || :

clean-hzn-patterns:
	-@hzn exchange pattern remove -f \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		pattern-$(SERVICE_NAME)-$(ARCH) || :

clean-hzn-nodes:
	-@hzn exchange node remove -f \
		-o $(HZN_ORG_ID) \
		-u $(HORIZON_USER_AUTH) \
		$(HORIZON_NODE) || :

# This imports the variables from horizon/hzn.cfg. You can ignore these lines, but do not remove them.
services/$(E_SERVICE_NAME)/horizon/.hzn.json.tmp.mk: services/$(E_SERVICE_NAME)/horizon/hzn.json
	@ hzn util configconv -f $< > $@
