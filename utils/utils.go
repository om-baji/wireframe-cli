package utils

import (
	"log"
	"os"
	"os/exec"

	"github.com/charmbracelet/x/term"
)

var ScriptPath = map[string]string{
	"Express":     "./scripts/express.sh",
	"Gin":         "./scripts/gin.sh",
	"FastAPI":     "./scripts/fastapi.sh",
	"net/http":    "./scripts/net.sh",
	"Spring Boot": "./scripts/spring.sh",
}

var Framework = map[string]string{
	"1": "Express",
	"2": "Gin",
	"3": "FastAPI",
	"4": "net/http",
	"5": "Spring Boot",
}

var Pakm = map[string]string{
	"1": "npm",
	"2": "pnpm",
	"3": "bun",
}

func GetTerminalSize() (w, h int, err error) {
	return term.GetSize(uintptr(os.Stdout.Fd()))
}

func ExecuteScript(path string, args ...string) {
	cmd := exec.Command("bash", append([]string{path}, args...)...)

	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}
}
