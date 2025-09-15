import credentials from "@/config/credentials";
import { PrismaClient as PrismaClientBase } from "../prisma/generated/prisma";
import { paginationModels } from "./pagination-models";

const globalForPrisma = global as unknown as { prisma: PrismaClientBase };

export const prismaCore =
  globalForPrisma.prisma ||
  new PrismaClientBase({
    datasources: {
      db: {
        url: credentials.database.sql.uri,
      },
    },
  });

export const prisma = prismaCore.$extends({
  model: paginationModels,
});

export type PrismaClientCore = typeof prismaCore;
export type PrismaClient = typeof prisma;

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prismaCore;
}
