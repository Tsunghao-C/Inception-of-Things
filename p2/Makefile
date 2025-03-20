all: up

up:
	vagrant up

down:
	vagrant destroy -f

clean:
	vagrant box prune
	rm -rf ~/.vagrant.d/tmp/*
	rm -rf ~/VirtualBox\ VMs/

s:
	vagrant ssh $(USERNAME)S

re: down up

.PHONY: all up down clean re s
