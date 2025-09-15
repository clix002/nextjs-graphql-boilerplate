#!/bin/bash

# Script inteligente para generar usecases
# Detecta automáticamente si es un modelo de Prisma o standalone

MODELO="$1"
PROJECT_ROOT="$(pwd)"

# Función para detectar si es un modelo de Prisma
is_prisma_model() {
  local model_name="$1"
  local prisma_schema="$PROJECT_ROOT/src/core/database/prisma/schema"

  # Buscar en archivos .prisma
  if find "$prisma_schema" -name "*.prisma" -exec grep -l "model $model_name" {} \; 2>/dev/null | grep -q .; then
    return 0  # Es un modelo de Prisma
  else
    return 1  # No es un modelo de Prisma (standalone)
  fi
}

# Función para convertir a kebab-case
to_kebab_case() {
  echo "$1" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//'
}

if [ -z "$MODELO" ]; then
  echo "❌ Uso: $0 <MODELO>"
  exit 1
fi

MODEL_KEBABCASE=$(to_kebab_case "$MODELO")
MODEL_CAMELCASE=$(echo "$MODELO" | awk '{print tolower(substr($0,1,1)) substr($0,2)}')
BASE_DIR="src/core/usecase"
TARGET_DIR="$BASE_DIR/$MODEL_KEBABCASE"
TARGET_FILE="$TARGET_DIR/${MODEL_KEBABCASE}.usecase.ts"

# Directorios para shared schemas
SHARED_SCHEMAS_DIR="src/shared/domain/schemas/$MODEL_KEBABCASE"
SHARED_SCHEMAS_FILE="$SHARED_SCHEMAS_DIR/${MODEL_KEBABCASE}.schemas.ts"

# Crear carpetas destino
mkdir -p "$TARGET_DIR"
mkdir -p "$SHARED_SCHEMAS_DIR"

if [ -f "$TARGET_FILE" ]; then
  echo "⚠️  El archivo $TARGET_FILE ya existe. No se sobrescribirá."
  exit 0
fi

# Generar usecase básico
cat <<EOF > "$TARGET_FILE"
import type { IContext } from "@/config/types";
import type { 
  ${MODELO},
  QueryGet${MODELO}ByIdArgs,
  MutationCreate${MODELO}Args,
} from "@/core/api/graphql/generated/backend";
import { validateForBackend } from "@/core/domain/utils/validation";
import { Create${MODELO}Schema } from "@/shared/domain/schemas/$MODEL_KEBABCASE/$MODEL_KEBABCASE.schemas";
import { GraphQLError } from "graphql";

class ${MODELO}UseCase {
  // Obtener $MODELO por ID
  async get${MODELO}ById(args: QueryGet${MODELO}ByIdArgs, context: IContext) {
    const { id } = args;
    
    const ${MODEL_CAMELCASE} = await context.prisma.$MODEL_CAMELCASE.findUnique({
      where: { id },
    });
    
    return ${MODEL_CAMELCASE};
  }

  // Crear $MODELO
  async create${MODELO}(args: MutationCreate${MODELO}Args, context: IContext) {
    const { input } = args;
    
    // 1. Validar los datos de entrada con Zod
    const validatedInput = validateForBackend(Create${MODELO}Schema, input);
    
    // 2. Validar campos únicos (ejemplo con email)
    // TODO: Agregar validaciones de campos únicos según tu modelo
    // const existingUser = await context.prisma.$MODEL_CAMELCASE.findUnique({
    //   where: { email: validatedInput.email },
    //   select: { id: true }
    // });
    // 
    // if (existingUser) {
    //   throw new GraphQLError("El email ya está registrado", {
    //     extensions: { code: "EMAIL_ALREADY_EXISTS", field: "email" }
    //   });
    // }
    
    // 3. Crear el registro en la base de datos (usando spread operator)
    const new${MODELO} = await context.prisma.$MODEL_CAMELCASE.create({
      data: {
        ...validatedInput, // Pasa todos los campos automáticamente
      },
    });
    
    return new${MODELO};
  }

  // TODO: Agregar más métodos según necesites
  // Ejemplo:
  // async getAll${MODELO}s(context: IContext) {
  //   return await context.prisma.$MODEL_CAMELCASE.findMany();
  // },
}

const ${MODEL_CAMELCASE}UseCase = new ${MODELO}UseCase();
export default ${MODEL_CAMELCASE}UseCase;
EOF

# Generar schemas de Zod en shared
if [ -f "$SHARED_SCHEMAS_FILE" ]; then
  echo "⚠️  El archivo $SHARED_SCHEMAS_FILE ya existe. No se sobrescribirá."
else
  cat <<EOF > "$SHARED_SCHEMAS_FILE"
import { z } from "zod";

// Schema base para $MODELO
export const ${MODELO}Schema = z.object({
  id: z.string().optional(),
  // TODO: Agregar campos específicos del modelo $MODELO
  // Ejemplo:
  // name: z.string().min(1, "El nombre es requerido"),
  // email: z.string().email("Email inválido"),
});

// Schema para crear $MODELO
export const Create${MODELO}Schema = ${MODELO}Schema.omit({
  id: true,
});

// Schema para actualizar $MODELO
export const Update${MODELO}Schema = ${MODELO}Schema.partial().omit({
  id: true,
});

// Tipos TypeScript
export type ${MODELO}Type = z.infer<typeof ${MODELO}Schema>;
export type Create${MODELO}Input = z.infer<typeof Create${MODELO}Schema>;
export type Update${MODELO}Input = z.infer<typeof Update${MODELO}Schema>;
EOF
  echo "✅ Schema de Zod creado: $SHARED_SCHEMAS_FILE"
fi

echo "✅ Usecase creado: $TARGET_FILE"
echo "✅ Schema de Zod creado: $SHARED_SCHEMAS_FILE"
echo "📝 Recuerda:"
echo "   - Implementar la lógica del usecase según tu fuente de datos"
echo "   - Definir los campos específicos en el schema de Zod"
