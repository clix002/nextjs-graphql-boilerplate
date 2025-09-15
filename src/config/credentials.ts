const credentials = {
  database: {
    sql: {
      uri: process.env.DATABASE_URL,
      shadowUri: process.env.SHADOW_DATABASE_URL,
    },
  },
  app: {
    url: process.env.NEXT_PUBLIC_APP_URL,
  },
  graphql: {
    url: process.env.NEXT_PUBLIC_GRAPHQL_URL,
  },
  prisma: {
    schemaPath: process.env.PRISMA_SCHEMA_PATH,
  },
  // Agregar más variables según necesites
};

export default credentials;
