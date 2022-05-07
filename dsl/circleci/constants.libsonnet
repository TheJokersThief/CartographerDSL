local docker = import 'executors/docker.libsonnet';
local machine = import 'executors/machine.libsonnet';
local macos = import 'executors/macos.libsonnet';
local windows = import 'executors/windows.libsonnet';


local executors = {
    docker: docker,
    machine: machine,
    macos: macos,
    windows: windows,
};


local route_executor(executor_type, executor_options) = executors[executor_type].verify(executor_options);

{
    default_version: 2.1,
    executor_types: [
        'docker',
        'machine',
        'macos',
        'windows',
    ],

    cache_vars: {
        branch: '{{ .Branch }}',
        buildNum: '{{ .BuildNum }}',
        revision: '{{ .Revision }}',
        checkoutKey: '{{ .CheckoutKey }}',
        epoch: '{{ epoch }}',
        arch: '{{ arch }}',

        checksum(filename):: '{{ checksum "%s" }}' % [filename],
        envVar(variable):: '{{ .Environment.%s }}' % [variable],
    },

    pipeline_values: {
        id: '<< pipeline.id >>',
        number: '<< pipeline.number >>',
        git_url: '<< pipeline.project.git_url >>',
        type: '<< pipeline.project.type >>',
        tag: '<< pipeline.git.tag >>',
        branch: '<< pipeline.git.branch >>',
        revision: '<< pipeline.git.revision >>',
        base_revision: '<< pipeline.git.base_revision >>',
        in_setup: '<< pipeline.in_setup >>',
        trigger_source: '<< pipeline.trigger_source >>',
        schedule_name: '<< pipeline.schedule.name >>',
        schedule_id: '<< pipeline.schedule.id >>',
    },

    resource_class: {
        docker: {
            small: 'small',
            medium: 'medium',
            medium_plus: 'medium+',
            large: 'large',
            xlarge: 'xlarge',
            xxlarge: '2xlarge',
            xxlarge_plus: '2xlarge+',
        },

        machine: {
            medium: 'medium',
            large: 'large',
            xlarge: 'xlarge',
            xxlarge: '2xlarge',
        },

        macos: {
            medium: 'medium',
            macos_x86_medium_gen2: 'macos.x86.medium.gen2',
            large: 'large',
            macos_x86_metal_gen1: 'macos.x86.metal.gen1',
        },

        windows: {
            medium: 'medium',
            large: 'large',
            xlarge: 'xlarge',
            xxlarge: '2xlarge',
        },

        gpu_linux: {
            gpu_nvidia_small: 'gpu.nvidia.small',
            gpu_nvidia_medium: 'gpu.nvidia.medium',
            gpu_nvidia_large: 'gpu.nvidia.large',
        },

        gpu_windows: {
            windows_gpu_nvidia_medium: 'windows.gpu.nvidia.medium',
        },
    },

    // Functions
    executors: executors,
    route_executor: route_executor,
}
