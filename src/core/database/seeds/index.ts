import "dotenv/config";
import { prismaCore } from "../connections/prisma";
import Logger from "./logger";
import { seedUsers } from "./seed-users";

async function main() {
  Logger.step("INICIO", "Iniciando seeding de la base de datos");

  try {
    Logger.info("Limpiando datos existentes...");
    await prismaCore.comment.deleteMany();
    await prismaCore.sysUser.deleteMany();
    Logger.success("Datos limpiados");

    await seedUsers(prismaCore);

    Logger.success("Seeding completado exitosamente");
  } catch (error) {
    Logger.error(`Error durante el seeding: ${error}`);
    throw error;
  } finally {
    await prismaCore.$disconnect();
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
