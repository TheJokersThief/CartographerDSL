package cartographerdsl

import (
	"fmt"

	"github.com/google/go-jsonnet"
	"github.com/kkyr/fig"
	"github.com/sirupsen/logrus"
)

type Config struct {
	DSLPath string `fig:"dsl_path" validate:"required"`
}

type CartographerDSL struct {
	JsonnetVM *jsonnet.VM
}

func NewCartographerDSL() *CartographerDSL {
	var cfg Config
	err := fig.Load(&cfg, fig.Dirs(userHomeDir(), userConfDir(), "/etc/cartographer-dsl", "."))
	if err != nil {
		logrus.Fatal(err)
	}

	return &CartographerDSL{
		JsonnetVM: MakeVM(cfg.DSLPath),
	}
}

func (cd *CartographerDSL) Parse(filename, input string) string {
	jsonStr, err := cd.JsonnetVM.EvaluateAnonymousSnippet(filename, input)
	if err != nil {
		logrus.Fatal(err)
	}

	fmt.Println(jsonStr)
	return jsonStr
}
