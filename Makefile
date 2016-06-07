.DEFAULT_GOAL := all

.PHONY: all
all:
	vagrant plugin list | grep vbguest || \
		vagrant plugin install vagrant-vbguest
	vagrant up

.PHONY: puppet
puppet:
	vagrant provision --provision-with puppet

.PHONY: traffic
traffic:
	./generate_traffic.py

.PHONY: clean
clean:
	vagrant destroy -f
