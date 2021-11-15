#!/bin/sh
flux bootstrap git --url=ssh://git@git.xirion.net:2222/olympus/flux.git --branch=main --path=cluster/base/ --ssh-key-algorithm=ed25519 --components-extra=image-reflector-controller,image-automation-controller
