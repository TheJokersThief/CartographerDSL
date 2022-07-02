package cartographerdsl

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

const testJsonnet = `
local dsl = import '../../dsl/_dsl.libsonnet';

local jobs = dsl.jobs;
local pipeline = dsl.pipeline;
local steps = dsl.steps;
local workflows = dsl.workflows;


pipeline.new(
    workflows=[
        workflows.new(
            'main',
            jobs=[
                workflows.job(
					'build-and-test',
					image="ubuntu:20.04",
					steps=[
						steps.checkout(),
						steps.run('echo "Hello World"', name='Install dependencies'),
					],
				),
            ],
        ),
    ],
)`

const resultYAML = `executors: {}
jobs:
  main_build-and-test:
    docker:
    - image: ubuntu:20.04
    parallelism: 1
    steps:
    - checkout
    - run:
        background: false
        command: echo "Hello World"
        name: Install dependencies
        no_output_timeout: 10m
        when: on_success
        working_directory: .
    working_directory: ~/project
version: 2.1
workflows:
  main:
    jobs:
    - main_build-and-test:
        name: main_build-and-test
`

func TestParse(t *testing.T) {
	dsl := NewCartographerDSL("testfile")
	parsedConfig := dsl.Parse("testfile", testJsonnet)

	assert.Equal(t, parsedConfig, resultYAML)
}
