local util = import '../util.libsonnet';
local const = import 'constants.libsonnet';

{
    new(
        name,
        steps=[],

        image=null,  // Helper to using just one docker image
        executor='docker',
        executor_options={},

        shell=null,
        parameters={},
        working_directory='~/project',
        parallelism=1,
        environment={},
        resource_class=null,
        circleci_ip_ranges=false,
    )::
        assert !util.is_empty(steps) : 'job: Missing at least 1 step';

        local final_exec_options =
            if util.is_empty(image)
            then
                executor_options
            else
                { image: image } + executor_options;

        local chosen_executor =
            if util.is_empty(executor)
            then
                {}
            else
                if std.member(const.executor_types, executor)
                then
                    { [executor]: const.executors[executor].verify(final_exec_options) }
                else
                    { executor: executor };

        {
            [name]: chosen_executor {
                steps: steps,
                shell: shell,
                parameters: parameters,
                working_directory: working_directory,
                parallelism: parallelism,
                environment: environment,
                resource_class: resource_class,
            },
        },
}
