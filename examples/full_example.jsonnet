// References example: https://circleci.com/docs/2.0/configuration-reference/#example-full-configuration

local dsl = import '_dsl.libsonnet';

local pipeline = dsl.circleci.pipeline;
local steps = dsl.circleci.steps;
local workflows = dsl.circleci.workflows;
local jobs = dsl.circleci.jobs;
local executors = dsl.circleci.executors;

local executor_auth = {
    username: 'mydockerhub-user',
    password: '$DOCKERHUB_PASSWORD',
};

local environments = ['staging', 'production'];

local environment_jobs = [
    jobs.new(
        'deploy-%s' % [environment],
        executor_type='docker',
        executor_options=[
            executors.options.docker.new('ubuntu:14.04', auth=executor_auth),
        ],
        working_directory='/tmp/my-project',
        steps=[
            steps.run(
                name='Deploy if tests pass and branch is %s' % [environment],
                command='ansible-playbook site.yml -i %s' % [environment],
            ),
        ],
    )
    for environment in environments
];

local environments = ['staging', 'production'];

local environment_jobs = [
    jobs.new(
        'deploy-%s' % [environment],
        executor_type="docker",
        executor_options=[
            executors.options.docker.new("ubuntu:14.04", auth=executor_auth),
        ],
        working_directory = '/tmp/my-project',
        steps = [
            steps.run(
                name='Deploy if tests pass and branch is %s' % [environment],
                command='ansible-playbook site.yml -i %s' % [environment],
            )
        ],
    ) for environment in environments
];

pipeline.new(
    jobs=[
        jobs.new(
            'build',
            executor_type='docker',
            executor_options=[
                executors.options.docker.new('ubuntu:14.04', auth=executor_auth),
                executors.options.docker.new('mongo:2.6.8', auth=executor_auth, command=['mongod', '--smallfiles']),
                executors.options.docker.new('postgres:14.2', auth=executor_auth, environment={ POSTGRES_USER: 'user' }),
                executors.options.docker.new('redis@sha256:54057dd7e125ca41afe526a877e8bd35ec2cdd33b9217e022ed37bdcf7d09673', auth=executor_auth),
                executors.options.docker.new('rabbitmq:3.5.4', auth=executor_auth),
            ],
            environment={ TEST_REPORTS: '/tmp/test-reports' },
            working_directory='~/my-project',
            steps=[
                steps.checkout(),
                steps.run('echo 127.0.0.1 devhost | sudo tee -a /etc/hosts'),
                steps.run(|||
                    sudo -u root createuser -h localhost --superuser ubuntu &&
                    sudo createdb -h localhost test_db
                |||),
                steps.restore_cache(['v1-my-project-{{ checksum "project.clj" }}', 'v1-my-project-']),
                steps.run(environment={ SSH_TARGET: 'localhost', TEST_ENV: 'linux' }, command=|||
                    set -xu
                    mkdir -p ${TEST_REPORTS}
                    run-tests.sh
                    cp out/tests/*.xml ${TEST_REPORTS}
                |||),
                steps.run(|||
                    set -xu
                    mkdir -p /tmp/artifacts
                    create_jars.sh << pipeline.number >>
                    cp *.jar /tmp/artifacts
                |||),
                steps.save_cache(key='v1-my-project-{{ checksum "project.clj" }}', paths=['~/.m2']),
                steps.store_artifacts(path='/tmp/artifacts', destination='build'),
                steps.store_test_results('/tmp/test-reports'),
            ],
        ),
    ] + environment_jobs,

    workflows=[
        workflows.new(
            name='build-deploy',
            jobs=[
                workflows.job('build', filters=workflows.filter_branches(ignore=['develop', '/feature-.*/'])),
                workflows.job('deploy-staging', requires=['build'], filters=workflows.filter_branches(only=['staging'])),
                workflows.job('deploy-production', requires=['build'], filters=workflows.filter_branches(only=['main'])),
            ]
        ),
    ],
)
