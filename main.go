package main

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/om-baji/wireframe-cli/utils"

	"github.com/briandowns/spinner"
	"github.com/charmbracelet/lipgloss"
	"github.com/urfave/cli/v2"
)

var (
	subtle  = lipgloss.AdaptiveColor{Light: "#D9D9D9", Dark: "#383838"}
	primary = lipgloss.Color("36")
	accent  = lipgloss.Color("213")

	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("#FAFAFA")).
			Background(primary).
			Padding(0, 1).
			MarginRight(1)

	descStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("244"))

	listStyle = lipgloss.NewStyle().
			PaddingLeft(2).
			Foreground(lipgloss.Color("252"))

	promptStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(accent).
			MarginRight(1)

	successStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("42")).
			PaddingLeft(1)

	boxStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(primary).
			Padding(1, 4).
			MarginLeft(1).
			MarginBottom(1)
)

func banner() {
	title := titleStyle.Render("WIRE FRAME")
	desc := descStyle.Render("Opinionated · Minimal · Production Ready")

	content := lipgloss.JoinVertical(lipgloss.Left, title, desc)

	fmt.Println()
	fmt.Println(boxStyle.Render(content))
}

func spin(msg string, d time.Duration) {
	s := spinner.New(
		spinner.CharSets[14],
		80*time.Millisecond,
		spinner.WithColor("fgCyan"),
		spinner.WithSuffix("  "+descStyle.Render(msg)),
	)
	s.Start()
	time.Sleep(d)
	s.Stop()
	fmt.Print("\r")
}

func main() {
	app := &cli.App{
		Name:  "wireframe",
		Usage: "A modern backend scaffolding CLI",
		Action: func(c *cli.Context) error {
			banner()

			fmt.Println(promptStyle.Render("?"), "Select a backend stack")
			options := []string{"Node.js (Express)", "Gin (Go)", "FastAPI (Python)", "net/http (Go)", "Spring Boot (Java)"}
			for i, opt := range options {
				fmt.Printf("  %s %s\n", descStyle.Render(fmt.Sprintf("%d.", i+1)), listStyle.Render(opt))
			}
			fmt.Println()

			fmt.Print(promptStyle.Render("›"))
			var choice string
			fmt.Scan(&choice)

			framework := utils.Framework[choice]
			if framework == "" {
				fmt.Println(lipgloss.NewStyle().Foreground(lipgloss.Color("9")).Render("  Invalid selection"))
				return nil
			}

			spin("Configuring "+framework+"...", 700*time.Millisecond)

			switch framework {
			case "Express":
				fmt.Println("\n", promptStyle.Render("?"), "Select package manager")
				pms := []string{"npm", "pnpm", "bun"}
				for i, p := range pms {
					fmt.Printf("  %s %s\n", descStyle.Render(fmt.Sprintf("%d.", i+1)), listStyle.Render(p))
				}
				fmt.Println()

				fmt.Print(promptStyle.Render("›"))
				var pm string
				fmt.Scan(&pm)

				pkg := utils.Pakm[pm]
				if pkg == "" {
					return nil
				}

				spin("Using "+pkg+"...", 600*time.Millisecond)
				utils.ExecuteScript(utils.ScriptPath[framework], pkg)

			case "Gin", "FastAPI", "net/http", "Spring Boot":
				utils.ExecuteScript(utils.ScriptPath[framework], "")
			}

			fmt.Println()
			fmt.Println(successStyle.Render("✔ Scaffolding complete!"))
			fmt.Println(descStyle.MarginLeft(2).Render("Navigate to the directory and start building."))
			fmt.Println()

			return nil
		},
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
}
