#!/bin/bash

# Cargar variables del entorno
load_env_and_check_schema_path() {
  if [ ! -f .env ]; then
    echo "Archivo .env no encontrado en el directorio actual."
    exit 1
  fi

  export $(grep -v '^#' .env | xargs)

  # Usar la ruta de nuestro proyecto
  if [ -z "$PRISMA_SCHEMA_PATH" ]; then
    # Default para nuestro proyecto
    export PRISMA_SCHEMA_PATH="src/core/database/prisma/schema"
  fi
}

# Obtiene el nombre del primer modelo definido en el archivo Prisma
get_model_name() {
  grep '^model ' "$1" | head -n 1 | awk '{print $2}'
}

# Convierte a camelCase
to_camel_case() {
  echo "$1" | awk '{print tolower(substr($0,1,1)) substr($0,2)}'
}

# Extrae las relaciones de un modelo Prisma
extract_relations() {
  local prisma_file="$1"
  local model_name="$2"
  
  # Buscar líneas de relación en el modelo
  grep -A 100 "model $model_name" "$prisma_file" | grep -B 100 "^}" | grep -E "@relation|->" | while read line; do
    if [[ $line == *"@relation"* ]]; then
      # Extraer el nombre del campo y el tipo relacionado
      echo "$line" | sed -E 's/^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*).*/\1:\2/'
    fi
  done
}

# Genera resolvers de relaciones basados en el modelo
generate_relation_resolvers() {
  local prisma_file="$1"
  local model_name="$2"
  local model_camelcase="$3"
  
  echo "  // Relaciones automáticas generadas desde Prisma:"
  
  # Extraer el bloque del modelo
  local model_block=$(sed -n "/^model $model_name/,/^}/p" "$prisma_file")
  
  # Buscar líneas con relaciones (que contienen @relation)
  echo "$model_block" | grep "@relation" | while read line; do
    # Extraer el nombre del campo (primera palabra)
    local field_name=$(echo "$line" | awk '{print $1}')
    
    # Extraer el tipo relacionado (segunda palabra, limpiar [] si existe)
    local related_model=$(echo "$line" | awk '{print $2}' | sed 's/\[\]//')
    
    # Verificar si es una relación inversa (sin fields:)
    if [[ $line == *"fields:"* ]]; then
      # Relación directa - extraer la foreign key
      local foreign_key=$(echo "$line" | sed -E 's/.*fields:[[:space:]]*\[[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*).*/\1/')
      
      if [[ -n "$field_name" && -n "$related_model" && -n "$foreign_key" ]]; then
        local related_camelcase=$(to_camel_case "$related_model")
        echo "  $field_name: ({ $foreign_key }, _, context) =>"
        echo "    $foreign_key ? context.dataLoaders.${related_camelcase}DataLoader.load($foreign_key) : null,"
      fi
    else
      # Relación inversa - usar el ID del modelo actual
      if [[ -n "$field_name" && -n "$related_model" ]]; then
        local related_camelcase=$(to_camel_case "$related_model")
        echo "  $field_name: ({ id }, _, context) =>"
        echo "    context.dataLoaders.${related_camelcase}sByAuthorDataLoader.load(id),"
      fi
    fi
  done
}

to_snake_case() {
  echo "$1" | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' | tr 'A-Z' 'a-z'
}

# Calcula el path relativo a /generated/backend según profundidad
calculate_import_path() {
  local dirpath="$1"
  if [[ "$dirpath" == "." ]]; then
    echo "../../../"
  else
    local depth=$(echo "$dirpath" | awk -F/ '{print NF}')
    local ups=""
    for ((i = 0; i < depth + 3; i++)); do
      ups="../$ups"
    done
    echo "$ups"
  fi
}

