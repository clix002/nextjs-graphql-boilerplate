import { GraphQLError } from "graphql";
import { z } from "zod";

/**
 * Funciones de validación específicas para el backend (GraphQL)
 */

/**
 * Función para validar con Zod y convertir errores a GraphQLError
 * @param schema - Esquema de Zod para validar
 * @param input - Datos a validar (unknown para máxima seguridad)
 * @returns Datos validados con el tipo correcto
 * @throws GraphQLError con mensaje claro si la validación falla
 */
export function validateWithZod<T>(schema: z.ZodSchema<T>, input: unknown): T {
  try {
    return schema.parse(input);
  } catch (error) {
    if (error instanceof z.ZodError) {
      // Usar z.prettifyError() para mensajes más claros
      const prettyError = z.prettifyError(error);
      throw new GraphQLError(prettyError, {
        extensions: { code: "VALIDATION_ERROR", statusCode: 400 },
      });
    }
    throw error;
  }
}

/**
 * Helper para crear validadores automáticamente (para backend)
 * @param schema - Esquema de Zod
 * @returns Función validadora con el tipo correcto
 */
export function createValidator<T extends z.ZodTypeAny>(schema: T) {
  return (input: unknown): z.infer<T> => {
    return validateWithZod(schema, input) as z.infer<T>;
  };
}
