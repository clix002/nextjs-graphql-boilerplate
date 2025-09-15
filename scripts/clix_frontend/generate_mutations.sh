#!/bin/bash

MODELO="$1"

# Convertir modelo a minúsculas para nombres de archivos
modelo_lower=$(echo "$MODELO" | tr '[:upper:]' '[:lower:]')

# Crear directorio
mkdir -p "src/client/apollo/typedefs/$modelo_lower"

# Verificar si el archivo ya existe
if [ -f "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.mutations.graphql" ]; then
  echo "❌ El archivo ya existe: $modelo_lower.mutations.graphql"
  echo "💡 Opciones:"
  echo "  1. Eliminar existente: pnpm clix:f remove:gm $MODELO"
  echo "  2. Ver contenido actual:"
  echo "     cat src/client/apollo/typedefs/$modelo_lower/$modelo_lower.mutations.graphql"
  exit 1
fi

# Generar mutations.graphql
cat > "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.mutations.graphql" << EOF
mutation Create${MODELO}(\$input: Create${MODELO}Input!) {
  create${MODELO}(input: \$input) {
    ...${MODELO}Fragment
  }
}

mutation Update${MODELO}(\$id: ID!, \$input: Update${MODELO}Input!) {
  update${MODELO}(id: \$id, input: \$input) {
    ...${MODELO}Fragment
  }
}

mutation Delete${MODELO}(\$id: ID!) {
  delete${MODELO}(id: \$id)
}
EOF

echo "✅ Mutations generadas para: $MODELO"
echo "📁 Ubicación: src/client/apollo/typedefs/$modelo_lower/$modelo_lower.mutations.graphql"
