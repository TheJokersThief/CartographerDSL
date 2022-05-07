{
    project_name: 'my-project',
    executor_auth: {
        username: 'mydockerhub-user',
        password: '$DOCKERHUB_PASSWORD',
    },

    cache_version: 'v1',
    cache_key_base: cache_version + '-' + self.project_name,  // Useful for fallback matching a cache
    cache_key: cache_key_base + '-' + const.cache_vars.checksum('project.clj'),
}
