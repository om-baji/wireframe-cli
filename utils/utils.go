package utils

import (
	"embed"
	"log"
	"os"
	"os/exec"

	"github.com/charmbracelet/x/term"
)

//go:embed scripts/*.sh
var Scripts embed.FS

var ScriptPath = map[string]string{
	"Express":     "scripts/express.sh",
	"Gin":         "scripts/gin.sh",
	"FastAPI":     "scripts/fastapi.sh",
	"net/http":    "scripts/net.sh",
	"Spring Boot": "scripts/spring.sh",
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
	data, err := Scripts.ReadFile(path)
	if err != nil {
		log.Fatalf("script not found: %s: %v", path, err)
	}

	tmp, err := os.CreateTemp("", "wireframe-*.sh")
	if err != nil {
		log.Fatal(err)
	}
	defer os.Remove(tmp.Name())

	if _, err := tmp.Write(data); err != nil {
		log.Fatal(err)
	}
	if err := tmp.Chmod(0700); err != nil {
		log.Fatal(err)
	}
	tmp.Close()

	cmd := exec.Command("bash", append([]string{tmp.Name()}, args...)...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}
}
