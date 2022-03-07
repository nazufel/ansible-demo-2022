# dockerfile

# dockerfiles are used to build docker images - https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

# start with the base image of Ubuntu 20.04 - https://hub.docker.com/_/ubuntu
FROM ubuntu:20.04

# install required packages to run demo
RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    openssh-server python3 python3-pip python3-apt \
    && rm -rf /var/lib/apt/lists/*

# install curl with apt
RUN apt update && apt intall -y curl

# install ansible
RUN pip3 install ansible

# ensure that required directories are created to run the container
RUN rm -rf /var/run/sshd && mkdir /var/run/sshd

# remove the ansible key from a previous run in case of caching
RUN rm -rf /root/.ssh/ansible_demo

# create an ssh key and place the public key in the authorized_keys 
# (https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server)
# for all containers so that the controller container defined in the
# docker-compose.yaml file will be able to ssh into the other conatiners
# and run ansible since it uses ssh to communicate with servers it 
# orchestrates
RUN ssh-keygen -f /root/.ssh/ansible_demo
RUN cat /root/.ssh/ansible_demo.pub > /root/.ssh/authorized_keys

# start command injected by docker-compose