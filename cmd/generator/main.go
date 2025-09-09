/*
Copyright 2021 Upbound Inc.
*/

// Package main contains the generator for the Crossplane Redis Cloud provider.
package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/crossplane/upjet/pkg/pipeline"

	"github.com/RedisLabs/provider-rediscloud/config"
)

func main() {
	if len(os.Args) < 2 || os.Args[1] == "" {
		panic("root directory is required to be given as argument")
	}
	rootDir := os.Args[1]
	absRootDir, err := filepath.Abs(rootDir)
	if err != nil {
		panic(fmt.Sprintf("cannot calculate the absolute path with %s", rootDir))
	}
	pipeline.Run(config.GetProvider(), absRootDir)
}
