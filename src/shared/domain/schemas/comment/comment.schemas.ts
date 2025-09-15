import { z } from "zod";

// Schema base para Comment
export const CommentSchema = z.object({
  id: z.string().optional(),
  content: z.string().min(1, "El contenido es requerido"),
  authorId: z.string().min(1, "El ID del autor es requerido"),
});

// Schema para crear Comment
export const CreateCommentSchema = CommentSchema.omit({
  id: true,
});

// Schema para actualizar Comment
export const UpdateCommentSchema = CommentSchema.partial().omit({
  id: true,
});

// Tipos TypeScript
export type CommentType = z.infer<typeof CommentSchema>;
export type CreateCommentInput = z.infer<typeof CreateCommentSchema>;
export type UpdateCommentInput = z.infer<typeof UpdateCommentSchema>;
