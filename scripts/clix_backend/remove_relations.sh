#!/bin/bash

# Script para eliminar relations de un modelo
# Uso: bash remove_relations.sh <modelo>

set -e

MODELO="$1"

if [ -z "$MODELO" ]; then
  echo "❌ Falta el nombre del modelo"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MODEL_LOWER="$(echo "$MODELO" | tr '[:upper:]' '[:lower:]')"

RELATION_FILE="$PROJECT_ROOT/src/core/api/graphql/resolvers/$MODEL_LOWER/$MODEL_LOWER.relations.resolvers.ts"

if [ -f "$RELATION_FILE" ]; then
  rm -f "$RELATION_FILE"
  echo "✅ Relation eliminado: $RELATION_FILE"
else
  echo "ℹ️  No se encontró relation para $MODELO"
fi
