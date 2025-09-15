#!/bin/bash

# Script para actualizar schema.ts con los resolvers del index
# Uso: bash update_schema.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SCHEMA_FILE="$PROJECT_ROOT/src/core/api/graphql/schema.ts"
INDEX_FILE="$PROJECT_ROOT/src/core/api/graphql/resolvers/index.ts"

echo "🔄 Actualizando schema.ts..."

# Verificar que existe el index.ts
if [ ! -f "$INDEX_FILE" ]; then
  echo "❌ No se encontró el archivo index.ts en $INDEX_FILE"
  exit 1
fi

# Extraer los exports del index.ts
EXPORTS=$(grep "^export {" "$INDEX_FILE" | sed 's/export { \([^}]*\) } from.*/\1/' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sort -u)

# Separar exports por tipo
QUERIES=""
MUTATIONS=""
RELATIONS=""

for export in $EXPORTS; do
  if [[ "$export" == *"Queries" ]]; then
    QUERIES="$QUERIES        ...$export,
"
  elif [[ "$export" == *"Mutations" ]]; then
    MUTATIONS="$MUTATIONS        ...$export,
"
  elif [[ "$export" == *"Relations" ]]; then
    # Determinar el nombre del tipo para relations
    TYPE_NAME=$(echo "$export" | sed 's/Relations$//')
    RELATIONS="$RELATIONS      $TYPE_NAME: $export,
"
  fi
done

# Crear el bloque de imports
IMPORT_BLOCK="// Importar resolvers desde el index central
import {
"
for export in $EXPORTS; do
  if [[ -n "$export" ]]; then
    IMPORT_BLOCK="$IMPORT_BLOCK  $export,
"
  fi
done
IMPORT_BLOCK="$IMPORT_BLOCK} from \"./resolvers/index\";"

# Crear el archivo schema.ts completo
cat > "$SCHEMA_FILE" << EOF
import path from "node:path";
import { loadFilesSync } from "@graphql-tools/load-files";
import { mergeTypeDefs } from "@graphql-tools/merge";
import { makeExecutableSchema } from "@graphql-tools/schema";
import type { IContext } from "@/config/types";

$IMPORT_BLOCK

function createSchema() {
  const projectRoot = process.cwd();

  try {
    const typesArray = loadFilesSync(
      path.join(projectRoot, "src/core/api/graphql/typedefs/**/*.graphql"),
    );

    const typeDefs = mergeTypeDefs(typesArray);

    const resolvers = {
      Query: {
$QUERIES      },
      Mutation: {
$MUTATIONS      },
$RELATIONS    };

    return makeExecutableSchema<IContext>({
      typeDefs,
      resolvers,
    });
  } catch (error) {
    console.error("Error creating GraphQL schema:", error);
    throw error;
  }
}

export const schema = createSchema();
EOF

echo "✅ Schema.ts actualizado"
