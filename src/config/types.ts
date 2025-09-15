import type { PrismaClient } from "../core/database/connections/prisma";

export type IDataLoaders = ReturnType<
  typeof import("../core/api/graphql/dataloaders").getDataLoaders
>;

export interface IContext {
  prisma: PrismaClient;
  now: Date;
  dataLoaders: IDataLoaders;
  // TODO: Agregar autenticación en el futuro
  // user?: {
  //   id: string;
  //   role: string;
  // };
}

export interface IContextOperation {
  prisma: PrismaClient;
  now: Date;
  // TODO: Agregar autenticación en el futuro
  // user?: {
  //   id: string;
  //   role: string;
  // };
}

export type IContextTransaction = Omit<IContext, "prisma"> & {
  prisma: PrismaClient;
};

export type IContextWithSelectFactory<TSelect> = IContext & {
  select?: Partial<Record<keyof TSelect, boolean>> | null;
};
