#!/bin/bash

# Script para registrar un modelo de paginación
# Uso: ./paginate_model.sh <model_name>
# Ejemplo: ./paginate_model.sh article

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Uso:${NC} $0 <model_name>"
    echo -e "${BLUE}Ejemplo:${NC} $0 article"
    echo -e "${BLUE}Descripción:${NC} Registra un modelo en el sistema de paginación"
    echo ""
    echo -e "${YELLOW}Opciones:${NC}"
    echo "  -h, --help     Mostrar esta ayuda"
    echo ""
    echo -e "${YELLOW}Modelos disponibles:${NC}"
    echo "  - sysUser"
    echo "  - comment"
    echo "  - article (ejemplo)"
    echo "  - category (ejemplo)"
}

# Verificar argumentos
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

MODEL_NAME="$1"
MODEL_NAME_LOWER=$(echo "$MODEL_NAME" | tr '[:upper:]' '[:lower:]')
PAGINATION_MODELS_FILE="src/core/database/connections/pagination-models.ts"

# Verificar que el archivo existe
if [ ! -f "$PAGINATION_MODELS_FILE" ]; then
    echo -e "${RED}Error:${NC} No se encontró el archivo $PAGINATION_MODELS_FILE"
    exit 1
fi

# Función para verificar si el modelo ya existe
model_exists() {
    grep -q "$MODEL_NAME_LOWER:" "$PAGINATION_MODELS_FILE"
}

# Función para verificar si el modelo existe en Prisma
prisma_model_exists() {
    # Buscar en los archivos .prisma (case insensitive)
    find src/core/database/prisma/schema -name "*.prisma" -exec grep -li "model $MODEL_NAME" {} \; | grep -q .
}

echo -e "${BLUE}🔍 Verificando modelo:${NC} $MODEL_NAME"

# Verificar si el modelo existe en Prisma
if ! prisma_model_exists; then
    echo -e "${RED}❌ Error:${NC} El modelo '$MODEL_NAME' no existe en el esquema de Prisma"
    echo -e "${YELLOW}💡 Tip:${NC} Asegúrate de que el modelo esté definido en src/core/database/prisma/schema/"
    exit 1
fi

echo -e "${GREEN}✅ Modelo encontrado en Prisma${NC}"

# Verificar si ya está registrado
if model_exists; then
    echo -e "${YELLOW}⚠️  El modelo '$MODEL_NAME' ya está registrado en paginación${NC}"
    exit 0
fi

echo -e "${BLUE}📝 Registrando modelo en paginación...${NC}"

# Crear backup del archivo original
cp "$PAGINATION_MODELS_FILE" "${PAGINATION_MODELS_FILE}.backup"
echo -e "${YELLOW}💾 Backup creado:${NC} ${PAGINATION_MODELS_FILE}.backup"

# Agregar el modelo a la configuración de paginación
# Buscar la línea que contiene el último modelo y agregar el nuevo después
sed -i "/^export const paginationModels = {/,/} as const;/ {
    /} as const;/ i\\
  $MODEL_NAME_LOWER: { paginate },
}" "$PAGINATION_MODELS_FILE"

echo -e "${GREEN}✅ Modelo '$MODEL_NAME' registrado exitosamente en paginación${NC}"

# Verificar que el registro fue exitoso
if model_exists; then
    echo -e "${GREEN}🎉 Verificación exitosa:${NC} El modelo está correctamente registrado"
    echo ""
    echo -e "${BLUE}📋 Próximos pasos:${NC}"
    echo "1. Regenera los tipos de GraphQL: pnpm codegen"
    echo "2. Reinicia el servidor de desarrollo"
    echo "3. Usa la paginación en tu use case:"
    echo "   context.prisma.$MODEL_NAME_LOWER.paginate({}).withPages(options)"
else
    echo -e "${RED}❌ Error:${NC} No se pudo verificar el registro del modelo"
    echo -e "${YELLOW}🔄 Restaurando backup...${NC}"
    mv "${PAGINATION_MODELS_FILE}.backup" "$PAGINATION_MODELS_FILE"
    exit 1
fi

echo -e "${GREEN}✨ ¡Listo! El modelo '$MODEL_NAME' ya tiene paginación disponible${NC}"
