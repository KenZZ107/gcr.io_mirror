#!/bin/sh

k8s_img=$1
mirror_img=$(echo ${k8s_img}|
        sed 's/quay\.io/anjia0532\/quay/g;s/ghcr\.io/anjia0532\/ghcr/g;s/registry\.k8s\.io/anjia0532\/google-containers/g;s/k8s\.gcr\.io/anjia0532\/google-containers/g;s/gcr\.io/anjia0532/g;s/\//\./g;s/ /\n/g;s/anjia0532\./anjia0532\//g' |
        uniq)

if [ -x "$(command -v docker)" ]; then
  sudo docker pull ${mirror_img}
  sudo docker tag ${mirror_img} ${k8s_img}
  if [ "$2"x = "--microk8s"x ]; then
      saveImage=${1#:}
      docker save $saveImage > ~/.docker_image.tmp.tar
      microk8s.ctr image import ~/.docker_image.tmp.tar
      rm ~/.docker_image.tmp.tar
  fi
  exit 0
fi

ctr_cmd="ctr"
if [ "$2"x = "--microk8s"x ]; then
  ctr_cmd="microk8s ${ctr_cmd}"
fi

if [ -x "$(command -v ${ctr_cmd})" ]; then
  sudo $ctr_cmd} -n k8s.io image pull docker.io/${mirror_img}
  sudo ${ctr_cmd} -n k8s.io image tag docker.io/${mirror_img} ${k8s_img}
  exit 0
fi

echo "command not found:docker or ctr"
