#!/bin/bash
set -e

BOLD='\033[1m'
PURPLE='\033[38;5;141m'
CYAN='\033[38;5;87m'
BLUE='\033[38;5;75m'
GREEN='\033[38;5;84m'
GRAY='\033[38;5;245m'
NC='\033[0m'

clear
echo -e "${PURPLE}┌──────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}│${NC}   ${BOLD}S C A F F O L D I N G   G I N${NC}                   ${PURPLE}│${NC}"
echo -e "${PURPLE}│${NC}   Production-ready Go backend                ${PURPLE}│${NC}"
echo -e "${PURPLE}└──────────────────────────────────────────────┘${NC}"
sleep 0.4

PROJECT_NAME="gin-service"
printf "\n${CYAN}❯${NC} Project Name ${GRAY}($PROJECT_NAME):${NC} "
read input
PROJECT_NAME=${input:-$PROJECT_NAME}

printf "${CYAN}❯${NC} Database ${GRAY}(postgres/mongodb/none):${NC} "
read DB

printf "${CYAN}❯${NC} Redis Cache? ${GRAY}(y/n):${NC} "
read REDIS

mkdir -p "$PROJECT_NAME"/{cmd/server,internal/{config,controllers,services,routes,models}}
cd "$PROJECT_NAME"

go mod init "$PROJECT_NAME"

go get github.com/gin-gonic/gin
go get github.com/joho/godotenv

[[ "$DB" == "postgres" ]] && go get gorm.io/gorm gorm.io/driver/postgres
[[ "$DB" == "mongodb" ]] && go get go.mongodb.org/mongo-driver/mongo
[[ "$REDIS" == "y" ]] && go get github.com/redis/go-redis/v9

cat <<EOF > internal/config/database.go
package config

import (
	"context"
	"os"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB
var Mongo *mongo.Client

func ConnectPostgres() error {
	db, err := gorm.Open(postgres.Open(os.Getenv("DATABASE_URL")), &gorm.Config{})
	if err != nil {
		return err
	}
	DB = db
	return nil
}

func ConnectMongo() error {
	client, err := mongo.Connect(context.TODO(), options.Client().ApplyURI(os.Getenv("DATABASE_URL")))
	if err != nil {
		return err
	}
	Mongo = client
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
	Redis = redis.NewClient(&redis.Options{
		Addr: os.Getenv("REDIS_URL"),
	})
	return Redis.Ping(context.Background()).Err()
}
EOF

cat <<EOF > cmd/server/main.go
package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"$PROJECT_NAME/internal/config"
)

func main() {
	_ = godotenv.Load()

	if os.Getenv("DATABASE_URL") != "" {
		config.ConnectPostgres()
	}

	if os.Getenv("REDIS_URL") != "" {
		config.ConnectRedis()
	}

	r := gin.Default()
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "UP"})
	})

	log.Fatal(r.Run(":8080"))
}
EOF

cat <<EOF > .env
PORT=8080
DATABASE_URL=
REDIS_URL=
EOF

echo -e "\n${GREEN}✔ Gin backend ready${NC}"
