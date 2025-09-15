import type { NextRequest } from "next/server";
import type { IContext } from "@/config/types";
import { prisma } from "@/core/database/connections/prisma";
import getDataLoaders from "./dataloaders";

export async function createContext(_req: NextRequest): Promise<IContext> {
  const baseContext = {
    prisma,
    now: new Date(),
    // TODO: Agregar autenticación aquí
    // user: await getUserFromRequest(req)
  } as IContext;

  // Crear DataLoaders con el contexto base
  const dataLoaders = getDataLoaders(baseContext);

  return {
    ...baseContext,
    dataLoaders,
  };
}
