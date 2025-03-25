all: check up

check:
	@sudo ./scripts/pre-requisitions.sh

up:
	./scripts/setup-k3d-argocd.sh

clean:
	k3d cluster delete $(USERNAME)
	docker volume prune -f
	docker network prune -f
	docker image prune -a -f

re: clean up

.PHONY: all check up clean re
