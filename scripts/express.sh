#!/bin/bash

set -e

BOLD='\033[1m'
BLUE='\033[38;5;75m'
CYAN='\033[38;5;87m'
GREEN='\033[38;5;84m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;245m'
RED='\033[38;5;196m'
NC='\033[0m'

clear

echo -e "${PURPLE}┌──────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}│${NC}   ${BOLD}S C A F F O L D I N G   E X P R E S S${NC}              ${PURPLE}│${NC}"
echo -e "${PURPLE}│${NC}   Project initialization & structure setup   ${PURPLE}│${NC}"
echo -e "${PURPLE}└──────────────────────────────────────────────┘${NC}"

sleep 0.4


PM=${1:-bun}
PROJECT_NAME="express-service"

printf "\n${CYAN}❯${NC} Project Name ${GRAY}($PROJECT_NAME):${NC} "
read input_name
PROJECT_NAME=${input_name:-$PROJECT_NAME}

printf "${CYAN}❯${NC} Database ${GRAY}(mongodb/postgres/none):${NC} "
read DB_TYPE

printf "${CYAN}❯${NC} ORM ${GRAY}(prisma/mongoose/none):${NC} "
read ORM_TYPE

printf "${CYAN}❯${NC} Redis Cache? ${GRAY}(y/n):${NC} "
read USE_REDIS

# --- Workspace Engine ---
echo -e "\n${BLUE}⚙️  Architecting Directory Structure...${NC}"
mkdir -p "$PROJECT_NAME/src"/{config,controllers,services,routes,models,middlewares,types}
cd "$PROJECT_NAME"

# Handle PM init differences
if [ "$PM" == "pnpm" ]; then
    pnpm init > /dev/null
else
    $PM init -y > /dev/null
fi

CORE_DEPS="express dotenv cors helmet"
DEV_DEPS="typescript @types/express @types/node @types/cors ts-node-dev"

[[ "$ORM_TYPE" == "prisma" ]] && { CORE_DEPS+=" @prisma/client"; DEV_DEPS+=" prisma"; }
[[ "$ORM_TYPE" == "mongoose" ]] && CORE_DEPS+=" mongoose"
[[ "$USE_REDIS" == "y" ]] && CORE_DEPS+=" redis"

echo -e "${BLUE}📦 Provisioning Dependencies via $PM...${NC}"
case $PM in
    npm) npm install $CORE_DEPS && npm install -D $DEV_DEPS ;;
    pnpm) pnpm add $CORE_DEPS && pnpm add -D $DEV_DEPS ;;
    *) bun add $CORE_DEPS && bun add -d $DEV_DEPS ;;
esac

# --- Boilerplate Generation ---

# App & Entry
cat <<EOF > src/app.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import routes from './routes';

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use('/api/v1', routes);

export default app;
EOF

cat <<EOF > src/index.ts
import app from './app';
import dotenv from 'dotenv';
dotenv.config();

const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
    console.log(\`[SYSTEM] Server active on port \${PORT}\`);
});
EOF

# Database Config
if [[ "$ORM_TYPE" == "prisma" ]]; then
cat <<EOF > src/config/database.ts
import { PrismaClient } from '@prisma/client';
export const db = new PrismaClient();
EOF
elif [[ "$ORM_TYPE" == "mongoose" ]]; then
cat <<EOF > src/config/database.ts
import mongoose from 'mongoose';
export const connectDB = async () => {
    try {
        await mongoose.connect(process.env.DATABASE_URL!);
    } catch (err) {
        process.exit(1);
    }
};
EOF
fi

# Redis Config
if [[ "$USE_REDIS" == "y" ]]; then
cat <<EOF > src/config/redis.ts
import { createClient } from 'redis';
export const redis = createClient({ url: process.env.REDIS_URL });
redis.connect().catch(console.error);
EOF
fi

# Service Pattern
cat <<EOF > src/services/health.service.ts
export class HealthService {
    static async check() {
        return { status: "UP", timestamp: new Date().toISOString() };
    }
}
EOF

# Controller Pattern
cat <<EOF > src/controllers/health.controller.ts
import { Request, Response } from 'express';
import { HealthService } from '../services/health.service';

export const getHealth = async (_req: Request, res: Response) => {
    const status = await HealthService.check();
    res.status(200).json(status);
};
EOF

# Routing Pattern
cat <<EOF > src/routes/index.ts
import { Router } from 'express';
import { getHealth } from '../controllers/health.controller';

const router = Router();
router.get('/health', getHealth);
export default router;
EOF

# TsConfig
cat <<EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "CommonJS",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
EOF

# Env
echo "PORT=8080" > .env
echo "DATABASE_URL=\"\"" >> .env
[[ "$USE_REDIS" == "y" ]] && echo "REDIS_URL=\"redis://localhost:6379\"" >> .env

if [[ "$ORM_TYPE" == "prisma" ]]; then npx prisma init --datasource-provider postgresql > /dev/null; fi

echo -e "\n${GREEN}✔ Architecture Deployed Successfully${NC}"
echo -e "${GRAY}Location: ./${PROJECT_NAME}${NC}"
