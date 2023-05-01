local dsl = import '_dsl.libsonnet';

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
                orbs.circleci.go.jobs.run_tests('test', go_version='1.17'),
                workflows.job('build',
                    image='cimg/go:1.17',
                    steps=[
                        steps.checkout(),
                        orbs.circleci.go.load_cache(),
                        orbs.circleci.go.mod_download_cached(),
                        steps.run('make build-linux'),
                        orbs.circleci.go.save_cache(),
                        steps.persist_to_workspace('dist', 'bin')
                    ],
                ),

                orbs.circleci.docker.jobs.publish(
                    image=docker_image,
                    tag='$CIRCLE_SHA1,$CIRCLE_BRANCH,latest',
                    requires=['build','test'],
                    filters=workflows.filter_branches(only=['main']),
                    docker_password='DOCKERHUB_PASSWORD',
                    before_build=[
                        steps.attach_workspace('/tmp/dist'),
                        steps.run('mv /tmp/dist ./dist')
                    ],
                )
            ],
        ),
    ],
)
