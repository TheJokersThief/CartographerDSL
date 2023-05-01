[![CircleCI](https://circleci.com/gh/TheJokersThief/CartographerDSL/tree/main.svg?style=svg&circle-token=edd9f7a179ba0e5a17b27ddbb620ca9096adec76)](https://circleci.com/gh/TheJokersThief/CartographerDSL/tree/main)

# Cartographer DSL

![](cartographer-campervan.png)

A domain specific language for defining CircleCI pipelines.

- [Cartographer DSL](#cartographer-dsl)
    - [Local Usage](#local-usage)
    - [Running on CircleCI](#running-on-circleci)
- [Examples](#examples)
- [Docs: CircleCI](#docs-circleci)


<details><summary>Expand For Full Table Of Contents</summary>
<!-- TOC -->

- [Cartographer DSL](#cartographer-dsl)
    - [Why??](#why)
    - [Local Usage](#local-usage)
        - [Docker Image](#docker-image)
    - [Running on CircleCI](#running-on-circleci)
- [Examples](#examples)
    - [Minimal](#minimal)
- [Docs: CircleCI](#docs-circleci)
    - [Pipeline](#pipeline)
    - [Workflows](#workflows)
        - [Job](#job)
        - [Job Executor Options](#job-executor-options)
        - [Filter: Branches](#filter-branches)
        - [Filter: Tags](#filter-tags)
        - [Multiple Filters](#multiple-filters)
        - [Matrix](#matrix)
            - [Docker](#docker)
            - [Machine](#machine)
            - [MacOS](#macos)
            - [Windows](#windows)
            - [Custom Executor e.g. from an orb](#custom-executor-eg-from-an-orb)
        - [Steps](#steps)
            - [run](#run)
            - [when](#when)
            - [unless](#unless)
            - [checkout](#checkout)
            - [setup_remote_docker](#setup_remote_docker)
            - [save_cache](#save_cache)
            - [restore_cache](#restore_cache)
            - [store_artifacts](#store_artifacts)
            - [store_test_results](#store_test_results)
            - [persist_to_workspace](#persist_to_workspace)
            - [attach_workspace](#attach_workspace)
            - [add_ssh_keys](#add_ssh_keys)
    - [Executors](#executors)
    - [Orbs](#orbs)

<!-- /TOC -->
</details>

---

## Why??

YAML is _fine_ at 100 lines, less so at 1,000 lines and almost impossible to maintain at 10,000 lines. Anchors provide some capacity to keep things DRY but they're clunky and don't do enough really.

Enter Cartographer DSL, a domain-specific language based on Jsonnet that gives you the power of a complete programming language.

Some of the benefits:

- Config can be more condensed when appropriate (easier to view lots of config all at once)
- Loops and variables make it easier to repeat and template steps

I'm also hoping to take some common patterns and turn them into templates/functions/reusable chunks.

I built this because I noticed CircleCI supported dynamic config generation, and I wanted more options than YAML to write my config.

## Local Usage

### Docker Image

```bash
export FILE_NAME=".circleci/_config.jsonnet"
docker run -it \
    -v "$(pwd):/project" thejokersthief/cartographer-dsl \
    cartographer-dsl --file $FILE_NAME
```

## Running on CircleCI

Check out the [.circleci](.circleci/) folder for a living example.

The below config uses the `setup` ability for CircleCI pipelines to generate the config dynamically. You'll need to enable this for your project in the project settings under "Advanced", at the bottom of the page.

Then, put your Cartographer file in the `.circleci/_config.jsonnet`.

Finally, add the following `.circleci/config.yml` file:

```yaml
version: 2.1
setup: true
orbs:
  continuation: circleci/continuation@0.1.0
jobs:
  generate-config:
    docker:
      - image: thejokersthief/cartographer-dsl:latest
    steps:
      - checkout
      - run:
          name: Generate Pipeline generated_config.yml file
          command: cartographer-dsl --file .circleci/_config.jsonnet > generated_config.yml
      - continuation/continue:
          parameters: '{}'
          configuration_path: generated_config.yml
workflows:
  setup-workflow:
    jobs:
      - generate-config:
          filters:
            branches:
              only:
                - /.*/
            tags:
              only:
                - /.*/
```

# Examples

- [Full example from the CircleCI Docs](examples/circleci_docs_example/_config.jsonnet)
- [Python poetry lint & test](examples/python_poetry_lint_test/_config.jsonnet)

If you're looking to learn more about writing Jsonnet, [there's a very nice tutorial on the official website.](https://jsonnet.org/learning/tutorial.html)

## Minimal

```jsonnet
local dsl = import '_dsl.libsonnet';

local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;

pipeline.new(
    workflows=[
        workflows.new(
            'main', jobs=[
                workflows.job(
                    'build',
                    image="ubuntu:20.04",
                    steps=[
                        steps.checkout(),
                        steps.run('echo "Hello World!"', name='Hello, World'),
                    ]
                )
            ]
        ),
    ],
)
```

# Docs: CircleCI

## Pipeline

`dsl.circleci.pipeline.new`


|Name       |  Type            |   Default   |
|-----------|------------------|-------------|
|version    |  string          |   "2.1",    |
|orbs       |  Orb             |   {}        |
|workflows  |  list[Workflows] |   []        |
|executors  |  list[Executors] |   []        |

**Example:**

```jsonnet
local dsl = import '_dsl.libsonnet';

local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;

pipeline.new(
    workflows=[
        workflows.new(
            'main', jobs=[
                workflows.job(
                    'build',
                    image="ubuntu:20.04",
                    steps=[
                        steps.checkout(),
                        steps.run('echo "Hello World!"', name='Hello, World'),
                    ]
                )
            ]
        ),
    ],
)
```

## Workflows

`dsl.circleci.workflows.new`

|Name    |    Type       |     Default   |
|--------|---------------|---------------|
|name    |    string     |     -         |
|jobs    |    list[Job]  |     -         |

```jsonnet
local dsl = import '_dsl.libsonnet';
local workflows = dsl.workflows;

workflows.new(
    "example-workflow",
    jobs=[ ... ]
)
```

### Job

`dsl.circleci.workflows.job`

|Name               |    Type                 |  Default    |
|-------------------|-------------------------|-------------|
|name               |    string               |  -          |
|requires           |    list[string]         |  []         |
|context            |    list[string]         |  []         |
|filters            |    Filter               |  {}         |
|matrix             |    Matrix               |  {}         |
|when               |    string               |  `null`     |
|steps              |     list[Step]          |    []       |
|image              |     string              |    `null`   |
|executor           |     string              |    docker   |
|executor_options   |     Executor            |    {}       |
|shell              |     string              |    `null`   |
|parameters         |     dict[string]string  |    {}       |
|working_directory  |     string              |    `null`   |
|parallelism        |     integer             |    1        |
|environment        |     dict[string]string  |    {}       |
|resource_class     |     string              |    `null`   |
|circleci_ip_ranges |     bool                |    false    |

```jsonnet
local dsl = import '_dsl.libsonnet';

local steps = dsl.steps;
local workflows = dsl.workflows;

workflows.job(
    'build',
    image="ubuntu:20.04",
    steps=[
        steps.checkout(),
    ]
)
```

### Job Executor Options

`dsl.circleci.executors.[docker, machine, macos, windows]`

### Filter: Branches

`dsl.circleci.workflows.filter_branches`

|Name      |    Type            |  Default |
|----------|--------------------|----------|
|only      |    list[string]    |  []      |
|ignore    |    list[string]    |  []      |

```jsonnet
local dsl = import '_dsl.libsonnet';
local workflows = dsl.workflows;

workflows.new(
    "example-workflow",
    jobs=[
        workflows.job(
            name='example-job',
            requires=['another-job'],
            filters=workflows.filters(
                only=['main']
            )
        )
    ]
)
```

### Filter: Tags

`dsl.circleci.workflows.filter_tags`

|Name      |    Type            |  Default |
|----------|--------------------|----------|
|only      |    list[string]    |  []      |
|ignore    |    list[string]    |  []      |

```jsonnet
local dsl = import '_dsl.libsonnet';
local workflows = dsl.workflows;

workflows.new(
    "example-workflow",
    jobs=[
        workflows.job(
            name='example-job',
            requires=['another-job'],
            filters=workflows.filters(
                only=['/v1.*/'],
                ignore=['/beta-.*/']
            )
        )
    ]
)
```

### Multiple Filters

```jsonnet
local dsl = import '_dsl.libsonnet';
local workflows = dsl.workflows;

workflows.new(
    "example-workflow",
    jobs=[
        workflows.job(
            name='example-job',
            requires=['another-job'],
            filters=(
                workflows.filters(
                    only=['/v1.*/'],
                    ignore=['/beta-.*/']
                )
                + workflows.filters(
                    only=['main']
                )
            )
        )
    ]
)
```

### Matrix

`dsl.circleci.workflows.matrix`

|Name        |    Type                 |   Default  |
|------------|-------------------------|------------|
|alias       |    string               |   `null`   |
|parameters  |    dict[string]string   |   {}       |
|exclude     |    list[string]         |   []       |


```jsonnet
local dsl = import '_dsl.libsonnet';
local workflows = dsl.workflows;

workflows.new(
    "example-workflow",
    jobs=[
        workflows.job(
            name='example-job',
            matrix=workflows.matrix(
                parameters={
                    version: ["0.1", "0.2", "0.3"]
                    platform: ["macos", "windows", "linux"]
                }
            )
        )
    ]
)
```

#### Docker

`dsl.circleci.executors.docker`


|Name        |   Type                 |    Default     |
|------------|------------------------|----------------|
|image       |   string               |    -           |
|name        |   string               |    `null`      |
|entrypoint  |   string               |    `null`      |
|command     |   string               |    `null`      |
|user        |   string               |    `null`      |
|environment |   dict[string]string   |    {}          |
|auth        |   dict[string]string   |    {}          |
|aws_auth    |   dict[string]string   |    {}          |

```jsonnet
local dsl = import '_dsl.libsonnet';
local jobs = dsl.jobs;
local executors = dsl.executors;

jobs.new(
    'build',
    executor="docker",
    executor_options=executors.docker(
        image="ubuntu:20.04",
        auth={'username': 'example', 'password': 'example'}
    ),
    steps=[
        steps.checkout(),
        steps.run('echo "Hello World!"', name='Hello, World'),
    ]
),
```

#### Machine

`dsl.circleci.executors.machine`

|Name                  |   Type     |    Default   |
|----------------------|------------|--------------|
|image                 |   string   |    -         |
|docker_layer_caching  |   bool     |    false     |

```jsonnet
local dsl = import '_dsl.libsonnet';
local jobs = dsl.jobs;
local executors = dsl.executors;

jobs.new(
    'build',
    executor="machine"
    executor_options=executors.machine(image='ubuntu-2004:202201-02')
    steps=[
        steps.checkout(),
        steps.run('echo "Hello World!"', name='Hello, World'),
    ]
),
```

#### MacOS

`dsl.circleci.executors.macos`

|Name                  |   Type     |    Default   |
|----------------------|------------|--------------|
|xcode                 |   string   |    -         |

```jsonnet
local dsl = import '_dsl.libsonnet';
local jobs = dsl.jobs;

jobs.new(
    'build',
    executor="macos"
    executor_options=executors.macos('12.5.1')
    steps=[
        steps.checkout(),
        steps.run('echo "Hello World!"', name='Hello, World'),
    ]
),
```

#### Windows

`dsl.circleci.executors.windows`

The windows executor has no options.

#### Custom Executor (e.g. from an orb)

```jsonnet
local dsl = import '_dsl.libsonnet';
local jobs = dsl.jobs;


// orbs.new({ python: 'circleci/python@0.2.1' })

jobs.new(
    'build',
    executor="python/default"
    steps=[
        steps.checkout(),
        steps.run('echo "Hello World!"', name='Hello, World'),
    ]
),
```

### Steps

#### run

`dsl.circleci.steps.run`

|Name               |    Type                 |    Default  |
|-------------------|-------------------------|-------------|
|command            |    string               |    -        |
|name               |    string               |    `null`   |
|shell              |    string               |    `null`   |
|environment        |    dict[string]string   |    {}       |
|background         |    bool                 |    false    |
|working_directory  |    string               |    "."      |
|no_output_timeout  |    string               |    "10m"    |
|when               |    string|dict          |    `null`   |


```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;

steps.run('echo "Hello, World!", no_output_timeout="30m)
```

#### when

|Name               |    Type                 |    Default  |
|-------------------|-------------------------|-------------|
|steps              |    list[Step]           |    -        |
|when               |    string|dict          |    -        |

`dsl.circleci.steps.when`

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;
local const = dsl.constants;

steps.when(
    condition={
        'equal': ['my-fave-schedule', const.pipeline_values.schedule_name]
    },
    steps=[steps.run('echo "This is my favourite schedule!"')]
)
```

#### unless

`dsl.circleci.steps.unless`

|Name               |    Type                 |    Default  |
|-------------------|-------------------------|-------------|
|steps              |    list[Step]           |    -        |
|when               |    string|dict          |    -        |

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;

steps.unless(
    condition={
        'equal': ['my-fave-schedule', const.pipeline_values.schedule_name]
    },
    steps=[steps.run('echo "This is my favourite schedule!"')]
)
```

#### checkout

`dsl.circleci.steps.checkout`

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;

steps.checkout()
```

#### setup_remote_docker

`dsl.circleci.steps.setup_remote_docker`

|Name                    | Type      |  Default         |
|------------------------|-----------|------------------|
|version                 | string    |  '17.09.0-ce'    |
|docker_layer_caching    | bool      |  false           |

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;

steps.setup_remote_docker()
```

#### save_cache

`dsl.circleci.steps.save_cache`

|Name   |   Type          |  Default  |
|-------|-----------------|-----------|
|key    |   string        |  -        |
|paths  |   list[string]  |  -        |

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;
local const = dsl.constants;

steps.save_cache(
    key='v1' + const.cache_vars.checksum('testfile.txt'),
    paths=['/cached/path']
)
```

#### restore_cache

`dsl.circleci.steps.restore_cache`

|Name   |   Type          |  Default  |
|-------|-----------------|-----------|
|key    |   string        |  -        |

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;
local const = dsl.constants;

steps.restore_cache('v1' + const.cache_vars.checksum('testfile.txt'))
```

#### store_artifacts

`dsl.circleci.steps.store_artifacts`

|Name          |   Type          |  Default  |
|--------------|-----------------|-----------|
|path          |   string        |  -        |
|destination   |   string        |  `null`   |

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;

steps.store_artifacts('/my-artifacts-folders/')
```

#### store_test_results

`dsl.circleci.steps.store_test_results`

|Name   |   Type          |  Default  |
|-------|-----------------|-----------|
|path   |   string        |  -        |

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;

steps.store_test_results('/my-artifacts-folders/')
```

#### persist_to_workspace

`dsl.circleci.steps.persist_to_workspace`

|Name    |   Type          |  Default  |
|--------|-----------------|-----------|
|root    |   string        |  -        |
|paths   |   list[string]  |  -        |

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;

steps.persist_to_workspace(
    root='/my-project',
    paths=['important-folder']
)
```

#### attach_workspace

`dsl.circleci.steps.attach_workspace`

|Name    |   Type          |  Default  |
|--------|-----------------|-----------|
|at      |   string        |  -        |

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;

steps.attach_workspace('/my-project/important-folder')
```

#### add_ssh_keys

`dsl.circleci.steps.add_ssh_keys`

|Name              |   Type          |  Default  |
|------------------|-----------------|-----------|
|fingerprints      |   list[string]  |  -        |

```jsonnet
local dsl = import '_dsl.libsonnet';
local steps = dsl.steps;

steps.add_ssh_keys()
```

## Executors

`dsl.circleci.executors`

|Name               |     Type                 |    Default  |
|-------------------|--------------------------|-------------|
|name               |     string               |    -        |
|executor           |     string               |    -        |
|executor_options   |     Executor             |    -        |
|resource_class     |     string               |    `null`   |
|shell              |     string               |    `null`   |
|working_directory  |     string               |    `null`   |
|environment        |     dict[string]string   |    {}       |


```jsonnet
local dsl = import '_dsl.libsonnet';
local pipeline = dsl.pipeline;
local executors = dsl.executors;

pipeline.new(
    executors=[
        // You can define multiple images for the same executor by reusing the name
        executors.new("my-custom-executor", executor=docker, executor_options=executors.docker(image='ubuntu:20.04')),
        executors.new("my-custom-executor", executor=docker, executor_options=executors.docker(image='redis')),

        // Otherwise, they're all unique
        executors.new("my-other-executor", executor=docker, executor_options=executors.docker(image='redis')),
    ]
)
```

## Orbs

```jsonnet
local dsl = import '_dsl.libsonnet';
local pipeline = dsl.pipeline;
local orbs = dsl.orbs;

pipeline.new(
    orbs=orbs.new({ python: 'circleci/python@0.2.1' }),
    jobs=[
        jobs.new(
            'build-and-test',
            executor='python/default',
            steps=[
                steps.checkout(),
                'python/load-cache',
                steps.run('poetry install', name='Install dependencies'),
                'python/save-cache',
                steps.run('poetry run pytest tests', name='Tests'),
            ],
        ),
    ],
)
```
