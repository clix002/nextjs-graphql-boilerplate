"use client";
// ^ este archivo necesita el pragma "use client"

import { HttpLink } from "@apollo/client";
import {
  ApolloClient,
  ApolloNextAppProvider,
  InMemoryCache,
} from "@apollo/client-integration-nextjs";
import { credentials } from "@/config";

function makeClient() {
  const httpLink = new HttpLink({
    uri: credentials.graphql.url || "http://localhost:3000/api/graphql",
    fetchOptions: {
      cache: "no-store", // Para desarrollo
    },
  });

  return new ApolloClient({
    cache: new InMemoryCache(),
    link: httpLink,
  });
}

export function ApolloWrapper({ children }: React.PropsWithChildren) {
  return (
    <ApolloNextAppProvider makeClient={makeClient}>
      {children}
    </ApolloNextAppProvider>
  );
}
