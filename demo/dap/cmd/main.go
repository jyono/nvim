package main

import (
	"fmt"
	"os"
	"time"

	"nvim-dap-demo/pkg/mathx"
)

func runAPI() {
	logLevel := os.Getenv("DEMO_LOG_LEVEL")
	if logLevel == "" {
		logLevel = "(unset)"
	}
	port := os.Getenv("DEMO_PORT")
	if port == "" {
		port = "(unset)"
	}

	fmt.Printf("api starting: DEMO_LOG_LEVEL=%s DEMO_PORT=%s\n", logLevel, port)

	sum := mathx.Add(2, 3)
	for i := 0; i < 5; i++ {
		fmt.Printf("tick %d sum=%d\n", i, sum)
		time.Sleep(200 * time.Millisecond)
	}
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: main <api>")
		os.Exit(1)
	}

	switch os.Args[1] {
	case "api":
		runAPI()
	default:
		fmt.Fprintf(os.Stderr, "unknown subcommand: %s\n", os.Args[1])
		os.Exit(1)
	}
}
