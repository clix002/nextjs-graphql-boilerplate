#!/bin/bash

# Script para eliminar queries de un modelo
# Uso: bash remove_queries.sh <modelo>

set -e

MODELO="$1"

if [ -z "$MODELO" ]; then
  echo "❌ Falta el nombre del modelo"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Función para convertir a kebab-case
to_kebab_case() {
  echo "$1" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//'
}

MODEL_KEBAB=$(to_kebab_case "$MODELO")

QUERY_RESOLVER_FILE="$PROJECT_ROOT/src/core/api/graphql/resolvers/$MODEL_KEBAB/$MODEL_KEBAB.queries.resolvers.ts"
QUERY_GRAPHQL_FILE="$PROJECT_ROOT/src/core/api/graphql/typedefs/$MODEL_KEBAB/$MODEL_KEBAB.queries.graphql"

# Eliminar archivo de resolver
if [ -f "$QUERY_RESOLVER_FILE" ]; then
  rm -f "$QUERY_RESOLVER_FILE"
  echo "✅ Query resolver eliminado: $QUERY_RESOLVER_FILE"
else
  echo "ℹ️  No se encontró query resolver para $MODELO"
fi

# Eliminar archivo GraphQL
if [ -f "$QUERY_GRAPHQL_FILE" ]; then
  rm -f "$QUERY_GRAPHQL_FILE"
  echo "✅ Query GraphQL eliminado: $QUERY_GRAPHQL_FILE"
else
  echo "ℹ️  No se encontró query GraphQL para $MODELO"
fi
