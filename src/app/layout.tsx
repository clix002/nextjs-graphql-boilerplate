import type { Metadata } from "next";
import { ApolloWrapper } from "@/client/apollo/apollo-wrapper";
import "./globals.css";

export const metadata: Metadata = {
  title: "Planoras",
  description: "Sistema de gestión académica",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="es">
      <body>
        <ApolloWrapper>{children}</ApolloWrapper>
      </body>
    </html>
  );
}
