//go:build windows

package internal

import "os/exec"

func isolateProcessGroup(*exec.Cmd) {}
