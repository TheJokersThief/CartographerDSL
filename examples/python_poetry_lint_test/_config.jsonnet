local dsl = import '_dsl.libsonnet';

local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;
local orbs = dsl.orbs;


pipeline.new(
    orbs=orbs.new({ python: 'circleci/python@0.2.1' }),
    workflows=[
        workflows.new(
            'main',
            jobs=[
                workflows.job(
                    'build-and-test',
                    executor='python/default',
                    steps=[
                        steps.checkout(),
                        'python/load-cache',
                        steps.run('poetry install', name='Install dependencies'),
                        'python/save-cache',
                        steps.run('poetry run flake8 --ignore F821,W504 src tests', name='Linting'),
                        steps.run('poetry run pytest tests --cov=src --strict tests', name='Tests'),
                    ],
                ),
            ],
        ),
    ],
)
