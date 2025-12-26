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
echo -e "${PURPLE}│${NC}   ${BOLD}S C A F F O L D I N G   F A S T A P I${NC}        ${PURPLE}│${NC}"
echo -e "${PURPLE}│${NC}   Async backend ready-to-run                 ${PURPLE}│${NC}"
echo -e "${PURPLE}└──────────────────────────────────────────────┘${NC}"
sleep 0.4

PROJECT_NAME="fastapi-service"
printf "\n${CYAN}❯${NC} Project Name ${GRAY}($PROJECT_NAME):${NC} "
read input
PROJECT_NAME=${input:-$PROJECT_NAME}

printf "${CYAN}❯${NC} Database ${GRAY}(postgres/mongodb/none):${NC} "
read DB

printf "${CYAN}❯${NC} Redis Cache? ${GRAY}(y/n):${NC} "
read REDIS

mkdir -p "$PROJECT_NAME"/app/{core,api,services}
cd "$PROJECT_NAME"

python3 -m venv venv
source venv/bin/activate

pip install fastapi uvicorn python-dotenv

[[ "$DB" == "postgres" ]] && pip install sqlalchemy psycopg2-binary
[[ "$DB" == "mongodb" ]] && pip install motor
[[ "$REDIS" == "y" ]] && pip install redis

cat <<EOF > app/core/database.py
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

engine = create_engine(os.getenv("DATABASE_URL"))
SessionLocal = sessionmaker(bind=engine)
EOF

cat <<EOF > app/core/redis.py
import os
import redis

redis_client = redis.Redis.from_url(os.getenv("REDIS_URL"))
EOF

cat <<EOF > app/main.py
from fastapi import FastAPI
from app.core.database import engine
from app.core.redis import redis_client

app = FastAPI()

@app.get("/health")
async def health():
    return {"status": "UP"}
EOF

cat <<EOF > .env
PORT=8000
DATABASE_URL=
REDIS_URL=
EOF

echo -e "\n${GREEN}✔ FastAPI backend ready${NC}"
