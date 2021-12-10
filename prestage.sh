#!/usr/bin/env bash


# WARNING: The directory placed here will be subject to a rm -rf operation.
# See prepare_prestaged_directory() for details.
PRESTAGE_DIRECTORY='./prestaged'


get_dapr_cli() {
	echo -e "\nFetching https://github.com/dapr/cli/releases/download/${DAPR_VERSION}/dapr_${OS}_${ARCH}.tar.gz..."
	curl -L https://github.com/dapr/cli/releases/download/${DAPR_VERSION}/dapr_${OS}_${ARCH}.tar.gz -o ${PRESTAGE_DIRECTORY}/dapr_${OS}_${ARCH}.tar.gz
}


get_daprd() {
	echo -e "\nFetching https://github.com/dapr/dapr/releases/download/${DAPR_VERSION}/daprd_${OS}_${ARCH}.tar.gz..."
	curl -L https://github.com/dapr/dapr/releases/download/${DAPR_VERSION}/daprd_${OS}_${ARCH}.tar.gz -o ${PRESTAGE_DIRECTORY}/daprd_${OS}_${ARCH}.tar.gz
}


get_options() {
	while getopts a:o:v: flag; do
		case "${flag}" in
			a) ARCH=${OPTARG};;
			o) OS=${OPTARG};;
			v) DAPR_VERSION=${OPT_ARG};;
		esac
	done

	if [ -z "${ARCH}" ]; then
		ARCH=$(uname -m)
	fi

	if [ -z "${OS}" ]; then
                OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')
        fi

	if [ -z "${DAPR_VERSION}" ]; then
		dapr_release_url="https://api.github.com/repos/dapr/dapr/releases"
                DAPR_VERSION=$(curl -s ${dapr_release_url} | grep \"tag_name\" | grep -v rc | awk 'NR==1{print $2}' |  sed -n 's/\"\(.*\)\",/\1/p')
        fi

	case $ARCH in
        	armv7*) ARCH="arm";;
        	aarch64) ARCH="arm64";;
        	x86_64) ARCH="amd64";;
    	esac

	echo -e "Prestaging dapr installation for:\n"
	echo -e "Architecture: ${ARCH}"
	echo -e "OS: ${OS}"
	echo -e "Dapr Version: ${DAPR_VERSION}"
}


prepare_prestaged_directory() {
	rm -rf ${PRESTAGE_DIRECTORY}
	mkdir -p ${PRESTAGE_DIRECTORY}
	cp -r ./components ${PRESTAGE_DIRECTORY}
	cp config.yaml ${PRESTAGE_DIRECTORY}
}


prestage_docker_images() {
	echo ""
	docker pull daprio/dapr:1.5.1
	echo ""
	docker pull redis:latest
	echo ""
	docker pull openzipkin/zipkin:latest
}


get_options
prepare_prestaged_directory
prestage_docker_images
get_dapr_cli
get_daprd
