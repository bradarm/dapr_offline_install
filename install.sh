#!/usr/bin/env bash


DAPR_PLACEMENT_NAME="dapr_placement"
DAPR_REDIS_NAME="dapr_redis"
DAPR_ZIPKIN_NAME="dapr_zipkin"


docker_remove_if_exists() {
	if [[ -n $(docker container ls | grep $1) ]]; then
		echo "Removing exiting docker container $1..."
		docker stop $1
		docker rm $1
		echo "Done"
	fi
}


docker_run_dapr_placement() {
	echo "Launching dapr placement service..."
	docker_remove_if_exists dapr_placement
	docker run \
		--name dapr_placement \
		--restart "always" \
		-d \
		--entrypoint "./placement" \
		-p "50005:50005" \
		daprio/dapr:1.5.1
	echo "Done"
}


docker_run_redis() {
	echo "Launching redis service..."
	docker_remove_if_exists dapr_redis
	docker run \
		--name dapr_redis \
		--restart "always" \
		-d \
		-p "6379:6379" \
		redis
	echo "Done"
}


docker_run_zipkin() {
	echo "Launching zipkin service..."
	docker_remove_if_exists dapr_zipkin
	docker run \
		--name dapr_zipkin \
		--restart "always" \
		-d \
		-p "9411:9411" \
		openzipkin/zipkin
	echo "Done"
}


install_components() {
	echo "Installing dapr components..."
	cp -r ./components ~/.dapr
	cp -r config.yaml ~/.dapr
	echo "Done"
}


install_dapr_cli() {
	echo "Installing Dapr CLI..."
	tar xf ./cli/dapr_linux_arm64.tar.gz -C ./cli
	chmod o+x ./cli/dapr
	sudo mv ./cli/dapr /usr/local/bin
	/usr/local/bin/dapr --version
	echo "Done"
	echo "To get started with Dapr, please visit https://docs.dapr.io/getting-started/"
}

install_daprd() {
	echo "Installing daprd..."
        tar xf ./daprd/daprd_linux_arm64.tar.gz -C ./daprd
        chmod o+x ./daprd/daprd
	mkdir -p ~/.dapr/bin
        mv ./daprd/daprd ~/.dapr/bin
	echo "Done"
	echo -e "Dapr runtime installed to ~/.dapr/bin, you may run the following to add it to your path if you want to run daprd directly:\nexport PATH=\$PATH:~/.dapr/bin"
}


run_dapr_uninstall() {
	echo "Runing dapr uninstall..."
	dapr uninstall
	echo "Done"
}


install_dapr_cli
run_dapr_uninstall
install_daprd
install_components
docker_run_redis
docker_run_zipkin
docker_run_dapr_placement
