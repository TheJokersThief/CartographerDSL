local full_dsl = import '_dsl.libsonnet';
local dsl = full_dsl.circleci;


local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;
local orbs = dsl.orbs;


local docker_image = 'thejokersthief/cartographer-dsl';


pipeline.new(
    orbs=(
        orbs.circleci.go.include()
        + orbs.circleci.docker.include()
    ),
    workflows=[
        workflows.new('main',
            jobs=[
                orbs.circleci.go.jobs.run_tests('build-and-test', go_version='1.17'),
                orbs.circleci.docker.jobs.publish(
                    image=docker_image,
                    tag='$CIRCLE_SHA1,$CIRCLE_BRANCH',
                    requires=['build-and-test'],
                    docker_password='DOCKERHUB_PASSWORD',
                    before_build=['make build-linux'],
                )
            ],
        ),
    ],
)
