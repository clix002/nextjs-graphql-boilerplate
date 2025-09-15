import { HttpLink } from "@apollo/client";
import {
  ApolloClient,
  InMemoryCache,
  registerApolloClient,
} from "@apollo/client-integration-nextjs";
import { credentials } from "@/config";

export const { getClient, query, PreloadQuery } = registerApolloClient(() => {
  return new ApolloClient({
    cache: new InMemoryCache(),
    link: new HttpLink({
      // URL absoluta para SSR
      uri: credentials.graphql.url || "http://localhost:3000/api/graphql",
      fetchOptions: {
        // Opciones de fetch para Next.js
        cache: "no-store", // Para desarrollo
      },
    }),
  });
});
