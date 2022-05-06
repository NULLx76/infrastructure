#!/bin/sh
flux bootstrap git --url=ssh://gitea@git.0x76.dev:42/v/infrastructure.git --branch=main --path=flux/cluster/base/ --ssh-key-algorithm=ed25519 --components-extra=image-reflector-controller,image-automation-controller
