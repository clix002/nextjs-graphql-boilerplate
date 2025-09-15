import { z } from "zod";

/**
 * Funciones de validación específicas para el frontend (React Hook Form)
 * Aprovechando las nuevas funcionalidades de Zod 4
 */

/**
 * Función para validar en el frontend y obtener errores organizados por campo
 * Utiliza z.flattenError() de Zod 4 para mejor manejo de errores
 * @param schema - Esquema de Zod
 * @param input - Datos a validar
 * @returns Objeto con success, data y errors organizados por campo
 */
export function validateForFrontend<T extends z.ZodTypeAny>(
  schema: T,
  input: unknown,
): {
  success: boolean;
  data?: z.infer<T>;
  errors?: { [key: string]: string };
  formErrors?: string[];
} {
  const result = schema.safeParse(input);

  if (result.success) {
    return { success: true, data: result.data };
  }

  // Usar z.flattenError() de Zod 4 para mejor manejo de errores
  const flattened = z.flattenError(result.error);
  const fieldErrors: { [key: string]: string } = {};

  // Convertir errores de campo a objeto simple
  Object.entries(flattened.fieldErrors).forEach(([field, errors]) => {
    if (Array.isArray(errors) && errors.length > 0) {
      fieldErrors[field] = errors[0]; // Solo el primer error por campo
    }
  });

  return {
    success: false,
    errors: fieldErrors,
    formErrors: flattened.formErrors || [],
  };
}

/**
 * Helper para crear validadores de frontend automáticamente
 * @param schema - Esquema de Zod
 * @returns Función validadora para el frontend
 */
export function createFrontendValidator<T extends z.ZodTypeAny>(schema: T) {
  return (input: unknown) => {
    return validateForFrontend(schema, input);
  };
}

/**
 * Función para obtener errores en formato de árbol (nested structure)
 * Útil para formularios complejos con validaciones anidadas
 * @param schema - Esquema de Zod
 * @param input - Datos a validar
 * @returns Estructura de árbol con errores organizados jerárquicamente
 */
export function validateWithTreeErrors<T extends z.ZodTypeAny>(
  schema: T,
  input: unknown,
): {
  success: boolean;
  data?: z.infer<T>;
  treeErrors?: ReturnType<typeof z.treeifyError>;
} {
  const result = schema.safeParse(input);

  if (result.success) {
    return { success: true, data: result.data };
  }

  // Usar z.treeifyError() de Zod 4 para estructura jerárquica
  const treeErrors = z.treeifyError(result.error);

  return {
    success: false,
    treeErrors,
  };
}

/**
 * Función para obtener errores formateados de forma legible
 * Útil para mostrar errores al usuario en formato texto
 * @param schema - Esquema de Zod
 * @param input - Datos a validar
 * @returns String formateado con errores legibles
 */
export function validateWithPrettyErrors<T extends z.ZodTypeAny>(
  schema: T,
  input: unknown,
): {
  success: boolean;
  data?: z.infer<T>;
  prettyErrors?: string;
} {
  const result = schema.safeParse(input);

  if (result.success) {
    return { success: true, data: result.data };
  }

  // Usar z.prettifyError() de Zod 4 para errores legibles
  const prettyErrors = z.prettifyError(result.error);

  return {
    success: false,
    prettyErrors,
  };
}
