#!/bin/bash

# Script para generar solo el archivo .mutations.graphql
# Uso: bash generate_mutations_graphql.sh [nombre]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

NOMBRE="$1"

if [ -z "$NOMBRE" ]; then
  echo "❌ Falta el nombre del resolver"
  echo "Uso: bash generate_mutations_graphql.sh <nombre>"
  echo "Ejemplo: bash generate_mutations_graphql.sh Auth"
  exit 1
fi

# Función para convertir a kebab-case
to_kebab_case() {
  echo "$1" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//'
}

# Convertir a kebab-case para el nombre del archivo
nombre_kebab=$(to_kebab_case "$NOMBRE")

# Rutas
TYPEDEFS_DIR="$PROJECT_ROOT/src/core/api/graphql/typedefs"
MODEL_DIR="$TYPEDEFS_DIR/$nombre_kebab"

# Archivo a crear
MUTATIONS_FILE="$MODEL_DIR/${nombre_kebab}.mutations.graphql"

# Crear directorio si no existe
mkdir -p "$MODEL_DIR"

# Verificar si ya existe el archivo
if [ -f "$MUTATIONS_FILE" ]; then
  echo "⚠️  El archivo $MUTATIONS_FILE ya existe. No se sobrescribirá."
  exit 0
fi

# Generar solo el archivo mutations.graphql (definiciones de tipos)
cat > "$MUTATIONS_FILE" << EOF
# Definiciones de tipos para mutations de $NOMBRE
# TODO: Agregar definiciones de tipos según necesites

# Ejemplo de definición de tipo para mutation:
# type Mutation {
#   create${NOMBRE}(input: Create${NOMBRE}Input!): $NOMBRE!
#   update${NOMBRE}(id: ID!, input: Update${NOMBRE}Input!): $NOMBRE!
#   delete${NOMBRE}(id: ID!): $NOMBRE!
# }
EOF

echo "✅ Mutations GraphQL creado:"
echo "  - $MUTATIONS_FILE"
echo "📝 Recuerda revisar y ajustar las mutations según tus necesidades"
