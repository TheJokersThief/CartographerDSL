local util = import '../../util.libsonnet';


{
    verify(options)::
        assert !util.is_empty(options.image) : 'executors.machine.options: Missing image';
        options,

    new(
        image,
        docker_layer_caching=false,
    )::
        {
            image: image,
            docker_layer_caching: docker_layer_caching,
        },
}
