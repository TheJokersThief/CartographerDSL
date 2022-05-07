local const = import "constants.libsonnet";
local util = import "../util.libsonnet";

{
    new(
        name,
        steps = [],
        executor_type = null,
        executor_options = {},
        shell = null,
        parameters = {},
        working_directory = "~/project",
        parallelism = 1,
        environment = {},
        resource_class = null,
        circleci_ip_ranges = false,
    ) ::
        assert !util.is_empty(steps) : 'job: Missing at least 1 step';

        local executor =
            if util.is_empty(executor_type)
            then
                {}
            else
                // If executor isn't empty, we should verify it's one of the available options
                assert std.member(const.executor_types, executor_type)
                    : 'executors.new: executor_type must be one of ' + const.executor_types;
                {
                    [executor_type]: const.executors[executor_type].verify(executor_options)
                };

        {
            [name]: executor + {
                steps: steps,
                shell: shell,
                parameters: parameters,
                working_directory: working_directory,
                parallelism: parallelism,
                environment: environment,
                resource_class: resource_class,
            }
        },
}
