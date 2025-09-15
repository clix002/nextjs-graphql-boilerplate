import DataLoader from "dataloader";
import { groupBy, keyBy } from "es-toolkit";
import type { IContext } from "@/config/types";
import type { Comment } from "@/core/api/graphql/generated/backend";

// Comment DataLoader - Carga Comments por ID
export const getCommentDataLoader = (context: IContext) =>
  new DataLoader<string, Comment | null, string>(
    async (ids) => {
      const items = await context.prisma.comment.findMany({
        where: { id: { in: ids as string[] } },
      });

      const itemById = keyBy(items, ({ id }) => id);

      return ids.map((id) => itemById[id] ?? null);
    },
    { cacheKeyFn: (key) => JSON.stringify(key) },
  );

// Comment DataLoader - Carga Comments por authorId
export const getCommentsByAuthorIdDataLoader = (context: IContext) =>
  new DataLoader<string, Comment[], string>(
    async (authorIds) => {
      const items = await context.prisma.comment.findMany({
        where: { authorId: { in: authorIds as string[] } },
      });

      const itemsByAuthorId = groupBy(items, ({ authorId }) => authorId);

      return authorIds.map((authorId) => itemsByAuthorId[authorId] ?? []);
    },
    { cacheKeyFn: (key) => JSON.stringify(key) },
  );
