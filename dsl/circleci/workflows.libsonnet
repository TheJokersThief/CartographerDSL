local util = import "../util.libsonnet";

local foldArrayOfObjects(last, current) = last + std.prune(current);

{
    new(name, jobs) ::
        local list_of_jobs = util.as_array(jobs);
        { [name]: std.foldl(foldArrayOfObjects, list_of_jobs, {}) },

    job(
        name,
        requires = [],
        context = [],
        filters = {},
        matrix = {},
        when = null,
    ) ::
        {
            [name]: {
                name: name,
                requires: requires,
                context: context,
                matrix: matrix,
                when: when,
            } + filters,
        },

    filter_branches(
        only = [],
        ignore = [],
    ) ::
        {
            filters +: {
                branches: {
                    only: only,
                    ignore: ignore,
                },
            },
        },

    filter_tags(
        only = [],
        ignore = [],
    ) ::
        {
            filters +: {
                tags: {
                    only: only,
                    ignore: ignore,
                },
            },
        },

    matrix(
        alias = null,
        parameters = {},
        exclude = [],
    ) ::
        {
            matrix: {
                parameters: parameters,
                exclude: exclude,
                alias: alias,
            },
        },
}
