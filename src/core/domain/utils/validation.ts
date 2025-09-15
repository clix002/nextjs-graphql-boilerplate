import { GraphQLError } from "graphql";
import { z } from "zod";

/**
 * Funciones de validación específicas para el backend (GraphQL)
 * Aprovechando las nuevas funcionalidades de Zod 4
 */

/**
 * Función para validar en el backend y lanzar GraphQLError si falla
 * Utiliza las nuevas funcionalidades de Zod 4 para mejor manejo de errores
 * @param schema - Esquema de Zod
 * @param input - Datos a validar
 * @returns Datos validados o lanza GraphQLError
 */
export function validateForBackend<T extends z.ZodTypeAny>(
  schema: T,
  input: unknown,
): z.infer<T> {
  const result = schema.safeParse(input);

  if (result.success) {
    return result.data;
  }

  // Usar z.prettifyError() de Zod 4 para mensajes más legibles
  const prettyErrors = z.prettifyError(result.error);

  throw new GraphQLError(`Error de validación:\n${prettyErrors}`, {
    extensions: {
      code: "VALIDATION_ERROR",
      validationErrors: result.error.issues,
      // Incluir información adicional para debugging
      timestamp: new Date().toISOString(),
    },
  });
}

/**
 * Helper para crear validadores de backend automáticamente
 * @param schema - Esquema de Zod
 * @returns Función validadora para el backend
 */
export function createValidator<T extends z.ZodTypeAny>(schema: T) {
  return (input: unknown) => {
    return validateForBackend(schema, input);
  };
}

/**
 * Función para validar con manejo personalizado de errores
 * Permite personalizar el mensaje de error y la información adicional
 * @param schema - Esquema de Zod
 * @param input - Datos a validar
 * @param options - Opciones de personalización
 * @returns Datos validados o lanza GraphQLError personalizado
 */
export function validateWithCustomError<T extends z.ZodTypeAny>(
  schema: T,
  input: unknown,
  options: {
    errorMessage?: string;
    errorCode?: string;
    includeInput?: boolean;
  } = {},
): z.infer<T> {
  const result = schema.safeParse(input, {
    reportInput: options.includeInput || false,
  });

  if (result.success) {
    return result.data;
  }

  // Usar z.flattenError() para obtener errores organizados
  const flattened = z.flattenError(result.error);

  const errorMessage = options.errorMessage || "Error de validación";
  const errorCode = options.errorCode || "VALIDATION_ERROR";

  throw new GraphQLError(errorMessage, {
    extensions: {
      code: errorCode,
      fieldErrors: flattened.fieldErrors,
      formErrors: flattened.formErrors,
      // Incluir información adicional para debugging
      timestamp: new Date().toISOString(),
      input: options.includeInput ? input : undefined,
    },
  });
}

/**
 * Función para validar arrays de datos
 * Útil para validar múltiples elementos de una vez
 * @param schema - Esquema de Zod
 * @param inputs - Array de datos a validar
 * @returns Array de datos validados o lanza GraphQLError
 */
export function validateArray<T extends z.ZodTypeAny>(
  schema: T,
  inputs: unknown[],
): z.infer<T>[] {
  const results = inputs.map((input, index) => {
    const result = schema.safeParse(input);

    if (!result.success) {
      const prettyErrors = z.prettifyError(result.error);
      throw new GraphQLError(
        `Error de validación en elemento ${index}:\n${prettyErrors}`,
        {
          extensions: {
            code: "VALIDATION_ERROR",
            index,
            validationErrors: result.error.issues,
            timestamp: new Date().toISOString(),
          },
        },
      );
    }

    return result.data;
  });

  return results;
}
