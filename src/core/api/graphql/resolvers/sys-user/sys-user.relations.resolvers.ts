import type { IContext } from "@/config/types";
import type { SysUserResolvers } from "@/core/api/graphql/generated/backend";
import type { Comment } from "@/core/database/prisma/generated/prisma";

export const SysUserRelations: SysUserResolvers<IContext> = {
  comments: async ({ id }, _, context) =>
    (await context.dataLoaders.commentsByAuthorIdDataLoader.load(
      id,
    )) as unknown as Comment[],
};
