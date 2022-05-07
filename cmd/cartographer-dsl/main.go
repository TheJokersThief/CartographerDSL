package main

import (
	"fmt"
	"io/ioutil"

	cartographerdsl "github.com/TheJokersThief/cartographer-dsl/pkg/cartographer-dsl"
	"github.com/alecthomas/kong"
)

type CLI struct {
	File string `help:"File to be parsed" required:""`
}

func main() {

	var cli CLI
	kong.Parse(&cli)

	cdsl := cartographerdsl.NewCartographerDSL(cli.File)
	content, _ := ioutil.ReadFile(cli.File)
	fmt.Println(cdsl.Parse(cli.File, string(content)))
}
