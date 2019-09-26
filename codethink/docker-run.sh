#!/bin/bash
# Run the build container
declare -r br_ccache="/home/codething/buildroot-ccache"
declare -r br_dl="/home/codething/buildroot-dl"

docker run \
	--mount=type=bind,src="$br_ccache",dst="$br_ccache" \
	--mount=type=bind,src="$br_dl",dst="$br_dl" \
	--mount=type=bind,src=$(pwd),dst=/mnt \
	-it tpreston/d9-buildroot "$@"
