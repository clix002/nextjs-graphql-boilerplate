import type { IContext } from "@/config/types";
import type {
  MutationCreateSysUserArgs,
  QueryGetSysUserByIdArgs,
  QueryGetSysUsersPaginatedArgs,
} from "@/core/api/graphql/generated/backend";
import { throwGraphQLError } from "@/core/domain/utils/errors";
import { validateForBackend } from "@/core/domain/utils/validation";
import { CreateSysUserSchema } from "@/shared/domain/schemas/sys-user/sys-user.schemas";

class SysUserUseCase {
  async getSysUserById(args: QueryGetSysUserByIdArgs, context: IContext) {
    const { id } = args;

    const sysUser = await context.prisma.sysUser.findUnique({
      where: { id },
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
}

const sysUserUseCase = new SysUserUseCase();
export default sysUserUseCase;
