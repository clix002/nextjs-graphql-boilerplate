#!/bin/bash

MODELO="$1"

# Convertir modelo a minúsculas para nombres de archivos
modelo_lower=$(echo "$MODELO" | tr '[:upper:]' '[:lower:]')

# Verificar si existe el archivo
if [ -f "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.queries.graphql" ]; then
  echo "🗑️  Eliminando queries para: $MODELO"
  rm "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.queries.graphql"
  echo "✅ Queries eliminadas para: $MODELO"
else
  echo "❌ No se encontró archivo: src/client/apollo/typedefs/$modelo_lower/$modelo_lower.queries.graphql"
fi
