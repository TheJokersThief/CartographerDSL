package cartographerdsl

import (
	"fmt"
	"os"

	"github.com/sirupsen/logrus"
)

func userHomeDir() string {
	dir, err := os.UserHomeDir()
	if err != nil {
		logrus.Error(err)
	}

	return dir
}

func userConfDir() string {
	return fmt.Sprintf("%s/.config/cartographer-dsl", userHomeDir())
}
