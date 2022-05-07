local full_dsl = import '_dsl.libsonnet';
local dsl = full_dsl.circleci;

local const = dsl.constants;

{
    dsl: dsl,
    project_name: 'my-project',
    executor_auth: {
        username: 'mydockerhub-user',
        password: '$DOCKERHUB_PASSWORD',
    },

    cache_version: 'v1',
    cache_key_base: self.cache_version + '-' + self.project_name,  // Useful for fallback matching a cache
    cache_key: self.cache_key_base + '-' + const.cache_vars.checksum('project.clj'),
}
