#!/bin/bash

source "$(dirname "$0")/utils.sh"
load_env_and_check_schema_path

resolve_prisma_info "$1"

MODEL_CAMELCASE=$(to_camel_case "$MODEL_NAME")
MODEL_KEBABCASE=$(echo "$MODEL_NAME" | sed 's/\([A-Z]\)/-\1/g' | sed 's/^-//' | tr '[:upper:]' '[:lower:]')

echo "🗑️  Eliminando dataloaders para $MODEL_NAME..."

# Eliminar archivo dataloader
rm -f "src/core/api/graphql/resolvers/$MODEL_KEBABCASE/$MODEL_KEBABCASE.dataloaders.ts"

# Remover del archivo central dataloaders.ts
DATALOADERS_FILE="src/core/api/graphql/dataloaders.ts"

# Remover import
sed -i "/import { get${MODEL_NAME}DataLoader } from \".\/resolvers\/$MODEL_KEBABCASE\/$MODEL_KEBABCASE\.dataloaders\";/d" "$DATALOADERS_FILE"

# Remover del objeto de retorno
sed -i "/${MODEL_CAMELCASE}DataLoader: get${MODEL_NAME}DataLoader(context),/d" "$DATALOADERS_FILE"

echo "✅ Dataloaders eliminado para $MODEL_NAME"
