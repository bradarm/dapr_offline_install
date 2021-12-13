#!/usr/bin/env bash


DAPR_PLACEMENT_NAME="dapr_placement"
DAPR_REDIS_NAME="dapr_redis"
DAPR_ZIPKIN_NAME="dapr_zipkin"

PRESTAGE_DIRECTORY='./prestaged'


docker_remove_if_exists() {
    if [[ -n $(docker container ls | grep $1) ]]; then
        echo -e "\nRemoving existing docker container $1..."
        docker stop $1
        docker rm $1
        echo ""
    fi
}


docker_run_dapr_placement() {
    echo -e "\nLaunching dapr placement service..."
    docker_remove_if_exists dapr_placement
    docker load -i ${PRESTAGE_DIRECTORY}/dapr_placement.tar
    docker run \
        --name dapr_placement \
        --restart "always" \
        -d \
        --entrypoint "./placement" \
        -p "50005:50005" \
        daprio/dapr:1.5.1
}


docker_run_redis() {
    echo -e "\nLaunching redis service..."
    docker_remove_if_exists dapr_redis
    docker load -i ${PRESTAGE_DIRECTORY}/redis.tar
    docker run \
        --name dapr_redis \
        --restart "always" \
        -d \
        -p "6379:6379" \
        redis
}


docker_run_zipkin() {
    echo -e "\nLaunching zipkin service..."
    docker_remove_if_exists dapr_zipkin
    docker load -i ${PRESTAGE_DIRECTORY}/zipkin.tar
    docker run \
        --name dapr_zipkin \
        --restart "always" \
        -d \
        -p "9411:9411" \
        openzipkin/zipkin
}


install_components() {
    echo -e "\nInstalling dapr components..."
    cp -r ${PRESTAGE_DIRECTORY}/components ~/.dapr
    cp ${PRESTAGE_DIRECTORY}/config.yaml ~/.dapr
}


install_dapr_cli() {
    echo -e "\nInstalling dapr CLI..."
    tar xf ${PRESTAGE_DIRECTORY}/dapr_*.tar.gz -C ${PRESTAGE_DIRECTORY}
    chmod o+x ${PRESTAGE_DIRECTORY}/dapr
    sudo mv ${PRESTAGE_DIRECTORY}/dapr /usr/local/bin
    /usr/local/bin/dapr --version
    echo "To get started with Dapr, please visit https://docs.dapr.io/getting-started/"
}


install_daprd() {
    echo -e "\nInstalling daprd..."
    tar xf ${PRESTAGE_DIRECTORY}/daprd_*.tar.gz -C ${PRESTAGE_DIRECTORY}
    chmod o+x ${PRESTAGE_DIRECTORY}/daprd
    mkdir -p ~/.dapr/bin
    mv ${PRESTAGE_DIRECTORY}/daprd ~/.dapr/bin
    echo -e "Dapr runtime installed to ~/.dapr/bin, you may run the following to add it to your path if you want to run daprd directly:\nexport PATH=\$PATH:~/.dapr/bin"
}


run_dapr_uninstall() {
    echo -e "\nRuning dapr uninstall..."
    dapr uninstall
}


install_dapr_cli
run_dapr_uninstall
install_daprd
install_components
docker_run_redis
docker_run_zipkin
docker_run_dapr_placement
echo -e "\nDapr installed successfully"
