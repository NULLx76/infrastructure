#!/bin/sh
flux bootstrap git --url=ssh://git@git.xirion.net:2222/0x76/infrastructure.git --branch=main --path=cluster/base/ --ssh-key-algorithm=ed25519 --components-extra=image-reflector-controller,image-automation-controller
