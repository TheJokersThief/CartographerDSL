// Generate a deploy job for all environments
local environments = ['staging', 'production'];

[
    jobs.new(
        'deploy-%s' % [environment],
        executor_type='docker',
        executor_options=[
            executors.options.docker.new('ubuntu:14.04', auth=cmn.executor_auth),
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
]
