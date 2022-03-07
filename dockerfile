FROM ubuntu:20.04

# install required packages
RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    openssh-server python3 python3-pip python3-apt \
    && rm -rf /var/lib/apt/lists/*

# install ansible
RUN pip3 install ansible

# ensure that required directories are created
RUN rm -rf /var/run/sshd && mkdir /var/run/sshd

# remove the ansible key from a previous run
RUN rm -rf /root/.ssh/ansible_demo

# create an ssh key and place the public key in the authorized_keys
RUN ssh-keygen -f /root/.ssh/ansible_demo
RUN cat /root/.ssh/ansible_demo.pub > /root/.ssh/authorized_keys

# start command injected by docker-compose