#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Start"
yum install -y python3-pip
pip3 install ansible

yum install git -y

cd /home/ec2-user/; git clone https://github.com/errne/Ansible-practise.git

cd Ansible-practise/; ansible-playbook main.yml

date
echo "The End"
