#!/bin/sh

docker build . -t k8s_cluster/tools

if [ $? -eq 0 ]; then
    docker rm -f k8s_cluster-tools 
    
    docker run -it \
        -v $PWD/app:/root/app \
        -p 8001:8001 \
        --name k8s_cluster-tools k8s_cluster/tools
fi
