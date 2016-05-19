.PHONY: all
all: mir-runner

# Runner base image: intermediate build container.
runner.tar.gz: src/*.c src/Makefile Dockerfile.runner-build
	docker build -t mir-runner-build -f Dockerfile.runner-build .
	docker run --rm mir-runner-build > runner.tar.gz

# Runner base image: mir-runner.
.PHONY: mir-runner
mir-runner: runner.tar.gz Dockerfile.runner
	docker build -t mir-runner -f Dockerfile.runner .

.PHONY: push
push: mir-runner
	docker tag mir-runner mor1/mir-runner:latest
	docker push mor1/mir-runner:latest

.PHONY: clean clobber
clean:
	$(RM) runner.tar.gz mir-stackv4.tar.gz mir-static_website.tar.gz

# Run to clean all images, include intermediate containers.
clobber: clean
	docker rmi -f mir-runner mir-runner-build \
	    mir-stackv4 mir-stackv4-build \
	    mir-static_website mir-static_website-build
