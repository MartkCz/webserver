REPO:=martkcz/webserver
VERSION:=8.1.8-r3
PHP:=81

all: build release

build:
	docker build --build-arg "PHP=${PHP}" -t $(REPO):${VERSION} .

build-force:
	docker build --build-arg "PHP=${PHP}" --no-cache -t $(REPO):${VERSION} .

release:
	docker push $(REPO):${VERSION}

test:
	sh tests/run.sh "${REPO}:${VERSION}"

test-server:
	sh tests/webserver.sh "${REPO}:${VERSION}"
