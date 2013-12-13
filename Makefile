NAME = phusion/passenger
VERSION = 0.9.3

.PHONY: all build_all \
	build_customizable build_ruby18 build_ruby19 build_ruby20 build_nodejs \
	tag_latest release clean

all: build_all

build_all: build_customizable build_ruby18 build_ruby19 build_ruby20 build_nodejs

# Docker doesn't support sharing files between different Dockerfiles. -_-
# So we copy things around.
build_customizable:
	rm -rf customizable_image
	cp -pR image customizable_image
	docker build -t $(NAME)-customizable:$(VERSION) -rm customizable_image

build_ruby18:
	rm -rf ruby18_image
	cp -pR image ruby18_image
	echo ruby18=1 >> ruby18_image/buildconfig
	echo final=1 >> ruby18_image/buildconfig
	docker build -t $(NAME)-ruby18:$(VERSION) -rm ruby18_image

build_ruby19:
	rm -rf ruby19_image
	cp -pR image ruby19_image
	echo ruby19=1 >> ruby19_image/buildconfig
	echo final=1 >> ruby19_image/buildconfig
	docker build -t $(NAME)-ruby19:$(VERSION) -rm ruby19_image

build_ruby20:
	rm -rf ruby20_image
	cp -pR image ruby20_image
	echo ruby20=1 >> ruby20_image/buildconfig
	echo final=1 >> ruby20_image/buildconfig
	docker build -t $(NAME)-ruby20:$(VERSION) -rm ruby20_image

build_nodejs:
	rm -rf nodejs_image
	cp -pR image nodejs_image
	echo nodejs=1 >> nodejs_image/buildconfig
	echo final=1 >> nodejs_image/buildconfig
	docker build -t $(NAME)-nodejs:$(VERSION) -rm nodejs_image

tag_latest:
	docker tag $(NAME)-customizable:$(VERSION) $(NAME)-customizable:latest
	docker tag $(NAME)-ruby18:$(VERSION) $(NAME)-ruby18:latest
	docker tag $(NAME)-ruby19:$(VERSION) $(NAME)-ruby19:latest
	docker tag $(NAME)-ruby20:$(VERSION) $(NAME)-ruby20:latest
	docker tag $(NAME)-nodejs:$(VERSION) $(NAME)-nodejs:latest

release: tag_latest
	@if ! docker images $(NAME)-customizable | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)-customizable version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)-ruby18 | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)-ruby18 version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)-ruby19 | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)-ruby19 version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)-ruby20 | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)-ruby20 version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)-nodejs | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)-nodejs version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)-customizable
	docker push $(NAME)-ruby18
	docker push $(NAME)-ruby19
	docker push $(NAME)-ruby20
	docker push $(NAME)-nodejs
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"

clean:
	rm -rf customizable_image
	rm -rf ruby18_image
	rm -rf ruby19_image
	rm -rf ruby20_image
	rm -rf nodejs_image
