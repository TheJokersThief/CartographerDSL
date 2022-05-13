local dslVersion = import 'version.libsonnet';
local util = import '../util.libsonnet';

local foldArrayOfObjects(last, current) = last + std.prune(current);

{
    new(
        version=dslVersion.new(),
        orbs={},
        // jobs=[],
        workflows=[],
        executors=[],
    )::
        version
        + orbs
        + util.foldArrayOfObjects(workflows)
        + {
            executors: util.foldArrayOfObjects(executors),
        },
}
