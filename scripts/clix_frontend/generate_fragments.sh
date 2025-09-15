#!/bin/bash

MODELO="$1"

# Convertir modelo a minúsculas para nombres de archivos
modelo_lower=$(echo "$MODELO" | tr '[:upper:]' '[:lower:]')

# Crear directorio
mkdir -p "src/client/apollo/typedefs/$modelo_lower"

# Verificar si el archivo ya existe
if [ -f "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.fragments.graphql" ]; then
  echo "❌ El archivo ya existe: $modelo_lower.fragments.graphql"
  echo "💡 Opciones:"
  echo "  1. Eliminar existente: pnpm clix:f remove:gf $MODELO"
  echo "  2. Ver contenido actual:"
  echo "     cat src/client/apollo/typedefs/$modelo_lower/$modelo_lower.fragments.graphql"
  exit 1
fi

# Generar fragments.graphql
cat > "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.fragments.graphql" << EOF
fragment ${MODELO}Fragment on ${MODELO} {
  id
  # TODO: Agregar campos específicos del modelo
}
EOF

echo "✅ Fragments generados para: $MODELO"
echo "📁 Ubicación: src/client/apollo/typedefs/$modelo_lower/$modelo_lower.fragments.graphql"
