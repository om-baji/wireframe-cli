# Wireframe CLI

**Opinionated · Minimal · Production Ready**

`wireframe` is a modern CLI tool designed to rapidly scaffold backend services with production-ready best practices. It supports multiple languages and frameworks, handling the repetitive setup so you can focus on building features.

## Supported Stacks

- **Node.js**: Express
- **Go**: Gin, net/http
- **Python**: FastAPI
- **Java**: Spring Boot

## Prerequisites

- **Go 1.21+** (required to build the CLI)
- **Make** (optional, for easy building)
- **Stack-specific tools:**
  - **Node.js**: `npm`, `pnpm`, or `bun` for Express projects.
  - **Python**: `python3` and `pip` for FastAPI.
  - **Java**: JDK and Maven/Gradle for Spring Boot.

## Installation

Clone the repository and build the binary:

```bash
git clone https://github.com/om-baji/wireframe-cli.git
cd wireframe-cli
make build
```

This will create a `cli` binary in the current directory.

## Usage

Wireframe is designed to be **interactive**. Simply run the binary to start the wizard:

```bash
./cli
```

### Interactive Walkthrough

1.  **Select a Backend Stack**: Choose from the available options (e.g., Node.js (Express), Gin (Go), etc.).
2.  **Configure Project**:
    *   **Express**: You will be prompted to choose a package manager (`npm`, `pnpm`, `bun`), database (MongoDB/PostgreSQL/None), ORM (Prisma/Mongoose), and whether to include Redis.
    *   **Other Stacks**: follow similar framework-specific prompts handled by the underlying scripts.
3.  **Scaffolding**: The CLI will generate the project structure, install dependencies, and set up basic boilerplate code.

### Example Flow

```text
? Select a backend stack
  1. Node.js (Express)
  2. Gin (Go)
  3. FastAPI (Python)
  4. net/http (Go)
  5. Spring Boot (Java)

› 1

Configuring Express...

? Select package manager
  1. npm
  2. pnpm
  3. bun

› 3
```

## Development

To modify the CLI logic, edit `main.go`.
To modify the scaffolding templates, edit the corresponding scripts in the `scripts/` directory.

Rebuild after changes:

```bash
make build
```
