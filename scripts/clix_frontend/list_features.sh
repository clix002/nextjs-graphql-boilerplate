#!/bin/bash

echo "📋 Features frontend existentes:"
echo ""

if [ -d "src/client/apollo/typedefs" ]; then
  for dir in src/client/apollo/typedefs/*/; do
    if [ -d "$dir" ]; then
      feature_name=$(basename "$dir")
      echo "📁 $feature_name"
      
      # Mostrar archivos dentro del directorio
      for file in "$dir"*.graphql; do
        if [ -f "$file" ]; then
          filename=$(basename "$file")
          echo "   📄 $filename"
        fi
      done
      echo ""
    fi
  done
else
  echo "❌ No se encontró directorio: src/client/apollo/typedefs"
fi
