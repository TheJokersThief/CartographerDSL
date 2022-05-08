# Cartographer DSL

A domain specific language for defining CircleCI pipelines.

<!-- TOC -->

- [Cartographer DSL](#cartographer-dsl)
    - [Local Usage](#local-usage)
        - [Docker Image](#docker-image)
    - [Running on CircleCI](#running-on-circleci)
- [Examples](#examples)
    - [Minimal](#minimal)
- [Docs: CircleCI](#docs-circleci)
    - [Pipeline dsl.circleci.pipeline.new](#pipeline-dslcirclecipipelinenew)
    - [Workflows dsl.circleci.workflows.new](#workflows-dslcircleciworkflowsnew)
        - [Job dsl.circleci.workflows.job](#job-dslcircleciworkflowsjob)
        - [Filter: Branches dsl.circleci.workflows.filter_branches](#filter-branches-dslcircleciworkflowsfilter_branches)
        - [Filter: Branches dsl.circleci.workflows.filter_tags](#filter-branches-dslcircleciworkflowsfilter_tags)
            - [Multiple Filters](#multiple-filters)
        - [Matrix dsl.circleci.workflows.matrix](#matrix-dslcircleciworkflowsmatrix)
    - [Jobs](#jobs)
            - [Job Executor Options dsl.circleci.executors.[docker, machine, macos, windows]](#job-executor-options-dslcircleciexecutorsdocker-machine-macos-windows)
                - [Docker dsl.circleci.executors.docker](#docker-dslcircleciexecutorsdocker)
                - [Machine dsl.circleci.executors.machine](#machine-dslcircleciexecutorsmachine)
                - [MacOS dsl.circleci.executors.macos](#macos-dslcircleciexecutorsmacos)
                - [Windows dsl.circleci.executors.windows](#windows-dslcircleciexecutorswindows)
                - [Custom Executor e.g. from an orb](#custom-executor-eg-from-an-orb)
        - [Steps](#steps)
    - [Executors](#executors)
    - [Orbs](#orbs)

<!-- /TOC -->

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
        auth:
          username: thejokersthief
          password: $DOCKERHUB_PASSWORD
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
      - generate-config
```

# Examples

## Minimal

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local dsl = full_dsl.circleci;

local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;

pipeline.new(
    jobs=[
        jobs.new('build',
            image="ubuntu:20.04",
            steps=[
                steps.checkout(),
                steps.run('echo "Hello World!"', name='Hello, World'),
            ]
        ),
    ],
    workflows=[
        workflows.new('main', jobs=[workflows.job('build')]),
    ],
)
```

# Docs: CircleCI

## Pipeline `dsl.circleci.pipeline.new`


|Name       |  Type            |   Default   |
|-----------|------------------|-------------|
|version    |  string          |   "2.1",    |
|orbs       |  Orb             |   {}        |
|jobs       |  list[Jobs]      |   []        |
|workflows  |  list[Workflows] |   []        |
|executors  |  list[Executors] |   []        |

**Example:**

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local dsl = full_dsl.circleci;

local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;

pipeline.new(
    jobs=[
        jobs.new('build',
            image="ubuntu:20.04",
            steps=[
                steps.checkout(),
                steps.run('echo "Hello World!"', name='Hello, World'),
            ]
        ),
    ],
    workflows=[
        workflows.new('main', jobs=[workflows.job('build')]),
    ],
)
```

## Workflows `dsl.circleci.workflows.new`

|Name    |    Type       |     Default   |
|--------|---------------|---------------|
|name    |    string     |     -         |
|jobs    |    list[Job]  |     -         |

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local workflows = full_dsl.circleci.workflows;

workflows.new(
    "example-workflow",
    jobs=[ ... ]
)
```

### Job `dsl.circleci.workflows.job`

|Name      |    Type            |  Default |
|----------|--------------------|----------|
|name      |    string          |  -       |
|requires  |    list[string]    |  []      |
|context   |    list[string]    |  []      |
|filters   |    Filter          |  {}      |
|matrix    |    Matrix          |  {}      |
|when      |    string          |  `null`  |

### Filter: Branches `dsl.circleci.workflows.filter_branches`

|Name      |    Type            |  Default |
|----------|--------------------|----------|
|only      |    list[string]    |  []      |
|ignore    |    list[string]    |  []      |

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local workflows = full_dsl.circleci.workflows;

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

### Filter: Branches `dsl.circleci.workflows.filter_tags`

|Name      |    Type            |  Default |
|----------|--------------------|----------|
|only      |    list[string]    |  []      |
|ignore    |    list[string]    |  []      |

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local workflows = full_dsl.circleci.workflows;

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

#### Multiple Filters

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local workflows = full_dsl.circleci.workflows;

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

### Matrix `dsl.circleci.workflows.matrix`

|Name        |    Type                 |   Default  |
|------------|-------------------------|------------|
|alias       |    string               |   `null`   |
|parameters  |    dict[string]string   |   {}       |
|exclude     |    list[string]         |   []       |


```jsonnet
local full_dsl = import '_dsl.libsonnet';
local workflows = full_dsl.circleci.workflows;

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

## Jobs

`image` is a convenience argument, for setting the executor to `"docker"` and specifying an image.

`executor` should be one of `docker`, `machine`, `macos` or `windows`.

|Name               |     Type                |    Default  |
|-------------------|-------------------------|-------------|
|name               |     string              |    -        |
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
local full_dsl = import '_dsl.libsonnet';
local jobs = circleci.dsl.jobs;

jobs.new(
    'build',
    image="ubuntu:20.04",
    steps=[
        steps.checkout(),
        steps.run('echo "Hello World!"', name='Hello, World'),
    ]
),
```

#### Job Executor Options `dsl.circleci.executors.[docker, machine, macos, windows]`

##### Docker `dsl.circleci.executors.docker`


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
local full_dsl = import '_dsl.libsonnet';
local jobs = circleci.dsl.jobs;
local executors = circleci.dsl.executors;

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

##### Machine `dsl.circleci.executors.machine`

|Name                  |   Type     |    Default   |
|----------------------|------------|--------------|
|image                 |   string   |    -         |
|docker_layer_caching  |   bool     |    false     |

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local jobs = circleci.dsl.jobs;
local executors = circleci.dsl.executors;

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

##### MacOS `dsl.circleci.executors.macos`

|Name                  |   Type     |    Default   |
|----------------------|------------|--------------|
|xcode                 |   string   |    -         |

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local jobs = circleci.dsl.jobs;

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

##### Windows `dsl.circleci.executors.windows`

The windows executor has no options.

##### Custom Executor (e.g. from an orb)

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local jobs = circleci.dsl.jobs;


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

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local dsl = full_dsl.circleci;

local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;
```

## Executors

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local dsl = full_dsl.circleci;

local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;
```

## Orbs

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local dsl = full_dsl.circleci;

local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;
```
