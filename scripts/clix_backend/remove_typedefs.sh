#!/bin/bash

# Script para eliminar typedefs de un modelo
# Uso: bash remove_typedefs.sh <modelo>

set -e

MODELO="$1"

if [ -z "$MODELO" ]; then
  echo "❌ Falta el nombre del modelo"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MODEL_LOWER="$(echo "$MODELO" | tr '[:upper:]' '[:lower:]')"

TYPEDEFS_DIR="$PROJECT_ROOT/src/core/api/graphql/typedefs/$MODEL_LOWER"

if [ -d "$TYPEDEFS_DIR" ]; then
  rm -rf "$TYPEDEFS_DIR"
  echo "✅ Typedefs eliminados: $TYPEDEFS_DIR"
else
  echo "ℹ️  No se encontró typedefs para $MODELO"
fi
