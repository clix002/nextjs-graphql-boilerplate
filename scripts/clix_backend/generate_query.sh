#!/bin/bash

# Script inteligente para generar queries (detecta modelo vs standalone)
# Uso: bash generate_smart_query.sh [nombre]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

NOMBRE="$1"

if [ -z "$NOMBRE" ]; then
  echo "❌ Falta el nombre del resolver"
  echo "Uso: bash generate_smart_query.sh <nombre>"
  echo "Ejemplo: bash generate_smart_query.sh Auth"
  exit 1
fi

# Función para convertir a kebab-case
to_kebab_case() {
  echo "$1" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//'
}

# Convertir a kebab-case para el nombre del archivo
nombre_kebab=$(to_kebab_case "$NOMBRE")

# Función para convertir a camelCase
to_camel_case() {
  echo "$1" | awk '{print tolower(substr($0,1,1)) substr($0,2)}'
}

# Convertir a camelCase para variables
MODEL_CAMELCASE=$(to_camel_case "$NOMBRE")

# Rutas
RESOLVERS_DIR="$PROJECT_ROOT/src/core/api/graphql/resolvers"
MODEL_DIR="$RESOLVERS_DIR/$nombre_kebab"
QUERY_FILE="$MODEL_DIR/${nombre_kebab}.queries.resolvers.ts"

# Crear directorio si no existe
mkdir -p "$MODEL_DIR"

# Verificar si el archivo ya existe
if [ -f "$QUERY_FILE" ]; then
  echo "⚠️  El archivo $QUERY_FILE ya existe. No se sobrescribirá."
  exit 0
fi

# Función para detectar si es un modelo de Prisma
is_prisma_model() {
  local model_name="$1"
  local prisma_schema="$PROJECT_ROOT/src/core/database/prisma/schema"
  
  # Buscar en archivos .prisma el modelo exacto
  if find "$prisma_schema" -name "*.prisma" -exec grep -l "model $model_name" {} \; | grep -q .; then
    return 0  # Es un modelo de Prisma
  else
    return 1  # No es un modelo de Prisma (standalone)
  fi
}

# Generar el archivo de queries
if is_prisma_model "$NOMBRE"; then
  echo "🔍 Detectado: $NOMBRE es un modelo de Prisma"
  
  # Generar para modelo de Prisma
  cat > "$QUERY_FILE" << EOF
import type { QueryResolvers, ${NOMBRE} } from "@/core/api/graphql/generated/backend";
import type { IContext } from "@/config/types";
import ${MODEL_CAMELCASE}UseCase from "@/core/usecase/${nombre_kebab}/${nombre_kebab}.usecase";

export const ${NOMBRE}Queries: QueryResolvers<IContext> = {
  get${NOMBRE}ById: async (_, args, context) =>
    await ${MODEL_CAMELCASE}UseCase.get${NOMBRE}ById(args, context) as unknown as ${NOMBRE},
  // TODO: Implementar otras queries según necesites
};
EOF

else
  echo "🔍 Detectado: $NOMBRE es un resolver standalone"
  
  # Generar para standalone
  cat > "$QUERY_FILE" << EOF
import type { QueryResolvers } from "@/core/api/graphql/generated/backend";
import type { IContext } from "@/config/types";

export const ${NOMBRE}Queries: QueryResolvers<IContext> = {
  // TODO: Implementar queries para $NOMBRE
  // Ejemplo:
  // healthCheck: async () => ({
  //   status: "OK",
  //   timestamp: new Date().toISOString(),
  //   version: "1.0.0"
  // }),
  
  // Agregar más queries aquí...
};
EOF

fi

echo "✅ Query creado: $QUERY_FILE"
echo "📝 Recuerda implementar la lógica de las queries"
