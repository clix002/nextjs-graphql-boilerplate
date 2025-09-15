#!/bin/bash

echo "📋 Modelos Prisma disponibles:"
echo ""

# Buscar modelos en archivos .prisma
if [ -d "src/core/database/prisma/schema" ]; then
  for file in src/core/database/prisma/schema/**/*.prisma; do
    if [ -f "$file" ]; then
      # Extraer nombres de modelos
      models=$(grep -E "^model\s+\w+" "$file" | sed 's/model\s\+//' | sed 's/\s*{.*//')
      if [ -n "$models" ]; then
        echo "$models" | while read -r model; do
          if [ -n "$model" ]; then
            echo "📦 $model"
          fi
        done
      fi
    fi
  done
else
  echo "❌ No se encontró directorio: src/core/database/prisma/schema"
fi
