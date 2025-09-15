#!/bin/bash

# Script simple para generar inputs
# Uso: bash generate_input.sh [nombre]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

NOMBRE="$1"

if [ -z "$NOMBRE" ]; then
  echo "❌ Falta el nombre del resolver"
  echo "Uso: bash generate_input.sh <nombre>"
  echo "Ejemplo: bash generate_input.sh Comment"
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
INPUT_FILE="$MODEL_DIR/${nombre_kebab}.inputs.graphql"

# Crear directorio si no existe
mkdir -p "$MODEL_DIR"

# Verificar si el archivo ya existe
if [ -f "$INPUT_FILE" ]; then
  echo "⚠️  El archivo $INPUT_FILE ya existe. No se sobrescribirá."
  exit 0
fi

# Generar el archivo de inputs (uno básico)
cat > "$INPUT_FILE" << EOF
# TODO: Agregar inputs según necesites
# input Create${NOMBRE}Input {
#   # Agregar aquí los campos requeridos para crear
#   # Ejemplo:
#   # name: String!
#   # description: String
# }
EOF

echo "✅ Input creado: $INPUT_FILE"
