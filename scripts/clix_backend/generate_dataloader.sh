#!/bin/bash

# Script inteligente para generar dataloaders
# Detecta automáticamente si es un modelo de Prisma o standalone

MODELO="$1"
PROJECT_ROOT="$(pwd)"

# Función para convertir a kebab-case
to_kebab_case() {
  echo "$1" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//'
}

if [ -z "$MODELO" ]; then
  echo "❌ Uso: $0 <MODELO>"
  exit 1
fi

MODEL_KEBABCASE=$(to_kebab_case "$MODELO")
MODEL_CAMELCASE=$(echo "$MODELO" | awk '{print tolower(substr($0,1,1)) substr($0,2)}')
BASE_DIR="src/core/api/graphql/resolvers"
TARGET_DIR="$BASE_DIR/$MODEL_KEBABCASE"
TARGET_FILE="$TARGET_DIR/${MODEL_KEBABCASE}.dataloaders.ts"

# Crear carpeta destino
mkdir -p "$TARGET_DIR"

if [ -f "$TARGET_FILE" ]; then
  echo "⚠️  El archivo $TARGET_FILE ya existe. No se sobrescribirá."
  exit 0
fi

# Generar dataloader básico
cat <<EOF > "$TARGET_FILE"
import DataLoader from "dataloader";
import { keyBy } from "es-toolkit";
import type { IContext } from "@/config/types";
import type { $MODELO } from "@/core/api/graphql/generated/backend";

// $MODELO DataLoader - Carga ${MODELO}s por ID
export const get${MODELO}DataLoader = (context: IContext) =>
  new DataLoader<string, $MODELO | null, string>(
    async (ids) => {
      const items = await context.prisma.$MODEL_CAMELCASE.findMany({
        where: { id: { in: ids as string[] } },
      });

      const itemById = keyBy(items, ({ id }) => id);

      return ids.map((id) => itemById[id] ?? null);
    },
    { cacheKeyFn: (key) => JSON.stringify(key) },
  );
EOF

# Registrar en dataloaders.ts central
DATALOADERS_FILE="$PROJECT_ROOT/src/core/api/graphql/dataloaders.ts"

# Agregar import
sed -i "/^import type { IContext } from \"@\/config\/types\";/a\\
import { get${MODELO}DataLoader } from \"./resolvers/$MODEL_KEBABCASE/$MODEL_KEBABCASE.dataloaders\";" "$DATALOADERS_FILE"

# Agregar al objeto de retorno
sed -i "/^export const getDataLoaders = (context: IContext) => ({/a\\
  ${MODEL_CAMELCASE}DataLoader: get${MODELO}DataLoader(context)," "$DATALOADERS_FILE"

echo "✅ Dataloader creado: $TARGET_FILE"
echo "✅ Dataloader registrado en dataloaders.ts central"
echo "📝 Recuerda implementar la lógica de carga de datos según tus necesidades"
