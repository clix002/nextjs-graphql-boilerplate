#!/bin/bash

MODELO="$1"
MODE="${2:-normal}"

# Convertir modelo a minúsculas para nombres de archivos
modelo_lower=$(echo "$MODELO" | tr '[:upper:]' '[:lower:]')

# Crear directorio
mkdir -p "src/client/apollo/typedefs/$modelo_lower"

# Verificar si algún archivo ya existe
existing_files=()
if [ -f "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.queries.graphql" ]; then
  existing_files+=("queries")
fi
if [ -f "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.mutations.graphql" ]; then
  existing_files+=("mutations")
fi
if [ -f "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.fragments.graphql" ]; then
  existing_files+=("fragments")
fi

if [ ${#existing_files[@]} -gt 0 ]; then
  echo "❌ Los siguientes archivos ya existen:"
  for file in "${existing_files[@]}"; do
    echo "   - src/client/apollo/typedefs/$modelo_lower/$modelo_lower.$file.graphql"
  done
  echo ""
  echo "💡 Opciones:"
  echo "  1. Eliminar existentes: pnpm clix:f remove:gt $MODELO"
  echo "  2. Crear individualmente:"
  for file in "${existing_files[@]}"; do
    echo "     pnpm clix:f remove:g${file:0:1} $MODELO && pnpm clix:f create:g${file:0:1} $MODELO"
  done
  echo ""
  echo "📁 Ubicación: src/client/apollo/typedefs/$modelo_lower/"
  exit 1
fi

# Generar queries.graphql (una básica comentada)
cat > "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.queries.graphql" << EOF
# TODO: Agregar queries cuando estén implementadas en el backend
# query Get${MODELO}ById(\$id: ID!) {
#   get${MODELO}ById(id: \$id) {
#     ...${MODELO}Fragment
#   }
# }
EOF

# Generar mutations.graphql (una básica comentada)
cat > "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.mutations.graphql" << EOF
# TODO: Agregar mutations cuando estén implementadas en el backend
# mutation Create${MODELO}(\$input: Create${MODELO}Input!) {
#   create${MODELO}(input: \$input) {
#     id
#   }
# }
EOF

# Generar fragments.graphql (básico)
cat > "src/client/apollo/typedefs/$modelo_lower/$modelo_lower.fragments.graphql" << EOF
fragment ${MODELO}Fragment on ${MODELO} {
  id
}
EOF

echo "✅ Archivos Apollo generados para: $MODELO"
echo "📁 Ubicación: src/client/apollo/typedefs/$modelo_lower/"
echo "📄 Archivos creados:"
echo "   - $modelo_lower.queries.graphql"
echo "   - $modelo_lower.mutations.graphql"
echo "   - $modelo_lower.fragments.graphql"
