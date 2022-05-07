local const = import "../constants.libsonnet";

{
    new(
        name,
        executor_type,
        executor_options,
        resource_class = null,
        shell = null,
        working_directory = null,
        environment = {},
    ) ::
        assert std.member(executor_type, const.executor_types) : 'executors.new: executor_type must be one of ' + const.executor_types;

        {
            executors +: {
                [name]: {
                    [executor_type]: const.route_executor(executor_options),
                    resource_class: resource_class,
                    shell: shell,
                    working_directory: working_directory,
                    environment: environment,
                }
            },
        },

    options: const.executors,
}
