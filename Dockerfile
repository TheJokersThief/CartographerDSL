FROM cimg/base:2022.04-20.04

ADD dist/bin/linux/amd64/cartographer-dsl /bin/cartographer-dsl
ADD dsl /dsl

WORKDIR /project
ADD docker/config.yaml /etc/cartographer-dsl/config.yaml


CMD ["/bin/cartographer-dsl"]
