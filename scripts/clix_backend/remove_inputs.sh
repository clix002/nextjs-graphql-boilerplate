#!/bin/bash

# Script para eliminar inputs de un modelo
# Uso: bash remove_inputs.sh <modelo>

set -e

MODELO="$1"

if [ -z "$MODELO" ]; then
  echo "❌ Falta el nombre del modelo"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MODEL_LOWER="$(echo "$MODELO" | tr '[:upper:]' '[:lower:]')"

INPUT_FILE="$PROJECT_ROOT/src/core/api/graphql/typedefs/$MODEL_LOWER/$MODEL_LOWER.inputs.graphql"

if [ -f "$INPUT_FILE" ]; then
  rm -f "$INPUT_FILE"
  echo "✅ Input eliminado: $INPUT_FILE"
else
  echo "ℹ️  No se encontró input para $MODELO"
fi
