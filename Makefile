SHELL := /bin/bash

host=all
tags=all
inventory=hosts
ansible_run=ansible-playbook playbook.yml -i "$(inventory)" --limit "$(host)" --tags "$(tags)"

install:
	ansible-galaxy install --force -r requirements.yml

generate_users:
	./generate_user_pass.sh

generate_pdf:
	./generate_user_into.sh

a_run:
	$(ansible_run) --diff

a_run_debug:
	$(ansible_run) -vvv --diff

a_check:
	$(ansible_run) --check --diff
