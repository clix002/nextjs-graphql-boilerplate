import { createPaginator } from "@/core/domain/services/pagination/createPaginator";

const paginate = createPaginator({
  pages: {
    limit: 15,
  },
});

/**
 * Configuración de modelos con paginación
 *
 * Solo agrega aquí los nombres de tus modelos y ya!
 */
export const paginationModels = {
  sysUser: { paginate },
  comment: { paginate },
} as const;
