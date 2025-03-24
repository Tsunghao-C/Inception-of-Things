all: check up

check:
	@sudo ./scripts/pre-requisitions.sh

up:
	./scripts/setup-k3d-argocd.sh

clean:
	k3d cluster delete $(USERNAME)

re: clean up

.PHONY: all check up clean re
