copy-server-crt:
	-@cp $(HORIZON_MACHINE_CA_CERT) ./ca.crt

build:
	-@docker build --no-cache \
		-t $(DOCKER_IMAGE_BASE):$(SERVICE_VERSION) \
		-f Dockerfile .