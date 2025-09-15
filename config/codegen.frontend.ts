import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  overwrite: true,

  // Schema - Backend GraphQL types
  schema: "./src/core/api/graphql/typedefs/**/*.graphql",

  // Documents - Frontend GraphQL operations
  documents: "./src/client/apollo/typedefs/**/*.graphql",

  generates: {
    // Frontend - Hooks para React (Apollo Client v4+)
    "src/client/apollo/generated/": {
      preset: "client",
      plugins: [],
      presetConfig: {
        fragmentMasking: false,
      },
    },
  },
};

export default config;
