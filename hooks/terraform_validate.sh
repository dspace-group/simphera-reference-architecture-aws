#!/bin/sh


[ ! -d ".terraform" ] && terraform init -lock=false # Unfortunately, kubernetes-addons submodule must be downloaded
terraform validate