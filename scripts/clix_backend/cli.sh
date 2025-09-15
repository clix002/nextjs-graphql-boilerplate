#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

show_help() {
  echo "🚀 Clix CLI Backend – Herramienta de scaffolding para GraphQL backend"
  echo ""
  echo "Uso:"
  echo "  pnpm clix:b <comando> <modelo>"
  echo ""
  echo "Comandos disponibles:"
  echo "  create        → Crea todos los artefactos"
  echo "  create:gt     → Crea solo typedefs (.types.graphql)"
  echo "  create:gm     → Crea solo mutations (.mutations.graphql + .mutations.resolvers.ts)"
  echo "  create:gq     → Crea solo queries (.queries.graphql + .queries.resolvers.ts)"
  echo "  create:gi     → Crea solo inputs (.inputs.graphql)"
  echo "  create:gd     → Crea solo dataloaders (.dataloaders.ts)"
  echo "  create:gr     → Crea solo relations (.relations.resolvers.ts)"
  echo "  create:uc     → Crea solo usecase (.usecase.ts)"
  echo "  create:schema → Crea solo schema de Zod (.schemas.ts)"
  echo "  paginate      → Registra modelo en sistema de paginación"
  echo ""
  echo "  remove        → Elimina todos los artefactos"
  echo "  remove:gt     → Elimina solo typedefs"
  echo "  remove:gm     → Elimina solo mutations"
  echo "  remove:gq     → Elimina solo queries"
  echo "  remove:gi     → Elimina solo inputs"
  echo "  remove:gd     → Elimina solo dataloaders"
  echo "  remove:gr     → Elimina solo relations"
  echo "  remove:uc     → Elimina solo usecase"
  echo ""
  echo "  regenerate-index → Regenera el index.ts de resolvers"
  echo ""
  echo "Ejemplos:"
  echo "  pnpm clix:b create Comment"
  echo "  pnpm clix:b create:uc Comment"
  echo "  pnpm clix:b paginate Comment"
  echo "  pnpm clix:b remove Comment"
  echo ""
  echo "Notas:"
  echo "  - Los archivos solo se generan si no existen"
  echo "  - Usa el nombre del modelo (ej: Comment, User) o ruta completa"
  echo ""
  exit 0
}

