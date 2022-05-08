local full_dsl = import '_dsl.libsonnet';
local dsl = full_dsl.circleci;


local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;
local orbs = dsl.orbs;
local executors = dsl.executors;


pipeline.new(
    jobs=[
        jobs.new(
            'build-and-test',
            executor_type='docker',
            executor_options=[executors.docker.new('ubuntu:20.04')],
            steps=[
                steps.checkout(),
                steps.run('echo "Hello World"', name='Install dependencies'),
            ],
        ),
    ],
    workflows=[
        workflows.new(
            'main',
            jobs=[
                workflows.job('build-and-test'),
            ],
        ),
    ],
)
