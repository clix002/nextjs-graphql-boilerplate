#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

show_help() {
  echo "🚀 Clix CLI Frontend – Herramienta de scaffolding para frontend GraphQL"
  echo ""
  echo "Uso:"
  echo "  pnpm clix:f <comando> <modelo>"
  echo ""
  echo "Comandos disponibles:"
  echo "  create        → Crea todos los artefactos frontend"
  echo "  create:gq     → Crea solo queries (.queries.graphql)"
  echo "  create:gm     → Crea solo mutations (.mutations.graphql)"
  echo "  create:gf     → Crea solo fragments (.fragments.graphql)"
  echo "  create:gt     → Crea solo Apollo typedefs (todos los .graphql)"
  echo ""
  echo "  remove        → Elimina todos los artefactos"
  echo "  remove:gq     → Elimina solo queries"
  echo "  remove:gm     → Elimina solo mutations"
  echo "  remove:gf     → Elimina solo fragments"
  echo "  remove:gt     → Elimina solo Apollo typedefs (todos los .graphql)"
  echo ""
  echo "  list          → Lista features existentes"
  echo "  list:models   → Lista modelos Prisma disponibles"
  echo ""
  echo "Ejemplos:"
  echo "  pnpm clix:f create User"
  echo "  pnpm clix:f create:gq Comment"
  echo "  pnpm clix:f create:gm Comment"
  echo "  pnpm clix:f create:gf Comment"
  echo "  pnpm clix:f create:gt Comment"
  echo "  pnpm clix:f remove User"
  echo "  pnpm clix:f remove:gt Comment"
  echo "  pnpm clix:f list"
  echo ""
  echo "Notas:"
  echo "  - Los archivos solo se generan si no existen"
  echo "  - Usa el nombre del modelo (ej: User, Comment) o ruta completa"
  echo "  - Si el modelo no existe, pregunta si crear standalone"
  echo ""
  exit 0
}

# Mostrar ayuda si no hay argumentos o si se solicita explícitamente
if [ "$1" == "--help" ] || [ "$1" == "-h" ] || ([ $# -lt 2 ] && [ "$1" != "list" ] && [ "$1" != "list:models" ]); then
  show_help
fi

COMANDO="$1"
MODELO="$2"

if [ -z "$COMANDO" ]; then
  echo "❌ Falta el comando"
  show_help
fi

if [ -z "$MODELO" ] && [ "$COMANDO" != "list" ] && [ "$COMANDO" != "list:models" ]; then
  echo "❌ Falta el modelo"
  show_help
fi

# Ejecutar según comando
case "$COMANDO" in
  # Comandos CREATE
  create)
    echo "🚀 Creando todos los artefactos frontend para: $MODELO"
    
    # Verificar si es un modelo de Prisma
    if bash "$SCRIPT_DIR/check_model_exists.sh" "$MODELO"; then
      echo "🔍 Detectado: $MODELO es un modelo de Prisma - Generando automáticamente"
      bash "$SCRIPT_DIR/generate_apollo.sh" "$MODELO"
    else
      echo "❌ No se encontró modelo $MODELO en Prisma"
      echo "💡 ¿Quieres crear un feature standalone?"
      read -p "¿Crear como feature standalone? (y/n): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔍 Creando feature standalone: $MODELO"
        bash "$SCRIPT_DIR/generate_apollo.sh" "$MODELO" "standalone"
      else
        echo "❌ Operación cancelada"
        exit 0
      fi
    fi
    
    echo "✅ Todos los artefactos frontend creados con éxito para: $MODELO"
    ;;
  create:gq)
    bash "$SCRIPT_DIR/generate_queries.sh" "$MODELO"
    ;;
  create:gm)
    bash "$SCRIPT_DIR/generate_mutations.sh" "$MODELO"
    ;;
  create:gf)
    bash "$SCRIPT_DIR/generate_fragments.sh" "$MODELO"
    ;;
  create:gt)
    bash "$SCRIPT_DIR/generate_apollo.sh" "$MODELO"
    ;;
  # Comandos REMOVE
  remove)
    echo "🗑️  Eliminando todos los artefactos frontend para: $MODELO"
    bash "$SCRIPT_DIR/remove_all.sh" "$MODELO"
    echo "✅ Todos los artefactos frontend eliminados para: $MODELO"
    ;;
  remove:gq)
    bash "$SCRIPT_DIR/remove_queries.sh" "$MODELO"
    ;;
  remove:gm)
    bash "$SCRIPT_DIR/remove_mutations.sh" "$MODELO"
    ;;
  remove:gf)
    bash "$SCRIPT_DIR/remove_fragments.sh" "$MODELO"
    ;;
  remove:gt)
    bash "$SCRIPT_DIR/remove_apollo.sh" "$MODELO"
    ;;
  # Comandos LIST
  list)
    bash "$SCRIPT_DIR/list_features.sh"
    ;;
  list:models)
    bash "$SCRIPT_DIR/list_models.sh"
    ;;
  *)
    echo "❌ Comando no reconocido: $COMANDO"
    show_help
    ;;
esac

# Mensaje final
echo ""
echo "────────────────────────────────────────────────────────────"
echo "✅ Acción completada por Clix CLI Frontend"
echo ""
echo "🔎 Revisa y valida manualmente el archivo generado."
echo "🛠️  Si notas algo incorrecto o quieres proponer mejoras, no dudes en colaborar."
echo "────────────────────────────────────────────────────────────"
