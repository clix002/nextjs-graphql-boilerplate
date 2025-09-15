import { paginateWithPages } from "./paginateWithPages";
import type {
  PaginateInfo,
  PaginateOptions,
  PrismaModel,
  PrismaQuery,
} from "./types";

interface PaginatorOptions {
  pages?: {
    limit?: number;
  };
}

type Paginator = <T>(
  this: T,
  args?: Record<string, unknown>,
) => {
  withPages: (options?: PaginateOptions) => Promise<{
    docs: unknown[];
    info: PaginateInfo;
  }>;
};

export const createPaginator = (globalOptions?: PaginatorOptions): Paginator =>
  function paginate(this, args) {
    return {
      withPages: async (options = {}) => {
        const { limit, page, sort }: PaginateOptions = {
          ...globalOptions?.pages,
          ...options,
        };

        const query = (args ?? { where: {} }) as unknown as PrismaQuery;

        return await paginateWithPages(this as PrismaModel, query, {
          limit,
          page,
          sort,
        });
      },
    };
  };
