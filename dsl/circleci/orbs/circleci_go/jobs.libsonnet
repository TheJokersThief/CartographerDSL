local go_steps = import '_main.libsonnet';
local workflows = import '../../workflows.libsonnet';
local steps = import '../../steps.libsonnet';

{
    run_tests(
        name,
        go_version='1.16',
        requires=[],
        context=[],
        filters={},
        matrix={},
        when=null,
    ):: workflows.job(
        name,
        requires=requires,
        context=context,
        filters=filters,
        matrix=matrix,
        when=when,

        executor={ name: 'go/default', tag: go_version},

        steps = [
            steps.checkout(),
            go_steps.load_cache(),
            go_steps.mod_download_cached(),
            go_steps.test(),
            go_steps.save_cache(),
        ]
    )
}
