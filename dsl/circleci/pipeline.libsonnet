local dslVersion = import 'version.libsonnet';
local util = import '../util.libsonnet';

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
        + util.foldArrayOfObjects(workflows, prune=false)
        + {
            executors: util.foldArrayOfObjects(executors),
        },
}
