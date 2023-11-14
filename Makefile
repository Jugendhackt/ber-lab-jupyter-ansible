SHELL := /bin/bash

host=all
tags=all
inventory=hosts
ansible_run=ansible-playbook playbook.yml -i "$(inventory)" --limit "$(host)" --tags "$(tags)"
num=10

install: tf_init
	python -m pip install -r requirements.txt
	cd ansible && ansible-galaxy install --force -r requirements.yml

tf_init:
	cd terraform &&	terraform workspace select -or-create production && terraform init

tf_plan:
	cd terraform &&	terraform workspace select production && terraform plan --var-file=config.tfvars.json

tf_apply:
	cd terraform &&	terraform workspace select production && terraform apply --var-file=config.tfvars.json

a_run:
	cd ansible && $(ansible_run) --diff

a_run_debug:
	cd ansible && $(ansible_run) -vvv --diff

a_check:
	cd ansible && $(ansible_run) --check --diff

generate:
	python generate.py -n "$(num)"
