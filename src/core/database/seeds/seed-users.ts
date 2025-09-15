import type { PrismaClientCore } from "../connections/prisma";
import Logger from "./logger";

export async function seedUsers(prisma: PrismaClientCore) {
  Logger.info("Seeding usuarios...");

  const users = await Promise.all([
    prisma.sysUser.upsert({
      where: { email: "admin@example.com" },
      update: {},
      create: {
        firstName: "Admin",
        lastName: "User",
        email: "admin@example.com",
      },
    }),
    prisma.sysUser.upsert({
      where: { email: "user@example.com" },
      update: {},
      create: {
        firstName: "Regular",
        lastName: "User",
        email: "user@example.com",
      },
    }),
  ]);

  Logger.success(`Usuarios creados: ${users.length}`);

  const comments = await Promise.all([
    prisma.comment.create({
      data: {
        content: "Este es un comentario de prueba del admin",
        authorId: users[0].id,
      },
    }),
    prisma.comment.create({
      data: {
        content: "Este es otro comentario del usuario regular",
        authorId: users[1].id,
      },
    }),
  ]);

  Logger.success(`Comentarios creados: ${comments.length}`);

  return { users, comments };
}
