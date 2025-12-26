#!/bin/bash
set -e

BOLD='\033[1m'
PURPLE='\033[38;5;141m'
CYAN='\033[38;5;87m'
GREEN='\033[38;5;84m'
GRAY='\033[38;5;245m'
NC='\033[0m'

clear
echo -e "${PURPLE}┌──────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}│${NC}   ${BOLD}S C A F F O L D I N G   N E T / H T T P${NC}   ${PURPLE}│${NC}"
echo -e "${PURPLE}│${NC}   Zero-framework backend                    ${PURPLE}│${NC}"
echo -e "${PURPLE}└──────────────────────────────────────────────┘${NC}"
sleep 0.4

PROJECT_NAME="http-service"
printf "\n${CYAN}❯${NC} Project Name ${GRAY}($PROJECT_NAME):${NC} "
read input
PROJECT_NAME=${input:-$PROJECT_NAME}

printf "${CYAN}❯${NC} Database ${GRAY}(postgres/mongodb/none):${NC} "
read DB

printf "${CYAN}❯${NC} Redis Cache? ${GRAY}(y/n):${NC} "
read REDIS

mkdir -p "$PROJECT_NAME"/{cmd/server,internal/config}
cd "$PROJECT_NAME"

go mod init "$PROJECT_NAME"

[[ "$DB" == "postgres" ]] && go get github.com/jackc/pgx/v5
[[ "$DB" == "mongodb" ]] && go get go.mongodb.org/mongo-driver/mongo
[[ "$REDIS" == "y" ]] && go get github.com/redis/go-redis/v9

cat <<EOF > internal/config/database.go
package config

import (
	"context"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

var DB *pgxpool.Pool

func Connect() error {
	db, err := pgxpool.New(context.Background(), os.Getenv("DATABASE_URL"))
	if err != nil {
		return err
	}
	DB = db
	return nil
}
EOF

cat <<EOF > internal/config/redis.go
package config

import (
	"context"
	"os"

	"github.com/redis/go-redis/v9"
)

var Redis *redis.Client

func ConnectRedis() error {
	Redis = redis.NewClient(&redis.Options{Addr: os.Getenv("REDIS_URL")})
	return Redis.Ping(context.Background()).Err()
}
EOF

cat <<EOF > cmd/server/main.go
package main

import (
	"net/http"
	"os"

	"$PROJECT_NAME/internal/config"
)

func main() {
	if os.Getenv("DATABASE_URL") != "" {
		config.Connect()
	}

	if os.Getenv("REDIS_URL") != "" {
		config.ConnectRedis()
	}

	http.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		w.Write([]byte("OK"))
	})

	http.ListenAndServe(":8080", nil)
}
EOF

cat <<EOF > .env
PORT=8080
DATABASE_URL=
REDIS_URL=
EOF

echo -e "\n${GREEN}✔ net/http backend ready${NC}"
