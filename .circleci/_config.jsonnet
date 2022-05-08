local full_dsl = import "_dsl.libsonnet";
local dsl = full_dsl.circleci;


local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;
local orbs = dsl.orbs;


pipeline.new(
    jobs=[
        jobs.new(
            'build-and-test',
            executor_ref="python/default",
            steps=[
                steps.checkout(),
                steps.run('echo "Hello World"', name='Install dependencies'),
            ],
        )
    ],
    workflows=[
        workflows.new('main',
            jobs=[
                workflows.job('build-and-test')
            ],
        )
    ],
)
