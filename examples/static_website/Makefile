.PHONY: all
all: mir-static_website

# Mirage 'static_website' sample: intermediate build container.
mir-static_website.tar.gz: Dockerfile.static_website-build
	docker build -t mir-static_website-build -f Dockerfile.static_website-build .
	docker run --rm mir-static_website-build > mir-static_website.tar.gz

# Mirage 'static_website' sample: mir-static_website.
.PHONY: mir-static_website
mir-static_website: mir-static_website.tar.gz Dockerfile.static_website mir-runner
	docker build -t mir-static_website -f Dockerfile.static_website .
