local util = import '../util.libsonnet';
local jobs = import 'jobs.libsonnet';


local extractJobs(array, key) = std.map(
    function(item)
        if std.objectHasAll(item, key)
        then item[key]
        else {}
    , array
);

local prefixNonOrbs(string, prefix) =
    local constainsSlash = std.length(std.findSubstr('/', string)) > 0;

    if constainsSlash
    then string
    else prefix + string
;

local prefixFieldValues(object, field, prefix) =
    if std.objectHas(object, field)
    then
        if std.type(object[field]) == 'array'
        then
            {[field]: std.map(function(item) prefixNonOrbs(item, prefix), object[field])}
        else
            {[field]: prefixNonOrbs(object[field], prefix)}
    else
        {}
;

local prefixAllJobs(array, prefix) = std.map(
    function(job)
        local jobFields = std.objectFields(job);

        if std.length(jobFields) > 0
        then
            local jobName = jobFields[0];
            {
                [prefixNonOrbs(jobName, prefix)]: job[jobName]
                    + prefixFieldValues(job[jobName], 'requires', prefix)
                    + prefixFieldValues(job[jobName], 'name', prefix)
            }
        else
            {}
    , array
);

{
    new(name, jobs)::
        local list_of_jobs = util.as_array(jobs);
        {
            workflows +: { [name]: { jobs: prefixAllJobs(list_of_jobs, name + "_") } },
            jobs +: util.foldArrayOfObjects(
                prefixAllJobs(
                    extractJobs(list_of_jobs, '_jobs'),
                    name + "_",
                )
            ),
        },

    job(
        name,
        requires=[],
        context=[],
        filters={},
        matrix={},
        when=null,

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
        {
            _jobs +:: jobs.new(
                name=name,
                steps=steps,
                image=image,
                executor=executor,
                executor_options=executor_options,
                shell=shell,
                parameters=parameters,
                working_directory=working_directory,
                parallelism=parallelism,
                environment=environment,
                resource_class=resource_class,
                circleci_ip_ranges=circleci_ip_ranges,
            ),

            [name]: {
                name: name,
                requires: requires,
                context: context,
                matrix: matrix,
                when: when,
            } + filters,
        },

    filter_branches(
        only=[],
        ignore=[],
    )::
        {
            filters+: {
                branches: {
                    only: only,
                    ignore: ignore,
                },
            },
        },

    filter_tags(
        only=[],
        ignore=[],
    )::
        {
            filters+: {
                tags: {
                    only: only,
                    ignore: ignore,
                },
            },
        },

    matrix(
        alias=null,
        parameters={},
        exclude=[],
    )::
        {
            matrix: {
                parameters: parameters,
                exclude: exclude,
                alias: alias,
            },
        },
}
