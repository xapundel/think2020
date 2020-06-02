# Code @ Think - Edge Computing workshop lab

_some introduction here_ ...

---

### Before you begin

First you need to install some software and make pre-configuration of your environment. Make sure you have passed [Preparation & pre-installation guide](Preparation.md) for that.

### Obtaining lab server certificates

Some services like your machine Docker and edge service you will deploy are using lab server certificates for their connections.

To download these certificates to you machine you should go 
to helper UI and click on `Download server certificates` link.

<img alt="Download server certificates" src="doc/img/download-server-certs.jpg" width="240">

Contents is an archive file the following cert files:

- `registry.crt` -- for Docker to connect to image registry
- `ca.crt` -- for edge service to connect lab server machine

Unzip this file to anywhere on your machine, but remember the paths to certs - we will use them to configure our environment later.

### Obtaining your lab user credentials

To help you with finding your progress during making these scripts for edge configuration & deployment, and to start with test user credentials for lab completion, you should visit helper UI welcome page ([link on the helper UI]()) and click on `Obtain token` button.

You can then see obtained user ID in place of button you clicked, and this user ID is also showing in the right-top corner of the helper UI page.

By clicking on `Copy credentials` button you can make a clipboard copy of your credentials in format like they are presented in credentials block in helper UI:

```
<user_id>:<token>
```

<img alt="Copy credentials" src="doc/img/copy-credentials.jpg" width="240">

Let's go to the next section and populate configuration file with some variable for your environment, including user credentials and server certificates paths.

Do not disturb about closing helper UI welcome page - your credentials are reserved for you after obtaining, and you are able to copy them in the next section.

### Populating environment variables config

In your lab working directory you can see `envvars.mk.sample` file with some environment properties, required for lab scripts execution.

Create a copy of it named `envvars.mk`.

```bash
cp envvars.mk.sample envvars.mk
# then edit envvars.mk file and put missing data
```

Now make a clipboard copy of your user credentials from welcome page by clicking on `Copy credentials` button there (see [Obtaining your lab user credentials](#obtaining-your-lab-user-credentials))

Place these credentials in envvars.mk file, considering that:

- `HORIZON_USER` and `HORIZON_TOKEN` -- Horizon access credentials, and respectively your user ID and token you copied just now.
- `REGISTRY_USER` and `REGISTRY_TOKEN` -- Docker image registry credentials, for this lab you should point the same user ID and token as above.
- `HORIZON_NODE` and `HORIZON_NODE_TOKEN` -- Your edge node specific credentials, just come up with some kind of your node ID and node token to register it in Exchange.
- `HORIZON_MACHINE_CA_CERT` and `REGISTRY_CERT` -- absolute paths on your machine to `ca.crt` and `registry.crt` files you've downloaded previously at [Obtaining lab server certificates](#obtaining-lab-server-certificates)

This set of variables is enough for all operations below, so you can continue to prepare you device.

### Setup Docker environment to work with images registry

Since there is a private registry raised for the Docker images that users will publish to there and run as edge services, we also need to provide registry cert for Docker to make it available to push images in that registry.

If you haven't yet downloaded `registry.crt` file, pass the [Obtaining lab server certificates](#obtaining-lab-server-certificates) and then [Populating environment variables config](#populating-environment-variables-config) sections above.

It's time to pass registry cert to Docker **certs.d** folder. To do that with proper registry host bind, run the following command:

```bash
make add-docker-reg-cert
```

On Mac, you then have to restart Docker daemon for changes to take effect. You can use toolbar Docker Desktop icon menu `-> Restart`.

<img alt="Restart Docker on Mac" src="doc/img/restart-docker-on-mac.jpg" height="320">

On Linux, you do not need to restart Docker daemon - it is already put into target **/etc/docker/certs.d** directory.

Final step here is registry authorization. Perform the following command to login your Docker with registry user credentials (`REGISTRY_USER` and `REGISTRY_TOKEN` in `envvars.mk`):

```bash
make docker-login
```

Now you can build your first edge service and publish its image to registry.

### Horizon service build & publication

Generally, each Horizon service consists of Docker image artifacts, service definitions and (optionally) service policies.

Before we can start service on Horizon node, we should build its image and push it into registry for further registered node agent access. Below are commands for doing that in a robust way.

```bash
make build
```

```bash
make push
```

Then we should ensure our services & patterns being signed when publishing them to Horizon Exchange. This can be reached by generating PKI key pair for our Horizon user. Signing operation will be called automatically in further when we try to publish service/pattern.

Command to generate singing PKI key pair:

```bash
make gen-service-keys
```

In our case, we prepared Horizon service definition and pattern for its deployment, but it is also possible to use deployment policies, which are good for conditioning service deployment (you can define node properties and constraints to match before service can be delivered to your node).

Let's make our `hellothink` service and pattern publication at Horizon Exchange by calling this small command:

```bash
make publish
```

You can easily verify that your service and pattern were publiushed appropriately by calling the commands below:

```bash
make get-exchange-service
```

```bash
make get-exchange-pattern
```

### Node registration

It's time to make our node Horizon agent do real job for us.

At first, it is useful to create your node definition at Horizon Exchange to make it visible for our next configuration.

```bash
make create-node
```

You are now able to see you node in the helper UI, by clicking on `Show registered edge nodes` button at welcome page. It's status is **Unconfigured** so far, and we define the pattern for it when make it registered.

<img alt="Registered nodes" src="doc/img/registered-nodes-view.jpg">

But before we register our edge node, let's prepare node userinput file with some environment variables, useful for future service. You could see these variable in the bottom section of `envvars.mk` file.

The script below generates `node.userinput.json` file which will be used in the node registration process to pass all that we need for our services from the edge node environment.

```bash
make node-userinput
```

Now we can register our node with the pattern where our workload (`hellothink` service) referred. Pattern name, node token and Horizon org we are using here are all defined at make context created from `envvars.mk`.

Run node registration command:

```bash
make register-node
```

Now you'are able to see in helper UI Registered edge nodes page that your node is `Configured` and has deployment pattern.

Since this moment, you Horizon agent is trying to obtain a new agreement for workload defined in deployment pattern (`hellothink` service), checking Docker images for that and finally starting Docker container with your edge service on your machine.

### Proccess monitoring

Commands below are optional, but can help with understanding that our Horizon agent is processing agreements and executing services deployment.

Good way to monitor agreements & events our agent has for service deployments is to use `hzn` CLI command.

This command starts a 2s-period monitor of agreements list API output:

```bash
watch hzn agreement list
```

In parallel, you can run this command for obtaining list of last 10 events:

```bash
watch "hzn eventlog list | tail -n 10"
```

Of course, since services are starting as Docker containers, you can invoke to see whether your service is already running:

```bash
docker ps
```

To see service logs, you can perform one of the following commands according to your platform.

For Linux, run:

```bash
sudo tail -f /var/log/syslog | grep lab_user_1.hellothink[[]
```

For Mac OS, run:

```bash
sudo docker logs -f $(sudo docker ps -q --filter name=lab_user_1.hellothink)
```

Here `lab_user_1.hellothink` is the name of your service, including user ID, so put there your actual Horizon user ID.

### Summary

--- TBD

### Cleanup

To unregister device run the following command:

```bash
make unregister-node
```

Then run cleanup script to remove Docker images from local machine, Horizon Exchange node, pattern and service, created during the above steps:

```bash
make clean
```

### How to get a completion certificate

To get the certificate please go to the UI: Link, 
find you edge device registered, check if service is up and running and print certificate!

### Useful links

--- TBD
