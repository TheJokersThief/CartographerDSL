package cartographerdsl

import (
	"github.com/google/go-jsonnet"
)

func MakeVM(dslPath, currentFilePath string) *jsonnet.VM {
	vm := jsonnet.MakeVM()

	importer := NewCustomImporter(dslPath, currentFilePath)
	vm.Importer(importer)

	return vm
}

type CustomImporter struct {
	DefaultImporter *jsonnet.FileImporter
}

func NewCustomImporter(dslPath, currentFilePath string) *CustomImporter {
	return &CustomImporter{
		DefaultImporter: &jsonnet.FileImporter{JPaths: []string{dslPath, currentFilePath}},
	}
}

func (i *CustomImporter) Import(importedFrom, importedPath string) (jsonnet.Contents, string, error) {
	return i.DefaultImporter.Import(importedFrom, importedPath)
}
