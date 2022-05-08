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

```jsonnet
local full_dsl = import '_dsl.libsonnet';
local dsl = full_dsl.circleci;

local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;
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
