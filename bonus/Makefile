all: up

up:
	@if ! k3d cluster list | grep -q $(USER); then \
		echo "Error: k3d cluster '$(USER)' is not running or does not exist"; \
		exit 1; \
	fi
	HOST_IP=$$(hostname -I | cut -d " " -f1) vagrant up
	./scripts/bonus.sh

down:
	vagrant destroy -f

clean:
	vagrant box prune
	rm -rf ~/.vagrant.d/tmp/*
	rm -rf ~/VirtualBox\ VMs/

s:
	vagrant ssh GitlabS

re: down up

.PHONY: all up down clean re s
