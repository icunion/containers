#!/usr/bin/env bash
grep \- variants.cfg.yml | sed -e "s/^  - //" | while read version ; do
   docker build -t icu-php:$version-fpm-alpine -f dockerfiles/Dockerfile.icu-php.$version-fpm-alpine .
done
