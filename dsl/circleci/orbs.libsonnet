{
    new(
        orbs={},
    )::
        {
            orbs+: orbs,
        },

    circleci: {
        go: import "orbs/circleci_go/_main.libsonnet",
        docker: import "orbs/circleci_docker/_main.libsonnet",
    },
}
