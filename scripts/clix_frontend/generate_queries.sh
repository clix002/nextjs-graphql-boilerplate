#!/bin/bash

MODELO="$1"

# Convertir modelo a minúsculas para nombres de archivos
modelo_lower=$(echo "$MODELO" | tr '[:upper:]' '[:lower:]')

# Crear directorio
mkdir -p "src/client/apollo/typedefs/$modelo_lower"

# Verificar si el archivo ya existe
if [ -f "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.queries.graphql" ]; then
  echo "❌ El archivo ya existe: $modelo_lower.queries.graphql"
  echo "💡 Opciones:"
  echo "  1. Eliminar existente: pnpm clix:f remove:gq $MODELO"
  echo "  2. Ver contenido actual:"
  echo "     cat src/client/apollo/typedefs/$modelo_lower/$modelo_lower.queries.graphql"
  exit 1
fi

# Generar queries.graphql
cat > "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.queries.graphql" << EOF
query GetAll${MODELO}s {
  getAll${MODELO}s {
    ...${MODELO}Fragment
  }
}

query Get${MODELO}ById(\$id: ID!) {
  get${MODELO}ById(id: \$id) {
    ...${MODELO}Fragment
  }
}
EOF

echo "✅ Queries generadas para: $MODELO"
echo "📁 Ubicación: src/client/apollo/typedefs/$modelo_lower/$modelo_lower.queries.graphql"
