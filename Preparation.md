# Preparation & pre-installation for Edge Computing workshop lab

## Prerequisites

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

## Downloading sources

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

> NOTE: If you don't have wget tool on your device, install it using `brew install wget` on Mac OS or `sudo apt install wget` on Ubuntu/Debian. You will also need it in the next steps.

## Installing Horizon agent on your device

For using your machine as edge device you should install Horizon agent package and Horizon CLI instruments. Below you can see the instructions for doing that [on Linux machine](#linux-installation) and [on Mac](#mac-os-installation). List of supported OS versions for Linux packages [you can find here](https://github.com/open-horizon/horizon-deb-packager).

#### Linux installation

1. Add Horizon packages repository. You can choose your Linux OS version [from their repository](http://pkg.bluehorizon.network/linux) as well - this is an example for Ubuntu Bionic 18.04.

    ```bash
    wget -qO - http://pkg.bluehorizon.network/bluehorizon.network-public.key | sudo apt-key add -
    sudo add-apt-repository 'deb [arch=amd64] http://pkg.bluehorizon.network/linux/ubuntu bionic-updates main'
    sudo add-apt-repository 'deb-src [arch=amd64] http://pkg.bluehorizon.network/linux/ubuntu bionic-updates main'
    ```

1. Install Horizon packages on machine. If you have another Linux OS, use your package manager to install these 3 packages.

    ```bash
    sudo apt update
    sudo apt install bluehorizon horizon-cli horizon
    ```

1. After Horizon agent installed, make a stop for it:

    ```bash
    sudo systemctl stop horizon
    systemctl status horizon
    ```

1. Go to lab working directory (`think2020-master` or as yu called it) and prepare the new default configuration file for Horizon agent by invoking Makefile script:

    ```bash
    cd <lab_workdir>
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

1. Verify that you have `envsubst` tool (gettext package) installed on your Mac OS:

    ```bash
    envsubst -V
    ```

    If it was not found, you can install gettext using Homebrew:

    ```bash
    brew install gettext
    brew link --force gettext
    ```

1. Prepare the new default configuration file for Horizon agent by invoking Makefile script (may require sudo permissions):

    ```bash
    sudo make update-horizon-cfg
    ```

1. Launch the Horizon agent container with newly updated Horizon config:

    ```bash
    horizon-container start 1 /etc/default/horizon
    ```

General step for all ways of installation to verify it was successful and Horizon agent is running is in retrieving general node information:

```bash
hzn node list
```

You should see something like this in the output:

```json
{
  "id": "",
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
