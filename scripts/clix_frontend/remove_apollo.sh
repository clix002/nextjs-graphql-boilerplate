#!/bin/bash

MODELO="$1"

# Convertir modelo a minúsculas para nombres de archivos
modelo_lower=$(echo "$MODELO" | tr '[:upper:]' '[:lower:]')

# Verificar si existe el directorio
if [ -d "src/client/apollo/typedefs/$modelo_lower" ]; then
  echo "🗑️  Eliminando Apollo typedefs para: $MODELO"
  rm -rf "src/client/apollo/typedefs/$modelo_lower"
  echo "✅ Apollo typedefs eliminados para: $MODELO"
else
  echo "❌ No se encontró directorio: src/client/apollo/typedefs/$modelo_lower"
fi
