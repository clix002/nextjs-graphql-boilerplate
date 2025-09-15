#!/bin/bash

# Script para generar solo el archivo .queries.graphql
# Uso: bash generate_queries_graphql.sh [nombre]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

NOMBRE="$1"

if [ -z "$NOMBRE" ]; then
  echo "❌ Falta el nombre del resolver"
  echo "Uso: bash generate_queries_graphql.sh <nombre>"
  echo "Ejemplo: bash generate_queries_graphql.sh Auth"
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
QUERIES_FILE="$MODEL_DIR/${nombre_kebab}.queries.graphql"

# Crear directorio si no existe
mkdir -p "$MODEL_DIR"

# Verificar si ya existe el archivo
if [ -f "$QUERIES_FILE" ]; then
  echo "⚠️  El archivo $QUERIES_FILE ya existe. No se sobrescribirá."
  exit 0
fi

# Generar solo el archivo queries.graphql (definiciones de tipos)
cat > "$QUERIES_FILE" << EOF
# Definiciones de tipos para queries de $NOMBRE
# TODO: Agregar definiciones de tipos según necesites

# Ejemplo de definición de tipo para query:
# type Query {
#   get${NOMBRE}ById(id: ID!): $NOMBRE
#   getAll${NOMBRE}s: [$NOMBRE!]!
# }
EOF

echo "✅ Queries GraphQL creado:"
echo "  - $QUERIES_FILE"
echo "📝 Recuerda revisar y ajustar las queries según tus necesidades"
