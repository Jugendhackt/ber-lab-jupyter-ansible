# Readme



### Step 0: Install prerequisites

1. Make sure you have [Pyhon installed](https://www.python.org/about/gettingstarted/) on your local system

2. set up a python virtual environment

   ```
   insert here how to set up new python env
   ```

3. install terraform

4. install ansible

### Step 1:  Anpassung der Config files:

1. add new `config.yaml`
2. copy `config.templ.yaml` s content into `config.yaml`



`hclould_token`

1. go to `console.hetzner.cloud/projects`
2. add new project
3. in project, open left sidebar > Security > API-Tokens > add API-Token
4. copy API-Token into `config.yaml` as value of `hcloud_token`



`domain`

1. [create](https://www.google.com/search?client=safari&rls=en&q=create+domain+namecheap&ie=UTF-8&oe=UTF-8) / use a [domain](https://de.wikipedia.org/wiki/Domain_(Internet)) from your favorite registrar (like [Namecheap.com](https://www.namecheap.com))
2. copy domain name to `config.yaml` as value of `domain`



`hostname`

1. choose a [hostname](https://en.wikipedia.org/wiki/Hostname) (anything)
2. copy hostname to `config.yaml` as value of `hostname`



`admins`

1. add at least one admin
2. choose an [admin](https://en.wikipedia.org/wiki/System_administrator) name (anything)
3. copy hostname to `config.yaml` as value of `user_name`
4. use or [generate](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) an [ssh](https://de.wikipedia.org/wiki/Secure_Shell)-key
5. copy the public key string  to `config.yaml` as value of `ssh_key`
6. pick a [shell](https://en.wikipedia.org/wiki/Command-line_interface) for the servers to run (like [`/bin/bash`](https://de.wikipedia.org/wiki/Bash_(Shell)) or [`/bin/zsh/`](https://de.wikipedia.org/wiki/Z_shell))



### Step 2. Run the scripts

1.  install requirements

      ```
      make install
      ```

2. run `generate.py`  with number of instances you need

   ```python
   python generate.py -n 10
   ```

3. run terraform

   ```
   make tf_init && make tf_plan
   ```

4. verify output

5. apply terraform

   ```
   make tf_apply
   ```

   this will print public IPv4 and IPv6 addresses



### Step 3: Add IP Adresses to DNS records of your domain

1. navigate to your registrar find your chosen domains DNS records 
2. add `A` and `AAAA` records for `NAME`  `*.hostname` and `hostname`
3. the `A`records take the IPv4 address
4. the `AAAA`records take the IPv6 address 



### Step 4: run ansible

1. set up base

   ```
   make a_run
   ```

2. in case any step fails, use tags in `ansible/playbook.yaml` to run them 



### Step 5: extract passwords and domain names

1. go to `ansible/config.yaml`
2. get urls and passwords 
3. profit



### Step 6: destroy server

1. open your hetzner console 
2. deactivate protection
3. delete server
