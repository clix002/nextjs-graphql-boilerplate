import type { IContext } from "@/config/types";
import type {
  Comment,
  MutationResolvers,
} from "@/core/api/graphql/generated/backend";
import commentUseCase from "@/core/usecase/comment/comment.usecase";

export const CommentMutations: MutationResolvers<IContext> = {
  createComment: async (_, args, context) =>
    (await commentUseCase.createComment(args, context)) as unknown as Comment,
  // TODO: Implementar otras mutations según necesites
};
