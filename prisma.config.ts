import "dotenv/config";
import path from "node:path";
import { defineConfig } from "prisma/config";

export default defineConfig({
  schema: path.join(__dirname, "src/core/database/prisma/schema"),
  migrations: {
    path: path.join(__dirname, "src/core/database/prisma/migrations"),
  },
});
