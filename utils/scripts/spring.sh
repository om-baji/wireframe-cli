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
echo -e "${PURPLE}│${NC}   ${BOLD}S C A F F O L D I N G   S P R I N G   B O O T${NC} ${PURPLE}│${NC}"
echo -e "${PURPLE}│${NC}   Enterprise backend ready                  ${PURPLE}│${NC}"
echo -e "${PURPLE}└──────────────────────────────────────────────┘${NC}"
sleep 0.4

PROJECT_NAME="spring-service"
GROUP_ID="com.example"

printf "\n${CYAN}❯${NC} Project Name ${GRAY}($PROJECT_NAME):${NC} "
read input
PROJECT_NAME=${input:-$PROJECT_NAME}

DEPS="web,data-jpa,postgresql,data-redis"

curl -s https://start.spring.io/starter.zip \
  -d dependencies=$DEPS \
  -d language=java \
  -d type=maven-project \
  -d groupId=$GROUP_ID \
  -d artifactId=$PROJECT_NAME \
  -d name=$PROJECT_NAME \
  -d packageName=$GROUP_ID.$PROJECT_NAME \
  -o $PROJECT_NAME.zip

unzip -q $PROJECT_NAME.zip
rm $PROJECT_NAME.zip

cat <<EOF > src/main/resources/application.yml
server:
  port: 8080
spring:
  datasource:
    url: \${DATABASE_URL}
  redis:
    url: \${REDIS_URL}
EOF

echo -e "\n${GREEN}✔ Spring Boot backend ready${NC}"
