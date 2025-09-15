import { z } from "zod";

// Schema base para SysUser
export const SysUserSchema = z.object({
  id: z.string().optional(),
  firstName: z.string().min(1, "El nombre es requerido"),
  lastName: z.string().optional(),
  email: z.string().email("Email inválido"),
});

// Schema para crear SysUser
export const CreateSysUserSchema = SysUserSchema.omit({
  id: true,
});

// Schema para actualizar SysUser
export const UpdateSysUserSchema = SysUserSchema.partial().omit({
  id: true,
});

// Tipos TypeScript
export type SysUserType = z.infer<typeof SysUserSchema>;
export type CreateSysUserInput = z.infer<typeof CreateSysUserSchema>;
export type UpdateSysUserInput = z.infer<typeof UpdateSysUserSchema>;
