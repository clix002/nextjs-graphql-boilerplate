import type { IContext } from "@/config/types";
import {
  getCommentDataLoader,
  getCommentsByAuthorIdDataLoader,
} from "./resolvers/comment/comment.dataloaders";

export const getDataLoaders = (context: IContext) => ({
  commentDataLoader: getCommentDataLoader(context),
  commentsByAuthorIdDataLoader: getCommentsByAuthorIdDataLoader(context),
  // TODO: Agregar dataloaders según necesites
  // Ejemplo:
  // userDataLoader: getUserDataLoader(context),
});

export default getDataLoaders;