resolve_prisma_info() {
  RAW_PATH="$1"

  if [ -z "$RAW_PATH" ]; then
    echo "Debe indicar una ruta válida al archivo Prisma"
    exit 1
  fi

  # Caso 1: Solo nombre del modelo (ej: Comment, User)
  if [[ "$RAW_PATH" =~ ^[A-Z][a-zA-Z]*$ ]]; then
    MODEL_NAME="$RAW_PATH"
    MODEL_LOWERCASE=$(to_camel_case "$MODEL_NAME")
    # Buscar archivo en la estructura actual (kebab-case)
    MODEL_KEBAB=$(echo "$MODEL_NAME" | sed 's/\([A-Z]\)/-\1/g' | sed 's/^-//' | tr '[:upper:]' '[:lower:]')
    
    # Buscar el archivo .prisma en la carpeta del modelo
    # Primero intentar con el nombre del modelo en minúscula
    MODEL_FILENAME=$(echo "$MODEL_NAME" | tr '[:upper:]' '[:lower:]')
    SEARCH_PATH="$MODEL_KEBAB/$MODEL_FILENAME.prisma"
    
    if [ -f "$PRISMA_SCHEMA_PATH/$SEARCH_PATH" ]; then
      PRISMA_PATH="$PRISMA_SCHEMA_PATH/$SEARCH_PATH"
    else
      # Si no existe, buscar cualquier archivo .prisma en la carpeta
      PRISMA_FILES=$(find "$PRISMA_SCHEMA_PATH/$MODEL_KEBAB" -name "*.prisma" 2>/dev/null | head -1)
      if [ -n "$PRISMA_FILES" ]; then
        # Extraer solo el nombre del archivo sin la ruta completa
        PRISMA_FILENAME=$(basename "$PRISMA_FILES")
        SEARCH_PATH="$MODEL_KEBAB/$PRISMA_FILENAME"
        PRISMA_PATH="$PRISMA_SCHEMA_PATH/$SEARCH_PATH"
      else
        echo "No se encontró modelo $MODEL_NAME en: $PRISMA_SCHEMA_PATH/$MODEL_KEBAB/"
        exit 1
      fi
    fi
  else
    # Caso 2: Ruta completa o relativa
    # Si no contiene .prisma, asumir que falta la extensión
    case "$RAW_PATH" in
      *.prisma) RESOLVED_INPUT="$RAW_PATH" ;;
      *) RESOLVED_INPUT="${RAW_PATH}.prisma" ;;
    esac

    # Intentar diferentes combinaciones de rutas
    if [ -f "$RESOLVED_INPUT" ]; then
      PRISMA_PATH="$RESOLVED_INPUT"
    elif [ -f "$PRISMA_SCHEMA_PATH/$RESOLVED_INPUT" ]; then
      PRISMA_PATH="$PRISMA_SCHEMA_PATH/$RESOLVED_INPUT"
    elif [ -f "$RAW_PATH" ]; then
      PRISMA_PATH="$RAW_PATH"
    else
      echo "Archivo Prisma no encontrado: $RAW_PATH"
      echo "Intentó buscar en:"
      echo "  - $RESOLVED_INPUT"
      echo "  - $PRISMA_SCHEMA_PATH/$RESOLVED_INPUT"
      echo "  - $RAW_PATH"
      exit 1
    fi
  fi

  # Calcular ruta relativa al esquema base (PRISMA_SCHEMA_PATH) usando Node.js (portátil)
  RELATIVE_PATH=$(node -e "console.log(require('path').relative('$PRISMA_SCHEMA_PATH', '$PRISMA_PATH'))")

  # Derivar nombre de modelo
  MODEL_NAME=$(get_model_name "$PRISMA_PATH")
  if [ -z "$MODEL_NAME" ]; then
    echo "No se encontró modelo en el archivo Prisma."
    exit 1
  fi

  # Derivar otros componentes útiles
  FILENAME=$(basename "$RELATIVE_PATH" .prisma)
  DIRPATH=$(dirname "$RELATIVE_PATH")
  DIRPATH="${DIRPATH#/}"  # Elimina slash inicial si lo hubiera
  MODEL_CAMELCASE=$(to_camel_case "$MODEL_NAME")

  # Exportar para scripts
  export RELATIVE_PATH
  export PRISMA_PATH
  export MODEL_NAME
  export FILENAME
  export DIRPATH
  export MODEL_CAMELCASE
}

# Construir ruta relativa
build_path_from_args() {
  local path=""

  for part in "$@"; do
    if [[ "$part" != "." && -n "$part" ]]; then
      if [[ -n "$path" ]]; then
        path="$path/$part"
      else
        path="$part"
      fi
    fi
  done

  echo "$path"
}
