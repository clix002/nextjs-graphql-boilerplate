import type { IContext } from "@/config/types";
import type {
  QueryResolvers,
  SysUser,
  SysUsersPaginatedResponse,
} from "@/core/api/graphql/generated/backend";
import sysUserUseCase from "@/core/usecase/sys-user/sys-user.usecase";

export const SysUserQueries: QueryResolvers<IContext> = {
  getSysUserById: async (_, args, context) =>
    (await sysUserUseCase.getSysUserById(args, context)) as unknown as SysUser,
  getAllSysUsers: async (_, _a, context) =>
    (await sysUserUseCase.getAllSysUsers(context)) as unknown as SysUser[],
  getSysUsersPaginated: async (_, args, context) =>
    (await sysUserUseCase.getSysUsersPaginated(
      args,
      context,
    )) as unknown as SysUsersPaginatedResponse,
};
