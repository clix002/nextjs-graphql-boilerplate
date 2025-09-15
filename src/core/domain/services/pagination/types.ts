import type { Maybe } from "@/core/api/graphql/generated/backend";

export type PrismaModel = Record<"findMany" | "count", CallableFunction>;

export interface PrismaQuery {
  orderBy?: Record<string, unknown>;
  where: Record<string, unknown>;
}

export interface PaginateOptions {
  limit?: Maybe<number>;
  page?: Maybe<number>;
  sort?: Record<string, unknown>;
}

export interface PaginateInfo {
  hasNextPage: boolean;
  hasPrevPage: boolean;
  limit: number;
  nextPage?: number;
  page: number;
  prevPage?: number;
  totalDocs: number;
  totalPages: number;
}
