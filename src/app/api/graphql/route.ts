import { ApolloServer } from "@apollo/server";
import { startServerAndCreateNextHandler } from "@as-integrations/next";
import type { NextRequest } from "next/server";
import { createContext } from "@/core/api/graphql/context";
import { schema } from "@/core/api/graphql/schema";

const server = new ApolloServer({
  schema,
  formatError: (formattedError, error) => {
    if (process.env.NODE_ENV === "development") {
      console.error("🚨 GraphQL Error:", {
        message: formattedError.message,
        code: formattedError.extensions?.code,
        path: formattedError.path,
        stack: error instanceof Error ? error.stack : undefined,
      });
    }

    return formattedError;
  },
});

const handler = startServerAndCreateNextHandler<NextRequest>(server, {
  context: async (req) => await createContext(req),
});

export async function GET(request: NextRequest) {
  return handler(request);
}

export async function POST(request: NextRequest) {
  return handler(request);
}
