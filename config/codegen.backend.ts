import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  overwrite: true,

  // Schema - Backend GraphQL types
  schema: "./src/core/api/graphql/typedefs/**/*.graphql",

  generates: {
    // Backend - Tipos para resolvers
    "src/core/api/graphql/generated/backend.ts": {
      plugins: ["typescript", "typescript-resolvers", "typescript-operations"],
      config: {
        useIndexSignature: true,
        contextType: "@/config/types#IContext",
        scalars: {
          DateTime: "Date",
          JSON: "any | any[]",
        },
      },
    },
  },
};

export default config;
