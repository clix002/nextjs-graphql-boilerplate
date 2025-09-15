#!/bin/bash

# Script inteligente para eliminar todos los artefactos
# No depende de utils.sh, funciona con cualquier nombre de modelo

MODELO="$1"

if [ -z "$MODELO" ]; then
  echo "❌ Uso: $0 <MODELO>"
  exit 1
fi

# Función para convertir a kebab-case
to_kebab_case() {
  echo "$1" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//'
}

MODEL_KEBABCASE=$(to_kebab_case "$MODELO")

echo "🗑️  Eliminando todos los artefactos para $MODELO..."

# Eliminar typedefs
if [ -d "src/core/api/graphql/typedefs/$MODEL_KEBABCASE" ]; then
  rm -rf "src/core/api/graphql/typedefs/$MODEL_KEBABCASE"
  echo "✅ Typedefs eliminados: src/core/api/graphql/typedefs/$MODEL_KEBABCASE"
else
  echo "ℹ️  No se encontraron typedefs para $MODELO"
fi

# Eliminar resolvers
if [ -d "src/core/api/graphql/resolvers/$MODEL_KEBABCASE" ]; then
  rm -rf "src/core/api/graphql/resolvers/$MODEL_KEBABCASE"
  echo "✅ Resolvers eliminados: src/core/api/graphql/resolvers/$MODEL_KEBABCASE"
else
  echo "ℹ️  No se encontraron resolvers para $MODELO"
fi

# Eliminar usecase
if [ -d "src/core/usecase/$MODEL_KEBABCASE" ]; then
  rm -rf "src/core/usecase/$MODEL_KEBABCASE"
  echo "✅ Usecase eliminado: src/core/usecase/$MODEL_KEBABCASE"
else
  echo "ℹ️  No se encontró usecase para $MODELO"
fi

# Limpiar archivo central de dataloaders
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/clean_dataloaders.sh"

echo "✅ Todos los artefactos eliminados para $MODELO"
