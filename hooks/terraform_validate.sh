#!/bin/sh

ls -ahl

export TF_PLUGIN_CACHE_DIR="/src/cache"
echo $TF_PLUGIN_CACHE_DIR

[ "$(ls -A /src/cache)" ] && echo "Not Empty" || terraform init
#[ ! -d ".terraform" ] && terraform init -lock=false # Unfortunately, kubernetes-addons submodule must be downloaded
terraform validate

