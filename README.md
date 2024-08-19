# Jupyter notebook deployment for Jugend Hackt Labs <!-- omit in toc -->

- [Foreword](#foreword)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
  - [Step 1: Setup Hetzner Cloud instance](#step-1-setup-hetzner-cloud-instance)
  - [Step 2: Create a new configuration file.](#step-2-create-a-new-configuration-file)
  - [Step 3: Setup](#step-3-setup)
  - [Step 4: Create your Hetzner Cloud instance](#step-4-create-your-hetzner-cloud-instance)
  - [Step 4: Add IP Adresses to DNS records of your domain](#step-4-add-ip-adresses-to-dns-records-of-your-domain)
  - [Step 5: Deploy the docker containers using Ansible](#step-5-deploy-the-docker-containers-using-ansible)
  - [Step 6: extract passwords and domain names](#step-6-extract-passwords-and-domain-names)
  - [Step 7: Use jupyter notebooks](#step-7-use-jupyter-notebooks)
  - [Step 8: (later) destroy server](#step-8-later-destroy-server)

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
- [Ansible](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

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
5. Fill the `admins` array. These will be the accounts that will be created on the server. Use your the public part of your ssh-key from above or any other ssh-key from your friends who want to access this server. Regarding the shell: if you know, you know otherwise just leave it as is.

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
1. run terraform

   ```
   make tf_init && make tf_plan
   ```

   Verify that the settings shown in this plan is what you are expecting.

2. apply terraform

   ```
   make tf_apply
   ```

   this will print the public IPv4 and IPv6 addresses

### Step 4: Add IP Adresses to DNS records of your domain

1. navigate to your registrar find your chosen domain's DNS records 
2. add `A` and `AAAA` records for `*.hostname` and `hostname`
3. the `A`records take the IPv4 address
4. the `AAAA`records take the IPv6 address 

### Step 5: Deploy the docker containers using Ansible

1. Run Ansible

   ```
   make a_run
   ```

2. in case any step fails, use tags in `ansible/playbook.yaml` to run single steps

### Step 6: extract passwords and domain names

1. go to `ansible/config.yaml`
2. get urls and passwords 

### Step 7: Use jupyter notebooks

The jupyter notebooks can be reached under `001.<hostname>.<domain>` where `001` indicates the instance number.

### Step 8: (later) destroy server

1. open your Hetzner Cloud Console 
2. deactivate protection
3. delete server
