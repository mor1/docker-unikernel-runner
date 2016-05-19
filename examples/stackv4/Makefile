.PHONY: all
all: mir-stackv4

# Mirage 'stackv4' sample: intermediate build container.
mir-stackv4.tar.gz: Dockerfile.stackv4-build
	docker build -t mir-stackv4-build -f Dockerfile.stackv4-build .
	docker run --rm mir-stackv4-build > mir-stackv4.tar.gz

# Mirage 'stackv4' sample: mir-stackv4.
.PHONY: mir-stackv4
mir-stackv4: mir-stackv4.tar.gz Dockerfile.stackv4 mir-runner
	docker build -t mir-stackv4 -f Dockerfile.stackv4 .
