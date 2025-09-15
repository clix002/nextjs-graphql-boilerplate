#!/bin/bash

# Script para eliminar mutations de un modelo
# Uso: bash remove_mutations.sh <modelo>

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

MUTATION_RESOLVER_FILE="$PROJECT_ROOT/src/core/api/graphql/resolvers/$MODEL_KEBAB/$MODEL_KEBAB.mutations.resolvers.ts"
MUTATION_GRAPHQL_FILE="$PROJECT_ROOT/src/core/api/graphql/typedefs/$MODEL_KEBAB/$MODEL_KEBAB.mutations.graphql"

# Eliminar archivo de resolver
if [ -f "$MUTATION_RESOLVER_FILE" ]; then
  rm -f "$MUTATION_RESOLVER_FILE"
  echo "✅ Mutation resolver eliminado: $MUTATION_RESOLVER_FILE"
else
  echo "ℹ️  No se encontró mutation resolver para $MODELO"
fi

# Eliminar archivo GraphQL
if [ -f "$MUTATION_GRAPHQL_FILE" ]; then
  rm -f "$MUTATION_GRAPHQL_FILE"
  echo "✅ Mutation GraphQL eliminado: $MUTATION_GRAPHQL_FILE"
else
  echo "ℹ️  No se encontró mutation GraphQL para $MODELO"
fi
