.EXPORT_ALL_VARIABLES:

# Horizon Exchange URI
HZN_EXCHANGE_URL=http://169.50.56.52:8080/v1/

# Horizon organization ID (main realm for all nodes, service and users)
E_HZN_ORG_ID=thinkmoscow

# Image registry address
REGISTRY_ADDRESS=169.50.56.52:443

# Horizon machine CA certificate local path
# (e.g. /Users/test/think2020/ca.crt)
# NOTE: you can obtain this certificate in archive using link in helper UI
HORIZON_MACHINE_CA_CERT=

# Image registry certificate local path
# (e.g. /Users/test/think2020/registry.crt)
# NOTE: you can obtain this certificate in archive using link in helper UI
REGISTRY_CERT=

# Registry repo location for all images
E_DOCKER_IMAGE_BASE=${REGISTRY_ADDRESS}/thinkmoscow2020

# Lab service base properties
E_SERVICE_NAME=hellothink
E_SERVICE_VERSION=1.0.0

# Horizon Exchange user credentials
HORIZON_USER=
HORIZON_TOKEN=
HORIZON_USER_AUTH=${HORIZON_USER}:${HORIZON_TOKEN}

# Image registry user credentials
# (for lab environment they are equivalent to Horizon Exchange user credentials)
REGISTRY_USER=${HORIZON_USER}
REGISTRY_TOKEN=${HORIZON_TOKEN}

# Edge node name and token for Horizon registration.
HORIZON_NODE=
HORIZON_NODE_TOKEN=
HORIZON_NODE_AUTH=${HORIZON_NODE}:${HORIZON_NODE_TOKEN}

# Node userinput variables
# (will be used as env variables for running edge service)
MQTT_BROKER_URI=mqtts://169.50.56.52:8883
