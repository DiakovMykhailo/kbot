# Makefile

APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=diakovmykhailo
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
PLATFORMS=linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64

 #Логін до GitHub Container Registry
#.PHONY: login
#login:
#	@echo "Logging in to GitHub Container Registry"
#	echo $(GHCR_TOKEN) | docker login ghcr.io -u $(GHCR_USERNAME) --password-stdin

# Форматування коду
format:
	gofmt -s -w ./

# Завантаження залежностей
get:
	go get

# Лінтинг коду
lint:
	golint

# Тестування коду
test:
	go test -v

# Збірка коду
build: format get
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build -v -o kbot -ldflags "-X=github.com/DiakovMykhailo/kbot/cmd.appVersion=$(VERSION)"

# Збірка Docker образу для кожної платформи
.PHONY: $(PLATFORMS)
$(PLATFORMS):
	@echo "Building for platform $@"
	docker buildx build --platform $@ --build-arg TARGETARCH=$(shell echo $@ | cut -d'/' -f2) -t $(REGISTRY)/$(APP):$(VERSION)-$(shell echo $@ | tr '/' '-') --push .

# Загальний збір усіх платформ
.PHONY: all
all: login $(PLATFORMS)

# Встановлення buildx, якщо не встановлено
.PHONY: setup
setup:
	@echo "Setting up buildx"
	docker buildx create --use

# Очистка
.PHONY: clean
clean:
	rm -rf kbot
	docker rmi $(foreach platform, $(PLATFORMS), $(REGISTRY)/$(APP):$(VERSION)-$(shell echo $(platform) | tr '/' '-'))