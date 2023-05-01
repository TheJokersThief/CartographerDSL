{
    publish(
        image,
        requires=[],
        context=[],
        filters={},
        matrix={},
        when=null,

        after_build=[],
        after_checkout=[],
        attach_at='',
        before_build=[],
        cache_from='',
        deploy=true,
        docker_context='.',
        docker_password='DOCKER_PASSWORD',
        docker_username='DOCKER_USERNAME',
        dockerfile='Dockerfile',
        executor='docker/machine',
        extra_build_args='',
        lint_dockerfile=true,
        path='.',
        readme='README.md',
        registry='docker.io',
        remote_docker_dlc=false,
        remote_docker_version='17.09.0-ce',
        tag='$CIRCLE_SHA1',
        treat_warnings_as_errors=false,
        update_description=false,
        use_buildkit=false,
        use_docker_credentials_store=false,
        use_remote_docker=false,
    ):: {
            'docker/publish': {
                'requires': requires,
                'context': context,
                'matrix': matrix,
                'when': when,
                'after_build': after_build,
                'after_checkout': after_checkout,
                'attach-at': attach_at,
                'before_build': before_build,
                'cache_from': cache_from,
                'deploy': deploy,
                'docker-context': docker_context,
                'docker-password': docker_password,
                'docker-username': docker_username,
                'dockerfile': dockerfile,
                'executor': executor,
                'extra_build_args': extra_build_args,
                'image': image,
                'lint-dockerfile': lint_dockerfile,
                'path': path,
                'readme': readme,
                'registry': registry,
                'remote-docker-dlc': remote_docker_dlc,
                'remote-docker-version': remote_docker_version,
                'tag': tag,
                'treat-warnings-as-errors': treat_warnings_as_errors,
                'update-description': update_description,
                'use-buildkit': use_buildkit,
                'use-docker-credentials-store': use_docker_credentials_store,
                'use-remote-docker': use_remote_docker,
            } + filters,
    },
}
