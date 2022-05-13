local const = import '../../constants.libsonnet';

{
    include():: { orbs+: {'docker': 'circleci/docker@2.1.1'}},

    jobs: import 'jobs.libsonnet',

    build(
        image,
        attach_at='',
        cache_from='',
        debug=false,
        docker_context='.',
        dockerfile='Dockerfile',
        extra_build_args='',
        lint_dockerfile=false,
        no_output_timeout='10m',
        path='.',
        registry='docker.io',
        step_name='Docker build',
        tag='$CIRCLE_SHA1',
        treat_warnings_as_errors=false,
        use_buildkit=false,
    ):: {
        'docker/build': {
            'attach-at': attach_at,
            'cache_from': cache_from,
            'debug': debug,
            'docker-context': docker_context,
            'dockerfile': dockerfile,
            'extra_build_args': extra_build_args,
            'image': image,
            'lint-dockerfile': lint_dockerfile,
            'no_output_timeout': no_output_timeout,
            'path': path,
            'registry': registry,
            'step-name': step_name,
            'tag': tag,
            'treat-warnings-as-errors': treat_warnings_as_errors,
            'use-buildkit': use_buildkit,
        },
    },

    check(
        docker_password='$DOCKER_PASSWORD',
        docker_username='$DOCKER_LOGIN',
        registry='docker.io',
        use_docker_credentials_store=false,
    ):: {
        'docker/check': {
            'docker-password': docker_password,
            'docker-username': docker_username,
            'registry': registry,
            'use-docker-credentials-store': use_docker_credentials_store,
        },
    },


}
