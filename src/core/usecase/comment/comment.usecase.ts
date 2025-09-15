import { GraphQLError } from "graphql";
import type { IContext } from "@/config/types";
import type {
  MutationCreateCommentArgs,
  QueryGetCommentByIdArgs,
} from "@/core/api/graphql/generated/backend";
import { validateForBackend } from "@/core/domain/utils/validation";
import { CreateCommentSchema } from "@/shared/domain/schemas/comment/comment.schemas";

class CommentUseCase {
  // Obtener Comment por ID
  async getCommentById(args: QueryGetCommentByIdArgs, context: IContext) {
    const { id } = args;

    const comment = await context.prisma.comment.findUnique({
      where: { id },
    });

    return comment;
  }

  // Crear Comment
  async createComment(args: MutationCreateCommentArgs, context: IContext) {
    const { input } = args;

    // Debug: verificar que input existe
    if (!input) {
      throw new GraphQLError("Input es requerido", {
        extensions: { code: "MISSING_INPUT" },
      });
    }

    // 1. Validar los datos de entrada con Zod
    const validatedInput = validateForBackend(CreateCommentSchema, input);

    // 2. Validar campos únicos (ejemplo con email)
    // TODO: Agregar validaciones de campos únicos según tu modelo
    // const existingUser = await context.prisma.comment.findUnique({
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
    const newComment = await context.prisma.comment.create({
      data: {
        ...validatedInput, // Pasa todos los campos automáticamente
      },
    });

    return newComment;
  }

  // TODO: Agregar más métodos según necesites
  // Ejemplo:
  // async getAllComments(context: IContext) {
  //   return await context.prisma.comment.findMany();
  // },
}

const commentUseCase = new CommentUseCase();
export default commentUseCase;
