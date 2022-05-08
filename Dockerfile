FROM debian:stable

RUN apt-get update && apt-get -y --no-install-recommends install curl jq

RUN adduser --disabled-password cartographer-dsl-user

ADD dist/bin/linux/amd64/cartographer-dsl /bin/cartographer-dsl
ADD dsl /dsl

USER cartographer-dsl-user
WORKDIR /project
ADD docker/config.yaml /etc/cartographer-dsl/config.yaml


CMD ["/bin/cartographer-dsl"]
