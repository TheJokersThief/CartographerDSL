local cmn = import 'common.libsonnet';
local dsl = cmn.dsl;

// DSL remapping for convenience
local executors = dsl.executors;
local workflows = dsl.workflows;
local steps = dsl.steps;


// Generate a deploy job for all environments
local environments = ['staging', 'production'];

[
    workflows.job(
        'deploy-%s' % [environment],
        requires=['build'], filters=workflows.filter_branches(only=[environment]),
        image='ubuntu:14.04',
        working_directory='/tmp/my-project',
        steps=[
            steps.run(
                name='Deploy if tests pass and branch is %s' % [environment],
                command='ansible-playbook site.yml -i %s' % [environment],
            ),
        ],
    )
    for environment in environments
]
