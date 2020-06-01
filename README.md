# think2020

## Preparation & Horizon agent installation

### Prerequisites

Before you begin to install and use Horizon on your machine, make sure you have the following software / utils installed:

- `make`  
  Make utility should be already installed on most of platforms, but if you haven't it, here are the platform ways to install it:
  - <ins>For Mac OS:</ins> Install XCode Command Line Tools: `xcode-select --install`
  - <ins>For Linux (Ubuntu):</ins> `sudo apt install build-essential`

- `curl`  
  - <ins>For Mac OS:</ins> `brew install curl`
  - <ins>For Linux (Ubuntu):</ins> `sudo apt install curl`

- Docker CE  
  Use the links below for Docker installation on your platform

  - <ins>For Mac OS:</ins> Visit [Docker CE Desktop Edition for Mac OS at Docker Hub](https://hub.docker.com/editions/community/docker-ce-desktop-mac) and click on **Get Docker Desktop for Mac (Stable)** button there.

  - <ins>For Linux:</ins> Evaluate the following in your terminal:

    ```bash
    curl -fsSL https://get.docker.com/ | sh
    ```

  - Check that Docker was installed and running by using the following command:

    ```bash
    docker --version
    ```

- `socat`  
  If you are on Mac OS, you also need to install Socat package (to be able to run Horizon agent in container) from Mac App Store using the link below (Homebrew).
  - <ins>For Mac OS:</ins> [http://macappstore.org/socat/](http://macappstore.org/socat/)

### Downloading sources

You can clone this repository to your machine by running:

```bash
git clone https://github.com/xapundel/think2020.git
```

or simply download ZIP archive with repo files and unpack it:

```bash
wget -q https://github.com/xapundel/think2020/archive/master.zip
unzip master.zip
cd think2020-master
```

### Put your credentials into environment variables config

You can see `envvars.mk.sample` file with some environment properties, required for lab scripts execution.

Create a copy of it named `envvars.mk` and put your user credentials into there.

```bash
cp envvars.mk.sample envvars.mk
# then edit envvars.mk file and put missing data
```

This set of variables is enough for all operations below, so you can continue to prepare you device.

### Install Horizon agent on your device

For using your machine as edge device you should install Horizon agent package and Horizon CLI instruments. Below you can see the instructions for doing that [on Linux machine](#linux-installation) and [on Mac](#mac-os-installation).

#### Linux installation

1. Add Horizon packages repository (example for Ubuntu Bionic 18.04):

    ```bash
    wget -qO - http://pkg.bluehorizon.network/bluehorizon.network-public.key | sudo apt-key add -
    sudo add-apt-repository 'deb [arch=amd64] http://pkg.bluehorizon.network/linux/ubuntu bionic-updates main'
    sudo add-apt-repository 'deb-src [arch=amd64] http://pkg.bluehorizon.network/linux/ubuntu bionic-updates main'
    ```

1. Install packages on machine:

    ```bash
    sudo apt update
    sudo apt install bluehorizon horizon-cli horizon
    ```

1. After Horizon agent installed, make a stop for it:

    ```bash
    sudo systemctl stop horizon
    systemctl status horizon
    ```

1. Prepare the new default configuration file for Horizon agent by invoking Makefile script:

    ```bash
    make update-horizon-cfg
    ```

    Config file updated by this command is `/etc/default/horizon`

1. Start Horizon service again:

    ```bash
    sudo systemctl start horizon
    ```

#### Mac OS installation

1. Download horizon-cli package and its trust certificate from Horizon repository and install it by using Mac OS Installer tool:

    ```bash
    wget -q http://pkg.bluehorizon.network/macos/certs/horizon-cli.crt
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain horizon-cli.crt
    wget -qO horizon-cli.pkg http://pkg.bluehorizon.network/macos/horizon-cli-2.24.18.pkg
    sudo installer -pkg "horizon-cli.pkg" -target /
    ```

1. Prepare the new default configuration file for Horizon agent by invoking Makefile script:

    ```bash
    make update-horizon-cfg
    ```

1. Launch the Horizon agent container:

    ```bash
    horizon-container start
    ```

General step for all ways of installation to verify it was successful and Horizon agent is running is in retrieving general node information:

```bash
hzn node list
```

You should see something like this in the output:

```json
{
  "id": "<HORIZON_NODE>",
  "organization": null,
  "pattern": null,
  "name": null,
  "token_last_valid_time": "",
  "token_valid": null,
  "ha": null,
  "configstate": {
    "state": "unconfigured",
    "last_update_time": ""
  },
  "configuration": {
    "exchange_api": "<HZN_EXCHANGE_URL>",
    "exchange_version": "2.28.0",
    "required_minimum_exchange_version": "2.11.1",
    "preferred_exchange_version": "2.11.1",
    "mms_api": "",
    "architecture": "amd64",
    "horizon_version": "2.24.18"
  },
  "connectivity": {
    "firmware.bluehorizon.network": true,
    "images.bluehorizon.network": true
  }
}
```

### Setup Docker environment to work with images registry

Since there is a private registry raised for the Docker images that users will publish to there and run as edge services, we also need to provide registry cert for Docker to make it available to push images in that registry.

Download the registry cert to your machine using the link below:
[Link to download registry cert]()

It's time to pass it to Docker **certs.d** folder. To do that with proper registry host bind, run the following command, with replacing `path_to_registry_cert_file` to your actual downloaded cert location.

```bash
make REGISTRY_CERT=<path_to_registry_cert_file> add-docker-reg-cert
```

On Mac, you then have to restart Docker daemon for changes to take effect. You can use use toolbar Docker Desktop icon menu `-> Restart`.

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

It's time to make our node Horizon agent do real job for us. But before we register our edge node, let's prepare node userinput file with some environment variables, useful for future service. You could see these variable in the bottom section of `envvars.mk` file.

The script below generates `node.userinput.json` file which will be used in the node registration process to pass all that we need for our services from the edge node environment.

```bash
make node-userinput
```

Now we can register our node with the pattern where our workload (`hellothink` service) referred. Pattern name, node token and Horizon org we are using here are all defined at make context created from `envvars.mk`.

Run node registration command:

```bash
make register-node
```

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

### Cleanup ???

--- TBD

### How to get a completion certificate

--- TBD

### Useful links

--- TBD
