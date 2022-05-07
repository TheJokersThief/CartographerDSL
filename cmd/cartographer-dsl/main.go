package main

import (
	"io/ioutil"

	cartographerdsl "github.com/TheJokersThief/cartographer-dsl/pkg/cartographer-dsl"
	"github.com/alecthomas/kong"
)

type CLI struct {
	File string `help:"File to be parsed" required:""`
}

func main() {
	cdsl := cartographerdsl.NewCartographerDSL()

	var cli CLI
	kong.Parse(&cli)

	content, _ := ioutil.ReadFile(cli.File)
	cdsl.Parse(cli.File, string(content))
}
