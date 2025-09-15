import type { IContext } from "@/config/types";
import type {
  MutationResolvers,
  SysUser,
} from "@/core/api/graphql/generated/backend";
import sysUserUseCase from "@/core/usecase/sys-user/sys-user.usecase";

export const SysUserMutations: MutationResolvers<IContext> = {
  createSysUser: async (_, args, context) =>
    (await sysUserUseCase.createSysUser(args, context)) as unknown as SysUser,
  updateSysUserById: async (_, args, context) =>
    (await sysUserUseCase.updateSysUserById(
      args,
      context,
    )) as unknown as SysUser,
  deleteSysUserById: async (_, args, context) =>
    (await sysUserUseCase.deleteSysUserById(
      args,
      context,
    )) as unknown as SysUser,
};
