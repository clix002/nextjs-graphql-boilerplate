#!/bin/bash

# Script inteligente para generar typedefs (detecta modelo vs standalone)
# Uso: bash generate_smart_typedefs.sh [nombre]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

NOMBRE="$1"

if [ -z "$NOMBRE" ]; then
  echo "❌ Falta el nombre del resolver"
  echo "Uso: bash generate_smart_typedefs.sh <nombre>"
  echo "Ejemplo: bash generate_smart_typedefs.sh Auth"
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

# Archivo a crear (solo types)
TYPES_FILE="$MODEL_DIR/${nombre_kebab}.types.graphql"

# Crear directorio si no existe
mkdir -p "$MODEL_DIR"

# Verificar si ya existe el archivo
if [ -f "$TYPES_FILE" ]; then
  echo "⚠️  El archivo $TYPES_FILE ya existe. No se sobrescribirá."
  exit 0
fi

# Generar solo el archivo types.graphql
cat > "$TYPES_FILE" << EOF
# Tipos para $NOMBRE
# TODO: Revisar y ajustar los campos según tus necesidades

type $NOMBRE {
  id: ID!
  # TODO: Agregar campos aquí
  # Ejemplo:
  # name: String!
  # email: String!
}
EOF

echo "✅ Typedefs creado:"
echo "  - $TYPES_FILE"
echo "📝 Recuerda revisar y ajustar los tipos según tus necesidades"
