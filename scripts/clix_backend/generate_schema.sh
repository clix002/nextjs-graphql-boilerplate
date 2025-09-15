#!/bin/bash

# Script para generar schemas de Zod en shared
# Útil para crear schemas sin generar usecases

MODELO="$1"
PROJECT_ROOT="$(pwd)"

# Función para convertir a camelCase
to_camel_case() {
  echo "$1" | awk '{print tolower(substr($0,1,1)) substr($0,2)}'
}

if [ -z "$MODELO" ]; then
  echo "❌ Uso: $0 <MODELO>"
  echo "💡 Ejemplo: $0 Product"
  exit 1
fi

MODEL_CAMELCASE=$(to_camel_case "$MODELO")
SHARED_SCHEMAS_DIR="src/shared/domain/schemas/$MODEL_CAMELCASE"
SHARED_SCHEMAS_FILE="$SHARED_SCHEMAS_DIR/${MODEL_CAMELCASE}.schemas.ts"

# Crear carpeta destino
mkdir -p "$SHARED_SCHEMAS_DIR"

if [ -f "$SHARED_SCHEMAS_FILE" ]; then
  echo "⚠️  El archivo $SHARED_SCHEMAS_FILE ya existe. No se sobrescribirá."
  exit 0
fi

# Generar schema de Zod
cat <<EOF > "$SHARED_SCHEMAS_FILE"
import { z } from "zod";

// Schema base para $MODELO
export const ${MODELO}Schema = z.object({
  id: z.string().optional(),
  // TODO: Agregar campos específicos del modelo $MODELO
  // Ejemplo:
  // name: z.string().min(1, "El nombre es requerido"),
  // email: z.string().email("Email inválido"),
  // age: z.number().min(0, "La edad debe ser positiva"),
});

// Schema para crear $MODELO
export const Create${MODELO}Schema = ${MODELO}Schema.omit({
  id: true,
});

// Schema para actualizar $MODELO
export const Update${MODELO}Schema = ${MODELO}Schema.partial().omit({
  id: true,
});

// Tipos TypeScript
export type ${MODELO}Type = z.infer<typeof ${MODELO}Schema>;
export type Create${MODELO}Input = z.infer<typeof Create${MODELO}Schema>;
export type Update${MODELO}Input = z.infer<typeof Update${MODELO}Schema>;
EOF

echo "✅ Schema de Zod creado: $SHARED_SCHEMAS_FILE"
echo "📝 Recuerda definir los campos específicos del modelo $MODELO"
echo "💡 Puedes usar: pnpm clix:b create:schema $MODELO para regenerar"
