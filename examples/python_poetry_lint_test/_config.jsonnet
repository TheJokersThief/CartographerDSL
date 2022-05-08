local full_dsl = import "_dsl.libsonnet";
local dsl = full_dsl.circleci;


local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;
local orbs = dsl.orbs;


// build-and-test:
//     executor: python/default
//     steps:
//       - checkout
//       - python/load-cache
//       - run:
//           command: make dev
//           name: Install dependencies
//       - python/save-cache
//       - run:
//           command: make lint
//           name: Linting
//       - run:
//           command: make test
//           name: Test
//
// workflows:
//   main:
//     jobs:
//       - build-and-test


pipeline.new(
    orbs=orbs.new({'python': 'circleci/python@0.2.1'}),
    jobs=[
        jobs.new(
            'build-and-test',
            executor_ref="python/default",
            steps=[
                steps.checkout(),
                'python/load-cache',
                steps.run('poetry install', name='Install dependencies'),
                'python/save-cache',
                steps.run('poetry run flake8 --ignore F821,W504 src tests', name='Linting'),
                steps.run('poetry run pytest tests --cov=src --strict tests', name='Tests'),
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
