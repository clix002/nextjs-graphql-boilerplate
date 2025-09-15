import { GraphQLError } from "graphql";

/**
 * Helper para crear errores de GraphQL de forma consistente
 *
 * @param message - Mensaje de error para el usuario
 * @param code - Código de error único
 * @param field - Campo específico que causó el error (opcional)
 * @param extensions - Extensiones adicionales (opcional)
 */
export const throwGraphQLError = (
  message: string,
  code: string,
  field?: string,
  extensions?: Record<string, unknown>,
) => {
  throw new GraphQLError(message, {
    extensions: {
      code,
      field,
      timestamp: new Date().toISOString(),
      ...extensions,
    },
  });
};
