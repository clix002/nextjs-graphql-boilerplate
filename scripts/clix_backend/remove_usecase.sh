#!/bin/bash

# Script para eliminar usecase de un modelo
# Uso: bash remove_usecase.sh <modelo>

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

USECASE_DIR="$PROJECT_ROOT/src/core/usecase/$MODEL_KEBAB"

if [ -d "$USECASE_DIR" ]; then
  rm -rf "$USECASE_DIR"
  echo "✅ Usecase eliminado: $USECASE_DIR"
else
  echo "ℹ️  No se encontró usecase para $MODELO"
fi
