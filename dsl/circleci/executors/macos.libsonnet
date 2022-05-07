local util = import "../../util.libsonnet";

{
    verify(options) ::
        assert !util.is_empty(options.xcode) : 'executors.macos.options: Missing xcode version';
        options,

    new(
        xcode,
    ) ::
        {
            xcode: xcode,
        },
}
