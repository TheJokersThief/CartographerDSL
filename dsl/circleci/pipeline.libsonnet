local dslVersion = import 'version.libsonnet';

local foldArrayOfObjects(last, current) = last + std.prune(current);

{
    new(
        version=dslVersion.new(),
        orbs={},
        jobs=[],
        workflows=[],
        executors=[],
    )::
        version
        + orbs
        + {
            jobs: std.foldl(foldArrayOfObjects, jobs, {}),
        }
        + {
            workflows: std.foldl(foldArrayOfObjects, workflows, {}),
        }
        + {
            executors: std.foldl(foldArrayOfObjects, executors, {}),
        },
}
