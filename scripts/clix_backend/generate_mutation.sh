#!/bin/bash

# Script inteligente para generar mutations (detecta modelo vs standalone)
# Uso: bash generate_smart_mutation.sh [nombre]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

NOMBRE="$1"

if [ -z "$NOMBRE" ]; then
  echo "❌ Falta el nombre del resolver"
  echo "Uso: bash generate_smart_mutation.sh <nombre>"
  echo "Ejemplo: bash generate_smart_mutation.sh Auth"
  exit 1
fi

# Función para convertir a kebab-case
to_kebab_case() {
  echo "$1" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//'
}

# Convertir a kebab-case para el nombre del archivo
nombre_kebab=$(to_kebab_case "$NOMBRE")

# Rutas
RESOLVERS_DIR="$PROJECT_ROOT/src/core/api/graphql/resolvers"
MODEL_DIR="$RESOLVERS_DIR/$nombre_kebab"
MUTATION_FILE="$MODEL_DIR/${nombre_kebab}.mutations.resolvers.ts"

# Crear directorio si no existe
mkdir -p "$MODEL_DIR"

# Verificar si el archivo ya existe
if [ -f "$MUTATION_FILE" ]; then
  echo "⚠️  El archivo $MUTATION_FILE ya existe. No se sobrescribirá."
  exit 0
fi

# Función para convertir a camelCase
to_camel_case() {
  echo "$1" | awk '{print tolower(substr($0,1,1)) substr($0,2)}'
}

MODEL_CAMELCASE=$(to_camel_case "$NOMBRE")

# Generar el archivo de mutations (una básica)
cat > "$MUTATION_FILE" << EOF
import type { MutationResolvers, ${NOMBRE} } from "@/core/api/graphql/generated/backend";
import type { IContext } from "@/config/types";
import ${MODEL_CAMELCASE}UseCase from "@/core/usecase/${nombre_kebab}/${nombre_kebab}.usecase";

export const ${NOMBRE}Mutations: MutationResolvers<IContext> = {
  create${NOMBRE}: async (_, args, context) =>
    await ${MODEL_CAMELCASE}UseCase.create${NOMBRE}(args, context) as unknown as ${NOMBRE},
  // TODO: Implementar otras mutations según necesites
};
EOF

echo "✅ Mutation creado: $MUTATION_FILE"
echo "📝 Recuerda implementar la lógica de las mutations"
