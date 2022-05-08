// References example: https://circleci.com/docs/2.0/configuration-reference/#example-full-configuration

// Local file imports
local cmn = import 'common.libsonnet';
local dsl = cmn.dsl;
local environment_jobs = import 'environment.libsonnet';

// DSL remapping for convenience
local const = dsl.constants;
local executors = dsl.executors;
local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;

pipeline.new(
    jobs=[
        jobs.new(
            'build',
            environment={ TEST_REPORTS: '/tmp/test-reports' },
            working_directory='~/%s' % [cmn.project_name],

            executor_type='docker',
            executor_options=[
                executors.options.docker.new('ubuntu:14.04', auth=cmn.executor_auth),
                executors.options.docker.new('mongo:2.6.8', auth=cmn.executor_auth, command=['mongod', '--smallfiles']),
                executors.options.docker.new('postgres:14.2', auth=cmn.executor_auth, environment={ POSTGRES_USER: 'user' }),
                executors.options.docker.new('redis@sha256:54057dd7e125ca41afe526a877e8bd35ec2cdd33b9217e022ed37bdcf7d09673', auth=cmn.executor_auth),
                executors.options.docker.new('rabbitmq:3.5.4', auth=cmn.executor_auth),
            ],

            steps=[
                steps.checkout(),
                steps.run('echo 127.0.0.1 devhost | sudo tee -a /etc/hosts'),
                steps.run(|||
                    sudo -u root createuser -h localhost --superuser ubuntu &&
                    sudo createdb -h localhost test_db
                |||),
                steps.restore_cache([cmn.cache_key, cmn.cache_key_base]),
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
                steps.save_cache(key=cmn.cache_key, paths=['~/.m2']),
                steps.store_artifacts(path='/tmp/artifacts', destination='build'),
                steps.store_test_results('/tmp/test-reports'),
            ],
        ),
    ] + environment_jobs,  // Add our environment jobs to the pipeline

    workflows=[
        workflows.new(
            name='build-deploy',
            jobs=[
                workflows.job('build', filters=workflows.filter_branches(ignore=['develop', '/feature-.*/'])),
                // Run deploys in parallel
                workflows.job('deploy-staging', requires=['build'], filters=workflows.filter_branches(only=['staging'])),
                workflows.job('deploy-production', requires=['build'], filters=workflows.filter_branches(only=['main'])),
            ]
        ),
    ],
)
