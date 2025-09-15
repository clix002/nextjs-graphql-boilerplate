import type { PrismaClient } from "@/core/database/connections/prisma";
import type { PaginateOptions, PrismaModel, PrismaQuery } from "./types";

const resetSelection = {
  include: undefined,
  omit: undefined,
  select: undefined,
};

const resetOrdering = {
  orderBy: undefined,
};

export const paginateWithPages = async (
  model: PrismaModel,
  query: PrismaQuery,
  { limit, page, sort }: PaginateOptions,
) => {
  const currentPage = page ?? 1;
  const take = limit ?? 15;
  const skip = (currentPage - 1) * take;

  const [docs, totalDocs] = await Promise.all([
    model.findMany({
      ...query,
      orderBy: query.orderBy ?? sort,
      skip,
      take,
    }),
    model.count({
      ...query,
      ...resetSelection,
      ...resetOrdering,
    }),
  ]);

  const totalPages = Math.ceil(totalDocs / take);
  const prevPage = currentPage > 1 ? currentPage - 1 : undefined;
  const nextPage = currentPage < totalPages ? currentPage + 1 : undefined;

  return {
    docs,
    info: {
      hasNextPage: Boolean(nextPage),
      hasPrevPage: Boolean(prevPage),
      limit: take,
      nextPage,
      page: currentPage,
      prevPage,
      totalDocs,
      totalPages,
    },
  };
};

interface PaginateRawQueryArgs<T> {
  countQuery?: unknown;
  docs?: T[];
  pagination: PaginateOptions;
  prisma: PrismaClient;
  query: unknown;
}

export const paginateRawQuery = async <T>({
  countQuery,
  pagination: { limit, page },
  prisma,
  query,
}: PaginateRawQueryArgs<T>) => {
  const currentPage = page ?? 1;
  const take = limit ?? 15;
  const skip = (currentPage - 1) * take;

  const docsQuery = `${query} LIMIT ${take} OFFSET ${skip};`;

  const getCountQuery = () => {
    if (countQuery) return String(countQuery);

    return `SELECT COUNT(*) as totalDocs FROM (${query}) as totalCount;`;
  };

  const [docs, [{ totalDocs }]] = await Promise.all([
    prisma.$queryRawUnsafe<T[]>(docsQuery),
    prisma.$queryRawUnsafe<[{ totalDocs: bigint }]>(getCountQuery()),
  ]);

  const totalPages = Math.ceil(Number(totalDocs) / take);
  const prevPage = currentPage > 1 ? currentPage - 1 : undefined;
  const nextPage = currentPage < totalPages ? currentPage + 1 : undefined;

  return {
    docs: docs as T[],
    info: {
      hasNextPage: Boolean(nextPage),
      hasPrevPage: Boolean(prevPage),
      limit: take,
      nextPage,
      page: currentPage,
      prevPage,
      totalDocs: Number(totalDocs),
      totalPages,
    },
  };
};
