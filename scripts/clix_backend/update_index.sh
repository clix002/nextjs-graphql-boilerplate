#!/bin/bash

# Script para actualizar el index.ts de resolvers automáticamente
# Uso: bash update_index.sh [modelo] [accion]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

MODELO="$1"
ACCION="$2"  # add, remove, regenerate

RESOLVERS_DIR="$PROJECT_ROOT/src/core/api/graphql/resolvers"
INDEX_FILE="$RESOLVERS_DIR/index.ts"

# Función para obtener el nombre del modelo en camelCase
get_camel_case() {
  local model="$1"
  echo "${model:0:1}$(echo "${model:1}" | sed 's/\([A-Z]\)/\L\1/g')"
}

# Función para obtener el nombre del modelo en PascalCase
get_pascal_case() {
  local model="$1"
  echo "${model^}"
}

# Función para obtener el nombre del modelo en lowercase
get_lower_case() {
  local model="$1"
  echo "${model,,}"
}

# Función para detectar si es un modelo de Prisma
is_prisma_model() {
  local model_name="$1"
  local prisma_schema="$PROJECT_ROOT/src/core/database/prisma/schema"
  
  # Buscar en archivos .prisma el modelo exacto
  if find "$prisma_schema" -name "*.prisma" -exec grep -l "model $model_name" {} \; | grep -q .; then
    return 0  # Es un modelo de Prisma
  else
    return 1  # No es un modelo de Prisma (standalone)
  fi
}

# Función para regenerar el index completo
regenerate_index() {
  echo "🔄 Regenerando index.ts de resolvers..."
  
  # Crear el contenido del index
  cat > "$INDEX_FILE" << 'EOF'
// ⚡ AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
// Este archivo es generado automáticamente por el CLI clix:b
// Para regenerar, ejecuta: pnpm clix:b regenerate-index

EOF

  # Buscar todos los resolvers en resolvers/
  if [ -d "$RESOLVERS_DIR" ]; then
    for resolver_dir in "$RESOLVERS_DIR"/*; do
      if [ -d "$resolver_dir" ] && [ "$(basename "$resolver_dir")" != "index.ts" ] && [ "$(basename "$resolver_dir")" != "standalone" ]; then
        resolver_name="$(basename "$resolver_dir")"
        
        # Convertir kebab-case a PascalCase (sys-user -> SysUser)
        resolver_pascal=$(echo "$resolver_name" | sed 's/-\([a-z]\)/\U\1/g' | sed 's/^\([a-z]\)/\U\1/')
        
        # Detectar si es modelo o standalone
        if is_prisma_model "$resolver_pascal"; then
          echo "// $resolver_pascal resolvers (modelo)" >> "$INDEX_FILE"
        else
          echo "// $resolver_pascal resolvers (standalone)" >> "$INDEX_FILE"
        fi
        
        # Agregar queries si existe
        if [ -f "$resolver_dir/${resolver_name}.queries.resolvers.ts" ]; then
          echo "export { ${resolver_pascal}Queries } from './$resolver_name/${resolver_name}.queries.resolvers';" >> "$INDEX_FILE"
        fi
        
        # Agregar mutations si existe
        if [ -f "$resolver_dir/${resolver_name}.mutations.resolvers.ts" ]; then
          echo "export { ${resolver_pascal}Mutations } from './$resolver_name/${resolver_name}.mutations.resolvers';" >> "$INDEX_FILE"
        fi
        
        # Agregar relations si existe
        if [ -f "$resolver_dir/${resolver_name}.relations.resolvers.ts" ]; then
          echo "export { ${resolver_pascal}Relations } from './$resolver_name/${resolver_name}.relations.resolvers';" >> "$INDEX_FILE"
        fi
        
        echo "" >> "$INDEX_FILE"
      fi
    done
  fi
  
  echo "✅ Index regenerado con éxito"
}

# Función para agregar un modelo al index
add_model() {
  local model="$1"
  local model_lower="$(get_lower_case "$model")"
  local model_pascal="$(get_pascal_case "$model")"
  
  echo "➕ Agregando $model al index..."
  
  # Verificar si el modelo ya existe en el index
  if grep -q "// $model_pascal resolvers" "$INDEX_FILE"; then
    echo "⚠️  El modelo $model ya existe en el index"
    return 0
  fi
  
  # Determinar el nombre correcto para relations
  if [ "$model_lower" = "user" ]; then
    RELATION_NAME="SysUser"
  else
    RELATION_NAME="$model_pascal"
  fi
  
  # Agregar al final del archivo (antes del TODO)
  sed -i "/^\/\/ TODO: El CLI agregará más modelos aquí automáticamente/i\\
// $model_pascal resolvers\\
export { Query as ${model_pascal}Queries } from './$model_lower/$model_lower.queries.resolvers';\\
export { Mutation as ${model_pascal}Mutations } from './$model_lower/$model_lower.mutations.resolvers';\\
export { $RELATION_NAME as ${model_pascal}Relations } from './$model_lower/$model_lower.relations.resolvers';\\
" "$INDEX_FILE"
  
  echo "✅ Modelo $model agregado al index"
}

# Función para remover un modelo del index
remove_model() {
  local model="$1"
  local model_pascal="$(get_pascal_case "$model")"
  
  echo "➖ Removiendo $model del index..."
  
  # Remover las líneas del modelo
  sed -i "/\/\/ $model_pascal resolvers/,+3d" "$INDEX_FILE"
  
  echo "✅ Modelo $model removido del index"
}

# Función para actualizar el schema.ts
update_schema() {
  echo "🔄 Actualizando schema.ts..."
  
  # Usar el script dedicado para actualizar schema.ts
  bash "$SCRIPT_DIR/update_schema.sh"
}

# Función principal
main() {
  case "$ACCION" in
    regenerate)
      regenerate_index
      update_schema
      ;;
    add)
      if [ -z "$MODELO" ]; then
        echo "❌ Falta el nombre del modelo"
        exit 1
      fi
      add_model "$MODELO"
      update_schema
      ;;
    remove)
      if [ -z "$MODELO" ]; then
        echo "❌ Falta el nombre del modelo"
        exit 1
      fi
      remove_model "$MODELO"
      update_schema
      ;;
    *)
      echo "❌ Acción no reconocida: $ACCION"
      echo "Uso: bash update_index.sh [modelo] [add|remove|regenerate]"
      exit 1
      ;;
  esac
}

# Ejecutar función principal
main
