import { prisma } from "@/core/database/connections/prisma";

const getGlobalContext = async () => {
  const now = new Date();

  return {
    prisma,
    now,
    // TODO: Implementar autenticación
    // user: await getUserFromToken(token)
  };
};

export default getGlobalContext;
