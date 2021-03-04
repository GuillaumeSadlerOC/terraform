#!/bin/bash

sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install --yes ansible

cd /home/ubuntu
git clone https://github.com/GuillaumeSadlerOC/ansible.git
ansible-playbook -e "wp_db_host=${db_instance_endpoint} wp_memcached_host=${cluster_configuration_endpoint}" -i ./ansible/inventory.ini ./ansible/playbook.yml