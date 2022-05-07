local util = import '../../util.libsonnet';


{
    verify(images)::
        local list_of_images = util.as_array(images);
        assert std.length(list_of_images) > 0 : 'executor.docker.options: Must pass at least 1 image to docker executor.';
        list_of_images,

    new(
        image,
        name=null,
        entrypoint=null,
        command=null,
        user=null,
        environment=null,
        auth=null,
        aws_auth=null,
    )::
        {
            image: image,
            name: name,
            entrypoint: entrypoint,
            command: command,
            user: user,
            environment: environment,
            auth: auth,
            aws_auth: aws_auth,
        },
}