# Mostrar ayuda si no hay argumentos o si se solicita explícitamente
if [ "$1" == "--help" ] || [ "$1" == "-h" ] || ([ $# -lt 2 ] && [ "$1" != "regenerate-index" ]); then
  show_help
fi

COMANDO="$1"
MODELO="$2"

if [ -z "$COMANDO" ]; then
  echo "❌ Falta el comando"
  show_help
fi

if [ -z "$MODELO" ] && [ "$COMANDO" != "regenerate-index" ]; then
  echo "❌ Falta el modelo"
  show_help
fi

# Ejecutar según comando
case "$COMANDO" in
  # Comandos CREATE
  create)
    echo "🚀 Creando todos los artefactos para: $MODELO"
    
    # Verificar si es un modelo de Prisma
    if bash "$SCRIPT_DIR/check_model_exists.sh" "$MODELO"; then
      echo "🔍 Detectado: $MODELO es un modelo de Prisma - Generando automáticamente"
      bash "$SCRIPT_DIR/generate_typedefs.sh" "$MODELO"
      bash "$SCRIPT_DIR/generate_input.sh" "$MODELO"
      bash "$SCRIPT_DIR/generate_queries_graphql.sh" "$MODELO"
      bash "$SCRIPT_DIR/generate_mutations_graphql.sh" "$MODELO"
      bash "$SCRIPT_DIR/generate_query.sh" "$MODELO"
      bash "$SCRIPT_DIR/generate_mutation.sh" "$MODELO"
      bash "$SCRIPT_DIR/generate_dataloader.sh" "$MODELO"
      bash "$SCRIPT_DIR/generate_relation.sh" "$MODELO"
      bash "$SCRIPT_DIR/generate_usecase.sh" "$MODELO"
      bash "$SCRIPT_DIR/generate_schema.sh" "$MODELO"
      bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "add"
      bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    else
      echo "❌ No se encontró modelo $MODELO en Prisma"
      echo "💡 ¿Quieres crear un resolver standalone?"
      read -p "¿Crear como resolver standalone? (y/n): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔍 Creando resolver standalone: $MODELO"
        bash "$SCRIPT_DIR/generate_typedefs.sh" "$MODELO"
        bash "$SCRIPT_DIR/generate_query.sh" "$MODELO"
        bash "$SCRIPT_DIR/generate_mutation.sh" "$MODELO"
        bash "$SCRIPT_DIR/generate_input.sh" "$MODELO"
        bash "$SCRIPT_DIR/generate_schema.sh" "$MODELO"
        bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "add"
        bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
      else
        echo "❌ Operación cancelada"
        exit 0
      fi
    fi
    
    echo "✅ Todos los artefactos creados con éxito para: $MODELO"
    ;;
  create:gt)
    bash "$SCRIPT_DIR/generate_typedefs.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "add"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  create:gm)
    bash "$SCRIPT_DIR/generate_mutations_graphql.sh" "$MODELO"
    bash "$SCRIPT_DIR/generate_mutation.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "add"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  create:gq)
    bash "$SCRIPT_DIR/generate_queries_graphql.sh" "$MODELO"
    bash "$SCRIPT_DIR/generate_query.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "add"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  create:gi)
    bash "$SCRIPT_DIR/generate_input.sh" "$MODELO"
    ;;
  create:gd)
    bash "$SCRIPT_DIR/generate_dataloader.sh" "$MODELO"
    ;;
  create:gr)
    bash "$SCRIPT_DIR/generate_relation.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "add"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  create:uc)
    bash "$SCRIPT_DIR/generate_usecase.sh" "$MODELO"
    ;;
  create:schema)
    bash "$SCRIPT_DIR/generate_schema.sh" "$MODELO"
    ;;
  paginate)
    bash "$SCRIPT_DIR/paginate_model.sh" "$MODELO"
    ;;
  # Comandos REMOVE
    remove)
      echo "🗑️  Eliminando todos los artefactos para: $MODELO"
      bash "$SCRIPT_DIR/remove_all.sh" "$MODELO"
      bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "remove"
      bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
      echo "✅ Todos los artefactos eliminados para: $MODELO"
    ;;
  remove:gt)
    bash "$SCRIPT_DIR/remove_typedefs.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "remove"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  remove:gm)
    bash "$SCRIPT_DIR/remove_mutations.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "remove"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  remove:gq)
    bash "$SCRIPT_DIR/remove_queries.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "remove"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  remove:gi)
    bash "$SCRIPT_DIR/remove_inputs.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "remove"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  remove:gd)
    bash "$SCRIPT_DIR/remove_dataloaders.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "remove"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  remove:gr)
    bash "$SCRIPT_DIR/remove_relations.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "remove"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  remove:uc)
    bash "$SCRIPT_DIR/remove_usecase.sh" "$MODELO"
    bash "$SCRIPT_DIR/update_index.sh" "$MODELO" "remove"
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  regenerate-index)
    bash "$SCRIPT_DIR/update_index.sh" "" "regenerate"
    ;;
  *)
    echo "❌ Comando no reconocido: $COMANDO"
    show_help
    ;;
esac

# Mensaje final
echo ""
echo "────────────────────────────────────────────────────────────"
echo "✅ Acción completada por Clix CLI Backend"
echo ""
echo "🔎 Revisa y valida manualmente el archivo generado."
echo "🛠️  Si notas algo incorrecto o quieres proponer mejoras, no dudes en colaborar."
echo "────────────────────────────────────────────────────────────"
