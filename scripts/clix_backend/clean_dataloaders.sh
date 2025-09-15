#!/bin/bash

# Script para limpiar el archivo central de dataloaders
# Uso: bash clean_dataloaders.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DATALOADERS_FILE="$PROJECT_ROOT/src/core/api/graphql/dataloaders.ts"

# Crear archivo limpio
cat > "$DATALOADERS_FILE" << EOF
import type { IContext } from "@/config/types";

export const getDataLoaders = (context: IContext) => ({
  // TODO: Agregar dataloaders según necesites
  // Ejemplo:
  // userDataLoader: getUserDataLoader(context),
  // commentDataLoader: getCommentDataLoader(context),
});

export default getDataLoaders;
EOF

echo "✅ Archivo dataloaders.ts limpiado"
