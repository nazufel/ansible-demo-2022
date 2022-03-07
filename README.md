# Ansible Introduction Demo

This is the readme for the [Ansible](https://docs.ansible.com/) Demo that happened on 05-14-2021 during the Engineering Open Discussions Meeting. 

Here is the format:

* Show the [docker-compose](./docker-compose.yaml) file and go over the infrastructure diagram in this document and build the infrastructure.
* Run the [curl](curl.sh) test script to show there's no funny business
* While the infrastructure spins up (it takes a few minutes) go over Ansible at a high level
    * Ansible is a configuration management and orchestration tool
    * Ansible is a combination of a declaritive and procedural API
        * Delclaritive modules
        * Excuted in a procedural order
    * Ansible uses a combination of primitives to make a robust and pluggable system
* Explain the primitives
    * Playbooks
    * Plays
    * Roles
    * Tasks
    * Inventories
    * Variables
    * Secrets
* Run the first part of the demo where the infrastructure is configured and v1 of the app is deployed
* Update v2 taking suggestions from the viewers as to what the "payload" should be and deploy
* Questions

Throughout the demo a [Makefile](./Makefile) will be used to shorten complex commands and make things easier.

## Show Compose File and Build Infrastructure

The infrastructure for this demo is created using [docker-compose](https://docs.docker.com/compose/) to simplify complex infrastructure defined in a [ docker-compose.yaml](./docker-compose.yaml). This is a demo and should not be used for production. The [Compose](https://docs.docker.com/compose/compose-file/compose-file-v3/) file builds a [Docker](https://www.docker.com/get-started) [image](https://docs.docker.com/engine/reference/commandline/image/).

To build and start the infrastructure use the make command:

```sh
make build
```

This will instruct docker-compose to build the included [dockerfile](./dockerfile) once and then spin up six [containers](https://www.docker.com/resources/what-container) based on that file with aliases, secrets, networking, mounted volumes, and a running ssh server for this demo. Below is the running infrastructure after running `make ps`.

```sh
docker-compose ps
   Name           Command        State                  Ports                
-----------------------------------------------------------------------------
controller   /usr/sbin/sshd -D   Up                                          
lb_01        /usr/sbin/sshd -D   Up      0.0.0.0:8080->80/tcp,:::8080->80/tcp
web_01       /usr/sbin/sshd -D   Up                                          
web_02       /usr/sbin/sshd -D   Up                                          
web_03       /usr/sbin/sshd -D   Up                                          
web_04       /usr/sbin/sshd -D   Up                                          
```

There should be six containers.
| name | purpose |
| --- | --- |
| controller | This is the container the demo will be running any ansible commands and Playbooks from since it will be part of the docker networking and to just make things easier. This container also has a volume mounted from the demo system into the container at `/root/ansible` where the Ansible files will be accssed from. |
| lb_01 | This container is [load balancer ](https://www.citrix.com/solutions/app-delivery-and-security/load-balancing/what-is-load-balancing.html#:~:text=Load%20balancing%20is%20defined%20as,server%20capable%20of%20fulfilling%20them.) for the demo and it will proxy traffic to the web servers. Notice, it is the only one with port forwarding set up. The only way to access the web servers is through this container. | 
| web_0* | These containers are web servers that will serve up the demo application. The only way to access these containers is through the *lb_01* load balancer. |

The infrastructure has been set up. There is nothing else to build. 

## Run the Curl Test Script

There is a [script](./curl.sh) in the demo directory that runs [curl](https://curl.se/) on a loop in half-second intervals. This script and the printed output will be client for accessing the demo application. Go ahead and run the script using the make command:

```sh
make curl
```

The output of the script should be an error:

```sh
curl: (56) Recv failure: Connection reset by peer
```

This is fine. Curl and the infrastructure are working properly. Curl can reach the *lb_01* container, but since there is not a webserver to respond to it, Linux just rests the connection. Once the app has been deployed and the load balancer is configured, then the script will get a valid response. Just let this script run and open another terminal for the next steps.

## Ansible Overview

Ansible is a configuration management and orchestration system that uses a combination of declaritive and prodcedural patterns. These terms will be covered as the demo goes on.

### Ansible Primitives

Ansible has several primitives to discuss. 

#### Tasks

The smallest unit in Ansible is a Task. Tasks use [modules](https://docs.ansible.com/ansible/latest/user_guide/modules_intro.html) or just small units of code to execute configuration and orchestruation steps defined by the author. A task does a single thing to a target system. They can template files, create directories, install packages, start services, update local firewall rules. There's probably a task for anything you want to do with  Ansible. A simple Internet search will turn up the module you are looking for.

An example of a Task comes from the [file](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html) module.

```yaml
- name: "create a file"
  ansible.builtin.file:
    path: "/etc/foo.conf"
    owner: "root"
    group: "root"
    mode: '0644'
```

This task creates a file in the specified path, with specified ownership, and with specified permissions. Every action in Ansible looks like this. This is the configuration management and declaritive parts of the above description. This Task defines configuration in a declaritive way. The user just has to define what configuration they want and the system figures out how to do that. The user does not need to check to see if the `/etc/` directory exists, then check to see if the `foo.conf` file is already there. If the file is not there, then create it. Or if the file is there, then check to make sure the permisisons and ownership are the way they were specified. Ansible abstracts all of this for the user. This is the declaritive part. There is a delcaritive definition of state and Ansible figures it out.

 The organization of different tasks is the orchestration and procedural parts of Ansible. Tasks in a certain order and orchestrate systems and a procedural way. Let's move onto how to organize tasks to get those orchestration and procedural benefits of the system.

 ### Roles

 Ansible Tasks can be oranized into [Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) (and also into Plays, more on Plays later). Roles provide self-contained and resuable chunks of configuration that can be called from different parts of the Ansible system. Read the provided link for more information. 


### Plays

Ansible [Plays](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html) are a way to group Tasks and Roles together and apply them to specified servers or groups of servers. Read the linked documentation on Plays. 

Plays are organized into Playbooks. A Playbook is a yaml file that holds one or more Plays. Read the [When to Use Another Play](../../../infra/ansible/CONTRIBUTING.md#when-to-use-another-play) part of the Ansible CONTRIBUTING document to see when another Play or Playbook should be used.

### Inventories

The Ansible [Inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html) is the most complex part of the system, but it also provides the most power and flexibility when leveraged properly. The Inventory provides a place to define servers or groups of servers to configure and orchestrate as well as the actual configurations and procedures to take on those systems. Read the linked document and its links to learn more about inventories, groups, hosts, variables, and how all of those are merged together in the system.

## Initial Configuration and Deploy Application V1

The infrastructure is up. Now its time to configure the servers and to deploy V1 of the application. 

Ansible Playbooks can be executed from the *controller* container. There is a `make` command for this: `make exec`. This will open a [BASH](https://www.gnu.org/software/bash/) inside of the *controller* container as the root user of the container.

```sh
$ make exec
docker-compose exec controller bash
root@bb34d35e7a4a:
```

The docker-compose file mounts this demo directory inside of the *controller* container at `/root/ansible/`. From inside the container, change to that directory to see the Ansible files.

```sh
root@bb34d35e7a4a: cd /root/ansible
root@bb34d35e7a4a:~/ansible# ls -alh
total 44K
drwxr-xr-x. 1 1000 1000  272 May 17 13:49 .
drwx------. 1 root root   64 May 17 13:55 ..
-rw-r--r--. 1 1000 1000   95 May 17 13:49 .gitignore
-rw-r--r--. 1 1000 1000  427 May 17 13:49 Makefile
-rw-r--r--. 1 1000 1000 8.9K May 17 14:08 README.md
-rw-r--r--. 1 1000 1000 1.9K May 17 13:49 common_setup_playbook.yaml
-rwxr-xr-x. 1 1000 1000   82 May 17 13:49 curl.sh
-rw-r--r--. 1 1000 1000 3.0K May 17 13:49 deploy_app.yaml
-rw-r--r--. 1 1000 1000 1.5K May 17 13:49 docker-compose.yml
-rw-r--r--. 1 1000 1000  521 May 17 13:49 dockerfile
drwxr-xr-x. 1 1000 1000   52 May 17 13:49 inventories
-rw-r--r--. 1 1000 1000    8 May 14 14:13 password-file.txt
drwxr-xr-x. 1 1000 1000   68 May 17 13:49 roles
```

Now, check to see if Ansible can find the inventory hosts and have access to log in by running an Ansible [Ad-Hoc](https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html) command against all Inventory hosts using the [ping](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ping_module.html) module.

```sh
root@bb34d35e7a4a:~/ansible# ansible -i inventories/production/ all -m ping
web_02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
web_03 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
web_01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
lb_01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
web_04 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Ansible can access all four web servers and the load balancer. Now it is time to run the [common setup Playbook](common_setup_playbook.yaml) to configure the infrastructure and deploy the first version of the application. The below command also uses Ansible [Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html). Vault requires a password file to be passed in as an argument when the `ansible-playbook` command is invoked with `--vault-password-file`. Run the following command to create a password file before running the Ansible command:

```sh
echo -n 'password' > password.txt
```

This will create a text file with the word `password` inside. This is the password to decrypt the Ansible Vault secret at `inventories/production/group_vars/web/vault.yaml`. Now, run the `ansible-playbook` command below.

```sh
root@bb34d35e7a4a:~/ansible# ansible-playbook -i inventories/production/ common_setup_playbook.yaml --vault-password-file ./password-file.txt 
```

After the Playbook finishes, the `curl` script running in the other terminal should start returning json:

```sh
{
    "host": "web_02",
    "host_id": "zyxw",
    "opinion": "Matt Smith was the best Doctor.",
    "secret": "doiuejfkdoeiu",
    "service_level": "production",
    "version": "v1"
}

{
    "host": "web_02",
    "host_id": "zyxw",
    "opinion": "Matt Smith was the best Doctor.",
    "secret": "doiuejfkdoeiu",
    "service_level": "production",
    "version": "v1"
}

{
    "host": "web_02",
    "host_id": "zyxw",
    "opinion": "Matt Smith was the best Doctor.",
    "secret": "doiuejfkdoeiu",
    "service_level": "production",
    "version": "v1"
}

{
    "host": "web_04",
    "host_id": "zyxw",
    "opinion": "Matt Smith was the best Doctor.",
    "secret": "doiuejfkdoeiu",
    "service_level": "production",
    "version": "v1"
}

{
    "host": "web_02",
    "host_id": "zyxw",
    "opinion": "Matt Smith was the best Doctor.",
    "secret": "doiuejfkdoeiu",
    "service_level": "production",
    "version": "v1"
}
```

Version one of the application has been deployed. Now it's time to update and deploy the next version.

## Deploy Application V1.1

There is a second Playbook that will update and deploy the *v1.1* version of the application. Run the following command to execute the [deploy appliaction](deploy_app.yaml) Playbook.

```sh
ansible-playbook -i inventories/production deploy_app.yaml --vault-password-file password.txt
```

This Playbook is a little different than the first. It has breakpoints that use the Ansible [pause](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pause_module.html) module. Make sure to read the prompt and follow the instructions to see the different parts of the rollout. Hit `Enter` on your keyboard to proceed through each prompt.

After the Playbook is finished the `curl` return should have changed:

```sh
{
    "host": "web_01",
    "host_id": "25",
    "opinion": "Darth Bane was the best Sith Lord.",
    "secret": "doiuejfkdoeiu",
    "service_level": "production",
    "version": "v1.1"
}

{
    "host": "web_03",
    "host_id": "zyxw",
    "opinion": "Darth Bane was the best Sith Lord.",
    "secret": "doiuejfkdoeiu",
    "service_level": "production",
    "version": "v1.1"
}

{
    "host": "web_03",
    "host_id": "zyxw",
    "opinion": "Darth Bane was the best Sith Lord.",
    "secret": "doiuejfkdoeiu",
    "service_level": "production",
    "version": "v1.1"
}

{
    "host": "web_01",
    "host_id": "25",
    "opinion": "Darth Bane was the best Sith Lord.",
    "secret": "doiuejfkdoeiu",
    "service_level": "production",
    "version": "v1.1"
}
```

Notice the the `option` and the `version` fields of the response have been updated to what is expected from the Playbook.

## Tear Down

The demo is complete. Feel free to read through Playbook files, Inventories, and Roles to see how things are structured. There are comments and links throughout this demo project. Also, before to read the links in this README as well.

The infrastructure can be down by first exiting the *controller* container.

```sh
root@bb34d35e7a4a:~/ansible# exit
exit
```

Next, use the following `make` command to tear down the containers. 

```sh
make down
rm -rf .bash_history
docker-compose down
Stopping web_02     ... done
Stopping web_01     ... done
Stopping lb_01      ... done
Stopping web_04     ... done
Stopping controller ... done
Stopping web_03     ... done
Removing web_02     ... done
Removing web_01     ... done
Removing lb_01      ... done
Removing web_04     ... done
Removing controller ... done
Removing web_03     ... done
Removing network 05-14-2021-ansible-core_demo
```

That's it. The demo is complete. If you have any questions or concerns, please reachout to the [CODEOWNERS](../../../CODEOWNERS.md) of the *infra* directory.

Thank you for your time.