all: up

up:
	./scripts/setup-k3d-argocd.sh

clean:
	k3d cluster delete mycluster

re: down up

.PHONY: all up down clean re
