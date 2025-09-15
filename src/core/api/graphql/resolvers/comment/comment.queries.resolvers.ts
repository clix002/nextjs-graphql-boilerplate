import type { IContext } from "@/config/types";
import type {
  Comment,
  QueryResolvers,
} from "@/core/api/graphql/generated/backend";
import commentUseCase from "@/core/usecase/comment/comment.usecase";

export const CommentQueries: QueryResolvers<IContext> = {
  getCommentById: async (_, args, context) =>
    (await commentUseCase.getCommentById(args, context)) as unknown as Comment,
  // TODO: Implementar otras queries según necesites
};
