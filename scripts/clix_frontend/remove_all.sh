#!/bin/bash

MODELO="$1"

# Convertir modelo a minúsculas para nombres de archivos
modelo_lower=$(echo "$MODELO" | tr '[:upper:]' '[:lower:]')

echo "🗑️  Eliminando todos los artefactos frontend para: $MODELO"

# Eliminar Apollo typedefs
if [ -d "src/client/apollo/typedefs/$modelo_lower" ]; then
  rm -rf "src/client/apollo/typedefs/$modelo_lower"
  echo "✅ Apollo typedefs eliminados"
fi

echo "✅ Todos los artefactos frontend eliminados para: $MODELO"
