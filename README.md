ICU Containers
==============

Containers used by Imperial College Union as common base images for other projects. There are sets of containers for `php`.

## Generating Dockerfiles from templates

Each container set provides multiple Dockerfiles for required software versions. Dockerfiles are generated from a common template using [dockerfile-templater](https://github.com/bossm8/dockerfile-templater).

To regenerate Dockerfiles, run the `apply-templates.sh` script in the target container set folder:

```sh
# e.g. for php
cd php
./apply-templates.sh
```

This will output regenerated files in the `dockerfiles` subfolder. These files are retained in version control, so don't forget to commit them along with changes to the template.

## Building and publishing an image

To build:

```sh
# e.g. for php 8.1
cd php
docker build -t icu-php:8.1-fpm-alpine -f dockerfiles/Dockerfile.icu-php.8.1-fpm-alpine .
```

Images are published via the organizational [GitHub Packages Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) by authorized members of the Systems Team. First log in to the container registry:

```sh
export CR_PAT=YOUR_TOKEN
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

You can then tag a locally built image and push to the registry:

```sh
# e.g. for php 8.1
docker tag icu-php:8.1-fpm-alpine ghcr.io/icunion/icu-php:8.1-fpm-alpine
docker push ghcr.io/icunion/icu-php:8.1-fpm-alpine
```

## PHP

The PHP container set provides fpm alpine images for versions 8.1, 8.2, and 8.3. They use the stock php fpm alpine images, and build on them by including additional extensions required by our apps, and also including `composer`.

## License

Copyright (c) 2024 Imperial College Union

License: [MIT](https://opensource.org/licenses/MIT)