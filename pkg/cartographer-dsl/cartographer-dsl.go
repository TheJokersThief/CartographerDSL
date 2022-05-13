package cartographerdsl

import (
	"path"

	"github.com/google/go-jsonnet"
	"github.com/kkyr/fig"
	"github.com/sirupsen/logrus"
	"sigs.k8s.io/yaml"
)

type Config struct {
	DSLPath string `fig:"dsl_path" validate:"required"`
}

type CartographerDSL struct {
	JsonnetVM *jsonnet.VM
}

func NewCartographerDSL(filename string) *CartographerDSL {
	var cfg Config
	err := fig.Load(&cfg, fig.Dirs(userHomeDir(), userConfDir(), "/etc/cartographer-dsl", ".", "../.."))
	if err != nil {
		logrus.Fatal(err)
	}

	return &CartographerDSL{
		JsonnetVM: MakeVM(cfg.DSLPath, path.Dir(filename)),
	}
}

func (cd *CartographerDSL) Parse(filename, input string) string {
	jsonStr, err := cd.JsonnetVM.EvaluateAnonymousSnippet(filename, input)
	if err != nil {
		logrus.Fatal(err)
	}

	content, _ := yaml.JSONToYAML([]byte(jsonStr))
	return string(content)
}
