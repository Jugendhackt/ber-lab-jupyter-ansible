# Jupyter notebook deployment for Jugend Hackt Labs <!-- omit in toc -->

- [Foreword](#foreword)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
  - [Step 1: Setup Hetzner Cloud instance](#step-1-setup-hetzner-cloud-instance)
  - [Step 2: Create a new configuration file.](#step-2-create-a-new-configuration-file)
  - [Step 3: Setup](#step-3-setup)
  - [Step 4: Create your Hetzner Cloud instance](#step-4-create-your-hetzner-cloud-instance)
  - [Step 5: Add IP addresses to DNS records of your domain](#step-5-add-ip-addresses-to-dns-records-of-your-domain)
  - [Step 6: Deploy the docker containers using Ansible](#step-6-deploy-the-docker-containers-using-ansible)
  - [Step 7: extract passwords and domain names](#step-7-extract-passwords-and-domain-names)
  - [Step 8: Use jupyter notebooks](#step-8-use-jupyter-notebooks)
  - [Step 9: (later) destroy server](#step-9-later-destroy-server)

## Foreword

This repository holds terraform and Ansible configuration files to set up Jupyter notebooks on a Hetzner Cloud instance.
It uses [traefik](https://traefik.io/traefik/) as a reverse proxy and [docker](https://www.docker.com/) with docker-compose to orchestrate the containers which will run the jupyter notebooks.

> [!WARNING]  
> A word of warning: You should be familiar with using the command line. The steps described here try to help you through the process but we can not cover everything.

## Prerequisites

- Computer running macOS, Linux or Windows with WSL
- A ssh key (create on using `ssh-keygen -t ed25519`) in `~/.ssh/id_ed25519`
- A Domain name like `alpacabook.de` with access to its DNS entries.
- A [Hetzner Cloud](https://www.hetzner.com/cloud/) account.
- [Python](https://www.python.org/about/gettingstarted/)
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Setup

### Step 1: Setup Hetzner Cloud instance

1. Create a new project on the [Hetzner Cloud Console](https://console.hetzner.cloud/projects)
2. Create a new token for the project with read/write access (open left sidebar > Security > API-Tokens > add API-Token)
3. Copy this token into your password manager of choice as it will only be displayed once.

### Step 2: Create a new configuration file.

1. Copy the template config to a new file `cp config.tmpl.yaml config.yaml`
2. Replace the placeholder for `hcloud_token` with your token from Hetzner Cloud.
3. Replace the placeholder for `domain` with your domain name like `alpacabook.de`.
4. Choose a hostname. This will be the subdomain your server will be reachable by. This could just be `jupyter` for example. So the server will be reachable using `jupyter.alpacabook.de` and the jupyter notebooks will be reachable under `00[1,2,3...].jupyter.alpacabook.de`
5. Add the location of your public key into `ssh_key_location` like `~/.ssh/id_ed25519`. This will be the key used to access the server initially.
6. Add an email for the `email` field under which you will get your certificates from [Letsencrypt](https://letsencrypt.org/)
7. Fill the `admins` array. These will be the accounts that will be created on the server. Use your the public part of your ssh-key from above or any other ssh-key from your friends who want to access this server. Regarding the shell: if you know, you know otherwise just leave it as is.

### Step 3: Setup

1. install requirements

   ```
   make install
   ```

2. run `generate.py`  with number of instances you need

   ```python
   python generate.py -n 10
   ```

### Step 4: Create your Hetzner Cloud instance
1. initialize terraform

   ```
   make tf_init
   ```

2. (optional) check the plan before creating anything

   ```
   make tf_plan
   ```

   This shows what terraform would create without creating anything, so you can safely run it after every change to `config.yaml` or the terraform files. Verify that the settings shown in this plan are what you are expecting. On a fresh deployment every resource should show as `+ create` and the plan should end with `0 to change, 0 to destroy`. If it wants to change or destroy something, a server or state from an earlier deployment is probably still around (see [Step 9](#step-9-later-destroy-server)).

   If `make tf_apply` fails with `name is already used`, the network or firewall from an earlier deployment still exists in your Hetzner project. Either delete them in the Hetzner Cloud Console, or import them into the terraform state (IDs are shown in the console):

   ```
   cd terraform
   terraform import --var-file=config.tfvars.json hcloud_network.internal <network_id>
   terraform import --var-file=config.tfvars.json hcloud_network_subnet.servers <network_id>-10.0.0.0/24
   terraform import --var-file=config.tfvars.json 'module.host[0].hcloud_firewall.firewall' <firewall_id>
   ```

   Note: the plan does not check whether Hetzner still offers the chosen server type or image in your location. If `make tf_apply` fails with `unsupported location for server type`, pick a current type in `terraform/hetzner.tf` (`server_type`, currently `cpx42`: 8 vCPU, 16 GB RAM). Current types are listed at https://www.hetzner.com/cloud/.

3. apply terraform

   ```
   make tf_apply
   ```

   this will print the public IPv4 and IPv6 addresses

### Step 5: Add IP addresses to DNS records of your domain

1. navigate to your registrar find your chosen domain's DNS records 
2. add `A` and `AAAA` records for `*.hostname` and `hostname`
3. the `A`records take the IPv4 address
4. the `AAAA`records take the IPv6 address 
5. verify that the records are published using `nslookup` or `dig`, e.g. `dig +short <hostname>.<domain>` must return the new IPv4 address. Wait for this before running Ansible, otherwise ssh may still reach the old IP from an earlier deployment.

### Step 6: Deploy the docker containers using Ansible

1. Run Ansible

   ```
   make a_run
   ```

   This might take a while.

2. If this fails with `REMOTE HOST IDENTIFICATION HAS CHANGED`, you already deployed to the same hostname before and `~/.ssh/known_hosts` still holds the old server's key. Remove it with `ssh-keygen -R <hostname>.<domain>` and run again.
3. in case any step fails, use tags in `ansible/playbook.yml` to run single steps
4. to debug you can access the server via `ssh -i ~/.ssh/private_ssh_key <admin_user>@<hostname>.<domain>`

### Step 7: extract passwords and domain names

1. go to `ansible/config.yaml`
2. get urls and passwords

### Step 8: Use jupyter notebooks

The jupyter notebooks can be reached under `001.<hostname>.<domain>` where `001` indicates the instance number.

### Step 9: (later) destroy server

1. open your Hetzner Cloud Console 
2. deactivate protection
3. delete server
4. also delete the network `production` and the firewall `<hostname>_firewall`. Otherwise the next `make tf_apply` fails with `name is already used`. Alternatively keep the terraform state in `terraform/terraform.tfstate.d/` and run `terraform destroy` from there instead.
5. remove the old host key so the next deployment can connect: `ssh-keygen -R <hostname>.<domain>`
