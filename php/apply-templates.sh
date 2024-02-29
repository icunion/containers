#!/usr/bin/env bash
docker run -it --rm \
           --user $(id -u):$(id -g) \
           -v ${PWD}:${PWD} -w ${PWD} \
       ghcr.io/bossm8/dockerfile-templater:latest \
           --dockerfile.tpl Dockerfile.tpl \
           --variants.def variants.yml \
           --variants.cfg variants.cfg.yml
