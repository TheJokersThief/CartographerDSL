local const = import '../constants.libsonnet';

local executor_constructors = {
    [exec_key]: const.executors[exec_key].new
    for exec_key in std.objectFields(const.executors)
};

executor_constructors {
    new(
        name,
        executor,
        executor_options,
        resource_class=null,
        shell=null,
        working_directory=null,
        environment={},
    )::
        assert std.member(executor, const.executor_types) : 'executors.new: executor must be one of ' + const.executor_types;

        {
            executors+: {
                [name]: {
                    [executor]: const.route_executor(executor_options),
                    resource_class: resource_class,
                    shell: shell,
                    working_directory: working_directory,
                    environment: environment,
                },
            },
        },
}
