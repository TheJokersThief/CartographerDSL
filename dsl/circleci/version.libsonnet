local const = import 'constants.libsonnet';

{
    new(
        version=const.default_version,
    )::
        {
            version+: version,
        },
}
