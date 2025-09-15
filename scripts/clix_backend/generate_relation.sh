#!/bin/bash

# Script simple para generar relations
# Uso: bash generate_relation.sh [nombre]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

NOMBRE="$1"

if [ -z "$NOMBRE" ]; then
  echo "❌ Falta el nombre del resolver"
  echo "Uso: bash generate_relation.sh <nombre>"
  echo "Ejemplo: bash generate_relation.sh Comment"
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
RELATION_FILE="$MODEL_DIR/${nombre_kebab}.relations.resolvers.ts"

# Crear directorio si no existe
mkdir -p "$MODEL_DIR"

# Verificar si el archivo ya existe
if [ -f "$RELATION_FILE" ]; then
  echo "⚠️  El archivo $RELATION_FILE ya existe. No se sobrescribirá."
  exit 0
fi

# Generar el archivo de relations (básico)
cat > "$RELATION_FILE" << EOF
import type { IContext } from "@/config/types";
import type { ${NOMBRE}Resolvers } from "@/core/api/graphql/generated/backend";
import { get${NOMBRE}DataLoader } from "./${nombre_kebab}.dataloaders";

export const ${NOMBRE}Relations: ${NOMBRE}Resolvers<IContext> = {
  // TODO: Implementar relations para $NOMBRE
  // Ejemplo:
  // author: async (parent, _, context) => 
  //   await get${NOMBRE}DataLoader(context).load(parent.authorId),
};
EOF

echo "✅ Relations creado: $RELATION_FILE"
