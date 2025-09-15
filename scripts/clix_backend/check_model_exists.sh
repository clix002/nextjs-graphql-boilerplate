#!/bin/bash

# Script para verificar si un modelo existe en Prisma
# Uso: bash check_model_exists.sh [nombre]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

NOMBRE="$1"

if [ -z "$NOMBRE" ]; then
  echo "❌ Falta el nombre del modelo"
  exit 1
fi

# Función para detectar si es un modelo de Prisma
is_prisma_model() {
  local model_name="$1"
  local prisma_schema="$PROJECT_ROOT/src/core/database/prisma/schema"
  
  # Buscar en archivos .prisma el modelo exacto
  if find "$prisma_schema" -name "*.prisma" -exec grep -l "model $model_name" {} \; 2>/dev/null | grep -q .; then
    return 0  # Es un modelo de Prisma
  else
    return 1  # No es un modelo de Prisma (standalone)
  fi
}

# Verificar si es un modelo de Prisma
if is_prisma_model "$NOMBRE"; then
  exit 0  # Existe
else
  exit 1  # No existe
fi
