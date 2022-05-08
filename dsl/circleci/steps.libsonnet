local util = import '../util.libsonnet';

local valid_when_enum = ['always', 'on_success', 'on_fail'];

{

    run(
        command,
        name=null,
        shell=null,
        environment={},
        background=false,
        working_directory='.',
        no_output_timeout='10m',
        when='on_success',
    )::
        assert std.member(valid_when_enum, when) : 'steps.run: when must be one of ' + valid_when_enum;

        {
            run: {
                command: command,
                name: name,
                shell: shell,
                environment: environment,
                background: background,
                working_directory: working_directory,
                no_output_timeout: no_output_timeout,
                when: when,
            },
        },

    when(
        condition,
        steps=[],
    )::
        {
            when: {
                condition: condition,
                steps: steps,
            },
        },

    unless(condition, steps)::
        self.when(condition, steps),

    checkout()::
        'checkout',

    setup_remote_docker(
        docker_layer_caching=false,
        version='17.09.0-ce',
    )::
        {
            setup_remote_docker: {
                docker_layer_caching: docker_layer_caching,
                version: version,
            },
        },

    save_cache(
        key,
        paths=[],
        name='Saving Cache',
        when='on_success',
    )::
        assert std.member(valid_when_enum, when) : 'steps.save_cache: when must be one of ' + valid_when_enum;
        {
            save_cache: {
                key: key,
                paths: paths,
                name: name,
                when: when,
            },
        },

    restore_cache(
        keys,
        name='Restoring Cache',
    )::
        {
            restore_cache: {
                keys: keys,
                name: name,
            },
        },

    store_artifacts(
        path,
        destination=null,
    )::
        {
            store_artifacts:
            {
                path: path,
            }
            + if !util.is_empty(destination)
            then { destination: destination }
            else {},
        },

    store_test_results(path)::
        {
            store_test_results: {
                path: path,
            },
        },

    persist_to_workspace(
        root,
        paths=[],
    )::
        assert !util.is_empty(paths) : 'steps.persist_to_workspace: Missing at least 1 path';

        {
            persist_to_workspace: {
                root: root,
                paths: paths,
            },
        },

    attach_workspace(at)::
        {
            attach_workspace: {
                at: at,
            },
        },

    add_ssh_keys(fingerprints=[])::
        {
            add_ssh_keys: {
                fingerprints: fingerprints,
            },
        },


}
