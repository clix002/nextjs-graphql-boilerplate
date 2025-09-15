import path from "node:path";
import { loadFilesSync } from "@graphql-tools/load-files";
import { mergeTypeDefs } from "@graphql-tools/merge";
import { makeExecutableSchema } from "@graphql-tools/schema";
import type { IContext } from "@/config/types";

// Importar resolvers desde el index central
import {
  CommentMutations,
  CommentQueries,
  SysUserMutations,
  SysUserQueries,
  SysUserRelations,
} from "./resolvers/index";

function createSchema() {
  const projectRoot = process.cwd();

  try {
    const typesArray = loadFilesSync(
      path.join(projectRoot, "src/core/api/graphql/typedefs/**/*.graphql"),
    );

    const typeDefs = mergeTypeDefs(typesArray);

    const resolvers = {
      Query: {
        ...CommentQueries,
        ...SysUserQueries,
      },
      Mutation: {
        ...CommentMutations,
        ...SysUserMutations,
      },
      SysUser: SysUserRelations,
    };

    return makeExecutableSchema<IContext>({
      typeDefs,
      resolvers,
    });
  } catch (error) {
    console.error("Error creating GraphQL schema:", error);
    throw error;
  }
}

export const schema = createSchema();
