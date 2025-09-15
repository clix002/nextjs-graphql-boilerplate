#!/bin/bash

MODELO="$1"

# Verificar si ya existe feature para este modelo
if [ -d "src/client/apollo/typedefs/$MODELO" ]; then
  echo "❌ Ya existe feature para modelo: $MODELO"
  echo " Archivos existentes:"
  ls -la "src/client/apollo/typedefs/$MODELO"
  echo ""
  echo " Opciones:"
  echo "  1. Eliminar existente: pnpm clix:f remove $MODELO"
  echo "  2. Sobrescribir: pnpm clix:f create $MODELO --force"
  exit 1
fi

# Verificar si existe en Prisma
if grep -q "model $MODELO" src/core/database/prisma/schema/**/*.prisma; then
  echo "✅ Modelo $MODELO encontrado en Prisma"
  exit 0
else
  echo "❌ Modelo $MODELO no encontrado en Prisma"
  exit 1
fi
