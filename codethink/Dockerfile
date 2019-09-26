FROM debian:9
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
	bash \
	bc \
	binutils \
	build-essential \
	bzip2 \
	cpio \
	debianutils \
	file \
	g++ \
	gcc \
	git \
	gzip \
	make \
	patch \
	perl \
	python \
	rsync \
	sed \
	tar \
	time \
	unzip \
	wget

# Share the cache directories
RUN mkdir -p \
	/home/codethink/buildroot-ccache \
	/home/codethink/buildroot-dl

RUN useradd -r -u 1001 tpreston
USER tpreston
WORKDIR /mnt

# Run `make <defconfig>` first
CMD make
