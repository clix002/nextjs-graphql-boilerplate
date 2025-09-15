import type { IContext, IContextWithSelectFactory } from "@/config/types";
import type {
  MutationCreateSysUserArgs,
  MutationUpdateSysUserByIdArgs,
  QueryGetSysUserByIdArgs,
  QueryGetSysUsersPaginatedArgs,
  SysUser,
} from "@/core/api/graphql/generated/backend";
import { throwGraphQLError } from "@/core/domain/utils/errors";
import { validateForBackend } from "@/core/domain/utils/validation";
import {
  CreateSysUserSchema,
  UpdateSysUserSchema,
} from "@/shared/domain/schemas/sys-user/sys-user.schemas";

type IContextWithSelect = IContextWithSelectFactory<SysUser>;

class SysUserUseCase {
  async getSysUserById(
    args: QueryGetSysUserByIdArgs,
    context: IContextWithSelect,
  ) {
    const { id } = args;

    const sysUser = await context.prisma.sysUser.findUnique({
      where: {
        id,
      },
      ...(context.select && { select: context.select }),
    });

    return sysUser;
  }

  async createSysUser(args: MutationCreateSysUserArgs, context: IContext) {
    const { input } = args;

    const validatedInput = validateForBackend(CreateSysUserSchema, input);

    const existingUser = await context.prisma.sysUser.findUnique({
      where: {
        email: validatedInput.email,
      },
      select: {
        id: true,
      },
    });

    if (existingUser) {
      throwGraphQLError(
        "El email ya está registrado",
        "EMAIL_ALREADY_EXISTS",
        "email",
      );
    }

    const newUser = await context.prisma.sysUser.create({
      data: {
        ...validatedInput,
      },
    });

    return newUser;
  }

  async getAllSysUsers(context: IContext) {
    return await context.prisma.sysUser.findMany({});
  }

  async getSysUsersPaginated(
    args: QueryGetSysUsersPaginatedArgs,
    context: IContext,
  ) {
    const { options } = args;
    return await context.prisma.sysUser
      .paginate({
        orderBy: { createdAt: "desc" },
      })
      .withPages(options);
  }

  async updateSysUserById(
    args: MutationUpdateSysUserByIdArgs,
    context: IContext,
  ) {
    const { input, id } = args;

    const validatedInput = validateForBackend(UpdateSysUserSchema, input);

    const existingUser = await this.getSysUserById(
      { id: id as string },
      { ...context, select: { id: true, email: true } },
    );

    if (!existingUser) {
      throwGraphQLError("Usuario no encontrado", "USER_NOT_FOUND", "id");
    }

    const updatedUser = await context.prisma.sysUser.update({
      where: { id: id as string },
      data: validatedInput,
    });

    return updatedUser;
  }

  async deleteSysUserById(args: { id: string }, context: IContext) {
    const { id } = args;

    const existingUser = await this.getSysUserById(
      { id: id as string },
      { ...context, select: { id: true } },
    );

    if (!existingUser) {
      throwGraphQLError("Usuario no encontrado", "USER_NOT_FOUND", "id");
    }

    const deletedUser = await context.prisma.sysUser.delete({
      where: { id },
    });

    return deletedUser;
  }
}

const sysUserUseCase = new SysUserUseCase();
export default sysUserUseCase;
