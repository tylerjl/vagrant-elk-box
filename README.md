This vagrant box installs elasticsearch, logstash and kibana 4.

## Prequisites

[VirtualBox](https://www.virtualbox.org/) and [Vagrant](http://www.vagrantup.com/).

## Up and SSH

To get started run:

    make

Elasticsearch will be available on the host machine at [http://localhost:9200/](http://localhost:9200/), Kibana at [http://localhost:5601/](http://localhost:5601/)

To clean up (remove the virtual machine):

    make clean

## Vagrant commands

```shell
vagrant up # starts the machine
vagrant ssh # ssh to the machine
vagrant halt # shut down the machine
vagrant provision # applies the bash and puppet provisioning
```
