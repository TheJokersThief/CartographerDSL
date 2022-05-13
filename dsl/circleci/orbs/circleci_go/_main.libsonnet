local const = import '../../constants.libsonnet';

{
    include():: { orbs+: {'go': 'circleci/go@1.7.1'}},

    jobs: import 'jobs.libsonnet',

    load_cache():: "go/load-cache",
    mod_download():: "go/mod-download",
    mod_download_cached():: "go/mod-download-cached",

    // Documentation: https://circleci.com/developer/orbs/orb/circleci/go#commands-test
    test(
        count = 1,
        covermode = 'set',
        coverpkg = './...',
        coverprofile = 'cover-source.out',
        failfast = false,
        packages = './...',
        parallel = 1,
        race = false,
        short = false,
        verbose = false,
    ):: {
        'go/test': {
            count: count,
            covermode: covermode,
            coverpkg: coverpkg,
            coverprofile: coverprofile,
            failfast: failfast,
            packages: packages,
            parallel: parallel,
            race: race,
            short: short,
            verbose: verbose,
        },
    },

    // Documentation: https://circleci.com/developer/orbs/orb/circleci/go#commands-save-cache
    save_cache(
        key=const.cache_vars.checksum('go.sum'),
    ):: {
        'go/save-cache': {
            key: key,
        },
    },

}
